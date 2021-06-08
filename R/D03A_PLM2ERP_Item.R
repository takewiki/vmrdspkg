#1.1A读取物料申请批次------
#1.1A pre 使用批次号前缀----
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
# 1.1B不再使用----
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
# 1.1C不再PRD-----传入前缀-----
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
# 1.1D读取物料ECN-----
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


#更新物料状态 TBU ，按整个类型进行处理----------
PLM_Item_UpdateStatus <- function(config_file = "config/conn_tc.R",batchNo='APP00000005') {
  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)

  # sql <- past

}
