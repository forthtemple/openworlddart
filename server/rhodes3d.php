<?php

$MAX_DISTANCE=-1;//10;// Players can be any distance away 
$CLOSEST=4;           // Only tell the player of the closest 4 players
$LOG_MSG=1;           // Log server

$welcome_message="Welcome to Lindos 1522";
$alone_message="You're the only player on";


// When a person logs on this is called to set the spawn position
// Here just try to make sure players aren't all on top of eachother
function game_spawn_position()
{
	global $ret;
	global $position;
	   // normal spawn pos is 8.59 1.31
	if ($ret["num_players"]>1&&abs(8.59-$position->x)+abs(1.31-$position->y)<0.2) {
		// Player is entering so make sure players are not on top of eachother so make slightly random
		$ret["player_pos"]=array($position->x+random()*0.5-0.25,$position->y+random()*0.5-0.25,0);
	}    
}

// Simple game action like waving
function game_action()
{
	global $position;
	if ($position->action=="wave") {
		tell_message($position->name,"You wave", userid());
		shout_message_exclude($position->name,$position->name." waves",userid());
	}
}

include_once "base_server.php";


?>
