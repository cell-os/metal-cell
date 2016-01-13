var AWS = require('aws-sdk');
var route53 = new AWS.Route53({apiVersion: '2013-04-01'});
var ZONE_ID = '/hostedzone/Z28WPRHMOEIFZ';
var DOMAIN = '.metal-cell.adobe.io';
var GW_PREFIX = '*.gw.';

// See https://forums.aws.amazon.com/thread.jspa?messageID=608949
var elbHostedZoneIds = {
   "ap-northeast-1": "Z14GRHDCWA56QT",
   "ap-southeast-1": "Z1LMS91P8CMLE5",
   "ap-southeast-2": "Z1GM3OXH4ZPM65",
   "eu-central-1": "Z215JYRZR1TBD5",
   "eu-west-1": "Z32O12XQLNTSW2",
   "sa-east-1": "Z2P70J7HTTTPLU",
   "us-east-1": "Z35SXDOTRQ7X7K",
   "us-west-1": "Z368ELLRRE2KJ0",
   "us-west-2": "Z1H1FL5HABSF5"
}

console.log('metal-cell dns');

function getParamsForARecord(values, dnsName) {
    var params = {
        ChangeBatch: {
          Changes: [{
              Action: 'UPSERT',
              ResourceRecordSet: {
                Name: dnsName,
                Type: 'A',
                TTL: 10,
                ResourceRecords: values.map(function(ip) {
                    return { Value: ip };
                })
              }
            }]
        },
        HostedZoneId: ZONE_ID 
  }
  return params;
}

function getParamsForAliasRecord(aliasDnsName, aliasHostedZoneId, dnsName) {
    var params = {
        ChangeBatch: {
          Changes: [{
              Action: 'UPSERT',
              ResourceRecordSet: {
                Name: dnsName,
                Type: 'A',
                AliasTarget: {
                    DNSName: aliasDnsName,
                    HostedZoneId: aliasHostedZoneId,
                    EvaluateTargetHealth: true
                }
              }
            }]
        },
        HostedZoneId: ZONE_ID 
  }
  return params;      
}

exports.handler = function(event, context) {
  
  var dnsName =  GW_PREFIX + event.cell_name + DOMAIN;
  var params = {};
  
  if (typeof(event.values) === "undefined" || event.values === null) {
    return context.fail("'values' field is missing. ");
  }
  if (Object.prototype.toString.call(event.values) !== "[object Array]") {
    return context.fail("'values' field expects an array. ");
  }

  var pieces = event.values[0].split(".");
  if (pieces.length < 4) {
    return context.fail("Invalid value ", event.values[0]);
  }

  if (pieces.length > 4) {
    // assuming it's something like c3-lb-membrane-1444059004.eu-west-1.elb.amazonaws.com
    var region = pieces[1];
    var hostedZoneId = elbHostedZoneIds[region];
    if (typeof(hostedZoneId) === "undefined") {
      return context.fail("Unknown region ", region);
    }
    params = getParamsForAliasRecord(event.values[0], hostedZoneId, dnsName);
  } else {
      params = getParamsForARecord(event.values, dnsName);
  }
  
  console.log("Calling R53 with params:", JSON.stringify(params, null, 2));

  route53.changeResourceRecordSets(params, function(err, data) {
    if (err) {
      context.fail("error creating " + dnsName + "\n" + data + "\n" + err + "\n"
      + err.stack);

    } else {
      context.succeed("created " + dnsName + "\n" + JSON.stringify(data) + 
      "\n" + JSON.stringify(params)); //console.log(err, err.stack);
    }
  });
};
