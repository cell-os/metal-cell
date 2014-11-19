#!/bin/bash

env HBASE_HOME='/usr/lib/hbase/' /opt/opentsdb/bin/create_table.sh
env TSDB_HOME=/opt/opentsdb COMPRESSION='NONE' HBASE_HOME='/usr/lib/hbase/' JAVA_HOME=/usr/lib/jvm/java-7-oracle/ /opt/opentsdb/bin/tsdb tsd --config /opt/opentsdb/share/opentsdb/opentsdb.conf
