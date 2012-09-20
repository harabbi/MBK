#!/bin/sh
. /home/philz/.bashrc
cd $(dirname $0)
ruby scripts/v_health_and_monitor.rb
