#!/bin/bash
host=$1
rsync -ravz -e 'ssh -p 2222' --exclude '.git' ~/work/s/deploy/puppet root@${host}:~/saasbase-deployment/
rsync -ravz -e 'ssh -p 2222' --exclude '.git' ~/work/trommel/clusters root@${host}:~/clusters/
