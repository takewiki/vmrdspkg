---Table 1 该表用于PLM向ERP 传输物料信息
--创建表结构
--TC中没有反禁用
--使用物料代码
if exists(select * from sys.objects where name ='PLMtoERP_Item')
drop table PLMtoERP_Item
go
CREATE TABLE [dbo].[PLMtoERP_Item](
	[MCode] [nvarchar](30) NULL,
	[MName] [nvarchar](80) NULL,
	[Spec] [nvarchar](80) NULL,
	[MDesc] [nvarchar](80) NULL,
	[UOM] [nvarchar](30) NULL,
	[MProp] [nvarchar](30) NULL,
	[PLMOperation] [nvarchar](30) NULL,
	[ERPOperation] [nvarchar](30) NULL,
	[PLMDate] [datetime] NULL,
	[ERPDate] [datetime] NULL,
	FInterId int identity(1,1)
) ON [PRIMARY]
GO

select *from PLMtoERP_Item

/*
插入示例

INSERT INTO [dbo].[PLMtoERP_Item]
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

查询
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

  FROM [dbo].[PLMtoERP_Item]
GO

*/




