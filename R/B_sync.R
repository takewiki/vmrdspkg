# 0.版权申明-----
# 本文用于同步数据
# 本库为项目私有库不用于对外公开
# 版本归上海棱星数据技术有限公司所有,保留所有版权
# 作者:胡立磊
# 邮箱:hulilei@takewiki.com.cn
# 日期:2021年06月06日
# 其中创建表结构与视图将使用SQL自身语法及文件进行处理
# 强制增加容错处理
# 增加try机制
# vm_create tables and viewed.sql
# sql:
# if exists(select * from sys.objects where  name ='PLMtoERP_Item')
# drop table PLMtoERP_Item
#
# CREATE TABLE [dbo].[PLMtoERP_Item](
#   [MCode] [nvarchar](30) NULL,
#   [MName] [nvarchar](80) NULL,
#   [Spec] [nvarchar](80) NULL,
#   [MDesc] [nvarchar](80) NULL,
#   [UOM] [nvarchar](30) NULL,
#   [MProp] [nvarchar](30) NULL,
#   [PLMOperation] [nvarchar](30) NULL,
#   [ERPOperation] [nvarchar](30) NULL,
#   [PLMDate] [datetime] NULL,
#   [ERPDate] [datetime] NULL,
#   [FInterId] [int] IDENTITY(1,1) NOT NULL,
#   [PLMBatchnum] [nvarchar](50) NULL
# ) ON [PRIMARY]
# GO
# 1.0 同步物料信息-------
#' 同步物料信息到ERP库,初始化仅一次
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
#'

sync_PLMtoERP_Item_initially <- function(conn_plm=conn_vm_plm_test(),conn_erp=conn_vm_erp_test()) {

sql_plm <- paste0("select * from PLMtoERP_Item")
data_plm <- tsda::sql_select()


}

#' 同步物料到ERP库周期性处理
#'
#' @param conn_plm
#' @param conn_erp
#'
#' @return
#' @export
#'
#' @examples
sync_PLMtoERP_Item_periodly <- function(conn_plm=conn_vm_plm_test(),conn_erp=conn_vm_erp_test()) {

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
