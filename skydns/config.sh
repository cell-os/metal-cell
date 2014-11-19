curl -XPUT http://scvm1231.dev.ut1.omniture.com:4001/v2/keys/skydns/config -d value='{"ttl": 100, "nameservers": ["10.27.56.31:53", "10.27.56.32:53"], "domain": "ut1-vcell-3.dev"}'

curl -XPUT http://scvm1231.dev.ut1.omniture.com:4001/v2/keys/skydns/config -d value='{"ttl": 100, "nameservers": ["10.27.56.31:53", "10.27.56.32:53"]}'

curl -XPUT http://127.0.0.1:4001/v2/keys/skydns/dev/ut1-vcell-3/production/service1 -d value='{"host": "service5.example.com"}'

SKYDNS_ADDR

docker run -e "SKYDNS_NAMESERVERS=10.27.56.31:53,10.27.56.32:53" -e "ETCD_MACHINES=http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" -e "SKYDNS_ADDR=0.0.0.0:53" -p 1053:53/udp "skynetservices/skydns:latest"

docker run -e "ETCD_MACHINES=http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" -p 127.17.42.1:1053:53/udp "skynetservices/skydns:latest" -verbose true -machines "http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" -nameservers ""

docker run -e "ETCD_MACHINES=http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" -p 127.0.0.1:1053:53/udp "skynetservices/skydns:latest" -verbose true -machines "http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" -nameservers "10.27.56.31:53,10.27.56.32:53" -dns_addr "0.0.0.0:53" 


docker run -e "ETCD_MACHINES=http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" -p 1053:53/udp -p 31900:8080 "skynetservices/skydns:latest" -verbose true -machines "http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" -nameservers ""

docker run -e "ETCD_MACHINES=http://scvm1231.dev.ut1.omniture.com:4001,http://scvm1232.dev.ut1.omniture.com:4001,http://scvm1235.dev.ut1.omniture.com:4001" -e "SKYDNS_DOMAIN=ut1-vcell-3.dev" -e "SKYDNS_NAMESERVERS=10.27.56.31:53" -p 53:53/udp -p 31900:8080 "skynetservices/skydns:latest"

docker run -e "ETCD_MACHINES=172.17.42.1:4001" -e "SKYDNS_DOMAIN=ut1-vcell-3.dev" -e "SKYDNS_NAMESERVERS=10.27.56.31:53" -p 53:53/udp -p 31900:8080 "skynetservices/skydns:latest"
docker run -e "ETCD_MACHINES=scvm1231.dev.ut1.omniture.com:4001" -e "SKYDNS_DOMAIN=ut1-vcell-3.dev" -e "SKYDNS_NAMESERVERS=10.27.56.31:53" -p 53:53/udp -p 31900:8080 "skynetservices/skydns:latest"
