#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby scripts/v_get_column_data.rb
ruby scripts/v_site2mysql.rb $1
