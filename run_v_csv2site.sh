#!/bin/sh
cd $(dirname $0)
ruby scripts/v_csv2site.rb $1
