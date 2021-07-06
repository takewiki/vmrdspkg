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

conn_vm_erp_prd_aux2 <- function() {
  res <-tsda::sql_conn_common(ip = '192.168.0.2',user_name = 'rds',password = 'rds@2021',db_name = 'AIS20140904110155')
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


#' 域华生产环境的连接数库设置
#'
#' @return
#' @export
#'
#' @examples
#' conn_vm_erp_prd2()
conn_vm_erp_prd2 <- function() {
  #获取链接信息
  res <-conn_vm_erp_prd_aux2()
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



conn_vm_plm_prd_aux2 <- function() {
  res <-tsda::sql_conn_common(ip = '192.168.0.9',user_name = 'infodba',password = 'infodba',db_name = 'TC4K3DB')
  return(res)

}

#' 生产环境的连接信息配置
#'
#' @return 返回值
#' @export
#'
#' @examples
#' conn_vm_plm_prd2()
conn_vm_plm_prd2 <- function() {
  #获取链接信息
  res <-conn_vm_plm_prd_aux2()
  return(res)

}


#' 读取配置文件并获取连接信息
#'
#' @param file_name 文件名
#'
#' @return 返回值
#' @export
#'
#' @examples
#' conn_config_read()
conn_config_read <- function(file_name="config/conn_erp.xlsx"){
  #library(readxl)
  data <- readxl::read_excel(file_name,
                         sheet = "conn")
  ip =  as.character(data$ip[1])
  user_name = as.character(data$user_name[1])
  password = as.character(data$password[1])
  db_name = as.character(data$db_name[1])
  port = as.integer(data$port[1])
  res <-tsda::sql_conn_common(ip = ip,user_name = user_name,password = password,db_name = db_name,port = port)
  return(res)

}

#' 写入配置文件
#'
#' @param file_name 文件名
#' @param ip 地址
#' @param port 端口
#' @param user_name 用户名
#' @param password 密码
#' @param db_name 数据库名称
#'
#' @return 返回值
#' @export
#'
#' @examples
#' conn_config_write()
conn_config_write <- function(file_name="config/conn_erp.xlsx",
                  ip='123.207.201.140',
                  port=1433,
                  user_name='sa',
                  password='rds@123',
                  db_name='AIS20140904110155'
){

  data <- data.frame(ip,port,user_name,password,db_name,stringsAsFactors = F)
  res <- list(data)
  names(res) <-"conn"
  openxlsx::write.xlsx(res,file_name)

}












