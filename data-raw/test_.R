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
  sql_item_tc <- paste0("  update a set ERPOperation ='R',ERPDate=GETDATE()
                        from PLMtoERP_Item  a  where PLMBatchnum ='",batchNo,"'
                        and MProp = N'外购'")
  tsda::sql_update(conn_tc,sql_str = sql_itemInput_updateStatus)









  #更新TC数据库的状态, 后续进行批量更新






  #返回结果
  return(res)

}
