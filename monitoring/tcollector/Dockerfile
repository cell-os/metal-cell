FROM debian

#FROM registry1.ut1.omniture.com:5000/pmackles/pipeline-producer:meatwad

RUN DEBIAN_FRONTEND=noninteractive apt-get -y  update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python php5-common libapache2-mod-php5 php5-cli unzip  vim

WORKDIR /opt
ADD http://bucasit-build.corp.adobe.com/saasbase-repo/tcollector/tcollector-0.0.9-SNAPSHOT.tar.gz /opt/downloads/
RUN tar xzvf /opt/downloads/tcollector*.tar.gz && rm /opt/downloads/tcollector*.tar.gz
RUN ln -s /opt/tcollector-* /opt/tcollector
RUN mkdir -p /usr/java/latest/lib/
RUN ln -s /usr/lib/jvm/java-7-oracle/lib/tools.jar /usr/java/latest/lib/tools.jar

ADD start-tcollector.sh /opt/tcollector/
ADD pipeline_producer_jmx.py /opt/tcollector/collectors/0/pipeline_producer_jmx.py
CMD bash -x /opt/tcollector/start-tcollector.sh
