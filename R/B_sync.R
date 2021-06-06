# 0.版权申明-----
# 本文用于同步数据
# 本库为项目私有库不用于对外公开
# 版本归上海棱星数据技术有限公司所有,保留所有版权
# 作者:胡立磊
# 邮箱:hulilei@takewiki.com.cn
# 日期:2021年06月06日
# 其中创建表结构与视图将使用SQL自身语法及文件进行处理
# 1.0 同步物料信息-------
#' 同步物料信息到ERP库
#'
#' @param conn_plm PLM连接信息
#' @param conn_erp ERP连接信息
#'
#' @return 返回值
#' @export
#'
#' @examples
#' sync_PLMtoERP_Item()
#' 表名：
#' SQL名：
sync_PLMtoERP_Item <- function(conn_plm=conn_vm_plm_test(),conn_erp=conn_vm_erp_test()) {

}

# 2.0 同步BOM信息-------


#' 同步BOM信息到ERP库
#'
#' @param conn_plm PLM连接信息
#' @param conn_erp ERP连接信息
#'
#' @return 返回值
#' @export
#'
#' @examples
#' sync_PLMtoERP_Item()
#' 表名：
#' SQL名：
sync_PLMtoERP_BOM <- function(conn_plm=conn_vm_plm_test(),conn_erp=conn_vm_erp_test()) {

}
