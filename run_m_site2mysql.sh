#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby scripts/m_site2mysql.rb $1
