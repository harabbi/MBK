#!/bin/sh
cd $(dirname $0)
ruby scripts/m2csv.rb $1
