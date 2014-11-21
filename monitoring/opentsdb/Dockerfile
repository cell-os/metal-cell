#Basic update/upgrade/setup and install packages needed in other sections at once to save on number of apt-get instantiations
FROM registry1.ut1.omniture.com:5000/metalcell/client:ut1-vcell-3

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl python gnuplot unzip

WORKDIR /opt
ADD http://bucasit-build.corp.adobe.com/saasbase-repo/opentsdb/opentsdb-2.1.0-rc3.tar.gz /opt/downloads/
RUN tar xzvf /opt/downloads/opentsdb*.tar.gz && rm /opt/downloads/opentsdb*.tar.gz
RUN ln -s /opt/opentsdb-* /opt/opentsdb

ADD logback.xml /opt/opentsdb/share/opentsdb/
ADD opentsdb.conf /opt/opentsdb/share/opentsdb/
ADD start-opentsdb.sh /opt/opentsdb/
#RUN chmod +x /opt/opentsdb/start-opentsdb.sh
#EXPOSE 4242

CMD env && python -mSimpleHTTPServer $PORT0

#/opt/opentsdb/build/tsdb tsd --port=4242 --staticroot=/opt/opentsdb/build/staticroot --cachedir=/tmp --auto-metric
#/opt/opentsdb/build/tsdb tsd --config <%= @tsdb_home %>/share/opentsdb/opentsdb.conf
#echo CiMhL2Jpbi9iYXNoCgpleHBvcnQgQ09NUFJFU1NJT049Ik5PTkUiCmV4cG9ydCBIQkFTRV9IT01FPS9vcHQvaGJhc2UtMC45NC4xMApleHBvcnQgSkFWQV9IT01FPS91c3IvbGliL2p2bS9qYXZhLTYtb3Blbmpkay1hbWQ2NAoKY2QgL29wdC9vcGVudHNkYgouL3NyYy9jcmVhdGVfdGFibGUuc2gKdG91Y2ggL29wdC9vcGVudHNkYl90YWJsZXNfY3JlYXRlZC50eHQK | base64 -d 

