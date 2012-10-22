#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby -W0 scripts/v_get_column_data.rb
ruby -W0 scripts/v_site2mysql.rb $1
