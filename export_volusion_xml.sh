#!/bin/sh
ruby scripts/v_get_column_data.rb
ruby scripts/v_site2xml.rb
ruby scripts/v_xml2mysql.rb $1
