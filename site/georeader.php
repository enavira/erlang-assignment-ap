<?php
	$my_file = "file.txt";
	$fh = fopen($my_file, 'r');
	$str = fread($fh, filesize($my_file));
	fclose($fh);
	//$info_arr = explode("#", $str);
	echo $str;
?>