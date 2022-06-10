
--增加基础 表
create table rds_md_itemProp (FInterId int,FName varchar(30))
insert into rds_md_itemProp values(1,'外购')
insert into rds_md_itemProp values(2,'自制')
insert into rds_md_itemProp values(3,'委外加工')
insert into rds_md_itemProp values(7,'配置类')
go
select * from rds_md_itemProp
go




--BOM表头处理
create  view  rds_pdm_bomHead
as
select a.FInterID as FBomInterId, i.FNumber as FParentItemNumber,
i.FName as FParentItemName,
i.FModel as FParentItemModel,
i.F_119 as FParentItemDescription
,FBOMNumber,a.FVersion as FBOMVerNo,
FBOMNumber+'/A' as FTCBomNumber ,
bg.FName as FBomGroupName,
im.FName  as FParentItemProp,
FUseStatus

from ICBOM a
left join ICBOMGroup bg
on a.FParentID = bg.FInterID
left join t_ICItem i
on a.FItemID = i.FItemID
left join rds_md_itemProp  im
on i.FErpClsID = im.FInterId
where  FUseStatus = 1072


go

select * from rds_pdm_bomHead
go
---(4146 rows affected)
---BOM表体处理
create  view  rds_pdm_bomAll
as
select
     bh.[FBomInterId],
FEntryID as FBomRowNo

      ,bh.[FParentItemNumber]
      ,bh.[FParentItemName]
      ,bh.[FParentItemModel]
      ,bh.[FParentItemDescription]
      ,bh.[FBOMNumber]
      ,bh.[FBOMVerNo]
      ,bh.[FTCBomNumber]
      ,bh.[FBomGroupName]
      ,bh.[FParentItemProp]
      ,bh.[FUseStatus],

i.FNumber as FSubItemNumber,i.FName as FSubItemName,
i.FModel as FSubItemModel,
i.f_119 as FSubItemDescription,
ipr.FName as FSubItemProp,
FQty,m.FName as FSubItemUnitName from ICBOMChild ic
inner  join t_ICItem i
on ic.FItemID = i.FItemID
left join t_MeasureUnit m
on ic.FUnitID = m.FMeasureUnitID
inner join rds_pdm_bomHead bh
on ic.FInterID = bh.FBomInterId
left join rds_md_itemProp ipr
on i.FErpClsID = ipr.FInterId

go

select * from rds_pdm_bomAll





--BOM
select * from ICBOM
--BOM分组
select * from ICBOMGroup where FName='vLocPro3-接收机'


select * from t_ItemPropDesc  where FItemClassID =4


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
GO

create view rds_pdm_bomRelation as
select  FParentItemnumber,FParentItemProp,FSubItemNumber,FSubItemProp from rds_pdm_bomAll
where  FSubItemProp <> '外购'
go



