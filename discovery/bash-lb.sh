#!/bin/bash

app=$1
port=$2

export ETCDCTL_PEERS=http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001

port=$(curl http://scvm1231.dev.ut1.omniture.com:8080/v2/tasks 2>/dev/null | jq --raw-output ".tasks[] | select(.appId == \"/$app\") | .ports[0] " | head -n 1 | tr -d ' ')

while true
do

counter=1
./etcd-v0.5.0-alpha.4-linux-amd64/etcdctl --peers "http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" ls \
    /skydns/local/cell/$app > removal

while read line; do
  entry=$(./etcd-v0.5.0-alpha.4-linux-amd64/etcdctl get $line)
  echo $entry| cut -d "\"" -f 4,7 | sed "s/\"//;s/}//;s/\ //" | xargs curl -s -I --connect-timeout 2 >/dev/null 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "Remvoing $line -> $entry from DNS"
    ./etcd-v0.5.0-alpha.4-linux-amd64/etcdctl rm $line
  fi
done < removal


counter=1
for host in $(curl http://scvm1231.dev.ut1.omniture.com:8080/v2/tasks 2>/dev/null | jq --raw-output ".tasks[] | select(.appId == \"/$app\") | .host"); do
  echo "setting $host, $counter to $port ..."
  ip=$(host $host | head -1 | awk '{print $4}')
  ./etcd-v0.5.0-alpha.4-linux-amd64/etcdctl  set /skydns/local/cell/$app/$counter "{\"host\": \"$ip\", \"port\": $port}"
  let counter=counter+1
done


done
