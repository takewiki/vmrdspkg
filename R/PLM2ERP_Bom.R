#########################################################################
# APP00000005   占位，不做处理
# BOM00000002   新增BOM，版本不变
# PRD00000004   新增BOM,修改，正式发布，版本不变
# ECN00000002   新增BOM，版本提升
# 版本号作为文本进行处理，不留历史版本
# 历史版本进入中台
# BOM历史版本与生产投料单进行核对
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
#
#
#
#########################################################################
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





#' BOM获取最新的内码
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' BOM_getNewInterId()
BOM_getNewInterId <- function(conn=conn_vm_erp_test()) {

  sql <- paste0("select max(FInterID )+1 as FInterId from ICBOM")
  r <- tsda::sql_select(conn,sql)
  res = r$FInterId

  return(res)
}

#' 获取BOM新增的模板_表体部分
#'
#' @param BOMRevCode 子项BOM版本号
#' @param PLMBatchnum  批号
#' @param FLowCode  流程低位码
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' BOM_getNewBillTpl_Body()
BOM_getNewBillTpl_Body <- function(conn=conn_vm_erp_test(),
                                   BOMRevCode='TCB100181/A',
                                   PLMBatchnum='BOM00000002',
                                   FLowCode =2

) {
  #思路可以有
  #获取模板数据
  sql <- paste0("select * from  rds_icbom_tpl_body")
  data_tpl <- tsda::sql_select(conn,sql)
  #print(length(names(data_tpl)))
  #获取实际数据
  sql_bom <- paste0("select FSubItemId as FItemID,FSubUnitId as FUnitID,BOMCount as FQty
   from  [vw_PLMtoERP_BOM]
  where BOMRevCode='",BOMRevCode,"' and PLMBatchnum='",PLMBatchnum,"'
  and CMCode <>'' and FLowCode = ",FLowCode)
  data_bom <- tsda::sql_select(conn,sql_bom)

  ncount <- nrow(data_bom)

  #上传数据库
  if(ncount >0){
    #检验实际获得的数据
    data_p <- tsdo::df_rowRepMulti(data_tpl,times = ncount)
    #针对数据进行替换
    data_p$FItemID <- data_bom$FItemID
    data_p$FEntryID <- 1:ncount
    data_p$FInterID <- rep(BOM_getNewInterId(conn = conn),ncount)
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


#' bom将PLM的版本转化为ERP中需要的版本
#'
#' @param conn 连接
#' @param version_plm plm版本
#'
#' @return 返回ERP中的版本从001开始
#' @export
#'
#' @examples
#' bom_getVersion()
bom_getVersion <- function(conn=conn_vm_erp_test(),version_plm='A') {
  sql <- paste0("select FVersion_ERP from rds_BOM_version
where FVersion_PLM ='",version_plm,"'")
  r <- tsda::sql_select(conn,sql)
  res <- r$FVersion_ERP[1]
  return(res)

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
  sql <- paste0("select * from  rds_icbom_tpl_head")
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
    data_p$FParentID <- data_bom$FProductGroupId

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
    sql_write_bom_head <- paste0("INSERT INTO ICBom(FInterID,FBomNumber,FBrNo,FTranType,FCancellation,FStatus,FVersion,FUseStatus,FItemID,FUnitID,FAuxPropID,FAuxQty,FYield,FNote,FCheckID,FCheckDate,FOperatorID,FEntertime,FRoutingID,FBomType,FCustID,FParentID,FAudDate,FImpMode,FPDMImportDate,FBOMSkip,FUseDate,FHeadSelfZ0135,FPrintCount)
select *   from rds_icbom_input ")
    tsda::sql_update(conn,sql_write_bom_head)
    #清空缓存表
    sql_clear_bom_body_input <- paste0("truncate table  rds_icbom_input ")
    tsda::sql_update(conn,sql_clear_bom_body_input)

  }




}




