

insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,1 as FStep  , '1.218.03.00001' as rootcode from rds_pdm_bomRelation a
where FParentItemNumber ='1.218.03.00001'
--step1
update rds_pdm_bomTestSet set FParentStatus =1

insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,2 as FStep ,'1.218.03.00001' as rootcode    from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FParentStatus =1 and FSubStatus =0
)

--step2

update a set FSubStatus =1   from rds_pdm_bomTestSet  a where FParentStatus =1 and FSubStatus =0
update rds_pdm_bomTestSet set FParentStatus =1 where FStep =2



insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,3 as FStep  ,'1.218.03.00001' as rootcode    from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FParentStatus =1 and FSubStatus =0
)
go


update a set FSubStatus =1   from rds_pdm_bomTestSet  a where FParentStatus =1 and FSubStatus =0
update rds_pdm_bomTestSet set FParentStatus =1 where FStep =3
go
select * from rds_pdm_bomTestSet

insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,4 as FStep,'1.218.03.00001' as rootcode    from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FParentStatus =1 and FSubStatus =0
)
go

update a set FSubStatus =1   from rds_pdm_bomTestSet  a where FParentStatus =1 and FSubStatus =0
update rds_pdm_bomTestSet set FParentStatus =1 where FStep =4


insert into rds_pdm_bomTestSet
select a.*  ,0 as FParentStatus,0 as FSubStatus,5 as FStep ,'1.218.03.00001' as rootcode     from rds_pdm_bomRelation a
where FParentItemNumber in
(
  select fsubitemnumber from rds_pdm_bomTestSet where FParentStatus =1 and FSubStatus =0
)
go


update a set FSubStatus =1   from rds_pdm_bomTestSet  a where FParentStatus =1 and FSubStatus =0
update rds_pdm_bomTestSet set FParentStatus =1 where FStep =5

---



---数据处理
create view rds_pdm_bomTestStep
as
select fparentitemnumber as FBomItemNo ,FStep,rootcode from rds_pdm_bomTestSet
union
select fsubItemNumber as FBomItemNo,FStep+1 as FStep,rootcode from rds_pdm_bomTestSet
go

select  *  from rds_pdm_bomTestStep
go

--创建linkServer 
exec sp_addlinkedserver 'plm','','SQLOLEDB','192.168.0.16' 

--登陆linkServer 
exec sp_addlinkedsrvlogin 'plm','false',null,'infodba','infodba' 




insert into  plm.TC4K3DB.dbo.ERPtoPLM_BOM


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
           ,[FLowCode],
		   rootcode)

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
	  ,b.FStep [FLowCode]
	  ,b.rootcode

  FROM [dbo].[rds_pdm_bom4TC] a
  inner join rds_pdm_bomTestStep b
  on a.pmcode =  b.FBomItemNo
  where rootcode ='1.218.03.00001'
order by b.FStep,a.PMCode,a.CMCode