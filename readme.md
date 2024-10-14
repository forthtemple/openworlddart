# Open World for dart
**Intro**  
This is a flutter based gaming engine based upon our existing Openworld repository https://github.com/forthtemple/openworldthreejs which uses threejs. The gaming engine uses three_dart (https://github.com/Knightro63/three_dart (is more up to date then three_dart on pub.dev) originally based on https://pub.dev/packages/three_dart) so it is easy to convert threejs code to three_dart. Because it uses flutter it has the advantage of being cross platform working on Android, iOS, web, Linux and windows and also has hotloading which the game engine takes advantage of being able to add 3D objects to a scene on the fly.

   -converted to flutter threedart
     -works for ios, android and web 
        -will add windows and linux
     -use of hotloading
        - can say add grass around your camera and see it straight away
     -becauses uses threedart largely compatible with threejs so easy to port existing threejs
     
This gaming engine includes two demo games with full source and all resources including blender models, sound, textures freely available in this repository.
One game is set in Jerusalem at the Second Temple 72AD just before a roman invasion. 

<img src="https://github.com/user-attachments/assets/87d3e8a2-fd28-428f-807e-733b0f1bbef2" width="400">

A second game is set in Lindos, Rhodes south of Greece in 1522 just before Sulamains invasion. Both games are available on iTunes.

  -includes two game demos
     -Second temple set in 72ad before roman invasion
     https://apps.apple.com/us/app/ark-uncovered/id6593662011
       -tasked with finding the ark so can defeat the coming enemies
        links on itunes and android
     -Lindos 1522 set in 1522 before sulamain invasion
       https://apps.apple.com/us/app/lindos-1522/id6736712620
        -uncover a spy to save lindos
        links on itunes and android
     -models are all blender 
       -all opensource materials
       
The philosphy of the engine has been to not let the engine get bloated and only include features that most openworld games would require on a smartphone or desktop. For example most openworld games would have animated actors eg a person or monster walking, most would include meshes planes and sprites, sound, light, weather, time of day, maps, music and rooms. But not all would include for example a player inventory system or a combat system or a shop money system, therefore these features are excluded.

      
  Engine not too bloated - only include what most openworld would want
    -not all have 
       inventory
       combat system
       shop system
    -but most will have terrains with a surface to walk on, walls not want to go through and roof
       -animated objects, models, planes sprites
       -sound
       -light
       -weather
       -time of day
       -maps
       -music
       -rooms
      -demo  show how tailor to game eg lindos 1522 has its own combat system that is not part of openworld

Alongside threedarts existing 3D functions such as loading models, lighting, texturing, shaders it includes functions specifically useful in openword games such as:

*Adding 3D objects - animated actors, models, sprites, planes and text*  
  Easy actor animation including duration, looping, cloning existing actors, assigning new textures to cloned actor, sharing animations between actors with the same skeleton, doing one acion and then transitioning to an idling action.  Also includes models that cna be cloned and also reused with different texutre. Allows saving of space where can reuse models and just apply a different skin to it. Sprites and planes can be added 

![image](https://github.com/user-attachments/assets/41a0a204-c41a-4115-9605-f8039a7d1bad)

 on top of threedart openworld engine designed for handling:
 animated actors
   ability for actor wield objects
   share animations between actors with same skeleton
 Easy addition of sprites, planes and text
 sprites, planes, text   

*Collision detection*. 
 The openworld allows for a single terrain model to be defined. In blender you can have multiple groups in the terrain. If the group contains the name surface then it is treated as a surface and 3D objects can easily be placed onto the surface using opendarts rayscaste. Likewise in belnder can define a gorup with the word wall in it and openworld will allow wall detection and likewise roof detection. Roof detection is useful to know if indoors and to turn off the rain in the weather system.
 
   collision system with a main terrain which is used as surface, walls and roofs
    -eg if raining and roof above know not to show rain
    -walls cannot walk into
      -ray intersect
    surface place objects on the terrain eg a rock  

*Spatial features*. 
Alongside using threedarts existing spatial placement of objects in a scene also includes procuedres to make it easy to place objects on a terrain at a certain point, turn and scale objects. All turn values are in degrees iwht 0 degrees being north and 90 being east. It also has functions making it easy to hide 3d objects if the camera gets a certain disance away from an object. Also includes 3d object spatial lerping so possible to move an object along a terrain from one point to another in a given amount of time. Similarly with turning an object it is possible to lerp. Eg turn 90 degrees in 1 second. It also includes functions easy to place an object in front of a camera.

    placement on surface, turn, scale
    object hide if distance way from camera
    -object lerping between two points
    -placing object in front of camera
    -turn lerp eg if faces you isnt sudden

texturing resusing mesh and changing texture  - save space

*Triggers*. 
Openworld also includes a trigger system whereby it is easy to trigger an event if for example the camera gets a certain distance from an npc for example. For example in the following example a cat actor is loaded and a distance trigger is added where if the player goes with 4 meters of the cat it meows.

    Group cat = await OPENWORLD.Actor.createActor('assets/actors/cat.glb', z:0);
    cat.scale.set(0.01,0.01,0.01);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cat,1,1, 0, 4);
    OPENWORLD.Space.objTurn(cat,0);
    scene.add(cat);
    OPENWORLD.BaseObject.setDistanceTrigger(cat, dist: 4);
    cat.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
         OPENWORLD.Sound.play(path: "sounds/meow.mp3", volume: 0.2);
      } else {
      }
    });

The is also a trigger if a 3D object in the scene is clicked. With the trigger you could do something like pick up a wallet.

It also includes custom triggers so for example you could create a trigger when an npc dies

 trigger system 
   -if certain distance will trigger eg if go near a monster cna make attack
   -trigger if click/touch an object
      -eg click on a wallet on the ground
   -custom triggers 
      eg your own trigger for when an npc dies   

      
*Movement system*. 
Uses flutter joystick (https://pub.dev/packages/flutter_joystick) used in confjuction with threejs joystick so can move using a smartphone.  Includes swiping screen to turn and swiping up and down for pitch

Also ability to use keyboard. threedart has been modified so keyboard capture can be turned off from dom and allow typing into a flutter dialog for example


   -with flutter joystick or keyboard on web
     -works on keyboard or screenonly

*Mob System*  
System to make it easy for npcs especially actors eg an animated guard. For example can set an actor to randomly walk around a point of a given distance and frequency eg a dog walking around randomly. Also includes move to loop where can have an npc walking through a set of positions over and over eg a guard walking up and down a corridor.  Also include features to make it easy to add random chatter to an npc so for example 

<img src="https://github.com/user-attachments/assets/63442d1c-8c3c-4ecd-9d29-624e784c2182" width="256">

Also add a speech so an npc can say multiple sentences

 mob system
    ability to put text on objects eg speech for actors
       chatter
       speech
    random walking around point
    movingto

*Weather*  
Weather is added to the Openworld engine and includes wind, rain, cloud and fog. It includes lerping so it is possible gradually transition from clear sky to cloudy or rain to fog. It also includes a random weather generator where you can specify the probabity in a given day it will rain, be cloudy, be windy or foggy.

<img src="https://github.com/user-attachments/assets/bd0a4334-5ca1-4d97-b179-33226fa7c2f0" width="356">

 weather system
   wind, rain, fog, cloud

*Time*     
Time of day can be specified using a skymat shader that allows for specifying the azimuth so can generate sunsets, sunrises, noon, night. Also the day length can be specified. For example 1 hour to equal 24 hours. Therefore a full day can occur in one hour. Will change ambience  as well so at night the terrain will be dark. Also incorporated into weather so for example if its foggy at night the fog is black while during the day it is grey.

![image](https://github.com/user-attachments/assets/814bbed1-a672-4298-8d06-ee1d7ddc7545)

![image](https://github.com/user-attachments/assets/7bdf6eba-8e67-4ab0-8a2d-d5d8d868cbf7)

time system
   night and day - light

*Light*  
Openworld includes features like specifying that a light should be switched on at night and turned off during the day. Also allows light to flicker and also to lerp turning a light on so its not sudden.

light system
   flicker, view only night or day

*Sound*  
Sound system includes a pool of flutter audioplayers which can be reused when its finished playing. The pool also allows all audioplayers to be silenced when close the game and reactivated when the game is restarted. The sound system also includes features like volume, looping, fading and also delay.

sound system
    -can load pool of audio taht can switch off and mute when app is deactivated
    -typical things like volume, looping

*Object Selection*  

 selection system so can select an item eg a wallet on the ground
 
 usage of delays eg have actor jump, then 5 seconds later play laugh sound
 persistence
   can store data so when restart app will remember game state
 rooms where define an area for a room and 
    can trigger entry and exit of room eg have butcher say hello when someone enters
    room sound eg sound fo a smithy when enter
    indoors when indoors then not effected by rain
 maps where just specify two points on a map ie pixel pos and world pos and can tranlate your position onto map
    -multipel maps and will choose the one at end so can have maps eg for a city and a global map
    -exmaples of display of maps in two demos
music where cna specify mutple tunes that play with a random probability
config json file
  -can define objects as a text file and set position for the defined object multiple times
  -pool system eg for vegetation - define say 50 trees and thousands of points and system will place vegetation in front of camera and hide those further away
    
some shaders like water, fire, flares
basic multi player
  - just position, turn and who, and simple actions eg way
       also speech - php

-demos made with blender modelling tool
  -mesh editing, animations, texturing in blender
 
A minimalistic framework to make it easier creating an multi user open world with threejs for both smartphones and desktops

To demonstrate the framework, a demo has been made for the Second Temple, the temple that was at the center of judaism before 77AD. It is where the dome of the rock currently stands on the temple mount in Jerusalem. In the demo you can explore the Second Temple. This framework also includes the original blender models for the temple and the actors in the demo. It also demonstrates a multi user server. The demo should work on smartphone browsers (tested on iPhone and iPad 9.3) and desktops.

Live Demo http://www.forthtemple.com/secondtemple

Click 'connect' to connect to the server

![alt tag](http://www.forthtemple.com/secondtemple/screenshots/temple200.jpg)  ![alt tag](http://www.forthtemple.com/secondtemple/screenshots/templeiii200.jpg)


**Installation**  
If you unzip the distrubution under your webserver root then browsing http://localhost/openworldthreejs/web/secondtemple/ should display the Second Temple.

For instructions on setting up the server refer to the server section at the end.

**Intro**  
The framework revolves around a main world model that contains surfaces and walls that the framework detects to allow a user to walk around a model. The demo includes a blender model for the second temple (/models/secondtemple/temple/temple.blend). The minimalistic framework is in the javascript file /web/secondtemple/openworldjs/openworld.js and has functions that make it possible to work with world coordinates and directions instead of local coordinates and rotations. For example the coordinates 5,4,0 means 5,4 in the xy plane and height zero off the surface of the model. Also direction can be specified with 90 degrees being east, 180 being south.

The openworld framework also includes an all purpose controller with virtual joystick that works on a smartphone. It also works with a keyboard and mouse.

There is also a server written in PHP and MySQL that allows multiple users to interact on the server. It has a base server that can be the basis for other multi user open worlds.


**Using blender models**  

terrain is exported to obj, use strip
  - seems to work better in terms of intersections
actor, models are export as glb from blender

All the models in the demos are created using Blender. There are included in the repository. In the demo, models are exported as wavefront 'obj' models since they allow for multiple texturing. For actors they are exported from Blender as json models since they include animations which json allows for but obj does not.

If you open /models/secondtemple/temple/temple.blend notice the multiple meshes. Notice that some have the word wall and some surface in them.

![alt tag](http://www.forthtemple.com/secondtemple/screenshots/wallsurface.jpg) 

A surface mesh will be intersected by the open world framework to determine the ground. Walls are also detected to stop players walking through walls. Also notice the units of distance in the blender model are around about 1 meter. Also Z is up. Also some meshes are hidden in order to reduce the size. To export the temple.blend model to obj, select all the meshes you wish to export (will exclude the hidden ones) and then export the obj and then click on 'selection only' to only export the selected meshes.

![alt tag](http://www.forthtemple.com/secondtemple/screenshots/exportobj.jpg) 

To export an actor like a priest (/models/secondtemple/priest/priest.blend) to json make sure the Blender export io_three is placed under the directory Blender\2.xx\scripts\addons. Exporting to json can be fiddly where you must first select the mesh you wish to export like selecting body below:

![alt tag](http://www.forthtemple.com/secondtemple/screenshots/jsonselectmesh.jpg) 

And then when you export to json you must specify all the correct flags once to export so that it is not missing animation, bone, texture information. These are the ones that work:

![alt tag](http://www.forthtemple.com/secondtemple/screenshots/exportjsonsmall.jpg) 

**Server**  
The server is written in pure PHP and MySQL with no dependencies. MySQL is used to hold the player positions and also includes messaging. Every second a player polls the server giving the server via json the players position. In return the server gives player positions in the players vicinity and also any messages from players. There is tests for player abuse, such as polling much more often or giving false positions, but this could easily be added in the future.
  
*Installation*  
1. From the distribution copy the server directory to your host that has PHP and MySQL. It should be the same directory as your index.html file. Eg  
     - index.html  
     - actors  
     - server  
     - models  
     - openworldjs  
2. Create a MySQL database such as 'openworld' with a user and password  
3. Run the openworld.sql script under /server on the new database  
4. Change the base_server.php mysql username and password and database to the database you just setup  
  
Now when you click on 'Connect' when browse to index.html it should connect you to the server.

*Modifying game parameters*  
Some of the game specific parameters for the server are specified in secondtemple.php. These paramaters include $MAX_DISTANCE where if it is greater than 0 will only tell players of other players that are within that distance. $CLOSET will show just the closest x number of players. 



