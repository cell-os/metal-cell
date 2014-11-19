#!/bin/bash

while true ; do 
    echo "put my.metric `date +%s` $(($RANDOM % 255))  host=somehost"  | nc scvm1278.dev.ut1.omniture.com 31666
    echo "pushed"
    sleep 1;
done

