#1.1读取物料批次------
#' 读取物料的批次列表
#'
#' @param config_file 配置文件
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM2ERP_Item_getBatchNo()
PLM2ERP_Item_getBatchNo <- function(config_file = "config/conn_tc.R") {

  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)
  #获取处理批次
  sql <- paste0("select distinct  PLMBatchnum  from PLMtoERP_Item
where PLMBatchnum like 'APP%' and ERPOperation is null")
  #返回结果
  res <- tsda::sql_select(conn = conn_tc,sql_str = sql)
  #关闭连接
  tsda::conn_close(conn_tc)
  #返回结果
  return(res)

}



# 1.2按批次号获取新增物料信息------

#' 按批次号获取新增物料信息
#'
#' @param config_file 配置文件
#' @param batchNo 批号
#'
#' @return 返回值
#' @export
#'
#' @examples
#'PLM2ERP_Item_readByBatchNo()
PLM2ERP_Item_readByBatchNo <- function(config_file = "config/conn_tc.R",batchNo='APP00000005') {

  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)
  #获取处理批次
  sql <- paste0("select  MCode,MName,Spec,MDesc,UOM,MProp   from PLMtoERP_Item
where PLMBatchnum  ='",batchNo,"'")

  #返回结果
  res <- tsda::sql_select(conn = conn_tc,sql_str = sql)
  #关闭连接
  tsda::conn_close(conn_tc)
  #返回结果
  return(res)

}






