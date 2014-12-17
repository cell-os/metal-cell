# VERSION 0.1
# DOCKER-VERSION  1.3.1
# AUTHOR:         Cosmin Lehene <clehene@adobe.com> 
# DESCRIPTION:    Image with docker-registry with HDFS support 
# TO_BUILD:       docker build -rm -t metalcell/docker-registry .
# TO_RUN:         docker run -p 5000:5000 metalcell/docker-registry

# Latest Ubuntu LTS
FROM ubuntu:14.04

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y python

RUN \
  apt-get install -y jq curl host && \
  curl -L  https://github.com/coreos/etcd/releases/download/v0.5.0-alpha.4/etcd-v0.5.0-alpha.4-linux-amd64.tar.gz -o etcd-v0.5.0-alpha.4-linux-amd64.tar.gz &&\
  tar xzvf etcd-v0.5.0-alpha.4-linux-amd64.tar.gz
  

ADD fill_etcd_from_marathon.sh .

CMD ./fill_etcd_from_marathon.sh cr.corp.adobe.com 58000
