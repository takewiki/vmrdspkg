#' 按生产任务单查询生产投料及BOM的差异
#'
#' @param conn 连接
#' @param fbillno 单据编码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' rpt_icmo_ppbom_diff_number()
rpt_icmo_ppbom_diff_number <-function(conn=conn_vm_erp_test(),
                                      fbillno ='WORK017602'
){

sql <- paste0("select

FBillno as '生产任务单号' ,
FNumber as '物料代码',
FName as '物料名称',
FModel as '规格型号',
FBomNumber as 'BOM编码',
FVersion as 'BOM版本',
FCommitDate as '下达日期',
FQty as '生产数量',
FBom_EntryId  as 'BOM单行号',
FBom_ItemNo as 'BOM子项物料编码',
FBom_Qty as 'BOM子项用量',
FPPbom_BillNo as '生产投料单号',
FPPbom_EntryId as '生产投料单行号',
FPPbom_ItemNo as '生产投料单子项物料代码',
FUnitQty as '生产投料单子项单位数量',
FQty_Diff as 'BOM及生产投料差异数量'
from rds_vw_icmo_diff_all
where  fbillno ='",fbillno,"'")
data <- tsda::sql_select(conn,sql)
ncount <- nrow(data)
return(data)
}


#' 按生产任务单查询生产投料及BOM的差异
#'
#' @param conn 连接
#' @param fbillno 单据编码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' rpt_icmo_ppbom_diff_Item()
rpt_icmo_ppbom_diff_Item <-function(conn=conn_vm_erp_test(),
                                    fnumber ='1.207.01.00002'
){

  sql <- paste0("select

FBillno as '生产任务单号' ,
FNumber as '物料代码',
FName as '物料名称',
FModel as '规格型号',
FBomNumber as 'BOM编码',
FVersion as 'BOM版本',
FCommitDate as '下达日期',
FQty as '生产数量',
FBom_EntryId  as 'BOM单行号',
FBom_ItemNo as 'BOM子项物料编码',
FBom_Qty as 'BOM子项用量',
FPPbom_BillNo as '生产投料单号',
FPPbom_EntryId as '生产投料单行号',
FPPbom_ItemNo as '生产投料单子项物料代码',
FUnitQty as '生产投料单子项单位数量',
FQty_Diff as 'BOM及生产投料差异数量'
from rds_vw_icmo_diff_all
where  fnumber ='",fnumber,"'")
  data <- tsda::sql_select(conn,sql)
  ncount <- nrow(data)
  return(data)
}
