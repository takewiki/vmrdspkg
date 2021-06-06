############################################################
#  用于处理BOM在ERP系统中逻辑
#  由于BOM单号由PLM系统生成，因此不需要在ERP系统中生成
#  但是内码需要进行进行
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
#
#
#
##########################################################################
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


#' BOM获取单据编码的组别
#'
#' @param FItemNumber 物料编码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' bom_getBillGroup()
bom_getBillGroup <- function(FItemNumber='2.104.20.00026') {
  #print(FItemNumber)
  my_str <-  strsplit(FItemNumber,'\\.')
  #print(my_str)
  res <-paste0(my_str[[1]][2:3],collapse = ".")
 # print(res)
  return(res)


}


#' 获取BOM单据编号的组别
#'
#' @param conn 连接
#' @param FItemNumber 单据编号
#'
#' @return 返回组别内码
#' @export
#'
#' @examples
#' bom_getBillGroupID()
bom_getBillGroupID <- function(conn=conn_vm_erp_test(),FItemNumber='2.104.20.00026') {
  billGroupNumber = bom_getBillGroup(FItemNumber)
  sql <- paste0("	 select  FInterID  from ICBOMGroup
	 where FNumber = '",billGroupNumber,"'")
  r <- tsda::sql_select(conn,sql)
  ncount <- nrow(r)
  if (ncount >0){
    res <- r$FInterID
  }else{
    #取未分配值
    sql <- paste0("	 select  FInterID  from ICBOMGroup
	 where FNumber = '999'")
    r <- tsda::sql_select(conn,sql)
    res <- r$FInterID


  }
  return(res)


}




