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
# 1.0 pre 物料表数据结构SQL----
# sql:
# use AIS20140904110155
# go
# ---创建PLMtoERP_Item物料表
# ---初始化时使用，会删除所有数据
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
#   [FInterId] [int]  NOT NULL,
#   [PLMBatchnum] [nvarchar](50) NULL
# ) ON [PRIMARY]
# GO

# 1.0 Pre 相关基础函数-------
#' 获取PLMtoERP_Item中的数据
#'
#' @param conn 连接
#'
#' @return 返回数据
#' @export
#'
#' @examples
#' data_PLMtoERP_Item()
data_PLMtoERP_Item  <- function(conn=conn_vm_erp_test()){
  sql <- paste0("select * from PLMtoERP_Item")
  data <- tsda::sql_select(conn = conn,sql_str = sql)
  return(data)
}

#' 获取PLMtoERP_Item中的数据PLM
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' data_PLMtoERP_Item_plm()
data_PLMtoERP_Item_plm <- function(conn=conn_vm_plm_test()) {
  res <- data_PLMtoERP_Item(conn = conn)
  return(res)

}

#' 获取PLMtoERP_Item中的数据ERP数据
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' data_PLMtoERP_Item_erp()
data_PLMtoERP_Item_erp <- function(conn=conn_vm_erp_test()) {
  res <- data_PLMtoERP_Item(conn = conn)
  return(res)

}




# 1.0 同步物料信息初始步-------
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

data_plm <- data_PLMtoERP_Item_plm(conn = conn_plm)
data_erp <- data_PLMtoERP_Item_erp(conn = conn_erp)
ncount_plm = nrow(data_plm)
ncount_erp = nrow(data_erp)
if(ncount_plm >0 & ncount_erp == 0){
  #说明存在初始化数据，可以进行写入
  # 虽然是写入，还是增加容错机制
  try({
    tsda::db_writeTable(conn = conn_erp,table_name = 'PLMtoERP_Item',r_object = data_plm,append = TRUE)
  })



}else if(ncount_plm & ncount_erp){
  print('ERP库中PLMtoERP_Item表中已经存在数据，不需要重写')
}else{
  print('PLM库中PLMtoERP_Item表中没有数据，不需要写入')
}


}


#' 获取最大日期
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' data_PLMtoERP_Item_maxDate()
data_PLMtoERP_Item_maxDate  <- function(conn=conn_vm_erp_test()){
  sql <- paste0("select max(PLMDate) as   PLMDate  from  PLMtoERP_Item")
  r <- tsda::sql_select(conn = conn,sql_str = sql)
  res <- r$PLMDate
  return(res)
}
# 1.1 pre 日志文件SQL创建------
# SQL:
# if exists(select * from sys.objects where  name ='rds_dataSync_log')
# drop table rds_dataSync_log
# CREATE TABLE [dbo].[rds_dataSync_log](
#   FDateFrom datetime,
#   FTableName varchar(30),
#   FCount int,
#   FStatus_PLM int,
#   FStatus_ERP int
# ) ON [PRIMARY]
# GO
# 1.1周期性同步物料数据------
#' 从PLM库中获取最新更新的数据
#'
#' @param conn_plm 连接
#' @param conn_erp ERP连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' data_PLMtoERP_Item_fromDate()
data_PLMtoERP_Item_fromDate  <- function(conn_plm=conn_vm_plm_test(),conn_erp=conn_vm_erp_test()){
  # 从ERP获取上次更新日期
  last_date <- data_PLMtoERP_Item_maxDate(conn = conn_erp)

  sql <- paste0("select  *  from  PLMtoERP_Item
where PLMDate >'",last_date,"'")
  data <- tsda::sql_select(conn = conn_plm,sql_str = sql)
  ncount = nrow(data)
  if(ncount > 0){
    #针对数据进行容错性处理
    data$MProp[data$MProp == 'Self made'] <- '自制'
    data$MProp[data$MProp == 'Purchased'] <- '外购'
    data$MProp[data$MProp == 'Outsourcing'] <- '委外加工'
    data$MProp[data$MProp == 'Configuration'] <- '自制'


    #数据已经存在,写入ERP
    try({
      tsda::db_writeTable(conn = conn_erp,table_name = 'PLMtoERP_Item',r_object = data,append = TRUE)
    })
    #写入日志表
    FDateFrom =  last_date
    FTableName = 'PLMtoERP_Item'
    FCount = ncount
    FStatus_PLM = 1
    FStatus_ERP = 0
    data_log = data.frame(FDateFrom,FTableName,FCount,FStatus_PLM,FStatus_ERP,stringsAsFactors = F)
    try({
      tsda::db_writeTable(conn = conn_erp,table_name = 'rds_dataSync_log',r_object = data_log,append = TRUE)
    })
    #更新PLM库的状态
    ERP_DATE = as.character(Sys.time())
    sql_udp_plm <- paste0("update a set a.ERPOperation = 'R' ,a.ERPDate = '",ERP_DATE,"'  from  PLMtoERP_Item a
where PLMDate >'",last_date,"'")
    try({
      tsda::sql_update(conn = conn_plm,sql_str = sql_udp_plm)
    })







  }else
  {
    print('不存在更新数据')
  }
  return(data)

}

#' 同步物料到ERP库周期性处理
#'
#' @param conn_plm PLM连接
#' @param conn_erp ERP连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' sync_PLMtoERP_Item_periodly()
sync_PLMtoERP_Item_periodly <- function(conn_plm=conn_vm_plm_test(),conn_erp=conn_vm_erp_test()) {

  res <- data_PLMtoERP_Item_fromDate(conn_plm = conn_plm,conn_erp = conn_erp)
  return(res)

}

# 2.0 pre BOM数据结构-----
# SQL:
# if exists(select * from sys.objects where  name ='PLMtoERP_BOM')
# drop table PLMtoERP_BOM
# CREATE TABLE [dbo].[PLMtoERP_BOM](
#   [PMCode] [nvarchar](30) NULL,
#   [PMName] [nvarchar](80) NULL,
#   [BOMRevCode] [nvarchar](30) NULL,
#   [CMCode] [nvarchar](30) NULL,
#   [CMName] [nvarchar](80) NULL,
#   [ProductGroup] [nvarchar](30) NULL,
#   [BOMCount] [nvarchar](30) NULL,
#   [BOMUOM] [nvarchar](30) NULL,
#   [PLMOperation] [nvarchar](30) NULL,
#   [ERPOperation] [nvarchar](30) NULL,
#   [PLMDate] [datetime] NULL,
#   [ERPDate] [datetime] NULL,
#   [FInterId] [int]  NOT NULL,
#   [RootCode] [nvarchar](80) NULL,
#   [FLowCode] [nvarchar](50) NULL,
#   [PLMBatchnum] [nvarchar](50) NULL
# ) ON [PRIMARY]
# GO
# 2.0 同步BOM信息初步化同步-------

#' 同步BOM信息
#'
#' @param conn 连接信息
#'
#' @return 返回值
#' @export
#'
#' @examples
#' data_PLMtoERP_BOM()
data_PLMtoERP_BOM  <- function(conn=conn_vm_erp_test()){
  sql <- paste0(" select * from PLMtoERP_BOM")
  data <- tsda::sql_select(conn = conn,sql_str = sql)
  return(data)
}

#' 读取PLM中的BOM信息
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' data_PLMtoERP_BOM_plm()
data_PLMtoERP_BOM_plm <- function(conn=conn_vm_plm_test()) {
  res <- data_PLMtoERP_BOM(conn = conn)
  return(res)

}


#' 获取PLM中的BOM信息
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' data_PLMtoERP_BOM_erp()
data_PLMtoERP_BOM_erp <- function(conn=conn_vm_erp_test()) {
  res <- data_PLMtoERP_BOM(conn = conn)
  return(res)

}



#' 同步BOM信息到ERP库
#'
#' @param conn_plm PLM连接信息
#' @param conn_erp ERP连接信息
#'
#' @return 返回值
#' @export
#'
#' @examples
#' sync_PLMtoERP_BOM_intially()
#' 表名：
#' SQL名：
sync_PLMtoERP_BOM_intially <- function(conn_plm=conn_vm_plm_test(),conn_erp=conn_vm_erp_test()) {
  data_plm <- data_PLMtoERP_BOM_plm(conn = conn_plm)
  data_erp <- data_PLMtoERP_BOM_erp(conn = conn_erp)
  ncount_plm = nrow(data_plm)
  ncount_erp = nrow(data_erp)
  if(ncount_plm >0 & ncount_erp == 0){
    #说明存在初始化数据，可以进行写入
    # 虽然是写入，还是增加容错机制
    try({
      tsda::db_writeTable(conn = conn_erp,table_name = 'PLMtoERP_BOM',r_object = data_plm,append = TRUE)
    })



  }else if(ncount_plm & ncount_erp){
    print('ERP库中PLMtoERP_BOM表中已经存在数据，不需要重写')
  }else{
    print('PLM库中PLMtoERP_BOM表中没有数据，不需要写入')
  }
}

# 2.1周期性同步BOM信息----

#' 获取最大日期
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' data_PLMtoERP_BOM_maxDate()
data_PLMtoERP_BOM_maxDate  <- function(conn=conn_vm_erp_test()){
  sql <- paste0("select max(PLMDate) as   PLMDate  from  PLMtoERP_BOM")
  r <- tsda::sql_select(conn = conn,sql_str = sql)
  res <- r$PLMDate
  return(res)
}

#' 从PLM库中获取最新更新的数据
#'
#' @param conn_plm 连接
#' @param conn_erp ERP连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' data_PLMtoERP_Item_fromDate()
data_PLMtoERP_BOM_fromDate  <- function(conn_plm=conn_vm_plm_test(),conn_erp=conn_vm_erp_test()){
  # 从ERP获取上次更新日期
  last_date <- data_PLMtoERP_BOM_maxDate(conn = conn_erp)

  sql <- paste0("select  *  from  PLMtoERP_BOM
where PLMDate >'",last_date,"'")
  data <- tsda::sql_select(conn = conn_plm,sql_str = sql)
  ncount = nrow(data)
  if(ncount > 0){
    #数据已经存在,写入ERP
    try({
      tsda::db_writeTable(conn = conn_erp,table_name = 'PLMtoERP_BOM',r_object = data,append = TRUE)
    })
    #写入日志表
    FDateFrom =  last_date
    FTableName = 'PLMtoERP_BOM'
    FCount = ncount
    FStatus_PLM = 1
    FStatus_ERP = 0
    data_log = data.frame(FDateFrom,FTableName,FCount,FStatus_PLM,FStatus_ERP,stringsAsFactors = F)
    try({
      tsda::db_writeTable(conn = conn_erp,table_name = 'rds_dataSync_log',r_object = data_log,append = TRUE)
    })
    #更新PLM库的状态

    ERP_DATE = as.character(Sys.time())
    sql_udp_plm <- paste0("update a set a.ERPOperation = 'R' ,a.ERPDate = '",ERP_DATE,"'  from  PLMtoERP_BOM a
where PLMDate >'",last_date,"'")
    try({
      tsda::sql_update(conn = conn_plm,sql_str = sql_udp_plm)
    })







  }else
  {
    print('不存在更新数据')
  }
  return(data)

}


#' 周期性同步BOM数据
#'
#' @param conn_plm PLM连接
#' @param conn_erp ERP连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' sync_PLMtoERP_BOM_periodly()
sync_PLMtoERP_BOM_periodly <- function(conn_plm=conn_vm_plm_test(),conn_erp=conn_vm_erp_test()) {

  res <- data_PLMtoERP_BOM_fromDate(conn_plm = conn_plm,conn_erp = conn_erp)
  return(res)

}
