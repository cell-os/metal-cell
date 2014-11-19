#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

host=$1

for host in $*; do
  rsync -ravz --exclude '.git' ~/work/s/deploy/puppet root@${host}:~/saasbase-deployment/
  rsync -ravz --exclude '.git' $DIR/../../clusters/* root@${host}:~/metalcell/clusters
  #rsync -ravz --exclude '.git' $DIR/../../clusters/* root@${host}:~/clusters

  for module in puppet-docker puppet-mesos puppet-etcd puppet-marathon; do 
    rsync -ravz --exclude '.git' $DIR/../../$module root@${host}:~/metalcell/puppet/
    #rsync -ravz --exclude '.git' $DIR/../../$module root@${host}:~/puppet/
  done
done
