#' 通过BOM返回数据
#'
#' @param conn_erp ERP连接信息
#' @param FNumber 产品编码
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_bom_version_query()
erp_bom_version_query <- function(conn_erp,FNumber='1.100.04.00004') {
  sql <-paste0("select
FNumber as 产品代码,
FBOMNumber  as BOM编号,
FVersion_PLM as BOM版本
from rds_vw_bom_version
where FNumber='",FNumber,"'")
  data = tsda::sql_select(conn = conn_erp,sql_str = sql)
  return(data)
}


#' 检验BOM在生产订单中是否存在，如果存在则不执行删除功能
#'
#' @param conn_erp 连接信息
#' @param FNumber 产品代码
#' @param FVersion_PLM PLM版本号
#'
#' @return 返回值，存在返回True,不存在返回FALSE
#' @export
#'
#' @examples
#' erp_bom_existInMo()
erp_bom_existInMo <- function(conn_erp,FNumber='1.100.04.00004',FVersion_PLM ='A') {
  sql <-paste0("select a.FBillNo as FMoBillNo,b.FNumber as FPrdNumber,b.FVersion_PLM as FPlmVersion from icmo a
inner join  rds_vw_bom_version b
on a.FItemID = b.FItemID
where b.FNumber ='",FNumber,"' and b.FVersion_PLM ='",FVersion_PLM,"'")
  data = tsda::sql_select(conn = conn_erp,sql_str = sql)
  ncount =nrow(data)
  if(ncount){
    res = TRUE
  }else{
    res = FALSE
  }
  return(res)
}













#' 删除ERP系统中的BOM数据，删除前正式进行表级备份，可用于后续恢复一次
#'
#' @param conn_erp ERP连接信息
#' @param FNumber 编码
#' @param FVersion_PLM 版本
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_bom_version_delete()
erp_bom_version_delete <- function(conn_erp,FNumber='2.104.20.00001',FVersion_PLM ='A') {
  #插入数据到last
  # 可以用于恢复最近一次删除的记录
  #A01最新的数据，先处理表头----
  sql_bom_head_last <- paste0("insert into rds_icbom_bak_last
select a.*  from icbom a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
  tsda::sql_update(conn = conn_erp,sql_str = sql_bom_head_last)
  #A02最新一次表体数据------
  sql_bom_body_last <- paste0("insert into rds_icbomchild_bak_last([FBrNo]
           ,[FEntryID]
           ,[FInterID]
           ,[FItemID]
           ,[FAuxQty]
           ,[FQty]
           ,[FScrap]
           ,[FOperSN]
           ,[FOperID]
           ,[FMachinePos]
           ,[FNote]
           ,[FMaterielType]
           ,[FMarshalType]
           ,[FPercent]
           ,[FBeginDay]
           ,[FEndDay]
           ,[FOffSetDay]
           ,[FBackFlush]
           ,[FStockID]
           ,[FSPID]
           ,[FSupply]
           ,[FUnitID]
           ,[FAuxPropID]
           ,[FPDMImportDate]
           ,[FPositionNo]
           ,[FItemSize]
           ,[FItemSuite]
           ,[FNote1]
           ,[FNote2]
           ,[FNote3]
           ,[FHasChar]
           ,[FDetailID]
           ,[FCostPercentage]
           ,[FEntrySelfZ0142]
           ,[FEntrySelfZ0144]
           ,[FEntrySelfZ0148]
           ,[FEntrySelfZ0146]
           ,[FEntrySelfZ0145])
select  d.[FBrNo]
           ,d.[FEntryID]
           ,d.[FInterID]
           ,d.[FItemID]
           ,d.[FAuxQty]
           ,d.[FQty]
           ,d.[FScrap]
           ,d.[FOperSN]
           ,d.[FOperID]
           ,d.[FMachinePos]
           ,d.[FNote]
           ,d.[FMaterielType]
           ,d.[FMarshalType]
           ,d.[FPercent]
           ,d.[FBeginDay]
           ,d.[FEndDay]
           ,d.[FOffSetDay]
           ,d.[FBackFlush]
           ,d.[FStockID]
           ,d.[FSPID]
           ,d.[FSupply]
           ,d.[FUnitID]
           ,d.[FAuxPropID]
           ,d.[FPDMImportDate]
           ,d.[FPositionNo]
           ,d.[FItemSize]
           ,d.[FItemSuite]
           ,d.[FNote1]
           ,d.[FNote2]
           ,d.[FNote3]
           ,d.[FHasChar]
           ,d.[FDetailID]
           ,d.[FCostPercentage]
           ,d.[FEntrySelfZ0142]
           ,d.[FEntrySelfZ0144]
           ,d.[FEntrySelfZ0148]
           ,d.[FEntrySelfZ0146]
           ,d.[FEntrySelfZ0145]  from icbom a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
inner join ICBOMChild  d
on a.FInterID = d.FInterID
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
  tsda::sql_update(conn = conn_erp,sql_str = sql_bom_body_last)
  #处理历史数据
  #B01处理历史数据表头数据------
  sql_bom_head_hist <- paste0("insert into rds_icbom_bak_hist
select a.*  from icbom a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
  tsda::sql_update(conn = conn_erp,sql_str = sql_bom_head_hist)
#B02历史数据表体------
  sql_bom_body_hist <- paste0("insert into rds_icbomchild_bak_hist([FBrNo]
           ,[FEntryID]
           ,[FInterID]
           ,[FItemID]
           ,[FAuxQty]
           ,[FQty]
           ,[FScrap]
           ,[FOperSN]
           ,[FOperID]
           ,[FMachinePos]
           ,[FNote]
           ,[FMaterielType]
           ,[FMarshalType]
           ,[FPercent]
           ,[FBeginDay]
           ,[FEndDay]
           ,[FOffSetDay]
           ,[FBackFlush]
           ,[FStockID]
           ,[FSPID]
           ,[FSupply]
           ,[FUnitID]
           ,[FAuxPropID]
           ,[FPDMImportDate]
           ,[FPositionNo]
           ,[FItemSize]
           ,[FItemSuite]
           ,[FNote1]
           ,[FNote2]
           ,[FNote3]
           ,[FHasChar]
           ,[FDetailID]
           ,[FCostPercentage]
           ,[FEntrySelfZ0142]
           ,[FEntrySelfZ0144]
           ,[FEntrySelfZ0148]
           ,[FEntrySelfZ0146]
           ,[FEntrySelfZ0145])
select  d.[FBrNo]
           ,d.[FEntryID]
           ,d.[FInterID]
           ,d.[FItemID]
           ,d.[FAuxQty]
           ,d.[FQty]
           ,d.[FScrap]
           ,d.[FOperSN]
           ,d.[FOperID]
           ,d.[FMachinePos]
           ,d.[FNote]
           ,d.[FMaterielType]
           ,d.[FMarshalType]
           ,d.[FPercent]
           ,d.[FBeginDay]
           ,d.[FEndDay]
           ,d.[FOffSetDay]
           ,d.[FBackFlush]
           ,d.[FStockID]
           ,d.[FSPID]
           ,d.[FSupply]
           ,d.[FUnitID]
           ,d.[FAuxPropID]
           ,d.[FPDMImportDate]
           ,d.[FPositionNo]
           ,d.[FItemSize]
           ,d.[FItemSuite]
           ,d.[FNote1]
           ,d.[FNote2]
           ,d.[FNote3]
           ,d.[FHasChar]
           ,d.[FDetailID]
           ,d.[FCostPercentage]
           ,d.[FEntrySelfZ0142]
           ,d.[FEntrySelfZ0144]
           ,d.[FEntrySelfZ0148]
           ,d.[FEntrySelfZ0146]
           ,d.[FEntrySelfZ0145]  from icbom a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
inner join ICBOMChild  d
on a.FInterID = d.FInterID
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
  tsda::sql_update(conn = conn_erp,sql_str = sql_bom_body_hist)
#删除正式库的数据
#C01删除正式库的表体数据-----
 sql_bom_body_prd <- paste0("delete d  from icbom a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
inner join ICBOMChild  d
on a.FInterID = d.FInterID
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
 tsda::sql_update(conn = conn_erp,sql_str = sql_bom_body_prd)
 #C02删除正式库的表头数据-----
 sql_bom_head_prd <- paste0("delete a   from icbom a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
 tsda::sql_update(conn=conn_erp,sql_str = sql_bom_head_prd)
 #D01写入日志----
 sql_log <- paste0("insert into rds_bom_subVerLog
select  a.FInterid,b.FNumber,b.FName,b.FModel,a.FBomNumber,a.FVersion,v.FVersion_PLM,'01' as FSubVersion,convert(nvarchar(20),GETDATE(),120) as FDate  from icbom a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
 tsda::sql_update(conn = conn_erp,sql_str = sql_log)








}





#' 用于BOM数据的最近一次恢复
#'
#' @param conn_erp ERPl连接
#' @param FNumber 产品代码
#' @param FVersion_PLM 版本
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_bom_version_recover()
erp_bom_version_recover <- function(conn_erp,FNumber='2.104.20.00001',FVersion_PLM ='A') {
  #生产环境插入BOM表头-----
  sql_bom_head_prd <- paste0("insert into icbom
select a.*  from rds_icbom_bak_last a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
  tsda::sql_update(conn = conn_erp,sql_str = sql_bom_head_prd)
  #生产环境插入BOM表体----
  sql_bom_body_prd <- paste0("insert into ICBOMChild ([FBrNo]
           ,[FEntryID]
           ,[FInterID]
           ,[FItemID]
           ,[FAuxQty]
           ,[FQty]
           ,[FScrap]
           ,[FOperSN]
           ,[FOperID]
           ,[FMachinePos]
           ,[FNote]
           ,[FMaterielType]
           ,[FMarshalType]
           ,[FPercent]
           ,[FBeginDay]
           ,[FEndDay]
           ,[FOffSetDay]
           ,[FBackFlush]
           ,[FStockID]
           ,[FSPID]
           ,[FSupply]
           ,[FUnitID]
           ,[FAuxPropID]
           ,[FPDMImportDate]
           ,[FPositionNo]
           ,[FItemSize]
           ,[FItemSuite]
           ,[FNote1]
           ,[FNote2]
           ,[FNote3]
           ,[FHasChar]
           ,[FDetailID]
           ,[FCostPercentage]
           ,[FEntrySelfZ0142]
           ,[FEntrySelfZ0144]
           ,[FEntrySelfZ0148]
           ,[FEntrySelfZ0146]
           ,[FEntrySelfZ0145])
select  d.[FBrNo]
           ,d.[FEntryID]
           ,d.[FInterID]
           ,d.[FItemID]
           ,d.[FAuxQty]
           ,d.[FQty]
           ,d.[FScrap]
           ,d.[FOperSN]
           ,d.[FOperID]
           ,d.[FMachinePos]
           ,d.[FNote]
           ,d.[FMaterielType]
           ,d.[FMarshalType]
           ,d.[FPercent]
           ,d.[FBeginDay]
           ,d.[FEndDay]
           ,d.[FOffSetDay]
           ,d.[FBackFlush]
           ,d.[FStockID]
           ,d.[FSPID]
           ,d.[FSupply]
           ,d.[FUnitID]
           ,d.[FAuxPropID]
           ,d.[FPDMImportDate]
           ,d.[FPositionNo]
           ,d.[FItemSize]
           ,d.[FItemSuite]
           ,d.[FNote1]
           ,d.[FNote2]
           ,d.[FNote3]
           ,d.[FHasChar]
           ,d.[FDetailID]
           ,d.[FCostPercentage]
           ,d.[FEntrySelfZ0142]
           ,d.[FEntrySelfZ0144]
           ,d.[FEntrySelfZ0148]
           ,d.[FEntrySelfZ0146]
           ,d.[FEntrySelfZ0145]  from rds_icbom_bak_last  a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
inner join rds_icbomchild_bak_last  d
on a.FInterID = d.FInterID
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
  tsda::sql_update(conn=conn_erp,sql_str = sql_bom_body_prd)
  #删除最近表的中的表体记录-----
  sql_bom_last_body <- paste0("delete d  from rds_icbom_bak_last  a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
inner join rds_icbomchild_bak_last  d
on a.FInterID = d.FInterID
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
  tsda::sql_update(conn=conn_erp,sql_str = sql_bom_last_body)
  #删除最近表中的表头记录
 sql_bom_last_head <- paste0("delete  a  from rds_icbom_bak_last a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
 tsda::sql_update(conn=conn_erp,sql_str = sql_bom_last_head)







}



#' 检验BOM是否已存在
#'
#' @param conn_erp 连接信息
#' @param FNumber 产品代码
#' @param FVersion_PLM 产品版本
#'
#' @return 返回值，存在返回TRUE,不存在返回FALSE
#' @export
#'
#' @examples
#' erp_bom_existInBom()
erp_bom_existInBom <- function(conn_erp,FNumber='2.104.20.00001',FVersion_PLM ='A'){
  sql_bom_precheck <-paste0("select a.*  from icbom a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
  data = tsda::sql_select(conn = conn_erp,sql_str = sql_bom_precheck)
  ncount = nrow(data)
  if(ncount){
    res <- TRUE
  }else{
    res <- FALSE
  }
  return(res)
}


#' 检查可恢复记录表中是否存在相关记录
#'
#' @param conn_erp 连接
#' @param FNumber 产品代码
#' @param FVersion_PLM 版本
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_bom_existInLast()
erp_bom_existInLast <- function(conn_erp,FNumber='2.104.20.00001',FVersion_PLM ='A'){

  sql_bom_precheck <-paste0("select a.*  from rds_icbom_bak_last a
inner join t_ICItem b
on a.FItemID = b.FItemID
inner join rds_BOM_version v
on  a.FVersion = v.FVersion_ERP
where a.FUseStatus =1072
and b.FErpClsID <>7
and b.FNumber='",FNumber,"' and v.FVersion_PLM='",FVersion_PLM,"'")
  data = tsda::sql_select(conn = conn_erp,sql_str = sql_bom_precheck)
  ncount = nrow(data)
  if(ncount){
    res <- TRUE
  }else{
    res <- FALSE
  }
  return(res)

}



#' 检查在BOM在中间表中是否存在
#'
#' @param conn_erp ERP链接
#' @param FNumber 产品代码
#' @param FBomNumber 产品BOM
#' @param FVersion_PLM BOM号
#' @param days 最近天数
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_bom_degrade_checkExistsInPLM()
erp_bom_degrade_checkExistsInPLM <- function(conn_erp,
                                             FNumber='2.104.20.00001',
                                             FBomNumber,FVersion_PLM ='A',
                                             days=7){
  BOMRevCode = paste0(FBomNumber,"/",FVersion_PLM)
  sql <- paste0("select  top  1 PLMBatchnum from PLMtoERP_BOM
where PMCode ='",FNumber,"' and BOMRevCode = '",BOMRevCode,"' and CMCode=''
and PLMDate >= DATEADD(DAY,-",days,",cast(GETDATE() as date)) order by FInterId desc")
  data =  tsda::sql_select(conn = conn_erp,sql_str = sql)
  ncount = nrow(data)
  if(ncount){
    res <- TRUE
  }else{
    res <- FALSE
  }
  return(res)


  }

#' 检查在BOM在中间表的状态数据
#'
#' @param conn_erp ERP链接
#' @param FNumber 产品代码
#' @param FBomNumber 产品BOM
#' @param FVersion_PLM BOM号
#' @param days 最近天数
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_bom_degrade_checkExistsInPLM()
erp_bom_degrade_resetStatusInPLM <- function(conn_erp,
                                             FNumber='2.104.20.00001',
                                             FBomNumber,FVersion_PLM ='A',
                                             days=7){
  BOMRevCode = paste0(FBomNumber,"/",FVersion_PLM)
  sql <- paste0("select  top  1 PLMBatchnum from PLMtoERP_BOM
where PMCode ='",FNumber,"' and BOMRevCode = '",BOMRevCode,"' and CMCode=''
and PLMDate >= DATEADD(DAY,-",days,",cast(GETDATE() as date)) order by FInterId desc")
  data =  tsda::sql_select(conn = conn_erp,sql_str = sql)
  ncount = nrow(data)
  if(ncount){
    PLMBatchnum = data$PLMBatchnum
    #进行后续的状态更新处理
    sql_update <- paste0("update a set  a.ERPDate=null,a.ERPOperation = null  from PLMtoERP_BOM a
where PMCode ='",FNumber,"' and BOMRevCode = '",BOMRevCode,"'
and PLMDate >= DATEADD(DAY,-",days,",cast(GETDATE() as date)) and PLMBatchnum='",PLMBatchnum,"'")
    tsda::sql_update(conn = conn_erp,sql_str = sql_update)
    res <- TRUE
  }else{
    res <- FALSE
  }
  return(res)


}
