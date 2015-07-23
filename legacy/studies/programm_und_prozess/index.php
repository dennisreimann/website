<?php

$pages = Array(
	"algorithmus" => "Algorithmus",
	"programme_und_prozesse" => "Programme und Prozesse",
	"programmiersprachen" => "Programmiersprachen",
	"formale_sprachen" => "Formale Sprachen",
	"mengen_und_zahlen" => "Mengen und Zahlen",
	"funktionen_und_parameter" => "Funktionen und Parameter",
	"bild_und_bildlichkeit" => "Bild und Bildlichkeit",
	"processing" => "Processing",
	"turing_berechenbarkeit" => "Turing-Berechenbarkeit",
	"zufall" => "Zufall",
	"bild_text_maschine_medium" => "Bild, Text, Maschine, Medium",
	"daten_information_wissen" => "Daten, Information, Wissen",
	"abstraktion" => "Abstraktion"
);

function url_for($page) { return $_SERVER['SERVER_ADDR'] == "127.0.0.1" ? "./index.php?p=" . $page : "./" . $page; }
function link_to($page) { global $pages; return '<a href="' . url_for($page) . '">' . $pages[$page] . '</a>'; }
function link_to_program($name) { return '<a class="program" href="programs/' . $name . '">' . $name . '</a>'; }

define("CONTENT", isset($_GET['p']) ? $_GET['p'] : "start");

if(CONTENT != "start")
	$page_title = $pages[CONTENT];

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
	<head>
		<title><?php if(isset($page_title)) { echo $page_title . " | "; } ?>Programm &amp; Prozess. Grundlagen der Programmierung von Bildern.</title>
		<link rel="Shortcut Icon" href="favicon.ico" type="image/x-icon" />
		<link rel="literature" href="literatur.html" type="text/html" />
		<link rel="stylesheet" type="text/css" media="all" href="css/pp.css" />
		<link rel="stylesheet" type="text/css" media="print" href="css/pp_print.css" />
		<!--[if lte IE 6]><link rel="stylesheet" type="text/css" media="all" href="css/pp_ie.css" /><![endif]-->
		<!--[if IE 7]><link rel="stylesheet" type="text/css" media="all" href="css/pp_ie7.css" /><![endif]-->
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<meta http-equiv="Content-Language" content="de" />
		<meta http-equiv="imagetoolbar" content="false" />
		<meta name="MSSmartTagsPreventParsing" content="true" />
		<meta name="author" content="dennisbloete.de" />
		<meta name="robots" content="index,follow" />
		<meta name="Copyright" content="Copyright (c) 2007 dennisbloete.de" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
	</head>
	<body>
		<div id="wrap">
			<div id="sidebar">
				<div id="logo"><a id="home" href="./" title="zur Startseite">Programm &amp; Prozess</a>.</div>
				<div id="claim">Grundlagen der Programmierung von Bildern.</div>
				<p>Frieder Nake, HfK Bremen</p>
				<ul class="go">
					<li><a href="<?= url_for("start"); ?>#contents">Inhaltsverzeichnis</a> | </li>
					<li><a href="<?= url_for("literatur"); ?>">Literatur &amp; Quellen</a></li>
				</ul>
				<p class="note">
					Dennis Bl&ouml;te, Universit&auml;t Bremen<br />
					Digitale Medien - WS 2006/2007<br />
					28. Februar 2007
				</p>
			</div>
			<div id="main">
<?php require("content/" . CONTENT . ".html") ?>
			</div>
			<div class="clear"></div>
		</div>
	</body>
</html>