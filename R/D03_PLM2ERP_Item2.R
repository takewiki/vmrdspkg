# 1.0获取物料处理列表 ----
# if exists(select * from sys.objects where  name ='vw_PLMtoERP_Item')
# drop view vw_PLMtoERP_Item
# go
# create view vw_PLMtoERP_Item
# as
# select MCode,MProp,PLMBatchnum from PLMtoERP_Item
# where ERPDate is null
# go
#' 获取物料的处理清单
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_getList()
Item_getList <- function(conn=conn_vm_erp_test()) {

  sql <- paste0("select * from  vw_PLMtoERP_Item
order by PLMBatchnum,MProp,MCode")
  res <- tsda::sql_select(conn,sql)
  return(res)

}

# 1.1 Pre写入物料前的准备工作------
# 1.1.01返回物料编码的内码------
#' 返回物料编码的内码
#'
#' @param conn_erp ERP
#' @param FItemNumber 物料代码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' item_GetInterId()
item_GetInterId <- function(conn_erp = conn_vm_erp_test(),FItemNumber='0.109.06.031') {

  sql_item <- paste0("select  FItemID from t_icitem
where FNumber ='",FItemNumber,"'")
  r <- tsda::sql_select(conn_erp,sql_item)
  ncount = nrow(r)
  if(ncount >0){
    res <- r$FItemID
  }else{
    res <- 0
  }
  return(res)

}
# 1.1.02 创建物资预分配表-----
# if exists(select * from sys.objects where  name ='t_Item_rds')
# drop table t_Item_rds
# CREATE TABLE [dbo].[t_Item_rds](
#   [FItemID] [int] NOT NULL,
#   [FItemClassID] [int] NOT NULL,
#   [FExternID] [int] NOT NULL,
#   [FNumber] [varchar](80) NOT NULL,
#   [FParentID] [int] NOT NULL,
#   [FLevel] [smallint] NOT NULL,
#   [FDetail] [bit] NOT NULL,
#   [FName] [varchar](255) NOT NULL,
#   [FUnUsed] [bit] NULL,
#   [FBrNo] [varchar](10) NOT NULL,
#   [FFullNumber] [varchar](80) NOT NULL,
#   [FDiff] [bit] NOT NULL,
#   [FDeleted] [smallint] NOT NULL,
#   [FShortNumber] [varchar](80) NULL,
#   [FFullName] [varchar](255) NULL,
#   [UUID] [uniqueidentifier] NOT NULL,
#   [FGRCommonID] [int] NOT NULL,
#   [FSystemType] [int] NOT NULL,
#   [FUseSign] [int] NOT NULL,
#   [FChkUserID] [int] NULL,
#   [FAccessory] [smallint] NOT NULL,
#   [FGrControl] [int] NOT NULL,
#   [FModifyTime] [timestamp] NOT NULL,
#   [FHavePicture] [smallint] NOT NULL
# )
# go
# 1.1.03创建备份数据表-------
# if exists(select * from sys.objects where  name ='t_Item_rdsBak')
# drop table t_Item_rdsBak
# CREATE TABLE [dbo].[t_Item_rdsBak](
#   [FItemID] [int] NOT NULL,
#   [FItemClassID] [int] NOT NULL,
#   [FExternID] [int] NOT NULL,
#   [FNumber] [varchar](80) NOT NULL,
#   [FParentID] [int] NOT NULL,
#   [FLevel] [smallint] NOT NULL,
#   [FDetail] [bit] NOT NULL,
#   [FName] [varchar](255) NOT NULL,
#   [FUnUsed] [bit] NULL,
#   [FBrNo] [varchar](10) NOT NULL,
#   [FFullNumber] [varchar](80) NOT NULL,
#   [FDiff] [bit] NOT NULL,
#   [FDeleted] [smallint] NOT NULL,
#   [FShortNumber] [varchar](80) NULL,
#   [FFullName] [varchar](255) NULL,
#   [UUID] [uniqueidentifier] NOT NULL,
#   [FGRCommonID] [int] NOT NULL,
#   [FSystemType] [int] NOT NULL,
#   [FUseSign] [int] NOT NULL,
#   [FChkUserID] [int] NULL,
#   [FAccessory] [smallint] NOT NULL,
#   [FGrControl] [int] NOT NULL,
#   [FModifyTime] [timestamp] NOT NULL,
#   [FHavePicture] [smallint] NOT NULL
# )
# go
#1.1.04初始化物料处理,预分配物料不够时使用此功能--------
#***************A外购物料-----

#' 写入外购的物料进行待分配表
#'
#' @param conn 连接
#' @param table_name_rds  外购物料
#' @param table_name_room  待分配表
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_Initial_WG()
Item_Initial_WG <-function(conn=conn_vm_erp_test(),
                                      table_name_rds='t_Item_rds',
                                      table_name_room ='t_item_rdsRoom'
){

  sql_item <- paste0("select  count(1)  as Fcount
		   from t_item
		where FNumber like 'RDS.01.%'
		and fname = 'WG'")
  data_item <- tsda::sql_select(conn,sql_item)
  ncount <- data_item$Fcount
  if (ncount >0){
    #存在待处理的记录
    sql_wg <-paste0("
 INSERT INTO [dbo].[",table_name_rds,"]
           ([FItemID]
           ,[FItemClassID]
           ,[FExternID]
           ,[FNumber]
           ,[FParentID]
           ,[FLevel]
           ,[FDetail]
           ,[FName]
           ,[FUnUsed]
           ,[FBrNo]
           ,[FFullNumber]
           ,[FDiff]
           ,[FDeleted]
           ,[FShortNumber]
           ,[FFullName]
           ,[UUID]
           ,[FGRCommonID]
           ,[FSystemType]
           ,[FUseSign]
           ,[FChkUserID]
           ,[FAccessory]
           ,[FGrControl]
           ,[FHavePicture])
 select [FItemID]
           ,[FItemClassID]
           ,[FExternID]
           ,[FNumber]
           ,[FParentID]
           ,[FLevel]
           ,[FDetail]
           ,[FName]
           ,[FUnUsed]
           ,[FBrNo]
           ,[FFullNumber]
           ,[FDiff]
           ,[FDeleted]
           ,[FShortNumber]
           ,[FFullName]
           ,[UUID]
           ,[FGRCommonID]
           ,[FSystemType]
           ,[FUseSign]
           ,[FChkUserID]
           ,[FAccessory]
           ,[FGrControl]
           ,[FHavePicture]
		   from t_item
		where FNumber like 'RDS.01.%'
		and fname = 'WG'")
    #深度对数据进行数据
    try(tsda::sql_update(conn,sql_wg))

    sql_room <- paste0("insert into ",table_name_room,"
select
          [FItemClassID],

          [FItemID]


           ,[FNumber]

           ,[FName],
		   '外购' as FPropType,
		   '' as FNumber_New,
		   0 as FFlag

		   from t_item
		where FNumber like 'RDS.01.%'
		and fname = 'WG'")

    try(tsda::sql_update(conn,sql_room))

    sql_del <- paste0("delete from t_item
		where FNumber like 'RDS.01.%'
		and fname = 'WG'")
    try(tsda::sql_update(conn,sql_del))

    res <- TRUE
  }else{
    res <- FALSE
  }
  return(res)
}

#**********************B自制物料--------
#' 针对自制物料进行初始化隐藏处理
#'
#' @param conn ERP链接信息
#' @param table_name_rds 物料明细表
#' @param table_name_room 待分配统计表
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_Initial_ZZ()
Item_Initial_ZZ <-function(conn=conn_vm_erp_test(),
                                      table_name_rds='t_Item_rds',
                                      table_name_room ='t_item_rdsRoom'
){

  sql_item <- paste0("select  count(1)  as Fcount
		   from t_item
		where FNumber like 'RDS.02.%'
		and fname = 'ZZ'")
  data_item <- tsda::sql_select(conn,sql_item)
  ncount <- data_item$Fcount
  if (ncount >0){
    #存在待处理的记录
    sql_wg <-paste0("
 INSERT INTO [dbo].[",table_name_rds,"]
           ([FItemID]
           ,[FItemClassID]
           ,[FExternID]
           ,[FNumber]
           ,[FParentID]
           ,[FLevel]
           ,[FDetail]
           ,[FName]
           ,[FUnUsed]
           ,[FBrNo]
           ,[FFullNumber]
           ,[FDiff]
           ,[FDeleted]
           ,[FShortNumber]
           ,[FFullName]
           ,[UUID]
           ,[FGRCommonID]
           ,[FSystemType]
           ,[FUseSign]
           ,[FChkUserID]
           ,[FAccessory]
           ,[FGrControl]
           ,[FHavePicture])
 select [FItemID]
           ,[FItemClassID]
           ,[FExternID]
           ,[FNumber]
           ,[FParentID]
           ,[FLevel]
           ,[FDetail]
           ,[FName]
           ,[FUnUsed]
           ,[FBrNo]
           ,[FFullNumber]
           ,[FDiff]
           ,[FDeleted]
           ,[FShortNumber]
           ,[FFullName]
           ,[UUID]
           ,[FGRCommonID]
           ,[FSystemType]
           ,[FUseSign]
           ,[FChkUserID]
           ,[FAccessory]
           ,[FGrControl]
           ,[FHavePicture]
		   from t_item
		where FNumber like 'RDS.02.%'
		and fname = 'ZZ'")
    #深度对数据进行数据
    try(tsda::sql_update(conn,sql_wg))

    sql_room <- paste0("insert into ",table_name_room,"
select
          [FItemClassID],

          [FItemID]


           ,[FNumber]

           ,[FName],
		   '自制' as FPropType,
		   '' as FNumber_New,
		   0 as FFlag

		   from t_item
		where FNumber like 'RDS.02.%'
		and fname = 'ZZ'")

    try(tsda::sql_update(conn,sql_room))

    sql_del <- paste0("delete from t_item
		where FNumber like 'RDS.02.%'
		and fname = 'ZZ'")
    try(tsda::sql_update(conn,sql_del))

    res <- TRUE
  }else{
    res <- FALSE
  }
  return(res)
}



# 1.1写入一行物料数据--------
#' 写入一行物料数据
#'
#' @param conn 连接
#' @param MCode 物料编码
#' @param MProp 属性
#' @param PLMBatchnum  批次号
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_readIntoERP_One()
Item_readIntoERP_One <- function(conn=conn_vm_erp_test(),
                                 MCode,
                                 MProp,
                                 PLMBatchnum

                                 ){
#写入代码：
#处理一行物料信息
#外购与委外都没有成本对象

#写入日志表


}

# 1.2写入所有物料数据-------
#' 将所有数据写入物料表
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_readIntoERP_ALL()
Item_readIntoERP_ALL <- function(conn=conn_vm_erp_test()){

  item_list <-  Item_getList(conn = conn)
  ncount = nrow(item_list)

  if (ncount >0){

    lapply(1:ncount, function(i){
      MCode <- item_list$MCode[i]
      MProp <-  item_list$MProp[i]
      PLMBatchnum <- item_list$PLMBatchnum[i]

      #写入物料,增加容错错误
      try({
        Item_readIntoERP_One(conn=conn,MCode = MCode,MProp = MProp,PLMBatchnum = PLMBatchnum)
      })









    })


  }


}
