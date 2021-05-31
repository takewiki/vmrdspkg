
--查看BOM单据编码
select  FProjectVal  from t_BillCodeRule where FBillTypeID =50
order by FClassIndex



---更新BOM编码
update a set FProjectVal ='4907'  from t_BillCodeRule  a where FBillTypeID =50
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




