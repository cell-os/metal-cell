FROM registry1.ut1.omniture.com:5000/metalcell/client:ut1-vcell-3

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y curl telnet unzip

ADD bosun.conf /bosun/bosun.conf
ADD bosun /bosun/bosun

CMD /bosun/bosun -c /bosun/bosun.conf
