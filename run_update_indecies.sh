#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby -W0 scripts/m_refresh_index.rb $1
