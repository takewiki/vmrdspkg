
--查看BOM单据编码
select  FProjectVal  from t_BillCodeRule where FBillTypeID =50
order by FClassIndex



---更新BOM编码
update a set FProjectVal ='4907'  from t_BillCodeRule  a where FBillTypeID =50
and FProjectID =3


select    FProjectVal   from t_BillCodeRule  a where FBillTypeID =50
and FProjectID =3







--最大内码的取数逻辑

select max(FInterID )+1 as FInterId from ICBOM

--BOM表本数据 的写入规则


INSERT INTO ICBomChild (FInterID,FEntryID,FBrNo,FItemID,FAuxPropID,FUnitID,FMaterielType,FMarshalType,FQty,FAuxQty,FBeginDay,FEndDay,FPercent,FScrap,FPositionNo,FItemSize,FItemSuite,FOperSN,FOperID,FMachinePos,FOffSetDay,FBackFlush,FStockID,FSPID,FNote,FNote1,FNote2,FNote3,FPDMImportDate,FDetailID,FCostPercentage,FEntrySelfZ0142,FEntrySelfZ0144,FEntrySelfZ0145,FEntrySelfZ0146,FEntrySelfZ0148)
SELECT 6499,1,'0',2038,0,66,371,385,1,1,'1900-01-01','2100-01-01',100,0.1,'','','',0,0,'',0,1059,0,0,'','','','','','{D3B00053-E136-4304-B83E-1334A2E23076}',0,'',Null,Null,0,0 union all
   SELECT 6499,2,'0',2260,0,66,371,385,2,2,'1900-01-01','2100-01-01',100,0.2,'','','',0,0,'',0,1059,0,0,'','','','','','{701576DB-9B5E-4BC8-B8CA-18684C319FAE}',0,'',Null,Null,0,0 union all
   SELECT 6499,3,'0',2040,0,66,371,385,3,3,'1900-01-01','2100-01-01',100,0.3,'','','',0,0,'',0,1059,0,0,'','','','','','{BAB62D42-6981-4E05-8777-501BA379759E}',0,'',Null,Null,0,0 union all
   SELECT 6499,4,'0',3502,0,66,371,385,4,4,'1900-01-01','2100-01-01',100,0.4,'','','',0,0,'',0,1059,6219,953,'','','','','','{2613494F-4D7C-44D5-9E1D-D6740E6F70DD}',0,'',Null,Null,0,0

go

--BOM表头数据 的写入规则

INSERT INTO ICBom(FInterID,FBomNumber,FBrNo,FTranType,FCancellation,FStatus,FVersion,FUseStatus,FItemID,FUnitID,FAuxPropID,FAuxQty,FYield,FNote,FCheckID,FCheckDate,FOperatorID,FEntertime,FRoutingID,FBomType,FCustID,FParentID,FAudDate,FImpMode,FPDMImportDate,FBOMSkip,FUseDate,FHeadSelfZ0135,FPrintCount)
SELECT 6499,'BOM004906','0',50,0,0,'000','1073',1862,'66',0,1,100,'',16394,'2021-01-07',16394,'2021-01-07',0,0,0,1341,Null,0,Null,'1059',Null,'自制',0
go




select FInterID,FBomNumber,FBrNo,FTranType,FCancellation,FStatus,FVersion,FUseStatus,FItemID,FUnitID,FAuxPropID,FAuxQty,FYield,FNote,FCheckID,FCheckDate,FOperatorID,FEntertime,FRoutingID,FBomType,FCustID,FParentID,FAudDate,FImpMode,FPDMImportDate,FBOMSkip,FUseDate,FHeadSelfZ0135,FPrintCount
into rds_icbom_tpl_head
from ICBom
where finterid =6499


---drop table rds_icbom_tpl_body

select  top 1 FInterID,FEntryID,FBrNo,FItemID,FAuxPropID,FUnitID,FMaterielType,FMarshalType,FQty,FAuxQty,FBeginDay,FEndDay,FPercent,FScrap,FPositionNo,FItemSize,FItemSuite,FOperSN,FOperID,FMachinePos,FOffSetDay,FBackFlush,FStockID,FSPID,FNote,FNote1,FNote2,FNote3,FPDMImportDate,FDetailID,FCostPercentage,FEntrySelfZ0142,FEntrySelfZ0144,FEntrySelfZ0145,FEntrySelfZ0146,FEntrySelfZ0148
into rds_icbom_tpl_body
from ICBOMChild
where finterid =6499

select *      from rds_icbom_tpl_body

select *  into  rds_icbomChild_input    from rds_icbom_tpl_body


select *    into  rds_icbom_input   from rds_icbom_tpl_head


delete  from rds_icbomChild_input


select *   from rds_icbomChild_input


select * from  rds_icbom_tpl_head


select * from rds_icbom_input
delete  from rds_icbom_input







INSERT INTO ICBomChild (FInterID,FEntryID,FBrNo,FItemID,FAuxPropID,FUnitID,FMaterielType,FMarshalType,FQty,FAuxQty,FBeginDay,FEndDay,FPercent,FScrap,FPositionNo,FItemSize,FItemSuite,FOperSN,FOperID,FMachinePos,FOffSetDay,FBackFlush,FStockID,FSPID,FNote,FNote1,FNote2,FNote3,FPDMImportDate,FDetailID,FCostPercentage,FEntrySelfZ0142,FEntrySelfZ0144,FEntrySelfZ0145,FEntrySelfZ0146,FEntrySelfZ0148)
select *   from rds_icbomChild_input
go


truncate table  rds_icbomChild_input


select *   from ICBOMChild where FInterID =6500





select *  from  rds_icbom_input



select * from  rds_icbom_tpl_body



sp_help rds_icbomChild_input

------同步数据

    select *  into PLMtoERP_BOM   from [TC4K3DB].[dbo].[PLMtoERP_BOM]


------创建视图
alter  view vw_PLMtoERP_BOM as
select a.*,i_pm.FItemID as FParentItemId, i_pm.FUnitID as FParentUnitID,
     i_sub.FItemID as FSubItemId,i_sub.FUnitID as FSubUnitId,ig.FInterID as FProductGroupId

from  [PLMtoERP_BOM] a
left  join t_ICItem i_pm
on  a.PMCode collate chinese_prc_ci_as  =  i_pm.FNumber
left  join t_ICItem i_sub
on  a.CMCode  collate chinese_prc_ci_as  = i_sub.FNumber
left join ICBOMGroup ig
on a.ProductGroup collate chinese_prc_ci_as = ig.FNumber
go


select * from  vw_PLMtoERP_BOM






	  select FParentItemId,FParentUnitID,BOMRevCode,FProductGroupId  from  [vw_PLMtoERP_BOM]
  where  PLMBatchnum='BOM00000002' and PMCode =  '2.104.20.00034' and CMCode=''



create table rds_BOM_version (FVersion_PLM varchar(30),FVersion_ERP varchar(30))
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



select FVersion_ERP from rds_BOM_version
where FVersion_PLM ='A'



















	  select FParentItemId,FParentUnitID,BOMRevCode,ProductGroup   from  [vw_PLMtoERP_BOM]
  where PLMBatchnum='BOM00000002'
and PMCode='2.104.20.00034' and CMCode =''


select * from ICBOMGroup where FNumber like '104%'



select * from ICBOMGroup where  FName  like 'vLoc3-5000%'




109.03




update a set  ProductGroup='109.03'  from  PLMtoERP_BOM a
where ProductGroup ='104'


select * from  PLMtoERP_BOM
