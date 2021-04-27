drop table rds_pdm_bomTestSet

select a.*  ,0 as FParentStatus,0 as FSubStatus,1 as FStep   into rds_pdm_bomTestSet from rds_pdm_bomRelation a
where FParentItemNumber ='2.300.05.00001'

--
insert into  TC4K3DB.dbo.ERPtoPLM_BOM


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
           ,[FLowCode],rootcode)
SELECT [PMCode]
      ,[PMName]
      ,[BOMRevCode]
      ,[CMCode]
      ,[CMName]
      ,[ProductGroup]
      ,[BOMCount]
      ,[BOMUOM]
      ,[PLMOperation]
      , 'W' as [ERPOperation]
      ,[PLMDate]
      ,[ERPDate]
	  , 1 as FLowCode,
	  '2.300.05.00001' as rootcode

  FROM [dbo].[rds_pdm_bom4TC]  where PMCode ='2.300.05.00001'
  order by PMCode,CMCode
