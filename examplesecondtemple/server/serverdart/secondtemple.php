<?php

$MAX_DISTANCE=-1;//10;// Players can be any distance away 
$CLOSEST=4;           // Only tell the player of the closest 4 players
$LOG_MSG=1;           // Log server

$welcome_message="<font color='yellow'>Welcome to Second Temple</font>";
$alone_message="<b>You the only player on</b>";


// When a person logs on this is called to set the spawn position
// Here just try to make sure players aren't all on top of eachother
function game_spawn_position()
{
	global $ret;
	global $position;
	   // normal spawn pos is 8.59 1.31
	if ($ret["num_players"]>1&&abs(8.59-$position[0]->x)+abs(1.31-$position[0]->y)<0.2) {
		// Player is entering so make sure players are not on top of eachother so make slightly random
		$ret["player_pos"]=array($position[0]->x+random()*0.5-0.25,$position[0]->y+random()*0.5-0.25,0);
	}    
}

function game_action()
{
	global $position;
	if ($position[0]->action=="wave") {
		tell_message($position[0]->name,"You wave", userid());
		shout_message_exclude($position[0]->name,$position[0]->name." waves",userid());
	}
}

include_once "base_server.php";


?>
