#!/bin/sh
ruby scripts/download_xmls.rb
ruby scripts/v_xml2mysql.rb $1
