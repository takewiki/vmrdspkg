#1.1A读取物料批次通用函数------
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



#1.1A读取物料申请批次------
#' 读取物料申请的批次列表
#'
#' @param config_file 配置文件
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_App_getBatchNo()
PLM_Item_App_getBatchNo <- function(config_file = "config/conn_tc.R") {


  res <- PLM_Item_getBatchNo_Aux(config_file = config_file ,prefix = 'APP')

  #返回结果
  return(res)

}


#1.1B读取物料创建BOM中使用的物料批次------
#' 读取物料创建BOM时使用到的物料的批次列表
#'
#' @param config_file 配置文件
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_Bom_getBatchNo()
PLM_Item_Bom_getBatchNo <- function(config_file = "config/conn_tc.R") {


  res <- PLM_Item_getBatchNo_Aux(config_file = config_file ,prefix = 'BOM')

  #返回结果
  return(res)

}

#1.1C读取物料发布BOM中使用的物料批次------
#' 读取物料发布BOM时使用到的物料的批次列表
#'
#' @param config_file 配置文件
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_Prd_getBatchNo()
PLM_Item_Prd_getBatchNo <- function(config_file = "config/conn_tc.R") {


  res <- PLM_Item_getBatchNo_Aux(config_file = config_file ,prefix = 'PRD')

  #返回结果
  return(res)

}


#1.1D读取物料ECN中使用的物料批次------
#' 读取物料ECN时使用到的物料的批次列表
#'
#' @param config_file 配置文件
#'
#' @return 返回值
#' @export
#'
#' @examples
#' PLM_Item_Ecn_getBatchNo()
PLM_Item_Ecn_getBatchNo <- function(config_file = "config/conn_tc.R") {


  res <- PLM_Item_getBatchNo_Aux(config_file = config_file ,prefix = 'ECN')

  #返回结果
  return(res)

}






# 1.2按批次号获取新增物料信息------

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


PLM_Item_UpdateStatus <- function(config_file = "config/conn_tc.R",batchNo='APP00000005') {
  #读取配置文件
  cfg_tc <- tsda::conn_config(config_file = config_file)
  #打开连接
  conn_tc <- tsda::conn_open(conn_config_info = cfg_tc)
  sql <- past

}


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


  #读取数据
  df_new <- PLM_Item_readByBatchNo_WG_New(config_file = config_file,batchNo = batchNo,
                                       conn_erp = conn_erp)
  ncount <- nrow(df_new)
  #读取待分配数据
  df_unAlloc <- mdmpkg::Item_getUnAllocateNumbers(conn=conn_erp,n = ncount,FPropType = '外购')
  #执行分配
  res <- tsdo::allocate(df_new,df_unAlloc)
  #添加批号信息
  res$FBatchNo <- batchNo
  res$FIsdo <- 0

  #写入ERP数据库
  try(tsda::db_writeTable(conn = conn_erp,table_name = 't_item_rdsInput',r_object = res,append = T))
  #更新分配表的状态
  sql_rdsroom_upd <- paste0("update a set a.fnumber_new = b.MCode,a.FFlag =1  from  t_item_rdsroom a
inner join  t_item_rdsInput b
on a.fnumber=b.fnumber
and b.fbatchNum='",batchNo,"' and mprop='外购'")
  tsda::sql_update(conn_erp,sql_str = sql_rdsroom_upd)

  #更新TC数据库的状态





  #返回结果
  return(res)

}


name <- function(variables) {

}













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












