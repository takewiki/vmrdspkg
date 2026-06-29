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
      ,[RootCode]
  FROM [TC4K3DB].[dbo].[ERPtoPLM_BOM]
  where PLMOperation is null



delete
  FROM [TC4K3DB].[dbo].[ERPtoPLM_BOM]
  where PLMOperation is null


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
      ,[RootCode]
  FROM [TC4K3DB].[dbo].[ERPtoPLM_BOM]


update ERPtoPLM_BOM set rootCode ='1.219.01.00003'
