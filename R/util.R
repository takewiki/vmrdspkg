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


#' 设置BOM单号的最大流水号
#'
#' @param conn
#'
#' @return
#' @export
#'
#' @examples
BOM_setNewBillNo <- function(conn=conn_vm_erp_test()) {


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
#' @param conn 连接
#' @param data_bom 新增的BOM数据
#'
#' @return 返回值
#' @export
#'
#' @examples
#' BOM_getNewBillTpl()
BOM_getNewBillTpl_Body <- function(conn=conn_vm_erp_test(),data_bom) {
     #思路可以有

   sql <- paste0("select * from  rds_ICBomChild_tpl")
   data_tpl <- tsda::sql_select(conn,sql)
   ncount <- nrow(data_bom)
   data_p <- tsdo::df_rowRepMulti(data_tpl,times = ncount)
   #针对数据进行替换
   data_p$FItemID <- data_bom$FItemID
   data_p$FEntryID <- 1:ncount
   data_p$FInterID <- rep(BOM_getNewInterId(conn = conn),ncount)
   data_p$FUnitID <- data_bom$FUnitID
   data_p$FQty <- data_bom$FQty
   data_p$FAuxQty <- data_bom$FQty
   #上传数据库
   if(ncount >0){
     tsda::db_writeTable(conn = conn,table_name = 'ICBomChild',r_object = data_p,append = T)
   }

}



BOM_getNewBillTpl_Head <- function(conn=conn_vm_erp_test(),data_bom) {



}






