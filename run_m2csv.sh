#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby scripts/m2csv.rb $1
