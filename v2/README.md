# Open World for dart
This a draft I'm writing for the future version of the openworld library so please ignore for the time being.

This library has feature to make openworld games with the dart package threejs. This is for flutter and is based upon the existing threejs openworld repository [openworldthreejs](https://github.com/forthtemple/openworldthreejs). Some of the advantages of using flutter for an openworld game is ease of making the game multiplatform with one code base, the huge number of flutter widgets that can be incorportated into the game and hotloading making it possible to add say grass to a scene, hit hotload and see it appear in your game very quickly. 

This version of the library is an updated version of the previous openworld library which used [three_dart](https://github.com/wasabia/three_dart) instead of [three_js](https://github.com/Knightro63/three_js)/ Threejs is more up to date and have found it works better across platforms. This library has been updated to work better on desktops. To showcase this there is a new game on steam https://store.steampowered.com/app/4067520/Second_Temple/ that uses the library. It is available on windows, mac, linux, iphone and android and web.

The openworld library has many new features such terrain levels which allows for say something like a multi story building, making is possible to walk around different floors. Also shadows have been added for models and actors. Also a new vegetation library the uses sprites to generate realistic vegetation like grass and shrubs cheaply. It also adds detail to the ground. Also treesusing sprites and plains with transparent textures allowing for cheap and realistic looking trees. The water2 object of threejs has been modified to be faster being able to to skip reflection updates and also choose which objects to reflect. There is also an asset encrypter so that when you deploy a game, your assets have some protection. The config class has been updated so that pooled objects are not only created from a static text file but also runtime. This allows for say crowds of people with say 1000 actors and only show say 50 near the camera. There is also actor animation throttling so that when there are a lot of actors the CPU doesn't speend too much time on actor animations. Also new actor animations can be created by combining other animations. The library also has the addition of extra callbacks. For example allow for say an npc o give a speech and when finished run a callback to have the npc jump up in the air. For large meshes, mesh intersection calculations for walking on a terrain or finding a wall can get expensive and the library has optimization of intersections including caching height positions and using and using bounding boxes for walls so interesctions. Run time obstacles have also been added so you can block off an area and then reenable it such as for a door that has been closed. For multiple doors, a doorsway class has have been added to allows that multiple doors eg two grand doors to be opened or closed with one call coding to manually opening each door. Keyboard callbacks have been added so that for a keypress a callback can be conditionally called for example when a player in near a horse and presses 'E' to mount hte horse. Another feature is fading objects as they move away from the camera rather than abruplty making them invisible. Simnilarly lights can also be dimmed as they move away from the camera. 

new features
levels eg have a building with multi stories and walk 
   can use mutlilevel portals to go between levels
shadows
vegetation  fast sprites
trees fast sprite
water3 customized faster - skip frames to update reflection - choose what objects to include in the reflection
asset encrypter
   develop as normal with protected folder but can encrypt for release
    It has been designed to allow development in debug mode and simple encyprtion into an asset that can be deployed with the release.
config can be used runtime so can say have a crowd of 1000 actors and only show those close to the camera

addition of callbacks eg moveltoop can say walk and do an action and callback eg walks to a house, knocks and play knocking sound
  speech
  moveto
  portals
optimized surface, wall intersections, touch intersections

obstacles, doorways, keyboardcallbacks

lerp opacity for objects so fade
light lerp so lights can fade instead of suddenly turning off

create new animations on the fly - if squating and have a look left animation can have squatting and looking left

iosntalced models and instanced sprite (billboard) make easy for lots of models so dont have huge number of render calls

lerp across surfaces

normal2world eg a car going down a hill will pitch down

multitext

This small sample code demonstrates a small part of openworld showing how to add a skydome but suggest you look at the example games in github to see how the library works in its entirety with weather, actor animations, terrains, chatter etc.


### Import

```
import 'package:openworld/shaders/SkyShader.dart';
import 'package:openworld/openworld.dart' as OPENWORLD;
```

### Usage

```
    // Example of adding skydome to openworld
    var skyGeo = THREE.SphereGeometry(-1000, 32, 15);

    var skyMat = new THREE.ShaderMaterial(SkyShader);

    var sky = THREE.Mesh(skyGeo, skyMat);

    scene.add(sky);

    skyMat.uniforms = {
      'turbidity': {'value': 10.0},
      'reileigh': {'value': 2.0},
      'mieCoefficient': {'value': 0.005},
      'mieDirectionalG': {'value': 0.8},
      'luminance': {'value': 1.0},
      'inclination': {'value': 0},
      'azimuth': {'value': 0},
      'opacity': {'value': 1.0},
      'sunPosition': {'value': THREE.Vector3(0, 100, 0)}
    };

    // Add Sun
    var sunSphere = THREE.Mesh(THREE.SphereGeometry(20000, 16, 8),
        THREE.MeshBasicMaterial({'color': THREE.Color.fromHex(0xffffff)}));
    sunSphere.position.y = -700000;
    sunSphere.visible = true;
    var sunlight = new THREE.SpotLight(0x888888);//ffffff);
    sunlight.intensity = 0.4;
    sunlight.penumbra = 1;
    sunSphere.add(sunlight);

    scene.add(sunSphere);

    // Openworld will change sky depending on time of day
    OPENWORLD.Time.init(sunSphere, skyMat, ambience);

```   
This gaming library includes two demo games with full source and all resources including blender models, sound, textures being freely available in this repository.

One game is set in Jerusalem at the Second Temple 65AD. 

<img src="https://github.com/user-attachments/assets/87d3e8a2-fd28-428f-807e-733b0f1bbef2" width="400"/>

![secondtemple](https://github.com/user-attachments/assets/49e647e9-a4b4-463b-a97a-8012a9cdcf60)

This game is not only available in this repository but also on <a href='https://store.steampowered.com/app/4067520/Second_Temple/'>Steam</a> (Windows, Mac, Linux). <a href="https://apps.apple.com/us/app/ark-uncovered/id6593662011">iTunes</a> (iOS, macOS) on  <a href="https://www.amazon.com/gp/mas/dl/android?p=com.forthtemple.secondtemple">Amazon</a> (Android), <a href='https://chatgpt.forthtemple.com/secondtemple/'>web</a>, <a href="https://snapcraft.io/secondtemple">snap</a> (Linux) and <a href='https://www.youtube.com/watch?v=v63XYmFEgj8'>Youtube</a>

[![secondtemple](https://snapcraft.io/secondtemple/badge.svg)](https://snapcraft.io/secondtemple)

A second game is set in Lindos, Rhodes south of Greece in 1522 just before Sulamains invasion.

![image](https://github.com/user-attachments/assets/be650f03-b6dd-4156-9a4c-ba32e5a1edca)

It is also available on <a href="https://apps.apple.com/us/app/lindos-1522/id6736712620">iTunes</a> (iOS, macOS) on  <a href="https://www.amazon.com/gp/mas/dl/android?p=com.forthtemple.rhodes3d">Amazon</a> (Android), <a href="https://snapcraft.io/rhodes3d">snap</a> (Linux), <a href='https://chatgpt.forthtemple.com/rhodes3d'>web</a> and <a href='https://www.youtube.com/watch?v=-xjAiFQzZRM'>Youtube</a>.

[![rhodes3d](https://snapcraft.io/rhodes3d/badge.svg)](https://snapcraft.io/rhodes3d)
-------

The philosophy of the engine it should not get bloated and only include features that typical openworld games would require on a smartphone or desktop. For example most openworld games will have animated actors, such as a person or monster walking. Most openworld games would include models,  planes and sprites, sound, light, weather, time of day, maps, music and rooms. But not all would include, for example, a players inventory system or a combat system or a monetary system. So these less used features are excluded.

Alongside threejs existing 3D functions such as loading models, lighting, texturing, shaders it also includes features that are useful in openword games such as:

*Animated actors*  
  Openworld has easy actor animation including duration, looping, cloning existing actors, assigning new textures to cloned actor, sharing animations between actors with the same skeleton, doing one acion and then transitioning to an idling action.  All actors  made with the Blender modelling tool and are available in '/examplesecondtemple/blender' and '/examplerhodes3d/blender'. These are then exported into the assets directory in glb format.

![image](https://github.com/user-attachments/assets/41a0a204-c41a-4115-9605-f8039a7d1bad)

The following is sample code for adding an animated actor to a scene from an actor created in blender. 

``` 
    // Load an actor in assets priests.glb using animations from another actor called 'seller'
    // Actor is from blender model:  openworld/examplerhodes3d/blender/actors/weaponer.blend
    var weaponer = await OPENWORLD.Actor.createActor(
      'assets/actors/weaponer.glb',
      shareanimations: seller,
      action:'idle',  // Actor starts with an 'idle' animation
      z: actoroffset,
    );
    weaponer.scale.set(0.0025, 0.0025, 0.0025);     // Set the scale of the actor
    OPENWORLD.Space.objTurn(weaponer, 90);          // Set angle actor is facing from north   - east
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        weaponer, -0.12, 1.3, 0, 3); // Set the position of the actor on the surface of the terrain and hide the actor when the camera is over 3 units away
    scene.add(weaponer);
```

Notice in '/examplerhodes3d/blender/actors/armourer.blend' it has about 20 animations while the rest of the actor have about 1 animation. This is because all the human actors in the Lindos 1522 demo share these animations. This makes it easy to add new animations without needing to add them to every actor.

It is possible to specify new textures for cloned actors and models which allows meshes to be reused and made to look different. For example for the Second Temple game a second shofar is cloned from the first and a different skin is applied:

```
    // Here the _shofar actor is cloned and the shofar2.jpg clone is applied to it create a second shofar that looks different
    _shofar2 = await OPENWORLD.Actor.copyActor(_shofar, randomduration: 0.1, texture:"assets/actors/shofar/shofar2.jpg");
```

- Create new animations
  
   You can create new animations from existing ones such as combining a squat animation with a look right animation instead of manually creating an infinite number of combinations in blender. For example

```
      // Create a new animation squatright using the squat animation and the lookright animation just copying the pose on the head
      OPENWORLD.Actor.createAnimation(seller, "squatright", "squat", "lookright", ["Bip01_Head"]);
      // Create a new animation walkhandrightpointleft using the with animation of oa person walking with the right hand up and combine it with a person pointing left using the bones left arm1 and left arm2 
      OPENWORLD.Actor.createAnimation(seller, "walkhandrightpointleft", "walkhandright", "pointleft", ["Bip01_L_Arm1","Bip01_L_Arm2"]);

```

- throttling
- shadows


*Models*  
  Openworld also make it easy to include models that can be cloned and also reused with different texture. Like actors, models are also made with the Blender modelling tool and are available in '/examplesecondtemple/blender' and '/examplerhodes3d/blender'. These are also exported into the assets directory in glb format with blender (except for the terrain which should be exported in wavefront objformat ).

![image](https://github.com/user-attachments/assets/b7c19259-9ead-4e7f-aac7-7ecfea18a19a)

```
    // Load a glb model from the blender model openworld/examplesecondtemple/blender/models/laver.blend
    var laver = await OPENWORLD.Model.createModel('assets/models/laver.glb',
        texture:"assets/models/temple/wood.jpg"  // Change the texture to be made of wood
    );
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        laver, 2.53,-0.51, 0.0, 7);             // Set the position of the laver on the surface and hide if over 7 units away
    laver.scale.set(0.11, 0.11, 0.11);          // Set the model scale    
    scene.add(laver);
    
```
instancedmodels

*Adding sprites, planes and text*  
Openworld also make it easy to add sprites, planes and text.

  ![image](https://github.com/user-attachments/assets/8eca92a9-a123-4563-a54e-3cdce4e9f6c6)

```
    // Load a sprite of gabriel 
    var gabriel = await OPENWORLD.Sprite.loadSprite(
        'assets/textures/gabriel.png', 0.5, 0.4,
        ambient: false);

    // Load a plane of coat of arms
    var coatarms = await OPENWORLD.Plane.loadPlane(
        "assets/textures/coatarms.png", 0.18, 0.2);

    // Load a plane with the text 'Lindos News'
    var textplane =   await OPENWORLD.Plane.makeTextPlane("Lindos News", Colors.black, backgroundopacity: 0);
```

As with actors and models, the objects can be scale and placed on the surface of terrain.
-multitext
  -mention extra features of adding text here perpahs like tails, padding
-instancedbillboards

*Terrain and collision detection*  
Openworld allows for a single terrain model to be defined. For example for the Second Temple game the terrain is defined in:

openworld/examplesecondtemple/blender/terrain/temple.blend 

![image](https://github.com/user-attachments/assets/7a1c1422-d8f5-4912-bf91-77e5107c946f)


In blender you can defines multple meshes in a model as follows:
 
 ![image](https://github.com/user-attachments/assets/3e4fb79b-1f38-4679-97f5-c2a4313813ad)
 
If the mesh contains the name 'surface' then OPENWORLD treats it as a surface and 3D objects can easily be placed onto the surface using opendarts rayscaster.  The OPENWORLD function worldToLocalSurfaceObj places an object on the terrain at the point it intersects the terrain surface. Likewise a mesh with the word 'wall' in it is treated as a wall and OPENWORLD stop a player walking through it. And a 'roof' mesh is used so OPENWORLD knows if a player is indoors and stop showing rain indoors
 

Terrains should be exported as wavefront obj files since mesh names are retained. This is necessary so OPENWORLD knows which meshes are a wall, surface or roof

```
    // Example of loading terrain  openworld/examplesecondtemple/blender/terrain/temple.blend that has been exported to an obj file with path mode set to strip
    var manager = THREE.LoadingManager();
    var mtlLoader = THREE_JSM.MTLLoader(manager);
    mtlLoader.setPath('assets/models/temple/');
    var materials = await mtlLoader.loadAsync('temple.mtl');
    await materials.preload();
    var loader = THREE_JSM.OBJLoader(null);
    loader.setMaterials(materials);
    Group mesh = await loader.loadAsync('assets/models/temple/temple.obj');
    scene.add(mesh);
    // OPENWORLD uses groups in mesh to determine which meshes are surfaces, walls or roofs
    OPENWORLD.Space.init(  mesh, scene);
```
multilevel
caching height so less cpu time with intersections
  -mnetion how to increase gridsize
mnetion about wall intersection how good to group into aras so will use bounding box
  -if spread out then will check coolisions on everything

*Spatial features*  
Alongside using threedarts existing spatial placement of objects OPENWORLD has extra procedures to make it easy to place objects on a terrain at a certain point and with procedures to turn and scale them. All turn angle are in degrees with 0 degrees being north and 90 being east. Spatial functions make it easy to hide 3D objects if the camera gets a certain distance away from an object helping to increase frame rate. There is also spatial lerping making it possible to move an object along a terrain from one point to another in a given amount of time. Similarly with turning an object it is possible to lerp. For example turn 90 degrees in 1 second such as in this example:

```
    // Example of a fountain moving south 1 unit taking 1 second to lerp and also spinning from 90 degrees to 180 degress in 1 second
    var fountain = await OPENWORLD.Model.createModel('assets/models/fountain.glb');
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fountain, 1,1, 0.0, 7);             // Set the position of the fountain on the surface and hide if its over 7 units away
    OPENWORLD.Space.objTurn(fountain, 90);          // Set angle plane is facing east 
    scene.add(fountain);

    // Move the fountain south one unit taking 1 second to gets there - lerp the fountain
    OPENWORLD.Space.worldToLocalSurfaceObjLerp(
            fountain, 1,2, 0, 1);
   // Have fountain spin from 90 degrees to 180 degress lerping for one second
   OPENWORLD.Space.objTurnLerp(fountain, 180, 1);

```

There are many other spatial functions.  For example:

```
// Place a sword 0.4 units in front of the camera
OPENWORLD.Space.placeBeforeCamera(sword, 0.4 );
// Place a sword 0.4 units in front of the camera taking 1 second to lerp to that position
OPENWORLD.Space.placeBeforeCamera(sword, 0.4, time: 1 );

// Make knight always face the camera
OPENWORLD.Space.faceObjectAlways(knight, camera);


```
normal2world
surfaceonlylerp
lerpacity
lerpintensity

maybe seperatley
portals
  useful between levels
     -angiediff
     -adjacent
obstacles
doors

*Triggers*  
Openworld also has a trigger system whereby its possible to trigger an event. For example a trigger for when the camera gets a certain distance from an npc. In the following example a cat has a distance trigger that causes the cat to meow when a player moves within 4 meters of the cat:

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
!distance triggers changed

The is also a trigger for when a 3D object in the scene is clicked. In the following example when the minorah is clicked it is hidden:

```
    var minorah = await OPENWORLD.Model.createModel('assets/models/minorah.glb');
    scene.add(minorah);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(minorah, -0.33, 1.03, 0.0, 4); 
    minorah.scale.set(0.11, 0.11, 0.11);
    OPENWORLD.Space.objTurn(minorah, 0);
    OPENWORLD.BaseObject.setTouchTrigger(minorah);
    minorah.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
       minorah.visible=false;
    });
```
!touch triggers changed

This is also custom triggers. For example its possible to create your own trigger for when an npc is struck by a player:

```
  // Code when player swings sword and hits an npc triggering the struck trigger: 
  npc.extra['customtrigger'].trigger('strucktrigger', 5);

  // Code for the npc that has been struck
  OPENWORLD.BaseObject.setCustomTrigger(journalist);
  journalist.extra['customtrigger'].addEventListener('strucktrigger', (THREE.Event event) {
      if (!actorIsDead(journalist2)) {
         ...
         ...

```
=really should change custom triggers to be consitent with the change
      
*Movement system*  
Openworld includes the flutter <a href="https://pub.dev/packages/flutter_joystick">joystick</a> widget that allows a player to control turning and movement on a smartphone.  

![image](https://github.com/user-attachments/assets/dcdd75c8-8ba9-43e3-8fdf-cc7b3c559d0c)

This widget is used in conjuction with a threejs joystick/ keyboard that has been converted to dart. The joystick/keyboard can also be used with a keyboard allowing control on a desktop without the need for the joystick widget. 

Movement also includes swiping on the screen to turn and pitch the camera.

The threedart code has been modified so that keyboard control can be switched from movement back to flutter widgets so that for example you could type text in a flutter widget.
-keyboardcallbacks


*Mob System*  
Openworld has procedures specifically for npcs. For example  have  an actor randomly walk around a point of a given distance and frequency like a dog walking around randomly:

```
  // Here a journalist will walk a random distance of 1.5 units from where he is at a speed of 0.2m/s, walking 10% of the time
  OPENWORLD.Mob.randomwalk(journalist, 1.5, 0.2, 0.1,
              action: "walk",     // Animation to play while walking
              stopaction: "idle", // Animation to play while idling
  );
```

There is also a procedure to move an NPC over and over again through a set of positions such as a guard walking up and down a corridor:

```
  // Here a storeman will walk through these three points walking at 0.2m/s looping over and over
  OPENWORLD.Mob.moveToLoop(
            storeman,
            [ [387.26, 285.76, 0, 0.2],
              [386.05, 281.09, 0, 0.2],
              [381.72, 276.86, 0, 0.2], ],
            action: "walk". // Animation to play while walking
       );
!must change and mention callbacks and actions and different types of movetoloops eg stop

  // Or just move an npc through multiple points to reach a destination
  // For example have a knight walk through the point 384.76, 252.02 to reach 383.76, 252.02
   OPENWORLD.Mob.moveTo(knight, [ [ 384.76, 252.02], [ 383.76, 252.02]] ,
      action:"walk",    // Animation while walking
      stopaction:"idle" // Animation when reached final point
  );
```
!mention callback

There are also procedures to make it easy to add random chatter to an npc. For example:

<img src="https://github.com/user-attachments/assets/63442d1c-8c3c-4ecd-9d29-624e784c2182" width="256">

```
  // Here the bottleshopowner will have these three sentences randomly spoken
  chatter=["I can see two of you.",
          "Sometimes I have to try out my wares",
          "Watch out for the beggar. He's a nasty piece of work"];
  OPENWORLD.Mob.setChatter(bottleshopowner, chatter);

```
Its also possible to have an npc say a speech with one sentence spoken after the other:
```
  // Here the oldlady says the following 3 sentences one after the other rather than randomly
  OPENWORLD.Mob.setSpeech(oldlady, ["I can't see very well.","Is someone there?","Try some of my pie"]);
```
-callback
-x,y,z 
-tails
-padding

*Weather*  
Openworld has weather built into the engine and includes wind, rain, cloud and fog. It has lerping so it is possible gradually transition from say clear sky to cloudy or rain to fog. It also includes a random weather generator where you can specify the probabity in a given day it will rain, be cloudy, be windy or foggy.

<img src="https://github.com/user-attachments/assets/bd0a4334-5ca1-4d97-b179-33226fa7c2f0" width="356">

```
// Set game to have moderate cloud like in the screenshot above
OPENWORLD.Weather.setCloud(0.5);
```


*Time*     
Time of day can be specified using a skymat shader that allows for specifying the azimuth so can generate sunsets, sunrises, noon, night. 

![image](https://github.com/user-attachments/assets/814bbed1-a672-4298-8d06-ee1d7ddc7545)

![image](https://github.com/user-attachments/assets/7bdf6eba-8e67-4ab0-8a2d-d5d8d868cbf7)

Also the day length can be specified. For example 1 hour to equal 24 hours. Therefore a full day can occur in one hour. Openworld can change ambience so at night the terrain will be darker than during the day. Time has been incorporated into the weather system so for example if its foggy at night the fog is black while during the day the fog will be grey:

![image](https://github.com/user-attachments/assets/6a07df72-d097-493a-bcc2-7fd6a079955d)


*Light*  
Openworld includes features like specifying that a light should be switched on at night and turned off during the day. Also allows light to flicker and also to lerp turning a light on so its not sudden.

```
    var homelight= new THREE.PointLight(0xFFA500);
    homelight.intensity = 1.0; 
    homelight.distance = 1.2;
    // Specify that homelight will flicker
    OPENWORLD.Light.addFlicker(homelight);
    // Specify that homelight will only be on at night
    OPENWORLD.Light.addNightOnly(homelight);
```
!lightlerp

*Sound*  
Openworld has a sound system including a pool of flutter audioplayers which can be reused when a sound has finished playing. The pool also allows all audioplayers to be silenced when the game is closed and reactivated when the game is restarted. The sound system also includes features like volume, looping, fading and also delay.

```
// Play the sound of rain
OPENWORLD.Sound.play( path: 'sounds/rain.mp3',
   fadeIn:1,  // Take 1 second to gradually fade the sound of rain in to volume 0.1
   volume: 0.1);

```

*Object Selection*  
Openworld allows for an object to be highlighted. When combined with a touch trigger this allows for an item to be highlighted further when clicked.

 ![image](https://github.com/user-attachments/assets/b716eaf3-8f63-4135-a616-f6941c7b16ec)
 
For example clicking on the minorah in the Second Temple and read information about it:

![image](https://github.com/user-attachments/assets/b4cf5463-a2e5-4ac0-8ab9-cfb8e8125413)

This code shows an example of how its possible to highlight an object and combine it with a touch trigger to 
do something like give information when the player clicks the highlighted object:

```
    // Create a minorah in the second temple and then highlight it with setHighLight making it bluish
    // letting the player know they can click it. Then add a touch trigger to when click on the minorah
    // give the player information about it
    var minorah = await OPENWORLD.Model.createModel('assets/models/minorah.glb');
    scene.add(minorah);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(minorah, -0.33, 1.03, 0.0, 4); 
    minorah.scale.set(0.11, 0.11, 0.11);
    // Highlight the minorah to show that can click it
    OPENWORLD.BaseObject.setHighlight(minorah, scene, THREE.Color(0x0000ff), 0.25);
    OPENWORLD.BaseObject.highlight(minorah, true,scale:1.05, opacity:0.15);
    OPENWORLD.BaseObject.setTouchTrigger(minorah);
    minorah.extra['touchtrigger'].addEventListener('trigger', (THREE.Event event) {
      // Display information about the minorah when click it
      OPENWORLD.BaseObject.highlight(minorah, true, scale:1.05, opacity:0.25);
     
      var clickevent=event.action;
      setState(() {
        menuposx=clickevent.clientX;
        menuposy=clickevent.clientY-40;
        menuitems.clear();
        menuitems.add({"text":"The menorah is made of pure gold."});
        ...
        ...
      });
    });
```


*Delays*  
There are many openworld procedures that have a delay. For example it is possible to have an actor wave his hand in 5 seconds or have cat meow in 5 seconds

```
  // Cat meows in 5 seconds
  OPENWORLD.Sound.play(path: "sounds/meow.mp3", volume: 0.2, delay:5);
```

The allows for a sequence of actions to be performed. For example have a knight spin in 1 second, jump in 2 seconds and then laugh in 3 seconds.
```
// Knight turns east in 1 seconds
OPENWORLD.Space.objTurnLerp(knight, 90, 0.5, delay:1);
// Knight jumps in 2 seconds
OPENWORLD.Actor.playActionThen( knight, "jump", "idle", delay: 2);
// Knight laughs in 3 seconds
OPENWORLD.Sound.play(path: "sounds/laugh.mp3", volume: 0.2, delay:3);
```

*Persistence*  
Openworld has persistence so data can be stored when an app is closed and all game information can be retrieved. For example remember the state of the weather:

```
   // Store the rain level
   OPENWORLD.Persistence.set("rain", 1.0);

   // When restart the game set the rain back to what it was when last saved
   Weather.setRain( await OPENWORLD.Persistence.get("rain",def:0));
```

*Rooms*  
Openworld has a room system which allows things to happen when a player enters a room such as play a background sound, determine if  the room is indoors and call a trigger when a player enters the room. Rooms are defined to have a central x,y point with a rectangle having distance from that point. Rooms not only have a looping sound associated with it but also a random intermittent sound such as a smithy hammering occasionly. If  a room is indoors then rain will not appear.  The following is an example of a room with a background sound and a random intermittent sound and is defined to be indoors if a roof is above the players head. When the player enters the room a priest says a speech:

```
    var roomBC = OPENWORLD.Room.createRoom(7.4, 1.26,               // central coordinates of the room
             soundpath: "sounds/courtyard.mp3", volume: 0.05,       // looping background sound played when enter the room
             randomsoundpath:"sounds/prayer.mp3", randomsoundgap:50 // prayer is played randomly every 50 seconds
    );
    scene.add(roomBC);
    OPENWORLD.Room.setAutoIndoors(roomBC, true);                    // If roof is above head is 
    OPENWORLD.Room.setDistanceTrigger(roomBC,
        minx: 5, maxx: 9.1, miny: -0.67, maxy: 2.8);                // define the boundaries of the room - room in x axis from 5 to 9.1 and y axis is -0.67 to 2.0
    // When enter the room
    roomBC.extra['trigger'].addEventListener('trigger', (THREE.Event event) {
      if (event.action) {
         OPENWORLD.Mob.setSpeech(priest, ["Welcome to the Second Temple","Its 72AD"]);   // When enter the room the priest says a speech
      } 
    });
```
! have modified distance trigger
-mention exitroom and ability to  have a roomterrain
<!--
rooms where define an area for a room and 
    can trigger entry and exit of room eg have butcher say hello when someone enters
    room sound eg sound fo a smithy when enter
    indoors when indoors then not effected by rain
-->

*Maps*  
Openworld has maps that show the players position with a marker. It is possible to have multiple maps where you can have a map for say a city and then a larger encompassing for wilderness. Each map is an image and you specify two points with a pixel position and a corresponding world position. With the two points openworld  calculates the image position from the world position through interpolation and can place a marker in the correct position:

<img src="https://github.com/user-attachments/assets/816b8b2d-b8d5-4a8c-80a2-e73cb7077fc4" width="350">

In this example there are two maps and when the player is within the area of map.jpg then this map is shown. If is outside this area then maplarge.jpg is shown.
```
    var maps = [
      OPENWORLD.MapItem('assets/maps/maplarge.jpg',
          worldx: -7.61,  // Point 1 with pixel position and corresponding world position
          worldy: 17.73,
          imagex: 301,
          imagey: 338,
          worldx2: 11.05,  // Point 2 with pixel position and corresponding world position
          worldy2: -12.99,
          imagex2: 371,
          imagey2: 450),
      OPENWORLD.MapItem('assets/maps/map.jpg',
          worldx: -2.36, // Point 1 with pixel position and corresponding world position
          worldy: 4.94,
          imagex: 13,
          imagey: 122,
          worldx2: 9.52, // Point 2 with pixel position and corresponding world position
          worldy2: -2.32,
          imagex2: 977,
          imagey2: 588)
    ];
    OPENWORLD.Maps.init(maps);

    // Given the current world position get the correct map and its marker position on that map
    var map = OPENWORLD.Maps.getMapFromWorldcoords(worldpos.x, worldpos.y);
```
<!--
 maps where just specify two points on a map ie pixel pos and world pos and can tranlate your position onto map
    -multipel maps and will choose the one at end so can have maps eg for a city and a global map
    -exmaples of display of maps in two demos
-->

*Music*  
Openworld can play music in the background with multiple songs with different probabilities of playing. In the example below there are four song and hatikvah has a 5/8 chance of the song being chosen to play. By default there is a gap between songs of 3 minutes plus a random number between 0 and 50 second though this can be changed with 'timebetweensongs' and 'randomtimebetweensongs':

```
    var musics = [
      OPENWORLD.MusicItem('sounds/hatikvah.mp3', chance: 0.5),
      OPENWORLD.MusicItem('sounds/harp.mp3', chance: 0.1),
      OPENWORLD.MusicItem('sounds/harp2.mp3', chance: 0.1),
      OPENWORLD.MusicItem('sounds/harp3.mp3', chance: 0.1),
    ];
    OPENWORLD.Musics.init(musics);
    OPENWORLD.Musics.timebetweensongs=6*60;

    // Randomness on how long before play a song
    OPENWORLD.Musics.randomtimebetweensongs=60;
```


*Config file*  
Rather than hard code all 3D objects in flutter it is possible to specify 3D objects in a configuration file specified in assets as 'config.json'. For example to define vegetation such as grass in many locations a grass object can be defined and then cloned in any number of  positions. In the example below a grass model is loaded called 'grass' and three grass models are placed on the surface at different positions ("p") and different scales ("s") and different turn ("t"). All will disappear if the player is more than 4 units away ("d")

```
{"objects": [
  {"name": "grass","object": [
    {"type": "model", "filename":"assets/models/grass.glb","s":0.03}
  ]},
  ],

"positions":
{"staticpositions":[
      {"name": "grass", "p": [412.20,307.97,0], "d":4},
      {"name": "grass", "p": [412.50,307.27,0], "s":0.5, "d":4},
      {"name": "grass", "p": [410.50,306.27,0], "s":0.6, "t":90, "d":4}
]
}]
  }
}
```

The config file also has  pool objects. This is useful for example with a forest with thousands of trees. Its possible to show only the closest 40 trees at anyone on time instead of clone 1000 trees. In the example below a tree object is created. There are two pool positions at two different positions with 500 trees defined in each that are randomly placed within 30 units of the position of the pool object. They are randomly scaled by 0.4 (scaled randomly between 0.8 to 1.2). So the example below defines 1000 trees but only creates 40 and displays only the closest 40 to the player.

```
{"objects": [
  {"name": "tree","object": [
    {"type": "model", "filename":"assets/models/tree.glb","s":1.5}
  ]},
  ],

"positions":
{  "poolpositions":[{"poolsize":40,  "positions":[
    { "name": "tree","p": [  -20.84, 20.39,0.0],  "rx": 30, "ry":30, "rs":0.4, "n": 500 },
    { "name": "tree","p": [  -42.05, 11.56,0.0],  "rx": 30, "ry":30, "rs":0.4, "n": 500 },
  ]
}]
  }
}
```
- mention big changes to config like onvisible, throttling
   -getting the json based on the actor so can know position and vice versa, given an position get the actor associated if visible
  
*Common objects*    
Openworld includes some useful objects like fire, water, flares, smoke and sky. Most are based on those  available in threejs as shaders. 

![image](https://github.com/user-attachments/assets/ab24ea2b-8149-4759-abec-f7f8eb794eca)

The following is an example of fire:
```
    fire = new VolumetricFire(
        2,4,2,0.5, camera);
    await fire.init();

    OPENWORLD.Space.worldToLocalSurfaceObjHide(fire.mesh,3.29, 0.25,0.3,3);
    scene.add(fire.mesh);
    OPENWORLD.Updateables.add(fire);
```

The following is an example of flares:

![image](https://github.com/user-attachments/assets/ee950d2f-7ca7-4a2f-8397-6bf3a9d8269d)

The following is an example of water:

![image](https://github.com/user-attachments/assets/4f4499fd-e278-4457-8810-71d83fd11289)

-vegetation
-trees


*Multi player*  
The demo games include simple multi player capability. But multiplayer is not built into the openworld gaming engine. This might change in the future. Openworld does have a client class with sessions and player information but the actual game play is specific for each demo. The demo multiplayer simply broadcasts a logged in players  position and turn and broadcasting a player action 'wave'. The multiplayer does provide chat and information on whos on. The server side is written in php and mysql as available in the repository in /server

![image](https://github.com/user-attachments/assets/d5114ddf-57ab-46e7-a3ab-54b29215eca7)
  - not in second temple demo but is in rhodes3d
    -possibly need to include the php server for rhdoes3d

*Hotloading*  
The demo games include a hotloading function that is called whenever a game is hotloaded. This allows everything in hotload function being reloaded and displayed instantly making placement of objects being possible on the fly. For example in the example below an extra grassposs position could be added and then hotloaded and it will be displayed straight away:

```
hotload() async
{

    _hotload.clear();
    // All the grass
    const grassposs = [
      [13.61, 1.54, 0.0, 4],
      [14.41, 1.82, 0.0, 4],
      [16.67, 1.33, 0.0, 4],
      [14.60, 5.79, 0.0, 4],
      [59.54, -0.12, 0, 4],
      [58.10, 0.35, 0, 4]
    ];
    var grass = await OPENWORLD.Sprite.loadSprite(
        'assets/textures/grass.png', 0.1, 0.1);
    for (var tree in grassposs) {
      var cyprusii = await OPENWORLD.Sprite.cloneSprite(grass);
      OPENWORLD.Space.worldToLocalSurfaceObj(cyprusii, tree[0].toDouble(),
          tree[1].toDouble(), tree[2].toDouble());
      _hotload.add(cyprusii);
    }
}
```

  
An easy way to get a world position on the terrain is from the android studio console which will every second display your location and turn:

```
pos: 8.59, 1.31, t-90.00
pos: 8.59, 1.41, t-90.00
pos: 8.59, 1.51, t-95.00
```

By copying and pasting the position into the hotload function, objects can be placed in the scene, hotloaded and viewed straight away.

--
asset protector
   load a model with asset...

