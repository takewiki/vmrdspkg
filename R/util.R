#获取BOM单号信息
#' 获取BOM的最新单据编号
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' BOM_getNewBillNo()
BOM_getNewBillNo <- function(conn=conn_vm_erp_test()) {

  sql <- paste0("select  FProjectVal  from t_BillCodeRule where FBillTypeID =50
order by FClassIndex")
  r <- tsda::sql_select(conn,sql)
  value = r$FProjectVal
  prefix = value[1]
  series_no = value[2]
  nlen = nchar(series_no)
  #增加补位符号,6位
  str_mid = paste0(rep('0',6-nlen),collapse = '')
  #print(str_mid)
  res <- paste0(prefix,str_mid,series_no)
  return(res)
}



#' 获取BOM单号流水号的最大值并转化为数值型
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' BOM_getMaxBillValue()
BOM_getMaxBillValue <- function(conn=conn_vm_erp_test()) {

  sql <- paste0("select    FProjectVal   from t_BillCodeRule  a where FBillTypeID =50
and FProjectID =3")
  r <- tsda::sql_select(conn,sql)
  #获取的是字符串，然后返回是数值型
  res = as.integer(r$FProjectVal)


  return(res)
}

#' 设置BOM单号的最大流水号
#'
#' @param conn 连接
#' @param ncount 数量
#'
#' @return 返回值
#' @export
#'
#' @examples
#' BOM_setNewBillNo()
BOM_setNewBillNo <- function(conn=conn_vm_erp_test(),ncount=1) {
  #获取最大号
  value = BOM_getMaxBillValue(conn = conn)
  next_value =  value + ncount
  value_next2 =  as.character(next_value)
  #更新相应的BOM号吗
  sql_update <- paste0("update a set FProjectVal ='",value_next2,"'  from t_BillCodeRule  a where FBillTypeID =50
and FProjectID =3")
  tsda::sql_update(conn,sql_str = sql_update)


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



BOM_getNewBillTpl_Head <- function(conn=conn_vm_erp_test(),
                                   BOMRevCode='TCB100181/A',
                                   PLMBatchnum='BOM00000002',
                                   FLowCode =2) {
  #获取模板数据
  sql <- paste0("select * from  rds_icbom_tpl_body")
  data_tpl <- tsda::sql_select(conn,sql)
  #




}






