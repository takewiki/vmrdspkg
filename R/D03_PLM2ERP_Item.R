
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


#########################################################################
#APP00000005 增加物料，分配物料，所有的物料都在分配
#BOM00000002 忽略，不建物料,不再使用
#PRD00000004 修改物料，不申请新物料，PLM类型M
#ECN00000002 修改物料，不申请物料，,PLM类型M,0
#                                 其中O为禁用，不会再出现在BOM
#  物料属性可以在中台进行修改，按规则修改
#  Jean规则可以定义在RDS.01,RDS.02,RDS.03的模板中
#
#
#
#
#########################################################################
#1.1A读取物料批次通用函数(本次不用这个逻辑)
# 1.1A:Note这个逻辑有问题的  Not Used-----
# 获取批号
#' 读取物料申请的批次列表
#'
#' @param config_file 配置文件
#' @param prefix 批号的前缀
#'
#' @return 返回值
#'
#' @examples
#' PLM_Item_getBatchNo_Aux()
PLM_Item_getBatchNo_Aux <- function(config_file = "config/conn_tc.R",prefix='APP') {

  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)
  #获取处理批次
  sql <- paste0("select distinct  PLMBatchnum  from PLMtoERP_Item
where PLMBatchnum like '",prefix,"%' and ERPOperation is null")
  #返回结果
  res <- tsda::sql_select(conn = conn_tc,sql_str = sql)
  #关闭连接
  tsda::conn_close(conn_tc)
  #返回结果
  return(res)

}



# 1.2按批次号获取新增物料信息------
# 读取物料编码，物料，描述，规避型号****核心-----
#' 按批次号获取新增物料信息
#'
#' @param config_file 配置文件
#' @param batchNo 批号
#' @param propType 物料属性
#'
#' @return 返回值
#'
#' @examples
#'PLM_Item_readByBatchNo_aux()
PLM_Item_readByBatchNo_aux <- function(config_file = "config/conn_tc.R",propType='外购',batchNo='APP00000005') {

  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)
  #获取处理批次
  sql <- paste0("select  MCode,MName,Spec,MDesc,UOM,MProp   from PLMtoERP_Item
where PLMBatchnum  ='",batchNo,"'  and MProp = N'",propType,"' ")
  # ##print(sql)

  #返回结果
  res <- tsda::sql_select(conn = conn_tc,sql_str = sql)
  #关闭连接
  tsda::conn_close(conn_tc)
  #返回结果
  return(res)

}

#1.2.1 外购物料信息读取--------
#' 外购物料的读取
#'
#' @param config_file 配置文件
#' @param batchNo 批次号
#'
#' @return 返回所有相关的物料
#' @export
#'
#' @examples
#' PLM_Item_readByBatchNo_WG()
PLM_Item_readByBatchNo_WG <- function(config_file = "config/conn_tc.R",batchNo='APP00000005') {


  res <- PLM_Item_readByBatchNo_aux(config_file = config_file,propType = '外购',batchNo = batchNo)

  #返回结果
  return(res)

}


#1.3 获取物料编码，后续将不再使用，原因之前PLM与ERP分开的逻辑-------
#后续通过视图等其他功能实现

#获取物料编码
#' 获取物料编码
#'
#' @param conn_erp ERP连接信息
#' @param item_list 列表
#'
#' @return 返回值
#' @export
#'
#' @examples
#' item_getNumber()
item_getNumber <- function(conn_erp = conn_vm_erp_test(),item_list) {
  #读取ERP数据
  #item_list <- res$MCode
  #格式化数据
  sql_tail <-  tsdo::sql_str(item_list)
  sql_item <- paste0("  select  fnumber from t_icitem
  where FNumber in (",sql_tail,")")
  ###print(sql_item)
  #查询数据结果
  res <- tsda::sql_select(conn_erp,sql_item)
  return(res)

}





# 1.4 获取全新的物料编码，后包含新增物料------
# 此条不适用于修改的物料，需要修改逻辑-----
# 是不是新增物料唯一影响是否需要修改物料内码-----
#' 获取全新的外购物料
#'
#' @param config_file 连接配置文件
#' @param batchNo 批次号
#' @param conn_erp ERP连接信息
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_readByBatchNo_WG_New()
PLM_Item_readByBatchNo_WG_New <- function(config_file = "config/conn_tc.R",batchNo='APP00000005',
                                          conn_erp = conn_vm_erp_test()) {


  res <- PLM_Item_readByBatchNo_aux(config_file = config_file,propType = '外购',batchNo = batchNo)
  #读取ERP数据
  item_list <- res$MCode
  #获取ERP数据
  data_item <- item_getNumber(conn_erp = conn_erp,item_list = item_list)
  ncount <- nrow(data_item)
  if(ncount >0){
    item_existed <- data_item$fnumber
    flag <-    !item_list %in% item_existed
    res <-res[flag,]
  }else{
    res <- res

  }

  #返回结果
  return(res)

}





#完成分配表的更新*****--------
#' 针对外购物料进行分配
#'
#' @param config_file 配置文件
#' @param batchNo  批号
#' @param conn_erp ERP连接信息
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_Allocated_wg()
PLM_Item_Allocated_wg <- function(config_file = "config/conn_tc.R",batchNo='APP00000005',
                                  conn_erp = conn_vm_erp_test()) {


  #1.1读取新增物料数据----
  df_new <- PLM_Item_readByBatchNo_WG_New(config_file = config_file,batchNo = batchNo,
                                          conn_erp = conn_erp)
  ###print('test_new:')
  ###print(df_new)
  ncount <- nrow(df_new)





  #1.2读取待分配数据------
  df_unAlloc <- mdmpkg::Item_getUnAllocateNumbers(conn=conn_erp,n = ncount,FPropType = '外购')
  ###print('df_unallocation:')
  ###print(df_unAlloc)
  #1.3 执行物料分配 ----
  res <- tsdo::allocate(df_new,df_unAlloc)
  ###print('test--1---')
  ###print(res)

  #1.4 添加批号信息及相关信息------
  res$FBatchNo <- batchNo
  res$FIsdo <- 0
  res$FItemId <- 0
  #上级物料编码
  res$FParentNumber <- mdmpkg::mdm_getParentNumber(res$MCode)


  #1.5 将相关结果写入ERP数据库-----
  #需要新加一个字段
  try(tsda::db_writeTable(conn = conn_erp,table_name = 't_item_rdsInput',r_object = res,append = T))

  #1.6 更新分配表的状态
  sql_rdsroom_upd <- paste0("update a set a.fnumber_new = b.MCode,a.FFlag =1  from  t_item_rdsroom a
inner join  t_item_rdsInput b
on a.fnumber=b.fnumber
and b.fbatchNum='",batchNo,"' and mprop='外购'")
  tsda::sql_update(conn_erp,sql_str = sql_rdsroom_upd)
  #更新物料输入表的物料的内码
  sql_rdsInput_itemID <- paste0("  update b  set   b.fitemid = a.fitemid  from  t_item_rdsroom a
  inner join  t_item_rdsInput b
  on a.fnumber=b.fnumber
  where b.fbatchNum='",batchNo,"' and mprop='外购' and a.fitemclassid =4 ")
  tsda::sql_update(conn_erp,sql_str = sql_rdsInput_itemID)
  #1.7 处理物料主表----
  sql_item_rds <- paste0("update  a set  a.FNumber =b.MCode ,a.FName=b.MName,a.fparentid = i.FItemID   from t_item_rds a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid
inner join t_item  i
on b.fParentNumber = i.FNumber
where  b.fbatchNum='",batchNo,"' and mprop='外购'
")
  tsda::sql_update(conn_erp,sql_str = sql_item_rds)
  #处理物料核心表----
  sql_item_core <- paste0("update a set    a.FNumber = b.MCode ,a.FName = b.MName ,a.FModel = b.Spec  from t_ICItemCore a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid

where  b.fbatchNum='",batchNo,"' and mprop='外购'
")
  tsda::sql_update(conn_erp,sql_str = sql_item_core)
  #处理物料自定义表----
  sql_item_custom <- paste0("update a set   a.F_119 = b.MDesc   from t_ICItemCustom a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid

where  b.fbatchNum='",batchNo,"' and mprop='外购'
")
  tsda::sql_update(conn_erp,sql_str = sql_item_custom)
  #更新物料的单位----
  sql_item_base <- paste0("update a set  FUnitID = m.FMeasureUnitID,FUnitGroupID=m.FUnitGroupID,
FOrderUnitID =m.FMeasureUnitID,
FProductUnitID =m.FMeasureUnitID,
FSaleUnitID =m.FMeasureUnitID,
FStoreUnitID = m.FMeasureUnitID
from t_ICItemBase a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid
inner join t_MeasureUnit m
on b.UOM  = m.FName
where  b.fbatchNum='",batchNo,"' and mprop='外购'")
  tsda::sql_update(conn_erp,sql_str = sql_item_base)
  #1.8将物料从缓存区更新到主表------
  sql_item_pushBack <- paste0("INSERT INTO [dbo].t_item
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
		   from t_item_rds
		   where fitemid in
		   (select fitemid  from  t_item_rdsInput b
where
 b.fbatchNum='",batchNo,"' and mprop='外购')

                ")
  tsda::sql_update(conn_erp,sql_str = sql_item_pushBack)

  #1.9更新物料表的状态---
  sql_itemInput_updateStatus <- paste0("update  b set FIsDo =1   from  t_item_rdsInput b
where
 b.fbatchNum='",batchNo,"' and mprop='外购'")
  tsda::sql_update(conn_erp,sql_str = sql_itemInput_updateStatus)
  #1.10更新中间表的状态-------
  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)
  # sql_item_tc <- paste0("  update a set ERPOperation ='R',ERPDate=GETDATE()
  #                       from PLMtoERP_Item  a  where PLMBatchnum ='",batchNo,"'
  #                       and MProp = N'外购'")
  ERP_DATE = as.character(Sys.time())
  sql_item_tc <- paste0("  update a set ERPOperation ='R',ERPDate= '",ERP_DATE,"'
                        from PLMtoERP_Item  a  where PLMBatchnum ='",batchNo,"'
                        and MProp = N'外购'")
  tsda::sql_update(conn_tc,sql_str = sql_itemInput_updateStatus)









  #更新TC数据库的状态, 后续进行批量更新






  #返回结果
  return(res)

}












# 自制物料的读取-----------


#' 自制物料的读取
#'
#' @param config_file 配置文件
#' @param batchNo 批次号
#'
#' @return 返回所有相关的物料
#' @export
#'
#' @examples
#' PLM_Item_readByBatchNo_ZZ()
PLM_Item_readByBatchNo_ZZ <- function(config_file = "config/conn_tc.R",batchNo='APP00000005') {


  res <- PLM_Item_readByBatchNo_aux(config_file = config_file,propType = '自制',batchNo = batchNo)


  #返回结果
  return(res)

}



#' 获取自制物料的信息信息
#'
#' @param config_file 配置
#' @param batchNo 批号
#' @param conn_erp ERP链接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_readByBatchNo_ZZ_New()
PLM_Item_readByBatchNo_ZZ_New <- function(config_file = "config/conn_tc.R",batchNo='APP00000005',
                                          conn_erp = conn_vm_erp_test()) {


  res <- PLM_Item_readByBatchNo_aux(config_file = config_file,propType = '自制',batchNo = batchNo)
  #读取ERP数据
  item_list <- res$MCode
  #获取ERP数据
  data_item <- item_getNumber(conn_erp = conn_erp,item_list = item_list)
  ncount <- nrow(data_item)
  if(ncount >0){
    item_existed <- data_item$fnumber
    flag <-    !item_list %in% item_existed
    res <-res[flag,]
  }else{
    res <- res

  }

  #返回结果
  return(res)

}

#自制物料的分配*******核心代码------------

#' 自制物料的分配-----
#'
#' @param config_file 配置文件
#' @param batchNo 批次
#' @param conn_erp 物料
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_Allocated_zz()
PLM_Item_Allocated_zz <- function(config_file = "config/conn_tc.R",batchNo='APP00000005',
                                  conn_erp = conn_vm_erp_test()) {
  #1.1读取新增物料数据----
  df_new <- PLM_Item_readByBatchNo_ZZ_New(config_file = config_file,batchNo = batchNo,
                                          conn_erp = conn_erp)
  ###print('test_new:')
  ###print(df_new)
  ncount <- nrow(df_new)


  #1.2读取待分配数据------
  df_unAlloc <- mdmpkg::Item_getUnAllocateNumbers(conn=conn_erp,n = ncount,FPropType = '自制')
  ###print('df_unallocation:')
  ###print(df_unAlloc)
  #1.3 执行物料分配 ----
  res <- tsdo::allocate(df_new,df_unAlloc)
  ###print('test--1---')
  ###print(res)

  #1.4 添加批号信息及相关信息------
  res$FBatchNo <- batchNo
  res$FIsdo <- 0
  res$FItemId <- 0
  #上级物料编码
  res$FParentNumber <- mdmpkg::mdm_getParentNumber(res$MCode)


  #1.5 将相关结果写入ERP数据库-----
  #需要新加一个字段
  try(tsda::db_writeTable(conn = conn_erp,table_name = 't_item_rdsInput',r_object = res,append = T))

  #1.6 更新分配表的状态
  sql_rdsroom_upd <- paste0("update a set a.fnumber_new = b.MCode,a.FFlag =1  from  t_item_rdsroom a
inner join  t_item_rdsInput b
on a.fnumber=b.fnumber
and b.fbatchNum='",batchNo,"' and mprop='自制'")
  tsda::sql_update(conn_erp,sql_str = sql_rdsroom_upd)
  #更新物料输入表的物料的内码
  sql_rdsInput_itemID <- paste0("  update b  set   b.fitemid = a.fitemid  from  t_item_rdsroom a
  inner join  t_item_rdsInput b
  on a.fnumber=b.fnumber
  where b.fbatchNum='",batchNo,"' and mprop='自制' and a.fitemclassid =4 ")
  tsda::sql_update(conn_erp,sql_str = sql_rdsInput_itemID)
  #1.7 处理物料主表----
  sql_item_rds <- paste0("update  a set  a.FNumber =b.MCode ,a.FName=b.MName,a.fparentid = i.FItemID   from t_item_rds a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid
inner join t_item  i
on b.fParentNumber = i.FNumber
where  b.fbatchNum='",batchNo,"' and mprop='自制'
")
  tsda::sql_update(conn_erp,sql_str = sql_item_rds)
  #处理物料核心表----
  sql_item_core <- paste0("update a set    a.FNumber = b.MCode ,a.FName = b.MName ,a.FModel = b.Spec  from t_ICItemCore a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid

where  b.fbatchNum='",batchNo,"' and mprop='自制'
")
  tsda::sql_update(conn_erp,sql_str = sql_item_core)
  #处理物料自定义表----
  sql_item_custom <- paste0("update a set   a.F_119 = b.MDesc   from t_ICItemCustom a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid

where  b.fbatchNum='",batchNo,"' and mprop='自制'
")
  tsda::sql_update(conn_erp,sql_str = sql_item_custom)
  #更新物料的单位----
  sql_item_base <- paste0("update a set  FUnitID = m.FMeasureUnitID,FUnitGroupID=m.FUnitGroupID,
FOrderUnitID =m.FMeasureUnitID,
FProductUnitID =m.FMeasureUnitID,
FSaleUnitID =m.FMeasureUnitID,
FStoreUnitID = m.FMeasureUnitID
from t_ICItemBase a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid
inner join t_MeasureUnit m
on b.UOM  = m.FName
where  b.fbatchNum='",batchNo,"' and mprop='自制'")
  tsda::sql_update(conn_erp,sql_str = sql_item_base)
  #1.8将物料从缓存区更新到主表------
  sql_item_pushBack <- paste0("INSERT INTO [dbo].t_item
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
		   from t_item_rds
		   where fitemid in
		   (select fitemid  from  t_item_rdsInput b
where
 b.fbatchNum='",batchNo,"' and mprop='自制')

                ")
  tsda::sql_update(conn_erp,sql_str = sql_item_pushBack)

  #1.9更新物料表的状态---
  sql_itemInput_updateStatus <- paste0("update  b set FIsDo =1   from  t_item_rdsInput b
where
 b.fbatchNum='",batchNo,"' and mprop='自制'")
  tsda::sql_update(conn_erp,sql_str = sql_itemInput_updateStatus)
  #1.10更新中间表的状态-------
  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)


  # sql_item_tc <- paste0("  update a set ERPOperation ='R',ERPDate=GETDATE()
  #                       from PLMtoERP_Item  a  where PLMBatchnum ='",batchNo,"'
  #                       and MProp = N'自制'")
  ERP_DATE = as.character(Sys.time())
  sql_item_tc <- paste0("  update a set ERPOperation ='R',ERPDate= '",ERP_DATE,"'
                        from PLMtoERP_Item  a  where PLMBatchnum ='",batchNo,"'
                        and MProp = N'自制'")
  tsda::sql_update(conn_tc,sql_str = sql_itemInput_updateStatus)


}


#' 委外物料的读取
#'
#' @param config_file 配置文件
#' @param batchNo 批次号
#'
#' @return 返回所有相关的物料
#' @export
#'
#' @examples
#' PLM_Item_readByBatchNo_WW()
PLM_Item_readByBatchNo_WW <- function(config_file = "config/conn_tc.R",batchNo='APP00000005') {


  res <- PLM_Item_readByBatchNo_aux(config_file = config_file,propType = '委外加工',batchNo = batchNo)

  #返回结果
  return(res)

}



#' 获取最新的委外物料信息
#'
#' @param config_file 配置文件
#' @param batchNo 批号
#' @param conn_erp ERP连接信息
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_readByBatchNo_WW_New()
PLM_Item_readByBatchNo_WW_New <- function(config_file = "config/conn_tc.R",batchNo='APP00000005',
                                          conn_erp = conn_vm_erp_test()) {


  res <- PLM_Item_readByBatchNo_aux(config_file = config_file,propType = '委外加工',batchNo = batchNo)
  #读取ERP数据
  item_list <- res$MCode
  #获取ERP数据
  data_item <- item_getNumber(conn_erp = conn_erp,item_list = item_list)
  ncount <- nrow(data_item)
  if(ncount >0){
    item_existed <- data_item$fnumber
    flag <-    !item_list %in% item_existed
    res <-res[flag,]
  }else{
    res <- res

  }


  #返回结果
  return(res)

}


# 委外物料的核心算法******-----------
# 考虑规范全部使用委外加工---
# FPropType = '委外'
# mprop='委外加工'
#
#' 委外加工
#'
#' @param config_file 连接
#' @param batchNo 批号
#' @param conn_erp 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_Allocated_ww()
PLM_Item_Allocated_ww <- function(config_file = "config/conn_tc.R",batchNo='APP00000005',
                                  conn_erp = conn_vm_erp_test()) {
  #1.1读取新增物料数据----
  df_new <- PLM_Item_readByBatchNo_WW_New(config_file = config_file,batchNo = batchNo,
                                          conn_erp = conn_erp)
  ###print('test_new:')
  ##print(df_new)
  ncount <- nrow(df_new)


  #1.2读取待分配数据------
  df_unAlloc <- mdmpkg::Item_getUnAllocateNumbers(conn=conn_erp,n = ncount,FPropType = '委外')
  ##print('df_unallocation:')
  ##print(df_unAlloc)
  #1.3 执行物料分配 ----
  res <- tsdo::allocate(df_new,df_unAlloc)
  ##print('test--1---')
  ##print(res)

  #1.4 添加批号信息及相关信息------
  res$FBatchNo <- batchNo
  res$FIsdo <- 0
  res$FItemId <- 0
  #上级物料编码
  res$FParentNumber <- mdmpkg::mdm_getParentNumber(res$MCode)


  #1.5 将相关结果写入ERP数据库-----
  #需要新加一个字段
  try(tsda::db_writeTable(conn = conn_erp,table_name = 't_item_rdsInput',r_object = res,append = T))

  #1.6 更新分配表的状态
  sql_rdsroom_upd <- paste0("update a set a.fnumber_new = b.MCode,a.FFlag =1  from  t_item_rdsroom a
inner join  t_item_rdsInput b
on a.fnumber=b.fnumber
and b.fbatchNum='",batchNo,"' and mprop='委外加工'")
  tsda::sql_update(conn_erp,sql_str = sql_rdsroom_upd)
  #更新物料输入表的物料的内码
  sql_rdsInput_itemID <- paste0("  update b  set   b.fitemid = a.fitemid  from  t_item_rdsroom a
  inner join  t_item_rdsInput b
  on a.fnumber=b.fnumber
  where b.fbatchNum='",batchNo,"' and mprop='委外加工' and a.fitemclassid =4 ")
  tsda::sql_update(conn_erp,sql_str = sql_rdsInput_itemID)
  #1.7 处理物料主表----
  sql_item_rds <- paste0("update  a set  a.FNumber =b.MCode ,a.FName=b.MName,a.fparentid = i.FItemID   from t_item_rds a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid
inner join t_item  i
on b.fParentNumber = i.FNumber
where  b.fbatchNum='",batchNo,"' and mprop='委外加工'
")
  tsda::sql_update(conn_erp,sql_str = sql_item_rds)
  #处理物料核心表----
  sql_item_core <- paste0("update a set    a.FNumber = b.MCode ,a.FName = b.MName ,a.FModel = b.Spec  from t_ICItemCore a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid

where  b.fbatchNum='",batchNo,"' and mprop='委外加工'
")
  tsda::sql_update(conn_erp,sql_str = sql_item_core)
  #处理物料自定义表----
  sql_item_custom <- paste0("update a set   a.F_119 = b.MDesc   from t_ICItemCustom a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid

where  b.fbatchNum='",batchNo,"' and mprop='委外加工'
")
  tsda::sql_update(conn_erp,sql_str = sql_item_custom)
  #更新物料的单位----
  sql_item_base <- paste0("update a set  FUnitID = m.FMeasureUnitID,FUnitGroupID=m.FUnitGroupID,
FOrderUnitID =m.FMeasureUnitID,
FProductUnitID =m.FMeasureUnitID,
FSaleUnitID =m.FMeasureUnitID,
FStoreUnitID = m.FMeasureUnitID
from t_ICItemBase a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid
inner join t_MeasureUnit m
on b.UOM  = m.FName
where  b.fbatchNum='",batchNo,"' and mprop='委外加工'")
  tsda::sql_update(conn_erp,sql_str = sql_item_base)
  #1.8将物料从缓存区更新到主表------
  sql_item_pushBack <- paste0("INSERT INTO [dbo].t_item
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
		   from t_item_rds
		   where fitemid in
		   (select fitemid  from  t_item_rdsInput b
where
 b.fbatchNum='",batchNo,"' and mprop='委外加工')

                ")
  tsda::sql_update(conn_erp,sql_str = sql_item_pushBack)

  #1.9更新物料表的状态---
  sql_itemInput_updateStatus <- paste0("update  b set FIsDo =1   from  t_item_rdsInput b
where
 b.fbatchNum='",batchNo,"' and mprop='委外加工'")
  tsda::sql_update(conn_erp,sql_str = sql_itemInput_updateStatus)
  #1.10更新中间表的状态-------
  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)
  ERP_DATE = as.character(Sys.time())
  sql_item_tc <- paste0("  update a set ERPOperation ='R',ERPDate= '",ERP_DATE,"'
                        from PLMtoERP_Item  a  where PLMBatchnum ='",batchNo,"'
                        and MProp = N'委外加工'")
  # sql_item_tc <- paste0("  update a set ERPOperation ='R',ERPDate=GETDATE()
  #                       from PLMtoERP_Item  a  where PLMBatchnum ='",batchNo,"'
  #                       and MProp = N'委外加工'")
  tsda::sql_update(conn_tc,sql_str = sql_itemInput_updateStatus)


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
#1.1.04A 初始化物料处理外购物料-----

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



#1.1.04B初始化物料处理自制物料--------
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
#1.1.04C初始化物料处理委外加工物料--------
#' 处理委外待分配数据
#'
#' @param conn 连接
#' @param table_name_rds 物料明细表
#' @param table_name_room 待分配信息表
#'
#' @return 返回值
#' @export
#'
#' @examples
#' md_pushItem2UnAllocated_ww()
Item_Initial_WW <-function(conn=vmrdspkg::conn_vm_erp_test(),
                           table_name_rds='t_Item_rds',
                           table_name_room ='t_item_rdsRoom'
){

  sql_item <- paste0("select  count(1)  as Fcount
		   from t_item
		where FNumber like 'RDS.03.%'
		and fname = 'WW'")
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
		where FNumber like 'RDS.03.%'
		and fname = 'WW'")
    #深度对数据进行数据
    try(tsda::sql_update(conn,sql_wg))

    sql_room <- paste0("insert into ",table_name_room,"
select
          [FItemClassID],

          [FItemID]


           ,[FNumber]

           ,[FName],
		   '委外加工' as FPropType,
		   '' as FNumber_New,
		   0 as FFlag

		   from t_item
		where FNumber like 'RDS.03.%'
		and fname = 'WW'")

    try(tsda::sql_update(conn,sql_room))

    sql_del <- paste0("delete from t_item
		where FNumber like 'RDS.03.%'
		and fname = 'WW'")
    try(tsda::sql_update(conn,sql_del))

    res <- TRUE
  }else{
    res <- FALSE
  }
  return(res)
}

#1.1.05 返回未分配物料-----
#' 返回未分配的物料数据
#'
#' @param conn 连接
#' @param MProp 物料属性
#' @param n  返回数量
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_getUnAllocateNumber()
Item_getUnAllocateNumber <- function(conn=conn_vm_erp_test(),
                                     MProp='外购') {
  #获取相应的数据物料数据，不考虑成本成本对象
  # 但是更新数据时需要考虑成本对象的
  sql <- paste0(" select  top  1  FNumber from t_item_rdsroom
 where  FPropType = '",MProp,"' and FFlag = 0 and FItemClassId = 4
 order by FNumber")
  data <- tsda::sql_select(conn,sql)
  ncount <-nrow(data)
  if(ncount >0){
    res <- data$FNumber
  }else{
    res <- NULL
    #print('没有待分配的物料，请联系管理员处理')
  }
  return(res)

}

#' 获取未分配的物料内码
#'
#' @param conn 连接
#' @param FNumber 物料代码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_getUnAllocateItemId()
Item_getUnAllocateItemId <- function(conn=conn_vm_erp_test(),
                                     FNumber='') {
  #获取相应的数据物料数据，不考虑成本成本对象
  # 但是更新数据时需要考虑成本对象的
  sql <- paste0(" select FItemID from t_item_rdsroom
where FNumber ='",FNumber,"' and FItemClassID =4 ")
  data <- tsda::sql_select(conn,sql)
  ncount <-nrow(data)
  if(ncount >0){
    res <- data$FItemID
  }else{
    res <- NULL
    #print('没有待分配的物料内码，请联系管理员处理')
  }
  return(res)

}

# 1.1.06-------
#' 读取数据
#'
#' @param conn 连接
#' @param MCode 物料
#' @param MProp 属性
#' @param PLMBatchnum 批次
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_ReadItem_One
Item_ReadItem_One <- function(conn=conn_vm_erp_test(),
                              MCode='3.02.09.001025',
                              MProp='外购',
                              PLMBatchnum='ECN00000002') {

  #获取处理批次
  sql <- paste0("select  MCode,MName,Spec,MDesc,UOM,MProp   from PLMtoERP_Item
where PLMBatchnum  ='",PLMBatchnum,"'  and MProp = N'",MProp,"'  and MCode ='",MCode,"' ")
  #print(sql)

  #返回结果
  res <- tsda::sql_select(conn = conn,sql_str = sql)

  #返回结果
  return(res)

}
#1.1.07 更新任务表的状态
#' 更新任务单状态
#'
#' @param conn 连接
#' @param MCode 物料代码
#' @param MProp 物料名称
#' @param PLMBatchnum 批次号
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_updateTaskStatus_One()
Item_updateTaskStatus_One <- function(conn=conn_vm_erp_test(),
                                      MCode='3.02.09.001025',
                                      MProp='外购',
                                      PLMBatchnum='ECN00000002') {
  #更新时间取ERP服务器时间
  #ERP_DATE = as.character(Sys.time())

  sql <- paste0("update a  set ERPOperation ='R',ERPDate=  GETDATE()
                        from  PLMtoERP_Item a
where PLMBatchnum ='",PLMBatchnum,"'  and MCode ='",MCode,"' and MProp ='",MProp,"'")
  tsda::sql_update(conn,sql_str = sql)

}

#1.07 获取成本对象人上级代码
#' 获取成本对象的代码
#'
#' @param conn 链接
#' @param MCode 物料
#'
#' @return 返回值
#' @export
#'
#' @examples
#' Item_GetParentItemId_costObj()
Item_GetParentItemId_costObj <- function(conn=conn_vm_erp_test(),
                                         MCode='3.02.09.001025') {
  FParentNumber_CB = mdmpkg::mdm_getParentNumber(MCode)
  sql <- paste0("select  FItemID from t_item where FNumber ='",FParentNumber_CB,"' and FItemClassID = 2001")
  r <- tsda::sql_select(conn,sql_str = sql)
  ncount = nrow(r)
  if(ncount >0){
    res <- r$FItemID
  }else{
    res <- 0
  }
  return(res)
}

#' to get the obj Itemid
#'
#' @param conn  conn
#' @param FNumber  new number for prebook
#'
#' @return return value
#' @export
#'
#' @examples
#' Item_getItemID_costObj()
Item_getItemID_costObj <- function(conn=conn_vm_erp_test2(),
                                   FNumber='RDS.02.000002') {

  sql <- paste0("select FItemId from t_item_rdsRoom where FPropTYPE ='自制' and FItemClassId =2001 and fnumber ='",FNumber,"'")
  ##print(sql)
  r <- tsda::sql_select(conn,sql_str = sql)
  ##print(r)
  ncount = nrow(r)
  if(ncount >0){
    res <- r$FItemId
  }else{
    res <- 0
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
  #获取物料
  FItemId = item_GetInterId(conn_erp = conn,FItemNumber = MCode)
  #读取传过来的信息
  res <- Item_ReadItem_One(conn = conn,MCode = MCode,MProp = MProp,PLMBatchnum = PLMBatchnum)
  #print('step1 ')
  #print(res)
  #print(FItemId)
  if(FItemId >0){
    #物料已经存在
    #说明物料编码已经存在修改相关的信息即可
    if(MProp == '外购'){
      #1.1A外购物料修改处理----


    }else if(MProp == '自制'){
      #1.1B自制物料修改处理----


    }else if(MProp == '委外加工'){
      #1.1C委外加工物料修改处理----


    }else{

      #1.1D其他属性物料修改处理----


    }
    #更新状态
    Item_updateTaskStatus_One(conn = conn,MCode = MCode,MProp = MProp,PLMBatchnum = PLMBatchnum)
  }else{
    #物料不存在
    #传入新分配的物料编码
    #print('s1')
    FNumber = Item_getUnAllocateNumber(conn = conn,MProp = MProp)
    #print('s1')
    #print(FNumber)
    #分配数据
    res$FNumber <-  FNumber
    res$FBatchNo <- PLMBatchnum
    res$FIsdo <- 0
    FItemId <- Item_getUnAllocateItemId(conn = conn,FNumber = FNumber)
    res$FItemId <- FItemId
    #上级物料编码
    res$FParentNumber <- mdmpkg::mdm_getParentNumber(MCode)
    try(tsda::db_writeTable(conn = conn,table_name = 't_item_rdsInput',r_object = res,append = T))
    #更新分配结果表,处理逻辑包含成本对象
    sql_rdsroom_upd <- paste0("update a set a.fnumber_new = '",MCode,"',a.FFlag =1  from  t_item_rdsroom a
                            where FNumber = '",FNumber,"' ")
    tsda::sql_update(conn=conn,sql_str = sql_rdsroom_upd)
    #更新内码,不需要更新物料内码
    # sql_rdsInput_itemID <- paste0("  update b  set   b.fitemid = a.fitemid  from  t_item_rdsroom a
    # inner join  t_item_rdsInput b
    # on a.fnumber=b.fnumber
    # where  a.fitemclassid =4  and b.fnumber = '",FNumber,"'")
    # tsda::sql_update(conn,sql_str = sql_rdsInput_itemID)
    #

    #1.7 处理物料主表----
    sql_item_rds <- paste0("update  a set  a.FNumber =b.MCode ,a.FName=b.MName,a.fparentid = i.FItemID   from t_item_rds a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid
inner join t_item  i
on b.fParentNumber = i.FNumber
where  a.fnumber = '",FNumber,"'")
    tsda::sql_update(conn,sql_str = sql_item_rds)
    #处理物料核心表----
    sql_item_core <- paste0("update a set    a.FNumber = b.MCode ,a.FName = b.MName ,a.FModel = b.Spec  from t_ICItemCore a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid

where  a.fnumber = '",FNumber,"'")
    tsda::sql_update(conn,sql_str = sql_item_core)
    #处理物料自定义表----
    sql_item_custom <- paste0("update a set   a.F_119 = b.MDesc   from t_ICItemCustom a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid

where  b.fitemid =  ",FItemId)
    tsda::sql_update(conn,sql_str = sql_item_custom)
    #更新物料属性表
    #列新数据
    timeValue = as.character(Sys.time())
    sql_item_baseProp <- paste0("update a set   a.FCreateDate = '",timeValue,"'   from t_BaseProperty a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid

where  b.fitemid =  ",FItemId)
    tsda::sql_update(conn,sql_str = sql_item_baseProp)

    #更新物料的单位----
    sql_item_base <- paste0("update a set  FUnitID = m.FMeasureUnitID,FUnitGroupID=m.FUnitGroupID,
FOrderUnitID =m.FMeasureUnitID,
FProductUnitID =m.FMeasureUnitID,
FSaleUnitID =m.FMeasureUnitID,
FStoreUnitID = m.FMeasureUnitID
from t_ICItemBase a
inner join  t_item_rdsInput b
on a.fitemid = b.fitemid
inner join t_MeasureUnit m
on b.UOM  = m.FName
 where  b.fitemid =  ",FItemId)
    tsda::sql_update(conn,sql_str = sql_item_base)
    #1.8将物料从缓存区更新到主表------
    sql_item_pushBack <- paste0("INSERT INTO [dbo].t_item
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
		   from t_item_rds
		   where fitemid = ",FItemId)
    tsda::sql_update(conn,sql_str = sql_item_pushBack)

    #1.9更新物料表的状态---
    sql_itemInput_updateStatus <- paste0("update  b set FIsDo =1   from  t_item_rdsInput b
where   b.fitemid = ",FItemId)
    tsda::sql_update(conn,sql_str = sql_itemInput_updateStatus)
    #1.10更新中间表的状态-------
    #读取配置文件
    Item_updateTaskStatus_One(conn = conn,MCode = MCode,MProp = MProp,PLMBatchnum = PLMBatchnum)
    #处理低值易消品取消批次管理
    #按物料进行列新 FNumber
    sql_LowPriceMtrl_cancelBatchManger <- paste0("update im set im.FBatchManager = 0
from t_ICItem i inner JOIN
rds_t_item_LowPriceMtrl l
on left(i.FNumber ,8) = l.Fnumber
inner join t_ICItemMaterial im
on i.FItemID  = im.FItemID
where im.FBatchManager <> 0 and i.FNumber ='",FNumber,"' ")

    tsda::sql_update(conn,sql_str = sql_LowPriceMtrl_cancelBatchManger)
    #设置低值易消耗品的默认仓库仓位
    sql_LowPriceMtrl_setDefaultStockPlace <- paste0("update im set im.fdefaultloc=13149,fspid =0
from t_ICItem i inner JOIN
rds_t_item_LowPriceMtrl l
on left(i.FNumber ,8) = l.Fnumber
inner join t_ICItembase im
on i.FItemID  = im.FItemID
where im.FDefaultLoc <> 13149 and im.FSPID <>0 and i.FNumber ='",FNumber,"'")
    tsda::sql_update(conn,sql_str = sql_LowPriceMtrl_setDefaultStockPlace)
    #低值易消耗处理结束
    #增加对物料上级组的处理
    sql_parentId_update = paste0("update b set  b.FParentID = a.fparentid  from t_item  a
inner join t_ICItemCore b
on a.FItemID  = b.FItemID
where  a.FItemClassID  = 4
and a.FParentID  <> b.FParentID")
    tsda::sql_update(conn,sql_str = sql_parentId_update)

    if(MProp == '外购'){
      #1.1E外购物料新增处理----


    }else if(MProp == '自制'){
      #1.1F自制物料新增处理----
      #成本对象的处理
      FParentItemID_obj = Item_GetParentItemId_costObj(conn = conn,MCode = MCode)
      FItemId_obj = Item_getItemID_costObj(conn=conn,FNumber = FNumber )
      sql_obj_rds <- paste0("update  a set  a.FNumber =  '",MCode,"' ,a.FName=   '",res$MName,"'  ,  a.fparentid =  ",FParentItemID_obj,"   from t_item_rds a
                            where a.FItemId =  ",FItemId_obj)
      tsda::sql_update(conn,sql_str = sql_obj_rds)
      #wirte back
      sql_obj_pushBack <- paste0("INSERT INTO [dbo].t_item
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
		   from t_item_rds
		   where fitemid = ",FItemId_obj)
      tsda::sql_update(conn,sql_str = sql_obj_pushBack)
      # 更新成本对象表
      sql_obj_table <- paste0("update  a set  a.FNumber =  '",MCode,"' ,a.FName=   '",res$MName,"'  ,  a.fparentid =  ",FParentItemID_obj,"   from cbCostObj a
                            where a.FItemId =  ",FItemId_obj)
      tsda::sql_update(conn,sql_str = sql_obj_table)





    }else if(MProp == '委外加工'){
      #1.1G委外加工物料新增处理---


    }else{
      #1.1H其他属性物料新增处理-----


    }

  }



  #写入日志表
  gc()


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

#' 清楚BUG
#'
#' @param conn 链接
#' @param FNumber 代码
#'
#' @return return value
#' @export
#'
#' @examples
#' item_debug_clear()
item_debug_clear <- function(conn=conn_vm_erp_test(),FNumber='3.02.02.001293') {
  sql01 = paste0("delete  from   t_item_rdsRoom  where fnumber_new =  '",FNumber,"'")
  sql02 = paste0("delete  from t_item_rdsInput where mcode =  '",FNumber,"'")
  sql03 = paste0("delete  from t_item_rds where  fnumber =  '",FNumber,"'")
  sql04 = paste0("delete   from t_icitem where  fnumber =  '",FNumber,"'")
  sql05 = paste0("delete   from t_item where  fnumber =  '",FNumber,"'")
  tsda::sql_update(conn,sql01)
  tsda::sql_update(conn,sql02)
  tsda::sql_update(conn,sql03)
  tsda::sql_update(conn,sql04)
  tsda::sql_update(conn,sql05)

}









