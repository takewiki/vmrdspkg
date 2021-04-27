USE [TC4K3DB]
GO

INSERT INTO [dbo].[ERPtoPLM_Item]
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


   select * from AIS20140904110155.dbo.rds_md_item4TC_Test
   order by mcode
   go
   select * from ERPtoPLM_Item
