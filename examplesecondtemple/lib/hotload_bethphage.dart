// This is code specifically for Bethphage journey
// Up at mount of olives in your house with wife and son
// Make your way to the tamid and meet a friend along the way
part of 'SecondTemplePage.dart';

extension HotloadBethphageExt on SecondTemplePageState {
  hotloadBethphage(firsthotload) async {
//// bethphage

    bool teststable=false;  // so you can go down to the stables and to see the stableboy tie up the donkeys
    Map dict = getusedict();// gamestartpos[gamestart];
    Glob.hasreachedsiloam=dict['p'][0]<-7.11||(dict['p'][1]<-21.6&&dict['p'][1]>-30&&dict['p'][0]<2.27)||(dict['p'][1]>-21.6&&dict['p'][0]<11.5);
    var hasbathed=Glob.hasreachedsiloam&&dict['p'][1]> -51.8;
    //var is10am= dict['p'][1]<0.0;// OPENWORLD.Time.setTimeLerp(10, 60);

    var pilgrimspeed = 0.025;

    var goatoffsetx=-0.75;
    var diff = 0.4;
    var points=OPENWORLD.Math.interpolateByIncrement(citizenpathsouth,diff);

    var citizenpathsouthfrienduse=citizenpathsouthfriend.toList();
    citizenpathsouthfrienduse.add([-7.17, -52.83]);//-7.18,-52.69]);  // Add the path up to the water gate otherwise just stops at the bottom
    var pointsfriendsouth=OPENWORLD.Math.interpolateByIncrement(citizenpathsouthfrienduse,diff);

    // Load all the vegetation round bethphage ie Mount of Olives

    //  This is all the areas
    var minmaxlist=[
      [52.0, 72.0, 3.0, 23.0, 0, 0],
      [32.0, 52.0, 3.0, 23.0, 1, 0],
      [12.0, 32.0, 3.0, 23.0, 2, 0],
      [52.0, 72.0, -17.0, 3.0, 0, 1],
      [32.0, 52.0, -17.0, 3.0, 1, 1],
      [12.0, 32.0, -17.0, 3.0, 2, 1],
      [46.0, 66.0, -37.0, -17.0, 0, 2],
      [26.0, 46.0, -37.0, -17.0, 1, 2],
      [6.0, 26.0, -27.0, -17.0, 2, 2],
      [1.0, 26.0, -37.0, -27.0, 2, 2],
      [32.0, 52.0, -57.0, -37.0, 0, 3],
      [12.0, 32.0, -57.0, -37.0, 1, 3],
      [-8.0, 12.0, -57.0, -37.0, 2, 3],
      [27.0, 47.0, -77.0, -57.0, 0, 4],
      [7.0, 27.0, -77.0, -57.0, 1, 4],
      [-13.0, 7.0, -77.0, -57.0, 2, 4]
    ];
    for (var ii=0; ii<minmaxlist.length; ii++) {
      var grassii = Vegetation();
      var minx=minmaxlist[ii][0],maxx=minmaxlist[ii][1],miny=minmaxlist[ii][2],maxy=minmaxlist[ii][3],j=minmaxlist[ii][4],i=minmaxlist[ii][5];
      var boundarywidth2=maxx-minx;
      var boundarylength2=maxy-miny;

      var grassposx=(maxx+minx)/2;
      var grassposy=(maxy+miny)/2;
      List<List<double>> excludeSquares = [];
      print("grassposx"+grassposx.toString()+" "+grassposy.toString()+" "+i.toString()+" "+j.toString()+" "+minx.toString()+" "+maxx.toString()+" "+miny.toString()+" "+maxy.toString());

      for (var point in points) {
        if (point[0] >= minx && point[0] <= maxx && point[1] >= miny &&
            point[1] <= maxy) {
          // if (i==0)
          //   print("point:"+point.toString());
          excludeSquares.add(
              [
                point[0],
                point[1],
                diff,
                diff,
              ]);
        } // bethphagepos),  diff, 0.4]);

      }
      // Add the exclude squares for path south up to water gate
      for (var point in pointsfriendsouth) {
        if (point[1]<-44&&point[0] >= minx && point[0] <= maxx && point[1] >= miny &&
            point[1] <= maxy) {
          // if (i==0)
          //   print("point:"+point.toString());
          excludeSquares.add(
              [
                point[0],
                point[1],
                0.3,
                diff,
              ]);
        } // bethphagepos),  diff, 0.4]);

      }

      if (i == 0&&j==0) {
        excludeSquares.add([57.55, 13.45, 0.4, 0.4]); // bethphage home

      }
      if (i==0&&(j==0||j==1)) {
        var bridgelist = [
          [ 58.70, 4.91],
          [ 55.75, 3.95], //55.30, 3.21],
          [51.41, 1.34], // 51.88, 1.56],
          [ 49.06, 0.58]];
        var pointsbridge = OPENWORLD.Math.interpolateByIncrement(
            bridgelist, 0.5);

        for (var pos in pointsbridge) {
          if (pos[0] >= minx && pos[0] <= maxx && pos[1] >= miny &&
              pos[1] <= maxy) {
            excludeSquares.add([pos[0], pos[1], 0.5, 0.3]); // bethphage home
          }
        }
      } else if (j==1&&i==2) {
        // tombs
        excludeSquares.add([21.28, -10.57, 1.0,2.0]);
        excludeSquares.add([21.17, -12.45, 1.0,1.0]);
        excludeSquares.add([21.13, -7.23,3.0,2.0]);  // absalom


      }
      var squares=[
        [12.38, -19.46,0.5,0.5] ,// olive
        [11.85, -20.36,0.5,0.5] ,// olive
        [11.57, -20.97,0.5,0.5] ,// olive
        [11.26, -21.34,0.5,0.5] ,// olive
        [10.88, -22.00,0.5,0.5] ,// olive
        [10.69, -22.47,0.5,0.5] ,// olive
        [10.19, -23.24,0.5,0.5] ,// olive
        [9.70, -23.94,0.5,0.5] ,// olive
        [7.80, -26.01,0.5,0.5] ,// olive
        [7.23, -26.55,0.5,0.5] ,// olive
        [6.79, -27.03,0.5,0.5] ,// olive
        [6.22, -27.58,0.5,0.5] ,// olive
        [5.65, -28.09,0.5,0.5] ,// olive
        [5.25, -28.52,0.5,0.5] ,// olive
        [13.01-0.5, -22.45,0.5,0.5],
        [12.98-0.5, -22.94,0.5,0.5],
        [ 12.64-0.5, -23.63,0.5,0.5] ,// olive
        [  12.36-0.5, -24.25,0.5,0.5] ,// olive
        [ 12.12-0.5, -24.85,0.5,0.5] ,// olive
        [  12.03-0.5, -25.46,0.5,0.5] ,// olive
        [  11.93-0.5, -26.02,0.5,0.5] ,// olive
        [ 4.31, -32.86,0.5,0.5] ,// olive
        [ 4.16, -33.52,0.5,0.5] ,// olive
        [ 3.98, -34.08,0.5,0.5] ,// olive
        [3.80, -34.58,0.5,0.5] ,// olive
        [3.63+goatoffsetx, -35.03,0.5,0.5] ,// olive
        [3.26+goatoffsetx, -35.78,0.5,0.5] ,// olive
        [3.13+goatoffsetx, -36.31,0.5,0.5] ,// olive
        [2.88+goatoffsetx, -36.87,0.5,0.5] ,// olive
        [2.54+goatoffsetx, -37.39,0.5,0.5] ,// olive
      ];
      for (var square in squares ) {
        if (square[0] >= minx && square[0] <= maxx && square[1] >= miny &&
            square[1] <= maxy) {
          excludeSquares.add([square[0], square[1], square[2],square[3]]); // bethphage home
        }
      }

      var fct;
      if (j<2&&i<2)
        fct=1;
      else  if (j<3)

        fct=0.5;
      else
        fct=0.15;

      var spriteambiencecolor=null;
      if (!OPENWORLD.Time.isDay(OPENWORLD.Time.time)&&OPENWORLD.Time.ambience != null) {
        //spriteMaterial.color = THREE.Color.fromHex32(0x000000);//Time._ambience!.color as THREE.Color;
        spriteambiencecolor = OPENWORLD.Time.ambience!.color as THREE.Color;

      }

      // print("mmmm"+excludeSquares.toString());
      var grassgroup = await grassii.createGrass(threeJs.camera,
          grassShadow: 0.2,
          boundaryWidth: boundarywidth2,
          //3
          boundaryLength: boundarylength2,
          color:spriteambiencecolor,
          edgeFalloff: 0,
          worldposx: grassposx,
          worldposy: grassposy,
          layerFadeAngle: 0.25,
          seed: 9999,
          surfaceTexture: !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?SurfaceTextureSpec(
              asset: 'assets/models/temple/detailmap.jpg',
              blendStrength: 0.25,
              tilingScale: 0.3, // texture repeats every 12 world metres
              edgeFade: 0.02
            //edgeFade: 0.25, // fades over the outer 25% of the boundary
          ):null,
          plants: [
            if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time))
            PlantSpec(
                spriteAsset: 'assets/models/temple/mallow.png',
                count: 100,
                width: 0.6,
                height: 0.4,
                billboard: 1,
                //3,
                flipProbability: 0.5,
                zOffset: 0.02
              //    renderMode: PlantRenderMode.sprite,
            ),
            if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time))
              PlantSpec(
              spriteAsset: 'assets/shaders/grass.png',
              count: 10000,
              width: 0.2 / 2,
              height: 0.3,
              billboard: 1,
              flipProbability: 0.5,
              //     exclusionOffset: 0.01,
              //    renderMode: PlantRenderMode.sprite,
            ),
            if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time))
            PlantSpec(
              spriteAsset: 'assets/shaders/grass2.png',
              count: 1000,
              width: 0.8 / 3,
              height: 0.6 / 3,
              billboard: 1,
              flipProbability: 0.5,
              //     exclusionOffset: 0.01,
              //   renderMode: PlantRenderMode.sprite,
            ),
            PlantSpec(
                spriteAsset: 'assets/models/temple/myrtle.png',
                //shaders/grass2.png',
                count: 50,
                width: 0.4 * 2,
                height: 0.6 * 2,
                billboard: 3,
                heightVariation: 0.3,
                widthVariation: 0.3,
                layers: 2,
                flipProbability: 0.5,
                planeSize: 100,
                exclusionOffset: 0.1
              //   renderMode: PlantRenderMode.sprite,
            ),
            PlantSpec(
                spriteAsset: 'assets/models/temple/olive.png',
                //shaders/grass2.png',
                count: ((350-200)*fct).round(),
                width: 1.3 * 3,
                height: 1.3 * 3,
                billboard: 3,
                heightVariation: 0.3,
                widthVariation: 0.3,
                layers: 2,
                flipProbability: 0.5,
                planeSize: 200,
                edgeFadeWidth: 2,
                exclusionOffset: 0.1
              //   renderMode: PlantRenderMode.sprite,
            ),
            /*  PlantSpec(
                spriteAsset: 'assets/models/temple/cyprus.png',
                //shaders/grass2.png',
                count: 150,
                width: 4,
                height: 12,
                billboard: 3,
                heightVariation: 0.3,
                widthVariation: 0.3,
                layers: 2,
                flipProbability: 0.5,
                planeSize: 200,
                edgeFadeWidth: 5,
                pitchVariation: 0.0, //17
                //  excludeSquares:[[-28.95, 106.26,0.6,0.6]],  //tomb
                //  exclusionOffset: 0.3
                // useFootprintExclusion: true,
                // zOffset: -0.1

                // renderMode: PlantRenderMode.sprite,
              ),*/
            PlantSpec(
                spriteAsset: 'assets/models/temple/figtree.png',
                //shaders/grass2.png',
                count: (100*fct).round(),
                width: 0.9 * 3,
                height: 0.9 * 3,
                billboard: 3,
                heightVariation: 0.3,
                widthVariation: 0.3,
                layers: 2,
                flipProbability: 0.5,
                edgeFadeWidth: 2,
                planeSize: 100,
                exclusionOffset: 0.5
              //   renderMode: PlantRenderMode.sprite,
            ),

          ],
          excludeSquares: excludeSquares,
          showHeightGrid: false,
          heightGridDivisions: 10,
          heightGridColor: 0xff6a00,
          heightGridOffset: 0.0,
          planeSize: 50);


      OPENWORLD.Space.worldToLocalSurfaceObjHide( //pitch            yaw
          grassgroup, grassposx, grassposy, 0.0,
          15); //,lerpopacity: 1.0); //-25.51, 117.12,0, 10);//,normalize2world:true);  //-1.8531121927940284 0.5194031433548219
      hotloadAdd(firsthotload, false, grassgroup);
      OPENWORLD.Updateables.add(grassii);

      ///print("mmmmuuu"+excludeSquares.toString());

      // This is the permanent plants
      if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
        var grassiii = Vegetation();
        //print("mmmm"+excludeSquares.length.toString());
        grassgroup = await grassiii.createGrass(threeJs.camera,
            boundaryWidth: boundarywidth2,
            //3
            boundaryLength: boundarylength2,
            edgeFalloff: 0,
            worldposx: grassposx,
            worldposy: grassposy,

            ///  layerFadeAngle: 0.25,
            seed: 9999,
            plants: [
              PlantSpec(
                  spriteAsset: 'assets/models/temple/olive.png',
                  count: (300 * fct).round(),
                  //350,
                  width: 1.3 * 3 * 2,
                  height: 1.3 * 3 * 2,
                  billboard: 1,
                  //3,
                  heightVariation: 0.3,
                  widthVariation: 0.3,
                  // layers: 2,
                  flipProbability: 0.5,
                  scrolling: false,
                  // planeSize: 200,
                  //edgeFadeWidth: 2,
                  exclusionOffset: 0.1
                //   renderMode: PlantRenderMode.sprite,
              ),
              PlantSpec(
                spriteAsset: 'assets/models/temple/cyprus.png',
                //shaders/grass2.png',
                count: (60 * fct).round(),
                width: 4 * 1.2,
                height: 12 * 1.2,
                billboard: 1,
                //3,
                heightVariation: 0.3,
                widthVariation: 0.3,
                //   layers: 2,
                flipProbability: 0.5,
                scrolling: false,
                //planeSize: 200,
                exclusionOffset: 0.5,
                // edgeFadeWidth: 5,
                pitchVariation: 0.0, //17
              ),


            ],
            excludeSquares: excludeSquares,
            showHeightGrid: false,
            heightGridDivisions: 10,
            heightGridColor: 0xff6a00,
            heightGridOffset: 0.0,
            planeSize: 50);

        OPENWORLD.Space.worldToLocalSurfaceObj(
            grassgroup, grassposx, grassposy,
            0.0); //,lerpopacity: 1.0); //-25.51, 117.12,0, 10);//,normalize2world:true);  //-1.8531121927940284 0.5194031433548219
        hotloadAdd(firsthotload, false, grassgroup);
        OPENWORLD.Updateables.add(grassiii);

      }



    }


    //////
    //// bethphage home
    var wife;
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      // create wife
      wife = await OPENWORLD.Actor.copyActor(
          citizenf2, action: "laysideidle2"); //right");
      //_hotload.add(wife);
      setcancollide(wife, false);
      hotloadAdd(firsthotload, false, wife);
      //  OPENWORLD.Space.objRoll(wife, -15); //+180);
      OPENWORLD.Space.objPitch(wife, -8);
      OPENWORLD.Space.objTurn(wife, 130 + 90); //+180);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          wife, 57.47 + 0.018, 13.53 - 0.008, -0.005, 2, level: 1);
//        wife, 57.47+0.02, 13.53-0.01, 0.015, 2,level:1);
      OPENWORLD.BaseObject.setVisible(
          wife, false,
          groupname: "citizen_1"); //2");  // shoes off - citizen_2 for clothes

      var child12ii = await OPENWORLD.Actor.copyActor(child12, action: "skip");
      hotloadAdd(firsthotload, false, child12ii);
      setcancollide(child12ii, true);

      // Son playing around
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          child12ii, 57.44, 13.10, 0, 2);
      OPENWORLD.Mob.moveToLoop(child12ii,
          [
            {'p': [57.30, 13.2, 0], 'v': pilgrimspeed},
            {'p': [57.45, 13.17, 0], 'v': pilgrimspeed, "action": "walk"},
            { "action": "idle3", "time": 5},
            {'p': [57.52, 13.29, 0], 'v': pilgrimspeed, "action": "walkup"},
            { "action": "idle3", "time": 5},
            {'p': [57.40, 13.40, 0], 'v': pilgrimspeed},
            { "action": "idle3", "time": 5}, //,"duration":8},
            {'p': [57.51, 13.30, 0], 'v': pilgrimspeed, "action": "walk"},
            { "action": "idle3", "time": 5}, //,"duration":8},
            {'p': [ 57.41, 13.18, 0], 'v': pilgrimspeed, "action": "walkup"},
          ],
          // looptype: OPENWORLD.Mob.LoopTypeReverseLoop,
          //  surfaceonly: true,
          fadeout: 1.0,

          ///  duration:1.0,
          action: "skip"
      );
      // Have son say hello
      var saidhello = false;
      OPENWORLD.BaseObject.setDistanceTrigger(
          child12ii, dist: 0.08, event: (action) {
        if (action) {
          if (!saidhello && OPENWORLD.You.level == 0) {
            //print("hi dad");
            OPENWORLD.Space.faceObjectLerp(child12ii, threeJs.camera, 1);
            OPENWORLD.Space.faceObjectLerp(
                child12ii, threeJs.camera, 1, delay: 1.1);
            OPENWORLD.Space.faceObjectLerp(
                child12ii, threeJs.camera, 1, delay: 2.2);
          //  OPENWORLD.Space.faceObjectAlways(child12ii,threeJs.camera);
            OPENWORLD.Mob.setSpeech(child12ii, [
              'Hi Dad!'
            ], z: 90,
                width: 300,
                clearwhendone: true,
                minwait: 3,
                randwait: 0,
                delay: 1,callbackonfinish: (actor) {
                //  OPENWORLD.Space.removeFaceObjectAlways(child12ii,delay:5);

                }
            );
            saidhello = true;
          }
        } else {

        }
      });

      // Roof to bottom of steps
      OPENWORLD.Portal portalgodownstairs=OPENWORLD.Portals.createPortal(
          57.74, 13.42,// 57.67, 13.41,
          0.05,
          0.05,
          57.63, 13.21,// 57.60, 13.47,// 57.67+0.15, 13.41,
          0.0,
          //   marker:_hotload,
          //initturn:180,
          finalturn:180+45,
          level:1,
          level2: 0,
          //   reverse:true,
          angleentry: 140,
          angleentrythresh: 140,
          lerp: 1,
          callback:(){
            print("callback in kitchen");
            OPENWORLD.Space.objTurnLerp(threeJs.camera, 318,1);
          }
      );
      // Top of steps to roof
      OPENWORLD.Portal portalgoupstairs= OPENWORLD.Portals.createPortal(
          57.76, 13.35,// 57.67, 13.41,
          0.04,
          0.04,
          57.7, 13.45,
          //  57.56, 13.49,// 57.60, 13.47,// 57.67+0.15, 13.41,
          0.0,
          finalturn:0,
          //  angleentry: 140,
          //  angleentrythresh: 140,
          level2: 1,
          //  marker: _hotload,
          //   reverse:true,
          lerp: 1);


      //var stairsicon = await OPENWORLD.Sprite.makeTextSprite(
      //       'Stairs ↓', Colors.white, width:200, sizeattentuation: true, scale:0.03,paddingLeft: 5, paddingRight: 5);
      // Show stairs icon
      List<Map> spritemsg=[];
      if (OPENWORLD.System.isDesktop()) {
        spritemsg.add( {'message': 'E', 'textcolor': Colors.white,
          'backgroundcolor': Colors.black,
          'backgroundopacity': 1.0,
          'paddingLeft': 5, 'paddingRight': 5});
      }
      spritemsg.add(
          {'message': 'Stairs ↓', 'textcolor': Colors.white,
            'backgroundcolor': Colors.black,
            'bold':true,
            'backgroundopacity': 0.0}
      );

      var stairsdownicon = await OPENWORLD.Sprite.makeMultiTextSprite( spritemsg, scale:0.03);//, x: x, y: y, z: z);



      hotloadAdd(firsthotload, false, stairsdownicon);
      // Make stair text bigger on a smartphone
      var fct;
      if (OPENWORLD.System.isDesktop())
        fct=1;
      else
        fct=2;
      stairsdownicon.scale.setValues(0.08*0.6*fct,0.02*0.6*fct,1.0);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          stairsdownicon, 57.76+0.06, 13.35, 0.03*fct, 2);
      if (OPENWORLD.System.isDesktop()) {
        // Keybarod callback so if press 'e' go down the stairs
        OPENWORLD.KeyboardCallbacks.createKeyboardCallback(
            'E', object: stairsdownicon,
            0.4,
            facingdiff: 90,
                (keyboardcallback) {
              print("keypressed stairs go down" + keyboardcallback.toString());
              var worldpos = OPENWORLD.You.getWorldPos();
              var closesthit = portalgodownstairs.closestHit(
                  worldpos.x, worldpos.y); // so dont get off the level
              OPENWORLD.Mob.moveTo(threeJs.camera, level: 1,
                  [
                    [
                      closesthit[0],
                      closesthit[1],
                      OPENWORLD.Camera.cameraoffset,
                      0.5
                    ]
                  ],
                  callbackonfinish: (actor) {
                    portalgodownstairs.enter();
                  }
              );
              // OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(
              //    threeJs.camera,57.76+0.06, 13.35,
              //    OPENWORLD.Camera.cameraoffset , 1.0,level:1);

            },
            level: 1);
      }
      //stairsicon = await OPENWORLD.Sprite.makeTextSprite(
      //     'Stairs ↑', Colors.white, width:200, sizeattentuation: true, scale:0.03,paddingLeft: 5, paddingRight: 5);
      // show icon to go up the stairs and also create the keyboadcallback to go up
      spritemsg= [];
      if (OPENWORLD.System.isDesktop()) {
        spritemsg.add( {'message': 'E', 'textcolor': Colors.white,
          'backgroundcolor': Colors.black,
          'backgroundopacity': 1.0,
          'paddingLeft': 5, 'paddingRight': 5});
      }
      spritemsg.add(
        {'message': 'Stairs ↑', 'textcolor': Colors.white,
          'backgroundcolor': Colors.black,
          'bold':true,
          'backgroundopacity': 0.0}
      );
      var stairsupicon = await OPENWORLD.Sprite.makeMultiTextSprite(spritemsg, scale:0.03);//, x: x, y: y, z: z);
      OPENWORLD.BaseObject.setTouchTrigger(stairsupicon,event:(event){
    //  stairsupicon.extra['touchtrigger'].addEventListener(
     //     'trigger', (THREE.Event event) {
        print("touched");
        OPENWORLD.BaseObject.highlight(stairsupicon, true, scale: 1.02, opacity: 0.35);
        //var clickevent = event.action;
       /* setState(() {
          menuposx = clickevent.clientX;
          menuposy = clickevent.clientY - 40;
          menuitems.clear();
          menuitems.add({"text": "The bronze laver is for "});
          menuitems.add({"text": "Aaron, his sons and their successors"});
          menuitems.add({"text": "as priests to wash their hands and "});
          menuitems.add({"text": "their feet before making a sacrifice"});
          menuobj = stairsupicon;*/
        });

      hotloadAdd(firsthotload, false, stairsupicon);

      stairsupicon.scale.setValues(0.08*0.6,0.02*0.6,1.0);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          stairsupicon, 57.59, 13.21, 0.03, 2);
      OPENWORLD.KeyboardCallbacks.createKeyboardCallback('E',object:stairsupicon,0.4, facingdiff: 90,
//    OPENWORLD.KeyboardCallbacks.createKeyboardCallback('E', 57.76+0.06, 13.35,0.4,
              (keyboardcallback) {
            if (OPENWORLD.You.room==roomBethphage) {
              print("keypressed stairs go up" + keyboardcallback.toString());
              var worldpos = OPENWORLD.You.getWorldPos();
              var closesthit = portalgoupstairs.closestHit(
                  worldpos.x, worldpos.y); // so dont get off the level
              OPENWORLD.Mob.moveTo(threeJs.camera, level: 0,
                  [
                    [
                      closesthit[0],
                      closesthit[1],
                      OPENWORLD.Camera.cameraoffset,
                      0.5
                    ]
                  ],
                  callbackonfinish: (actor) {
                    portalgoupstairs.enter();
                  }
              );
            }
          });

      //
      roomBethphage = OPENWORLD.Room.createRoom(57.55, 13.41,
          soundpath: !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/indoors.mp3":null,randomsoundpaths: ["sounds/chickens.mp3","sounds/bah.mp3"],
          randomsoundvolume:0.05, randomsoundgap: 100, name:"bethphage",
          volume: 0.1,exitroom: roomTerrain); //THREE.Object3D();

     // roomBethphage.extra['name']='bethphage';
      roomBethphage.extra['guide'] = [
        "You are at your house at bethphage.",
      ];
      //OPENWORLD.Room.setIndoors(roomBethphage,true);
      OPENWORLD.Room.setAutoIndoors(roomBethphage, true);
      _hotload.add(roomBethphage);

      OPENWORLD.Room.setDistanceTrigger(roomBethphage,
          maxy: 13.65,
          miny: 12.96,
          minx: 57.28,
          // 57.1,
          maxx: 57.86,
          event: (action) {
            //  maxy: 13.67, miny: 13.13, minx: 57.28, maxx: 57.73, event:(action) {
            if (action) {
              OPENWORLD.Space.readdObjFromHide(stairsupicon);
              OPENWORLD.Space.readdObjFromHide(stairsdownicon);
              stairsupicon.visible=true;
              stairsdownicon.visible=true;
              setState(() {
                // Lower to the ground if indoors

                  OPENWORLD.Camera.cameraoffset =
                      Glob.defaultcameraoffset * 0.75;
                //  print("offset 0.75 bethphage");
                //}
                if (mounted)
                  roomname = "Bethphage Home";
              });
            } else {
              // Wqve goodbye to her husband as he leaves
              OPENWORLD.Space.removeObjFromHide(stairsupicon);
              OPENWORLD.Space.removeObjFromHide(stairsdownicon);
              stairsupicon.visible=false;
              stairsdownicon.visible=false;
              saveGameState('lefthome');  // Save game state that left home
              if (gamestart==GameStart.bethphage) {
                // wife and son say good bye when you leave
                OPENWORLD.Mob.moveTo(
                    wife, [
                  [57.40, 13.21, 0, pilgrimspeed * 2],
                  // get there quick before he's gone  57.49, 13.26
                ], action: "walk",
                    stopaction: "idle",
                    callbackonfinish: (actor) {
                      OPENWORLD.Actor.playActionThen(wife, "wave", "idle");
                      OPENWORLD.Mob.setSpeech(wife, [
                        'Be safe'
                      ], z: 100,
                          scale: 0.4,
                          minwait: 5,
                          randwait: 0,
                          width: 300
                      );

                      OPENWORLD.Mob.setSpeech(child12ii, [
                        'Bye Dad'
                      ], z: 100,
                          width: 300,
                          clearwhendone: true,
                          minwait: 3,
                          randwait: 0,
                          delay: 1
                      );
                    }

                );
              }

              OPENWORLD.Camera.cameraoffset =
                  Glob.defaultcameraoffset;
              setState(() {
                if (mounted)
                  roomname = "";
              });
            }
          }
          );
    }
    // On roof
    var matvii = mati.clone();
    hotloadAdd(firsthotload, false, matvii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matvii, 57.56-0.02, 13.49, 0.00, 2, level:1);
    OPENWORLD.Space.objTurn(matvii,130);

    var pillow5 = pillow.clone();
    hotloadAdd(firsthotload, false, pillow5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pillow5,  57.59, 13.50, 0.0, 2,level:1);//57.56, 13.49
    OPENWORLD.Space.objTurn(pillow5, 130);

    var pillow7 = pillow.clone();
    hotloadAdd(firsthotload, false, pillow7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pillow7,  57.52+0.01-0.012, 13.54+0.01, 0.00, 2,level:1);//57.56, 13.49
    OPENWORLD.Space.objTurn(pillow7, 130);


    var matviiii = mati.clone();
    hotloadAdd(firsthotload, false, matviiii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matviiii, 57.47+0.02, 13.53-0.01, 0.00, 2, level:1);
    OPENWORLD.Space.objTurn(matviiii,130);

    // kitchen
    var boardposx = 57.64+0.01;
    var boardposy = 13.44-0.08;
    var plate9 = plate.clone();
    hotloadAdd(firsthotload, false, plate9);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        plate9, boardposx + 0.03-0.08, boardposy + 0.025-0.03, 0.011,
        2);
    // This leavened bread
    var bread4=bread.clone();
    _hotload.add(bread4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bread4,     57.66, 13.34, 0.01, 2);
    OPENWORLD.Space.objTurn(bread4, OPENWORLD.Math.random()*360);
    var bread5=bread.clone();
    _hotload.add(bread5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bread5,      57.66, 13.34+0.02, 0.01, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(bread5, OPENWORLD.Math.random()*360);

    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      // When player on roof at bethphage and first moves to get up - wife gets up too and offers to make breakfast
      firstmovebethphage() async {
        OPENWORLD.Actor.playActionThen(
            wife, "kneel", "squatwork", delay: 2);
        OPENWORLD.Space.faceObjectLerp(
            wife, threeJs.camera, 1, delay: 2);
        // OPENWORLD.Actor.playActionThen(wife, "laysideidle", "squatwork",delay:2);

        //  OPENWORLD.Actor.playActionThen(wife, "laysideidle", "kneel",delay:2);
        //  OPENWORLD.Actor.playAction(wife, action: "squatwork");
        OPENWORLD.Space.objPitch(wife, 0);
        // Check if you are looking at your wife
        var ticks = 0;
        var hasstarted = false;

        Timer.periodic(const Duration(seconds: 1), (timer) async {
          // var angle=OPENWORLD.Space.getAngleBetweensObjs(threeJs.camera, wife);
          // var anglediff=OPENWORLD.Math.angleDifference(OPENWORLD.Camera.turn,angle);
          // print("anglediff"+anglediff.toString()+' '+angle.toString()+" "+OPENWORLD.Camera.turn.toString());
          if (ticks > 6 && OPENWORLD.You.isfacing(wife, 45) &&
              OPENWORLD.You.level == 1 && !hasstarted) { //anglediff.abs()<45) {
            hasstarted = true;
            //     OPENWORLD.Space.faceObjectLerp(threeJs.camera, wife,1);
             OPENWORLD.Space.faceObjectLerp( wife, threeJs.camera,1);
            OPENWORLD.Space.faceObjectLerp( wife, threeJs.camera,1,delay:6);
            // If looking at your wife then she asks if you want some breakfast
            OPENWORLD.Actor.playAction(
                wife, action: "squat", duration: 2); //reclineidle");
            OPENWORLD.Mob.setSpeech(wife, [
              'Want some breakfast?',
              "I'll get you some bread"
            ], z: 60,
                scale: 0.4,
                minwait: 5,
                randwait: 0,
                width: 300,
                clearwhendone: true,
                delay: 1,
              callbackonfinish: (actor) {

                print("going down the stairs");
                // Then she goes to the kitchen
                var wifespeed=0.04;
                OPENWORLD.Mob.moveTo(
                    wife, [
                  [57.76, 13.41, 0, wifespeed, null, 1],
                  //
                  [57.80, 13.35, 0, wifespeed],
                  // top stairs
                  [57.60, 13.19, 0, wifespeed],
                  // bottom of stairs
                  [57.51, 13.28, 0,wifespeed],
                  //57.39, 13.42
                  [57.57, 13.37, 0, pilgrimspeed],
                  // food table 57.53, 13.36  57.59, 13.35
                ], action: "walk",
                    stopaction: "squatwork",
                    callbackonfinish: (actor) async {
                      var sitposx=57.57;
                      var sitposy=13.37;

                      OPENWORLD.Space.objTurnLerp(wife, 121, 1); //146, 1);
                      // OPENWORLD.Space.faceObjectLerp(wife,threeJs.camera, 1,delay:2)

                      var ticks2 = 0;
                      Timer.periodic(const Duration(seconds: 1), (timer2) async {
                        if (OPENWORLD.Space.getDistanceBetweenObjs(
                            threeJs.camera, wife) < 0.3 &&
                            OPENWORLD.You.isfacing(wife, 45) &&
                            OPENWORLD.You.level == 0) {
                          setcancollide(wife, true);

                          //OPENWORLD.Space.faceObjectLerp(wife,threeJs.camera, 1,delay:2);
                          //  OPENWORLD.Actor.playAction(wife, action: "squat",duration:2);//reclineidle");

                          var breadunleaven2 = breadunleaven.clone();
                          plate9.add(breadunleaven2);

                          OPENWORLD.Mob.setSpeech(wife, [
                            'Here you go',
                          ], z: 60,
                              scale: 0.4,
                              minwait: 5,
                              randwait: 0,
                              width: 300,
                              clearwhendone: true,
                              delay: 5
                          );
                          Future.delayed(Duration(milliseconds: 7000), () async {
                            OPENWORLD.Mob.moveTo(
                                wife, [
                              [57.63, 13.43, 0, pilgrimspeed],
                              // food table 57.53, 13.36
                            ], action: "walk",
                                stopaction: "squatwork",
                                callbackonfinish: (actor) {
                                  OPENWORLD.Space.faceObjectLerp(
                                      actor, bread4, 1.0);
                                }
                            );
                            // You are sat down at your breakfast and eat
                            OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(
                                threeJs.camera, sitposx,sitposy,//57.57, 13.37,
                                OPENWORLD.Camera.cameraoffset / 2, //57.59, 13.35
                                1.0);
                            OPENWORLD.You.setImmobile(true, delay: 1);
                            OPENWORLD.Space.objTurnLerp(
                                threeJs.camera, 96,1);//121, 1); //146, 1);
                            OPENWORLD.You.setImmobile(false, delay: 4);
                            OPENWORLD.Camera.setPitch(-10);

                            eatbread(breadunleaven2,10,bitetime:4.0);
                            Future.delayed(Duration(milliseconds: 7000), () async {
                              print("move handler wife");
                              OPENWORLD.Actor.playAction(wife, action: "squatworkright", delay:5);
                              OPENWORLD.Actor.playAction(wife, action: "squatwork", delay:15);
                              //  OPENWORLD.Space.faceObjectLerp(wife,threeJs.camera,1, delay:7+15);
                              OPENWORLD.Mob.setSpeech(wife, [
                                "Here is your breakfast.",
                                'Hope its enough for your',
                                'trip to Jerusalem.',
                                '',
                                'That was quick.',
                                "Finished already.",
                                'You better hurry',
                                "if you don't want to miss",
                                'the Tamid'
                              ], z: 40,
                                  y:-40,
                                  x:20,
                                  scale: 0.2,
                                  minwait: 5,
                                  randwait: 0,
                                  width: 300,
                                  clearwhendone: true,
                                tails:{'bottomleft'},
                              //  delay:7,
                                callbackonfinish: (actor){
                                  OPENWORLD.Actor.playAction(wife, action: "idle", delay:5);

                                }
                              );
                              OPENWORLD.Camera.setPitch(-6);
                              hasmovedhandler = () {
                                print("this handler");
                                OPENWORLD.Camera.setPitch(0);
                                OPENWORLD.Camera.cameraoffset =
                                    Glob.defaultcameraoffset; //*0.75;
                                OPENWORLD.Mob.placeBeforeCamera(
                                    wife, 0.05, action: "walk",
                                    stopaction: "idle",
                                    time: 2);

                                OPENWORLD.Mob.setSpeech(wife, [
                                  'You better get going'// hurry',
                                 // "if you don't want to miss",
                                  //'the Tamid'
                                ], z: 80,
                                    scale: 0.2,
                                    minwait: 5,
                                    randwait: 0,
                                    width: 300,
                                    clearwhendone: true,
                                    delay: 2
                                );

                                OPENWORLD.Mob.moveTo(
                                    wife, [
                                  [57.63, 13.43, 0, pilgrimspeed],
                                  // food table 57.53, 13.36
                                ], action: "walk",
                                    stopaction: "squatwork",
                                    callbackonfinish: (actor) {
                                      OPENWORLD.Space.faceObjectLerp(
                                          actor, bread4, 1.0);
                                    },
                                    delay: 15);
                              };
                            });

                          });

                          timer2.cancel();
                        }
                        if (ticks2 > 100)
                          timer2.cancel();
                        ticks2++;
                      });
                    });

              }
            );


            timer.cancel();
          } else if (ticks > 100)
            timer.cancel();
          ticks++;
        });
      }
      if (gamestart == GameStart.bethphage)
        hasmovedhandler =
            firstmovebethphage; // When player first moves then call this once

    }

    var pot17 = pot.clone();
    hotloadAdd(firsthotload, false, pot17);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot17, 57.43, 13.39,0,// 57.50, 13.56,0,//57.46, 13.48, 0,
        2, level:1);

    var lamp4 = lamp.clone();
    hotloadAdd(firsthotload, false, lamp4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        lamp4,57.58, 13.40, 0.005,
        2,level:1);

    var clothespileii = clothespile.clone();
    _hotload.add(clothespileii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clothespileii, 57.63, 13.47, 0.001, 2,level:1);

    var clothespileiii = clothespile.clone();
    _hotload.add(clothespileiii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clothespileiii,57.54, 13.60, 0.001, 2,level:1); //57.51, 13.55

    // Ground floor
    var tableposx= 57.56+0.07;
    var tableposy= 13.49;
    var table8 = table.clone();
    hotloadAdd(firsthotload, false, table8);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        table8, tableposx,tableposy,0.0,2);//-16.93, -45.43, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(table8, 95+40);

    var chisel5=chisel.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        chisel5, tableposx-0.02,tableposy+0.05-0.05,0.058,//-16.93, -45.38, 0.057,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    // _hotload.add(chisel);
    hotloadAdd(firsthotload, false, chisel5);


//    hammer.children[0].scale.setValues(0.1, 0.1, 0.1);
    // OPENWORLD.Space.setTurnPitchRoll(hammer.children[0], 90, 90, 90);
    var hammer5=hammer.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hammer5, tableposx-0.01-0.02,tableposy+0.05-0.05,0.057,//-16.94, -45.38, 0.057,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    //_hotload.add(hammer);
    hotloadAdd(firsthotload, false, hammer5);


    var saw4=saw.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        saw4, tableposx+0.01-0.02,tableposy+0.05-0.05,0.059,//-16.92, -45.38, 0.059,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    //_hotload.add(saw);
    hotloadAdd(firsthotload, false, saw4);
    OPENWORLD.Space.objRoll(saw4, 90);


    //_hotload.add(amphora);
    var amphora10=amphora.clone();
    hotloadAdd(firsthotload, false, amphora10);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora10, 57.77-0.01, 13.43,0,// boardposx, boardposy, 0.01,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);

    var boardv = board.clone();
    //  _hotload.add(boardii);
    hotloadAdd(firsthotload, false, boardv);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        boardv, boardposx, boardposy, 0.005,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    boardv.scale.setValues(0.011, 0.011, 0.011);
    OPENWORLD.Space.objTurn(boardv, 95+40);
    var pot16 = pot.clone();
    //  _hotload.add(pot3);
    hotloadAdd(firsthotload, false, pot16);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot16, boardposx - 0.04, boardposy + 0.02-0.06, 0.01,
        2); //-16.79, -45.47,0.0,2);//-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);
    //  _hotload.add(cup);
    var cup17=cup.clone();
    hotloadAdd(firsthotload, false, cup17);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup17, boardposx, boardposy + 0.025, 0.01, 2);
    var cup18 = cup.clone();
    //_hotload.add(cup2);
    hotloadAdd(firsthotload, false, cup18);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup18, boardposx - 0.015, boardposy + 0.025, 0.005,
        2);
    var mortar5 = mortar.clone();
    hotloadAdd(firsthotload, false, mortar5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mortar5, boardposx - 0.01, boardposy + 0.035, 0.01,
        2);
    var matviiiii = mati.clone();
    hotloadAdd(firsthotload, false, matviiiii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matviiiii,57.56+0.03, 13.42-0.04, 0.005, 2);
    OPENWORLD.Space.objTurn(matviiiii,130);



    var matrolled6 = matrolled.clone();
    // _hotload.add(matrolled2);
    hotloadAdd(firsthotload, false, matrolled6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matrolled6, 57.56, 13.59-0.04, 0, 2);

    var matviii = mati.clone();
    hotloadAdd(firsthotload, false, matviii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matviii,57.48, 13.52, 0.005, 2);
    OPENWORLD.Space.objTurn(matviii,130);
    var pillow6 = pillow.clone();
    hotloadAdd(firsthotload, false, pillow5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pillow6,  57.43, 13.47, 0.01, 2);//57.56, 13.49
    OPENWORLD.Space.objTurn(pillow6, 130);

    var basket12 = basket.clone();
    hotloadAdd(firsthotload, false, basket12);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket12, 57.53, 13.63, 0,
        2);
    var shovel4 = shovel.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        shovel4, 57.62, 13.53, 0.0,
        2);
    hotloadAdd(firsthotload, false, shovel4);
    OPENWORLD.Space.setTurnPitchRoll(shovel4, 90, 10, 0);

    var pitchfork8 = pitchfork.clone();
    pitchfork8.children[0].scale.setValues(0.01, 0.01, 0.01);
    OPENWORLD.Space.setTurnPitchRoll(pitchfork8.children[0], 90, 90, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pitchfork8,57.70, 13.46, 0,
        2);
    hotloadAdd(firsthotload, false, pitchfork8);

    var jug9=jug.clone();
    _hotload.add(jug9);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        jug9,    57.49+0.02, 13.41, 0.01, 2);
    var basket13 = basket.clone();
    hotloadAdd(firsthotload, false, basket13);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket13, 57.54, 13.43, 0,
        2);
    var mortar4 = mortar.clone();
    hotloadAdd(firsthotload, false, mortar4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mortar4, 57.38, 13.45, 0.0,
        2);

    var ovenposx = 57.27; //-16.85;
    var ovenposy = 13.34; //-45.25;
    //   _hotload.add(oven);
    var oven3=tannur.clone();
    hotloadAdd(firsthotload, false, oven3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        oven3, ovenposx, ovenposy, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(oven3, 180); //+180);

    var fence3vii = fence3.clone();
    // _hotload.add(fence3v);
    hotloadAdd(firsthotload, false, fence3vii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3vii, 57.47, 13.13, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence3vii, 130);
    fence3vii.scale.setValues(0.017, 0.012, 0.012);

    var sheep15 = await OPENWORLD.Actor.copyActor(
        sheeporig, duration: 6, randomduration: 1);
    // _hotload.add(sheep6);
    hotloadAdd(firsthotload, false, sheep15);
    OPENWORLD.Space.objTurn(sheep15.children[0], 0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheep15, 57.51, 13.09, 0.0,
        2);
    OPENWORLD.Space.objTurn(sheep15, 0);

    var hay25= hay.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay25, 57.51, 13.09, 0.0, 2);
    // _hotload.add(hay14);
    hotloadAdd(firsthotload, false, hay25);
    var hay26= hay.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay26, 57.51+0.02, 13.09, 0.0, 2);
    // _hotload.add(hay14);
    hotloadAdd(firsthotload, false, hay26);


    // Second house
    basket12 = basket.clone();
    hotloadAdd(firsthotload, false, basket12);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket12,  58.30, 11.44, 0,
        2);
    shovel4 = shovel.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        shovel4, 58.23, 11.47, 0.0,
        2);
    hotloadAdd(firsthotload, false, shovel4);
    OPENWORLD.Space.setTurnPitchRoll(shovel4, 90, 10, 0);
     matviii = mati.clone();
    hotloadAdd(firsthotload, false, matviii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matviii,58.4-0.1, 11.53, 0.005, 2);
    OPENWORLD.Space.objTurn(matviii,130);

    // sometimes there is a cat around
    if (OPENWORLD.Math.random()<0.1) {
      var cat2 = await OPENWORLD.Actor.copyActor(
         cat, action: "idle"); //"shovel");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cat2,57.77, 13.1, 0, 0.5, lerpopacity: 1.0); //15.04, 6.73

      OPENWORLD.Space.objTurn(cat2, 0);
      _hotload.add(cat2);

      // Cat meows when you get near
      OPENWORLD.BaseObject.setDistanceTrigger(cat2,
          dist: 0.2, event: (action) {
            if (action) {
              if (OPENWORLD.Math.random()<0.1)
                OPENWORLD.Sound.play(path: 'sounds/meow.mp3',
                  volume: 0.05,
                  delay: OPENWORLD.Math.random() * 5);
              OPENWORLD.Mob.randomwalk(
                cat2, 0.1, 0.02, 0.1, // -17.4,-45.9, 0.1, //1, 0.15
                action: "walk",
                actionduration: 2, //0.5,
                stopaction: "idle",
             //   reset: true,
              );
              //  citizen.visible = true;
            } else {
              //   citizen.visible = false;
            }
          });
    }

    // sometimes there is a dog around
    if (OPENWORLD.Math.random()<0.1) {
      var dog2 = await OPENWORLD.Actor.copyActor(
          wilddog, action: "idle"); //"shovel");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          dog2,56.80, 12.46, 0, 1.0, lerpopacity: 1.0); //15.04, 6.73

      OPENWORLD.Space.objTurn(dog2, 0);
      _hotload.add(dog2);

      // Cat meows when you get near
      OPENWORLD.BaseObject.setDistanceTrigger(dog2,
          dist: 0.2, event: (action) {
            if (action) {
              OPENWORLD.Sound.play(path: 'sounds/bark.mp3',
                  volume: 0.05,
                  delay: OPENWORLD.Math.random() * 5);
              OPENWORLD.Mob.randomwalk(
                dog2, 0.1, 0.02, 0.1, // -17.4,-45.9, 0.1, //1, 0.15
                action: "walk",
                actionduration: 1, //0.5,
                stopaction: "idle",
                //   reset: true,
              );
              //  citizen.visible = true;
            } else {
              //   citizen.visible = false;
            }
          });
    }
    // sometimes your neighbours are out chatting
    if (OPENWORLD.Math.random()<0.1&&!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      createNeightboursChatting(58.5+0.02 ,11.36,90-45, 58.58, 11.43,'women');
    }

    // sometimes your neigbhour is raking
    if (OPENWORLD.Math.random()<0.2&&!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var neighbour = await OPENWORLD.Actor.copyActor(
          citizen2, action: "shovel");
      var pitchfork2 = pitchfork.clone();
      OPENWORLD.Space.setTurnPitchRoll(pitchfork2.children[0], 90, 0, 0);
      // OPENWORLD.Space.objRoll(pitchfork.children[0], 90);
      //  OPENWORLD.Space.objTurn(pitchfork.children[0], 20 + 180);
      OPENWORLD.Actor.wield(neighbour, pitchfork2, "Bip01_L_Hand");
      OPENWORLD.Space.objPitch(neighbour, -8);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(neighbour, 58.63, 13.09, 0, 2);
      _hotload.add(neighbour);
      var rakingsound = OPENWORLD.Sound.getAudioPlayer();
      OPENWORLD.BaseObject.setDistanceTrigger(neighbour,
          dist: 0.5, event: (action) {
            if (action) {
              OPENWORLD.Sound.play(sound: rakingsound,
                  path: 'sounds/raking.mp3',
                  volume: 0.1,
                  loop: true,
                  fadein: 1.0
              );
              OPENWORLD.Space.faceObjectLerp(neighbour, threeJs.camera, 1);
              OPENWORLD.Space.faceObjectLerp(
                  neighbour, threeJs.camera, 1, delay: 5);
              OPENWORLD.Mob.setSpeech(neighbour, [
                'Shalom' // hurry',
              ], z: 80,
                  scale: 0.2,
                  minwait: 5,
                  randwait: 0,
                  width: 300,
                  clearwhendone: true,
                  delay: 2
              );

              //  citizen.visible = true;
            } else {
              OPENWORLD.Sound.fadeOut(rakingsound, 5.0);
              //   citizen.visible = false;
            }
          });
    }

    // Sometimes your neigbhours cow is out
    if (OPENWORLD.Math.random()<0.4) {
      var cow = await OPENWORLD.Actor.copyActor(
          _cow, randomduration: 0.1, duration: 2);
      _hotload.add(cow);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cow, 57, 12.08, 0, 3);

      OPENWORLD.BaseObject.setDistanceTrigger(
          cow, dist: 1.0, event: (action) async {
        if (action) {
          print("in cow");
          var moo = ((OPENWORLD.Math.random() * 3) + 1).floor().toString();
          OPENWORLD.Sound.play(delay: OPENWORLD.Math.random() * 10,
              path: 'sounds/moo' + moo + '.mp3',
              volume: 0.5);
          // var starttime=OPENWORLD.System.currentMilliseconds();
        }
      });
    }

    // Sometimes neighbour has cart out on the street
    if (OPENWORLD.Math.random()<0.3&&!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var cart2 = await OPENWORLD.Actor.copyActor(cart,
          action: "idle"); //await OPENWORLD.Model.createModel('assets/models/cart.glb');
      _hotload.add(cart2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cart2, 57.77 + 0.1, 12.13, -0.01, 2); // 3.2,2.5, 0.0);
      // cart.scale.setValues(0.01 * convscale, 0.01 * convscale,
      //     0.01 * convscale);
      OPENWORLD.Space.objTurn(cart2, 90 + 45);
      var figs2 = figs.clone();
      // figs.scale.setValues(5.0,5.0,5.0);
      cart2.add(figs2);
    }

    // sometimes two kids playing
    if (OPENWORLD.Math.random()<0.3&&!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var childgirliv = await OPENWORLD.Actor.copyActor(
          childgirl, action: "walkup");//,duration:1.0);
      _hotload.add(childgirliv);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          childgirliv, 58.03, 12.45, 0.00,
          2);
      OPENWORLD.Space.objTurn(childgirliv, 0);

      var girlspeed = 0.07;
      OPENWORLD.Mob.moveToLoop(childgirliv,
          [
            {'p': [58.03, 12.45, 0], 'v': girlspeed},
            {'p': [57.54, 12.91, 0], 'v': girlspeed},
            {'p': [57.39, 12.55, 0], 'v': girlspeed},
            {'p': [57.76, 12.19, 0], 'v': girlspeed},
            /*  {'p':[57.97,13.36, 0],'v': girlspeed},
          {'p':[58.05,13.3, 0],'v': girlspeed},
          {'p':[58.38,13.57, 0],'v': girlspeed},
          {'p':[59.04, 13.05, 0],'v': girlspeed},*/
            { "action": "idle3", "time": 10},
            { "action": "starjump", "time": 10},
          ],

          //  duration:0.7,
          //  index:0,
          randomduration: 0.1,
          //  reverseloop:true,
          surfaceonly: true,
          action: "walkup" //straight"
      );

      var child1ii = await OPENWORLD.Actor.copyActor(child1, action: "idle3");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          child1ii, 57.83, 12.68, 0, 2);
      ;
      _hotload.add(child1ii);
      OPENWORLD.Space.objTurn(child1ii, 0);
      OPENWORLD.Space.faceObjectAlways(child1ii, childgirliv);
    }


    final finalsiloamposx=-8.1;
    final finalsiloamposy=-52.3-0.1;


    // Callback to sing a psalm  as go up pilgrims road
    var lastverse = null;
    psalm(actor, { first = true, againy}) {

        // verselines.insert(0,"Lets sing a psalm");
        //if (first)
          lookback(actor);
        OPENWORLD.Mob.setSpeech(actor,

            [first ? "Let's sing a psalm of the ascent" : OPENWORLD.Math.randPick(["One more?","How about another?"])], z: 90,
            width: 300,
            clearwhendone: true,
            minwait: 5,
            scale: 0.3,
            randwait: 0,
            callbackonfinish: (actor) {
              var verse;
              if (lastverse == null)
                verse = OPENWORLD.Math.randPick(travelsongs); //rabbitexts);
              else
                verse = OPENWORLD.Math.randPick(
                    travelsongs, exclude: [lastverse]); //rabbitexts);
              lastverse = verse;
              var verselines = OPENWORLD.Mob.chopText(verse['text']);
              OPENWORLD.Mob.setSpeech(actor,
                  verselines, z: 90,
                  width: 300,
                  clearwhendone: true,
                  minwait: 5,
                  scale: 0.4,
                  randwait: 0,
                  delay: 2,
                  callbackonfinish: (actor) {
                    if (actor
                        .visible&&againy!=null) { //&&OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, actor)<)
                      var friendposition = OPENWORLD.Space.localToWorldObj(
                          actor);
                      // If more time then do another psalm
                      //74
                      if (friendposition.y < againy &&
                          OPENWORLD.Space.getDistanceBetweenObjs(
                              threeJs.camera, actor) < 1)
                        psalm(actor, againy: againy, first: false);
                    }
                  });
            }
          //   delay:9
        );

    }

    pastsiloam()
    {
      friendbethphagegroup!.extra['friend'].visible=false;
      friendbethphagegroup!.extra['friendold'].visible=true;

    }

    // Have your friend look back at you at the tamid
    tamidlookback(actor) {
      if (!actor.extra.containsKey('inlookback')) {
        actor.extra['inlookback']=true;
        var currentturn = OPENWORLD.Space.getObjTurn(actor);
       // OPENWORLD.Space.faceObjectLerp(actor,threeJs.camera,1);
        OPENWORLD.Actor.playAction(
            actor, action: "lookright", //clampWhenFinished: true,
            //   stopallactions: true,
            delay: 1.0);
        OPENWORLD.Space.objTurnLerp(
            actor, currentturn + 80, 1, delay: 1.0); //-90, 1, delay: 1.0);
        Future.delayed(
            Duration(
                milliseconds: 5000), () async {
          OPENWORLD.Space.objTurnLerp(
              actor, currentturn, 1);//, delay: 5.0);
          OPENWORLD.Actor.playAction(
              actor, action: "idle3", //clampWhenFinished: true,
              //   stopallactions: true,
              delay: 1.0);
          actor.extra.remove('inlookback');

        });
      }
    }

    // Have you and your friend watch the finale of the tamid
    tamidfinal()
    {
      print('start tamid final');
      OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['friendold'], action: "idle");
      // start final tamid
      var courtisraelpositions=OPENWORLD.Config.getPositionsByLabel( OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'], 'courtisrael');

      for (var i =0 ; i < courtisraelpositions.length; i++) {
        var positionjson=courtisraelpositions[i];
        List pos=positionjson?['p'];
        if (gamestart==GameStart.bethphage&&pos[1]<0.1) {
          var actor = OPENWORLD.Config.getPoolPositionObject(
              positionjson);
          if (actor != null) {
            OPENWORLD.Space.faceObjectAlways(actor,  Glob.hewnstonpriestlist[1]);// Glob.priestfirepan);
          }
        }
      }
      friendbethphagegroup!.extra['followingfriend'] = false;
      OPENWORLD.Space.faceObjectAlways(friendbethphagegroup!.extra['friendold'], Glob.hewnstonpriestlist[1],delay:2);//Glob.priestfirepan);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          friendbethphagegroup!.extra['friendold'],  5.17, -0.38,0,// 5.17, -0.38+0.1,0,//5.14, 0.55+0.1, 0,
          3,
          level: 1);
      // Call the general tamid final in second temple now that have set everything up with your friend
      Glob.tamidfinal!(Glob.hewnstonpriestlist,
          callbackonfinish: () {
            // When the tamid final is finished you and your friend prostrate
            OPENWORLD.Space.removeFaceObjectAlways(friendbethphagegroup!.extra['friendold']);
            OPENWORLD.Space.objTurnLerp(friendbethphagegroup!.extra['friendold'],270,1);

            OPENWORLD.Actor.playActionThen(
                friendbethphagegroup!.extra['friendold'], "kneel", "prostrate", duration:3 ,delay:OPENWORLD.Math.random()*2 );
            // Do the priests in the chamber of the hewnstone - they shouldn't be standing at the end of the tamidfinal
            for (var priest in [...Glob.sixpriests, ...Glob.threepriests]) {
                OPENWORLD.Space.objTurnLerp(priest, 270+45, 1);
                if (priest.extra.containsKey("wielding")) {
                  OPENWORLD.Actor.unwield(priest, "Bip01_R_Hand");
                  OPENWORLD.Actor.unwield(priest, "Bip01_L_Hand");
                }
                OPENWORLD.Actor.playActionThen(
                    priest, "kneel", "prostrate",
                    delay:1+ OPENWORLD.Math.random() * 2);
                //OPENWORLD.Actor.playAction(
                //     priest, action: "prostrate",
                //    delay: 3 + OPENWORLD.Math.random() * 2);
            }



            OPENWORLD.Camera.cameraoffset=Glob.defaultcameraoffset*0.75;
            OPENWORLD.Space.setZ(
                threeJs.camera,
                OPENWORLD.Camera.cameraoffset*0.75, level: 1,delay:1);
            OPENWORLD.Space.objTurnLerp(threeJs.camera, 280,1,delay:1);
            Future.delayed(Duration(milliseconds: 10000), () async {
              OPENWORLD.Camera.cameraoffset=Glob.defaultcameraoffset;
            });

          });
    }

    // You and your friend watch the ketoret from the court of israel
    ketoret()
    {
      // reached good spot to watch ketoret
      friendbethphagegroup!.extra['followingfriend'] = false;
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          friendbethphagegroup!.extra['friendold'],  5.17, -0.38,0,// 5.17, -0.38+0.1,0,//5.14, 0.55+0.1, 0,
          3,
          level: 1);
     OPENWORLD.Space.objTurnLerp( friendbethphagegroup!.extra['friendold'],270,1);

      var courtisraelpositions=OPENWORLD.Config.getPositionsByLabel( OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'], 'courtisrael');

      for (var i =0 ; i < courtisraelpositions.length; i++) {
        var positionjson=courtisraelpositions[i];
        List pos=positionjson?['p'];
        if (gamestart==GameStart.bethphage&&pos[1]<0.1) {
          var actor = OPENWORLD.Config.getPoolPositionObject(
              positionjson);
          if (actor != null) {
            OPENWORLD.Space.faceObjectAlways(actor, Glob.priestfirepan);
          }
        }
      }
    //  OPENWORLD.Space.objTurnLerp(actor, 270, 1);
      OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['friendold'], action: "idle");
      OPENWORLD.Space.worldToLocalSurfaceObjLerp(
          threeJs.camera,5.23, -0.26, OPENWORLD.Camera.cameraoffset,// 5.17, 1.33
          level: 1, 2.0, delay: 1);
      OPENWORLD.Space.worldToLocalSurfaceObj(
          threeJs.camera,5.23, -0.26, OPENWORLD.Camera.cameraoffset,  //5.17, 1.33
          level: 1, delay: 3.5);

      OPENWORLD.Space.objTurnLerp(
          threeJs.camera, 230, 1, delay: 2);

      Future.delayed(
          Duration(
              milliseconds: 5000), () async {
        tamidlookback(friendbethphagegroup!.extra['friendold']);
        OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
          ["What an honour",
            "it'd be for",
            "my friend Simon to do",
            "the ketoret.",
            "The honour of going",
            "to the sanctuary.",
            "Pity we can't go",
            "in and see"], z: 80,
          width: 300,
          clearwhendone: true,
          minwait: 5,
          scale: 0.2,
          randwait: 0,
          callbackonfinish: (actor){
            Future.delayed(
                Duration(
                    milliseconds: 120000), () async {
              OPENWORLD.Space.removeFaceObjectAlways(
                  friendbethphagegroup!.extra['friendold']);
              OPENWORLD.Mob.moveTo(
                  friendbethphagegroup!.extra['friendold'],
                  [[ 5.14, -0.18, 0, 0.03]], // go back to  5.17, -0.38
                  action: "walk",
                  stopaction: "idle3",
                  surfaceonly: true,
                  level: 1,
                  callbackonfinish: (actor) {
                    OPENWORLD.Space.faceObjectAlways(
                        friendbethphagegroup!.extra['friendold'],
                        Glob.priestfirepan);
                  }
                // delay:15,


              );
            });

          }
          // delay:20
        );
      });
      OPENWORLD.Space.faceObjectAlways(friendbethphagegroup!.extra['friendold'],Glob.priestfirepan,delay:20);

      Future.delayed(
          Duration(
              milliseconds: 260000), () async {
        OPENWORLD.Space.removeFaceObjectAlways(friendbethphagegroup!.extra['friendold']);
        OPENWORLD.Space.faceObjectLerp(friendbethphagegroup!.extra['friendold'],threeJs.camera,1);
        OPENWORLD.Space.faceObjectAlways(friendbethphagegroup!.extra['friendold'],Glob.priestfirepan,delay:6);

        OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
            ["I think they'd be",
              "in the sanctuary now.",
              "Smell that?",
              "They say the incense",
              "you can smell",
              "far as jericho.",
              "Standing here I can see why.",
              "They should be coming",
              "out soon."
            ], z: 80,
            width: 300,
            clearwhendone: true,
            minwait: 5,
            scale: 0.3,
            randwait: 0,
         //   delay: 260,
            callbackonfinish: (actor) {
              OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
                  ["Nearly out"
                  ], z: 80,
                  width: 300,
                  clearwhendone: true,
                  minwait: 5,
                  delay:40,
                  scale: 0.3,
                  randwait: 0);

              OPENWORLD.Space.removeFaceObjectAlways(friendbethphagegroup!.extra['friendold']);
              OPENWORLD.Mob.moveTo(
                  friendbethphagegroup!.extra['friendold'],
                  [[ 5.17, -0.38, 0, 0.03]], // go back to original sport
                  action: "walk",
                  stopaction: "idle3",
                  surfaceonly: true,
                  level: 1,
                  delay: 120,
                  callbackonfinish: (actor) {
                    OPENWORLD.Space.faceObjectAlways(
                        friendbethphagegroup!.extra['friendold'],
                        Glob.priestfirepan);
                  }

              );
            }
        );
      });
      // Once you and your friend are set up do the general ketoret
      Glob.ketoret!(
          Glob.priestfirepanget, Glob.priestfirepan, Glob.priestassistant, Glob.priestincense,callbackonfinish:(){
        saveGameState('tamidfinal');
        // ketoret over
       // Future.delayed(
            //Duration(
             //   milliseconds: 10000), () async {
            OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
                ["I wonder if the high priest",
                  "will finish the Tamid",//do the final part ",
                 // "of the Tamid",
                ], z: 80,
                width: 300,
                clearwhendone: true,
                minwait: 5,
                scale: 0.3,
                randwait: 0,
                callbackonfinish: (actor) {
                  tamidfinal();
                }

            );

       // });
      });

    }

    // You and your friend watch the tamid
    tamid()
    {
      //
      OPENWORLD.Space.worldToLocalSurfaceObj(
          friendbethphagegroup!.extra['friendold'],5 + 0.05, 1.37,0, level: 1);
      OPENWORLD.Space.objTurn(friendbethphagegroup!.extra['friendold'],270);
      OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['friendold'], action: "idle3");
      friendbethphagegroup!.extra['followingfriend'] = false;
      Future.delayed(
          Duration(milliseconds: (4000).round()), () async {

        tamidlookback(friendbethphagegroup!.extra['friendold']);

        OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
          ["What good timing.",
            "We're just in time"], z: 80,
          width: 300,
          clearwhendone: true,
          minwait: 5,
          scale: 0.4,
          randwait: 0,
        );
      });
      Future.delayed(
          Duration(milliseconds: (10000).round()), () async {
        var tamidcomplete=false;
        OPENWORLD.Space.faceObjectAlways(friendbethphagegroup!.extra['friendold'],Glob.sixpriests[0]);
        var courtisraelpositions=OPENWORLD.Config.getPositionsByLabel( OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'], 'courtisrael');
        for (var i =0 ; i < courtisraelpositions.length; i++) {
          var positionjson=courtisraelpositions[i];
          List pos=positionjson?['p'];
          if (gamestart==GameStart.bethphage&&pos[1]>1.02) {
            var actor = OPENWORLD.Config.getPoolPositionObject(
                positionjson);
            if (actor != null) {
              OPENWORLD.Space.faceObjectAlways(actor,Glob.sixpriests[0]);
            }
          }
        }
        Future.delayed(
            Duration(milliseconds: (30000).round()), () async {
          OPENWORLD.Space.removeFaceObjectAlways(friendbethphagegroup!.extra['friendold']);
          tamidlookback(friendbethphagegroup!.extra['friendold']);
          OPENWORLD.Space.faceObjectAlways(friendbethphagegroup!.extra['friendold'],Glob.sixpriests[0], delay:10);
          OPENWORLD.Mob.setSpeech(
            friendbethphagegroup!.extra['friendold'],
            ["I was hoping my",
              "friend Simon would be",
              "in the Tamid but",
              "I don't see him."], z: 80,
            width: 300,
            clearwhendone: true,
            minwait: 5,
            scale: 0.2,
            randwait: 0,
          );
          Future.delayed(
              Duration(milliseconds: (130000).round()), () async {
            OPENWORLD.Space.removeFaceObjectAlways(friendbethphagegroup!.extra['friendold']);
            tamidlookback(friendbethphagegroup!.extra['friendold']);
            OPENWORLD.Space.faceObjectAlways(friendbethphagegroup!.extra['friendold'],Glob.sixpriests[0], delay:10);
            OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
              ["The priests are",
                "going up the altar now.",
                "It's hard to",
                "see from here"], z: 80,
              width: 300,
              clearwhendone: true,
              minwait: 5,
              scale: 0.2,
              randwait: 0,
            );
          });
        });

        // Once you and your friend are set up, start the general tamid
        Glob.tamid!(Glob.sixpriests, Glob.threepriests, callbackonfinish: (actor) {
          // Finished tamid
          if (!tamidcomplete) {
            tamidcomplete=true;  // You get every priest called back so only do one
            print("tamid complete");
            saveGameState('ketoret');
            for (var i =0 ; i < courtisraelpositions.length; i++) {
              var positionjson=courtisraelpositions[i];
              var actor = OPENWORLD.Config.getPoolPositionObject(
                  positionjson);
              if (actor != null) {
                OPENWORLD.Space.removeFaceObjectAlways(actor);
              }

            }
            friendbethphagegroup!.extra['followingfriend'] = true;

            OPENWORLD.Space.removeFaceObjectAlways(friendbethphagegroup!.extra['friendold']);
            tamidlookback(friendbethphagegroup!.extra['friendold']);
            //   OPENWORLD.Space.faceObjectAlways(friendbethphagegroup!.extra['friendold'],Glob.sixpriests[0], delay:10);

            // Move to a better spot to watch
            OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
              ["Do you mind if we",
                "go closer to the altar?",
                "I want see if my friend Simon",
                "got the ketoret. "], z: 80,
              width: 300,
              clearwhendone: true,
              minwait: 5,
              scale: 0.2,
              randwait: 0,
            );
            OPENWORLD.Mob.moveTo(
                friendbethphagegroup!.extra['friendold'],
                [[ 5 + 0.05, 1.37, 0, 0.07],
                  [ 5 + 0.05, -0.38, 0, 0.07],
                  [ 5.17, -0.38, 0, 0.07]],
                action: "walk",
                stopaction: "idle3",
                surfaceonly: true,
                level: 1,
                delay:15,
                callbackonfinish: (actor) {
                  ketoret();

                }
            );
          }
        });
      });

    }

    var hasstarted=false;
    // This called after bathing at the pool of siloam done. Based up progress continue the journey past the bathing
    Glob.donebathing=()
    {
      print('started done bathing');

      saveGameState('donebathing');
      // up to the plaza
      pastsiloam();

      if (gamestartpos[gamestart]['progress'].contains('tamidfinal')) {
        Glob.meatdropall!(); // put meat on the altar
        Glob.tools!();
        Glob.tamiditems!();
        tamidfinal();
      } else if (gamestartpos[gamestart]['progress'].contains('ketoret')) {
        Glob.meatdropall!(); // put meat on the altar
        Glob.tools!();
        Glob.tamiditems!();
        ketoret();
      } else if (gamestartpos[gamestart]['progress'].contains('tamid')) {
        tamid();
      } else {
        // Have done bathing but haven't reached the temple yet
        print("done bathing");
        var girlspeed = 0.07;
        // var friendpos;//=OPENWORLD.Space.localToWorldObj(friendbethphagegroup!.extra['friendold']);

        var xval;
        var yval;
        List<Map> actions = [];
        if (!hasbathed || hasstarted) {
          // Case where are continuing the game straight after bathing so use current friend position
          var friendpos = OPENWORLD.Space.localToWorldObj(friendbethphagegroup!
              .extra['friendold']); // case where coming straight from reachedsiloam
          actions.add({"p": [friendpos.x, friendpos.y, 0.0], "v": girlspeed, "l":OPENWORLD.You.level});
          xval = friendpos.y;
          yval = friendpos.y;
        } else {
          // Starting game from progress so use the position defined in gamestart
          xval = dict['p'][0];
          yval = dict['p'][1];

          //friendpos = THREE.Vector3(-9.07, -51.21); //-8.93,-51.97,0.0);
        }
        print("bethphage yval" + yval.toString() + " " + xval.toString());

        // Based upon your starting y position work out the movetoloop path your friend will take to reach the temple
        hasstarted = true;
        if (yval < -51.21) {
          actions.add(
              {
                "p": [-9.07, -51.21, 0],
                "v": girlspeed,
                "callback": (actor) //-9.49+0.1, -50.74+0.1  -8.81, -51.57
                {
                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                      threeJs.camera, -8.94, -51.36, OPENWORLD.Camera.cameraoffset,1.0); // move player so walkers dont go through you
                  OPENWORLD.Space.faceObjectLerp(friendbethphagegroup!.extra['friendold'], threeJs.camera, 1.0, delay:1);
                  OPENWORLD.Space.faceObjectLerp(threeJs.camera,friendbethphagegroup!.extra['friendold'],  1.0, delay:1);
                  OPENWORLD.Mob.setSpeech(
                      friendbethphagegroup!.extra['friendold'],
                      [
                        "I feel purified",
                        "We're ready for the Tamid",
                        "Lets go"
                      ],
                      z: 80,
                      width: 300,
                      clearwhendone: true,
                      minwait: 5,
                      scale: 0.4,
                      randwait: 0
                  );
                  // OPENWORLD.Actor.playAction(
                  //     friendbethphagegroup!.extra['friendold'], action: "idle");

                }
              }
          );
          actions.add({"action": "idle", "time": 18.0,});
        }

        if (yval < -50.85) {
          actions.add(
              {"p": [ -11.33, -50.85, 0], "v": girlspeed}); // west of plaza
          actions.add({"action": "idle", "time": 1, "t": -45}); // west of plaza
        }
        // actions.add(
        //      {"p": [-12.13, -45.60, 0], "v": girlspeed}); //

        // Ignore the last point as will add at the end manually
        for (var i = citizenessenpath.length - 1; i >= 1; i--) {
          var pos = citizenessenpath[i];

          if (yval > -13.48 && yval <
              -13.07) { // special case where going east along southern wall
            // if (pos[1]>-13.48&&pos[1]<-13.06)
            //   ydiff=0.08;  // walkway across south wall you should walk slightly north so dont hit essenpath
            /// else
            //  ydiff=0.0;
            if (yval - 0.1 < pos[1] && xval < pos[0]) {
              var action = {"p": [pos[0], pos[1] + 0.08, 0], "v": girlspeed};
              actions.add(action);
            }
          }
          if (pos[1] > -48 && yval <
              pos[1]) { // -0.1 is to account for ydiff of 0.08 if going along southern wall

            var xdiff;
            var ydiff=0.0;
            if (pos[1]>-6.77&&pos[1]<-3.52) {
              xdiff=-0.05; // court of gentiles
              ydiff=0.08;
            } else if (pos[1]>-13.48&&yval<-13.07) {
              xdiff=-0.05;  // southern wall section
              ydiff=0.05;
            }else if (pos[1] > -2.4)
              xdiff = -0.05;
            else if (pos[1] < -13.1)
              xdiff = -0.05;
            else if (pos[1] < -6.69)
              xdiff =
              -0.08; // a little bit further to left when go up the tunnel
            else
              xdiff = 0.0;
            // var ydiff;
            print("xdiffydiff"+pos[1].toString()+" "+xdiff.toString()+" "+ydiff.toString());

            var action = {"p": [pos[0] + xdiff, pos[1]+ydiff, 0], "v": girlspeed};
            if (pos[1] > -45 && pos[1] < -44) {
              print('psalm');
              action['callback'] = (actor) {
                // delay so that get correct turn when do lookback() in psalm
                Future.delayed(
                    Duration(
                        milliseconds: 5000), () async {
                  psalm(actor, againy: -25);
                });
              };
            } else if (pos[1] > -26 && pos[1] < -25) {
              action['callback'] = (actor) {
                saveGameState('pilgrimsroad');
                Future.delayed(
                    Duration(milliseconds: (5000).round()), () async {
                  lookback(actor);
                  OPENWORLD.Mob.setSpeech(actor,
                    ["We're getting close",
                      "to the Huldah gates"], z: 80,
                    width: 300,
                    clearwhendone: true,
                    minwait: 5,
                    scale: 0.4,
                    randwait: 0,

                  );
                });
              };
            } else if (pos[1] > -23 && pos[1] < -22) {
              action['callback'] = (actor) {
                Future.delayed(
                    Duration(milliseconds: (5000).round()), () async {
                  lookback(actor);
                  OPENWORLD.Mob.setSpeech(actor,
                    ["I think the Stoa will",
                      "be busy. Lets go through",
                      "the Huldah gates"], z: 80,
                    width: 300,
                    clearwhendone: true,
                    minwait: 5,
                    scale: 0.4,
                    randwait: 0,
                  );
                });
              };
            } else if (pos[1] > -20 && pos[1] < -18) {
              action['callback'] = (actor) {
                saveGameState('pilgrimsroad2');
                Future.delayed(
                    Duration(milliseconds: (5000).round()), () async {
                  lookback(actor);
                  OPENWORLD.Mob.setSpeech(actor,
                      ["We're making good time.",
                        "We should make it to",
                        "the start of the tamid"], z: 80,
                      width: 300,
                      clearwhendone: true,
                      minwait: 5,
                      scale: 0.4,
                      randwait: 0,
                      delay: 1
                  );
                });
              };
            } else if (pos[1] > -14 && pos[1] < -12&&pos[0]<-4) {
              action['callback'] = (actor) {
                Future.delayed(
                    Duration(milliseconds: (5000).round()), () async {
                  lookback(actor);
                  OPENWORLD.Mob.setSpeech(actor,
                      ["I'm exhausted",
                        "going up pilgrims road",
                        "now up the Huldah gates"], z: 80,
                      width: 300,
                      clearwhendone: true,
                      minwait: 5,
                      scale: 0.4,
                      randwait: 0,
                  );
                });
              };
            } else if (pos[1] > -7 && pos[1] < -6&&pos[0]<3) {
              action['callback'] = (actor) {
                Future.delayed(
                    Duration(milliseconds: (5000).round()), () async {
                  saveGameState('courtgentiles');

                  lookback(actor);
                  OPENWORLD.Mob.setSpeech(actor,
                      ["Even though I'm exhausted",
                        "when you finally see",
                        "the magnificance of",
                        "the temple my",
                        "exhaustion disappears"], z: 80,
                      width: 300,
                      clearwhendone: true,
                      minwait: 5,
                      scale: 0.4,
                      randwait: 0,

                  );
                });
              };
            } else if (pos[1] > -2 && pos[1] < -1) {
              action['callback'] = (actor) {
                saveGameState('courtwomen');

                lookback(actor);
                OPENWORLD.Mob.setSpeech(actor,
                    ["Looks like the tamid",
                    "is about to start.",
                    "Everyone in the",
                    "court of women",
                    "is watching"], z: 80,
                    width: 300,
                    clearwhendone: true,
                    minwait: 5,
                    scale: 0.4,
                    randwait: 0,
                );
              };
            }
            if (pos[1] > -6.8) //95)//7.04)
              action['l'] = 1; // court of gentiles
            actions.add(action);
          //  print("mmmoo"+actions.toString());

          }
        }
        actions.add(
            {"p": [6.49, -0.86, 0], "v": girlspeed, "l": 1}); // avoid lampstand
        actions.add({"p": [6.00, 0.20, 0], "v": girlspeed, "l": 1}); //5.82,0.37
        actions.add({
          "p": [5.15 - 0.1, 0.43, 0],
          "v": girlspeed,
          "l": 1,
          "callback": (actor) { // through nicanor doors
          }
        });
        actions.add({"p": [ 5 + 0.05, 1.37, 0], "v": girlspeed, "l": 1});
        actions.add({
          "p": [ 5 + 0.1, 1.37, 0],
          "v": girlspeed,
          "l": 1,
          "callback": (actor) {
            saveGameState('tamid');
            // Final spot where watch tamid
            OPENWORLD.Space.objTurnLerp(actor, 270, 1);
            OPENWORLD.Actor.playAction(actor, action: "idle");
            //234.03
            //5.16, 1.44, t227.04  use this instead
            OPENWORLD.Space.objTurnLerp(threeJs.camera, 227, 1, delay: 2); //265
            OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                threeJs.camera,5.16, 1.44, OPENWORLD.Camera.cameraoffset,// 5.17, 1.33
                level: 1, 2.0, delay: 1);
            OPENWORLD.Space.worldToLocalSurfaceObj(
                threeJs.camera,5.16, 1.44, OPENWORLD.Camera.cameraoffset,  //5.17, 1.33
                level: 1, delay: 3);
            tamid();

          }
        }); // tamid pos

        //print("donebathing actions" + actions.toString());
        var level;
        if (actions[0].containsKey('l'))
          level=actions[0]['l'];
        else
          level=0;
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            friendbethphagegroup!.extra['friendold'],actions[0]['p'][0],actions[0]['p'][1],0,
            6,lerpopacity: 1.0, level:level);
        // Now that got your friends path move your friend
        OPENWORLD.Mob.moveToLoop(
            friendbethphagegroup!.extra['friendold'],
            actions,
            surfaceonly: true,
            action: "walk",
            looptype: OPENWORLD.Mob.LoopTypeStop
          //callbackonfinish: reachedsiloam,
        );
      }
    };

    // Handle you and your friend reaching siloam after coming up the watergate
    // Have a stable boy collect your donkey and then go an bathe
    reachedsiloam(actor)
    {
      print("reachedsiloam");
      saveGameState('siloam');
      // At this point friendbethphagegroup still contains your friend and haven't seperated it
      var horsetext=OPENWORLD.Mob.getTextSprite(_horse);
      horsetext.visible=false;  //  Hide going to tamid text

      // When you reach the pool of the siloam
      pastsiloam();  // extra friend settings when past
      OPENWORLD.Space.objTurnLerp(friendbethphagegroup!, 290, 1.0);

      if (teststable)
        OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera,
            finalsiloamposx+0.15, finalsiloamposy,OPENWORLD.Camera.cameraoffset);

      // Your horse to your right
      OPENWORLD.Space.worldToLocalSurfaceObjLerp(
          _horse,
          finalsiloamposx+0.1,finalsiloamposy+0.1, // worldpos.y + 0.52,
          -0.002,1.0);
      OPENWORLD.Space.objTurnLerp(_horse, 290, 1.0);

      OPENWORLD.Space.worldToLocalSurfaceObj(
          friendbethphagegroup!.extra['friendold'],
          finalsiloamposx+0.04, // Place your friend to the right of his donkey
//      finalsiloamposx-0.04, //worldpos.x,
          finalsiloamposy, // worldpos.y + 0.52,
          -0.002);

      OPENWORLD.Space.worldToLocalSurfaceObj(
          friendbethphagegroup,
          finalsiloamposx, finalsiloamposy,
          -0.002);
      _hotload.add(friendbethphagegroup!.extra['friendold']);
      OPENWORLD.Space.faceObjectLerp(friendbethphagegroup!.extra['friendold'], threeJs.camera, 1.0);

      OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
          ["1 coin ok?"], z: 80,
          width: 300,
          clearwhendone: true,
          minwait: 6,
          scale: 0.4,
          randwait: 0,
          delay:1
      );
      OPENWORLD.Space.faceObjectLerp(friendbethphagegroup!.extra['friendold'], threeJs.camera, 1.0);

      Future.delayed(
          Duration(
              milliseconds: 5000), () async {
        // Move the stable boy to collect your donkeys and take down to the stables
        OPENWORLD.Space.faceObjectLerp(friendbethphagegroup!.extra['stableboy'],friendbethphagegroup!.extra['friendold'], 1.0);
        OPENWORLD.Space.faceObjectLerp(friendbethphagegroup!.extra['friendold'],friendbethphagegroup!.extra['stableboy'], 1.0);
        OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
            ["Yes, thats fine"], z: 80,
            width: 300,
            clearwhendone: true,
            minwait: 6,
            scale: 0.4,
            randwait: 0
        );
        var time=await OPENWORLD.Mob.moveTo(
          friendbethphagegroup!.extra['stableboy'],
          [[finalsiloamposx-0.02, finalsiloamposy+0.037,0,0.07]],
          action:"walk",
          stopaction: "idlehold",
          surfaceonly: true,
          //callbackonfinish: reachedsiloam,
        );
        OPENWORLD.Space.faceObjectLerp(friendbethphagegroup!.extra['stableboy'],friendbethphagegroup!, 1.0, delay:time+0.5);
        OPENWORLD.Space.faceObjectLerp(friendbethphagegroup!.extra['stableboy'],_horse, 1.0, delay:time+2.0);
        // stable boy walk to _horse
        OPENWORLD.Mob.moveTo(
            friendbethphagegroup!.extra['stableboy'],
            [[finalsiloamposx+0.05, finalsiloamposy+0.09,0,0.07]],
            action:"walk",
            stopaction: "idlehold",
            surfaceonly: true,
            delay:time+3.0
          //callbackonfinish: reachedsiloam,
        );
        OPENWORLD.Space.faceObjectLerp(friendbethphagegroup,_horse, 1.0, delay:time+3.0);
        // friend donkey walk to _horse with stable boy
        var time2=await OPENWORLD.Mob.moveTo(
            friendbethphagegroup,
            [[finalsiloamposx, finalsiloamposy+0.05,0,0.07]],
            surfaceonly: true,
            delay:time+3.0,
            callbackonfinish: (actor) {
              print("frienddonkey idle stable boy");
              OPENWORLD.Actor.playAction(
                  friendbethphagegroup!.extra['frienddonkey'], action: "idle",delay:0.5);

            }
        );
        print("time2 siloam"+time2.toString()+" "+time.toString());
        // friend donkey walk to _horse action
        OPENWORLD.Actor.playAction(
            friendbethphagegroup!.extra['frienddonkey'], action: "walk",delay:time+3.0);

        var walktostableposs=[
          [-9.33, -50.97,0,0.07],
          [-11.58, -51.16,0,0.07],
          [-11.18, -53.62,0,0.07],
          [ -11.88, -53.74,0,0.07],
          [-11.93, -53.57,0,0.07],
        ];
        var  walktostablepossleft = getpathoffset(walktostableposs, true,0.05);
        // print("possleft"+walktostablepossleft.toString());
        var  walktostablepossright = getpathoffset(walktostableposs, false,0.05);

        OPENWORLD.Mob.moveTo(
            friendbethphagegroup!.extra['stableboy'],
            walktostableposs,
            surfaceonly: true,
            action:"walk",
            stopaction: "idle",
            delay:time2+3,
            callbackonfinish: (actor)
            {
              OPENWORLD.Space.objTurnLerp(actor, 180, 1.0);
            }
        );

        OPENWORLD.Mob.moveTo(
            friendbethphagegroup!,
            walktostablepossleft,// walktostableposs,
            surfaceonly: true,
            //  action:"walk",
            delay:time2+3,
            callbackonfinish: (actor) {
              OPENWORLD.Actor.playAction(
                  friendbethphagegroup!.extra['frienddonkey'], action: "idle");
            }
        );
        // Seems to be for stables
        OPENWORLD.Actor.playAction(
            friendbethphagegroup!.extra['frienddonkey'], action: "walk",delay:time2+3.2);

        OPENWORLD.Mob.moveTo(
            _horse,
            walktostablepossright,//  walktostableposs,
            surfaceonly: true,
            action:"walk",
            stopaction: "idle",
            delay:time2+3
          //callbackonfinish: reachedsiloam,
        );

        Future.delayed(
            Duration(
                milliseconds: (time2 + 10).round()*1000), () async {
          // Now donkeys taken care of go and bath in the mikveh
          // Donkeys taken away so friend looks back at you
          OPENWORLD.Space.faceObjectLerp(
            friendbethphagegroup!.extra['friendold'], threeJs.camera, 1.0,
            // delay: time2 + 3
          );
          OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friendold'],
              ["Lets go bathe"], z: 80,
              width: 300,
              clearwhendone: true,
              minwait: 6,
              scale: 0.4,
              randwait: 0
          );

           var startpos=THREE.Vector2(-8.40, -52.31);
          // Walk to outside of then
          // Time it so you start when the other bathers start going in
          callwhentrue(() {
            return   Glob.bathingstep==1;
          },//delay:6,
                  () async {
            // Add your friend to the pool reflections
            Glob.watersiloam.includeInReflection.add(friendbethphagegroup!.extra['friendold']);
            await OPENWORLD.Mob.moveTo(
                friendbethphagegroup!.extra['friendold'],
                [[ startpos.x, startpos.y, 0, 0.04]], action: "walk",
                stopaction: "idle");
            Future.delayed(
                Duration(
                    milliseconds: (10).round() * 1000), () async {
              // Move your friend in the mikveh and have you follow him and both start bathing
              // The rest of the bathers bathing are defined in hotloadsiloam and not here
              var girlspeed = 0.07;
              var batherclothespos = THREE.Vector2(-8.72, -52.48);
              var batherfinalpos = THREE.Vector2(-8.80, -52.59);
              var batheractionlist = bathingactions.toList();
              batheractionlist.shuffle();
              List<Map> actions = [
                {"p": [ startpos.x, startpos.y, 0],
                  "v": girlspeed,
                  "callback": (actor) {
                    // OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, startpos.x,startpos.y, OPENWORLD.Camera.cameraoffset, 1.0);
                  }
                },
                // entrance of the tent   -10.86, -53.20
                {"p": [-8.64, -52.53, 0], "v": girlspeed, "callback": (actor) {
                  // Put player on the correct place on ledge
                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, -8.62, -52.57, OPENWORLD.Camera.cameraoffset, 1.0);
                }
                },
                // friend on the ledge
                // walk to clothes position
                {
                  "p": [
                    batherclothespos.x,
                    batherclothespos.y,
                    0
                  ],
                  "v": girlspeed,
                  "callback": (actor) {
                    OPENWORLD.Space.objTurnLerp(threeJs.camera, 290, 1);
                  }
                },
                {"action": "armsup", "time": 1.0,},
                {"action": "hitup", "time": 1.0, 'callback': (actor) {
                  // print("bathers clothes off");
                  OPENWORLD.BaseObject.setVisible(
                      actor, false, groupname: "citizen_3"); // no pants
                  OPENWORLD.BaseObject.setVisible(
                      actor, false, groupname: "citizen_4"); // no clothes
                  //clothespileii.visible = true; // show the clothes on the ground
                }},
                {"action": "pickupright", "time": 10.0,},
                // Walk into pool
                {
                  "p": [
                    batherfinalpos.x,
                    batherfinalpos.y,
                    0
                  ],
                  "v": girlspeed / 2,
                  "callback": (actor) {
                    // Put the player into the pool and face north
                    playSplash();
                    OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                        threeJs.camera, -8.73, -52.69, OPENWORLD.Camera
                        .cameraoffset, 1.0);
                    OPENWORLD.Space.objTurnLerp(threeJs.camera, 330, 1);
                  }
                }
              ];
              for (var j = 0; j < 20; j++) {
                Map action = {
                  "action": batheractionlist[j % batheractionlist.length]
                };
                if (j % batheractionlist.length == 0)
                  action['t'] = OPENWORLD.Math.randFloatSpread(40);
                if (j%4==0) {
                  action['callback']=(actor) {
                    // Bob the player up and down for washing
                    if (OPENWORLD.You.getObjDistance(friendbethphagegroup!.extra['friendold'])<0.3) {  // Dont splash if out of the mikveh
                      playSplash();
                      playSplash(delay: 2);
                      var worldpos = OPENWORLD.You.getWorldPos();
                      OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                          threeJs.camera, worldpos.x + 0.005, worldpos.y,
                          OPENWORLD.Camera.cameraoffset * 0.9, 0.5);
                      OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                          threeJs.camera, worldpos.x, worldpos.y,
                          OPENWORLD.Camera.cameraoffset, 0.5, delay: 1.5);
                    }
                  };
                }
                actions.add(action);
              }
              // After bathing move back to clothes
              actions.add({
                "p": [
                  batherclothespos.x,
                  batherclothespos.y,
                  0
                ],
                "v": girlspeed / 2,
                "callback":(actor){
                  // Put player on the correct place on ledge
                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, -8.62, -52.57, OPENWORLD.Camera.cameraoffset, 1.0);
                  OPENWORLD.Space.objTurnLerp(threeJs.camera, 290, 1);

                }
              });
              actions.add({
                "action": "idle",
                "time": 1.0,
                't': OPENWORLD.Math.randFloatSpread(40)
              });
              actions.add({"action": "armsup", "time": 1.0,});
              actions.add({"action": "pickupright", "time": 10.0,});
              actions.add({"action": "hitup", "time": 1.0,});
              actions.add({"action": "idle", "time": 1.0, 'callback': (actor) {
                //  print("bathers clothes on");
                OPENWORLD.BaseObject.setVisible(
                    actor, true, groupname: "citizen_3"); //put on pants
                OPENWORLD.BaseObject.setVisible(
                    actor, true, groupname: "citizen_4"); // put on clothes

                // clothespileii.visible = false; // show the clothes on the ground
              }});
              actions.add({
                "p": [-9.19, -52.16, 0],  // end of the ledge
                "v": girlspeed,
                "callback":(actor) {
                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, -9.16, -52.19, OPENWORLD.Camera.cameraoffset, 1.0);
                  OPENWORLD.Space.objTurnLerp(threeJs.camera, 0.0, 1);

                  //     OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, -9.19+0.01, -52.16, OPENWORLD.Camera.cameraoffset, 1.0);

                }
              }); // of the clothes line
              actions.add(
                  {"p": [-8.93, -51.97, 0], "v": girlspeed, "callback":(actor){
                    Glob.donebathing!();
                  }
                  }); // out of the tent


              OPENWORLD.Mob.moveToLoop(
                  friendbethphagegroup!.extra['friendold'],
                  actions,

                  surfaceonly: true,
                  action: "walk",
                  looptype: OPENWORLD.Mob.LoopTypeStop
                //callbackonfinish: reachedsiloam,
              );



            });
          });
        });


        // OPENWORLD.Space.worldToLocalSurfaceObjLerp(friendbethphagegroup!.extra['stableboy'],finalposx,finalposy, 0, 1.0);

      });


//       OPENWORLD.Space.objTurnLerp(friendbethphagegroup!.extra['friendold'], turn-180,1);
      //OPENWORLD.Space.faceObjectAlways(
      //    friendbethphagegroup!.extra['friendold'], threeJs.camera);
      OPENWORLD.Actor.playAction(
          friendbethphagegroup!.extra['friendold'], action: "idle");
      print("frienddonkey idle - seems to be after siloam");
      OPENWORLD.Actor.playAction(
          friendbethphagegroup!.extra['frienddonkey'], action: "idle");
      OPENWORLD.Actor.playAction(
          friendbethphagegroup!.extra['frienddonkey'], action: "idle", delay:1);
      OPENWORLD.Actor.playAction(_horse, action: "idle");
      OPENWORLD.BaseObject.setVisible(
          _horse, true, groupname: "horse001_1");  // show the rope
      OPENWORLD.BaseObject.setVisible(
          friendbethphagegroup!.extra['frienddonkey'], true, groupname: "horse001_1");  // show the rope


    }

    // This is the path of your friend while you are on the donkey before siloam
    // Given a path offset it so that are to the left or right of the path so dont walk through people
    //    I dont think this is true because it is using citizenpathsouthfriend which already has the offset, it is not done here
    Glob.getCurrentPathSouthFriend=()
    {
      // Get the offset citizenpath


      var friendpos = OPENWORLD.Space.localToWorldObj(friendbethphagegroup!);
      // var dist=OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, friendbethphagegroup);
      // print("disttt"+dist.toString());
      List<Map> positions = [
        {"p": [friendpos.x,friendpos.y, 0], 'v': horsespeed / 2}
      ];
      //var citizenpathsouthoffset=pathoffset(citizenpathsouth,false,0.05);
      // Find the closest point that is in front of you - dont pick a point behind you
      var closestdist=9999.0;
      var closestind=-1;
      for (var i=0; i< citizenpathsouthfriend.length; i++) {
        var pos=citizenpathsouthfriend[i];
        var dist2 = OPENWORLD.Math.vectorDistance(
            friendpos, THREE.Vector3(pos[0], pos[1], 0.0));
        if (dist2 < closestdist) {
          closestdist = dist2;
          closestind = i;
        }

      }
      // !! You could probably replace this with findClosestNextIndex(List<List> path, x, y)
      var worldpos = OPENWORLD.You.getWorldPos();
      var distbeth=OPENWORLD.Math.vectorDistance(THREE.Vector3(gamestartpos[gamestart]['p'][0],gamestartpos[gamestart]['p'][1],0.0), worldpos);
      var dist1=OPENWORLD.Math.vectorDistance(THREE.Vector3(gamestartpos[gamestart]['p'][0],gamestartpos[gamestart]['p'][1],0.0), THREE.Vector3(citizenpathsouth[closestind][0],citizenpathsouth[closestind][1],0.0));
      // var dist2=OPENWORLD.Math.vectorDistance(THREE.Vector3(gamestartpos[gamestart]['p'][0],gamestartpos[gamestart]['p'][1],0.0), THREE.Vector3(citizenpathsouth[closestind+1][0],citizenpathsouth[closestind+1][1],0.0));
      // Work out the starting index of citizenpathsouthfriend based upon on your position
      var useind;
      if (distbeth>dist1)
        useind=closestind+1;
      else
        useind=closestind;

      // Create the movetoloop path including callbacks for gamestate
      for (var i=useind; i< citizenpathsouthfriend.length; i++) {
        var pos=citizenpathsouthfriend[i];
        var position={"p": [pos[0],pos[1], 0], 'v': horsespeed / 2};
        // print("iiii"+i.toString()+" "+pos[1].toString());
        if (pos[1]<11&&pos[1]>10) {
          position['callback'] = (actor) {
            saveGameState('kidron');
          };
        } else   if (pos[1]>-15&&pos[1]<-14) {
            position['callback']=(actor) {
              saveGameState('zechariah');
            };
        } else   if (pos[1]>-25&&pos[1]<-24) {
          position['callback']=(actor) {
            saveGameState('olive');
          };
        } else   if (pos[1]>-37&&pos[1]<-36) {
          position['callback']=(actor) {
            saveGameState('goatmischeif');
          };
        } else if (pos[1]<-49&&pos[1]>-50) {//i==38) {  // -49
          //  positions.add({

          position[
          "callback"]= (actor) {
            saveGameState('beforegate');
            // When you reach the bottom of the water gate
            OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friend'],
              ["How about we get off here",
                "and walk up?"], z: 80,
              width: 300,
              clearwhendone: true,
              minwait: 6,
              scale: 0.4,
              randwait: 0,
              //   delay:9
            );
            // After saying lets get off then wait 1 second before stopping and getting off
            Future.delayed( Duration(milliseconds: 500), () async {
              Glob.hasreachedsiloam=true;
              Glob.hasdonebeforegate=true;  // so that know have got off donkey and gone up to watergate for timing
              dismount(offset: -0.05);
              var horsetext = OPENWORLD.Mob.getTextSprite(_horse);
              horsetext.visible = false; //  Hide going to tamid text
              //   print("entering water gate");

              //  OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['friend'],
              //      action: "sittableidle");
              print("frienddonkey idle again after siloam");
              OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['frienddonkey'], action: "idle");
              OPENWORLD.Actor.playAction(
                  friendbethphagegroup!.extra['friend'],
                  action: "idle");
              OPENWORLD.Actor.playAction(
                  friendbethphagegroup!.extra['friend'],
                  action: "work", delay: 10);
              friendbethphagegroup!.extra['friend'].position.x = -0.04;  // place your friend to your right of his donkey as you follow
              friendbethphagegroup!.extra['friend'].position.y = 0.00;
              OPENWORLD.Space.objTurnLerp(
                  friendbethphagegroup!.extra['friend'], 0, 0.5); // face you
              //  friendbethphagegroup!.extra['friend'].rotation.y = OPENWORLD.Math.degToRad(180);
              OPENWORLD.Space.objTurnLerp(
                  friendbethphagegroup!.extra['friend'], 90, 1.0,
                  delay: 10); // face your donkey
//                 friendbethphagegroup!.extra['friend'].rotation.y = OPENWORLD.Math.degToRad(90);
              OPENWORLD.Space.objTurnLerp(
                  friendbethphagegroup!.extra['friend'], 180, 1.0, delay: 20);
              OPENWORLD.Actor.playAction(
                  friendbethphagegroup!.extra['friend'], action: "idle",
                  delay: 20);
              Future.delayed(Duration(milliseconds: 22000), () async {
                // Now that have got off horse start walking up to the water gate
                OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friend'],
                  ["Lets go"], z: 80,
                  width: 300,
                  clearwhendone: true,
                  minwait: 6,
                  scale: 0.4,
                  randwait: 0,
                  //   delay:9
                );

                OPENWORLD.Actor.playAction(
                    friendbethphagegroup!.extra['friend'], action: "walk");
                // Seems to be where you both get off at the bottom of watergate and go up
                OPENWORLD.Actor.playAction(friendbethphagegroup!.extra['frienddonkey'], action: "walk");
                // Your friends donkey is to your left
                OPENWORLD.Mob.moveTo(
                  friendbethphagegroup!, [
                  [-7.17 + 0.05, -52.83 - 0.05, 0, 0.07],
                  [finalsiloamposx, finalsiloamposy, 0, 0.07],
                ],
                  surfaceonly: true,
                  callbackonfinish: reachedsiloam, // This is where you get to the tent with the stable boy
                );

                // Your horse is to your right
                OPENWORLD.Mob.moveTo(
                  _horse, [
                  [-7.17 + 0.02, -52.83, 0, 0.07],
                  [finalsiloamposx + 0.1, finalsiloamposy + 0.1, 0, 0.07],
                ],
                  action: "walk",
                  surfaceonly: true,
                  // delay:0.5,//1.0
                  // facedir: false
                );
              });


              // }
            });
          };
          // );

        }

        positions.add(position);
      }
      print("friend positions"+positions.toString());
      return positions;

    };


    if (gamestart == GameStart.bethphage) {
      // donkey outside your house
      _horse = await OPENWORLD.Actor.copyActor(
          donkeypack, randomduration: 0.1); //, action:null);
      // Donkey that you ride - doesn't animate - rocks up and down in animate()
      _horse.extra['riding'] = await OPENWORLD.Model.createModel(
          'assets/actors/donkey.glb'); // why must I do this - if you dont it flutters
      _horse.extra['riding'].scale.setValues(0.04, 0.04, 0.04);
      OPENWORLD.Space.objTurn(_horse.extra['riding'], 0);
      //                          up    forward
      _horse.extra['riding'].position.setValues(0.0, -0.095, -0.06);
      if (OPENWORLD.System.isDesktop()) {
        // Dismount text on horse - dont have it on a smartphone
        List<Map> spritemsg = [];
        spritemsg.add({'message': 'E', 'textcolor': Colors.white,
          'backgroundcolor': Colors.black,
          'backgroundopacity': 1.0,
          'paddingLeft': 5, 'paddingRight': 5});
        spritemsg.add(
            {'message': 'Dismount', 'textcolor': Colors.white,
              'backgroundcolor': Colors.black,
              'backgroundopacity': 0.0}
        );

        OPENWORLD.Mob.setMultiText(
            _horse.extra['riding'], spritemsg, scale: 0.0018,
            x: -0.05,
            y: 0.07,
            z: 1.7);
      }
      // _horse = await OPENWORLD.Model.createModel('assets/actors/donkey29.glb');
      _horse.scale.setValues(0.04, 0.04,
          0.04);
      //  _horse = await OPENWORLD.Actor.copyActor(horse, randomduration: 0.1);
      OPENWORLD.Space.objTurn(_horse,270-5);

      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          _horse,57.21, 13.09,0,//57.32, 13.16, 0.0,
          6,lerpopacity: 1.0); //-25.49, 116.86,0,6);//12.67, 5.22, 0, 6); // 9.8,1.1, 0.14,3); //3.42);
      _hotload.add(_horse);

      if (OPENWORLD.System.isDesktop())
        horseKeypress();
      ///  OPENWORLD.BaseObject.setDistanceTrigger(_horse, dist: 0.1);
      threeJs.camera.children.clear();

      List<Map> spritemsg=[];
      // No keypress if smartphone
      if (OPENWORLD.System.isDesktop())
        spritemsg.add({'message': 'E', 'textcolor': Colors.white,
        'backgroundcolor': Colors.black,
        'backgroundopacity': 1.0,
        'paddingLeft': 5, 'paddingRight': 5});
      spritemsg.add(
        {'message': 'Mount → to Tamid', 'textcolor': Colors.white,
          'backgroundcolor': Colors.black,
          'backgroundopacity': 0.02});

      OPENWORLD.Mob.setMultiText(
          _horse, spritemsg, scale: 0.008, y: 0.0, z: 1.8); //, fontfamily: "Roboto");

      // Show the horse riding icon top right for smartphone
      OPENWORLD.BaseObject.setDistanceTrigger(_horse, dist: 0.3, event:(action) {
        if (action) {
          setState(() {
            canhorseride=true;
          });
        } else {
          setState(() {
            canhorseride=false;
          });

        }
      });
      //mount();
    }

    var housefire = new VolumetricFire(
        Glob.fireWidth, Glob.fireHeight, Glob.fireDepth, Glob.sliceSpacing, threeJs.camera);
    await housefire.init();

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        housefire.mesh, ovenposx, ovenposy, 0.02,
        3); // 3.35, 0.51, 0.3,3); //3.7);
    housefire.mesh.scale.x = 0.01;
    housefire.mesh.scale.y = 0.01;
    housefire.mesh.scale.z = 0.01;
    //  _hotload.add(housefire.mesh);
    hotloadAdd(firsthotload, false, housefire.mesh);

    OPENWORLD.Updateables.add(housefire);

    var smoke2 = Smoke();
    var smokeGroup2 = await smoke2.createSmoke(
        'assets/textures/smoke/clouds64.png');

    //var smokeGroup2=smokeGroup.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smokeGroup2, ovenposx, ovenposy, 0.05, 3);

    smokeGroup2.scale.setValues(0.00001, 0.00001, 0.00001);
    OPENWORLD.Updateables.add(smoke2);
    //_hotload.add(smokeGroup2);
    hotloadAdd(firsthotload, false, smokeGroup2);

    var chicken3 = await OPENWORLD.Actor.copyActor(
        chicken,
        action: null,
        randomduration: 0.1);
    _hotload.add(chicken3);
    setcancollide(chicken3,true);
    var chickenpos3x = 57.43; //9;
    var chickenpos3y = 13.17;
    OPENWORLD.Mob.moveToLoop(chicken3,
        [
          {'p': [chickenpos3x, chickenpos3y, 0], 'v': 0.02},
          {"action": "pecking", "time": 8, "duration": null, "z": 0},
          {'p': [chickenpos3x - 0.07/2, chickenpos3y, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenpos3x - 0.12/2, chickenpos3y, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenpos3x - 0.07/2, chickenpos3y - 0.04/2, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenpos3x, chickenpos3y - 0.06/2, 0], 'v': 0.02},
          {"action": "pecking", "time": 10, "duration": null, "z": 0.0}
        ],
        //  duration:1.0,
        facenow: true,
        randomduration: 0.1,
        hidedist:2,
        //  reverseloop:true,
        action: "walk" //straight"
    );

    //// Bridge Mount of Olives side - Miphkad Altar
    var altargreatposx=48.67;//,48.76;
    var altargreatposy=0.39;//0.28;

    var altargreat2 = altargreat.clone();
    _hotload.add(altargreat2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        altargreat2, altargreatposx,altargreatposy,-0.01,//57.19, 0.39, -0.01,
        7);
    altargreat2.scale.setValues(0.3, 0.3, 0.3);
    housefire = new VolumetricFire(
        Glob.fireWidth, Glob.fireHeight, Glob.fireDepth, Glob.sliceSpacing, threeJs.camera);
    await housefire.init();

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        housefire.mesh, altargreatposx,altargreatposy,0,//57.19, 0.3 + 0.08, 0,
        10); // 3.35, 0.51, 0.3,3); //3.7);
    housefire.mesh.scale.x = 0.03;
    housefire.mesh.scale.y = 0.03;
    housefire.mesh.scale.z = 0.03;
    //  _hotload.add(housefire.mesh);
    _hotload.add(housefire.mesh);
    OPENWORLD.Updateables.add(housefire);
  //  texture: "assets/actors/citizen/citizenf22.jpg",
     var priest36ii=await OPENWORLD.Actor.copyActor(
        priest36, randomduration: 0.1,texture:"assets/actors/priest/sash.jpg", groupname: "citizen_2");
    _hotload.add(priest36ii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        priest36ii, 49.09, 0.50,0,3);//.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
    THREE.MeshStandardMaterial mat=await OPENWORLD.Texture.getMaterialByGroupname(priest36ii, "citizen_2");
    mat.map?.wrapS = THREE.RepeatWrapping;
    mat.map?.wrapT = THREE.RepeatWrapping;
    OPENWORLD.Space.faceObjectAlways(priest36ii, threeJs.camera);
    var stave = spear.clone();
    OPENWORLD.BaseObject.setVisible(
             stave, false, groupname: "head");
    OPENWORLD.Actor.wield(priest36ii, stave, "Bip01_R_Hand");

    var havepushed=0;
    OPENWORLD.BaseObject.setDistanceTrigger(priest36ii, dist: 0.5, event:(action) {
      if (action) {

        OPENWORLD.Mob.setSpeech(priest36ii, havepushed==0?[
          'Whats your business here?',
          'On your way'
        ]:[
          "You had better go"
        ], z: 100,
            width: 300,
            clearwhendone: true,
            minwait: 3,
            randwait: 0,
            );

      } else {

      }
    });

    var priest37ii=await OPENWORLD.Actor.copyActor(
        priest37, randomduration: 0.1);
    _hotload.add(priest37ii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        priest37ii, 48.83, 0.37,0,3);
    OPENWORLD.Texture.setMaterial(priest37ii, mat,groupname: "citizen_2");
    OPENWORLD.Space.faceObjectAlways(priest37ii, threeJs.camera);
    var stave2 = stave.clone();
    OPENWORLD.Actor.wield(priest37ii, stave2, "Bip01_R_Hand");

    roomMiphkad = OPENWORLD.Room.createRoom( altargreatposx,altargreatposy,
        soundpath: "sounds/courtyard.mp3", volume: 0.05); //THREE.Object3D();

    roomMiphkad.extra['guide'] = [
      "Altar for the red hefer ceremony",
    ];
    _hotload.add(roomMiphkad);

    OPENWORLD.Room.setDistanceTrigger(roomMiphkad,
        maxy: 0.7, miny: 0, minx: 48.1, maxx: 49, event:(action) {
      if (action) {
        setState(() {
          if (mounted)
            roomname = "Miphkad Altar";

          OPENWORLD.Mob.setSpeech(priest37ii, [
            'On your way!'
          ], z: 100,
              width: 300,
              clearwhendone: true,
              minwait: 3,
              randwait: 0,
             );
        });
        OPENWORLD.Mob.placeBeforeCamera(priest37ii, 0.2, action: "walk",
            stopaction: "idle",
            time: 1);

        OPENWORLD.Actor.playActionThen(priest37ii, "push", "idle", delay: 2);

        var worldpos = OPENWORLD.You.getWorldPos();
        var roomedge=OPENWORLD.Room.getClosestEdgePoint(roomMiphkad,worldpos.x, worldpos.y,offset:0.3);
        if (roomedge.length==2) {
          OPENWORLD.Mob.moveTo(threeJs.camera,
              facedir:false,
              [[roomedge[0], roomedge[1], OPENWORLD.Camera.cameraoffset, 1.2]],
              delay: 2.5);
          OPENWORLD.Mob.placeBeforeCamera(priest36ii, 0.2, action: "walk",offset:0.1,
              stopaction: "idle",
              time: 1, delay:4);
          OPENWORLD.Mob.setSpeech(priest36ii, [
            havepushed==0?'Next time you going to be punished':'Youve had it now!'
          ], z: 100,
            width: 300,
            clearwhendone: true,
            minwait: 3,
            randwait: 0,
            delay:5
          );
          havepushed++;


        }
//        OPENWORLD.Actor.playActionThen(priest37ii, "push", "idle", delay: 2);
      } else {
        setState(() {
          if (mounted)
            roomname = "";
        });
      }
    });

    var citizen3ii;
    var donkey3;
    if (OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {
      // This is your friend at bethphage who is having trouble with his donkey
      citizen3ii = await OPENWORLD.Actor.copyActor(
          citizen3, randomduration: 0.1,
          action: 'work'); //duration:0.7, resetposition: true);//,action:"idle3");
      _hotload.add(citizen3ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen3ii, 53.81, 12.64, 0, 3, lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(citizen3ii, 90); //187);//266);//187);
      donkey3 = await OPENWORLD.Actor.copyActor(
          donkeypack); //,action:"walk",resetposition: true);//,action:"idle3");
      //threeJs.scene.add( donkey3);
      donkey3.scale.setValues(0.04, 0.04,
          0.04); //25, 0.0025, 0.0025);
      _hotload.add(donkey3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkey3, 53.85, 12.64, 0, 3,
          lerpopacity: 1.0); //, normalize2world:true);
      OPENWORLD.Space.objTurn(donkey3, 180, normalize2world: true);
      // Need this here so that getPathSouthFriend() knows where your friend is
      // OPENWORLD.Space.worldToLocalSurfaceObjHide(
      //     friendbethphagegroup, 53.85, 12.64, 0, 3);
      // Are you creating this even if not bethphage journey?
      friendbethphagegroup = THREE.Group();
//    OPENWORLD.Mob.setName( friendbethphagegroup,'yourfriend');
      // friendbethphagegroup?.extra['finalsiloamposx']=-8.1;
      // friendbethphagegroup?.extra['finalsiloamposy']=-52.3-0.1;
      //var child1ii = await OPENWORLD.Actor.copyActor(child12, action: "idle3");

      // Create the stableboy at the pool of siloam
      // Child waiting to take donkeys
      var child1ii=await OPENWORLD.Actor.copyActor(child12,action:"idle3");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          child1ii, -8.13, -52.32, 0.0, 3);
      _hotload.add(child1ii);
      //  OPENWORLD.Space.faceObjectAlways(child1ii, threeJs.camera);
      OPENWORLD.BaseObject.setDistanceTrigger(
            child1ii, dist: 0.3, event: (action) {
          if (action) {
            OPENWORLD.Mob.setSpeech(child1ii,
              ["1 coin each to stable"], z: 100,
              width: 300,
              clearwhendone: true,
              minwait: 6,
              scale: 0.4,
              randwait: 0,
              //   delay:9
            );
          } else {

          }
        });
      friendbethphagegroup!.extra['stableboy'] = child1ii;
      friendbethphagegroup!.extra['nocache'] = true; // horrible fudge

      _hotload.add(friendbethphagegroup);

      if (gamestart==GameStart.bethphage) {

        // This is for the initial donkey near bethphage that is your friends who is having trouble with his pack
         OPENWORLD.BaseObject.setDistanceTrigger(
          donkey3, dist: 0.5, event: (action) {
        if (action) {
          if (horseriding) {
            horseriding = false;
            // Stop issue with dismounting donkey while horseriding is false
            if (OPENWORLD.System.isDesktop()&&horsekeyboardcallback!=null)
              horsekeyboardcallback!.type=OPENWORLD.KeyboardCallbackType.disabled;
            OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(
                threeJs.camera, 53.90, 12.86, OPENWORLD.Camera.cameraoffset,
                4.0);
            OPENWORLD.Space.faceObjectLerp(
                threeJs.camera, citizen3ii, 1.0, delay: 4);
            var origpitchdiff = pitchdiff;
            OPENWORLD.Space.faceObjectAlways(citizen3ii, threeJs.camera);
            ;
            OPENWORLD.Actor.playActionThen(citizen3ii, "wave", "idle", delay: 8);

            if (OPENWORLD.Camera.pitch<-20)  // so can see your friends speech
              OPENWORLD.Camera.setPitch(-20);
            var time = OPENWORLD.Mob.setSpeech(citizen3ii, //donkey3groupi, [
                [
                  'Long time no see!',
                  'My pack was loose',
                  'Are you going to the Tamid?',
                  'We should go together',
                  "Let's go"
                ], z: 90,
                width: 300,
                clearwhendone: true,
                minwait: 5,
                scale: 0.4,
                randwait: 0,
                delay: 9,
              callbackonfinish: (actor) {
                OPENWORLD.Space.removeFaceObjectAlways(citizen3ii);
                pitchdiff = -10.0;
              }
            );
           // Future.delayed(
            //    Duration(milliseconds: (time * 1000).round()), () async {

              //   OPENWORLD.Camera.setPitch(-10);//pitch = -20.0;
          //  });

            //  OPENWORLD.You.drag=0.2;


            Future.delayed(
                Duration(milliseconds: ((time + 1) * 1000).round()), () async {
              pitchdiff = origpitchdiff;
              OPENWORLD.Space.objTurnLerp(citizen3ii, 180, 0.9);
              OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(
                  citizen3ii, 53.85, 12.64 + 0.01, 0.033, 1.0);
              OPENWORLD.Actor.playAction(
                  citizen3ii, action: "sittableleft", duration: 1.2); //0.7);
              // OPENWORLD.Space.removeObjFromHide(citizen22v);

              Future.delayed(Duration(milliseconds: 1000), () async {
                friendbethphagegroup!.extra['friendaction'] = "sittableleft";
                friendbethphagegroup!.extra['friendold'] = citizen3ii;
                var citizen3vi = await OPENWORLD.Actor.copyActor(
                    citizen3, randomduration: 0.1,
                    action: 'sittableleft'); //duration:0.7, resetposition: true);//,action:"idle3");
                friendbethphagegroup!.extra['friend'] = citizen3vi;
                friendbethphagegroup!.extra['frienddonkey'] = donkey3;
                friendbethphagegroup!.extra['friendinc'] = 0; // this is for the chats that happen as you go along
                friendbethphagegroup!.extra['friendwaiting'] = false;
                friendbethphagegroup!.extra['friendnexttick'] = OPENWORLD.System.currentMilliseconds() + 5000;

                //   var sphereAxis = new AxesHelper(2000);
                //  donkey3groupi.add(sphereAxis);

                // OPENWORLD.BaseObject.clearAll(citizen22v);  // could still be in hide
                OPENWORLD.Space.removeObjFromHide(citizen3ii);
                citizen3ii.visible = false;
                friendbethphagegroup!.add(citizen3vi);
                //_hotload.remove(citizen22v);
                citizen3vi.position.x = 0.0;
                citizen3vi.position.y = 0.028;
                citizen3vi.position.z = 0.0; //-0.013;
                // !! You must reset rotation because objTurn subtracts 180
                citizen3vi.rotation.x = 0.0;
                citizen3vi.rotation.y = 0.0;
                citizen3vi.rotation.z = 0.0; //-0.013;

                //citizen22v.updateMatrixWorld(true);
                //  OPENWORLD.Space.removeObjFromHide(citizen22v);
                //    OPENWORLD.Space.objTurn(citizen22v,180);
                //   OPENWORLD.Space.setTurnPitchRoll(citizen22v,0.0,0.0,0.0);//, turn, pitch, roll)
                //   OPENWORLD.Space.objTurn(citizen22v, 0);
                // OPENWORLD.Space.objTurnLerp(citizen22v, 0,1.0,delay:1.0);
                // _hotload.remove(citizen22v);friendbethphage.add(citizen22v);
//            friendbethphagegroup!.add(citizen22v);
                //    OPENWORLD.Space.objTurn(citizen22v, 0);
                OPENWORLD.Space.removeObjFromHide(donkey3);
//            OPENWORLD.BaseObject.clearAll(donkey3); // could still be in hide
                donkey3.position.x = 0.0;
                donkey3.position.y = 0.0;
                donkey3.position.z = 0.0;
                // !! You must reset rotation because objTurn subtracts 180
                donkey3.rotation.x = 0.0;
                donkey3.rotation.y = 0.0;
                donkey3.rotation.z = 0.0; //-0.013;
                // OPENWORLD.Space.setTurnPitchRoll(
                //     donkey3, 0.0, 0.0, 0.0); //, turn, pitch, roll)
                //   OPENWORLD.Space.objTurn(donkey3, 0);
                print("frienddonkey walks");
                OPENWORLD.Actor.playAction(donkey3, action: "walk"); //,duration:1.2);//0.7);
                // _hotload.remove(donkey3);
                friendbethphagegroup!.attach(donkey3);
                //   friendbethphagegroup!.add(donkey3);
                //   friendbethphagegroup!.updateMatrixWorld(true);
                OPENWORLD.Space.worldToLocalSurfaceObjHide(
                    friendbethphagegroup, 53.85, 12.64, 0, 3); //,
                OPENWORLD.Space.objTurn(
                    friendbethphagegroup!, 180.0, normalize2world: true);
                //citizen22v.updateMatrixWorld(true);
                donkey3.updateMatrixWorld(true);
                //   threeJs.scene.updateMatrixWorld(true);

                //  normalize2world: true); //187);//266);//187);
                OPENWORLD.Space.objTurnLerp(threeJs.camera, 260, 1);
                List<Map> positions; /*= [
              {"p": [53.85, 12.64, 0], 'v': horsespeed / 2}
            ];*/
                positions = Glob.getCurrentPathSouthFriend!();


                OPENWORLD.Mob.setName(friendbethphagegroup, "donkeygroup3i");
                //  OPENWORLD.Mob.setName(_horse, "myhorse");
                //  OPENWORLD.Mob.setName(threeJs.camera, "me");
                //  Future.delayed(Duration(milliseconds: 1000), () async {
                //   print("positions" + positions.toString());

                // Timer.periodic(const Duration(seconds: 2), (timer) {
                // print(timer.tick);

                //    print("donkey get turn "+OPENWORLD.Math.standardAngle(OPENWORLD.Space.getTurn(donkey3groupi)).toString()+ " "+OPENWORLD.Camera.turn.toString());


                // });

                Future.delayed(Duration(milliseconds: 2000), () async {
                  horseriding = true;
                  if (OPENWORLD.System.isDesktop()&&horsekeyboardcallback!=null)
                    horsekeyboardcallback!.type=OPENWORLD.KeyboardCallbackType.unconditional;
                  OPENWORLD.Mob.moveToLoop(friendbethphagegroup,
                      positions,
                      // hidedist:0,
                      lerpopacity: 1.0,
                      surfaceonly: true,
                      normalize2world: true,
                      looptype: OPENWORLD.Mob.LoopTypeStop
                    // facedir: true,
                    //  duration:1.0,
                    //facenow: true,
                    ///randomduration: 0.1,
                    //  reverseloop:true,
                    //action: "walk" //straight"
                  );
                  friendbethphagegroup!.extra['followingfriend'] = true;
                });
                // });
              });
            });
          }
        } else {

        }
      });
    }
    }


    // Tombs along kidron valley
    var tomb2= await OPENWORLD.Model.createModel(
        'assets/models/tomb2.glb');
    _hotload.add(tomb2);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb2,  21.30+0.1, -10.88+0.3,0.1, 20,lerpopacity: 1.0); // 3.2,2.5, 0.0);
    tomb2.scale.setValues(0.135,0.135,0.135);
    OPENWORLD.Space.objTurn(tomb2, 100-180);

    var tombabsalom= await OPENWORLD.Model.createModel(
        'assets/models/tombabsalom.glb');
    _hotload.add(tombabsalom);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tombabsalom,  22.50, -7.81,0.0,20,lerpopacity: 1.0);//22.2,-8.0,0.0,20);//4.0 ,-35.5,0.0, 20); // 3.2,2.5, 0.0);
    tombabsalom.scale.setValues(0.35,0.35,0.35);
    OPENWORLD.Space.objTurn(tombabsalom,290);

    var tomb2bleftright=tomb2.clone();
    OPENWORLD.BaseObject.setVisible(tomb2bleftright, false,groupname:'topright');
    OPENWORLD.BaseObject.setVisible(tomb2bleftright, false,groupname:'topleft');
    _hotload.add(tomb2bleftright);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb2bleftright,  15.03+0.6, -36.53,0.15,20,lerpopacity: 1.0);//22.2,-8.0,0.0,20);//4.0 ,-35.5,0.0, 20); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tomb2bleftright,200+20);

    var tomb2bleftrightii=tomb2bleftright.clone();
    OPENWORLD.BaseObject.setVisible(tomb2bleftrightii, false,groupname:'back');
    _hotload.add(tomb2bleftrightii);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb2bleftrightii, 17.78+0.8, -33.53,0.15,20,lerpopacity: 1.0);//22.2,-8.0,0.0,20);//4.0 ,-35.5,0.0, 20); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tomb2bleftrightii,210);

    var tomb2bleftrightiii=tomb2bleftrightii.clone();
    _hotload.add(tomb2bleftrightiii);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb2bleftrightiii,  12.71+0.1, -38.87,0.35,20,lerpopacity: 1.0);//22.2,-8.0,0.0,20);//4.0 ,-35.5,0.0, 20); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tomb2bleftrightiii,220);

    var tomb2bleftrightiv=tomb2bleftrightii.clone();
    _hotload.add(tomb2bleftrightiv);
    OPENWORLD.BaseObject.setVisible(tomb2bleftrightiv, false,groupname:'bottomleft');
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb2bleftrightiv, 20.48, -31.13,0.25,20,lerpopacity: 1.0);//22.2,-8.0,0.0,20);//4.0 ,-35.5,0.0, 20); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tomb2bleftrightiv,220);
    tomb2bleftrightiv.scale.setValues(0.1,0.1,0.1);

    var tomb2bleftrightv=tomb2bleftrightiv.clone();
    _hotload.add(tomb2bleftrightv);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb2bleftrightv, 7.30+0.3, -46.90,0.2,20,lerpopacity: 1.0);//22.2,-8.0,0.0,20);//4.0 ,-35.5,0.0, 20); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tomb2bleftrightv,250);
    tomb2bleftrightv.scale.setValues(0.1,0.1,0.1);

    var tomb2bleftrightvi=tomb2bleftrightiv.clone();
    _hotload.add(tomb2bleftrightvi);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb2bleftrightvi, 8.46, -43.70,0.15,20,lerpopacity: 1.0);//22.2,-8.0,0.0,20);//4.0 ,-35.5,0.0, 20); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tomb2bleftrightvi,210);
    tomb2bleftrightvi.scale.setValues(0.1,0.1,0.1);

    // Olive trees and workers along kidron valley
    var olivetrees=[
      [10.74, -22.49], //0
       [5.85, -27.98], //1
      [5.47, -28.33 ], //2
      [12.63-0.25, -22.95],//3   oliveman
      [12.76-0.25, -22.53],
      [ 2.65+goatoffsetx, -37.35],  // on with the goats
     [2.87+goatoffsetx, -36.87]
       ];
    var olivepickerlist=[
      citizen2,
      citizen22,
      citizen23
      /*citizenf2,
      citizenf22,
      citizenf3,
      citizenf32,
      citizen43,
      citizen23,
      citizen33,*/
    ];
    var olivepickerind=OPENWORLD.Math.randInt(olivepickerlist.length);
  //  var manind=OPENWORLD.Math.randInt(manlist.length);
    var goatman=null;
    var oliveman=null;
    for (var i=0; i<olivetrees.length; i++) {
      var olivetreepos = olivetrees[i];
      olivetree = await Tree.createTree([
//        var treei = await tree.createTree([
        "assets/models/temple/olive.png", //, 0.8], // leafscale
        //  "assets/models/temple/olive.png",//, 0.8],
        //  "assets/models/temple/olive.png"//, 1.4]
      ],
          windspeed: 1.0,
          leafspritescale: 1.2,
          // is redundant because have specified in leafpaths
          // treehollowness: 0.2,
          spreadx: 0.0,
          spreadz: 0.0,
          spready: 0.0,
          randomroll: 0.0,
          //   useplanes: false,
          leafspritespertree: 1,
          // 128,
          spreadytapertop: 0.5);
      //   OPENWORLD.Updateables.add(tree);
      olivetree.scale.setValues(0.1 * 2.5, 0.1 * 2.5, 0.1 * 2.5);
      OPENWORLD.Space.objTurn(olivetree, 90); //OPENWORLD.Math.random() * 360);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          olivetree, olivetreepos[0], olivetreepos[1], 0.1,
          //10.74, -22.49, 0.1,
          10
        //,lerpopacity: 4.0
      ); // -25.51, 116.5,0.0,6);//-25.49, 116.86,0,6);//12.67, 5.22, 0, 6); // 9.8,1.1, 0.14,3); //3.42);
      _hotload.add(olivetree);
      var olivetree2 = await Tree.createTree([
//        var treei = await tree.createTree([
        "assets/models/temple/olive.png", //, 0.8], // leafscale
      ],
          windspeed: 1.0 + OPENWORLD.Math.random() * 0.5,
          leafspritescale: 1.2,
          // is redundant because have specified in leafpaths
          // treehollowness: 0.2,
          spreadx: 0.0,
          spreadz: 0.0,
          spready: 0.0,
          randomroll: 0.0,
          //   useplanes: false,
          leafspritespertree: 1,
          // 128,
          spreadytapertop: 0.5);
      //   OPENWORLD.Updateables.add(tree);
      olivetree2.scale.setValues(0.1 * 2.5, 0.1 * 2.5, 0.1 * 2.5);
      OPENWORLD.Space.objTurn(
          olivetree2, 180); //OPENWORLD.Math.random() * 360);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          olivetree2, olivetreepos[0], olivetreepos[1], 0.1, 10
        //,lerpopacity: 4.0
      );
      _hotload.add(olivetree2);

      // Put a hat on the olive pickers so more visible
      wieldhat(actor) {
        var turbanwield2 = turbanwield.clone();
        turbanwield2.position.x = 7.0;
        turbanwield2.position.y = -1.0;
        turbanwield2.scale.setValues(5.0, 5.0, 5.0);
        OPENWORLD.Space.setTurnPitchRoll(
            turbanwield2, 0, -90, 0);
        OPENWORLD.Actor.wield(actor, turbanwield2, "Bip01_Head");
      }

      if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
        var citizen23ii = await OPENWORLD.Actor.copyActor(
            olivepickerlist[olivepickerind % olivepickerlist.length],
            randomduration: 0.1,
            action: 'hitup'); //duration:0.7, resetposition: true);//,action:"idle3");
        _hotload.add(citizen23ii);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            citizen23ii, olivetreepos[0] + 10.82 - olivetrees[0][0],
            olivetreepos[1] - 22.40 - olivetrees[0][1], 0, 3, lerpopacity: 1.0);
        wieldhat(citizen23ii);
        // OPENWORLD.Space.objTurn(citizen23ii, 180);
        OPENWORLD.Mob.setInitTurn(citizen23ii, 180);
        var staff = stave.clone();
        // OPENWORLD.BaseObject.setVisible(
        //    staff, false, groupname: "head");
        OPENWORLD.Actor.wield(citizen23ii, staff, "Bip01_R_Hand");
        var citizen42ii = await OPENWORLD.Actor.copyActor(
            olivepickerlist[(olivepickerind + 1) % olivepickerlist.length],
            randomduration: 0.1,
            action: 'hitup'); //duration:0.7, resetposition: true);//,action:"idle3");
        _hotload.add(citizen42ii);
        wieldhat(citizen42ii);

        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            citizen42ii, olivetreepos[0] + 10.69 - olivetrees[0][0],
            olivetreepos[1] - 22.60 - olivetrees[0][1], 0, 3,
            lerpopacity: 1.0); //10.85, -22.31
        OPENWORLD.Space.objTurn(citizen42ii, 0); //187);//266);//187);
        var staffii = staff.clone();
        // OPENWORLD.BaseObject.setVisible(
        //    staff, false, groupname: "head");
        OPENWORLD.Actor.wield(citizen42ii, staffii, "Bip01_R_Hand");

        if (i == 3) {
          oliveman = citizen23ii;
          OPENWORLD.BaseObject.setDistanceTrigger(
              oliveman, dist: 1.0, event: (action) {
            if (action) {
              if (!friendbethphagegroup!.extra.containsKey('friendwaiting')||!friendbethphagegroup!.extra['friendwaiting']) {
                OPENWORLD.Actor.playActionThen(
                    friendbethphagegroup!.extra['friend'], "sittablepoint",
                    "sittableleft", duration: 1.2);
                //  friendbethphagegroup!.extra['friendaction'] = "sittableleft";
                OPENWORLD.Space.objTurnLerp(
                    friendbethphagegroup!.extra['friend'], -15 - 180, 1);
              }
            } else {

            }
          });
        } else if (i == 5) {
          goatman = citizen23ii;
          goatman.extra['origpos'] = [
            olivetreepos[0] + 10.82 - olivetrees[0][0],
            olivetreepos[1] - 22.40 - olivetrees[0][1]
          ];
          OPENWORLD.BaseObject.setDistanceTrigger(
              goatman, dist: 1.5, event: (action) {
            if (action) {
              //  OPENWORLD.Actor.playAction(
              //      friendbethphagegroup!.extra['friend'], action: "sittableleft",
              //       duration: 1.2);
              OPENWORLD.Actor.playActionThen(
                  friendbethphagegroup!.extra['friend'], "sittablepoint",
                  "sittableleft", duration: 1.2);
              //  friendbethphagegroup!.extra['friendaction'] = "sittableleft";
              OPENWORLD.Space.objTurnLerp(
                  friendbethphagegroup!.extra['friend'], -15 - 180, 1);
            } else {

            }
          });
        }
        var mat11 = mati.clone();
        hotloadAdd(firsthotload, false, mat11);
        // _hotload.add(mat10);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            mat11, olivetreepos[0] + 10.73 - olivetrees[0][0],
            olivetreepos[1] - 22.46 - olivetrees[0][1], -0.0015,
            2, normalize2world: true);
        mat11.scale.setValues(1.5, 1.5, 1.5);
        OPENWORLD.Space.objTurn(mat11, 90); //187);//266);//187);
        // var olivesmat = await OPENWORLD.Model.createModel(
        //     'assets/models/olivesmat.glb');
        var olivesmat = mati.clone();
        OPENWORLD.BaseObject.setVisible(
            olivesmat, true, groupname: "olives"); // shoes off

        //_hotload.add(mati);
        hotloadAdd(firsthotload, false, olivesmat);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            olivesmat, olivetreepos[0] + 10.73 - olivetrees[0][0],
            olivetreepos[1] - 22.46 - olivetrees[0][1], -0.001, 2,
            normalize2world: true);
        olivesmat.scale.setValues(1.2, 1.2, 1.2);
        OPENWORLD.Space.objTurn(olivesmat, 90 + 180);


        var mat12 = mat11.clone();
        hotloadAdd(firsthotload, false, mat12);
        // _hotload.add(mat10);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            mat12, olivetreepos[0] + 10.83 - olivetrees[0][0],
            olivetreepos[1] - 22.48 - olivetrees[0][1], -0.0015, 2,
            normalize2world: true);
        //  OPENWORLD.Space.objTurn(mat12,90);//187);//266);//187);
        var olivesmatii = olivesmat.clone();
        //_hotload.add(mati);
        hotloadAdd(firsthotload, false, olivesmatii);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            olivesmatii, olivetreepos[0] + 10.83 - olivetrees[0][0],
            olivetreepos[1] - 22.48 - olivetrees[0][1], -0.001, 2,
            normalize2world: true);
        olivepickerind += 2;
      }
    }


    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var citizenolivesit = await OPENWORLD.Actor.copyActor(
          womanlist[olivepickerind % womanlist.length], randomduration: 0.1,
          action: 'sittableidle',
          duration: 2.5); //idle3');
      _hotload.add(citizenolivesit);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizenolivesit, 8.79 + 0.02, -26.81, -0.03,
          3); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
      OPENWORLD.Space.objTurn(citizenolivesit, 317);
      OPENWORLD.BaseObject.setDistanceTrigger(
          citizenolivesit, dist: 1.0, event: (action) {
        if (action) {
          OPENWORLD.Mob.setSpeech(citizenolivesit, [
            'Shalom',
          ], z: 100, width: 300, clearwhendone: true);
          OPENWORLD.Actor.playActionThen(
              citizenolivesit, "sittablewave", "sittableidle", duration: 5);
          //OPENWORLD.Space.objTurnLerp(friendbethphagegroup!,90+45,1,delay:1);
          //OPENWORLD.Space.objTurnLerp(friendbethphagegroup!,180,1,delay:4);
          OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friend'], [
            'Shalom',
          ], z: 100, width: 300, clearwhendone: true, delay: 1.5);
          OPENWORLD.Actor.playActionThen(
              friendbethphagegroup!.extra['friend'], "sittablewave",
              "sittableidle", duration: 5, delay: 1.5);
          OPENWORLD.Space.objTurnLerp(
              friendbethphagegroup!.extra['friend'], -15 - 180, 1);
        } else {

        }
      });
      olivepickerind++;
      var citizenolivesitii = await OPENWORLD.Actor.copyActor(
          childlist[olivepickerind % childlist.length], randomduration: 0.1,
          action: 'sittableidle',
          duration: 2.5); //idle3');
      _hotload.add(citizenolivesitii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizenolivesitii, 8.79 + 0.04, -26.81 + 0.03, -0.02,
          3); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
      OPENWORLD.Space.objTurn(citizenolivesitii, 317);
      olivepickerind++;

      var citizenolivesitiii = await OPENWORLD.Actor.copyActor(
          girllist[olivepickerind % girllist.length], randomduration: 0.1,
          action: 'sittableidle',
          duration: 2.5); //idle3');
      _hotload.add(citizenolivesitiii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizenolivesitiii, 8.79 - 0.01, -26.81 - 0.03, -0.02,
          3); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
      OPENWORLD.Space.objTurn(citizenolivesitiii, 317);
      olivepickerind++;


      print("create goats");
      // goats along kidron valley
      var goats = [
        [-0.58, -45.83],
        [5.0, -30.82], //5.01, -41.69]
      ];
      for (var pos in goats) {
        var goatx = pos[0];
        var goaty = pos[1];
        var area = 0.2;
        for (var i = 0; i < 6; i++) {
          var sheep = await OPENWORLD.Actor.copyActor(goat);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              sheep,
              goatx + OPENWORLD.Math.randFloatSpread(area),

              ///5 * (OPENWORLD.Math.random() - 0.5),
              goaty + OPENWORLD.Math.randFloatSpread(area),
              //5 * (OPENWORLD.Math.random() - 0.5),
              0, 5,lerpopacity: 1.0);
          OPENWORLD.Space.objTurn(sheep, OPENWORLD.Math.random() * 360);
          //  OPENWORLD.Space.objTurn(crab  ,90);  //e
          _hotload.add(sheep);
          // addnpc(sheep, "sheep", true, deathsoundpath: "sounds/bah.mp3");
          OPENWORLD.BaseObject.setDistanceTrigger(
              sheep, dist: 5, event: (action) {
            if (action) {
              //if (OPENWORLD.Math.random() < 0.05)
              // OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5);
              OPENWORLD.Mob.randomwalk(sheep, area, 0.02, 0.05,
                  action: "walk",
                  actionduration: 1,
                  stopaction: "eat",
                  //idle",
                  reset: true,
                  surfaceonly: true
              );
            }
          });
        }
        // boylist[manind%manlist.length]
        var sheperd = await OPENWORLD.Actor.copyActor(
            childlist[olivepickerind % childlist.length], randomduration: 0.1,
            action: 'idle3'); //duration:0.7, resetposition: true);//,action:"idle3");
        _hotload.add(sheperd);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            sheperd, goatx, goaty, 0, 3, lerpopacity: 1.0); //10.85, -22.31
        OPENWORLD.Space.objTurn(sheperd, 0); //187);//266);//187);
        var staff = stave.clone();
        OPENWORLD.Actor.wield(sheperd, staff, "Bip01_R_Hand");
        var sheepsound=OPENWORLD.Sound.getAudioPlayer();
        OPENWORLD.BaseObject.setDistanceTrigger(
            sheperd, dist: 1.5 /* 2 */, event: (action) {
          if (action) {
            //if (OPENWORLD.Math.random() < 0.05)
            // OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5);

            if (friendbethphagegroup!.extra.containsKey('friend')) {
              OPENWORLD.Sound.play(sound:sheepsound,path: 'sounds/goats.mp3', fadein:4, loop: true,
                  volume: 0.5); // makes no sense having sheep when its goats
              OPENWORLD.Actor.playActionThen(
                  friendbethphagegroup!.extra['friend'], "sittablepoint",
                  "sittableleft", duration: 1.2);
              //  friendbethphagegroup!.extra['friendaction'] = "sittableleft";
              OPENWORLD.Space.objTurnLerp(
                  friendbethphagegroup!.extra['friend'], -15 - 180, 1);

              OPENWORLD.Mob.randomwalk(sheperd, area, 0.02, 0.2,
                  action: "walk",
                  actionduration: 1,
                  stopaction: "idle3",
                  //idle",
                  reset: true,
                  surfaceonly: true
              );
            }
          } else {
            if (friendbethphagegroup!.extra.containsKey('friend')) {
              OPENWORLD.Sound.fadeOut(sheepsound, 8.0);
            }
          }
        });
        olivepickerind++;
      }

      // do the boy chasing the goats getting the olives at!! 3.30, -37.38
      var goatx = 3.3 + goatoffsetx;
      var goaty = -37.38;

      var goatdummy=THREE.Object3D();
      OPENWORLD.Space.worldToLocalSurfaceObj(goatdummy, goatx,goaty, 0);
      _hotload.add(goatdummy);
      var sheepsound=OPENWORLD.Sound.getAudioPlayer();
      OPENWORLD.BaseObject.setDistanceTrigger(
          goatdummy, dist: 1.5, event: (action) {
        if (action ) {
          OPENWORLD.Sound.play(sound:sheepsound,path: 'sounds/goats.mp3', fadein:4, loop: true,
              volume: 0.5);

        } else {
          OPENWORLD.Sound.fadeOut(sheepsound, 8.0);
        }
      });

      var area = 0.2;
      var goatactors = [];
      for (var i = 0; i < 6; i++) {
        var sheep = await OPENWORLD.Actor.copyActor(
            goat, randomduration: 0.1, duration: 6);
        goatactors.add(sheep);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            sheep,
            goatx + OPENWORLD.Math.randFloatSpread(area),

            ///5 * (OPENWORLD.Math.random() - 0.5),
            goaty + OPENWORLD.Math.randFloatSpread(area),
            //5 * (OPENWORLD.Math.random() - 0.5),
            0, 5);
        OPENWORLD.Space.objTurn(sheep, OPENWORLD.Math.random() * 360);
        //  OPENWORLD.Space.objTurn(crab  ,90);  //e
        _hotload.add(sheep);
        // addnpc(sheep, "sheep", true, deathsoundpath: "sounds/bah.mp3");
        if (i != 0) {
          OPENWORLD.BaseObject.setDistanceTrigger(
              sheep, dist: 5, event: (action) {
            if (action) {
              //if (OPENWORLD.Math.random() < 0.05)
              // OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5);
              OPENWORLD.Mob.randomwalk(sheep, area, 0.02, 0.05,
                  action: "walk",
                  actionduration: 1,
                  stopaction: "eat",
                  //idle",
                  reset: true,
                  surfaceonly: true
              );
            }
          });
        }
      }
      // boylist[manind%manlist.length]
      var sheperd = await OPENWORLD.Actor.copyActor(
          childlist[olivepickerind % childlist.length], randomduration: 0.1,
          action: 'idle3'); //duration:0.7, resetposition: true);//,action:"idle3");
      _hotload.add(sheperd);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheperd, goatx, goaty, 0, 3, lerpopacity: 1.0); //10.85, -22.31
      OPENWORLD.Space.objTurn(sheperd, 0); //187);//266);//187);
      var staff = stave.clone();
      OPENWORLD.Actor.wield(sheperd, staff, "Bip01_R_Hand");
      var haschased = false;
      OPENWORLD.BaseObject.setDistanceTrigger(
          sheperd, dist: 5, event: (action) async {
        if (action) {
          if (!haschased) {
            haschased = true;
            OPENWORLD.Mob.moveTo(goatactors[0],
                //  [[ 54.66, 11.64,0, 0.1]],
                //     [[ 52.66, 12.64,0, 0.1]],
                [[ 2.81 + goatoffsetx, -37.44, 0, 0.04]],
                facedir: true,
                action: "walk",
                actionduration: 1,
                //    normalize2world: true,
                stopaction: "eat",
                surfaceonly: true);
            OPENWORLD.Mob.moveTo(sheperd,
                //  [[ 54.66, 11.64,0, 0.1]],
                //     [[ 52.66, 12.64,0, 0.1]],
                [[ 2.93 + goatoffsetx, -37.48, 0, 0.05]],
                facedir: true,
                action: "walkup",
                //  actionduration: 2,
                //    normalize2world: true,
                stopaction: "handsouttogether",
                surfaceonly: true,
                delay: 4);
            OPENWORLD.Mob.setSpeech(sheperd, [
              'Get back here!',
              'Sorry about that!'

            ], z: 100,
                width: 300,
                clearwhendone: true,
                minwait: 3,
                randwait: 0,
                delay: 5
            );
            var time = await OPENWORLD.Mob.moveTo(goatman,
                [[ 2.81 + goatoffsetx, -37.36, 0, 0.04]],
                facedir: true,
                action: "walk",
                stopaction: "handsouttogether",
                // stopactionduration:0.5,
                surfaceonly: true,
                delay: 7);


            OPENWORLD.Space.faceObjectLerp(
                goatman, goatactors[0], 1.0, delay: time + 1);
            //   OPENWORLD.Actor.playAction(goatman,action:"handsouttogether", delay:time+1);
            OPENWORLD.Mob.setSpeech(goatman, [
              'Shoo!'

            ], z: 100,
                width: 300,
                clearwhendone: true,
                minwait: 3,
                randwait: 0,
                delay: time + 1
            );

            Future.delayed(
                Duration(milliseconds: (1000 * (time + 2)).round()), () async {
              OPENWORLD.Mob.setSpeech(sheperd, [
                'Sorry',

              ], z: 100,
                width: 300,
                clearwhendone: true,
                minwait: 3,
                randwait: 0,
              );
              OPENWORLD.Mob.moveTo(sheperd,
                  [[ goatx, goaty, 0, 0.04]],
                  facedir: true,
                  action: "walk",
                  //  actionduration: 1,
                  //    normalize2world: true,
                  stopaction: "idle3",
                  surfaceonly: true);
              var time2 = await OPENWORLD.Mob.moveTo(goatactors[0],
                  [[ 3.20 + goatoffsetx, -37.41, 0, 0.04]],
                  facedir: true,
                  action: "walk",
                  actionduration: 1,
                  //    normalize2world: true,
                  stopaction: "eat",
                  surfaceonly: true);
              var time3 = await OPENWORLD.Mob.moveTo(goatman,
                  [
                    [
                      goatman.extra['origpos'][0],
                      goatman.extra['origpos'][1],
                      0,
                      0.04
                    ]
                  ],
                  facedir: true,
                  action: "walk",
                  // actionduration: 1,
                  //    normalize2world: true,
                  stopaction: "hitup",
                  surfaceonly: true,
                  delay: 4);
              OPENWORLD.Space.objTurnLerp(
                  goatman, OPENWORLD.Mob.getInitTurn(goatman), 1,
                  delay: time3 + 1);

              Future.delayed(Duration(
                  milliseconds: (1000 * (time2 + 2)).round()), () async {
                OPENWORLD.BaseObject.setDistanceTrigger(
                    sheperd, dist: 5, event: (action) {
                  if (action) {
                    //if (OPENWORLD.Math.random() < 0.05)
                    // OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5);
                    OPENWORLD.Mob.randomwalk(sheperd, area, 0.02, 0.2,
                        action: "walk",
                        actionduration: 1,
                        stopaction: "idle3",
                        //idle",
                        reset: true,
                        surfaceonly: true
                    );
                  }
                });
                OPENWORLD.BaseObject.setDistanceTrigger(
                    sheperd, dist: 5, event: (action) {
                  if (action) {
                    //if (OPENWORLD.Math.random() < 0.05)
                    // OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5);
                    OPENWORLD.Mob.randomwalk(sheperd, area, 0.02, 0.2,
                        action: "walk",
                        actionduration: 1,
                        stopaction: "idle3",
                        //idle",
                        reset: true,
                        surfaceonly: true
                    );
                  }
                });

                OPENWORLD.BaseObject.setDistanceTrigger(
                    goatactors[0], dist: 5, event: (action) {
                  if (action) {
                    //if (OPENWORLD.Math.random() < 0.05)
                    // OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5);
                    OPENWORLD.Mob.randomwalk(goatactors[0], area, 0.02, 0.05,
                        action: "walk",
                        actionduration: 1,
                        stopaction: "eat",
                        //idle",
                        reset: true,
                        surfaceonly: true
                    );
                  }
                });
              });
            });
          }
        }
      });
    }

    // Chats your friend makes as you go along the kidron valley
    var chats=[
      {"chat":[
        'I think I need a new pack',
        'It keeps coming loose',
        'How are you going?',
        "I haven't seen you for a while",  // 53.85, 12.64
      ],"x":53},  //0
      {"chat":['I was just visiting friends in Bethany',
        'And I thought on the way back to Jericho',
        'I should do the Tamid.',
        "I haven't been for a few months"],"x":47},  //1  47.11, 13.33
      {"chat":["How is it living in Bethphage?",
        "Does your wife mind living out of Jerusalem?",
        "with the jackals?"]},  //2  40.64, 14.50
      {"chat":['I wonder if the Tamid will be busy',
        'I think going in the morning is a good idea'],"x":33}, //3 33.22, 12.36
      {"chat":["The old ramp never ceases to amaze me",
        "It'd be handy if it was open to the public",
        'instead of every 100 years',
        'for the red heifer ceremony',
        "Imagine how much easier it'd be",
        'to get to the temple',
        "But we'd still have to bathe though"],"x":19,"y":7.0},//18, "y":5.63},//19,"y":7.0}, // does it if world.x>19 and world.y<7  4 19.84, 6.97
      {"chat":['My friend Simon is a priest and he is at the temple today',
        "But he still hasn't been picked to do the Tamid",
        'Maybe this time I will see him in the Tamid',
        "It's what he's been dreaming of"
      ],"y":0}, //5  17.81, 0.79

      // absolaoms
      // zechariah
      {"chat":["Something my friend Simon",
        "always tells me when we",
        "pass these tombs is he",
        "say he's from the "
            "Benei Hezir family",
        "But he's not so wealthy",
        "so I'm not sure if it's true.",
        "You'd have to be wealthy",
        "to build a tomb like that"],"y":-6.0}, //6  18.09, -6.17

      {"chat":[
        "Remember when we were",
        "kids and we were sitting next",
        "to that donkey and just as the chief priest",
        "walked past the donkey let off",
        "and the priest thought it was you.",
        'And you said "it wasn\'t me, it was the donkey"',
        "And the priest smiled like he knew it was the donkey",
        "Still makes me laugh"
      ],"y":-12.86}, //7  16.53, -12.86
      {"chat":["I wouldn't want to work out in this heat",
        "Someone's got to do it I guess"],"y":-21.40}, //-21.30  8
      {"chat":["Someone's going to get annoyed",
        "if those goats get into their olives"],"y":-28.5} ,//9
      {"chat":["Heh, what did I tell you.",
        "Goats and olives don't mix"],"y":-36.0},  //10
      {"chat":["Nearly there.",
        "The pool of Siloam",
        "is such a relief after a long journey"],"y":-45.0} //11

    ];

    var done10am=false;

    // Do the chats as go along bethphage journey
    Glob.nextfriendtick=(anglediff)
    {
      var worldpos = OPENWORLD.You.getWorldPos();
      if (anglediff.abs()<110&&OPENWORLD.System.currentMilliseconds()>=friendbethphagegroup!.extra['friendnexttick']) {

        if (worldpos.y<0&&OPENWORLD.Time.time<10&&!done10am) {
          done10am=true;
          OPENWORLD.Time.setTimeLerp(10, 60);
        }
        if (friendbethphagegroup!.extra['friendinc']>=0&&friendbethphagegroup!.extra['friendinc']<chats.length) {
          Map chat=chats[friendbethphagegroup!.extra['friendinc']];
        //  print("current chat"+chat.toString());
          var dochat=!chat.containsKey('y')&&!chat.containsKey('x');
          if (!dochat) {
            if (chat.containsKey('y')&&chat.containsKey('x')) {
              var x = chat['x'];
              var y = chat['y'];
             // print("xy chat"+worldpos.toString()+" "+x.toString()+" "+y.toString());
              dochat = worldpos.x > x.toDouble()&& worldpos.y < y.toDouble();

            } else if (chat.containsKey('y')) {
              var y = chat['y'];
              // if (y!=null)
              dochat = worldpos.y < y.toDouble();
            } else if (chat.containsKey('x')) {
          //  if (!dochat&&!chat.containsKey('y')&&chat.containsKey('x')) {
              var x = chat['x'];
              //if (x!=null)
              dochat = worldpos.x > x.toDouble();
            }
            //  print("not do chat"+y.toString()+" "+worldpos.y.toString());

          }
          if (dochat) {
            OPENWORLD.Mob.setSpeech(friendbethphagegroup!.extra['friend'],
              chat["chat"], z: 80,
              width: 300,
              clearwhendone: true,
              minwait: 6,
              scale: 0.4,
              randwait: 0,
              //   delay:9
            );
            friendbethphagegroup!.extra['friendnexttick'] =
                OPENWORLD.System.currentMilliseconds() + 70 * 1000;
            friendbethphagegroup!.extra['friendinc']++;
          }
        }
      }
    };



    // This is what restarts an existing game and put you back on your donkey and your friend on a donkey also
    var restartgame=gamestart==GameStart.bethphage&&friendbethphagegroup!=null&&
        dict['p'][0]<56&&(dict['l']==0||!dict.containsKey('l')||(dict['l']==1&&dict['p'][0]<10.24&&dict['p'][1]>-6.95));
    if (restartgame) {

        print("restart bethphage");
        //var worldpos = OPENWORLD.You.getWorldPos();
      if (!Glob.hasreachedsiloam) {//&&dict['p'][0]<56) {//worldpos.x<56) { // 56 so dont mount if just left home
         // print("mount")
         // callwhenloaded(() {
            mount();
            horseriding = true;
        //  });
        //if (dict.containsKey('t'))
         //   OPENWORLD.Space.objTurnLerp(threeJs.camera, dict['t'],1);
      }

      friendbethphagegroup!.extra['friendaction'] = "sittableleft";
      friendbethphagegroup!.extra['friendold'] = citizen3ii;
        friendbethphagegroup!.extra['friendold'].visible=false;  // This to stop friend dropping from the sky when past siloam and restart the game
      var citizen3vi = await OPENWORLD.Actor.copyActor(
          citizen3, randomduration: 0.1,
          action: 'sittableleft'); //duration:0.7, resetposition: true);//,action:"idle3");
      friendbethphagegroup!.extra['friend'] = citizen3vi;
      friendbethphagegroup!.extra['frienddonkey'] = donkey3;
      var friendinc = -1;
      for (var i = 0; i < chats.length; i++) {
        Map chat = chats[i];
        if (friendinc == -1) {
          print("chat bethphage " + i.toString() + " " + chat.toString() + " " +
              dict['p'].toString());

          if (chat.containsKey('x') && chat.containsKey('y')) {
            if (dict['p'][0] > chat['x'] && dict['p'][1] < chat['y'])
              friendinc = i;
          } else if ((chat.containsKey('x') && dict['p'][0] > chat['x']) ||
              (chat.containsKey('y') && chat['y']! < dict['p'][1])) {
            friendinc = i;
          }
        }
      }
      print("friend inc calculated" + friendinc.toString());
      friendbethphagegroup!.extra['friendinc'] = friendinc; //4+4+2;  // the chats that go along
      friendbethphagegroup!.extra['friendwaiting'] = false;
      friendbethphagegroup!.extra['friendnexttick'] =
          OPENWORLD.System.currentMilliseconds() + 5000;

      // OPENWORLD.BaseObject.clearAll(citizen22v);  // could still be in hide
      OPENWORLD.Space.removeObjFromHide(citizen3ii);
      citizen3ii.visible = false;
      friendbethphagegroup!.add(citizen3vi);
      //_hotload.remove(citizen22v);
      citizen3vi.position.x = 0.0;
      citizen3vi.position.y = 0.028;
      citizen3vi.position.z = 0.0; //-0.013;
      // !! You must reset rotation because objTurn subtracts 180
      citizen3vi.rotation.x = 0.0;
      citizen3vi.rotation.y = 0.0;
      citizen3vi.rotation.z = 0.0; //-0.013;

      OPENWORLD.Space.removeObjFromHide(donkey3);
//            OPENWORLD.BaseObject.clearAll(donkey3); // could still be in hide
      donkey3.position.x = 0.0;
      donkey3.position.y = 0.0;
      donkey3.position.z = 0.0;
      // !! You must reset rotation because objTurn subtracts 180
      donkey3.rotation.x = 0.0;
      donkey3.rotation.y = 0.0;
      donkey3.rotation.z = 0.0; //-0.013;
      // OPENWORLD.Space.setTurnPitchRoll(
      //     donkey3, 0.0, 0.0, 0.0); //, turn, pitch, roll)
      //   OPENWORLD.Space.objTurn(donkey3, 0);
      // OPENWORLD.Actor.playAction(
      //     donkey3, action: "walk"); //,duration:1.2);//0.7);
      // _hotload.remove(donkey3);
      friendbethphagegroup!.attach(donkey3);
      if (Glob.hasreachedsiloam) { //teststable) {
        // If restart game and have reached siloam
        callwhenloaded(() {
          if (hasbathed)
            Glob.donebathing!();
          else
            reachedsiloam(null);
        });
      } else {
        // Otherwise going along kidron valley
        List posi = dict['p'];
        var foundind = OPENWORLD.Math.findClosestNextIndex(
            citizenpathsouth, posi[0], posi[1]);
        var pos = citizenpathsouth[foundind]; //18];//26];//7];//33];;//];
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            friendbethphagegroup, pos[0], pos[1], 0, 3);
        List<Map> positions = Glob.getCurrentPathSouthFriend!();

        // restart
        print("frienddonkey walksii");
        OPENWORLD.Actor.playAction(donkey3, action: "walk"); //,duration:1.2);//0.7);

        // This is never called if you are past the pool of siloam
      //  OPENWORLD.Space.faceObjectLerp(threeJs.camera, friendbethphagegroup, 1);
      ////  OPENWORLD.Space.faceObjectLerp(
      //      threeJs.camera, friendbethphagegroup, 1, delay: 5);
        if (dict.containsKey('t')) {
          OPENWORLD.Space.objTurnLerp(threeJs.camera, dict['t'], 1.0);
          OPENWORLD.Space.objTurnLerp(threeJs.camera, dict['t'], 1.0, delay: 5);
        }
        OPENWORLD.Mob.moveToLoop(friendbethphagegroup,
            positions,
            // hidedist:0,
            lerpopacity: 1.0,
            surfaceonly: true,
            normalize2world: true,
            looptype: OPENWORLD.Mob.LoopTypeStop // facedir: true,
          //  duration:1.0,
          //facenow: true,
          ///randomduration: 0.1,
          //  reverseloop:true,
          //action: "walk" //straight"
        );
      }
      //callwhenloaded(() {
        friendbethphagegroup!.extra['followingfriend'] = true;
     // });
      //OPENWORLD.Camera.setTurn(180);

    //);
    }

  }
}
