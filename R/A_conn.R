# 0.版权申明-----
# 本文用于设置测试数据库连接信息
# 本库为项目私有库不用于对外公开
# 版本归上海棱星数据技术有限公司所有,保留所有版权
# 作者:胡立磊
# 邮箱:hulilei@takewiki.com.cn
# 日期:2021年06月06日
# 1.ERP连接信息信息-----
#    1.1RDS测试环境ERP配置-------
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

#1.2 域华电子生产环境的测试ERP设置-----
#' 生产环境的测试数据库
#'
#' @return 返回链接
#' @export
#'
#' @examples
#' conn_vm_erp_prd_aux()
conn_vm_erp_test2_aux <- function() {
  res <-tsda::sql_conn_common(ip = '192.168.0.110',user_name = 'sa',password = 'Vxmt$h5502',db_name = 'AIS20200629100920')
  return(res)

}

#' 域华电子生产环境的测试设置
#'
#' @return 返回链接
#' @export
#'
#' @examples
#' conn_vm_erp_test2()
conn_vm_erp_test2 <- function() {
  #获取链接信息
  res <-conn_vm_erp_test2_aux()
  return(res)

}

# 1.3 域华电子生产环境的ERP连接设置-----
#' 生产环境的正式数据库
#'
#' @return 返回值
#' @export
#'
#' @examples
#' conn_vm_erp_prd_aux()
conn_vm_erp_prd_aux <- function() {
  res <-tsda::sql_conn_common(ip = '192.168.0.110',user_name = 'sa',password = 'Vxmt$h5502',db_name = 'AIS20140904110155')
  return(res)

}

#' 域华生产环境的连接数库设置
#'
#' @return
#' @export
#'
#' @examples
#' conn_vm_erp_prd()
conn_vm_erp_prd <- function() {
  #获取链接信息
  res <-conn_vm_erp_prd_aux()
  return(res)

}


# 2.0 PLM链接信息设置-------
# 2.1 测试环境的PLM连接信息设置-----

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

# 2.2 生产环境的PLM连接信息设置-----

conn_vm_plm_prd_aux <- function() {
  res <-tsda::sql_conn_common(ip = '192.168.0.16',user_name = 'infodba',password = 'infodba',db_name = 'TC4K3DB')
  return(res)

}

#' 生产环境的连接信息配置
#'
#' @return 返回值
#' @export
#'
#' @examples
#' conn_vm_plm_prd()
conn_vm_plm_prd <- function() {
  #获取链接信息
  res <-conn_vm_plm_prd_aux()
  return(res)

}













