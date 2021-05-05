#1.1A读取物料批次通用函数------
#' 读取物料申请的批次列表
#'
#' @param config_file 配置文件
#' @param prefix 批号的前缀
#'
#' @return 返回值
#'
#' @examples
#' PLM_Item_getBatchNo_Aux()
PLM_Item_getBatchNo_Aux <- function(config_file = "config/conn_tc.R",prefix='APP') {

  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)
  #获取处理批次
  sql <- paste0("select distinct  PLMBatchnum  from PLMtoERP_Item
where PLMBatchnum like '",prefix,"%' and ERPOperation is null")
  #返回结果
  res <- tsda::sql_select(conn = conn_tc,sql_str = sql)
  #关闭连接
  tsda::conn_close(conn_tc)
  #返回结果
  return(res)

}



#1.1A读取物料申请批次------
#' 读取物料申请的批次列表
#'
#' @param config_file 配置文件
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_App_getBatchNo()
PLM_Item_App_getBatchNo <- function(config_file = "config/conn_tc.R") {


  res <- PLM_Item_getBatchNo_Aux(config_file = config_file ,prefix = 'APP')

  #返回结果
  return(res)

}


#1.1B读取物料创建BOM中使用的物料批次------
#' 读取物料创建BOM时使用到的物料的批次列表
#'
#' @param config_file 配置文件
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_Bom_getBatchNo()
PLM_Item_Bom_getBatchNo <- function(config_file = "config/conn_tc.R") {


  res <- PLM_Item_getBatchNo_Aux(config_file = config_file ,prefix = 'BOM')

  #返回结果
  return(res)

}

#1.1C读取物料发布BOM中使用的物料批次------
#' 读取物料发布BOM时使用到的物料的批次列表
#'
#' @param config_file 配置文件
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_Prd_getBatchNo()
PLM_Item_Prd_getBatchNo <- function(config_file = "config/conn_tc.R") {


  res <- PLM_Item_getBatchNo_Aux(config_file = config_file ,prefix = 'PRD')

  #返回结果
  return(res)

}


#1.1D读取物料ECN中使用的物料批次------
#' 读取物料ECN时使用到的物料的批次列表
#'
#' @param config_file 配置文件
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_Ecn_getBatchNo()
PLM_Item_Ecn_getBatchNo <- function(config_file = "config/conn_tc.R") {


  res <- PLM_Item_getBatchNo_Aux(config_file = config_file ,prefix = 'ECN')

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
PLM_Item_readByBatchNo <- function(config_file = "config/conn_tc.R",batchNo='APP00000005') {

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






