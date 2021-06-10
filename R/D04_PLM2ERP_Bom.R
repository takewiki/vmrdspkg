#########################################################################
# APP00000005   占位，不做处理
# BOM00000002   新增BOM，版本不变，               BOM打头不处理
# PRD00000004   新增BOM,修改，正式发布，版本不变，BOM打头不处理
# ECN00000002   新增BOM，版本提升    ，           BOM打头处理
# BOM版本为BOM打头同时业务类型为ECN则进行变更
# 所有不做处理，日期的状态同步更新。
# 否则忽略
# 版本号作为文本进行处理，不留历史版本
# 历史版本进入中台
# BOM历史版本与生产投料单进行核对
# BOM单组别增加 999   未分类,根据物料编码进行判断   ok
# #BOM子项物料的排序，FEntryId可能影响成本计算
# #
#
#
#
#
#
#
#
#
#
#
#
#
#########################################################################




#' 获取BOM的内码
#'
#' @param conn 连接
#' @param PMCode 物料代码
#'
#' @return 返回BOM内码，为空则为0
#' @export
#'
#' @examples
#' bom_getInterId()
bom_getInterId <- function(conn=conn_vm_erp_test(),PMCode='2.104.20.00034') {

  sql <- paste0("select FInterID  from ICBOM  a
inner join t_ICItem i
on a.FItemID = i.fitemid
where i.FNumber ='",PMCode,"'")
  r <- tsda::sql_select(conn,sql)
  ncount <- nrow(r)
  if(ncount >0){
    #确认一下一个产品是否会有2个BOM
    res <- r$FInterID[1]
  }else{
    res<-0
  }

  return(res)

}

#0. BOM在ERP中处理的核心函数-----------



#' 获取BOM新增的模板_表体部分
#'
#' @param PLMBatchnum  批号
#' @param conn 连接
#' @param PMCode 更新产品编码
#'
#' @return 返回值
#' @include C_util.R
#' @export
#'
#' @examples
#' BOM_getNewBillTpl_Body()
BOM_getNewBillTpl_Body <- function(conn=conn_vm_erp_test(),
                                   PMCode='2.104.20.00034',
                                   PLMBatchnum='BOM00000002'


) {
  #思路可以有
  #增加BOM已经存在的更新逻辑

  #获取模板数据
  sql <- paste0("select * from  rds_icbom_tpl_body")
  data_tpl <- tsda::sql_select(conn,sql)
  #print(length(names(data_tpl)))
  #获取实际数据
  sql_bom <- paste0("select FSubItemId as FItemID,FSubUnitId as FUnitID,BOMCount as FQty
   from  [vw_PLMtoERP_BOM]
  where PMCode ='",PMCode,"' and PLMBatchnum='",PLMBatchnum,"'
  and CMCode <>'' ")
  data_bom <- tsda::sql_select(conn,sql_bom)
  print('data_bom')
  print(data_bom)

  ncount <- nrow(data_bom)

  #上传数据库
  if(ncount >0){
    #检验实际获得的数据
    data_p <- tsdo::df_rowRepMulti(data_tpl,times = ncount)
    #针对数据进行替换
    data_p$FItemID <- data_bom$FItemID
    data_p$FEntryID <- 1:ncount
    # 针对内码进行处理
    var_InterID <- bom_getInterId(conn = conn,PMCode = PMCode)
    #如果存在内码
    if(var_InterID >0){
      #如果已经存在内码
      data_p$FInterID <- rep(BOM_getNewInterId(conn = conn),ncount)
      # 针对BOM数据进行处理，将数据写入历史缓存表
      sql_bak_history_bom_body <- paste0("	insert into rds_ICBOMChild
   select * from ICBOMChild where FInterID =  ",var_InterID)
      tsda::sql_update(conn,sql_bak_history_bom_body)
      #从正式表中删除掉
      sql_del_bom_body <- paste0(" delete  from ICBOMChild where FInterID =  ",var_InterID)
      tsda::sql_update(conn,sql_del_bom_body)
      #处理BOM表头信息
      sql_bak_history_bom_head <- paste0("	insert into rds_ICBOM
   select * from ICBOM where FInterID =  ",var_InterID)
      tsda::sql_update(conn,sql_bak_history_bom_head)
      #从正式表中删除掉
      sql_del_bom_head <- paste0(" delete  from ICBOM where FInterID =  ",var_InterID)
      tsda::sql_update(conn,sql_del_bom_head)

    }else{
      data_p$FInterID <- rep(BOM_getNewInterId(conn = conn),ncount)

    }

    data_p$FUnitID <- data_bom$FUnitID
    data_p$FQty <- as.numeric(data_bom$FQty)
    data_p$FAuxQty <- as.numeric(data_bom$FQty)
    data_p$FPDMImportDate <-''
    data_p$FEntrySelfZ0144 <- 0
    data_p$FEntrySelfZ0145 <- 0
    #View(data_p)
    openxlsx::write.xlsx(data_p,'data_bom.xlsx')
    str(data_p)
    #写入BOM缓存表
    tsda::db_writeTable(conn = conn,table_name = 'rds_icbomChild_input',r_object = data_p,append = T)
    #将数据写入正式表
    sql_write_bom_body <- paste0("INSERT INTO ICBomChild (FInterID,FEntryID,FBrNo,FItemID,FAuxPropID,FUnitID,FMaterielType,FMarshalType,FQty,FAuxQty,FBeginDay,FEndDay,FPercent,FScrap,FPositionNo,FItemSize,FItemSuite,FOperSN,FOperID,FMachinePos,FOffSetDay,FBackFlush,FStockID,FSPID,FNote,FNote1,FNote2,FNote3,FPDMImportDate,FDetailID,FCostPercentage,FEntrySelfZ0142,FEntrySelfZ0144,FEntrySelfZ0145,FEntrySelfZ0146,FEntrySelfZ0148)
select *   from rds_icbomChild_input ")
    tsda::sql_update(conn,sql_write_bom_body)
    #清空缓存表
    sql_clear_bom_body_input <- paste0("truncate table  rds_icbomChild_input ")
    tsda::sql_update(conn,sql_clear_bom_body_input)

  }

}







#' 针对BOM的表头数据进行处理
#'
#' @param conn 连接
#' @param PMCode 物料代码
#' @param PLMBatchnum  批号
#'
#' @return  返回值
#' @export
#'
#' @examples
#' BOM_getNewBillTpl_Head()
BOM_getNewBillTpl_Head <- function(conn=conn_vm_erp_test(),
                                   PMCode =  '2.104.20.00034',
                                   PLMBatchnum='BOM00000002'
) {
  #获取模板数据
  sql <- paste0("SELECT [FInterID]
      ,[FBomNumber]
      ,[FBrNo]
      ,[FTranType]
      ,[FCancellation]
      ,[FStatus]
      ,[FVersion]
      ,[FUseStatus]
      ,[FItemID]
      ,[FUnitID]
      ,[FAuxPropID]
      ,[FAuxQty]
      ,[FYield]
      ,[FNote]
      ,[FCheckID]
      ,[FCheckDate]
      ,[FOperatorID]
      ,[FEntertime]
      ,[FRoutingID]
      ,[FBomType]
      ,[FCustID]
      ,[FParentID]
      ,[FAudDate]
      ,[FImpMode]
      ,[FPDMImportDate]
      ,[FBOMSkip]
      ,[FUseDate]
      ,[FHeadSelfZ0135]
  FROM [dbo].[rds_icbom_tpl_head]")
  data_tpl <- tsda::sql_select(conn,sql)
  #获取实际数据
  sql_bom <- paste0("select FParentItemId as FItemID,FParentUnitID as FUnitID,BOMRevCode,FProductGroupId  from  [vw_PLMtoERP_BOM]
  where  PLMBatchnum='",PLMBatchnum,"' and PMCode =  '",PMCode,"' and CMCode=''")
  data_bom <- tsda::sql_select(conn,sql_bom)

  ncount <- nrow(data_bom)

  #上传数据库
  if(ncount >0){
    #检验实际获得的数据
    data_p <- tsdo::df_rowRepMulti(data_tpl,times = ncount)
    #针对数据进行替换
    data_p$FItemID <- data_bom$FItemID
    #data_p$FEntryID <- 1:ncount
    data_p$FInterID <- rep(BOM_getNewInterId(conn = conn),ncount)
    data_p$FUnitID <- data_bom$FUnitID
    bom_bill_version <- strsplit(data_bom$BOMRevCode,'/')
    data_p$FBomNumber <- bom_bill_version[[1]][1]
    #BOM处于使用状态
    data_p$FUseStatus <- 1072
    data_p$FVersion <-bom_getVersion(conn = conn,version_plm = bom_bill_version[[1]][2])
    #组别采用新增规则，从物料编码上判断，取第2，3段，否则为未分类
    # 不再从中间表传递
    #data_p$FParentID <- data_bom$FProductGroupId
    data_p$FParentID <- bom_getBillGroupID(conn = conn,FItemNumber = PMCode)

    # data_p$FQty <- as.numeric(data_bom$FQty)
    # data_p$FAuxQty <- as.numeric(data_bom$FQty)
    # data_p$FPDMImportDate <-''
    # data_p$FEntrySelfZ0144 <- 0
    # data_p$FEntrySelfZ0145 <- 0
    #View(data_p)
    openxlsx::write.xlsx(data_p,'data_bom_head.xlsx')
    str(data_p)
    #写入BOM缓存表表头信息
    tsda::db_writeTable(conn = conn,table_name = 'rds_icbom_input',r_object = data_p,append = T)
    #将数据写入正式表
    sql_write_bom_head <- paste0("INSERT INTO ICBom(FInterID,FBomNumber,FBrNo,FTranType,FCancellation,FStatus,FVersion,FUseStatus,FItemID,FUnitID,FAuxPropID,FAuxQty,FYield,FNote,FCheckID,FCheckDate,FOperatorID,FEntertime,FRoutingID,FBomType,FCustID,FParentID,FAudDate,FImpMode,FPDMImportDate,FBOMSkip,FUseDate,FHeadSelfZ0135)
select *   from rds_icbom_input ")
    tsda::sql_update(conn,sql_write_bom_head)
    #清空缓存表
    sql_clear_bom_body_input <- paste0("truncate table  rds_icbom_input ")
    tsda::sql_update(conn,sql_clear_bom_body_input)

  }




}



#' 更新BOM的状态
#'
#' @param conn 连接
#' @param PMCode 产品代码
#' @param PLMBatchnum 批号
#'
#' @return 返回值
#' @export
#'
#' @examples
#' bom_readIntoERP_updateStatus()
bom_readIntoERP_updateStatus<- function(conn=conn_vm_erp_test(),
                                        PMCode =  '2.104.20.00034',
                                        PLMBatchnum='BOM00000002') {
sql <- paste0("update a set  ERPOperation='R',ERPDate =GETDATE()
              from PLMtoERP_BOM  a where PMCode ='",PMCode,"'
              and PLMBatchnum='",PLMBatchnum,"'")
try(
  tsda::sql_update(conn,sql)
)

}



#' 获取待处理的BOM清单
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' bom_getList()
bom_getList <- function(conn=conn_vm_erp_test()) {

  sql <- paste0("select PMCode,PLMBatchNum from  vw_PLMtoERP_BOM
where  cmcode ='' and  ERPDate is null
order by plmbatchnum,flowcode ")
  res <- tsda::sql_select(conn,sql)
  return(res)

}



#' 批量写入BOM逻辑更新
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' bom_readIntoERP_ALL()
bom_readIntoERP_ALL <- function(conn=conn_vm_erp_test()){

  bom_list <-  bom_getList(conn = conn)
  ncount = nrow(bom_list)

  if (ncount >0){

    lapply(1:ncount, function(i){
      PMCode <- bom_list$PMCode[i]
      PLMBatchnum <- bom_list$PLMBatchNum[i]

      #写入BOM表体
      BOM_getNewBillTpl_Body(conn = conn,PMCode = PMCode,PLMBatchnum = PLMBatchnum)
      #写入BOM报头
      BOM_getNewBillTpl_Head(conn = conn,PMCode = PMCode,PLMBatchnum = PLMBatchnum)
      #更新BOM表的状态
      bom_readIntoERP_updateStatus(conn = conn,PMCode = PMCode,PLMBatchnum = PLMBatchnum)





    })


  }


}








#1.1PLM系统中的BOM申请-------
#对ERP系统没有任何影响，不需要做任何任何不做版本更新
# 此时的BOM资料还没有完整
# 在PLM系统中起到占位的使用
PLM_BOM_Apply <- function(config_file = "config/conn_k3.R",data_bom) {

  sql <- paste0("/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [PMCode]
      ,[PMName]
      ,[BOMRevCode]
      ,[CMCode]
      ,[CMName]
      ,[ProductGroup]
      ,[BOMCount]
      ,[BOMUOM]
      ,[PLMOperation]
      ,[ERPOperation]
      ,[PLMDate]
      ,[ERPDate]
      ,[FInterId]
      ,[RootCode]
      ,[FLowCode]
      ,[PLMBatchnum]
  FROM [TC4K3DB].[dbo].[PLMtoERP_BOM]
  where PLMBatchnum='APP00000005'")

}


# 1.2 PLM中的BOM正式发布------
# 正式发布，需要在ERP系统中生产001版本的完整的BOM
# 这是针对APPLY 版本BOM的完善，也是真正意义上的ERP系统中的BOM
#' BOM正式发布
#'
#' @param config_file 配置文件
#' @param data_bom BOM数据
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_BOM_Release()
PLM_BOM_Release <- function(config_file = "config/conn_k3.R",data_bom) {

}


#1.3PLM系统中的BOM的版升级，简称工程变更ECN-------
# 目前PLM传递的新版本的BOM也是完整的BOM
# 相对于原来的BOM做了版本升级
# 初步沟通ERP系统中的历史版本的BOM进入中台
# ERP系统中只保留一个最新状态最新版本的BOM
# 需要核实一下生产股料单上有没有记录BOM版本号
# 原则上可能没有记录
# 需要在ERP系统中新建BOM
#' PLM-BOM的工程变更与版本升级
#'
#' @param config_file 配置文件
#' @param data_bom BOM数据
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_BOM_ECN()
PLM_BOM_ECN <- function(config_file = "config/conn_k3.R",data_bom) {

}










