#!/bin/bash

export PIDFILE=/var/run/tcollector.pid
export LOG=/var/log/tcollector.log

/opt/tcollector/startstop start -p 31666
sleep 5
tail -n10000 -f /var/log/tcollector.log
