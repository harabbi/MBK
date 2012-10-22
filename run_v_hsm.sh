#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby -W0 scripts/v_health_and_monitor.rb
