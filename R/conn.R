
#' 测试环境ERP的连接参数设置
#'
#' @return 返回数据链接
#'
#' @examples
#' conn_vm_erp_test_aux()
conn_vm_erp_test_aux <- function() {
  res <-tsda::sql_conn_common(ip = '123.207.201.140',user_name = 'sa',password = 'rds@2020',db_name = 'AIS20140904110155')
  return(res)

}


#' 测试环境PLM的连接参数设置
#'
#' @return 返回链接信息
#'
#' @examples
#'  conn_vm_plm_test_aux()
conn_vm_plm_test_aux <- function() {
  res <-tsda::sql_conn_common(ip = '123.207.201.140',user_name = 'sa',password = 'rds@2020',db_name = 'TC4K3DB')
  return(res)

}




#' VM公司的测试环境的ERP设置
#'
#' @return 返回测试链接
#' @export
#'
#' @examples
#' conn_vm_erp_test()
conn_vm_erp_test <- function() {
  #获取链接信息
  res <-conn_vm_erp_test_aux()
  return(res)

}



#' VM公司的测试环境的PLM设置
#'
#' @return 返回测试链接
#' @export
#'
#' @examples
#' conn_vm_plm_test()
conn_vm_plm_test <- function() {
  #获取链接信息
  res <-conn_vm_plm_test_aux()
  return(res)

}




