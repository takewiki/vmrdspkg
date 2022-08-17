
#' 日志汇总信息
#'
#' @param conn 连接
#' @param FTableName  表名
#' @param FStartDate 开始日期
#' @param FEndDate  结束日期
#'
#' @return 返回值
#' @export
#'
#' @examples
#'log_summary()
log_summary <- function(conn=conn_vm_plm_test(),
                        FTableName ='rds_vw_log_PLMtoERP_Item_summary',
                        FStartDate = '2021-01-01',
                        FEndDate ='2021-08-01') {
  sql <- paste0("select * from  ",FTableName,"
where   flogdate >='",FStartDate,"'   and FlogDate <='",FEndDate,"' ")

  data = tsda::sql_select(conn,sql)
  return(data)

}


#' 日志明细信息
#'
#' @param conn 连接
#' @param FTableName  表名
#' @param FLogDate 日志日期
#'
#' @return 返回值
#' @export
#'
#' @examples
#' log_detail()
log_detail <- function(conn=conn_vm_plm_test(),
                        FTableName ='rds_vw_log_PLMtoERP_Item_detail',
                        FLogDate = '2021-04-22'
                        ) {
  sql <- paste0("select  *  from  ",FTableName,"
where   flogdate  =  '",FLogDate,"'")

  data = tsda::sql_select(conn,sql)
  return(data)

}

