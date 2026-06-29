

conn_erp = conn_vm_erp_test2()
sql = paste0("select * from icbom where fbomnumber like '%2994%'")
mydata = tsda::sql_select(conn_erp,sql)
View(mydata)

conn_plm = conn_vm_plm_prd()
sql_plm = paste0("select * from  ERPtoplm_bom")
mydata2 = tsda::sql_select(conn_plm,sql_plm)
View(mydata2)





sync_PLMtoERP_Item_initially(conn_plm = conn_plm,conn_erp = conn_erp )
sync_PLMtoERP_Item_periodly(conn_plm = conn_plm,conn_erp = conn_erp )

# ---test for bom
sync_PLMtoERP_BOM_intially(conn_plm = conn_plm,conn_erp = conn_erp )
sync_PLMtoERP_BOM_periodly(conn_plm = conn_plm,conn_erp = conn_erp )
#--test for plm to ERP
bom_getList(conn = conn_erp)

# 1  2.104.01.00043 BOM00000001
# 2  2.104.01.00044 BOM00000001
# 3  2.104.01.00045 BOM00000001
# 4  2.104.01.00049 BOM00000001
# 5  2.104.01.00050 BOM00000001
# 6  2.104.01.00046 BOM00000001
# 7  2.104.01.00047 BOM00000001
# 8  2.104.01.00048 BOM00000001
# 9  2.109.03.00019 ECN00000003
# 10 2.218.03.00007 PRD00000004
# 11 2.218.03.00008 PRD00000004
# 12 2.218.03.00009 PRD00000004
Item_getList(conn = conn_erp )



BOM_getNewBillTpl_Body(conn = conn_erp,PMCode = '1.218.03.00002',PLMBatchnum = 'ECN00000009')

BOM_getNewBillTpl_Head(conn = conn_erp,PMCode = '1.218.03.00002',PLMBatchnum = 'ECN00000009')


--
  --initial the material
Item_Initial_WG(conn = conn_erp)
Item_Initial_WW(conn = conn_erp)
Item_Initial_ZZ(conn=conn_erp)

Item_readIntoERP_One(conn=conn_erp,MCode = '3.02.02.001293',MProp = '外购',PLMBatchnum = 'ECN00000004')
Item_readIntoERP_One(conn=conn_erp,MCode = '3.02.02.001282',MProp = '外购',PLMBatchnum = 'PRD00000005')
Item_readIntoERP_One(conn=conn_erp,MCode = '3.02.02.001283',MProp = '外购',PLMBatchnum = 'PRD00000005')

Item_readIntoERP_One(conn=conn_erp,MCode = '3.02.02.001292',MProp = '外购',PLMBatchnum = 'ECN00000004')


Item_readIntoERP_One(conn=conn_erp,MCode = '3.02.09.000952',MProp = '委外加工',PLMBatchnum = 'ECN00000004')


Item_readIntoERP_One(conn=conn_erp,MCode = '2.218.03.00007',MProp = '自制',PLMBatchnum = 'ECN00000004')
Item_readIntoERP_One(conn=conn_erp,MCode = '2.218.03.00008',MProp = '自制',PLMBatchnum = 'PRD00000005')
Item_readIntoERP_One(conn=conn_erp,MCode = '2.218.03.00009',MProp = '自制',PLMBatchnum = 'PRD00000005')


Item_readIntoERP_One(conn=conn_erp,MCode = '3.02.02.001292',MProp = '外购',PLMBatchnum = 'ECN00000004')


Item_readIntoERP_ALL(conn=conn_erp)


bom_readIntoERP_ALL(conn = conn_erp)



