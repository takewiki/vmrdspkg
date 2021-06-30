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
  # print(sql)

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
  #print(sql_item)
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
  #print('test_new:')
  #print(df_new)
  ncount <- nrow(df_new)





  #1.2读取待分配数据------
  df_unAlloc <- mdmpkg::Item_getUnAllocateNumbers(conn=conn_erp,n = ncount,FPropType = '外购')
  #print('df_unallocation:')
  #print(df_unAlloc)
  #1.3 执行物料分配 ----
  res <- tsdo::allocate(df_new,df_unAlloc)
  #print('test--1---')
  #print(res)

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
  print('test_new:')
  print(df_new)
  ncount <- nrow(df_new)


  #1.2读取待分配数据------
  df_unAlloc <- mdmpkg::Item_getUnAllocateNumbers(conn=conn_erp,n = ncount,FPropType = '自制')
  print('df_unallocation:')
  print(df_unAlloc)
  #1.3 执行物料分配 ----
  res <- tsdo::allocate(df_new,df_unAlloc)
  print('test--1---')
  print(res)

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
  print('test_new:')
  print(df_new)
  ncount <- nrow(df_new)


  #1.2读取待分配数据------
  df_unAlloc <- mdmpkg::Item_getUnAllocateNumbers(conn=conn_erp,n = ncount,FPropType = '委外')
  print('df_unallocation:')
  print(df_unAlloc)
  #1.3 执行物料分配 ----
  res <- tsdo::allocate(df_new,df_unAlloc)
  print('test--1---')
  print(res)

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












