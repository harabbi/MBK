#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby scripts/v_mysql2site.rb $1
