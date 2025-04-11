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
  #更新只过滤使用状态的BOM

  sql <- paste0("select FInterID  from ICBOM  a
inner join t_ICItem i
on a.FItemID = i.fitemid
where i.FNumber ='",PMCode,"'  and a.FUseStatus =1072 ")

  r <- tsda::sql_select(conn,sql)
  ncount <- nrow(r)
  if(ncount >0){
    #确认一下一个产品是否会有2个BOM
    #这种处理有点欠妥啊  20220218
    res <- r$FInterID[1]
  }else{
    res<- BOM_getNewInterId(conn=conn)
  }

  return(res)

}

#' 获取BOM的产品版本信息
#'
#' @param conn 连接
#' @param PMCode 代码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' bom_getBomVersionNumber()
bom_getBomVersionNumber <- function(conn=conn_vm_erp_test(),PMCode='2.104.20.00034') {

  # 待更新

  sql <- paste0("select a.FVersion  from ICBOM  a
inner join t_ICItem i
on a.FItemID = i.fitemid
where i.FNumber ='",PMCode,"'")
  r <- tsda::sql_select(conn,sql)
  ncount <- nrow(r)
  if(ncount >0){
    #确认一下一个产品是否会有2个BOM
    res <- r$FVersion[1]
  }else{
    res<- NULL
  }

  return(res)

}



#0. BOM在ERP中处理的核心函数-----------



#' 获取BOM新增的模板_表体部分
#'
#' @param PLMBatchnum  批号
#' @param conn 连接
#' @param PMCode 更新产品编码
#' @param FInterID id
#'
#' @return 返回值
#' @include C_util.R
#' @export
#'
#' @examples
#' BOM_getNewBillTpl_Body()
BOM_getNewBillTpl_Body <- function(conn=conn_vm_erp_test(),
                                   PMCode='2.104.20.00034',
                                   PLMBatchnum='BOM00000002',FInterID =0


) {
  #思路可以有
  #增加BOM已经存在的更新逻辑

  #获取模板数据
  sql <- paste0("select * from  rds_icbom_tpl_body")
  data_tpl <- tsda::sql_select(conn,sql)
  ##print(length(names(data_tpl)))
  #获取实际数据
  sql_bom <- paste0("select distinct FSubItemId as FItemID,FSubUnitId as FUnitID,BOMCount as FQty
   from  [vw_PLMtoERP_BOM2]
  where PMCode ='",PMCode,"' and PLMBatchnum='",PLMBatchnum,"'
  and CMCode <>'' ")
  #print(sql_bom)
  data_bom <- tsda::sql_select(conn,sql_bom)
  #print('data_bom')
  #View(data_bom)
  #print(data_bom)

  ncount <- nrow(data_bom)

  #上传数据库
  if(ncount >0){
    #检验实际获得的数据
    data_p <- tsdo::df_rowRepMulti(data_tpl,times = ncount)
    #释放内存
    rm(data_tpl)
    #针对数据进行替换
    data_p$FItemID <- data_bom$FItemID
    data_p$FEntryID <- 1:ncount
    # 针对内码进行处理
    var_InterID <- FInterID

    #如果已经存在内码
    #data_p$FInterID <- rep(BOM_getNewInterId(conn = conn),ncount)
    data_p$FInterID <- rep(var_InterID,ncount)






    data_p$FUnitID <- data_bom$FUnitID
    data_p$FQty <- as.numeric(data_bom$FQty)
    data_p$FAuxQty <- as.numeric(data_bom$FQty)
    data_p$FPDMImportDate <-''
    data_p$FEntrySelfZ0144 <- 0
    data_p$FEntrySelfZ0145 <- 0
    #View(data_p)
    #openxlsx::write.xlsx(data_p,'data_bom.xlsx')
    #str(data_p)
    #写入BOM缓存表
    print(data_p)
    #tsda::db_writeTable(conn = conn,table_name = 'rds_icbomChild_input',r_object = data_p,append = F)
    tsda::db_writeTable(conn = conn,table_name = 'rds_icbomChild_input',r_object = data_p,append = F)
    #释放内存
    rm(data_p)
    #将数据写入正式表
    sql_write_bom_body <- paste0("INSERT INTO ICBomChild (FInterID,FEntryID,FBrNo,FItemID,FAuxPropID,FUnitID,FMaterielType,FMarshalType,FQty,FAuxQty,FBeginDay,FEndDay,FPercent,FScrap,FPositionNo,FItemSize,FItemSuite,FOperSN,FOperID,FMachinePos,FOffSetDay,FBackFlush,FStockID,FSPID,FNote,FNote1,FNote2,FNote3,FPDMImportDate,FDetailID,FCostPercentage,FEntrySelfZ0142,FEntrySelfZ0144,FEntrySelfZ0145,FEntrySelfZ0146,FEntrySelfZ0148)
select *   from rds_icbomChild_input ")
    tsda::sql_update(conn,sql_write_bom_body)
    #fix the FDetailId Error
    sql_updateDetailID <- paste0(" update  a set  FDetailID =NEWID()  from  ICBOMchild  a   where finterid =  ",var_InterID)
    tsda::sql_update(conn, sql_updateDetailID )

    #清空缓存表
    sql_clear_bom_body_input <- paste0("truncate table  rds_icbomChild_input ")
    tsda::sql_update(conn,sql_clear_bom_body_input)

  }
  #回收内存BOM_getNewBillTpl_Body
  gc()
}




#' 检验BOM是否新版本
#'
#' @param conn 连接
#' @param FBOMNumber BOM
#' @param FVersion 版本号
#'
#' @return 返回值
#' @export
#'
#' @examples
#' bom_check_is_newVersion()
bom_check_is_newVersion <- function(conn=conn_vm_erp_test(),
                                    FBOMNumber = 'BOM000001',
                                    FVersion='001'){
  sql <- paste0("select  * from ICBOM
where FBOMNumber = '",FBOMNumber,"' and FVersion='",FVersion,"'  and FUseStatus =1072")
  r <- tsda::sql_select(conn,sql)
  ncount <- nrow(r)
  if(ncount >0){
    res <- FALSE
  }else{
    res <- TRUE
  }
  return(res)

}

#' bom的批次回写规则
#'
#' @param batchNo  批号
#'
#' @return 返回值
#' @export
#'
#' @examples
#' bom_check_batchNo_overWrite()
bom_check_batchNo_overWrite <- function(batchNo ='PRD00000003'){
  r <- tsdo::left(batchNo,3)
  if( r == 'ECN' | r == 'BOM'){
    #ECN不回写
    #针对ECN及BOM情况，需要进一步判断是否版本升级，升级则回写，否则不回写
    #目前是所有情况都需要进行判断
    #不管什么情况，都要判断版本是否升级
    #目前PLMBATCHNO中的APPLY仅仅用于占位，没有实则性使用
    res <- FALSE
  }else{
    #其他进行回写
    #取消此路线，全部需要判断
    #res <- TRUE
    res <- FALSE
  }
  return(res)

}



#' 根据单据编号查询是否BOM跳层
#'
#' @param conn 连接
#' @param PMCode 物料代码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' BOM_getBomSkip()
BOM_getBomSkip <- function(conn=conn_vm_erp_test(),
                           PMCode =  '2.104.20.00034'){
  sql <- paste0("select FErpClsID from t_ICItem
where FNumber ='",PMCode,"'")
  data <- tsda::sql_select(conn,sql)
  ncount <- nrow(data)
  if(ncount >0){
    flag = data$FErpClsID[1]
    if(flag == 2){
      res <-1058
    }else{
      res <- 1059
    }
  }else{
    res <- 1059
  }
  return(res)

}

#' 针对BOM的表头数据进行处理
#'
#' @param conn 连接
#' @param PMCode 物料代码
#' @param PLMBatchnum  批号
#' @param FInterID id
#'
#' @return  返回值
#' @export
#'
#' @examples
#' BOM_getNewBillTpl_Head()
BOM_getNewBillTpl_Head <- function(conn=conn_vm_erp_test(),
                                   PMCode =  '2.104.20.00034',
                                   PLMBatchnum='BOM00000002',FInterID =0
) {
  #获取模板数据
  #取当前日期
  #针对数据加强内存回收
  var_date <- as.character(Sys.Date())
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
  #修复一下日期的Bug
  data_tpl <- tsda::sql_select(conn,sql)
  data_tpl$FCheckDate <- var_date
  data_tpl$FEntertime <- var_date
  data_tpl$FAudDate <- var_date
  data_tpl$FUseDate <- var_date
  #添加BOM跳层的判断
  data_tpl$FBOMSkip <- BOM_getBomSkip(conn = conn,PMCode = PMCode)


  #获取实际数据
  sql_bom <- paste0("select distinct  FParentItemId as FItemID,FParentUnitID as FUnitID,BOMRevCode,FProductGroupId  from  [vw_PLMtoERP_BOM]
  where  PLMBatchnum='",PLMBatchnum,"' and PMCode =  '",PMCode,"' and CMCode=''")
  data_bom <- tsda::sql_select(conn,sql_bom)

  ncount <- nrow(data_bom)
  #处理BC-BOM展开的情况
  sql_bc <- paste0("select distinct  FParentItemId as FItemID,FParentUnitID as FUnitID,BOMRevCode,FProductGroupId  from  [vw_PLMtoERP_BOM]
  where  PLMBatchnum='",PLMBatchnum,"' and PMCode =  '",PMCode,"' and CMCode='' and PLMOperation ='BC'" )
  data_bc <- tsda::sql_select(conn,sql_bc)
  ncount_bc <- nrow(data_bc)
  if(ncount_bc >0){
    #flag_bc  <- TRUE
    flag_bc <- FALSE
  }else{
    flag_bc <- FALSE
  }

  #上传数据库

  if(ncount >0){




    #检验实际获得的数据,实际数据使用
    data_p <- tsdo::df_rowRepMulti(data_tpl,times = ncount)
    #加强内存回收
    rm(data_tpl)

    bom_bill_version <- strsplit(data_bom$BOMRevCode,'/')
    data_p$FBomNumber <- bom_bill_version[[1]][1]
    data_p$FVersion <-bom_getVersion(conn = conn,version_plm = bom_bill_version[[1]][2])
    #可以根据BOm及版本信息进行判断是否写入
    #判断是否存在同版本
    #如果版本相同，则不需要回写
    if(bom_check_batchNo_overWrite(batchNo = PLMBatchnum)){
      #中路径从2022-02-18已经不再使用


      if(flag_bc){
        #BC物料不做处理
        flag = 0
        #print('A')
      }else{
        #执行over_write
        #写入BOM版本数据
        #针对数据进行替换
        data_p$FItemID <- data_bom$FItemID
        #data_p$FEntryID <- 1:ncount
        data_p$FInterID <- FInterID
        data_p$FUnitID <- data_bom$FUnitID

        #bom单号

        #BOM处于使用状态
        data_p$FUseStatus <- 1072
        #BOM版本号

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
        # openxlsx::write.xlsx(data_p,'data_bom_head.xlsx')
        #str(data_p)
        #处理BOM表头信息
        var_InterID <- FInterID
        sql_bak_history_bom_head <- paste0("	insert into rds_ICBOM
   select * from ICBOM where FInterID =  ",var_InterID)
        tsda::sql_update(conn,sql_bak_history_bom_head)
        #从正式表中删除掉
        sql_del_bom_head <- paste0(" delete  from ICBOM where FInterID =  ",var_InterID)
        tsda::sql_update(conn,sql_del_bom_head)


        #清空缓存表
        sql_clear_bom_body_input <- paste0("truncate table  rds_icbom_input ")
        tsda::sql_update(conn,sql_clear_bom_body_input)


        #写入BOM缓存表表头信息
        tsda::db_writeTable(conn = conn,table_name = 'rds_icbom_input',r_object = data_p,append = F)
        #删除数据，加强内存处理
        rm(data_p)
        #将数据写入正式表
        sql_write_bom_head <- paste0("INSERT INTO ICBom(FInterID,FBomNumber,FBrNo,FTranType,FCancellation,FStatus,FVersion,FUseStatus,FItemID,FUnitID,FAuxPropID,FAuxQty,FYield,FNote,FCheckID,FCheckDate,FOperatorID,FEntertime,FRoutingID,FBomType,FCustID,FParentID,FAudDate,FImpMode,FPDMImportDate,FBOMSkip,FUseDate,FHeadSelfZ0135)
select *   from rds_icbom_input ")
        tsda::sql_update(conn,sql_write_bom_head)
        #清空缓存表
        sql_clear_bom_body_input <- paste0("truncate table  rds_icbom_input ")
        tsda::sql_update(conn,sql_clear_bom_body_input)
        #end of bom----
        flag = 1
        #print('B')
      }

    }else{

      #针对ECN的情况
      #针对其他情况，包括新增BOM2022-02-18
      #print('test for bc bom version')
      #print(data_p$FBomNumber)
      #print(data_p$FVersion)

      if(bom_check_is_newVersion(conn = conn,FBOMNumber = data_p$FBomNumber ,FVersion = data_p$FVersion)){
        #执行覆盖
        #新版本
        #写入BOM版本数据
        #针对数据进行替换
        if(flag_bc){
          #bc物料不做处理
          flag =0
          #print('C')
        }else{
          data_p$FItemID <- data_bom$FItemID
          #data_p$FEntryID <- 1:ncount
          data_p$FInterID <- FInterID
          data_p$FUnitID <- data_bom$FUnitID

          #bom单号
          var_InterID <- FInterID

          #BOM处于使用状态
          data_p$FUseStatus <- 1072
          #BOM版本号

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
          # openxlsx::write.xlsx(data_p,'data_bom_head.xlsx')
          #str(data_p)
          #写入BOM缓存表表头信息
          sql_bak_history_bom_head <- paste0("	insert into rds_ICBOM
   select * from ICBOM where FInterID =  ",var_InterID)
          tsda::sql_update(conn,sql_bak_history_bom_head)
          #删除前加强检查
          sql_bom_head_check <- paste0("select 1 from  rds_ICBOM
    where FInterID =  ",var_InterID)
          data_bom_head_check = tsda::sql_select(conn,sql_bom_head_check)
          ncount_bom_head_check = nrow(data_bom_head_check)
          #数据的数据
          sql_bom_head_check2 <- paste0("select 1 from  ICBOM
    where FInterID =  ",var_InterID)
          data_bom_head_check2 = tsda::sql_select(conn,sql_bom_head_check2)
          ncount_bom_head_check2 = nrow(data_bom_head_check2)
          if(ncount_bom_head_check2  == 0){
            #变更逻辑，使其可以通过，说明是新增
            ncount_bom_head_check =1
          }

          #加载删除前检查
          if(ncount_bom_head_check >0){
            #已有数据，可以放心删除

            # 针对BOM数据进行处理，将数据写入历史缓存表
            sql_bak_history_bom_body <- paste0("	insert into rds_ICBOMChild
   select * from ICBOMChild where FInterID =  ",var_InterID)
            tsda::sql_update(conn,sql_bak_history_bom_body)
            #删除前加强检验
            sql_check_bom_body <- paste0("	select 1 from  rds_ICBOMChild
    where FInterID =  ",var_InterID)
            data_check_bom_body =  tsda::sql_select(conn,sql_check_bom_body)
            ncount_check_bom_body = nrow(data_check_bom_body)
            if(ncount_bom_head_check2 == 0){
              #针对新增的情况
              ncount_check_bom_body = 1
            }
            if(ncount_check_bom_body >0){
              #从正式表中删除掉,删除金蝶的表头，系统会自动删除表体
              sql_del_bom_head <- paste0(" delete  from ICBOM where FInterID =  ",var_InterID)
              tsda::sql_update(conn,sql_del_bom_head)
              tsda::db_writeTable(conn = conn,table_name = 'rds_icbom_input',r_object = data_p,append = T)
              #删除数据回收内存
              rm(data_p)
              #将数据写入正式表
              sql_write_bom_head <- paste0("INSERT INTO ICBom(FInterID,FBomNumber,FBrNo,FTranType,FCancellation,FStatus,FVersion,FUseStatus,FItemID,FUnitID,FAuxPropID,FAuxQty,FYield,FNote,FCheckID,FCheckDate,FOperatorID,FEntertime,FRoutingID,FBomType,FCustID,FParentID,FAudDate,FImpMode,FPDMImportDate,FBOMSkip,FUseDate,FHeadSelfZ0135)
select distinct *   from rds_icbom_input ")
              tsda::sql_update(conn,sql_write_bom_head)
              #清空缓存表
              sql_clear_bom_body_input <- paste0("truncate table  rds_icbom_input ")
              tsda::sql_update(conn,sql_clear_bom_body_input)

              flag =1
              #print('D')

            }






          }else{
            #start for e
            #表头数据没有备份，不允许删除
            flag = 0
            #print('E')
            #end for e
          }


        }







      }else{
        # 不进行覆盖
        flag = 0
        #print('F')

      }



    }









  }
  gc()

  return(flag)


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
  #取服务器时间
  #ERP_DATE = as.character(Sys.time())
  sql <- paste0("update a set  ERPOperation='R',ERPDate =  GETDATE()
              from PLMtoERP_BOM  a where PMCode ='",PMCode,"'
              and PLMBatchnum='",PLMBatchnum,"'")
  # sql <- paste0("update a set  ERPOperation='R',ERPDate =GETDATE()
  #               from PLMtoERP_BOM  a where PMCode ='",PMCode,"'
  #               and PLMBatchnum='",PLMBatchnum,"'")
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

  sql <- paste0("select distinct  PMCode,PLMBatchNum from  vw_PLMtoERP_BOM
where  cmcode ='' and  ERPDate is null ")
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
  #现在的变更逻辑是BOM版本有差异，就可以变成
  #除了ECN，需要包含BOM打头但做了版本升级的部分
  #已经修改了相应的视图
  #20220218
  #处理相应的逻辑，一般全部走快速发布
  #BOM的处理规则如下
  # 1） 如果单据编号存在，且版本一致，不更新。
  # 2）如果单据编码存在，且版本更高，做版本更新，
  # 3）如果单据编码不存在，删除历史的单据编号，同时做新增操作。
  # 同时数据误删


  bom_list <-  bom_getList(conn = conn)
  #print('bom_list')
  #print(bom_list)
  ncount = nrow(bom_list)

  if (ncount >0){

    lapply(1:ncount, function(i){
      PMCode <- bom_list$PMCode[i]
      PLMBatchnum <- bom_list$PLMBatchNum[i]

      #获取内码
      #只过滤使用状态的BOM

      FInterID = bom_getInterId(conn = conn,PMCode = PMCode)
      #针对BOM打头的物料，需要修改BOM表头信息
      #print('test1:bom_interid')
      #print(FInterID)

      flag = BOM_getNewBillTpl_Head(conn = conn,PMCode = PMCode,PLMBatchnum = PLMBatchnum,FInterID =FInterID )
      #处理BOM表头
      #print('flag for bom')
      #print(flag)

      if (flag >0){
        BOM_getNewBillTpl_Body(conn = conn,PMCode = PMCode,PLMBatchnum = PLMBatchnum,FInterID = FInterID)
        #更新BOM表的状态
        #只有在成功的状态下才更新状态，否则不再更新状态
        bom_readIntoERP_updateStatus(conn = conn,PMCode = PMCode,PLMBatchnum = PLMBatchnum)
      }else{
        #不再写入
      }


      #写入BOM报头
      gc()







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





#' 增加BOM导入前的预检验
#'
#' @param conn 连接
#' @param FNumber 代码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' ERP_BOM_preCheck()
ERP_BOM_preCheck <- function(conn=conn_vm_erp_test(),FNumber='0.109.06.03') {
  #物料检查

  sql1 <- paste0("select FItemID from t_ICItem where FNumber='",FNumber,"'")
  res1 <- tsda::sql_select(conn,sql1)
  ncount1 <- nrow(res1)
  #BOM检验
  sql2<- paste0("select FBOMNumber from ICBOM  a
inner join t_ICItem b
on a.FItemID = b.FItemID
where b.FNumber ='",FNumber,"'")
  res2 <- tsda::sql_select(conn,sql2)
  ncount2 <- nrow(res2)
  if(ncount1  > 0){
    if(ncount2 >0){
      info =2
    }else{
      info =1
    }

  }else{
    info = 0
  }

  return(info)

}











