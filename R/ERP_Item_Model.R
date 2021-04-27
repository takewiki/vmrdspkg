#' 根据最新的物料编码获取同分组的最大物料编码
#'
#' @param config_file
#' @param FNumber
#'
#' @return
#' @export
#'
#' @examples
ERP_Item_getMaxItemNoByGroup <- function(config_file = "config/conn_tc.R",FNumber='1.105.04.00001') {
  sql <- paste0("select max(FNumber) as FMaxNumber from t_ICItem where
FParentID in
(select  FParentID from t_ICItem where FNumber='1.105.04.00001'
)")


}
