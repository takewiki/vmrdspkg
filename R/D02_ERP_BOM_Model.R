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
#' generate the sql for bom initial
#'
#' @param conn connection
#' @param FNumber  the item number
#' @param FStep   step from 1 ,2 ...
#'
#' @return return value
#' @export
#'
#' @examples
#' bom_level_sql_ERP2PLM()
bom_level_sql_ERP2PLM<- function(conn=conn_vm_erp_test2(),FNumber='1.218.03.00002',FStep =1 ) {

  if ( FStep == 1){
  sql <- paste0("select a.*  ,0 as FParentStatus,0 as FSubStatus,1 as FStep  , '",FNumber,"' as rootcode , 0 as FStatus from rds_pdm_bomRelation a
where FParentItemNumber ='",FNumber,"'")

}else{
  sql <- paste0("select a.*  ,0 as FParentStatus,0 as FSubStatus,  ",  FStep   ,"   as FStep ,'",FNumber,"' as rootcode, 0 as FStatus    from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FStep = ",FStep - 1,"  and FStatus = 0)")

}
  return(sql)
}







#' initial bom to check level 1 have data and return true or
#'
#' @param conn connection
#' @param FNumber item number
#'
#' @return return true or false
#' @export
#'
#' @examples
#' bom_level1_haveValue_ERP2PLM()
bom_is_haveValue_ERP2PLM<- function(conn=conn_vm_erp_test2(),FNumber='1.218.03.00002',FStep =1) {
  # get the sql
  sql <-  bom_level_sql_ERP2PLM(conn = conn,FNumber = FNumber,FStep = FStep)
  r <- tsda::sql_select(conn,sql)
  ncount <- nrow(r)
  if(ncount > 0){
    res <- TRUE
  }else{
    res <- FALSE
  }
  return(res)
}


#' insert into value
#'
#' @param conn conn
#' @param FNumber  item number
#' @param FStep step count
#'
#' @return not value
#' @export
#'
#' @examples
#' bom_is_insertValue_ERP2PLM()
bom_insertValue_ERP2PLM<- function(conn=conn_vm_erp_test2(),FNumber='1.218.03.00002',FStep =1) {
  prefix = "insert into rds_pdm_bomTestSet   "
  ##print(prefix)
  ##print(FStep)
  sql <-  bom_level_sql_ERP2PLM(conn = conn,FNumber = FNumber,FStep = FStep)
  sql_ins = paste0(prefix," ",sql)
  ##print(sql_ins)
   try({
     tsda::sql_update(conn,sql_ins)
   })
}



#' update the data value
#'
#' @param conn_erp conn1
#' @param conn_plm conn2
#' @param FNumber item number
#'
#' @return return value
#' @export
#'
#' @examples
#' bom_selectValue_ERP2PLM()
bom_selectValue_ERP2PLM<- function(conn_erp=conn_vm_erp_test2(),conn_plm=conn_vm_plm_prd(),FNumber='1.218.03.00002') {

  sql <-  paste0("SELECT [PMCode]
      ,[PMName]
      ,[BOMRevCode]
      ,[CMCode]
      ,[CMName]
      ,[ProductGroup]
      ,[BOMCount]
      ,[BOMUOM]
      ,[PLMOperation]
      ,'W' as [ERPOperation]
      ,[PLMDate]
      ,[ERPDate]
	  ,b.FStep [FLowCode]
	  ,b.rootcode

  FROM [dbo].[rds_pdm_bom4TC] a
  inner join rds_pdm_bomTestStep b
  on a.pmcode =  b.FBomItemNo
  where rootcode ='",FNumber,"' and b.fstatus = 0
order by b.FStep,a.PMCode,a.CMCode ")
  r <- tsda::sql_select(conn_erp,sql)

  r$PLMDate <-  as.character(r$PLMDate)
  r$PLMOperation <- as.character(r$PLMOperation)
  ##print(str(r))
  ##print(r)
  openxlsx::write.xlsx(x = r,file = 'bom_test.xlsx')
  ncount =nrow(r)
  if (ncount >0){
    #本地写入结果
    ##print('C1')
     lapply(1:ncount, function(i){
      # #print(r[i, ])
       tsda::db_writeTable(conn = conn_erp,table_name = 'ERPtoPLM_BOM',r_object = r[i, ],append = T)

     })



    #写入PLM数据库
    # #print('C2')
    tsda::db_writeTable(conn = conn_plm,table_name = 'ERPtoPLM_BOM_Input',r_object = r,append = T)
    ##print('C3')
    sql_ins <- paste0("INSERT INTO [dbo].[ERPtoPLM_BOM]
           ([PMCode]
           ,[PMName]
           ,[BOMRevCode]
           ,[CMCode]
           ,[CMName]
           ,[ProductGroup]
           ,[BOMCount]
           ,[BOMUOM]
           ,[PLMOperation]
           ,[ERPOperation]
           ,[PLMDate]
           ,[ERPDate]
           ,[FLowCode]
           ,[RootCode])
           select * from ERPtoPLM_BOM_Input ")
    tsda::sql_update(conn = conn_plm,sql_str = sql_ins)
    ##print('C4')
    sql_truncate <- paste0(" truncate table  ERPtoPLM_BOM_Input ")
    tsda::sql_update(conn = conn_plm,sql_str = sql_truncate)



    # lapply(1:ncount, function(i){
    #   sql_ins <- paste0("INSERT INTO [dbo].[ERPtoPLM_BOM]
    #        ([PMCode]
    #        ,[PMName]
    #        ,[BOMRevCode]
    #        ,[CMCode]
    #        ,[CMName]
    #        ,[ProductGroup]
    #        ,[BOMCount]
    #        ,[BOMUOM]
    #        ,[PLMOperation]
    #        ,[ERPOperation]
    #        ,[PLMDate]
    #        ,[ERPDate]
    #        ,[FLowCode]
    #        ,[RootCode])
    #  VALUES
    #        ('",r$PMCode[i],"'
    #        ,N'",r$PMName[i],"'
    #        ,N'",r$BOMRevCode[i],"'
    #        ,N'",r$CMCode[i],"'
    #        ,N'",r$CMName[i],"'
    #        ,N'",r$ProductGroup[i],"'
    #        ,'",r$BOMCount[i],"'
    #        ,N'",r$BOMUOM[i],"'
    #        ,NULL
    #        ,'",r$ERPOperation[i],"'
    #        ,NULL
    #        ,'",r$ERPDate[i],"'
    #        ,",r$FLowCode[i],"
    #        ,'",r$rootcode[i],"' )")
    #
    #   cat(sql_ins)
    #
    #   tsda::sql_update(conn = conn_plm,sql_str = sql_ins)
    # })

  }

  return(r)



}


#' update the data value
#'
#' @param conn_erp conn1
#' @param conn_plm conn2
#' @param FNumber item number
#'
#' @return return value
#' @export
#'
#' @examples
#' bom_selectValue_ERP2PLM_wg()
bom_selectValue_ERP2PLM_wg<- function(conn_erp=conn_vm_erp_test2(),conn_plm=conn_vm_plm_prd(),FNumber='1.218.03.00002') {

  sql <-  paste0("SELECT [PMCode]
      ,[PMName]
      ,[BOMRevCode]
      ,[CMCode]
      ,[CMName]
      ,[ProductGroup]
      ,[BOMCount]
      ,[BOMUOM]
      ,[PLMOperation]
      ,[ERPOperation]
      ,[PLMDate]
      ,[ERPDate]
      ,1 as [FLowCode]
      ,'",FNumber,"' as [RootCode]
  FROM [dbo].[rds_pdm_bom4TC]
where PMCode ='",FNumber,"'")
  r <- tsda::sql_select(conn_erp,sql)
  r$ERPOperation <- 'W'
  r$ERPDate <- as.character(Sys.time())
  r$PLMDate <-  as.character(r$PLMDate)
  r$PLMOperation <- as.character(r$PLMOperation)
  ##print(str(r))
  ncount =nrow(r)
  if (ncount >0){
    #本地写入结果

    tsda::db_writeTable(conn = conn_erp,table_name = 'ERPtoPLM_BOM',r_object = r,append = T)

    #写入PLM数据库
    tsda::db_writeTable(conn = conn_plm,table_name = 'ERPtoPLM_BOM_Input',r_object = r,append = T)
    sql_ins <- paste0("INSERT INTO [dbo].[ERPtoPLM_BOM]
           ([PMCode]
           ,[PMName]
           ,[BOMRevCode]
           ,[CMCode]
           ,[CMName]
           ,[ProductGroup]
           ,[BOMCount]
           ,[BOMUOM]
           ,[PLMOperation]
           ,[ERPOperation]
           ,[PLMDate]
           ,[ERPDate]
           ,[FLowCode]
           ,[RootCode])
           select * from ERPtoPLM_BOM_Input ")
    tsda::sql_update(conn = conn_plm,sql_str = sql_ins)
    sql_truncate <- paste0(" truncate table  ERPtoPLM_BOM_Input ")
    tsda::sql_update(conn = conn_plm,sql_str = sql_truncate)



    # lapply(1:ncount, function(i){
    #   sql_ins <- paste0("INSERT INTO [dbo].[ERPtoPLM_BOM]
    #        ([PMCode]
    #        ,[PMName]
    #        ,[BOMRevCode]
    #        ,[CMCode]
    #        ,[CMName]
    #        ,[ProductGroup]
    #        ,[BOMCount]
    #        ,[BOMUOM]
    #        ,[PLMOperation]
    #        ,[ERPOperation]
    #        ,[PLMDate]
    #        ,[ERPDate]
    #        ,[FLowCode]
    #        ,[RootCode])
    #  VALUES
    #        ('",r$PMCode[i],"'
    #        ,N'",r$PMName[i],"'
    #        ,N'",r$BOMRevCode[i],"'
    #        ,N'",r$CMCode[i],"'
    #        ,N'",r$CMName[i],"'
    #        ,N'",r$ProductGroup[i],"'
    #        ,'",r$BOMCount[i],"'
    #        ,N'",r$BOMUOM[i],"'
    #        ,NULL
    #        ,'",r$ERPOperation[i],"'
    #        ,NULL
    #        ,'",r$ERPDate[i],"'
    #        ,",r$FLowCode[i],"
    #        ,'",r$rootcode[i],"' )")
    #
    #   cat(sql_ins)
    #
    #   tsda::sql_update(conn = conn_plm,sql_str = sql_ins)
    # })

  }

  return(r)



}



#' update the status
#'
#' @param conn conn
#' @param FNumber  the item number
#'
#' @return retur value
#' @export
#'
#' @examples
#' bom_updateStatus_ERP2PLM()
bom_updateStatus_ERP2PLM<- function(conn=conn_vm_erp_test2(),FNumber='1.218.03.00002') {
  sql <- paste0("update a  set a.fstatus =1 from  rds_pdm_bomTestSet  a where rootcode ='",FNumber,"' and fstatus =0")


  try({
    tsda::sql_update(conn,sql)
  })
}




#' deal with bom initial one
#'
#' @param conn_erp  conn1
#' @param conn_plm conn2
#' @param FNumber item number
#'
#' @return return value
#' @export
#'
#' @examples
#' ERPtoPLM_BOM_one()
ERPtoPLM_BOM_one<- function(conn_erp=conn_vm_erp_test2(),conn_plm=conn_vm_plm_prd(),FNumber='1.218.03.00002'){
  FStep = 1
  flag<- bom_is_haveValue_ERP2PLM(conn=conn_erp,FNumber = FNumber,FStep = FStep)
  ##print('step')
  ##print(FStep)
  ##print(flag)
  if(flag){
    #可以展开
    while(flag){
      ##print('PART-A')
      bom_insertValue_ERP2PLM(conn = conn_erp,FNumber = FNumber,FStep = FStep)
      FStep = FStep + 1
      ##print('PART-B')
      flag<- bom_is_haveValue_ERP2PLM(conn=conn_erp,FNumber = FNumber,FStep = FStep)
      ##print('step')
      ##print(FStep)
    }
    ##print('finished all the step')
    ##print('PART-C')
    res <- bom_selectValue_ERP2PLM(conn_erp = conn_erp,conn_plm = conn_plm,FNumber = FNumber)
    ##print('PART-D')
    bom_updateStatus_ERP2PLM(conn=conn_erp,FNumber = FNumber)
    ##print('PART-E')
  }else{
    #全部为外购物料
    res <-bom_selectValue_ERP2PLM_wg(conn_erp = conn_erp,conn_plm = conn_plm,FNumber = FNumber)
  }


  return(res)


}



#' deal with bom initial one
#'
#' @param conn_erp  conn1
#' @param conn_plm conn2
#' @param FNumber item number
#'
#' @return return value
#' @export
#'
#' @examples
#' ERPtoPLM_BOM_one()
ERPtoPLM_BOM_ALL<- function(conn_erp=conn_vm_erp_test2(),conn_plm=conn_vm_plm_prd(),FNumbers='1.218.03.00002'){

   res <- lapply(FNumbers, function(FNumber){
     ERPtoPLM_BOM_one(conn_erp = conn_erp,conn_plm = conn_plm,FNumber = FNumber)
   })
   return(res)

}


