Description
-----------
Public DNS registration Lambda exposed through the public Adobe IO Gateway.

Usage 
-----
```
curl -i -k -X POST "https://dns.metal-cell.adobe.io/gateway?api_key=<API-KEY>" --data '{"cell_name": "my-cell","values": ["1.2.3.4"]}'
```

Details
------
`register-dns-set` is an Amazon Lambda function that interacts with Route 53 to register a domain to an IP set.  

Deployment
---------

### Deploy the lambda function  

`register-gateway-set.js`
TBD

### Enable access to Adobe IO Gateway (stage)

    enable-access arn:aws:iam::889681731264:role/apiplatform-web

### Configure Adobe IO Gateway 
This configuration secures access to the lambda. Currently it's token based.  
`api_key=7f7513685fcb4af1be40814ac2c199fa`


