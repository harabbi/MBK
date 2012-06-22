#!/bin/sh
cd $(dirname $0)
ruby scripts/v_xml2mysql.rb $1
