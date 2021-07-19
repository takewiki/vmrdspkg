#' 物料属性批量修改
#'
#' @param file 文件名
#' @param sheet 页答
#' @param lang 语言
#' @param conn  写入ERP
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_materia_read()
erp_materia_read <-function(file="data-raw/VM物料批量修改模板V2.xlsx",sheet = "物料",lang='cn',conn=conn_vm_erp_test()){
  #library(readxl)
  res <- readxl::read_excel(file,
                    sheet = sheet, col_types = c("text",
                                                "text", "text", "text", "text", "text",
                                                "text", "numeric", "numeric", "text",
                                                "text", "text", "text"))
  ncount <- nrow(res)
  print(res)
  if(ncount >0){
    if(lang == 'en'){
      names(res) <-c('FNumber',
                     'FName',
                     'FModel',
                     'FItemClassName',
                     'FUnitGroupName',
                     'FUnitName',
                     'FDescription',
                     'FFixLeadTime',
                     'FSecInv',
                     'FWgInspecName',
                     'FProdInspecName',
                     'FWwInspecName',
                     'FIsLowValueItem')
      #写入数据库
      res$FUploadDate <- as.character(Sys.Date())
      res$FUseStatus <- 0
      res$FIsDo <-0
      tsda::db_writeTable(conn = conn,table_name = 'rds_item_BatchUpdate_input',r_object = res,append = T)
    }
  }

  return(res)

}



#' 更新物料的状态
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_checkItemUseStatus()
erp_checkItemUseStatus <- function(conn=conn_vm_erp_test()) {
  #更新物料的状态在采购订单的状态，如果还没有处理，状态为0需要进行更新
  sql_po <- "update rds_item_BatchUpdate_db
set FUseStatus =1 where   FItemid
in
(select FItemID from POOrderEntry)
and FUseStatus = 0 and FIsDo =0 "
  tsda::sql_update(conn,sql_po)
  #更新物料在库存类单据中的状态
sql_stk <- paste0("update rds_item_BatchUpdate_db
set FUseStatus =2  where   FItemid
in
(select FItemID from ICStockBillEntry)
and FUseStatus = 0 and FIsDo =0 ")
tsda::sql_update(conn,sql_stk)


}


#' 更新物料状态
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_updateItem_plmMode()
erp_updateItem_plmMode <- function(conn=conn_vm_erp_test()) {


    #不更新PLM信息
    #更新安全库存
    sql_base1 <- paste0("update a set


		 a.FSecInv= b.FSecInv
from t_ICItemBase  a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FItemId
where b.FUseStatus = 0 and FIsDo =0")
    tsda::sql_update(conn,sql_base1)
    #更新提前期
    sql_plan1 <- paste0("update a set

		 a.FFixLeadTime = b.FFixLeadTime

from t_ICItemPlan  a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FItemId
where b.FUseStatus = 0 and FIsDo =0")
    tsda::sql_update(conn,sql_plan1)
    # 更新质检信息
    sql_qc1 <- paste0("update a set
		 a.FInspectionLevel =b.FInspectionLevel,
		 a.FProChkMde = a.FProChkMde,
		 a.FWWChkMde = b.FWWChkMde

from t_ICItemQuality a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FItemId
where b.FUseStatus = 0 and FIsDo =0")
    tsda::sql_update(conn,sql_qc1)
    # 更新低值
    sql_lowValue <- paste0("update a set


		 a.F_128 = b.F_128
from t_ICItemCustom  a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FItemId
where b.FUseStatus = 0 and FIsDo =0")
    tsda::sql_update(conn,sql_lowValue)
    #针对低值再更新相关字段,倒冲，仓库，批次管理等
    sql_lowValue2 <- paste0("update a set


		a.FBatchManager = 0  ,a.FIsBackFlush =1,  a.FDefaultLoc =13149
from t_ICItem   a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FItemId
where  isnull(b.F_128,0) = 1 and   b.FUseStatus = 0 and FIsDo =0")
    tsda::sql_update(conn,sql_lowValue2)



    #更新状态
    sql_do <- paste0("update rds_item_BatchUpdate_db set  fisdo =1 where fisdo =0 ")
    tsda::sql_update(conn,sql_do)




}


#' 更新物料状态
#'
#' @param conn 连接
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_updateItem_erpMode()
erp_updateItem_erpMode <- function(conn=conn_vm_erp_test()) {

    #更新相关信息,更新名称
    sql_item <- paste0("update a set    a.FName = b.fname

from t_Item a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FItemID
where b.FUseStatus = 0 and FIsDo =0
and a.FItemClassID = 4")
    tsda::sql_update(conn,sql_item)
    #更新名称及规格型号
    sql_core <- paste0("update a set    a.FName = b.fname  ,
         a.FModel = b.FModel
from t_ICItemCore a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.fitemID
where b.FUseStatus = 0 and FIsDo =0")
    tsda::sql_update(conn,sql_core)
    # 更新物料属性及计量单位
    sql_base <- paste0("update a set

		 a.FErpClsID  = b.FErpClsID,
		 a.FUnitGroupID = b.FUnitGroupID,
		 a.FUnitID =  b.FUnitID

from t_ICItemBase  a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FItemId
where b.FUseStatus = 0 and FIsDo =0")
    tsda::sql_update(conn,sql_base)
    # 更新description信息
    sql_desc <- paste0("update a set
		 a.F_119 = b.F_119


from t_ICItemCustom  a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FItemId
where b.FUseStatus = 0 and FIsDo =0")
    tsda::sql_update(conn,sql_desc)
    #更新成本对象
    sql_cb1 <- paste0("update a set


		 a.FName = b.FName
from t_Item  a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FCostOjbItemId
where b.FUseStatus = 0 and FIsDo =0
and a.FItemClassID =2001")
    tsda::sql_update(conn,sql_cb1)
    sql_cb2 <- paste0("update a set


		 a.FName = b.FName
from cbCostObj  a
inner join rds_item_BatchUpdate_db b
on a.FItemID = b.FCostOjbItemId
where b.FUseStatus = 0 and FIsDo =0")
    tsda::sql_update(conn,sql_cb2)

    #更新其他PLM没有的字段
    erp_updateItem_plmMode(conn = conn)


}


#' ERP读取PLM传入的物料数据
#'
#' @param conn 连接
#' @param FStartDate 开始日期
#' @param FEndDate 结束日期
#'
#' @return 返回值
#' @export
#'
#' @examples
#' erp_getItemListFromPlm()
erp_getItemListFromPlm <- function(conn=conn_vm_erp_test(),FStartDate='2021-06-01',FEndDate='2021-06-10') {
  #仅对申请状态的物料进行处理
  #APP 打头的物料

sql <- paste0("select MCode as FNumber,MName as FName,Spec as FModel,MProp as FItemClassName,'数量组' as FUnitGroupName,
UOM as FUnitName,MDesc as FDescription,0 as FFixLeadTime,1 as FSecInv,
case MProp when '外购' then '抽检'  else '免检' end  as FWgInspeName,
case MProp when '自制' then '全检'  else '免检' end  as FPropInspecName,
case MProp when '委外加工' then '全检'  else '免检' end  as FWwInspecName,
'否'  as FIsLowValueItem
from PLMtoERP_Item
where ERPDate >='",FStartDate,"'  and ERPDate <='",FEndDate,"'
and PLMBatchnum like 'APP%'  and MCode not in
(select FNumber from rds_item_BatchUpdate_input
)")
res <- tsda::sql_select(conn,sql)
ncount <- nrow(res)
if(ncount >0){
 names(res) <-c('代码',	'名称',	'规格型号',	'物料属性_FName',	'计量单位组_FName',	'基本计量单位_FName',	'Description',
                '固定提前期',	'安全库存数量',	'采购检验方式_FName',	'产品检验方式_FName',	'委外加工检验方式_FName',	'是否为低值易耗'
)
}
return(res)
}







