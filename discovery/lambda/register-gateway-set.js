var AWS = require('aws-sdk');
var route53 = new AWS.Route53({apiVersion: '2013-04-01'});
var ZONE_ID = '/hostedzone/Z28WPRHMOEIFZ';
var DOMAIN = '.metal-cell.adobe.io';
var GW_PREFIX = '*.gw.';

console.log('metal-cell dns');

exports.handler = function(event, context) {
  
  var dnsName =  GW_PREFIX + event.cell_name + DOMAIN;
  var params = {
    ChangeBatch: {
      Changes: [{
          Action: 'UPSERT',
          ResourceRecordSet: {
            Name: dnsName,
            Type: 'A',
            TTL: 10,
            ResourceRecords: event.values.map( function(ip) {
                return { Value: ip };
            })
          }
        }]
    },
    HostedZoneId: ZONE_ID 
  };

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
