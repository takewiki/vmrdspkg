#1.获取BOM清单------------

bom_getList

# select PMCode,PLMBatchNum from  vw_PLMtoERP_BOM
# where  cmcode ='' and  ERPDate is null
# order by plmbatchnum,flowcode

# sp_helptext vw_PLMtoERP_BOM

# CREATE   view vw_PLMtoERP_BOM as
# select a.*,i_pm.FItemID as FParentItemId, i_pm.FUnitID as FParentUnitID,
# i_sub.FItemID as FSubItemId,i_sub.FUnitID as FSubUnitId,ig.FInterID as FProductGroupId
#
# from  [PLMtoERP_BOM] a
# left  join t_ICItem i_pm
# on  a.PMCode collate chinese_prc_ci_as  =  i_pm.FNumber
# left  join t_ICItem i_sub
# on  a.CMCode  collate chinese_prc_ci_as  = i_sub.FNumber
# left join ICBOMGroup ig
# on a.ProductGroup collate chinese_prc_ci_as = ig.FNumber
# --v1
# --where ((PLMBatchnum not like 'APP%' and BOMRevCode not like 'BOM%') or (BOMRevCode  like 'BOM%' and PLMBatchnum like 'ECN%' ) )
# --and ERPDate is null
# --we need to contain bom
# where (PLMBatchnum not like 'APP%' )
# and ERPDate is null
#



conn = tsda::conn_rds('test')
sql = "select * from a"
(tsda::sql_select(conn,sql))
sql2 = "insert into a values(3,'huzi',21)"
tsda::sql_update(conn,sql2)
(tsda::sql_select(conn,sql))
sql3 ="delete from a where fid =3"
tsda::sql_update(conn,sql3)
(tsda::sql_select(conn,sql))



