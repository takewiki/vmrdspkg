#确认物料的逻辑
sync_PLMtoERP_Item_initially(conn_plm = conn_vm_plm_test(),conn_erp = conn_vm_erp_test())
sync_PLMtoERP_Item_periodly()
#确认BOM的物料
sync_PLMtoERP_BOM_intially()
sync_PLMtoERP_BOM_periodly()
