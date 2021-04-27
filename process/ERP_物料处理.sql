create view rds_md_item4Bom_Test
as
SELECT [PMCode] as FBomItemNumber



  FROM [rds_pdm_bom4TC] a
  inner join rds_pdm_bomTestStep b
  on a.pmcode =  b.FBomItemNo
union
SELECT
      [CMCode] as FBomItemNumber


  FROM [rds_pdm_bom4TC] a
  inner join rds_pdm_bomTestStep b
  on a.pmcode =  b.FBomItemNo
  go
  select * from rds_md_item4Bom_Test
  go

  create view rds_md_item4TC_Test
  as
  select

   a.FBomItemNumber  [MCode]
      , i.FName  [MName]
      , i.FModel [Spec]
      , i.F_119    [MDesc]
      ,  m.FName   [UOM]
      , ipr.fname   [MProp]
      ,null [PLMOperation]
      ,'R' [ERPOperation]
      ,NULL  [PLMDate]
      ,GETDATE() [ERPDate]

  from rds_md_item4Bom_Test a
  inner join t_ICItem i
  on a.FBomItemNumber = i.FNumber
  inner join t_MeasureUnit m
  on i.FUnitID = m.FMeasureUnitID
  inner join rds_md_itemProp ipr
  on i.FErpClsID = ipr.finterid
  go

  alter  view rds_md_item4TC_Test
as
select

   i.FNumber  [MCode]
      , i.FName  [MName]
      , i.FModel [Spec]
      , i.F_119    [MDesc]
      ,  m.FName   [UOM]
      , ipr.fname   [MProp]
      ,null [PLMOperation]
      ,'W' [ERPOperation]
      ,NULL  [PLMDate]
      ,GETDATE() [ERPDate]

  from t_ICItem i

  inner join t_MeasureUnit m
  on i.FUnitID = m.FMeasureUnitID
  inner join rds_md_itemProp ipr
  on i.FErpClsID = ipr.finterid
  where
  (i.FNumber like '1.%'  or i.FNumber like '2.%'  or i.FNumber like '3.%'  or i.FNumber like '4.%'  or i.FNumber like '6.%'  )
  go

  select * from rds_md_item4TC_Test




---修改视图的定义
alter  view rds_md_item4TC_Test
as
select

   i.FNumber  [MCode]
      , i.FName  [MName]
      , i.FModel [Spec]
      , i.F_119    [MDesc]
      ,  m.FName   [UOM]
      , ipr.fname   [MProp]
      ,null [PLMOperation]
      ,'W' [ERPOperation]
      ,NULL  [PLMDate]
      ,GETDATE() [ERPDate]

  from t_ICItem i

  inner join t_MeasureUnit m
  on i.FUnitID = m.FMeasureUnitID
  inner join rds_md_itemProp ipr
  on i.FErpClsID = ipr.finterid
  where
  (i.FNumber like '1.%'  or i.FNumber like '2.%'  or i.FNumber like '3.%'  or i.FNumber like '4.%'  or i.FNumber like '6.%'  )
  go



  ----修改标识
  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [PMCode]
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
      ,[FInterId]
  FROM [TC4K3DB].[dbo].[ERPtoPLM_BOM]

 update ERPtoPLM_BOM set  ERPOperation = 'W'

