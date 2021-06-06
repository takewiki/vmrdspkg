#########################################################################
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
#
#
#
#########################################################################
# 0.1根据已有的物料编码获取同类的标准物料-----
# 方法上还有有待优化，针对新增的物料，ERP系统中其实并没有处理
# 因此还是需要进行必要的处理
# 目前VM的物料编码的尾号还是不统一的，需要使用辅助函数进行处理
#' 根据最新的物料编码获取同分组的最大物料编码
#'
#' @param config_file 配置文件
#' @param FNumber 物料编码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' ERP_Item_getMaxItemNoByGroup()
ERP_Item_getMaxItemNoByGroup <- function(config_file = "config/conn_k3.R",FNumber='1.105.04.00001') {
  sql <- paste0("select max(FNumber) as FMaxNumber from t_ICItem where
FParentID in
(select  FParentID from t_ICItem where FNumber='1.105.04.00001'
)")


}


#1.1物料新增-------
#' 处理物料新增数据
#'
#' @param config_file 配置文件
#' @param data_item  物料新增
#'
#' @return 返回值
#' @export
#'
#' @examples
#' ERP_Item_New()
ERP_Item_New <- function(config_file = "config/conn_k3.R",data_item) {

}



#1.2物料属性的修改-------
#其中物料编码、计量单位、物料属性不会修改
# 其他属于可能会变化
#' 物料修改属性
#'
#' @param config_file 配置文件
#' @param data_item 物料数据
#'
#' @return 返回值
#' @export
#'
#' @examples
#' ERP_Item_Modify()
ERP_Item_Modify <- function(config_file = "config/conn_k3.R",data_item) {

}


# 1.3物料的逻辑禁用-----
# 通过修改物料的备注属性进行禁用
# 不做其他过多的内容
# ERP系统中也不执行【禁用】操作
#' 物料禁用
#'
#' @param config_file 配置文件
#' @param data_item 物料数据
#'
#' @return 返回值
#' @export
#'
#' @examples
#' ERP_Item_Disable()
ERP_Item_Disable <- function(config_file = "config/conn_k3.R",data_item) {

}



