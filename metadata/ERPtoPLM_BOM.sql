if exists(select * from sys.objects where name ='ERPtoPLM_BOM')
drop table ERPtoPLM_BOM
go
CREATE TABLE [dbo].[ERPtoPLM_BOM](
	[PMCode] [nvarchar](30) NULL,
	[PMName] [nvarchar](80) NULL,
	[BOMRevCode] [nvarchar](30) NULL,
	[CMCode] [nvarchar](30) NULL,
	[CMName] [nvarchar](80) NULL,
	[ProductGroup] [nvarchar](30) NULL,
	[BOMCount] [nvarchar](30) NULL,
	[BOMUOM] [nvarchar](30) NULL,
	[PLMOperation] [nvarchar](30) NULL,
	[ERPOperation] [nvarchar](30) NULL,
	[PLMDate] [datetime] NULL,
	[ERPDate] [datetime] NULL,
	FLowCode int,
	FInterId int identity(1,1)
) ON [PRIMARY]
GO

/*

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
     VALUES
           (<MCode, nvarchar(30),>
           ,<MName, nvarchar(80),>
           ,<Spec, nvarchar(80),>
           ,<MDesc, nvarchar(80),>
           ,<UOM, nvarchar(30),>
           ,<MProp, nvarchar(30),>
           ,<PLMOperation, nvarchar(30),>
           ,<ERPOperation, nvarchar(30),>
           ,<PLMDate, datetime,>
           ,<ERPDate, datetime,>)
GO

GO

SELECT [MCode]
      ,[MName]
      ,[Spec]
      ,[MDesc]
      ,[UOM]
      ,[MProp]
      ,[PLMOperation]
      ,[ERPOperation]
      ,[PLMDate]
      ,[ERPDate]
  FROM [dbo].[ERPtoPLM_Item]
GO

*/
