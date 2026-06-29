delete  from ERPtoPLM_BOM where PLMOperation is null


select *  from ERPtoPLM_BOM
where PLMOperation is null
order by rootcode,flowcode,pmcode,cmcode
