#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby -W0 scripts/m_site2mysql.rb $1
