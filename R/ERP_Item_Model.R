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


#物料新增-------
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
