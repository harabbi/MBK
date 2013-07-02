#!/bin/bash

mysql -uphilz -pasdyuh23 mbk_site_export_$(date +"%Y%m%d") -e "update Products_Joined set mbk_ready_to_import=0"
