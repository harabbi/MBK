#!/bin/sh
cd $(dirname $0)
ruby scripts/m_site2mysql.rb $1
