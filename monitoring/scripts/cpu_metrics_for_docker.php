<?php
$host = 'localhost';
$host = 'scvm1277.dev.ut1.omniture.com';
$port = '31400';
$url = '/api/v1.2/containers';
$sleep = 58;
$iters = 500;
date_default_timezone_set('UTC');
$last_total = 0;
$last_ts = 0;

$cur_iters = 0;
$url = "http://{$host}:{$port}{$url}";
$ch = curl_init(); 
curl_setopt($ch, CURLOPT_URL, $url); 
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
curl_setopt($ch, CURLOPT_POST, null);

while (true) {
    $cur_iters++;

    if ($cur_iters > $iters) {
        break;
    }

    $output = curl_exec($ch);

    if ($output == false) {
        break;
    }

    $json = json_decode($output, true);

    foreach ($json['stats'] as $cd) {
	$cpu = $cd['cpu']['usage'];
	$ts = getUnixTime($cd['timestamp']);
        list($last_total, $last_ts) = getCPU($cpu, $ts, $last_total, $last_ts);
    }

    sleep($sleep);
}

curl_close($ch);

function getUnixTime($ts) {
    return strtotime(str_replace('T', ' ', substr($ts, 0, 19))) . '.' . substr($ts, 20, -1);
}

function getCPU($data, $ts, $last_total, $last_ts) {
    $cores = sizeof($data['per_cpu_usage']);
    $total = ($data['total'] - $last_total) / 1000000000;
    $max = $cores * ($ts - $last_ts);
    $perc_util = $total / $max;

    if ($last_total != 0) {
        printOpenTSDB('container.cpu.util', substr($ts, 0, 10), $total);
    } 
    return array($data['total'], $ts);
}

function printOpenTSDB($key, $ts, $val, $tags = null) {
    $tag_str = '';

    if (is_array($tags)) {
        foreach($tags as $tag_name => $tag_val) {
            $tag_str .= "$tag_name=$tag_val ";
        }
    }

    echo "$key $ts $val $tag_str\r\n";
}
