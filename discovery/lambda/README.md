Description
-----------
Public DNS registration Lambda exposed through the public Adobe IO Gateway.

Usage 
-----
```
curl -i -k -X POST "https://dns.metal-cell.adobe.io/gateway?api_key=<API-KEY>" --data '{"cell_name": "my-cell","values": ["1.2.3.4"]}'
```

* `cell_name` is the name of a CellOS
* `values` is an array of IPs. In AWS it can also be a single entry array containing the domain name of an ELB, in which case the R53 entry is created as an [Alias A Record](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html).

Details
------
* `register-gateway-set.js` is an Amazon Lambda function that interacts with Route 53 in order to register a domain to an IP set.
* `enable-access.sh` is a utility script used to allow another party to invoke the lambda function. This is currently used to allow the API Gateway to call the function directly. 

Deployment
---------

### Deploy the lambda function  

The code for the function is maintained in
[register-gateway-set.js](register-gateway-set.js)

At the moment the deployment is done manually in the AWS Account `#482993447592`, `us-east-1` region, named as `register-gateway-set`. ( AWS ARN is: `arn:aws:lambda:us-east-1:482993447592:function:register-gateway-set` ) 

Each new deployment is automatically exposed through the Gateway using the latest version of the function. 

### Enable access to Adobe IO Gateway (stage)

The API Gateway's accounts (Stage and Prod) in AWS needs to be given `InvokeFunction` permissions. Using the credentials for the AWS account `482993447592` run the `enable-access` utility script.

    enable-access.sh arn:aws:iam::889681731264:role/apiplatform-web
    enable-access.sh arn:aws:iam::360362858010:role/apiplatform-web


### Configure Adobe IO Gateway 

Adobe IO Gateway is a fully managed service provided by Adobe. The Gateway configuration for this endpoint is defined in the [Adobe IO API Console](https://console-stage.adobe.io/publisher/org/396/service/311). To learn more about how to expose a lambda function via Adobe IO see the [documentation](https://wiki.corp.adobe.com/display/API/Configure+AWS+Lambda). 

Each service exposed through Adobe IO belongs to an Adobe publisher. In this case the publisher is [Metal-Cell](https://console-stage.adobe.io/publisher/org/396). The admin for this publisher is `clehene@adobe.com`. The admin can invite more members to manage the service configuration. The service itself is exposed through an API Facade named `Metal Cell Global DNS Service` belonging to the `Metal-Cell` publisher. 

This DNS service is protected with API-KEY. To see the list of application subscribed to the service [click here](https://console-stage.adobe.io/publisher/org/396/service/311/apps).

To see who's calling this service and to monitor it for errors use this [dashboard]( http://elasticsearch.gw.apip-insights-stage.metal-cell.adobe.io/_plugin/kibana/#/dashboard/API-Errors?_g=\(refreshInterval:\(display:Off,section:0,value:0\),time:\(from:now-7d,mode:quick,to:now\)\)&_a=\(query:\(query_string:\(analyze_wildcard:!t,query:'service:dns_metal_cell'\)\),title:API-Errors\)).
