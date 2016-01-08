var AWS = require('aws-sdk');
var route53 = new AWS.Route53({apiVersion: '2013-04-01'});
var ZONE_ID = '/hostedzone/Z28WPRHMOEIFZ';
var DOMAIN = '.metal-cell.adobe.io';
var GW_PREFIX = '*.gw.';

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
                ResourceRecords: values.map( function(ip) {
                    return { Value: ip };
                })
              }
            }]
        },
        HostedZoneId: ZONE_ID 
  };
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
  };
  return params;      
}

exports.handler = function(event, context) {
  
  var dnsName =  GW_PREFIX + event.cell_name + DOMAIN;
  var params = {};
  
  // {"cell_name":"my-cell",  "values":["my-ELB-domain-name"], "hostedZoneId":"ELB-domain-name-zone-id"}
  if ( typeof(event.hostedZoneId) !== "undefined" && event.hostedZoneId !== null ) {
      if ( typeof(event.values) === "undefined" || event.values === null ) {
          return context.fail("'values' field is missing. ");
      }
      if ( Object.prototype.toString.call(event.values) !== "[object Array]" || event.values.length !== 1 ) {
          return context.fail("'values' field expects a one element array for now. ");
      }
      params = getParamsForAliasRecord( event.values[0], event.hostedZoneId, dnsName );
  } else {
      params = getParamsForARecord(event.values, dnsName );    
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
