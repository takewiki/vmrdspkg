drop table rds_pdm_bomTestSet

select a.*  ,0 as FParentStatus,0 as FSubStatus,1 as FStep   into rds_pdm_bomTestSet from rds_pdm_bomRelation a
where FParentItemNumber ='1.109.03.00024'

go
select * from rds_pdm_bomTestSet
update rds_pdm_bomTestSet set FParentStatus =1

select * from rds_pdm_bomTestSet
go

insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,2 as FStep    from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FParentStatus =1 and FSubStatus =0
)

select * from rds_pdm_bomTestSet
go

update a set FSubStatus =1   from rds_pdm_bomTestSet  a where FParentStatus =1 and FSubStatus =0
update rds_pdm_bomTestSet set FParentStatus =1 where FStep =2

go

insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,3 as FStep    from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FParentStatus =1 and FSubStatus =0
)
go
select * from rds_pdm_bomTestSet

update a set FSubStatus =1   from rds_pdm_bomTestSet  a where FParentStatus =1 and FSubStatus =0
update rds_pdm_bomTestSet set FParentStatus =1 where FStep =3
go
select * from rds_pdm_bomTestSet

insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,4 as FStep    from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FParentStatus =1 and FSubStatus =0
)
go

update a set FSubStatus =1   from rds_pdm_bomTestSet  a where FParentStatus =1 and FSubStatus =0
update rds_pdm_bomTestSet set FParentStatus =1 where FStep =4


insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,5 as FStep    from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FParentStatus =1 and FSubStatus =0
)
go


update a set FSubStatus =1   from rds_pdm_bomTestSet  a where FParentStatus =1 and FSubStatus =0
update rds_pdm_bomTestSet set FParentStatus =1 where FStep =5

---

select * from rds_pdm_bomTestSet
insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,6 as FStep    from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FParentStatus =1 and FSubStatus =0
)
go

update a set FSubStatus =1   from rds_pdm_bomTestSet  a where FParentStatus =1 and FSubStatus =0
update rds_pdm_bomTestSet set FParentStatus =1 where FStep =6

---数据处理
create view rds_pdm_bomTestStep
as
select fparentitemnumber as FBomItemNo ,FStep from rds_pdm_bomTestSet
union
select fsubItemNumber as FBomItemNo,FStep+1 as FStep from rds_pdm_bomTestSet
go

select  *  from rds_pdm_bomTestStep
go

select * from rds_pdm_bomTestSet




insert into  TC4K3DB.dbo.ERPtoPLM_BOM


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
           ,[FLowCode],rootcode)

SELECT [PMCode]
      ,[PMName]
      ,[BOMRevCode]
      ,[CMCode]
      ,[CMName]
      ,[ProductGroup]
      ,[BOMCount]
      ,[BOMUOM]
      ,[PLMOperation]
      ,'W' as [ERPOperation]
      ,[PLMDate]
      ,[ERPDate]
	  ,b.FStep [FLowCode],'1.109.03.00024' as rootcode

  FROM [dbo].[rds_pdm_bom4TC] a
  inner join rds_pdm_bomTestStep b
  on a.pmcode =  b.FBomItemNo
order by b.FStep,a.PMCode,a.CMCode



select * from rds_pdm_bom4TC