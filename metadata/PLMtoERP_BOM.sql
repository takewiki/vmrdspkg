if exists(select * from sys.objects where name ='PLMtoERP_BOM')
drop table PLMtoERP_BOM
go
CREATE TABLE [dbo].[PLMtoERP_BOM](
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
	FInterId int identity(1,1)
) ON [PRIMARY]
GO

/*

插入示例
INSERT INTO [dbo].[PLMtoERP_BOM]
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
           ,[ERPDate])
     VALUES
           (<PMCode, nvarchar(30),>
           ,<PMName, nvarchar(80),>
           ,<BOMRevCode, nvarchar(30),>
           ,<CMCode, nvarchar(30),>
           ,<CMName, nvarchar(80),>
           ,<ProductGroup, nvarchar(30),>
           ,<BOMCount, nvarchar(30),>
           ,<BOMUOM, nvarchar(30),>
           ,<PLMOperation, nvarchar(30),>
           ,<ERPOperation, nvarchar(30),>
           ,<PLMDate, datetime,>
           ,<ERPDate, datetime,>)
GO

查询

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
      ,[ERPDate]

  FROM [dbo].[PLMtoERP_BOM]
GO


*/
