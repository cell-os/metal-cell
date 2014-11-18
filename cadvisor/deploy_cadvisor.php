<?php

echo "Gathering Node Count\n";
$registry = getRegistry('vm1077.dev.ut1.omniture.com');
$nodes = sizeof($registry['slaves']['slaves']);
echo "Node Count = $nodes\n";

// set the number of nodes to deploy
$contents = file_get_contents('cadvisor.json');
$config = json_decode($contents, true);
$config['instances'] = $nodes;
$json = json_encode($config);
file_put_contents('cadvisor.json', $json);

// deploy cadvisor
exec("curl -X POST -H \"Content-Type: application/json\" http://vm9159.ut1.omniture.com:8080/v2/apps -d@cadvisor.json", $out, $state);

print_r($out);

function getRegistry($host) {
    $url = "http://{$host}:5050/registrar(1)/registry";
    exec("curl -X POST 'http://{$host}:5050/registrar(1)/registry' 2>/dev/null", $out, $state);
    return json_decode($out[0], true);
}
