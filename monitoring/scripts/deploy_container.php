<?php

if ($argc != 3) {
    echo "Usage: ./" . $argv[0] . " <host> <fn>\n";
    exit(1);
}

$host = $argv[1];
$fn = $argv[2];

if (!file_exists($fn)) {
    echo "File $fn does not exist\n";
    exit(1);
}

$fn_new = $fn . '.new';

echo "Gathering Node Count\n";
$registry = getRegistry($host);
$nodes = sizeof($registry['slaves']['slaves']);
echo "Node Count = $nodes\n";

// set the number of nodes to deploy
$contents = file_get_contents($fn);
$config = json_decode($contents, true);
$config['instances'] = $nodes;
$json = json_encode($config);
file_put_contents($fn_new, $json);

$status = deployContainer($host, $fn_new);

print_r($status);
unlink($fn_new);
exit(0);

function deployContainer($host, $fn) {
    exec("curl -X POST -H \"Content-Type: application/json\" http://{$host}:8080/v2/apps -d@{$fn} 2>/dev/null", 
         $out,
         $state);

    return json_decode($out[0], true);
}

function getRegistry($host) {
    exec("curl -X POST 'http://{$host}:5050/registrar(1)/registry' 2>/dev/null", $out, $state);
    return json_decode($out[0], true);
}
