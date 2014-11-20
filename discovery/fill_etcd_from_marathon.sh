#!/bin/bash

app=$1
port=$2

port=$(curl http://scvm1231.dev.ut1.omniture.com:8080/v2/tasks 2>/dev/null | jq --raw-output ".tasks[] | select(.appId == \"/$app\") | .ports[0] " | head -n 1 | tr -d ' ')

counter=1
for host in $(curl http://scvm1231.dev.ut1.omniture.com:8080/v2/tasks 2>/dev/null | jq --raw-output ".tasks[] | select(.appId == \"/$app\") | .host"); do
  echo "setting $host, $counter to $port ..."
  ip=$(host $host | awk '{print $4}')
  etcdctl --peers "http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" set \
    /skydns/local/cell/$app/$counter "{\"host\": \"$ip\", \"port\": $port}"
  let counter=counter+1
done
