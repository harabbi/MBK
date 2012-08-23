#!/bin/sh
cd $(dirname $0)
ruby scripts/merge2m.rb $1
