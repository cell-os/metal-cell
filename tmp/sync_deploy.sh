#!/bin/bash

export SAASBASE_DEPLOYMENT_HOME=${SAASBASE_DEPLOYMENT_HOME:-~/work/s/deploy/puppet}

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
export DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

copy_stuff() {
  local host=$1
  echo "Copying to $host"
  rsync -ravz --exclude '.git' $SAASBASE_DEPLOYMENT_HOME root@${host}:~/saasbase-deployment/
  rsync -ravz --exclude '.git' $DIR/../../clusters/* root@${host}:~/metalcell/clusters

  for module in puppet-docker puppet-mesos puppet-etcd puppet-marathon; do 
    rsync -ravz --exclude '.git' $DIR/../../$module root@${host}:~/metalcell/puppet/
  done
}

export -f copy_stuff

parallel --env DIR --env SAASBASE_DEPLOYMENT_HOME copy_stuff ::: $*
