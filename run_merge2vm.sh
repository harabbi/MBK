#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby -W0 scripts/merge2vm.rb $1
