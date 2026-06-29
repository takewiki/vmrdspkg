----使用ERP数据库
use AIS20140904110155
go
---1.1创建PLMtoERP_Item物料表
---初始化时使用，会删除所有数据
if exists(select * from sys.objects where  name ='PLMtoERP_Item')
   drop table PLMtoERP_Item
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
	[FInterId] [int]  NOT NULL,
	[PLMBatchnum] [nvarchar](50) NULL
) ON [PRIMARY]
GO
---1.2数据同步日志步
if exists(select * from sys.objects where  name ='rds_dataSync_log')
   drop table rds_dataSync_log
CREATE TABLE [dbo].[rds_dataSync_log](
	FDateFrom datetime,
	FTableName varchar(30),
	FCount int,
	FStatus_PLM int,
	FStatus_ERP int
) ON [PRIMARY]
GO


----select * from rds_dataSync_log
---2.1BOM同步结构 ----
if exists(select * from sys.objects where  name ='PLMtoERP_BOM')
   drop table PLMtoERP_BOM
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
	[FInterId] [int]  NOT NULL,
	[RootCode] [nvarchar](80) NULL,
	[FLowCode] [nvarchar](50) NULL,
	[PLMBatchnum] [nvarchar](50) NULL
) ON [PRIMARY]
GO

select * from PLMtoERP_BOM
select max(PLMDate) as   PLMDate  from  PLMtoERP_BOM

---2.2定义BOM版本号
if exists(select * from sys.objects where  name ='rds_BOM_version')
   drop table rds_BOM_version 
create table rds_BOM_version 
(FVersion_PLM varchar(30),FVersion_ERP varchar(30))
----2.2A插入版本数据
insert into rds_BOM_version values('A','001')
insert into rds_BOM_version values('B','002')
insert into rds_BOM_version values('C','003')
insert into rds_BOM_version values('D','004')
insert into rds_BOM_version values('E','005')
insert into rds_BOM_version values('F','006')
insert into rds_BOM_version values('G','007')
insert into rds_BOM_version values('H','008')
insert into rds_BOM_version values('I','009')
insert into rds_BOM_version values('J','010')
insert into rds_BOM_version values('K','011')
insert into rds_BOM_version values('L','012')
insert into rds_BOM_version values('M','013')
insert into rds_BOM_version values('N','014')
insert into rds_BOM_version values('O','015')
insert into rds_BOM_version values('P','016')
insert into rds_BOM_version values('Q','017')
insert into rds_BOM_version values('R','018')
insert into rds_BOM_version values('S','019')
insert into rds_BOM_version values('T','020')
insert into rds_BOM_version values('U','021')
insert into rds_BOM_version values('V','022')
insert into rds_BOM_version values('W','023')
insert into rds_BOM_version values('X','024')
insert into rds_BOM_version values('Y','025')
insert into rds_BOM_version values('Z','026')
-----2.3定义BOM组为999未分配，提醒Jean处理。

---3 处理ERP向PLM传入BOM
---3.0 基础表
if exists(select * from sys.objects where  name ='rds_md_itemProp')
   drop table rds_md_itemProp 
create table rds_md_itemProp 
(FInterId int,FName varchar(30))
insert into rds_md_itemProp values(1,'外购')
insert into rds_md_itemProp values(2,'自制')
insert into rds_md_itemProp values(3,'委外加工')
insert into rds_md_itemProp values(7,'配置类')


----3.1 定义BOM关系视图
if exists(select * from sys.objects where  name ='rds_pdm_bomRelation')
   drop view rds_pdm_bomRelation 
go
create view rds_pdm_bomRelation 
as select  FParentItemnumber,FParentItemProp,FSubItemNumber,FSubItemProp 
from rds_pdm_bomAll where  FSubItemProp <> '外购' 
go
---3.2定义表结构
if exists(select * from sys.objects where  name ='rds_pdm_bomTestSet')
   drop table rds_pdm_bomTestSet
CREATE TABLE [dbo].[rds_pdm_bomTestSet](
	[FParentItemnumber] [varchar](80) NULL,
	[FParentItemProp] [varchar](30) NULL,
	[FSubItemNumber] [varchar](80) NULL,
	[FSubItemProp] [varchar](30) NULL,
	[FParentStatus] [int] NOT NULL,
	[FSubStatus] [int] NOT NULL,
	[FStep] [int] NOT NULL,
	rootcode varchar(80)
) ON [PRIMARY]
GO
--3.3 定义数据 处理视图
if exists(select * from sys.objects where  name ='rds_pdm_bomTestStep')
   drop view rds_pdm_bomTestStep
go
create view rds_pdm_bomTestStep
as
select fparentitemnumber as FBomItemNo ,FStep,rootcode from rds_pdm_bomTestSet
union
select fsubItemNumber as FBomItemNo,FStep+1 as FStep,rootcode from rds_pdm_bomTestSet
go
--3.4 定义视图
if exists(select * from sys.objects where  name ='rds_pdm_bomHead')
   drop view rds_pdm_bomHead 
go
create  view  rds_pdm_bomHead 
as select a.FInterID as FBomInterId, i.FNumber as FParentItemNumber, 
i.FName as FParentItemName, i.FModel as FParentItemModel, i.F_119 as FParentItemDescription ,
FBOMNumber,a.FVersion as FBOMVerNo, FBOMNumber+'/A' as FTCBomNumber , 
bg.FName as FBomGroupName, im.FName  as FParentItemProp, FUseStatus  
from ICBOM a 
left join ICBOMGroup bg on a.FParentID = bg.FInterID 
left join t_ICItem i on a.FItemID = i.FItemID 
left join rds_md_itemProp  im on i.FErpClsID = im.FInterId where  FUseStatus = 1072   
go

if exists(select * from sys.objects where  name ='rds_pdm_bomAll')
   drop view rds_pdm_bomAll
go
create  view  rds_pdm_bomAll as 
select      bh.[FBomInterId], FEntryID as FBomRowNo        ,
bh.[FParentItemNumber]       ,bh.[FParentItemName]       ,bh.[FParentItemModel]       ,
bh.[FParentItemDescription]       ,bh.[FBOMNumber]       ,bh.[FBOMVerNo]    
   ,bh.[FTCBomNumber]       ,bh.[FBomGroupName]       ,bh.[FParentItemProp]       ,
   bh.[FUseStatus],  i.FNumber as FSubItemNumber,i.FName as FSubItemName, 
   i.FModel as FSubItemModel, i.f_119 as FSubItemDescription, ipr.FName as FSubItemProp, 
   FQty,m.FName as
 FSubItemUnitName 
 from ICBOMChild ic 
 inner  join t_ICItem i on ic.FItemID = i.FItemID 
 left join t_MeasureUnit m on ic.FUnitID = m.FMeasureUnitID 
 inner join rds_pdm_bomHead bh on ic.FInterID = bh.FBomInterId 
 left join rds_md_itemProp ipr on i.FErpClsID = ipr.FInterId  
go

--3.5 定义处理好的视图
if exists(select * from sys.objects where  name ='rds_pdm_bom4TC')
   drop view rds_pdm_bom4TC
go
create  view rds_pdm_bom4TC AS  
SELECT FParentItemNumber [PMCode]  
      ,FParentItemName  [PMName]  
      ,FTCBomNumber  [BOMRevCode]  
      ,FSubItemNumber [CMCode]  
      , FSubItemName [CMName]  
      ,FBomGroupName [ProductGroup]  
      ,FQTY [BOMCount]  
      ,FSubItemUnitName [BOMUOM]  
      ,null  as [PLMOperation]  
      ,'R' as [ERPOperation]  
      ,NULL as  [PLMDate]  
      ,getdate() [ERPDate],  
   FBomNumber as FBomNo_K3,  
   FBomRowNO as FBomRowNo_k3,  
   FBomInterID as FBomInterId_k3  
        
  FROM rds_pdm_bomAll 
 go

 ---4.0 处理ERP BOM 数据
 if exists(select * from sys.objects where  name ='vw_PLMtoERP_BOM')
   drop view vw_PLMtoERP_BOM
go
 CREATE  view vw_PLMtoERP_BOM as  
select a.*,i_pm.FItemID as FParentItemId, i_pm.FUnitID as FParentUnitID,  
     i_sub.FItemID as FSubItemId,i_sub.FUnitID as FSubUnitId,ig.FInterID as FProductGroupId  
  
from  [PLMtoERP_BOM] a  
left  join t_ICItem i_pm   
on  a.PMCode collate chinese_prc_ci_as  =  i_pm.FNumber  
left  join t_ICItem i_sub  
on  a.CMCode  collate chinese_prc_ci_as  = i_sub.FNumber  
left join ICBOMGroup ig  
on a.ProductGroup collate chinese_prc_ci_as = ig.FNumber  
where ((PLMBatchnum not like 'APP%' and BOMRevCode not like 'BOM%') or (BOMRevCode  like 'BOM%' and PLMBatchnum like 'ECN%' ) )
and ERPDate is null 
go
----4.1创建BOM表体模板
 if exists(select * from sys.objects where  name ='rds_icbom_tpl_body')
   drop table rds_icbom_tpl_body

CREATE TABLE [dbo].[rds_icbom_tpl_body](
	[FInterID] [int] NOT NULL,
	[FEntryID] [int] NOT NULL,
	[FBrNo] [varchar](10) NOT NULL,
	[FItemID] [int] NOT NULL,
	[FAuxPropID] [int] NOT NULL,
	[FUnitID] [int] NOT NULL,
	[FMaterielType] [int] NOT NULL,
	[FMarshalType] [int] NOT NULL,
	[FQty] [decimal](28, 10) NOT NULL,
	[FAuxQty] [decimal](28, 10) NOT NULL,
	[FBeginDay] [datetime] NOT NULL,
	[FEndDay] [datetime] NOT NULL,
	[FPercent] [decimal](28, 10) NOT NULL,
	[FScrap] [decimal](28, 10) NOT NULL,
	[FPositionNo] [nvarchar](4000) NOT NULL,
	[FItemSize] [nvarchar](255) NOT NULL,
	[FItemSuite] [nvarchar](255) NOT NULL,
	[FOperSN] [int] NOT NULL,
	[FOperID] [int] NOT NULL,
	[FMachinePos] [varchar](1000) NULL,
	[FOffSetDay] [decimal](28, 10) NOT NULL,
	[FBackFlush] [int] NOT NULL,
	[FStockID] [int] NULL,
	[FSPID] [int] NOT NULL,
	[FNote] [varchar](1000) NULL,
	[FNote1] [nvarchar](255) NOT NULL,
	[FNote2] [nvarchar](255) NOT NULL,
	[FNote3] [nvarchar](255) NOT NULL,
	[FPDMImportDate] [datetime] NULL,
	[FDetailID] [uniqueidentifier] NOT NULL,
	[FCostPercentage] [decimal](6, 2) NULL,
	[FEntrySelfZ0142] [varchar](255) NULL,
	[FEntrySelfZ0144] [int] NULL,
	[FEntrySelfZ0145] [int] NULL,
	[FEntrySelfZ0146] [int] NULL,
	[FEntrySelfZ0148] [int] NULL
) ON [PRIMARY]
GO

---4.2创建BOM表头模板表
 if exists(select * from sys.objects where  name ='rds_icbom_tpl_head')
   drop table rds_icbom_tpl_head
CREATE TABLE [dbo].[rds_icbom_tpl_head](
	[FInterID] [int] NOT NULL,
	[FBomNumber] [varchar](300) NOT NULL,
	[FBrNo] [varchar](10) NOT NULL,
	[FTranType] [int] NOT NULL,
	[FCancellation] [bit] NOT NULL,
	[FStatus] [smallint] NOT NULL,
	[FVersion] [varchar](300) NOT NULL,
	[FUseStatus] [int] NULL,
	[FItemID] [int] NOT NULL,
	[FUnitID] [int] NOT NULL,
	[FAuxPropID] [int] NOT NULL,
	[FAuxQty] [decimal](28, 10) NOT NULL,
	[FYield] [decimal](28, 10) NULL,
	[FNote] [varchar](300) NOT NULL,
	[FCheckID] [int] NULL,
	[FCheckDate] [datetime] NULL,
	[FOperatorID] [int] NULL,
	[FEntertime] [datetime] NOT NULL,
	[FRoutingID] [int] NOT NULL,
	[FBomType] [int] NOT NULL,
	[FCustID] [int] NOT NULL,
	[FParentID] [int] NULL,
	[FAudDate] [datetime] NULL,
	[FImpMode] [smallint] NOT NULL,
	[FPDMImportDate] [datetime] NULL,
	[FBOMSkip] [smallint] NOT NULL,
	[FUseDate] [datetime] NULL,
	[FHeadSelfZ0135] [varchar](255) NULL,
	[FPrintCount] [int] NOT NULL
) ON [PRIMARY]
GO
---4.3Abom表头输入表
if exists(select * from sys.objects where  name ='rds_icbom_input')
   drop table rds_icbom_input
CREATE TABLE [dbo].[rds_icbom_input](
	[FInterID] [int] NOT NULL,
	[FBomNumber] [varchar](300) NOT NULL,
	[FBrNo] [varchar](10) NOT NULL,
	[FTranType] [int] NOT NULL,
	[FCancellation] [bit] NOT NULL,
	[FStatus] [smallint] NOT NULL,
	[FVersion] [varchar](300) NOT NULL,
	[FUseStatus] [int] NULL,
	[FItemID] [int] NOT NULL,
	[FUnitID] [int] NOT NULL,
	[FAuxPropID] [int] NOT NULL,
	[FAuxQty] [decimal](28, 10) NOT NULL,
	[FYield] [decimal](28, 10) NULL,
	[FNote] [varchar](300) NOT NULL,
	[FCheckID] [int] NULL,
	[FCheckDate] [datetime] NULL,
	[FOperatorID] [int] NULL,
	[FEntertime] [datetime] NOT NULL,
	[FRoutingID] [int] NOT NULL,
	[FBomType] [int] NOT NULL,
	[FCustID] [int] NOT NULL,
	[FParentID] [int] NULL,
	[FAudDate] [datetime] NULL,
	[FImpMode] [smallint] NOT NULL,
	[FPDMImportDate] [datetime] NULL,
	[FBOMSkip] [smallint] NOT NULL,
	[FUseDate] [datetime] NULL,
	[FHeadSelfZ0135] [varchar](255) NULL,
	[FPrintCount] [int] NOT NULL
) ON [PRIMARY]
GO
----4.3B BOM表体输入表
if exists(select * from sys.objects where  name ='rds_icbomChild_input')
   drop table rds_icbomChild_input
CREATE TABLE [dbo].[rds_icbomChild_input](
	[FInterID] [int] NOT NULL,
	[FEntryID] [int] NOT NULL,
	[FBrNo] [varchar](10) NOT NULL,
	[FItemID] [int] NOT NULL,
	[FAuxPropID] [int] NOT NULL,
	[FUnitID] [int] NOT NULL,
	[FMaterielType] [int] NOT NULL,
	[FMarshalType] [int] NOT NULL,
	[FQty] [decimal](28, 10) NOT NULL,
	[FAuxQty] [decimal](28, 10) NOT NULL,
	[FBeginDay] [datetime] NOT NULL,
	[FEndDay] [datetime] NOT NULL,
	[FPercent] [decimal](28, 10) NOT NULL,
	[FScrap] [decimal](28, 10) NOT NULL,
	[FPositionNo] [nvarchar](4000) NOT NULL,
	[FItemSize] [nvarchar](255) NOT NULL,
	[FItemSuite] [nvarchar](255) NOT NULL,
	[FOperSN] [int] NOT NULL,
	[FOperID] [int] NOT NULL,
	[FMachinePos] [varchar](1000) NULL,
	[FOffSetDay] [decimal](28, 10) NOT NULL,
	[FBackFlush] [int] NOT NULL,
	[FStockID] [int] NULL,
	[FSPID] [int] NOT NULL,
	[FNote] [varchar](1000) NULL,
	[FNote1] [nvarchar](255) NOT NULL,
	[FNote2] [nvarchar](255) NOT NULL,
	[FNote3] [nvarchar](255) NOT NULL,
	[FPDMImportDate] [datetime] NULL,
	[FDetailID] [uniqueidentifier] NOT NULL,
	[FCostPercentage] [decimal](6, 2) NULL,
	[FEntrySelfZ0142] [varchar](255) NULL,
	[FEntrySelfZ0144] [int] NULL,
	[FEntrySelfZ0145] [int] NULL,
	[FEntrySelfZ0146] [int] NULL,
	[FEntrySelfZ0148] [int] NULL
) ON [PRIMARY]
GO


---处理日常物料
 if exists(select * from sys.objects where  name ='vw_PLMtoERP_Item')
   drop view vw_PLMtoERP_Item
go
create view vw_PLMtoERP_Item
as
select MCode,MProp,PLMBatchnum from PLMtoERP_Item
where ERPDate is null 
go

---创建物料预分配表
if exists(select * from sys.objects where  name ='t_Item_rds')
   drop table t_Item_rds
CREATE TABLE [dbo].[t_Item_rds](
	[FItemID] [int] NOT NULL,
	[FItemClassID] [int] NOT NULL,
	[FExternID] [int] NOT NULL,
	[FNumber] [varchar](80) NOT NULL,
	[FParentID] [int] NOT NULL,
	[FLevel] [smallint] NOT NULL,
	[FDetail] [bit] NOT NULL,
	[FName] [varchar](255) NOT NULL,
	[FUnUsed] [bit] NULL,
	[FBrNo] [varchar](10) NOT NULL,
	[FFullNumber] [varchar](80) NOT NULL,
	[FDiff] [bit] NOT NULL,
	[FDeleted] [smallint] NOT NULL,
	[FShortNumber] [varchar](80) NULL,
	[FFullName] [varchar](255) NULL,
	[UUID] [uniqueidentifier] NOT NULL,
	[FGRCommonID] [int] NOT NULL,
	[FSystemType] [int] NOT NULL,
	[FUseSign] [int] NOT NULL,
	[FChkUserID] [int] NULL,
	[FAccessory] [smallint] NOT NULL,
	[FGrControl] [int] NOT NULL,
	[FModifyTime] [timestamp] NOT NULL,
	[FHavePicture] [smallint] NOT NULL
	)
	go
----创建备份数据表
	if exists(select * from sys.objects where  name ='t_Item_rdsBak')
   drop table t_Item_rdsBak
CREATE TABLE [dbo].[t_Item_rdsBak](
	[FItemID] [int] NOT NULL,
	[FItemClassID] [int] NOT NULL,
	[FExternID] [int] NOT NULL,
	[FNumber] [varchar](80) NOT NULL,
	[FParentID] [int] NOT NULL,
	[FLevel] [smallint] NOT NULL,
	[FDetail] [bit] NOT NULL,
	[FName] [varchar](255) NOT NULL,
	[FUnUsed] [bit] NULL,
	[FBrNo] [varchar](10) NOT NULL,
	[FFullNumber] [varchar](80) NOT NULL,
	[FDiff] [bit] NOT NULL,
	[FDeleted] [smallint] NOT NULL,
	[FShortNumber] [varchar](80) NULL,
	[FFullName] [varchar](255) NULL,
	[UUID] [uniqueidentifier] NOT NULL,
	[FGRCommonID] [int] NOT NULL,
	[FSystemType] [int] NOT NULL,
	[FUseSign] [int] NOT NULL,
	[FChkUserID] [int] NULL,
	[FAccessory] [smallint] NOT NULL,
	[FGrControl] [int] NOT NULL,
	[FModifyTime] [timestamp] NOT NULL,
	[FHavePicture] [smallint] NOT NULL
	)
	go

	----创建物料分配规则表
	if exists(select * from sys.objects where  name ='t_item_rdsRoom')
   drop table t_item_rdsRoom
	Create table t_item_rdsRoom   (
		[FItemClassID] [int] NOT NULL,
			[FItemID] [int] NOT NULL,

	[FNumber] [varchar](80) NOT NULL,
	[FName] [varchar](255) NOT NULL,
	FPropType varchar(30) Not Null,
	[FNumber_New] [varchar](80)  default('')  NOT NULL,
	FFlag int default(0))
	go
  ----创建物料分配后的缓存表
if exists(select * from sys.objects where  name ='t_item_rdsInput')
   drop table t_item_rdsInput
	Create table t_item_rdsInput  (
  [MCode] [nvarchar](30) NULL,
	[MName] [nvarchar](80) NULL,
	[Spec] [nvarchar](80) NULL,
	[MDesc] [nvarchar](80) NULL,
	[UOM] [nvarchar](30) NULL,
	[MProp] [nvarchar](30) NULL,
	FNumber varchar(80) not null,
	[FBatchNum] [varchar](50) NULL,
	FIsDo int default(0),
	FItemId int default(0),
	FParentNumber varchar(30)

		)

go












