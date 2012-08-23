#!/bin/sh
cd $(dirname $0)
ruby scripts/v2merge.rb $1
