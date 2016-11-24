<?php
$dbhost = 'dbhost';
$dbuser = 'dbuser';
$dbpass = 'dbpass';
$dbname = 'dbname';
$svrcon = 'svrcon';

function send_commands($cmds)
{
	global $svip;
	global $svport;
	global $svrcon;

	$fp = fsockopen("udp://$svip", $svport, $errno, $errstr);
	if ($fp) {
		$string = chr(1).chr(0).chr(242).chr(strlen($svrcon)).$svrcon.pack("S",strlen($cmds)).$cmds;
		fwrite($fp, $string);
		fclose($fp);
	}
}

function escape_string($link, $var)
{
	$var = mysqli_real_escape_string($link, $var);
	$var = utf8_encode($var);
	$var = trim($var);
	$var = htmlspecialchars($var);

	return $var;
}

function send_results($data)
{
	global $id;
	global $dbhost;
	global $dbuser;
	global $dbpass;
	global $dbname;

	$length = sizeof($data);
	printf("Received data: %d\n", $length);

	$link = mysqli_connect($dbhost, $dbuser, $dbpass, $dbname);

	if (mysqli_connect_errno()) {
		printf("Connect failed: %s\n", mysqli_connect_error());
		exit();
	}

	mysqli_set_charset($link, "utf8");

	if ($length == 8) {
		$team_a = escape_string($link, $data[0]);
		$team_b = escape_string($link, $data[1]);
		$map = escape_string($link, $data[2]);
		$size = escape_string($link, $data[3]);
		$team_a_t_score = escape_string($link, $data[4]);
		$team_b_ct_score = escape_string($link, $data[5]);
		$team_a_ct_score = escape_string($link, $data[6]);
		$team_b_t_score = escape_string($link, $data[7]);
		$end = time();

		$query = "INSERT INTO warmod_matches VALUES (NULL, '$team_a', '$team_b', '$map', '$size', '$team_a_t_score', '$team_b_ct_score', '$team_a_ct_score', '$team_b_t_score', '$end')";

		mysqli_query($link, $query);

		$id = mysqli_insert_id($link);

		send_commands("msg ".chr(169)."255255255www.cs2d.net/workshop/mixes.php?id=$id");
	}

	if ($length == 14) {
		$usgn = escape_string($link, $data[0]);
		$ip = escape_string($link, $data[1]);

		if ($ip == "0.0.0.0") {
			$code = "";
		} else {
			$code = trim(file_get_contents("http://ip-api.com/line/$ip?fields=countryCode"));
		}

		$name = escape_string($link, $data[2]);
		$team = escape_string($link, $data[3]);
		$mix_dmg = escape_string($link, $data[4]);
		$frags = escape_string($link, $data[5]);
		$deaths = escape_string($link, $data[6]);
		$bomb_plants = escape_string($link, $data[7]);
		$bomb_defusals = escape_string($link, $data[8]);
		$double = escape_string($link, $data[9]);
		$triple = escape_string($link, $data[10]);
		$quadra = escape_string($link, $data[11]);
		$aces = escape_string($link, $data[12]);
		$total_mvp = escape_string($link, $data[13]);

		$query = "INSERT INTO warmod_stats VALUES (NULL, '$id', '$usgn', '$ip', '$code', '$name', '$team', '$mix_dmg', '$frags', '$deaths', '$bomb_plants', '$bomb_defusals', '$double', '$triple', '$quadra', '$aces', '$total_mvp')";

		mysqli_query($link, $query);
	}

	mysqli_close($link);
}

if (!isset($argv[1])) {
	$name = $argv[0];
	die("Usage: $name <port>\n");
}

if (!($socket = socket_create(AF_INET, SOCK_DGRAM, 0))) {
	$errorcode = socket_last_error();
	$errormsg = socket_strerror($errorcode);

	die("Could not create socket: [$errorcode] $errormsg\n");
}

echo "Socket created\n";

if (!socket_bind($socket, "0.0.0.0", $argv[1])) {
	$errorcode = socket_last_error();
	$errormsg = socket_strerror($errorcode);

	die("Could not bind socket: [$errorcode] $errormsg\n");
}

echo "Socket bind OK\n";

while (true) {
	$r = socket_recvfrom($socket, $buf, 2048, 0, $svip, $svport);

	$buf = substr($buf, 5);
	$buf = preg_replace("/\x{F3}.\x{00}/", "\n", $buf);
	$buf = explode("\n", $buf);

	foreach ($buf as &$value) {
		$value = preg_split("/\t/", $value);
		$length = sizeof($value);

		if ($length >= 8) {
			send_results($value);
		}
	}
}

socket_close($socket);
?>