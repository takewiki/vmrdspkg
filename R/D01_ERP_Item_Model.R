#########################################################################
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#########################################################################
# 0.1根据已有的物料编码获取同类的标准物料-----
# 方法上还有有待优化，针对新增的物料，ERP系统中其实并没有处理
# 因此还是需要进行必要的处理
# 目前VM的物料编码的尾号还是不统一的，需要使用辅助函数进行处理
#' 根据最新的物料编码获取同分组的最大物料编码
#'
#' @param config_file 配置文件
#' @param FNumber 物料编码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' ERP_Item_getMaxItemNoByGroup()
ERP_Item_getMaxItemNoByGroup <- function(config_file = "config/conn_k3.R",FNumber='1.105.04.00001') {
  sql <- paste0("select max(FNumber) as FMaxNumber from t_ICItem where
FParentID in
(select  FParentID from t_ICItem where FNumber='1.105.04.00001'
)")


}


#1.1物料新增-------
#' 处理物料新增数据
#'
#' @param config_file 配置文件
#' @param data_item  物料新增
#'
#' @return 返回值
#' @export
#'
#' @examples
#' ERP_Item_New()
ERP_Item_New <- function(config_file = "config/conn_k3.R",data_item) {

}



#1.2物料属性的修改-------
#其中物料编码、计量单位、物料属性不会修改
# 其他属于可能会变化
#' 物料修改属性
#'
#' @param config_file 配置文件
#' @param data_item 物料数据
#'
#' @return 返回值
#' @export
#'
#' @examples
#' ERP_Item_Modify()
ERP_Item_Modify <- function(config_file = "config/conn_k3.R",data_item) {

}


# 1.3物料的逻辑禁用-----
# 通过修改物料的备注属性进行禁用
# 不做其他过多的内容
# ERP系统中也不执行【禁用】操作
#' 物料禁用
#'
#' @param config_file 配置文件
#' @param data_item 物料数据
#'
#' @return 返回值
#' @export
#'
#' @examples
#' ERP_Item_Disable()
ERP_Item_Disable <- function(config_file = "config/conn_k3.R",data_item) {

}





#' get the initial item value
#'
#' @param conn_erp  conn1
#' @param conn_plm conn2
#'
#' @return return value
#' @export
#'
#' @examples
#' item_selectValue_ERP2PLM()
item_selectValue_ERP2PLM<- function(conn_erp=conn_vm_erp_test2(),conn_plm=conn_vm_plm_prd()) {

  sql <-  paste0("  select * from  rds_md_item4TC_Test")
  r <- tsda::sql_select(conn_erp,sql)
  print(str(r))
  r$PLMDate <-  as.character(r$PLMDate)
  r$PLMOperation <- as.character(r$PLMOperation)
  ncount =nrow(r)
  if (ncount >0){
    #本地写入结果

    tsda::db_writeTable(conn = conn_erp,table_name = 'ERPtoPLM_Item',r_object = r,append = T)

    #写入PLM数据库
    tsda::db_writeTable(conn = conn_plm,table_name = 'ERPtoPLM_Item_Input',r_object = r,append = T)
    sql_ins <-paste0("INSERT INTO [dbo].[ERPtoPLM_Item]
           ([MCode]
           ,[MName]
           ,[Spec]
           ,[MDesc]
           ,[UOM]
           ,[MProp]
           ,[PLMOperation]
           ,[ERPOperation]
           ,[PLMDate]
           ,[ERPDate])
           select * from ERPtoPLM_Item_Input

                     ")


      tsda::sql_update(conn = conn_plm,sql_str = sql_ins)
      sql_truncate <- paste0(" truncate table  ERPtoPLM_Item_Input ")
      tsda::sql_update(conn = conn_plm,sql_str = sql_truncate)


  }

  return(r)



}


#' get the initial item value
#'
#' @param conn_erp  conn1
#' @param conn_plm conn2
#' @param FNumbers 增加多选的物料编码
#'
#' @return return value
#' @export
#'
#' @examples
#' item_selectValue_ERP2PLM_multi()
item_selectValue_ERP2PLM_multi<- function(conn_erp=conn_vm_erp_test2(),conn_plm=conn_vm_plm_prd(),FNumbers) {
  FNumbers_sql <- sql_Fnumber_multi(FNumbers)
  #支持多选的情况处理
  sql <-  paste0("select * from  rds_md_item4TC_Test
where MCode in (",FNumbers_sql,")")
  r <- tsda::sql_select(conn_erp,sql)
  print(str(r))

  ncount =nrow(r)
  if (ncount >0){
    #本地写入结果
    r$PLMDate <-  as.character(r$PLMDate)
    r$PLMOperation <- as.character(r$PLMOperation)
    tsda::db_writeTable(conn = conn_erp,table_name = 'ERPtoPLM_Item',r_object = r,append = T)

    #写入PLM数据库
    tsda::db_writeTable(conn = conn_plm,table_name = 'ERPtoPLM_Item_Input',r_object = r,append = T)
    sql_ins <-paste0("INSERT INTO [dbo].[ERPtoPLM_Item]
           ([MCode]
           ,[MName]
           ,[Spec]
           ,[MDesc]
           ,[UOM]
           ,[MProp]
           ,[PLMOperation]
           ,[ERPOperation]
           ,[PLMDate]
           ,[ERPDate])
           select * from ERPtoPLM_Item_Input

                     ")


    tsda::sql_update(conn = conn_plm,sql_str = sql_ins)
    sql_truncate <- paste0(" truncate table  ERPtoPLM_Item_Input ")
    tsda::sql_update(conn = conn_plm,sql_str = sql_truncate)
    res <- TRUE


  }else{
    res <- FALSE
  }

  return(res)



}

#' get the initial item value
#'
#' @param conn_erp  conn1
#' @param conn_plm conn2
#'
#' @return return value
#' @export
#'
#' @examples
#' item_selectValue_ERP2PLM_newRead
item_selectValue_ERP2PLM_newRead<- function(conn_erp=conn_vm_erp_test2(),conn_plm=conn_vm_plm_prd()) {

  #支持多选的情况处理
  sql <-  paste0("select mcode,MName,spec from  rds_md_item4TC_Test

where MCode not in
(select MCode from ERPtoPLM_Item
union
select MCode  from PLMtoERP_Item)")
  r <- tsda::sql_select(conn_erp,sql)
  ncount <- nrow(r)
  if(ncount >0){
    #存在数据的情况下
    names(r) <- c('编码','名称','规格型号')


  }


  return(r)



}


#' 填写相应的初始化物料数据
#'
#' @param conn_erp ERP连接
#' @param conn_plm PLM连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' item_selectValue_ERP2PLM_newWrite()
item_selectValue_ERP2PLM_newWrite<- function(conn_erp=conn_vm_erp_test2(),conn_plm=conn_vm_plm_prd()) {

  #支持多选的情况处理
  sql <-  paste0("select * from  rds_md_item4TC_Test

where MCode not in
(select MCode from ERPtoPLM_Item
union
select MCode  from PLMtoERP_Item)")
  r <- tsda::sql_select(conn_erp,sql)
  print(str(r))

  ncount =nrow(r)
  if (ncount >0){
    #本地写入结果
    r$PLMDate <-  as.character(r$PLMDate)
    r$PLMOperation <- as.character(r$PLMOperation)
    tsda::db_writeTable(conn = conn_erp,table_name = 'ERPtoPLM_Item',r_object = r,append = T)

    #写入PLM数据库
    tsda::db_writeTable(conn = conn_plm,table_name = 'ERPtoPLM_Item_Input',r_object = r,append = T)
    sql_ins <-paste0("INSERT INTO [dbo].[ERPtoPLM_Item]
           ([MCode]
           ,[MName]
           ,[Spec]
           ,[MDesc]
           ,[UOM]
           ,[MProp]
           ,[PLMOperation]
           ,[ERPOperation]
           ,[PLMDate]
           ,[ERPDate])
           select * from ERPtoPLM_Item_Input

                     ")


    tsda::sql_update(conn = conn_plm,sql_str = sql_ins)
    sql_truncate <- paste0(" truncate table  ERPtoPLM_Item_Input ")
    tsda::sql_update(conn = conn_plm,sql_str = sql_truncate)
    res <- TRUE


  }else{
    res <- FALSE
  }

  return(res)



}



#' get the initial item value
#'
#' @param conn_erp  conn1
#' @param conn_plm conn2
#'
#' @return return value
#' @export
#'
#' @examples
#' ERPtoPLM_Item_ALL()
ERPtoPLM_Item_ALL<- function(conn_erp=conn_vm_erp_test2(),conn_plm=conn_vm_plm_prd()) {

  res <- item_selectValue_ERP2PLM(conn_erp = conn_erp,conn_plm = conn_plm)

  return(res)
}





