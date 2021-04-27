use TC4K3DB
go
---处理BOM
insert into ERPtoPLM_BOM


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
           ,[FLowCode])


SELECT [PMCode]
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
      ,[ERPDate],
	  b.FStep as FLowCode

  FROM AIS20140904110155.[dbo].[rds_pdm_bom4TC] a
  inner join AIS20140904110155.dbo.rds_pdm_bomTestStep b
  on a.pmcode =  b.FBomItemNo
order by b.FStep,a.PMCode,a.fbomrowno_k3


select * from ERPtoPLM_BOM
