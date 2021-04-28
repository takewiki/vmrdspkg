#1.1PLM系统中的BOM申请-------
#对ERP系统没有任何影响，不需要做任何任何不做版本更新
# 此时的BOM资料还没有完整
# 在PLM系统中起到占位的使用
PLM_BOM_Apply <- function(config_file = "config/conn_k3.R",data_bom) {

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








