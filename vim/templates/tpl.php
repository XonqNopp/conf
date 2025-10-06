<?php
require_once("#&%functions/page_helper.php");
$rootPath = "#&%";
$funcpath = "$rootPath/functions";
$page = new PhPage($rootPath);

// debug
//$page->htmlHelper->init();
//$page->logger->levelUp(6);

$page->bobbyTable->init();
//$userIsAdmin = $page->loginHelper->userIsAdmin();

$body = "";


$body = $page->bodyBuilder->goHome(NULL, "..");
// Set title and hot booty
$body .= $page->htmlHelper->setTitle(#&%);  // before HotBooty
$page->htmlHelper->hotBooty();


echo $body;
?>
