# Open World for dart
This a draft I'm writing for the future version of the openworld library so please ignore for the time being.

This is a library to make openworld games with the dart package threejs. This library is based upon an older threejs openworld library just for web using javascript [openworldthreejs](https://github.com/forthtemple/openworldthreejs). The advantages of flutter for an openworld game is with one code base you can create a multi platform (iOS, Windows,Android, MacOS, Linux, Web). Also there is a huge number of flutter widgets that can be incorporated into the game. There is also hotloading making it possible to place objects in a scene, hit hotload and the 3D object will appear in your game within seconds. 

This version of the library is an update of the previous openworld library that used [three_dart](https://github.com/wasabia/three_dart) instead of [three_js](https://github.com/Knightro63/three_js)/ Threejs is more up to date and have found it works better across platforms. The openworld library itself has been updated to work better on desktops as opposed to smartphones. This has been showcased by an improved version of the Second Temple game on  [steam](https://store.steampowered.com/app/4067520/Second_Temple/). This new version is available on [windows, mac](https://store.steampowered.com/app/4067520/Second_Temple/),  linux,[iPhone](https://apps.apple.com/us/app/second-temple/id6593662011) and android and [web](https://secondtemple.org). As with the previous version, this library includes two demo games, Second Temple and Rhodes 3D.

The openworld library has many new features added such terrain levels which allows for example, a multi story building where you can place objects on different levels of the building. There are also shadows built into model and actor creation. There is a new vegetation object using cheap sprites to generate realistic vegetation like grass and shrubs. It can also add detail to the ground. There are also a tree object using many sprites and plains to create branches and leaves. And the water2 object of threejs has been made faster with the ability to skip reflection updates and also choose which objects to reflect. There is also an asset encrypter so when you deploy a game, your assets have some protection. The config class has been updated so pooled objects are not only created from a static text file but also runtime. This allows for example crowds of people with for example 1000 actors, only showing the closest 50 near the camera. There is now actor animation throttling so when theres lots of actors the CPU only actors close to the camera have every animation frame calculated with those further away having frames skipped. Also the new openworld library includes being able to add actor animations run time by combining existing animations. The library also has the addition of extra callbacks. For example allow when an npc has given a speech you can add callback when finished to say have the npc jump up in the air. Also callbacks for keypresses have been added. For example a keypress callback can be  called when a player gets near a horse and presses 'E' to mount the horse. For large meshes, mesh intersection calculations for walking on a terrain or finding a wall can be expensive and openworld is now far more optimized for calculating intersections using caching and bounding boxes. Run time obstacles have also been added so you can block off an area and then reenable. This is useful for say a door that has been closed. For multiple doors, a doorsway class has have been added to allows that multiple doors eg two grand doors to be opened or closed with one call coding to manually opening each door.  Another feature is fading objects as they move away from the camera rather than abruplty making them invisible. Simnilarly lights can also be dimmed as they move away from the camera. 

This small code snippet emonstrates a small part of openworld showing how to add a skydome but but it'd be better to look at the example games to see how the library works in its entirety with weather, actor animations, terrains, chatter etc.


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


One of the demo games is set in Jerusalem at the Second Temple 65AD. 

<img width="400" alt="Screenshotcourtowmen" src="https://github.com/user-attachments/assets/fe084261-9002-4611-b9f4-a45f51108c95" />
<img width="426" height="240" alt="Video Project 2" src="https://github.com/user-attachments/assets/cea19076-b1ee-47a2-aa2b-7430ac8ccf97" />

This games models, actors and texture are all availabe in this repository and the game can be run on steam  for <a href='https://store.steampowered.com/app/4067520/Second_Temple/'>Steam</a> (Windows and macOS). <a href="https://apps.apple.com/us/app/ark-uncovered/id6593662011">iTunes</a> (iOS, macOS) on  <a href="https://forthtemple.com/secondtemple.apk">TODO secondtemple.apk</a> (Android), <a href='https://secondtemple.org/'>web</a>, <a href="https://snapcraft.io/secondtemple">todo snap</a> (Linux) and <a href='https://www.youtube.com/watch?v=fNuSaUxYvGs'>Youtube</a>

[![secondtemple](https://snapcraft.io/secondtemple/badge.svg)](https://snapcraft.io/secondtemple)

A second game is set in Lindos, Rhodes south of Greece in 1522 just before Sulamains invasion.

![image](https://github.com/user-attachments/assets/be650f03-b6dd-4156-9a4c-ba32e5a1edca)

It is also available on <a href="https://apps.apple.com/us/app/lindos-1522/id6736712620">iTunes</a> (iOS, macOS) on  <a href="https://www.amazon.com/gp/mas/dl/android?p=com.forthtemple.rhodes3d">Amazon</a> (Android), <a href="https://snapcraft.io/rhodes3d">snap</a> (Linux), <a href='https://chatgpt.forthtemple.com/rhodes3d'>web</a> and <a href='https://www.youtube.com/watch?v=-xjAiFQzZRM'>Youtube</a>.

[![rhodes3d](https://snapcraft.io/rhodes3d/badge.svg)](https://snapcraft.io/rhodes3d)
-------

The philosophy of the library is it should not get too bloaded and only include features that typical openworld games would require on a smartphone or desktop. For example most openworld games will have animated actors, such as a person or monster walking. Most openworld games would include models,  planes and sprites, sound, light, weather, time of day, maps, music and rooms. But not all would include, for example, a players inventory system or a combat system or a monetary system. So these less used features are excluded.

Alongside threejs existing 3D functions such as loading models, lighting, texturing, shaders it also includes features that are useful in openword games such as:

*Animated actors*  
  Openworld makes actor animation easy and includes duration, looping, cloning existing actors, assigning new textures to cloned actor, sharing animations between actors with the same skeleton, doing an action and then transitioning to an idling action.  All actors  made with the Blender modelling tool and are available in '/examplesecondtemple/blender' and '/examplerhodes3d/blender'. These are then exported into the assets directory in glb format.

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
  
   It is possible to create new animations from existing ones such as combining a squat animation with a look right animation. This reduces the need to manually creating an infinite number of combinations of animations in blender. For example rather than in blender creating a squat look right animation combine two animations like below:

```
      // Create a new animation squatright using the squat animation and the lookright animation just copying the pose on the head
      OPENWORLD.Actor.createAnimation(seller, "squatright", "squat", "lookright", ["Bip01_Head"]);
      // Create a new animation walkhandrightpointleft using the with animation of oa person walking with the right hand up and combine it with a person pointing left using the bones left arm1 and left arm2 
      OPENWORLD.Actor.createAnimation(seller, "walkhandrightpointleft", "walkhandright", "pointleft", ["Bip01_L_Arm1","Bip01_L_Arm2"]);

```

- Animation throttling
  
     If there are  a large number of actors, such as a crowd it can be expensive to animate every actors new pose each frame. To reduce CPU expense frames can be skipped if the actor is a certain distance away from the camera. For example if the actor is 0.5 units away then skip 6 frames before doing the next animation.
  
```
     // Have every 6th frame skipped if 0.5 units from the camera
     OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
     // Turn the animation throttling off
     OPENWORLD.Actor.disableDistanceThrottle(actor);
```
  



*Models*  
  Openworld also make it easy to include models that can be cloned and also reused with different textures. Like actors, models are also made with the Blender modelling tool and are available in '/examplesecondtemple/blender' and '/examplerhodes3d/blender'. These are also exported into the assets directory in glb format with blender (except for the terrain which is easier when model groups when wavefront obj format is used ).

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


*Shadows*

For actors and models threejs allows shadows to be created and the openworld library makes it easier to set that an object casts a shadow, such as an NPC.

  
<img width="309"  alt="image" src="https://github.com/user-attachments/assets/bc52b1d4-4d14-4131-9532-f815aeb4a8d7" />

In example below the sun has a shadow map and the terrain (groundsurface) is set to receive shadows and the soldier2 is set to cast a shadow:

```
  
 var sunlight = new THREE.DirectionalLight(0x888888,1.0);//.PointLight(0x888888);///.PointLight(0x888888); //ffffff);
 sunlight.target=threeJs.camera;
   // Set sun shadows
 sunlight.shadow?.mapSize.width = 1024;
 sunlight.shadow?.mapSize.height = 1024;
 sunlight.shadow?.camera?.near = 0.01;
 sunlight.shadow?.camera?.far = 500;
 sunlight.castShadow = true;
 threeJs.scene.add(sunlight);
 sunlight.shadow!.radius=1;

 // Terrain recieves shadows
 groundsurface= OPENWORLD.BaseObject.getGroupByName(OPENWORLD.Space.mesh, "ground");
 groundsurface.receiveShadow = true;

// Soldier casts a shadow
 soldier2 = await OPENWORLD.Actor.createActor(
        'assets/actors/soldier/soldier2.glb',
        z: actoroffset,
        shareanimations: seller,
        castshadow: true);
```
        
*Adding sprites, planes and text*  
Openworld also make it easy to add sprites, planes and text.

  ![image](https://github.com/user-attachments/assets/8eca92a9-a123-4563-a54e-3cdce4e9f6c6)
  <img width="200" alt="image" src="https://github.com/user-attachments/assets/85480e4e-6ce2-4144-aa4f-1c3f46724b12" />


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

   // Create a multitext sprite with the part on the left with a transparent background and the second part of the text black and bold like in the screenshot above
   var stairsdownicon = await OPENWORLD.Sprite.makeMultiTextSprite( [{'message': 'E', 'textcolor': Colors.white,
          'backgroundcolor': Colors.black,
          'backgroundopacity': 1.0,
          'paddingLeft': 5, 'paddingRight': 5},
              {'message': 'Stairs ↓', 'textcolor': Colors.white,
            'backgroundcolor': Colors.black,
            'bold':true,
            'backgroundopacity': 0.0}], scale:0.03);
```

As with actors and models, these objects can be scaled and placed on the surface of terrain.

*Instanced Objects*

Can be costly if must render huge number of objects each frame
   can use instanced models and sprite so one pass
   
<img width="400"  alt="image" src="https://github.com/user-attachments/assets/17044f21-63e5-4ef2-a835-de14085beb5b" />

in this example thousands of column models displayed and renderer will be one pass

```
    // Display 300 columns in a row with one column model
    column = await OPENWORLD.Model.createModel( 'assets/models/column.glb');
    instancedColumns = InstancedModel.fromTemplate(column, 300, threeJs.scene,name:'column');
    instancedColumns.hideDistance=15.0;
    instancedModels.add(instancedColumns);

    instancedColumns.reset();
    for (var i = 0; i < 300; i++) {
      instancedColumns.place(-90, 6.82, 14.77 + i * 0.15, 0.0, scale: THREE.Vector3(0.4, 0.4, 0.4));
    instancedColumns.finish();

    //  Display 100 grass sprites at random positions
    var grasstexture = await  AssetPack.loadTexture('assets/models/temple/grass.png');
    instancedGrass = InstancedBillboards.create(grasstexture!, 10, threeJs.scene,color:spritebillboardambiencecolor);
    for (var i=0; i<100; i++)
      instancedGrass.place(    OPENWORLD.Math.random()*10, OPENWORLD.Math.random()*10, 0.1,  width: 0.1,  height: 0.1);

```

*Terrain and collision detection*  
Openworld allows for a single terrain model to be defined. For example for the Second Temple game the terrain is defined in:

openworld/examplesecondtemple/blender/terrain/temple.blend 
<img width="1247" height="546" alt="image" src="https://github.com/user-attachments/assets/58ed0076-f1b3-467a-bc27-e6e2c840f00c" />
<!--
![image](https://github.com/user-attachments/assets/7a1c1422-d8f5-4912-bf91-77e5107c946f)


In blender you can defines multple meshes in a model as follows:
 
 ![image](https://github.com/user-attachments/assets/3e4fb79b-1f38-4679-97f5-c2a4313813ad)
-->

If the mesh contains the name 'surface' then OPENWORLD treats it as a surface and 3D objects can easily be placed onto the surface using opendarts rayscaster.  The OPENWORLD function worldToLocalSurfaceObj places an object on the terrain at the point it intersects the terrain surface. Also you can define levels of surfaces eg a roof with level name 'surface1' in blender. Can also be negative for say below ground

Likewise a mesh with the word 'wall' in it is treated as a wall and OPENWORLD stop a player walking through it. And a 'roof' mesh is used so OPENWORLD knows if a player is indoors and stop showing rain indoors.


Terrains can be exported as glb files but also wavefront obj files. 

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


*Spatial features*  
Alongside using threejs existing spatial placement of objects OPENWORLD has extra procedures to make it easy to place objects on a terrain at a certain point and with procedures to turn and scale them. All turn angle are in degrees with 0 degrees being north and 90 being east. Spatial functions make it easy to hide 3D objects if the camera gets a certain distance away from an object helping to increase frame rate. There is also spatial lerping making it possible to move an object along a terrain from one point to another in a given amount of time. Similarly with turning an object it is possible to lerp. For example turn 90 degrees in 1 second such as in this example:

```
    // Example of a car moving south 1 unit taking 1 second to lerp and also spinning from 90 degrees to 180 degrees in 1 second
    var car = await OPENWORLD.Model.createModel('assets/models/car.glb');
    OPENWORLD.Space.worldToLocalSurfaceObjHide(     car, 1,1, 0.0, 7);             // Set the position of the car on the surface and hide if its over 7 units away
    OPENWORLD.Space.objTurn(car, 90);          // Set angle plane is facing east 
    scene.add(car);

    // Move the car south one unit taking 1 second to gets there - lerp the car
    OPENWORLD.Space.worldToLocalSurfaceObjLerp(  car, 1,2, 0, 1);
   // Have car spin from 90 degrees to 180 degress lerping for one second
   OPENWORLD.Space.objTurnLerp(car, 180, 1);

   // Can also use levels eg place a chimney on a roof that is on a surface set as level 1 in blender
   var chimney = await OPENWORLD.Model.createModel('assets/models/chimney.glb');
   OPENWORLD.Space.worldToLocalSurfaceObjHide(
       chimney, 1,3, 0.0, 7, level:1);             // Set the position of the chimney on the roof which is level 1 and hide if its over 7 units away
   OPENWORLD.Space.objTurn(chimney, 90);          // Set angle chimey is facing east 
   scene.add(chimney);



```
Behind the scenes mesh intersections with surfaces are cached in a small grid. This way say a lot of NPC's walking on a surface will not cost a rayintersection with every frame. If you wish finer more accrate heights can increase grid size.

Also wall intersection are optimized so that if you have a big terrain with a lot of walls, can be expensive to do wall intersection every frame. Behind scenes has bounding box so only check walls in mesh that are within range of the camera rather than everwhere. Therefore it is good if  group your walls into blocks rather than spread over the terrain so dont intersect with every walls.

There are many other spatial functions.  For example:

```
// Place a sword 0.4 units in front of the camera
OPENWORLD.Space.placeBeforeCamera(sword, 0.4 );
// Place a sword 0.4 units in front of the camera taking 1 second to lerp to that position
OPENWORLD.Space.placeBeforeCamera(sword, 0.4, time: 1 );

// Make knight always face the camera
OPENWORLD.Space.faceObjectAlways(knight, camera);


```
It is also possibly to place an object on a terrain with the same pitch as the terrain using the normal2world parameter. For example a horse and cart going up a hill like below

<img width="261" height="279" alt="image" src="https://github.com/user-attachments/assets/71d9c89f-65ed-4f06-8b13-a3e4ee273bd2" />

```
  OPENWORLD.Space.worldToLocalSurfaceObjHide(  cart, 1,3, 0.0, 7, normal2world:true);

  // Move the cart up hill to position 1,5 in 10 seconds while keeping the cart normal to the world
  // worldToLocalSurfaceOnlyObjLerp will calculate its height position on the terrain at every movement so the cart will move along the contours of the terrain
  OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(  cart, 1,5,0, 10.0, normal2world:true);
```

It is also possible to lerp the opacity of the object so rather than an object disappear instantly when it is a certain distance from the camera instead if fades
```
    // Have a car fade in 1 second when the car is 7 units away from the camera and fade in when you get closer than 7 units
    OPENWORLD.Space.worldToLocalSurfaceObjHide(     car, 1,1, 0.0, 7, lerpopacity:1.0);             

```

This also applies to light intensity. Rather than have a light abruptly turn off when the camera is a certain distance away from it it can fade using the 'lerplight' parameter:

```
    // Set up a point light
    var hearthlightgroup = THREE.Group();
    var light = new THREE.PointLight(    0xFFA500); 
    light.intensity = 0.3; 
    light.distance = 0.5; 
    hearthlightgroup.add(light);
    scene.add(hearthlightgroup);
    // Place the light source in the scene and when camera is 2 units away from it have the light fade in 1 second
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hearthlightgroup, hearthposx, hearthposy,2.0,level:1, 1, lerplight: 1);

```



*Triggers*  
Openworld also has a trigger system whereby its possible to trigger an event. For example a trigger for when the camera gets a certain distance from an npc. In the following example a cat has a distance trigger that causes the cat to meow when a player moves within 4 meters of the cat:

    Group cat = await OPENWORLD.Actor.createActor('assets/actors/cat.glb', z:0);
    cat.scale.set(0.01,0.01,0.01);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cat,1,1, 0, 4);
    OPENWORLD.Space.objTurn(cat,0);
    scene.add(cat);
    OPENWORLD.BaseObject.setDistanceTrigger(cat, dist: 4. event: (action) {
      if (event.action) {
         OPENWORLD.Sound.play(path: "sounds/meow.mp3", volume: 0.2);
      } else {
      }
    });


There is also a trigger for when a 3D object in the scene is clicked. In the following example when the minorah is clicked it is hidden:

```
    var minorah = await OPENWORLD.Model.createModel('assets/models/minorah.glb');
    scene.add(minorah);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(minorah, -0.33, 1.03, 0.0, 4); 
    minorah.scale.set(0.11, 0.11, 0.11);
    OPENWORLD.Space.objTurn(minorah, 0);
    OPENWORLD.BaseObject.setTouchTrigger(minorah,event:(event) {
       minorah.visible=false;
    });
```
<!--
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
-->

*Portals*

Allows you to jump from one part of the game to another. For example if multi level and have a set of stairs when hit a rectangle at bottom of stairs give a destination at a new level and player moves to the new level

```


     // Take a player to the top of a set of steps to level 1
     // If a player walk into a rectangle at x,y=57.16, 13.35 with width and height 0.04 then take them to x,y 57.7,13.45 on level 1 and have them face 0 degrees when they reach their destination
     OPENWORLD.Portals.createPortal(
          57.76, 13.35,
          0.04,
          0.04,
          57.7, 13.45,
          0.0,
          level2: 1,
          finalturn:0,
          //  marker: _hotload,   // If visually want to see the portal entrance and destination then comment this part out
          lerp: 1  // Take one second to get lerp to the top of the steps
     );

     // This portal does the opposite and takes the player from the top of the steps down to the bottom. When the player reaches the bottom they turn 225 degrees
     // There is a callback where when they reach the bottom, after a delay of 1 second they turn to 318 degrees
     // Angle entry is the angle they must enter the portal (140 degrees) with a certain threshold (eg  50 degrees eg can enter the portal 90 to 190 degrees)
     // Angle entry stops the problem of  possibly have multiple portals near each other and accidently falling into the wrong one
     OPENWORLD.Portals.createPortal(
          57.74, 13.42,
          level:1,
          0.05,
          0.05,
          57.63, 13.21,
          level2: 0,
          0.0,
          //   marker:_hotload,
          finalturn:225,
          angleentry: 140,
          angleentrythresh: 50,
          lerp: 1,
          callback:(){
            OPENWORLD.Space.objTurnLerp(threeJs.camera, 318,1,delay1);
          }
      );
```

*Obstacles*

At run time place a rectangle of certain with and height and stop player from getting past

```
    // Place an obstacle at  hearthposx, hearthposy with a width and height of 0.1
    // If hit the obstacle then play a pain sound
    OPENWORLD.Obstacles.createObstacle(
        hearthposx, hearthposy, 0.1, 0.1,
         //marker:_hotload   // Draw the marker
        callback: (obstacle) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick(['sounds/pain.mp3','sounds/pain2.mp3','sounds/pain3.mp3']),volume: 0.1);
        },
        callbacknextwait: 1  // Wait 1 second before allow another callback - stop flood of callbacks if a player hits the obstacle
    );
```

*Doorways*
If have a doorway made of multiple doors such as a double door can add the doors to doorway class and set their angle when opened or close so only need to call setOpenClose( to open and
close a door rather than move the doors individually.

```
    // For a doorway of two doors create the two door objects
    var doorwomensgateeast = doorwood.clone();
    _hotload.add(doorwomensgateeast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwomensgateeast,-13.66, 63.15, 0.00,  10);
    doorwomensgateeast.scale.setValues(0.2, 0.25, 0.2);

    var doorwomensgatewest = doorwomensgateeast.clone();
    _hotload.add(doorwomensgatewest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwomensgatewest, -13.86, 63.15, 0.00,   10);

    // These two doors can be added to a doorway 
    var doorwaywomensgate=OPENWORLD.Doorway();
    // If the door is open turn the door to 0 degrees otherwise to 90 degrees
    doorwaywomensgate.addDoor(doorwomensgateeast,0,90);
    // If the second door is open turn the door to 0 degrees otherwise set it to -90 degrees
    doorwaywomensgate.addDoor(doorwomensgatewest,0,-90);
    // Set the doors open or closed with one call - here if its not night time then both doors will be 0 degrees
    doorwaywomensgate.setOpenClose(!OPENWORLD.Time.isNight(OPENWORLD.Time.time));

```
      
*Movement system*  
Openworld includes the flutter <a href="https://pub.dev/packages/flutter_joystick">joystick</a> widget that allows a player to control turning and movement on a smartphone.  

![image](https://github.com/user-attachments/assets/dcdd75c8-8ba9-43e3-8fdf-cc7b3c559d0c)

This widget is used in conjuction with a threejs joystick/ keyboard that has been converted to dart. The joystick/keyboard can also be used with a keyboard allowing control on a desktop without the need for the joystick widget. 

Movement also includes swiping on the screen to turn and pitch the camera.

The threejs code has been modified so that keyboard control can be switched from movement back to flutter widgets so that for example you could type text in a flutter widget.

*Keyboard callbacks*
allows an event to coniditionally occur when press a key. For example if you are facing a donkey at a certain distance and press 'e' can mount the donkey. Call backs can also be unconditional eg very time a player press space they jump up in the air

```
// Create a keyboard callback wehre if you are 0.5 units from a horse and facing it with 50 degrees and press 'e' you will mount the horse.
OPENWORLD.KeyboardCallbacks.createKeyboardCallback(
          'E', object: _horse, 0.5,facingdiff: 50,
              (keyboardcallback) {
             mount();
          });
```


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
  // Here a storeman will walk through these three points walking at 0.02 units/s looping over and over.
   // Movetoloop also includes actions where can reach a certain point and do something like jump up in the air and turn west.
  // Also includes callbacks where once a position When reaches 6.1,-20.5 the storaman cries in pain
  // The looptype canbe looptypestop where rather than looping will stop
  var v=0.02;
  OPENWORLD.Mob.moveToLoop(storeman,
              [
                {"p": [-5.84, -30.5, 0], "v": v},
                {"p": [-6.1, -20.5, -0.01], "v": v,
                  "callback": (actor) {
                     OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick(['sounds/pain.mp3','sounds/pain2.mp3','sounds/pain3.mp3']),volume: 0.1);
                  }
                },
                {"action": "jump", "time": 10, "t": 270},  // Jump when reach -6.1,-20.5 waiting 10 seconds and face west
                {"p": [-6.1, -20.5, 0], "v":v},
                {"p": [-5.84, -35, 0],  "v": v, },
              ],
             // looptype: OPENWORLD.Mob.LoopTypeStop,  
              action: "walk");


  // Or just move an npc through multiple points to reach a destination
  // For example have a knight walk through the point 384.76, 252.02 to reach 383.76, 252.02
  // Can have a callback when finish so for example the knight says hello when reached the destinstation
   OPENWORLD.Mob.moveTo(knight, [ [ 384.76, 252.02], [ 383.76, 252.02]] ,
      action:"walk",    // Animation while walking
      stopaction:"idle" // Animation when reached final point
       callbackonfinish: (actor) {
         OPENWORLD.Mob.setSpeech(actor, ["Hello"], z: 90,    scale: 0.4);
       })
  );

```

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

The speech also allows for placement for example the placement of the text above the npc with z. Or left and right of the npc with x or forward or back with y (eg -50 units forward in the example below). It also includes a callback so when it the speech is finished can have the npc do something else.

  <img width="300" alt="image" src="https://github.com/user-attachments/assets/4687b052-1eac-496b-a4c4-14335e081c75" />
 OPENWORLD.Mob.setSpeech(actor,
    ['Jack and Jill',
     'went up the hill',
     'to fetch a pale of water'],
    x: 20,     y: -50.0,  z: 90,
     clearwhendone: true,   // When speech is finished, clear the text
      scale: 0.7,  tails: { 'bottomleft', 'bottomright', 'bottomcenter' },  // have tails at the bottom of the speech bubble like in the screenshot - for example imlpy a group of people are singing
      callbackonfinish: (actor) {
        // When finished speech laugh
         OPENWORLD.Sound.play(path:'sounds/laugh.mp3');
      });

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
Light intensity can also be lerped dimmer as move away.
```
    var homelight= new THREE.PointLight(0xFFA500);
    homelight.intensity = 1.0; 
    homelight.distance = 1.2;
    // Specify that homelight will flicker
    OPENWORLD.Light.addFlicker(homelight);
    // Specify that homelight will only be on at night
    OPENWORLD.Light.addNightOnly(homelight);
    // when move 5 units away from camera, light will fade in 1 second or vice versa
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        homelight, hearthposx, hearthposy, 5, lerplight: 1);
```

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
It also has exitroom so when you leave a room it'll take you do another room eg room terrain
   -for example can have a large roomterrain with smaller rooms of houses that lead into the terrain
      -roomterrain could have sound of crickets at night or general terrain 
```
    var roomBC = OPENWORLD.Room.createRoom(7.4, 1.26,               // central coordinates of the room
             soundpath: "sounds/courtyard.mp3", volume: 0.05,       // looping background sound played when enter the room
             randomsoundpath:"sounds/prayer.mp3", randomsoundgap:50, // prayer is played randomly every 50 seconds
             exitroom: roomTerrain
    );
    scene.add(roomBC);
    OPENWORLD.Room.setAutoIndoors(roomBC, true);                    // If roof is above head is 
    OPENWORLD.Room.setDistanceTrigger(roomBC,
       // define the boundaries of the room - room in x axis from 5 to 9.1 and y axis is -0.67 to 2.0
        minx: 5, maxx: 9.1, miny: -0.67, maxy: 2.8,     event: (action) { {
    // When enter the room
      if (event.action) {
         OPENWORLD.Mob.setSpeech(priest, ["Welcome to the Second Temple","Its 72AD"]);   // When enter the room the priest says a speech
      } 
    });
```

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
Config pool objects can also be used run time creating pool objects on the fly without using ocnfig.json file. For example you could create a crowd of 100 npc actors like below randomly placed in a 10x10 grid facing at random directions.  They also have an callbackonvisible and callbackonhide so when they appear you could have them for example say a speech, jump up in the air. And when they are no longer visible you can clear it on callbackonhide. You should always remember to to undo whatever youve done on callbackonvisible or it'll appear when the pool object is reused. In the example below animation throttling is used so that actors that are furtuher away have less frames computed the those closer to the camera allowing for large crowds without expensive animation pose calcualtions.

```
    // Create 100 pool object in a 10x10 units area
    for (var i=0; i<100; i++) 
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name':  OPENWORLD.Math.randPick(manlist),
              'p': [OPENWORLD.Math.random()*10,OPENWORLD.Math.random()*10, 0],
              't': OPENWORLD.Math.random()*360,
              'action': "idle",
              'randomduration': 0.1,
              "lerpopacity": 1,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },
            });


    // Call this once any new objects are created  - eg at the end of hotload
    await OPENWORLD.Config.updatePoolObjects();

    OPENWORLD.Config.forceShowPoolObjects();
```

It is also possible given an pool object you get find its positionjson information. In the example below ppositionjson will have ppositionjson['p'] as 10,10,0 and 't' will be 35 so for example in callbackonvisible know what positionjson it belongs to and below if its a blacksmith will play a hammering sound.
   -getting the json based on the actor so can know position and vice versa, given an position get the actor associated if visible
```
   OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name':  'citizen3',
              'p': [10,10, 0],   't': 35,
              'label':'blacksmith',
              'action': "idle",
                "callbackonvisible":(actor) {
                  var positionjson = OPENWORLD.Config.getPositionForObject(actor);
                  if (positionjson['label']=='blacksmith')
                    OPENWORLD.Sound.play(path: "sounds/hammer.mp3");
                },
            });

    // Also possible to get the object associated with the positionjson if it is visible
    var actor = OPENWORLD.Config.getPoolPositionObject(  positionjson);
    if (actor!=null) {
       OPENWORLD.Space.objTurnLerp(actor,35,1);
    }
```
  
*Common objects*    
Openworld includes some useful objects like fire, water, flares, smoke and sky. Most are based on those  available in threejs as shaders. 

- Water
  The following is an example of water:
<img width="300" alt="image" src="https://github.com/user-attachments/assets/de67d132-ddea-46c8-b08f-87ad39534f68" />

Here have set to incluseiveonly so that choose what you want to reflect otherwise can choose what to exclude. Also only calculates reflections once every 4 frames

```
    final waterGeometryi = THREE.PlaneGeometry(20.0, 20.0);
    var watersiloam = Water(waterGeometryi, WaterOptions(
      color: 0xbbddff,
      scale: 4 / 32.0,
      reflectivity: 1.0,
      flowDirection: THREE.Vector2(0.05, 0.05),
      textureWidth: 256,
      textureHeight: 256, 
      inclusiveOnly:true
    ));

    watersiloam.scale.setValues(0.1,0.1, 1.0);
    OPENWORLD.Space.setTurnPitchRoll(Glob.watersiloam!, 0, 0, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(watersiloam!, -9.3-0.4, -52.62, 0.063, 2.5);
    scene.add(watersiloam);

    // Use inclusive where say what want reflected in the pool
    // Choose to include for example the sky, clouds tents
    threeJs.scene.traverse((obj) {
        if (obj is THREE.Mesh && 
            (obj.name== 'skymesh' || obj.name == 'clouds'||   obj.name == 'tentsiloamnormalclotheswall')) 
           Glob.watersiloam.includeInReflection.add(obj);
      });
      // Only calculate the reflections once every 4 frames
      watersiloam.reflectionUpdateInterval =4;

```

- Vegeration
  <img width="300" alt="image" src="https://github.com/user-attachments/assets/ffeca468-17f4-4c6e-9737-6d8669980a1c" />
The vegetation object allows the rendering of vegetation sprites cheaply including grass and shrubs and also detail the ground.
In the example below the surfaceTexture is is set to detailmap.jpg 
```
    // Create vegetation at x,y=5,6 of 20 units in width and height and exclude a point at 2,2 of width and height 0.5
    // Add grass and myrtle
    var grass = Vegetation();
    var grassgroupii = await grass.createGrass(threeJs.camera,
        boundaryWidth: 20,   boundaryLength:20,    worldposx: 5,  worldposy: 6,
        layerFadeAngle: 0.25,
        excludeSquares: [[2,2,0.5,0.5]],  // Exclude regions
        surfaceTexture: SurfaceTextureSpec(
            asset: 'assets/models/temple/detailmap.jpg',
            blendStrength: 0.25,
            tilingScale: 0.3, // texture repeats every 12 world metres
            edgeFade: 0.02
        ),
        plants: [
          PlantSpec(
            spriteAsset: 'assets/shaders/grass.png',
            count: 10000,  // Create a lot of grass sprites
            width: 0.2 / 2,
            height: 0.3,
            billboard: 1,
            flipProbability: 0.5,
          ),
          PlantSpec(
              spriteAsset: 'assets/models/temple/myrtle.png',
              count: 100,
              width: 0.4 ,
              height: 0.6 ,
              billboard: 3,
              heightVariation: 0.3,  // Dont make all the myrtle the same width and height
              widthVariation: 0.3,
              layers: 2,
              flipProbability: 0.5,  // Randomly flip the mytle
              planeSize: 100,
              exclusionOffset: 0.1
          ),
        ],
        heightGridDivisions: 10,
        planeSize: 50);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        grassgroupii,5,6, 0.0,  15);
    scene.add( grassgroupii);

    OPENWORLD.Updateables.add(grassiii);
```  
- Trees
  Can cheap trees made up of transparent planes. In example below  has 3 types of tree section and have 128 out of them. Made quite large so fewer leaves.
  
  <img width="300" alt="image" src="https://github.com/user-attachments/assets/974a3ece-0b53-4c1a-83d2-abccc6e2a7a1" />
```
          var treei = await Tree.createTree([
            ["assets/textures/boxthorn.png", 0.8], // leafscale
            ["assets/textures/boxthorn2.png", 0.8],
            ["assets/textures/boxthorn3.png", 1.4]
          ],
              leafspritescale: 1.2,
              // is redundant because have specified in leafpaths
              spreadx: 3.0,
              spreadz: 3.0,
              spready: 1.0,
              //   useplanes: false,
              leafspritespertree: 128,
              spreadytapertop: 0.5);
```
- Fire

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
<!--
The following is an example of flares:

![image](https://github.com/user-attachments/assets/ee950d2f-7ca7-4a2f-8397-6bf3a9d8269d)
-->

*Asset Pack*

If you upload to steam then your assets will have not protection and can be loaded by anyone. There is an asset pack tool that lets you encrypt your assets to offer some encryption.  It is made to be convenient so that in debug mode you can continue to load your assets like normal  in a new /protected folder but when you do a release instead the assets can be loaded from an archive in your assets/pack directory. You will need to add - assets/packs/ to your pubspec.yaml file.


You can follow instructions in /lib/ASSET_PACK_README.md
```
dart run openworld:pack_assets --gen-key

dart run openworld:pack_assets --in protected --out assets/packs/game.owp


```

*Multi player*  
The rhodes3d demo games include simple multi player capability. But multiplayer is not built into the openworld gaming engine. This might change in the future. Openworld does have a client class with sessions and player information but the actual game play is specific for each demo. The demo multiplayer simply broadcasts a logged in players  position and turn and broadcasting a player action 'wave'. The multiplayer does provide chat and information on whos on. The server side is written in php and mysql as available in the repository in /server

![image](https://github.com/user-attachments/assets/d5114ddf-57ab-46e7-a3ab-54b29215eca7)

Future versions of the library will include multiplayer support that is peer to peer so that no server is required. The games will be hosted by players themselves. 

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


