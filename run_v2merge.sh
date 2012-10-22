#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby -W0 scripts/v2merge.rb $1
