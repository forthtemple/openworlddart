**Server**  
The server is written in pure PHP and MySQL with no dependencies. MySQL is used to hold the player positions and also includes messaging. Every second a player polls the server giving the server via json the players position. In return the server gives player positions in the players vicinity and also any messages from players. There is tests for player abuse, such as polling much more often or giving false positions, but this could easily be added in the future.
  
*Installation*  
1. Create a MySQL database such as 'openworld' with a user and password  
2. Run the openworld.sql script under /server on the new database  
3. Change the base_server.php mysql username and password and database to the database you just setup  
4. Change the session URL in your game  eg change:    _session = CLIENT.Session("https://forthtemple.com/secondtemple/serverdart/secondtemple.php");
 
*Modifying game parameters*  
Some of the game specific parameters for the server are specified in secondtemple.php. These paramaters include $MAX_DISTANCE where if it is greater than 0 will only tell players of other players that are within that distance. $CLOSET will show just the closest x number of players. 



