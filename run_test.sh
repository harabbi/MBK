#!/bin/bash

mysql -uphilz -pasdyuh23 -e "update vm_merged.vm_merged_products set mbk_import_update=1 where v_productcode like 'MSI-60-403%'"
mysql -uphilz -pasdyuh23 -e "update vm_merged.vm_merged_products set mbk_import_new=1 where v_productcode like 'MSI-60-402%'"
sleep 2
sh run_merge2m.sh
sleep 10
sh run_m2csv.sh
