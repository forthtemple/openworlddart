<?php

define("LOG_GENERAL",0);
define("LOG_ENTER",1);    // New player is created in database
define("LOG_EXIT",2);     // Player has disconnected
define("LOG_DIED",3);     // Player removed because inactive
define("LOG_WELCOME",4);  // Player may have same session but reentered

if (!$_POST["position"]) {
	exit;
}

$link = mysql_connect('localhost', 'skinhat_open','Zk.JH=WU0snk');
if (!$link) {
		echo 'Could not connect to mysql';
		exit;
}

if (!mysql_select_db('skinhat_open2', $link)) {
		echo 'Could not select database';
		exit;
}
error_reporting(E_ALL ^ E_DEPRECATED ^ E_WARNING);  // Stop deprecated messages

session_start();
/*
if(date_default_timezone_get()==ini_get('date.timezone'))
	date_default_timezone_set("Europe/London"); // get rid of strtotime error
*/
// server should keep session data for AT LEAST 1 hour
ini_set('session.gc_maxlifetime', 3600);

// each client should remember their session id for EXACTLY 1 hour
session_set_cookie_params(3600);



// userid of the current player who has connected to server
function userid()
{
	global $link;
	$sql    = 'SELECT * FROM user WHERE session="'.session_id().'"';	 
	$result =mysql_query($sql, $link);	 
	$row =  mysql_fetch_assoc($result);		
	return $row['id'];

}

// Shout from a player
function shout_message($name, $msgi)
{	
	global $link;

	if (!$name)
	   $sql    = 'INSERT INTO msg (fromuserid,name,msg,time ) values ("-1","'.$name.'","'.$msgi.'",now(3))';//me="'.$position[0]->name.'", x="'.$position[0]->x.'", y="'.$position[0]->y.'", z="'.$position[0]->z.'", turn="'.$position[0]->turn.'", action="'.$position[0]->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
	else 
	   $sql    = 'INSERT INTO msg (fromuserid,name,msg,time ) values ("'.userid().'","'.$name.'","'.$msgi.'",now(3))';//me="'.$position[0]->name.'", x="'.$position[0]->x.'", y="'.$position[0]->y.'", z="'.$position[0]->z.'", turn="'.$position[0]->turn.'", action="'.$position[0]->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
    mysql_query($sql, $link);
}

// Broadcast from server to everyone
function broadcast_message($msgi)
{
	shout_message("",$msgi);
}

function shout_message_exclude($name, $msgi, $excludeuserid)
{
	global $link;

	if (!$name)
		$sql    = 'INSERT INTO msg (fromuserid,excludeuserid,msg,time ) values ("-1","'.$excludeuserid.'","'.$msgi.'",now(3))';//me="'.$position[0]->name.'", x="'.$position[0]->x.'", y="'.$position[0]->y.'", z="'.$position[0]->z.'", turn="'.$position[0]->turn.'", action="'.$position[0]->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
	else 
		$sql    = 'INSERT INTO msg (fromuserid,name, excludeuserid,msg,time ) values ("'.userid().'","'.$name.'","'.$excludeuserid.'","'.$msgi.'",now(3))';//me="'.$position[0]->name.'", x="'.$position[0]->x.'", y="'.$position[0]->y.'", z="'.$position[0]->z.'", turn="'.$position[0]->turn.'", action="'.$position[0]->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
   
    mysql_query($sql, $link);
}

// Tell everyone the message except excludeuserid
function broadcast_message_exclude($msgi, $excludeuserid)
{
	shout_message_exclude("",$msgi,$excludeuserid);
}

// Tell the message only to touserid
function tell_message($name, $msgi, $touserid)
{
	global $link;

	if (!$name)
		$sql    = 'INSERT INTO msg (fromuserid,touserid,msg,time ) values ("-1","'.$touserid.'","'.$msgi.'",now(3))';//me="'.$position[0]->name.'", x="'.$position[0]->x.'", y="'.$position[0]->y.'", z="'.$position[0]->z.'", turn="'.$position[0]->turn.'", action="'.$position[0]->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
	else 
		$sql    = 'INSERT INTO msg (fromuserid,name, touserid,msg,time ) values ("'.userid().'","'.$name.'","'.$touserid.'","'.$msgi.'",now(3))';//me="'.$position[0]->name.'", x="'.$position[0]->x.'", y="'.$position[0]->y.'", z="'.$position[0]->z.'", turn="'.$position[0]->turn.'", action="'.$position[0]->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
   
    mysql_query($sql, $link);

}
//if (/*is_ajax()&&*/$_POST["position"]) {

	$position=json_decode($_POST["position"]);

	//$MAX_DISTANCE=10;

	$commands=$position[0]->commands;

	// Remove disconnected player
	if (in_array("disconnect",$commands)){//isset($position[0]->disconnect)&&$position[0]->disconnect) {
        broadcast_message($position[0]->name." left the game");
        if ($LOG_MSG) {
			$sql    = 'INSERT INTO log (userid, type,ip,msg) values ("'.userid().'",  "'.LOG_EXIT.'","'. $_SERVER['REMOTE_ADDR'].'","'.$position[0]->name.' exited")';
			mysql_query($sql, $link);
		}
		$sql    = 'DELETE FROM user WHERE session="'.session_id().'"';//name="'.$position[0]->name.'"';
		$result = mysql_query($sql, $link);

		return;
	}
	// Remove old dead players - players who have done nothing for 5 minutes
	$sql    = 'SELECT * FROM user WHERE now(3)-last_active>5*60';//name="'.$position[0]->name.'"';
	$result = mysql_query($sql, $link);
	while ($row = mysql_fetch_assoc($result)) {
		$sql="DELETE FROM user WHERE id='".$row['id']."'";
		mysql_query($sql,$link);
	    if ($LOG_MSG) {
			$sql    = 'INSERT INTO log (userid, type,ip,msg) values ("'.$row['id'].'","'.LOG_DIED.'","'. $_SERVER['REMOTE_ADDR'].'","'.$row['name'].' died")';
			mysql_query($sql, $link);
		}
	}

	// insert user messages
	if (isset($position[0]->msg)&&$position[0]->msg&&count($position[0]->msg)>0) {
		foreach ($position[0]->msg as $msgi) {
		    shout_message($position[0]->name,$msgi);
		}
	}

    if ($position[0]->action) {
    	game_action();  
    }

	$sql    = 'SELECT * FROM user WHERE session="'.session_id().'"';//name="'.$position[0]->name.'"';
	$result = mysql_query($sql, $link);

	$msg=array();
	$welcome=in_array("connecting",$commands);
	if ( !mysql_num_rows ( $result )) {
		// Player is not in the database so add him
		$sql    = "INSERT INTO user (name,session,last_active,x,y,z,turn) values ('".$position[0]->name."','".session_id()."',now(3),0,0,0,0)";
		mysql_query($sql, $link);
		if ($LOG_MSG) {
		 	$sql    = 'INSERT INTO log (userid, type,ip,msg) values ("'.userid().'","'.LOG_ENTER.'","'. $_SERVER['REMOTE_ADDR'].'","'.$position[0]->name.' entered")';
		 	mysql_query($sql, $link);
		 	$welcome=true;
		}

	} else {
		// Player already in the database.
		// Fetch him any new messages
		$row =  mysql_fetch_assoc($result);
		$sql    = 'SELECT * FROM msg WHERE time>"'.$row['last_active'].'"';

		$result = mysql_query($sql, $link);

		while ($row = mysql_fetch_assoc($result)) {

			// if touserid only tell touserid
			// if excludeuserid then tell everyone except excludeuserid
			if (($row['touserid']&&userid()==$row['touserid'])||
				(!$row['touserid']&&$row['excludeuserid']!=userid())) {
					$msg[]=array($row['fromuserid'],$row['msg']);
			}
		}		


	}

	// Update your location in the database
	$sql    = 'UPDATE user SET name="'.$position[0]->name.'", x="'.$position[0]->x.'", y="'.$position[0]->y.'", z="'.$position[0]->z.'", turn="'.$position[0]->turn.'", action="'.$position[0]->action.'",last_active=now(3) where session="'.session_id().'"';
    mysql_query($sql, $link);
	
	// Find players close by
	if ($MAX_DISTANCE>0)
		$ex='" AND abs(x- '.$position[0]->x.')<'.$MAX_DISTANCE.' AND abs(y- '.$position[0]->y.')<'.$MAX_DISTANCE;
	else
		$ex="";
	if ($CLOSEST>0) 
		$ex.=' ORDER BY GREATEST(abs(x- '.$position[0]->x.'),abs(y- '.$position[0]->y.')) LIMIT '.$CLOSEST;
	$sql    = 'SELECT * FROM user WHERE session<>"'.session_id().'" '.$ex ;
	//log_text($sql);
	$result = mysql_query($sql, $link);


	if (!$result) {
		echo "DB Error, could not query the database\n";
		echo 'MySQL Error: ' . mysql_error();
		exit;
	}
	
	
	$ret=array();

	// Tell the player of players close by
	$ret["users"]=array();
	if (mysql_num_rows ( $result )){//||count($msg)>0) {

		while ($row = mysql_fetch_assoc($result)) {
			$ret["users"][]=array($row['id'],$row['name'],$row["x"],$row["y"],$row["z"],$row["turn"], $row["action"]);
		}
 
	} 
	// Tell the player how many players are on
	$sql    = 'SELECT *  FROM user ';
	$result = mysql_query($sql, $link);
    $ret["num_players"]=mysql_num_rows ( $result );

    // Give a new player a welcome message
	if ($welcome) {
		 if ($LOG_MSG) {
			$sql    = 'INSERT INTO log (userid,type,ip,msg) values ("'.userid().'","'.LOG_WELCOME.'","'. $_SERVER['REMOTE_ADDR'].'","'.$position[0]->name.' welcome")';
			mysql_query($sql, $link);
		}
        shout_message_exclude($position[0]->name,$position[0]->name." enters the game", userid(), $link);

		$msg[]=array(-1,$welcome_message);//"<font color='yellow'>Welcome to Second Temple</font>");
		if ($alone_message&&mysql_num_rows ( $result )==1)
			$msg[]=array(-1,$alone_message);
	}    

	// Tell the player whos on if they ask
    if (in_array("who",$commands)){//$position[0]->who) {
        	$ret["who"]=array();
			while ($row = mysql_fetch_assoc($result)) {
				$ret["who"][]=$row['name'];
			}

    }
    if ($welcome)
    	game_spawn_position();

	$ret["msg"]=$msg;


	echo json_encode($ret);//["users"]);

//}

function random()
{   // auxiliary function
    // returns random number with flat distribution from 0 to 1
    return (float)rand()/(float)getrandmax();
}

function log_text($msg)
{
	$file = 'people.txt';

  file_put_contents($file,$msg);
}
/*
function log_message($type, $msg,$link)
{
		 $sql    = 'INSERT INTO log (type,msg) values ("'.$type.'","'.$msg.'")';
		 mysql_query($sql, $link);

}*/
/*
function is_ajax() {
		return true;//isset($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest';
}
*/

	?>