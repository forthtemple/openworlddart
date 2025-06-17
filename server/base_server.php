<?php

define("LOG_GENERAL",0);
define("LOG_ENTER",1);    // New player is created in database
define("LOG_EXIT",2);     // Player has disconnected
define("LOG_DIED",3);     // Player removed because inactive
define("LOG_WELCOME",4);  // Player may have same session but reentered


if (!$_POST["position"]) {
	//print("xxx");
	exit;
}

$link = mysqli_connect('localhost', '','');
if (!$link) {
		echo 'Could not connect to mysql';
		exit;
}

if (!mysqli_select_db($link, 'openworld')) {
		echo 'Could not select database';
		exit;
}
error_reporting(E_ALL ^ E_DEPRECATED ^ E_WARNING);  // Stop deprecated messages

session_start();

// server should keep session data for AT LEAST 1 hour
ini_set('session.gc_maxlifetime', 3600);

// each client should remember their session id for EXACTLY 1 hour
session_set_cookie_params(3600);



// userid of the current player who has connected to server
function userid()
{
	global $link;
	$sql    = 'SELECT * FROM user WHERE session="'.session_id().'"';	 
	$result =mysqli_query($link, $sql);	 
	$row =  mysqli_fetch_assoc($result);		
	return $row['id'];

}

// Shout from a player
function shout_message($name, $msgi)
{	
	global $link;

	if (!$name)
	   $sql    = 'INSERT INTO msg (fromuserid,name,msg,time ) values ("-1","'.$name.'","'.$msgi.'",now(3))';//me="'.$position->name.'", x="'.$position->x.'", y="'.$position->y.'", z="'.$position->z.'", turn="'.$position->turn.'", action="'.$position->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
	else 
	   $sql    = 'INSERT INTO msg (fromuserid,name,msg,time ) values ("'.userid().'","'.$name.'","'.$msgi.'",now(3))';//me="'.$position->name.'", x="'.$position->x.'", y="'.$position->y.'", z="'.$position->z.'", turn="'.$position->turn.'", action="'.$position->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
    mysqli_query($link, $sql);
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
		$sql    = 'INSERT INTO msg (fromuserid,excludeuserid,msg,time ) values ("-1","'.$excludeuserid.'","'.$msgi.'",now(3))';//me="'.$position->name.'", x="'.$position->x.'", y="'.$position->y.'", z="'.$position->z.'", turn="'.$position->turn.'", action="'.$position->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
	else 
		$sql    = 'INSERT INTO msg (fromuserid,name, excludeuserid,msg,time ) values ("'.userid().'","'.$name.'","'.$excludeuserid.'","'.$msgi.'",now(3))';//me="'.$position->name.'", x="'.$position->x.'", y="'.$position->y.'", z="'.$position->z.'", turn="'.$position->turn.'", action="'.$position->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
   
    mysqli_query($link, $sql);
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
		$sql    = 'INSERT INTO msg (fromuserid,touserid,msg,time ) values ("-1","'.$touserid.'","'.$msgi.'",now(3))';//me="'.$position->name.'", x="'.$position->x.'", y="'.$position->y.'", z="'.$position->z.'", turn="'.$position->turn.'", action="'.$position->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
	else 
		$sql    = 'INSERT INTO msg (fromuserid,name, touserid,msg,time ) values ("'.userid().'","'.$name.'","'.$touserid.'","'.$msgi.'",now(3))';//me="'.$position->name.'", x="'.$position->x.'", y="'.$position->y.'", z="'.$position->z.'", turn="'.$position->turn.'", action="'.$position->action.'",last_active=now(), ipaddress="'. $_SERVER['REMOTE_ADDR'].'" where session="'.session_id().'"';
   
    mysqli_query($link, $sql);

}
//if (/*is_ajax()&&*/$_POST["position"]) {

	//echo "nn".$_POST["position"];

	$position=json_decode($_POST["position"]);


	//print_r($position);
	//$MAX_DISTANCE=10;

	$commands=$position->commands;

	print_r($commands);

	
	// Remove disconnected player
	if (in_array("disconnect",$commands)){  //isset($position->disconnect)&&$position->disconnect) {
        broadcast_message($position->name." left the game");
        if ($LOG_MSG) {
			$sql    = 'INSERT INTO log (userid, type,ip,msg) values ("'.userid().'",  "'.LOG_EXIT.'","'. $_SERVER['REMOTE_ADDR'].'","'.$position->name.' exited")';
			mysqli_query($link, $sql);
		}
		$sql    = 'DELETE FROM user WHERE session="'.session_id().'"';//name="'.$position->name.'"';
		$result = mysqli_query($link, $sql);

		//echo "vooot";
		return;
	}
	// Remove old dead players - players who have done nothing for 5 minutes
	$sql    = 'SELECT * FROM user WHERE now(3)-last_active>5*60';//name="'.$position->name.'"';
	$result = mysqli_query($link, $sql);
	while ($row = mysqli_fetch_assoc($result)) {
		$sql="DELETE FROM user WHERE id='".$row['id']."'";
		mysqli_query($sql,$link);
	    if ($LOG_MSG) {
			$sql    = 'INSERT INTO log (userid, type,ip,msg) values ("'.$row['id'].'","'.LOG_DIED.'","'. $_SERVER['REMOTE_ADDR'].'","'.$row['name'].' died")';
			mysqli_query($link, $sql);
		}
	}

	// insert user messages
	// This is set from the client 
	if (isset($position->msg)&&$position->msg&&count($position->msg)>0) {
		foreach ($position->msg as $msgi) {
		   // shout_message($position->name,$msgi);
		   tell_message($position->name,"You say:".$msgi, userid());
		   shout_message_exclude($position->name,$position->name." say:".$msgi,userid());
		}
	}

    // This action is from the client
    if ($position->action) {
    	game_action();  
    }

	$sql    = 'SELECT * FROM user WHERE session="'.session_id().'"';//name="'.$position->name.'"';
	$result = mysqli_query($link, $sql);

	$msg=array();
	$welcome=in_array("connecting",$commands);
	if ( !mysqli_num_rows ( $result )) {
		// Player is not in the database so add him
		$sql    = "INSERT INTO user (name,session,last_active,x,y,z,turn) values ('".$position->name."','".session_id()."',now(3),0,0,0,0)";
		mysqli_query($link, $sql);
		if ($LOG_MSG) {
		 	$sql    = 'INSERT INTO log (userid, type,ip,msg) values ("'.userid().'","'.LOG_ENTER.'","'. $_SERVER['REMOTE_ADDR'].'","'.$position->name.' entered")';
		 	mysqli_query($link, $sql);
		 	$welcome=true;
		}

	} else {
		// Player already in the database.
		// Fetch him any new messages - ignore any that are older than last time player active so dont get repeats
		$row =  mysqli_fetch_assoc($result);
		$sql    = 'SELECT * FROM msg WHERE time>"'.$row['last_active'].'"';

		$result = mysqli_query($link, $sql);

		while ($row = mysqli_fetch_assoc($result)) {

			// if touserid only tell touserid
			// if excludeuserid then tell everyone except excludeuserid
			if (($row['touserid']&&userid()==$row['touserid'])||
				(!$row['touserid']&&$row['excludeuserid']!=userid())) {
					$msg[]=array($row['fromuserid'],$row['msg']);//,$row['name']);
			}
		}		


	}


	// Update your location in the database
	$sql    = 'UPDATE user SET name="'.$position->name.'", x="'.$position->x.'", y="'.$position->y.'", z="'.$position->z.'", turn="'.$position->turn.'", action="'.$position->action.'",last_active=now(3) where session="'.session_id().'"';
    mysqli_query($link, $sql);
	
	// Find players close by
	if ($MAX_DISTANCE>0)
		$ex='" AND abs(x- '.$position->x.')<'.$MAX_DISTANCE.' AND abs(y- '.$position->y.')<'.$MAX_DISTANCE;
	else
		$ex="";
	if ($CLOSEST>0) 
		$ex.=' ORDER BY GREATEST(abs(x- '.$position->x.'),abs(y- '.$position->y.')) LIMIT '.$CLOSEST;
	$sql    = 'SELECT * FROM user WHERE session<>"'.session_id().'" '.$ex ;
	//log_text($sql);
	$result = mysqli_query($link, $sql);


	if (!$result) {
		echo "DB Error, could not query the database\n";
		echo 'MySQL Error: ' . mysqli_error();
		exit;
	}
	
	
	$ret=array();

	// Tell the player of players close by
	$ret["users"]=array();
	if (mysqli_num_rows ( $result )){//||count($msg)>0) {

		while ($row = mysqli_fetch_assoc($result)) {
			$ret["users"][]=array($row['id'],$row['name'],$row["x"],$row["y"],$row["z"],$row["turn"], $row["action"]);
		}
 
	} 
	// Tell the player how many players are on
	$sql    = 'SELECT *  FROM user ';
	$result = mysqli_query($link, $sql);
    $ret["num_players"]=mysqli_num_rows ( $result );

    // Give a new player a welcome message
	if ($welcome) {
		 if ($LOG_MSG) {
			$sql    = 'INSERT INTO log (userid,type,ip,msg) values ("'.userid().'","'.LOG_WELCOME.'","'. $_SERVER['REMOTE_ADDR'].'","'.$position->name.' welcome")';
			mysqli_query($link, $sql);
		}
        shout_message_exclude($position->name,$position->name." enters the game", userid(), $link);

		$msg[]=array(-1,$welcome_message);//"<font color='yellow'>Welcome to Second Temple</font>");
		if ($alone_message&&mysqli_num_rows ( $result )==1)
			$msg[]=array(-1,$alone_message);
	}    

	// Tell the player whos on if they ask
    if (in_array("who",$commands)){//$position->who) {
        	$ret["who"]=array();
			while ($row = mysqli_fetch_assoc($result)) {
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


	?>
