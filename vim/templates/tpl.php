<?php
/* TODO:
 */
require("#&%functions/classPage.php");
$rootPath = "#&%";
$funcpath = "$rootPath/functions";
$page = new PhPage($rootPath);
//$page->initDB();
//// debug
//$page->initHTML();
//$page->LogLevelUp(6);
//// CSS paths
//$page->CSS_ppJump();
//$page->CSS_ppWing();
//// init body
$body = "";


//// GoHome
$gohome = new stdClass();
$body .= $page->GoHome($gohome);
//// Set title and hot booty
$body .= $page->SetTitle(#&%);// before HotBooty
$page->HotBooty();


//// Finish
echo $body;
unset($page);
?>
