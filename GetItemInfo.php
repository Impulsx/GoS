<?php

$versions = file_get_contents('https://ddragon.leagueoflegends.com/api/versions.json');
$versions = json_decode($versions, true);
$latest = $versions['0'];
$json = file_get_contents('https://ddragon.leagueoflegends.com/cdn/'.$latest.'/data/en_US/item.json');
$json = json_decode($json, true);
$list = $json['data'];

function getItemInfo($id = 1) {
  global $list;
  return $list[$id];
}

//print_r(getItemInfo(8001));

//echo getItemInfo(8001)['name'];

?>
