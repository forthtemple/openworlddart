// Code related to the chamber of the hearth journey and shares code with hotload_secondtemple for the tamid, ketoret etc
// It can be hotloaded
part of 'SecondTemplePage.dart';

extension HotloadHearthExt on SecondTemplePageState {
  hotloadHearth(firsthotload) async {
    // ----- Hearth
    instancedHaysHearth.reset();
    instancedPillows.reset();
    instancedBeddings.reset();

    var hearthsound;
    if (gamestart==GameStart.hearth)
      hearthsound="sounds/hearth.mp3";
    else
      hearthsound=OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/sleeping.mp3":"sounds/yeshiva.mp3";
    roomHearth = OPENWORLD.Room.createRoom(0.93, 2.76,
        volume: 0.05, roomspeed:1.5 / 20,soundpath:hearthsound,exitroom: roomTerrain,name:"Chamber of the Hearth"); //THREE.Object3D();  0.01

    roomHearth.extra['guide'] = [
      "You are at the chamber of the Hearth",
    ];
    //OPENWORLD.Room.setIndoors(roombethphage,true);
    OPENWORLD.Room.setAutoIndoors(roomHearth, true);
    _hotload.add(roomHearth);

    OPENWORLD.Room.setDistanceTrigger(roomHearth,
        maxy: 3.39, miny: 2.19, minx:0.46, maxx:1.33, event:(action) {
          if (action) {
            setState(() {

              if (mounted)
                roomname = "Chamber of the Hearth";
            });
          } else {
            setState(() {
              if (mounted)
                roomname = "";
            });
          }
        });

    // Create the hearth
    // Position of the hearth
    var hearthposx = 0.94 - 0.01; //0.92;//0.94;
    var hearthposy = 3.12; //2.92;//2.65;

    var hearth = await OPENWORLD.Model.createModel(
        'assets/models/hearth.glb',castshadow:true);
    _hotload.add(hearth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hearth, hearthposx, hearthposy, 0.001,level:1,
        2); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
    hearth.scale.setValues(0.04, 0.04, 0.04);
    // if step on hearth then pain sound
    OPENWORLD.Obstacles.createObstacle(
        hearthposx, hearthposy, 0.1, 0.1,level:1,//,marker:_hotload
        callback: (obstacle) {
          print("hit hearth");
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick(['sounds/pain.mp3','sounds/pain2.mp3','sounds/pain3.mp3']),volume: 0.1);
        },
        callbacknextwait: 1
    );
    var firesound = OPENWORLD.Sound.getAudioPlayer();
    OPENWORLD.BaseObject.setDistanceTrigger(hearth,
        dist: 0.2, event:(action) {
          if (action) {
            print("hearth fire on");
            OPENWORLD.Sound.play(sound:firesound,path: 'sounds/fire.mp3',loop:true,
                volume: 0.2,fadein: 3.0);
          } else {
            print("hearth fire off");
            OPENWORLD.Sound.fadeOut(firesound, 3.0);
          }
        });

    var hearthfire = new VolumetricFire(
        Glob.fireWidth, Glob.fireHeight, Glob.fireDepth, Glob.sliceSpacing, threeJs.camera);
    await hearthfire.init();

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hearthfire?.mesh, hearthposx, hearthposy, 0.07,level:1,
        3); //1.46-0.05, 4.22-0.05, 0.11, 3); // 3.35, 0.51, 0.3,3); //3.7);
    hearthfire?.mesh.scale.x = 0.04;
    hearthfire?.mesh.scale.y = 0.04;
    hearthfire?.mesh.scale.z = 0.04;
    _hotload.add(hearthfire?.mesh);
    OPENWORLD.Updateables.add(hearthfire);

    // Create light for the hearth, it is always on
    var hearthlightgroup = THREE.Group();
    var light = new THREE.PointLight(
        0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

    light.intensity = 0.3; // 0.6;
    light.distance = 0.5; //1.2;
    light.castShadow=true;
    light.shadow?.mapSize.width = 64;
    light.shadow?.mapSize.height = 64;;
    light.shadow?.camera?.near = 0.01;
    light.shadow?.camera?.far = 0.5;
   // light.shadow?.radius = 4;
    light.shadow?.blurSamples=10.0;
    // light.position.y = 0.33;
    OPENWORLD.Light.addFlicker(light);
    hearthlightgroup.add(light);
    _hotload.add(hearthlightgroup);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hearthlightgroup, hearthposx, hearthposy, 0.05,level:1, 1, lerplight: 1); //1.46-0.05, 4.22-0.05, 0.0, 3);



    // This the cloumns in the chamber of the hearth
    // Northern two columns
   /* var column2ii = column.clone();
  //  column2ii.scale.setValues(0.03, 0.032, 0.03);
    OPENWORLD.Space.objTurn(column2ii, -90); //45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        column2ii, 1.03 + 0.3, 3.16 - 0.05, 0.1,level:1, 2); //1.09, 3.05, 0, 10);
    _hotload.add(column2ii);*/
    instancedColumns.place(
        -90,  1.03 + 0.3, 3.16 - 0.05, 0.1,level:1); //,5);


  /*  var column2iv = column.clone();
   // column2iv.scale.setValues(0.03, 0.032, 0.03);
    OPENWORLD.Space.objTurn(column2iv, -90); //45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        column2iv, 0.8 - 0.3-0.04, 3.16 - 0.05, 0.1,level:1, 2);
    _hotload.add(column2iv);*/
    instancedColumns.place(
        -90,0.8 - 0.3-0.04, 3.16 - 0.05, 0.1,level:1); //,5);

   /* var column2iiii = column.clone();
    //  column2iii.scale.setValues(0.03, 0.032, 0.03);
    OPENWORLD.Space.objTurn(column2iiii, -90); //45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        column2iiii, 1.03 + 0.3,2.81-0.05, 0.0,level:1, 2); //1.09, 3.05, 0, 10);
    _hotload.add(column2iiii);*/
    instancedColumns.place(
        -90,1.03 + 0.3,2.81-0.05, 0.0,level:1); //,5);

    /*var column2iiv = column.clone();
    // column2iiv.scale.setValues(0.03, 0.032, 0.03);
    OPENWORLD.Space.objTurn(column2iv, -90); //45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        column2iiv, 0.8 - 0.3-0.04,2.81-0.05, 0.0,level:1, 2);
    _hotload.add(column2iiv);*/
    instancedColumns.place(
        -90,0.8 - 0.3-0.04,2.81-0.05, 0.0,level:1); //,5);

    /* var column2iib = column.clone();
    column2iib.scale.setValues(0.03,0.032, 0.03);
    OPENWORLD.Space.objTurn(column2iib,90);//45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(column2iib,1.03, 3.16+0.025,0,3);
    _hotload.add(column2iib);*/
    // Souther two columns
   /* var column2iii = column.clone();
  //  column2iii.scale.setValues(0.3, 0.32, 0.3);
    OPENWORLD.Space.objTurn(column2iii, 90); //45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(column2iii, 1.03+0.05, 2.24, 0,level:1, 2);
    _hotload.add(column2iii);*/
    instancedColumns.place(
        90,1.03+0.05, 2.24, 0.0,level:1); //,5);

   // var column2vi = column.clone();
    /*column2vi.scale.setValues(0.03,0.032, 0.03);
    OPENWORLD.Space.objTurn(column2vi,90);//45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(column2vi,1.34, 2.405, 0, 3);
    _hotload.add(column2vi);*/
  /*  var column2v = column.clone();
   // column2v.scale.setValues(0.03, 0.032, 0.03);
    OPENWORLD.Space.objTurn(column2v, 90); //45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(column2v, 0.74, 2.24, 0,level:1,2);
    _hotload.add(column2v);*/
    instancedColumns.place(
        90,0.74, 2.24, 0.0,level:1); //,5);

    /* var column2vii = column.clone();
    column2vii.scale.setValues(0.03,0.032, 0.03);
    OPENWORLD.Space.objTurn(column2vii,90);//45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(column2vii,0.8-0.31, 2.405, 0, 3);
    _hotload.add(column2vii);*/


    // Brazier in the mikveh
    var brazierposx=0.47+0.02;
    var brazierposy=3.17;
    var priestwarming = await OPENWORLD.Actor.copyActor(
        priest3clothed, action: "squat", randomduration: 0.1);  //handsouttogether
    // setActorSize(citizenoldwoman2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        priestwarming, brazierposx+0.045,brazierposy, 0,level:1,
        0.3); //0.71,0,3);//2.89, 1.06,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
    hotloadAdd(firsthotload, false, priestwarming);
    OPENWORLD.Space.objTurn(priestwarming,270);

    OPENWORLD.Actor.playActionsLoop(priestwarming,
      ["squat","squatright","squat","squatwork"],
      randomaction: true,
      //  fadeout: 0.7
    );
    // priest bathing
    var bather = await OPENWORLD.Actor.copyActor(
        citizen34, action: "idle3", randomduration: 0.1);
    // setActorSize(citizenoldwoman2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bather, 0.53-0.02, 3.30, -0.01,level:1,
        0.3); //0.71,0,3);//2.89, 1.06,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
    hotloadAdd(firsthotload, false, bather);
    OPENWORLD.Space.objTurn(bather,180);

    OPENWORLD.BaseObject.setVisible(
        bather, false, groupname: "citizen_3"); // no pants
    OPENWORLD.BaseObject.setVisible(
        bather, false, groupname: "citizen_4"); // no clothes

    // Priest waiting in mikveh
    var waiter = await OPENWORLD.Actor.copyActor(
        citizen32, action: "handsouttogether", randomduration: 0.1);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        waiter,0.6,3.15, 0,level:1,
        0.3); //0.71,0,3);//2.89, 1.06,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
    hotloadAdd(firsthotload, false, waiter);
    OPENWORLD.Space.objTurn(waiter,-90);
    setcancollide(waiter,true);
    OPENWORLD.Actor.playActionsLoop(waiter,
      ["handsouttogether","work","idlebum","work","handsouttogether","idlenose"],durations:[5,5,null,5,5],//looprepetitionss: [3,3],
      randomaction: true,
      //  fadeout: 0.7
    );

    var clothespilemikveh = clothespile.clone();
    _hotload.add(clothespilemikveh);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clothespilemikveh, brazierposx+0.06,brazierposy, 0,0.5, level:1);


    var slabkey= await OPENWORLD.Model.createModel(
        'assets/models/slabkey.glb'); //,texture:"assets/detailmap.png");
    _hotload.add(slabkey);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        slabkey,    0.91, 2.37+0.004,-0.003, 1,level:1); // 3.2,2.5, 0.0);
    slabkey.scale.setValues(0.015,0.015,0.015);
    OPENWORLD.Space.objTurn(slabkey, 0);
    OPENWORLD.Texture.setMaterial(slabkey, bronzematclean!,groupname:"ring");

    // North monumental doors of the hearth
    var doorwoodhearthnortheast=doorwood.clone();
    _hotload.add(doorwoodhearthnortheast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodhearthnortheast, 1.071 - 0.042, 3.36 + 0.035, 0.00,level:1,
//        doorwoodnortheast, 1.071 - 0.031, 3.36 + 0.035, 0.00,level:1,
        10);

    var doorwoodhearthnorthwest = doorwood.clone();
    _hotload.add(doorwoodhearthnorthwest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodhearthnorthwest, 0.82 - 0.031, 3.36 + 0.035, 0.00,level:1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    // Doorway made up of these two doors that can be opened and closed
    var doorwayhearth=OPENWORLD.Doorway();
    doorwayhearth.addDoor(doorwoodhearthnortheast,0,90);
    doorwayhearth.addDoor(doorwoodhearthnorthwest,0,-90);
    doorwayhearth.obstacle=  OPENWORLD.Obstacles.createObstacle(0.89,3.39,0.4,0.1,level:1);//,marker:_hotload);
    doorwayhearth.setOpenClose(!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwayhearth);

    // Inner court doors south of the chamber of the hearth
    var doorsouthhearth = doorwood.clone();
    _hotload.add(doorsouthhearth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorsouthhearth, 0.85+0.01+0.01+0.004, 2.19-0.03, 0.00,level:1, 10);
    doorsouthhearth.scale.setValues(0.06, 0.08, 0.05);

    var doorwaysouthhearth=OPENWORLD.Doorway();
    doorwaysouthhearth.addDoor( doorsouthhearth,180,-90);
    doorwaysouthhearth.obstacle=  OPENWORLD.Obstacles.createObstacle(0.85+0.01+0.01+0.004, 2.19-0.03,0.1,0.1,level:1);//,marker:_hotload);
    doorwaysouthhearth.setOpenClose(!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwaysouthhearth);

    // This is so that when you do progress don't see the priests all at angles or laying on the ground
      // should all be standing if have done the lottery
    var priestsarestanding=gamestartpos[gamestart].containsKey('progress')&&gamestartpos[gamestart]['progress'].contains('tolottery');
    if (OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var beddingkey = bedding.clone();
      OPENWORLD.Space.objTurn(
          beddingkey, 0);
      beddingkey.scale.setValues(0.6, 1.0, 0.5);
      //    OPENWORLD.Actor.playActionsLoop(priest3iv, ["reclineidle","laysideidle","layidle"],durations:[20,20,20],fadeout:1.0);
      _hotload.add(beddingkey);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          beddingkey, 0.90, 2.47-0.08, -0.003,level:1,
          // -0.006 + OPENWORLD.Math.randFloatSpread(0.002),// 0.87, 2.79
          3); //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);

      // Center priest on marble     // Priest guarding the key
      var priestkey = await OPENWORLD.Actor.copyActor(
          manlist[1], randomduration: 0.1, action:"reclineidle");
     // setcancollide(priestkey,true);
      _hotload.add(priestkey);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priestkey, 0.90, 2.47-0.08, -0.01,level:1, //0.01,//0.87, 2.79
          3); //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);
      OPENWORLD.Space.objTurn(priestkey, 270);

      // Extra security priests
      var priestsextra=[];
      for (var i=0; i<10; i++) {
        var priest = await OPENWORLD.Actor.copyActor(manlist[i % manlist.length], randomduration: 0.1,
            action: "idle");
        setcancollide(priest, true);
        priest.visible=false;
        priestsextra.add(priest);
        _hotload.add(priest);
      }

      // All the sleeping priests on their slabs
      // Uses config so can reuse the actors
      var beddist = 0.03;
      var inc = 0;
      for (var j = 0; j < 6; j++) {
        for (var i = 0; i < 7; i++) {
        //  if (OPENWORLD.Math.random()<0.8) {//i!=6||(i==6&&j%3==0)) {
          if (OPENWORLD.Math.random()<0.9&&(i!=6||(i==6&&j%3==0))) {
            // east side

            var bedposx = 1.23 + 0.03 +
                j * 0.011; //+0.09;// - 5 * 0.04 + (j * 0.04);
            var bedposy = 3.11 - 0.015 -
                (i * 0.06 + OPENWORLD.Math.random() * 0.01) +
                (i / 2).round() * 0.025;
            ;

            instancedBeddings.place(OPENWORLD.Math.randFloatSpread(15),bedposx, bedposy,
                -0.003 + OPENWORLD.Math.randFloatSpread(0.002) + j * beddist, level:1, scale:THREE.Vector3(0.6 + OPENWORLD.Math.randFloatSpread(0.04),
                    1.0 + OPENWORLD.Math.randFloatSpread(0.04),
                    0.5 + OPENWORLD.Math.randFloatSpread(0.04)));//,5);


            instancedPillows.place(OPENWORLD.Math.randFloatSpread(15),bedposx + 0.035 + OPENWORLD.Math.randFloatSpread(0.01),
                bedposy + OPENWORLD.Math.randFloatSpread(0.01),
                0.001 + j * beddist, level:1, scale:THREE.Vector3(0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                    0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                    0.5 + OPENWORLD.Math.randFloatSpread(0.04)));//,5);
            //var priest;
            var turn,pitch,roll,z;

            if ( !priestsarestanding) {
              if (OPENWORLD.Math.random() < 0.3) {
                turn = 270 + OPENWORLD.Math.randFloatSpread(25);
                pitch = 180 + OPENWORLD.Math.randFloatSpread(15);
                roll = OPENWORLD.Math.randFloatSpread(15);
                z = 0.025;
              } else {
                turn = 270 + OPENWORLD.Math.randFloatSpread(25);
                pitch = 0 + OPENWORLD.Math.randFloatSpread(15);
                roll = OPENWORLD.Math.randFloatSpread(10);
                z = -0.01;
              }
            } else {
              z=0.0;
              turn=pitch=roll=0.0;
            }
            z += j * beddist;
        //    print("nammmmii"+OPENWORLD.Config.getObjectName( manlist[inc % manlist.length]).toString()+" "+inc.toString());
           // if (inc>=10) {
              OPENWORLD.Config
                  .config['positions']['poolpositions'][1]['positions'].add(
                  { 'name': OPENWORLD.Config.getObjectName( manlist[inc % manlist.length]),
                    'p': [bedposx, bedposy, z], 'l': 1, 't': turn,
                    'pitch': pitch,
                    'roll': roll,
                    'label':'sleeping',
                    'action': 'layidle',
                    "lerpopacity": 1,
                    "callbackonvisible":(actor) {
                      OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.2, skipFrames:8);
                    },
                    "callbackonhide":(actor) {
                      OPENWORLD.Actor.disableDistanceThrottle(actor);
                    }});

            inc++;

            //OPENWORLD.Space.objTurn(priest, 180);

            // west side

            bedposx = 0.47 + 0.08 - j * 0.011; // + (j * 0.04);
            // bedposy = 3.10 - (i * 0.12 + OPENWORLD.Math.random() * 0.025);
            bedposy = 3.10 - (i * 0.06 + OPENWORLD.Math.random() * 0.01) +
                (i / 2).round() * 0.025;

          /*  bedding2 = bedding.clone();
            OPENWORLD.Space.objTurn(
                bedding2, OPENWORLD.Math.randFloatSpread(15));
            bedding2.scale.setValues(0.6 + OPENWORLD.Math.randFloatSpread(0.04),
                1.0 + OPENWORLD.Math.randFloatSpread(0.04),
                0.5 + OPENWORLD.Math.randFloatSpread(0.04));
            _hotload.add(bedding2);
            OPENWORLD.Space.worldToLocalSurfaceObjHide(
                bedding2, bedposx, bedposy,
                -0.003 + OPENWORLD.Math.randFloatSpread(0.002) + j * beddist,level:1,
                //0.0325,
                3); *///4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);
            instancedBeddings.place(OPENWORLD.Math.randFloatSpread(15),bedposx, bedposy,
                -0.003 + OPENWORLD.Math.randFloatSpread(0.002) + j * beddist, level:1, scale:THREE.Vector3(0.6 + OPENWORLD.Math.randFloatSpread(0.04),
                    1.0 + OPENWORLD.Math.randFloatSpread(0.04),
                    0.5 + OPENWORLD.Math.randFloatSpread(0.04)));//,5);

           /* pillow2 = pillow.clone();
            pillow2.scale.setValues(0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                0.5 + OPENWORLD.Math.randFloatSpread(0.04));
            OPENWORLD.Space.objTurn(
                pillow2, OPENWORLD.Math.randFloatSpread(15));
            OPENWORLD.Space.worldToLocalSurfaceObjHide(
                pillow2, bedposx - 0.035 + OPENWORLD.Math.randFloatSpread(0.01),
                bedposy + OPENWORLD.Math.randFloatSpread(0.01),level:1,
                0.001 + j * beddist, // 0.0325,
                2); //, level:1);
            _hotload.add(pillow2);*/
            instancedPillows.place(OPENWORLD.Math.randFloatSpread(15),bedposx - 0.035 + OPENWORLD.Math.randFloatSpread(0.01),
                bedposy + OPENWORLD.Math.randFloatSpread(0.01),
                0.001 + j * beddist, level:1, scale:THREE.Vector3(0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                    0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                    0.5 + OPENWORLD.Math.randFloatSpread(0.04)));//,5);


            if ( !priestsarestanding) {
              if (OPENWORLD.Math.random() < 0.3) {
                turn = 90 + OPENWORLD.Math.randFloatSpread(25);
                pitch = 180 + OPENWORLD.Math.randFloatSpread(15);
                roll = OPENWORLD.Math.randFloatSpread(10);
                z = 0.025;
              } else {
                turn = 90 + OPENWORLD.Math.randFloatSpread(25);
                pitch = 0 + OPENWORLD.Math.randFloatSpread(15);
                roll = OPENWORLD.Math.randFloatSpread(10);
                z = -0.01;
              }
            } else {
              z=0.0;
              turn=pitch=roll=0.0;
            }

            z += j * beddist;
         //   print("nammmm"+OPENWORLD.Config.getObjectName( manlist[inc % manlist.length]).toString()+" "+inc.toString());
           // if (inc>=10) {
              OPENWORLD.Config
                  .config['positions']['poolpositions'][1]['positions'].add(
                  { 'name': OPENWORLD.Config.getObjectName( manlist[inc % manlist.length]),
                    'p': [bedposx, bedposy, z],
                    'l': 1,
                    't': turn, 'pitch': pitch,
                    'roll': roll,
                    'action': 'layidle',
                    'label':'sleeping',
                    "lerpopacity": 1,
                    "callbackonvisible":(actor) {
                      OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.2, skipFrames: 8);
                    },
                    "callbackonhide":(actor) {
                      OPENWORLD.Actor.disableDistanceThrottle(actor);
                    }});

            //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);
            //OPENWORLD.Space.objTurn(priest, 180);
          }
          inc++;
        }
      }
    //  print("incccc"+inc.toString()+" "+manlist.length.toString());
      await OPENWORLD.Config.createPoolObjects();//_hotload);


      // Priests laying on the ground in front of the slabs around the fire
      var dooropenereast;
      var dooropenerwest;
      var priestlots=[];
      var priestgrounds=[];
      var priest;
      for (var j = 0; j < 2; j++) {
        var num;
        if (j == 0)
          num = 0;  // stop having those around the mikveh latrine
        else
          num = 7;
        for (var i = 0; i < num; i++) {
          // eastern side of the hearth
          var bedposx = 1.17 - j * 0.11;
          // bedposy = 3.10 - (i * 0.12 + OPENWORLD.Math.random() * 0.025);
          var bedposy = 2.99 + (i * 0.05 + OPENWORLD.Math.random() * 0.02);


          instancedBeddings.place(OPENWORLD.Math.randFloatSpread(15),bedposx, bedposy,
              -0.006 + OPENWORLD.Math.randFloatSpread(0.002), level:1, scale:THREE.Vector3(0.6 + OPENWORLD.Math.randFloatSpread(0.04),
                  1.0 + OPENWORLD.Math.randFloatSpread(0.04),
                  0.5 + OPENWORLD.Math.randFloatSpread(0.04)));//,5);

         /* var pillow2 = pillow.clone();
          pillow2.scale.setValues(0.5 + OPENWORLD.Math.randFloatSpread(0.04),
              0.5 + OPENWORLD.Math.randFloatSpread(0.04),
              0.5 + OPENWORLD.Math.randFloatSpread(0.04));
          OPENWORLD.Space.objTurn(
              pillow2, OPENWORLD.Math.randFloatSpread(15));
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              pillow2, bedposx + 0.035 + OPENWORLD.Math.randFloatSpread(0.01),
              bedposy + OPENWORLD.Math.randFloatSpread(0.01), 0.001,level:1,
              2); //, level:1);
          _hotload.add(pillow2);*/
          instancedPillows.place(OPENWORLD.Math.randFloatSpread(15),
              bedposx + 0.035 + OPENWORLD.Math.randFloatSpread(0.01),
              bedposy + OPENWORLD.Math.randFloatSpread(0.01),
              0.001, level:1, scale:THREE.Vector3(0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                  0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                  0.5 + OPENWORLD.Math.randFloatSpread(0.04)));//,5);

          var z;
          if (gamestart==GameStart.hearth&&j==1&&(i==0||i==4)) {
            priest = await OPENWORLD.Actor.copyActor(
                priestlist[inc % priestlist.length], randomduration: 0.1,
                action: !priestsarestanding?"stoopidle":"idle");
            priest.extra['clothed']=priestlist[inc % priestlist.length].extra['clothed'];
            priestlots.add(priest);
            print("priest hearth inc"+inc.toString());
            setcancollide(priest, true);
            z=0;
            OPENWORLD.Space.objTurn(
                priest, i==0?45:135+OPENWORLD.Math.randFloatSpread(15));
            if (!priestsarestanding) {
              List actions=["stoopidle", "armsup", "hitup", "stoopidle", "kneel"];
              List durations=[10+OPENWORLD.Math.randFloatSpread(2),
                                         5+OPENWORLD.Math.randFloatSpread(1),
                                                   5+OPENWORLD.Math.randFloatSpread(1),
                                                              10+OPENWORLD.Math.randFloatSpread(2),
                                                                        5+OPENWORLD.Math.randFloatSpread(2)];
              var rnd=math.Random(OPENWORLD.Math.randInt(9999));
              actions.shuffle(rnd);
              actions.insert(0,"idle");
              durations.shuffle(rnd);
              durations.insert(0,10);
              OPENWORLD.Actor.playActionsLoop(priest, actions, /*looprepetitionss:[4,4],*/durations: durations,delay:1); //,randomaction:true, delay:2);
            }
          } else if (j == 1 && i == 2) {
            priest = await OPENWORLD.Actor.copyActor(
                manlist[inc % manlist.length], randomduration: 0.1,
                action: !priestsarestanding?"reclineidle":"idle");
            priestgrounds.add(priest);
            setcancollide(priest, true);
             if ( !priestsarestanding) {
               OPENWORLD.Space.setTurnPitchRoll(
                   priest, -90 + OPENWORLD.Math.randFloatSpread(15),
                   0 + OPENWORLD.Math.randFloatSpread(15), 0);
             }
            z = -0.01;
            OPENWORLD.BaseObject.setVisible(
                priest, false, groupname: getShoesGroup(manlist[inc % manlist.length]));//"citizen_2"); // remove shoes
          } else {
            var rnd = OPENWORLD.Math.random();
            var action;
            if (!priestsarestanding) {
              if (rnd < 0.4)
                action = "laysideidle";
              else
                action = "layidle";
            } else
              action="idle";
            priest = await OPENWORLD.Actor.copyActor(
                manlist[inc % manlist.length], randomduration: 0.1,
                action: action); // "layidle");
            setcancollide(priest, true);
            priestgrounds.add(priest);
            if (gamestart==GameStart.hearth&&j==1&&i==6)
              dooropenereast=priest;
            if ( !priestsarestanding) {
              if (rnd > 0.9) {
                // Some lay on their face
                OPENWORLD.Space.setTurnPitchRoll(
                    priest, -90 + OPENWORLD.Math.randFloatSpread(15),
                    180 + OPENWORLD.Math.randFloatSpread(15), 0);
                z = 0.0;//25;
              } else {
                OPENWORLD.Space.setTurnPitchRoll(
                    priest, -90 + OPENWORLD.Math.randFloatSpread(15),
                    0 + OPENWORLD.Math.randFloatSpread(15), 0);
                z = -0.01;
              }
            } else
              z=0.0;

            OPENWORLD.BaseObject.setVisible(
                priest, false, groupname: getShoesGroup(manlist[inc % manlist.length]));//"citizen_2"); // remove shoes
          }


          _hotload.add(priest);
       //   print("priest z east"+z.toString());
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              priest, bedposx, bedposy, z,level:1,
              3); //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);


          // Western side of the hearth
          inc++; // so that dont have the same actor mirrored on the opposite side
          bedposx = 0.8 - 0.14 + j * 0.11;
          // bedposy = 3.10 - (i * 0.12 + OPENWORLD.Math.random() * 0.025);
          bedposy = 2.99 + (i * 0.05 + OPENWORLD.Math.random() * 0.02);

        /*  bedding2 = bedding.clone();
          OPENWORLD.Space.objTurn(
              bedding2, OPENWORLD.Math.randFloatSpread(15));
          bedding2.scale.setValues(0.6 + OPENWORLD.Math.randFloatSpread(0.04),
              1.0 + OPENWORLD.Math.randFloatSpread(0.04),
              0.5 + OPENWORLD.Math.randFloatSpread(0.04));
          _hotload.add(bedding2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              bedding2, bedposx, bedposy,
              -0.006 + OPENWORLD.Math.randFloatSpread(0.002),level:1,
              3);*/ //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);
          instancedBeddings.place(OPENWORLD.Math.randFloatSpread(15),bedposx, bedposy,
              -0.006 + OPENWORLD.Math.randFloatSpread(0.002), level:1, scale:THREE.Vector3(0.6 + OPENWORLD.Math.randFloatSpread(0.04),
                  1.0 + OPENWORLD.Math.randFloatSpread(0.04),
                  0.5 + OPENWORLD.Math.randFloatSpread(0.04)));//,5);

        /*  pillow2 = pillow.clone();
          pillow2.scale.setValues(0.5 + OPENWORLD.Math.randFloatSpread(0.04),
              0.5 + OPENWORLD.Math.randFloatSpread(0.04),
              0.5 + OPENWORLD.Math.randFloatSpread(0.04));
          OPENWORLD.Space.objTurn(
              pillow2, OPENWORLD.Math.randFloatSpread(15));
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              pillow2, bedposx - 0.035 + OPENWORLD.Math.randFloatSpread(0.01),
              bedposy + OPENWORLD.Math.randFloatSpread(0.01), 0.001,level:1,
              2); //, level:1);
          _hotload.add(pillow2);*/
          instancedPillows.place(OPENWORLD.Math.randFloatSpread(15),
              bedposx - 0.035 + OPENWORLD.Math.randFloatSpread(0.01),
              bedposy + OPENWORLD.Math.randFloatSpread(0.01),
              0.001, level:1, scale:THREE.Vector3(0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                  0.5 + OPENWORLD.Math.randFloatSpread(0.04),
                  0.5 + OPENWORLD.Math.randFloatSpread(0.04)));//,5);


          if (!(j==1&&i==0)) { // Leave this spot empty for yourself
            if (gamestart == GameStart.hearth && j == 1 && (i == 0 || i == 4)) {
              priest = await OPENWORLD.Actor.copyActor(priestlist[inc % priestlist.length], randomduration: 0.1,
                  action: !priestsarestanding?"stoopidle":"idle");
              priest.extra['clothed']=priestlist[inc % priestlist.length].extra['clothed'];
              priestlots.add(priest);
              print("priest hearth inc"+inc.toString());
              setcancollide(priest, true);
              z = 0;
              OPENWORLD.Space.objTurn(
                  priest,
                  i == 0 ? 45 : 270 + OPENWORLD.Math.randFloatSpread(15));
              if (!priestsarestanding) {
                List actions=["stoopidle", "armsup", "hitup", "stoopidle", "kneel"];
                List durations=[10+OPENWORLD.Math.randFloatSpread(2),
                  5+OPENWORLD.Math.randFloatSpread(1),
                  5+OPENWORLD.Math.randFloatSpread(1),
                  10+OPENWORLD.Math.randFloatSpread(2),
                  5+OPENWORLD.Math.randFloatSpread(2)];
                var rnd=math.Random(OPENWORLD.Math.randInt(9999));
                actions.shuffle(rnd);
                actions.insert(0,"idle");
                durations.shuffle(rnd);
                durations.insert(0,10);
                OPENWORLD.Actor.playActionsLoop(
                    priest, actions,//["stoopidle", "armsup", "hitup", "stoopidle","kneel","idle"],
                   durations:durations, delay:1// [10, 5, 5, 10, 5, 10],
                   // randomaction: true
                );
              }
            } else {
              if (j == 1 && i == 1) {
                while (!manlist[inc % manlist.length].extra.containsKey('robes'))
                  inc++;  // fudge so your friend is a priest who is wearing normal clothes
                priest = await OPENWORLD.Actor.copyActor(
                    manlist[inc % manlist.length], randomduration: 0.1,
                    action: !priestsarestanding?"reclineidle":"idle");
              //  priestgrounds.add(priest);
                setcancollide(priest, true);
                if ( !priestsarestanding) {
                  OPENWORLD.Space.setTurnPitchRoll(
                      priest, 90 + OPENWORLD.Math.randFloatSpread(15),
                      0 + OPENWORLD.Math.randFloatSpread(15), 0);
                  z = -0.01;
                }
                friendhearth = priest;
                friendhearth.extra['robes']= manlist[inc % manlist.length].extra['robes'];
                OPENWORLD.Mob.setName(friendhearth,'friendhearth');
                //priestlots.add(priest);
              } else {
                var rnd = OPENWORLD.Math.random();
                var action;
                if (!priestsarestanding) {
                  if (rnd < 0.4)
                    action = "laysideidle";
                  else
                    action = "layidle";
                } else
                  action="idle";
                priest = await OPENWORLD.Actor.copyActor(
                    manlist[inc % manlist.length], randomduration: 0.1,
                    action: action);
                priestgrounds.add(priest);
                // setcancollide(priest,true);
                if (gamestart==GameStart.hearth&&j==1&&i==6)
                  dooropenerwest=priest;

                if ( !priestsarestanding) {
                  if (rnd > 0.9) {
                    // Some lay on their face
                    OPENWORLD.Space.setTurnPitchRoll(
                        priest, 90 + OPENWORLD.Math.randFloatSpread(15),
                        180 + OPENWORLD.Math.randFloatSpread(15), 0);
                    z = 0.0;//25;
                  } else {
                    OPENWORLD.Space.setTurnPitchRoll(
                        priest, 90 + OPENWORLD.Math.randFloatSpread(15),
                        0 + OPENWORLD.Math.randFloatSpread(15), 0);
                    z = -0.01;
                  }
                } else
                  z=0.0;
              }
              // If you step on priests laying on the ground then they get up and say something
              if (priest != friendhearth)
                priest.extra['hittrigger'] = (actor) {
                  print("hit priest");
                  actor.extra.remove('hittrigger');
                  var position = OPENWORLD.Space.localToWorldObj(actor);
                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                      actor, position.x, position.y + 0.001, 0, 1.0, level: 1);
                  //   OPENWORLD.Space.setTurnPitchRoll(
                  //       actor, 0, 0 , 0);
                  OPENWORLD.Actor.playActionThen(
                      actor, "kneel", "idle");
                  OPENWORLD.Actor.playAction(
                      actor, action: "squatwork", delay: 10);


                  actor.rotation.x = 0.0;
                  actor.rotation.y = 0.0;
                  actor.rotation.z = 0.0;
                  OPENWORLD.Space.faceObjectLerp(actor, threeJs.camera, 1);
                  OPENWORLD.Space.faceObjectLerp( actor, threeJs.camera, 1, delay: 2);
                  //  OPENWORLD.Space.faceObjectLerp(actor, threeJs.camera, 1, delay:4);
                  if (OPENWORLD.Math.random() < 0.5)
                    OPENWORLD.Mob.setSpeech(actor, [
                      OPENWORLD.Math.randPick(
                          ["Shalom!", "Hey!", "Watch it", "Watch it, clumsy"])
                    ], z: 90,
                        width: 300,
                        scale: 0.4,
                        randwait: 0,
                        clearwhendone: true,
                        delay: 1);

                  if (OPENWORLD.Math.random() < 0.2)
                    OPENWORLD.Actor.playActionThen(
                        actor, "push", "idle3", delay: 3);
                };
              OPENWORLD.BaseObject.setVisible(
                  priest, false, groupname: getShoesGroup(
                  manlist[inc % manlist.length])); //"citizen_2"); // remove shoes
            }
            _hotload.add(priest);
            OPENWORLD.Space.worldToLocalSurfaceObjHide(
                priest, bedposx, bedposy, z, level: 1,
                3); //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);
          }
          inc++;
        }
      }




      if (gamestart==GameStart.hearth) {
        // Is your friend close by. If not then let the player leave
        friendisclose()
        {
          return OPENWORLD.You.getObjDistance(friendhearth)<0.5;
        }

        // Called when a player first moves - otherwise just stay laying in the hearth
        runhearth() async{
          //OPENWORLD.Space.resetPosRot(friendhearth);

          // This is the position of the priests casting lots in the chamber of the hearth
          var poslots = [
            [0.91, 2.3], // top
            [0.86, 2.3], // top right
            [0.86, 2.37], // right
            [0.86, 2.41], // bottom right
            [0.97, 2.41], // bottom left
            [0.97, 2.37], // left
            [0.97, 2.3], //  top left
            [0.91, 2.41], // bottom
          ];
          var superintendent = await OPENWORLD.Actor.copyActor(manlist[0], randomduration: 0.2, action: "idlehold");
          var lampbronzewield = lampbronze.clone();
          var lightlampwield = new THREE.PointLight(
              0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

          lightlampwield.intensity = 0.08; // 0.6;
          lightlampwield.distance = 0.6; //1.2;
          lightlampwield.position.y = 1.0; // up
          lightlampwield.position.z = 1.0; // forward
          //var sphereAxis = new AxesHelper(2000);
          //lightlampwield.add(sphereAxis );

          OPENWORLD.Light.addFlicker(lightlampwield);
          lampbronzewield.add(lightlampwield);
          lampbronzewield.scale.setValues(5.0, 5.0, 5.0);
          lampbronzewield.position.z=-2.0;
          OPENWORLD.Space.setTurnPitchRoll(lampbronzewield, 90, -90, 0);
          OPENWORLD.Actor.wield(
              superintendent, lampbronzewield, "Bip01_R_Hand");

          var ashposx = 4.53;
          var ashposy = Glob.firepanposy;

          var tools=Glob.tools!();  // Create tools that are next to the altar
          Glob.tamiditems!();  // tamid items like libation bowl

          var superlotteryx = 0.91; // position of the superintendant when he's doing the lottery
          var superlotteryy = 2.37;
          var priestkeyfinalposx = 0.73;  // where priestkey ends up after getting up off the slap and to the west
          var priestkeyfinalposy = 2.49;
          var playerlotterystartposx = 0.78;  // where you stand when the first lottery start
          var playerlotterystartposy = 2.56;

          //positions of priests on ground where they walk up to watch the lottery
          var posgrounds = [
            [1.08, 2.31],
            [0.72, 2.27+0.04],
            [0.8, 2.24],
            [1.0, 2.24],
            [1.1, 2.33],
            [1.02, 2.4],
            [1.08, 2.51],
            [0.72, 2.5],
            // [0.72+0.1,2.5],
            [0.86 + 0.1, 2.51],
          ];

          // Get all the sleeping priests and put the on the ground
          priestsleepstoground() async {
            var positions=OPENWORLD.Config.getPositionsByLabel(OPENWORLD.Config.config['positions']['poolpositions'][1]['positions'],'sleeping');
            for (var position in positions) {
              var newposx;
              if (position['p'][0]<0.93)
                newposx = 0.65;
              else
                newposx = 1.15;
              position['p'][0]=newposx + OPENWORLD.Math.randFloatSpread(0.15);
              position['p'][1]+= OPENWORLD.Math.randFloatSpread(0.1);
              position['p'][2]=0.0;
              var rnd = OPENWORLD.Math.random();
              position['action']=rnd<0.3?"squat":rnd<0.6?"stoopidle":"idle3";
              position['t']=OPENWORLD.Math.random() * 360;
            }
            await OPENWORLD.Config.updatePoolObjects();
          }

          // priestly robes onto your friend
          friendcloth() {
            var mat1 = OPENWORLD.Texture.getMaterialByGroupname(
                friendhearth.extra['robes'], "citizen_2");
            var mat2 = OPENWORLD.Texture.getMaterialByGroupname(
                friendhearth.extra['robes'], "citizen_1");
            friendhearth.extra['hair'] =
                OPENWORLD.Texture.getMaterialByGroupname(
                    friendhearth, "citizen_3");
            var mathead = OPENWORLD.Texture.getMaterialByGroupname(
                friendhearth.extra['robes'], "citizen_3");
            OPENWORLD.Texture.setMaterial(
                friendhearth, mat1, groupname: "citizen_2");
            OPENWORLD.Texture.setMaterial(
                friendhearth, mat2, groupname: "citizen_1");
            OPENWORLD.Texture.setMaterial(
                friendhearth, mathead, groupname: "citizen_3");
          }

          // 5 priests in priest lots - i think initially they were the ones in the mikveh who leave and put their clothes
          // this replicates these 5 when restart the hearth journey
          dresspriests() async {
            // print("dresspriests");
            for (var i = 0; i < 5; i++) {
              // print("dresspriestsu"+i.toString());
              if (i < 4) {
                priest = await OPENWORLD.Actor.copyActor(
                  //      priestlist[i % priestlist.length], randomduration: 0.2);
                    priestlist[(i + 1) % priestlist.length].extra['clothed'],
                    randomduration: 0.2);
                priest.extra['robes'] = priestlist[(i + 1) % priestlist.length];
                priest.extra['clothed']= priestlist[(i + 1) % priestlist.length].extra['clothed'];

              } else {
                print('added friend to lots');
                priest = friendhearth;
              }
              _hotload.add(priest);

              priestlots.add(priest);
              //    print("priestlotsin"+priestlots.length.toString()+" i"+i.toString());

              if (i < 4) {
                // Put your robes on but not for friendhearth
                var mat1 = OPENWORLD.Texture.getMaterialByGroupname(
                    priest.extra['robes'], "citizen_2");
                var mat2 = OPENWORLD.Texture.getMaterialByGroupname(
                    priest.extra['robes'], "citizen_1");
                var mathead = OPENWORLD.Texture.getMaterialByGroupname(
                    priest.extra['robes'], "citizen_3");
                OPENWORLD.Texture.setMaterial(
                    priest, mat1, groupname: "citizen_2");
                OPENWORLD.Texture.setMaterial(
                    priest, mat2, groupname: "citizen_1");
                OPENWORLD.Texture.setMaterial(
                    priest, mathead, groupname: "citizen_3");
              }
            }
          }

          // Recreate priests moved from sleeping to the lottery if restart the hearth journey
          priestgroundstolottery() {
            for (var i = 0; i < priestgrounds.length; i++) {
              var priestground = priestgrounds[i];
              OPENWORLD.Space.resetRot(priestground);
              OPENWORLD.Space.setZ(priestground, 0, level: 1);
              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(priestground);
              OPENWORLD.Space.worldToLocalSurfaceObjHide(
                  priestground, posgrounds[i][0], posgrounds[i][1], 0, level: 1,
                  2); //, level:1);
              // OPENWORLD.Space.faceObjectLerp(priestground,superintendent,1,delay:1);

              OPENWORLD.Space.faceObject(priestground, superintendent);
              //  OPENWORLD.Space.faceObjectAlways(priestground,superintendent);//,superintendent,1);
              OPENWORLD.Actor.playAction(priestground, action: "idle");
            }
          }

          // Position of the hearth doorway
          var doorposx = 0.88 + 0.005;
          var doorposy = 2.17;

          // When leave hearth this is position of the western group including you and friend outside - final position of friendhearth
          var securitywestposx = 0.75;
          var securitywestposy = 1.51;

          // This is the other eastern group
          var securityeastposx = 1.47;
          var securityeastposy = 1.66;

          var securitylist = [];

          var mysecuritystartposx = 0.66;  // place where you stand when start the security
          var mysecuritystartposy = 1.51;
          var meetupposx = 5.15;  // meetup chitveh when finish security
          var meetupposy = -0.81; //-0.55;
          var opendoorsstartposx = meetupposx - 0.1;
          var opendoorsstartposy = meetupposy - 0.2;

          var sheepslaughter;
          var priestgetlamb;
          var sheepfinalposx=4.04;  // Think this is the position where slaughter the lamb on the pillars
          var sheepfinalposy=1.10+0.02;
          var slaughterviewangle=337;  // Angle you view the slaugher
          var friendhearthaltarposx=3.98;  // place your friend stands at corner of altar during lambslaughte
          var friendhearthaltarposy=0.51;
          var priesttamidneeded=6;   // How many priests should line up at the altar for the slaughter
          var sixpriests=[];  // These are the 9 priests that make up the tamid
          var threepriests=[];

          // Positions of priests on the altar during terumut
          var priestaltarposs = [
            [4.40, -0.22],
            [4.18, -0.18],
            [4.10, 0.03],
            [4.28, -0.18],
            [4.44, -0.17],
            [4.57, 0.16,],
            [4.17, -0.29],
          ];

          // Position of the superintedent in the chamber the hewnstone doing the lottery
          var hewnstonelotposx = 4.90;
          var hewnstonelotposy = -1.64;

          // Relative positions of priests doing the lottery in the chamber of the hewnstone
          var poshewstonelotsdiff = [
            [0, 1], //1
            [-1, 1],
            [-1, 0],
            [-1, -1],
            [0, -1],
            [1, -1],
            [1, 0],
            [1, 1],  //8
            [0.5,1],
            [-1,0.5],
            [-1,-0.5],
            [-0.5,-1],
            [0.5,-1], //13
            []
          ];


          // this is a bit like createcrowdpoints where try not to create overlaps
          // used for security priests
          nextdonthit(prevlist, x, randspreadx, y, randspready, distcutoff) {
            var tryagain = false; // Check doesn't land on yourself
            var diffx = 0.0;
            var diffy = 0.0;
            do {
              // Put a box around your friend so you dont have priests over lapping
              diffx = OPENWORLD.Math.randFloatSpread(randspreadx);
              diffy = OPENWORLD.Math.randFloatSpread(randspready);

              tryagain = false;
              for (var j = 0; j < prevlist.length; j++) {
                var dist = OPENWORLD.Math.vectorDistance(THREE.Vector3(
                    x + diffx, y + diffy, 0),
                    THREE.Vector3(prevlist[j][0], prevlist[j][1], 0));
                if (dist < distcutoff) {
                  //print("try again");
                  tryagain = true;
                }
              }
              //  print("vooooot"+i.toString());
            } while (tryagain);
            return [x + diffx, y + diffy];
          }

          // This places the security groups outside the hearth in the security area
          setsecurityfinalpos(securitylist) {
            var finalposs = [];
            // Create a path from door to friend hearth so don't collide with everyone
            var gappoints = OPENWORLD.Math.interpolateByIncrement(
                [[doorposx,doorposy],[securitywestposx,securitywestposy]], 0.1);
            for (var i = 0; i < securitylist.length; i++) {
              var finalpos;
              if (i % 2 == 0) {
                // You are creating the prevlist every time
                var prevlist = [];
                prevlist.add([securitywestposx, securitywestposy]);
                prevlist.add([mysecuritystartposx, mysecuritystartposy]);
                for (var pos in gappoints)
                  prevlist.add([pos[0],pos[1]]);
                for (var pos in finalposs)
                  prevlist.add([pos[0], pos[1]]);
                var nextpos = nextdonthit(
                    prevlist, securitywestposx, 0.3, securitywestposy + 0.07,
                    0.3, 0.05);
                finalpos = [ // west group
                  nextpos[0],

                  /// securitywestposx + diffx ,
                  nextpos[1], // securitywestposy +diffy,
                  0,
                  0.02
                ];
              } else

                finalpos = [ // east group
                  securityeastposx + OPENWORLD.Math.randFloatSpread(0.3),
                  securityeastposy + OPENWORLD.Math.randFloatSpread(0.3),
                  0,
                  0.02
                ];
              finalposs.add(finalpos);
            }
            return finalposs;
          }

          // This creates the movetoloop actions for a lottery in the hewnstone for the superintendant- is used for 3 lottery
          // Probably should use it for the lottry in the chamber of the hearth also
          // actions is any existing actions want to add to,
          // startangle is the initial angle of the superintendant, who he asks to to take off turban
          // finalangle is the angle of the final winning priest
          lotteryactions(actions,startangle, startpriest,finalangle,priestwinner,{exclude})
          {
            var idleholdduration=5;
            var timespread = 0.5;
            var anglespread = 45.0; // Dont want the superintendant rotating too smoothly
            actions.add({"action":"idlehold","duration":idleholdduration,"time":10,"t":0});
            actions.add({"action":"idlehold","duration":idleholdduration,"time":10,"t":270});
            actions.add({"action":"idlehold","duration":idleholdduration,"time":10,"t":startangle,"callback":(actor){
              for (var priest in priestlots) {
                if (priest!=superintendent&&(exclude==null||(exclude!=null&&!exclude.contains(priest))))
                  OPENWORLD.Actor.playAction(
                      priest, action: "idlehold",
                      duration:idleholdduration,
                      randomduration: 0.1, delay:1+OPENWORLD.Math.random()*3);


              }
              if (exclude==null||(exclude!=null&&!exclude.contains(friendhearth)))
                OPENWORLD.Actor.playAction(
                    friendhearth, action: "idlehold",
                    randomduration: 0.1,duration:idleholdduration, delay:2+OPENWORLD.Math.random()*3);

              /* OPENWORLD.Actor.playAction(
                  startpriest, action: "starjump",
                  duration:idleholdduration,
                  randomduration: 0.1, delay:4+OPENWORLD.Math.random()*3);*/

              OPENWORLD.Mob.setSpeech(superintendent, [
                "Extend a finger.",
                "I'll start with you.",
                "Take off your turban"
              ], z: 80,
                  width: 300,
                  scale: 0.2,
                  randwait: 0,
                  clearwhendone: true,
                  callbackonfinish: (actor) async {
                    // Friend takes his\ turban off
                    OPENWORLD.Actor.playActionThen(
                        startpriest, "armsup", "idlehold",
                        randomdurationthen: 0.1,durationthen:idleholdduration);
                    startpriest.extra['turban'] = OPENWORLD.Texture.getMaterialByGroupname(startpriest, "citizen_3");
                    var clothed= OPENWORLD.Texture.getMaterialByGroupname(startpriest.extra['clothed'],"citizen_3");
                    OPENWORLD.Texture.setMaterial(startpriest, clothed,groupname: "citizen_3");
                    // Hold turban in hands

                    OPENWORLD.Actor.wield(
                        startpriest, turbanwield.clone(), "Bip01_R_Hand", delay: 1);
                  }
              );

            }
            });
            actions.add({"time":20});
            actions.add({"action":"walkhandrightpoint","duration":1.5,"time":2});  // was 5
            //  actions.add({"time":1+OPENWORLD.Math.randFloatSpread(timespread),"t":180+OPENWORLD.Math.randFloatSpread(anglespread)});
            //   actions.add({"time":1+OPENWORLD.Math.randFloatSpread(timespread),"t":270+OPENWORLD.Math.randFloatSpread(anglespread)});
            //   actions.add({"time":1+OPENWORLD.Math.randFloatSpread(timespread),"t":0+OPENWORLD.Math.randFloatSpread(anglespread)});
            var finished=false;
            for (var i=0; i<4; i++) {
              for (var j=0; j<8; j++) {
                if (!finished) {
                  actions.add({ "time": 1 + OPENWORLD.Math.randFloatSpread(timespread), "t": startangle + j * 45 + OPENWORLD.Math.randFloatSpread(anglespread) });
                  finished = (i == 3 && (startangle + j * 45) == finalangle);
                }
              }

            }
            actions[actions.length-1]['callback']=(actor){
              // Where they finish the lottery
              OPENWORLD.Mob.setSpeech(superintendent, ["You!"], z: 90,
                  width: 300,
                  scale: 0.4,
                  randwait: 0,
                  clearwhendone: true,
                  delay: 1);
              OPENWORLD.Actor.playActionThen(
                superintendent, "idleholdpoint", "idlehold",
                duration: 2,
                durationthen:idleholdduration,
              );

              //  OPENWORLD.Actor.playAction(
              //     friendhearth, action:"lookdown", randomduration: 0.1, delay: 2 + 3 * OPENWORLD.Math.random());

              if (exclude==null||(exclude!=null&&!exclude.contains(friendhearth)))
                OPENWORLD.Actor.playActionThen(friendhearth, priestwinner==friendhearth?"lookup":"lookdown", "idle", duration:1,  delay: 2 + 3 * OPENWORLD.Math.random());
              for (var priestlot in priestlots) {
                if (priestlot!=superintendent&&(exclude==null||(exclude!=null&&!exclude.contains(priestlot)))) {
                  OPENWORLD.Space.removeFaceObjectAlways(priestlot);
                  OPENWORLD.Actor.playAction(
                      priestlot, action: priestlot != priestwinner
                      ? "lookdown"
                      : "lookup",
                      randomduration: 0.1,
                      delay: 2 + 3 * OPENWORLD.Math.random());
                  var priestpos = OPENWORLD.Space.localToWorldObj(
                      priestlot);
                  var newpos = OPENWORLD.Math.vectorMoveForward(
                      priestpos.x, priestpos.y,
                      OPENWORLD.Space.getObjTurn(priestlot) - 180, 0.08);
                  if (newpos.y > -1.58) // So doesn't stick in the wall
                    newpos.y = -1.58;
                  OPENWORLD.Mob.moveTo(
                      priestlot,
                      [
                        [newpos.x, newpos.y, 0, 0.01]
                      ], action: "walk",
                      stopaction: "idle",
                      surfaceonly: true,
                      level: 1,
                      callbackonfinish: (actor) {
                        OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1.0);
                        if (actor==startpriest) {
                          // First priest puts his turban back on
                          OPENWORLD.Actor.playActionThen(
                              startpriest,  "armsup",duration:0.5, "idlestraight",
                              delay:4);
                          OPENWORLD.Actor.unwield(
                              actor, "Bip01_R_Hand", delay: 5);
                          Future.delayed(Duration(milliseconds: 5000), () async {
                            OPENWORLD.Texture.setMaterial(actor, actor.extra['turban'],
                                groupname: "citizen_3");
                          });
                        }
                      },
                      delay: 8 + 6 * OPENWORLD.Math.random()
                  );
                }
              }

            };
            // print("actions"+actions.toString());
            return actions;
          }

          // When restart game general purpose door open - opens all the doors
          doorssetopen()
          {
            Glob.grouplamphewnstoneeast.visible = true;
            Glob.grouplamphewnstonewest.visible = true;
            Glob.doorwaynicanoreastgatesouth.setOpenClose(true);
            Glob.doorwaynicanoreastgatenorth.setOpenClose(true);
            for (var doorway in doorways)
              doorway.setOpenClose(true);

            Glob.doorwayhewnstone.setOpenClose(true);
          //  OPENWORLD.Space.objTurn(Glob.doornicanornorth, 90);
          //  OPENWORLD.Space.objTurn(Glob.doornicanorsouth, 90);
            Glob.doorwaynicanor.setOpenClose(true);

          }

          // when restart the game dress the priests, create the priests and set the security priests
          general() async {
            await dresspriests();
            //  print("priestlotsb len"+priestlots.length.toString());

            priestlots.remove(
                friendhearth); // Only put him in so can clothe him properly and is in correct position
            _hotload.add(superintendent);

            for (var i = 0; i < priestlots.length; i++) {
              var priestlot = priestlots[i];
              // if (priestlot==friendhearth)
              //   print("found friend"+i.toString());
              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(priestlot);
            }


          //  OPENWORLD.Space.objTurn(doorgold, 180);
            doorwaysouthhearth.setOpenClose(true);
            priestgroundstolottery();
            priestsleepstoground();
            friendcloth();
            OPENWORLD.Space.resetRot(friendhearth);
            OPENWORLD.Space.setZ(friendhearth, 0, level: 1);

            securitylist.clear();
            // securitylist.addAll(priestlots);
            securitylist.addAll(priestgrounds);
            for (var i = 0; i < 10; i++)
              securitylist.add(priestsextra[i]);
            //securitylist.shuffle();

            for (var securitypriest in securitylist) {
              securitypriest.extra.remove('hittrigger');
              OPENWORLD.Space.setObjHideDist(securitypriest, 4);
            }
            securitylist.shuffle();
            securitylist.insert(0, superintendent);

            // var finalposs=setsecurityfinalpos(securitylist);
            for (var i = 0; i < securitylist.length; i++) {
              var securitypriest = securitylist[i];
              OPENWORLD.BaseObject.removeDistanceTrigger(securitypriest);
              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(securitypriest);
            }

          }

          // Similar to general2 but a bit further along up lamb slaughter reset
          general2() async {
            OPENWORLD.Space.removeFaceObjectAlways(superintendent);
            OPENWORLD.Space.worldToLocalSurfaceObjHide(
                superintendent, meetupposx, meetupposy, 0, 1,
                level: 1);
            OPENWORLD.Space.objTurn(
                superintendent,270);
            OPENWORLD.Actor.playAction(
                superintendent, action: "idlehold",
                randomduration: 0.1);
            OPENWORLD.Actor.unwield(
                superintendent, "Bip01_R_Hand");

            // Need a few more priests - put them in the chamber of the hewn stone
            for (var i = 0; i < 4; i++) {
              var pickedpriest=OPENWORLD.Math.randPick(priestlist);
              var priest = await OPENWORLD.Actor.copyActor(pickedpriest,
                  randomduration: 0.1);
              priest.extra['clothed']=pickedpriest.extra['clothed'];
              _hotload.add(priest);
              // OPENWORLD.Space.worldToLocalSurfaceObjHide(
              //     priest, 4.9-OPENWORLD.Math.random()*0.2,-1.6+OPENWORLD.Math.randFloatSpread(0.4), 0, level: 1, 4);
//                  priest, 3.89+OPENWORLD.Math.randFloatSpread(0.4),-1.24+OPENWORLD.Math.randFloatSpread(0.4), 0, level: 1, 4);
              priestlots.add(priest);
            }



            var prevlist = [];
            var meetuposs = [];
            //   prevlist.add([meetupposx, meetupposy,0,0.02]);
            // prevlist.add([startterumatposx,startterumatposy,0,0.02]);
            for (var i = 0; i < securitylist.length; i++) {
              var nextpos = nextdonthit(
                  prevlist, meetupposx, 0.2, meetupposy, 0.4, 0.05);
              meetuposs.add([nextpos[0], nextpos[1], 0, 0.02]);
              prevlist.add(nextpos);
            }

            // Place the priests outside the chitveh
            for (var i = 10; i < securitylist.length; i++) {
              var securitypriest = securitylist[i];
              if (securitypriest!=superintendent) {
                OPENWORLD.Actor.playAction(
                    securitypriest, action: "idle3", randomduration: 0.1);
                if (securitypriest != friendhearth) {
                  OPENWORLD.Space.worldToLocalSurfaceObj(
                      securitypriest, meetuposs[i][0], meetuposs[i][1], 0,
                      level: 1); //meetupposx+diffx,meetupposy-diffy-0.1, 0,  level: 1);//,5);


                  OPENWORLD.Space.faceObject(securitypriest, superintendent);
                }
              }
            }

            for (var i=0; i<10; i++) {
              var securitypriest = securitylist[i];
              if (securitypriest!=superintendent) {
                var westside = OPENWORLD.Math.random() < 0.5;
                var finalpos = [];
                if (westside) {
                  finalpos = [
                    4.58 + OPENWORLD.Math.random() * 0.1,
                    -1.64 + OPENWORLD.Math.randFloatSpread(0.2)]; // west side
                  OPENWORLD.Space.objTurn(securitypriest,90);
                } else {
                  finalpos = [
                    5.32 - OPENWORLD.Math.random() * 0.1,
                    -1.64 + OPENWORLD.Math.randFloatSpread(0.2)]; // eastside
                  OPENWORLD.Space.objTurn(securitypriest,270);

                }
                OPENWORLD.Space.worldToLocalSurfaceObjHide(
                    securitypriest, finalpos[0], finalpos[1], 0,
                    level: 1,4); //meetupposx+diffx,meetupposy-diffy-0.1, 0,  level: 1);//,5)

                // OPENWORLD.Space.faceObject(securitypriest, superintendent);
              }

            }
          }

          // This is the start of the horrible huge nesting of each part of the chamber the hearth journey is nested

          // Do the tamid final
          tamidfinal()
          {
            saveGameState('ketoret');
            OPENWORLD.Config.updatePoolObjects();
            OPENWORLD.Time.setTimeLerp(8.5, 60,onlyifover: true);
            friendhearth.extra['followhearth'] = true;

            for (var priest in priestlots)
              OPENWORLD.Actor.unwield(priest, "Bip01_R_Hand");  // make sure no priest are wielding anything

            // get the 9 priests who will get the meat off the ramp
            var hewnstonpriestlist=[];
            for (var i=0; i<9; i++) {
              // Guarantee correct priestnum and threepriest
              if (i<6) {
                priestlots[i].extra['priestnum'] = i;
                priestlots[i].extra.remove('threepriest');
              } else {
                priestlots[i].extra['priestnum'] = i-6;
                priestlots[i].extra['threepriest']=true;
              }
              hewnstonpriestlist.add(priestlots[i]);
            }

            // Start the general tamid final in hotloadsecondtemple
            Glob.tamidfinal!(hewnstonpriestlist,callbackonfinish:(){
              // Have you and your friend and priests and security priests prostrate themselves when tamid final happens
            OPENWORLD.Actor.playActionThen(
                  friendhearth, "kneel", "prostrate", duration:3 ,delay:OPENWORLD.Math.random()*2 );
              OPENWORLD.Camera.cameraoffset=Glob.defaultcameraoffset*0.75;
            if (friendisclose())
              OPENWORLD.Space.setZ(
                  threeJs.camera,
                  OPENWORLD.Camera.cameraoffset*0.75, level: 1,delay:1);
            if (friendisclose())
            OPENWORLD.Space.objTurnLerp(threeJs.camera, 306,1,delay:1);
//              OPENWORLD.Space.objTurnLerp(threeJs.camera, 280,1,delay:1);
              Future.delayed(Duration(milliseconds: 10000), () async {
                OPENWORLD.Camera.cameraoffset=Glob.defaultcameraoffset;
              });

            //  for (var i = 10; i < securitylist.length; i++) {
              for (var i = 0; i < securitylist.length; i++) {
                var securitypriest = securitylist[i];
                OPENWORLD.Space.objTurnLerp(securitypriest,270+45,1);
                OPENWORLD.Actor.playActionThen(
                    securitypriest, "kneel", "prostrate", duration:3 ,delay:OPENWORLD.Math.random()*2 );
              }
              for (var i = 9; i < priestlots.length; i++) {
                var priest = priestlots[i];
                OPENWORLD.Space.objTurnLerp(priest,270+45,1);
                OPENWORLD.Actor.playActionThen(
                    priest, "kneel", "prostrate", duration:3 ,delay:OPENWORLD.Math.random()*2 );
              }
            });
            OPENWORLD.Mob.placeBeforeCamera(
                friendhearth, 0.08, offset: 0,//-0.03,
                time: 5,
                action: "walkhandright",
                stopaction: "idle",
                callbackonfinish: (actor) {
                  OPENWORLD.Mob.setSpeech(friendhearth, [
                    "This is the final part",
                    "of the tamid.",
                    "The pieces of the lamb",
                    "are placed in the altar",
                    "and then finally the wine",
                    "libation and trumpeting.",
                    "Lets go watch it",
                  ], z: 80,
                      width: 300,
                      scale: 0.2,
                      randwait: 0,
                      clearwhendone: true,
                      callbackonfinish: (actor) {
                        //  OPENWORLD.Space.faceObjectAlways(
                        //      friendhearth, winningpriest);
                        OPENWORLD.Mob.moveTo(
                            friendhearth,
                            [
                              [4.91+0.03, -1.5, 0, 0.02],
                              [5.03+0.03, -1.28+0.04, 0, 0.02],
                            ],
                            level: 1,
                            action: "walkstraight",
                            stopaction: "idlestraight",
                            actionrandomduration: 0.1,
                            callbackonfinish: (actor){
                              OPENWORLD.Space.objTurnLerp(actor, 270,1);
                              if (friendisclose())
                                OPENWORLD.Space.objTurnLerp(threeJs.camera, 326,1, delay:1);
                              if (friendisclose())
                                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                  threeJs.camera, 5.04+0.03, -1.29,// 5.03, -1.28,
                                  OPENWORLD.Camera.cameraoffset,1, level: 1,delay:1);

                            },
                            surfaceonly: true);

                      }
                  );
                },
                delay: 30);
          }

          // Allow restart game starting the tamid final getting everything in place
          tamidfinalreset() async {

            //  if (OPENWORLD.Time.time<7.75)
            OPENWORLD.Time.setTime(8.5);
            // OPENWORLD.Time.setTimeLerp(7.75, 60,onlyifover: true);
            doorssetopen();
            Glob.createTamidCourtCrowd!(50*2,30*1.5);//,270);

            Glob.showblood!(true);

            //   var friendhearthx=Glob.tamidhewnstonepriestposx!( 4,false);
            OPENWORLD.Space.worldToLocalSurfaceObj(
                threeJs.camera, Glob.ketoretstartposx,Glob.ketoretstartposy, // 4.94, -1.80,//4.93, -1.78,//Glob.priestincenseposx+0.05,Glob.priestincenseposy,//  Glob.priestassistantposx, Glob.priestassistantposy,//4.85, -1.80,// friendhearthx-0.05,Glob.tamidhewnstonepriestposy,
                OPENWORLD.Camera.cameraoffset, level: 1);
            OPENWORLD.Space.objTurn(threeJs.camera,10);//313);


            OPENWORLD.Space.worldToLocalSurfaceObj(
                friendhearth, Glob.priestincenseposx,Glob.priestincenseposy,0,level:1);//4.98, -1.76,0,level:1);// 4.85, -1.76,0, level: 1);
            OPENWORLD.Space.objTurn(friendhearth,0);//313);
            OPENWORLD.Space.objTurnLerp(friendhearth,0, 1,delay:1);//313);
           // OPENWORLD.Actor.playAction( friendhearth, action: "starjump", randomduration: 0.1);
            OPENWORLD.Actor.playAction( friendhearth, action: "idlestraight", randomduration: 0.1);

            await general();

            await general2();

            Glob.meatdropall!(); // put meat on the altar
            Glob.tools!();
            Glob.tamiditems!();


            superintendent=priestlots[0];// cheat, use an extra priest inside the chamber of the hewnstone instead of the original one outside the chitveh
            OPENWORLD.Space.worldToLocalSurfaceObj(
                superintendent,   hewnstonelotposx,hewnstonelotposy,0, level: 1);
            OPENWORLD.Space.objTurn(superintendent,90);//313);
            OPENWORLD.Actor.playAction(superintendent, action: "idlestraight", randomduration: 0.1);

            for (var i = 10; i < securitylist.length; i++) {
              var securitypriest = securitylist[i];
              if (securitypriest!=superintendent)
                OPENWORLD.Space.objTurnLerp(securitypriest, 270, 1,delay:OPENWORLD.Math.random()*5);
            }

            for (var i = 0; i < priestlots.length; i++) {
              var priest = priestlots[i];
              setcancollide(priest, true);
              if (priest!=superintendent) {
                OPENWORLD.Actor.removeObjectFromPlayActionsLoop(priest);
                OPENWORLD.Space.worldToLocalSurfaceObjHide(
                    priest, hewnstonelotposx + poshewstonelotsdiff[i][0] * 0.07,
                    hewnstonelotposy + poshewstonelotsdiff[i][1] * 0.07, 0,
                    level: 1, 4);
                OPENWORLD.Space.faceObject(priest,superintendent);
                var newpos = OPENWORLD.Math.vectorMoveForward(
                    hewnstonelotposx + poshewstonelotsdiff[i][0] * 0.07,
                    hewnstonelotposy + poshewstonelotsdiff[i][1] * 0.07,
                    OPENWORLD.Space.getObjTurn(priest) - 180, 0.08);
                if (newpos.y > -1.58) // So doesn't stick in the wall
                  newpos.y = -1.58;

                OPENWORLD.Space.worldToLocalSurfaceObjHide(
                    priest, newpos.x,newpos.y, 0,
                    level: 1, 4);
                OPENWORLD.Actor.playAction(
                    priest, action: "idle",
                    randomduration: 0.1);

              }

            }

            // Once everything loaded start the tamid final
            callwhenloaded(() {
              tamidfinal();
            });
          }


          if (gamestart == GameStart.hearth &&
              gamestartpos[gamestart]['progress'].contains('ketoret')) {
            // If the progress has done the ketoret the start the tamid final
            print("tamidfinalreset start");
            tamidfinalreset();
          } else {
            // Do the ketoret - your friend has won the lottery and you are his assistant
            ketoret() async
            {
              saveGameState('shema');
              OPENWORLD.Config.updatePoolObjects();
              if (OPENWORLD.Time.time < 8)
                OPENWORLD.Time.setTimeLerp(8, 60, onlyifover: true);
              friendhearth.extra['followhearth'] = true;
              OPENWORLD.You.room?.extra['distfollow'] = 0.1;
              Glob.createTamidCourtCrowd!(50 * 2, 30 * 2); //,270);


              // Priests outside chitveh should face west
              for (var i = 10; i < securitylist.length; i++) {
                var securitypriest = securitylist[i];
                if (securitypriest != superintendent)
                  OPENWORLD.Space.objTurnLerp(securitypriest, 270, 1,
                      delay: OPENWORLD.Math.random() * 5);
              }

              // Your friend who does the ketoret and is the incense priest who throws the incense
              var priestincense = friendhearth;

              //var priestfirepanget=priestlots[1];
              // The priest that gets the firepan at puts it at the bottom of the ramp then comes back to the hewnstone
              var priestfirepanget = await OPENWORLD.Actor.copyActor(
                  OPENWORLD.Math.randPick(priestlist),
                  randomduration: 0.1);
              _hotload.add(priestfirepanget);
              OPENWORLD.Space.worldToLocalSurfaceObj(
                  priestfirepanget,4.08, -1.28+0.2,  0, level: 1);  // near the laver

              // Create a new priest to guarentee isn't one effected later stopping the ketoret - issue where the ketoret doesn't start
              var priestfirepan = await OPENWORLD.Actor.copyActor(
                  OPENWORLD.Math.randPick(priestlist),
                  randomduration: 0.1);
              _hotload.add(priestfirepan);
              OPENWORLD.Space.worldToLocalSurfaceObj(
                  priestfirepan,4.86, -1.65,  0, level: 1);

              // Get the superintendent out of the way
              OPENWORLD.Mob.moveTo(
                  superintendent,
                  [
                    [5.04, -1.68, 0, 0.02],
                  ],
                  level: 1,
                  action: "walk",
                  stopaction: "idlestraight",
                  actionrandomduration: 0.1,
                  callbackonfinish: (actor){
                    //OPENWORLD.Space.objTurnLerp(actor,0,1,delay:1);
                    for (var priest in priestlots) {
                      if (priest!=superintendent&&priest!=friendhearth&&priest!=priestfirepanget&&priest!=priestfirepan)
                        OPENWORLD.Space.objTurnLerp(priest, 0, 1, delay: 3+ OPENWORLD.Math.random()*5);
                    }

                  },
                  surfaceonly: true);

              // Start the general ketoret now that have create the firepanget and firepan priest
               // You are the assistant so is redundant
              Glob.ketoret!(
                  priestfirepanget, priestfirepan, null, //priestassistant,
                  priestincense,
                  callbackapproachhewnstone:(){
                     // So can clear a path through priests so you dont walk through them as you both come back to the hewnstone
                     for (var priest in priestlots) {
                       var friendpos = OPENWORLD.Space.localToWorldObj(priest);

                       if (friendpos.x<5.03&&friendpos.x>4.82) {
                         var newposx;
                         if (friendpos.x > 4.93) {
                           newposx = 5.03;
                         } else {
                           newposx = 4.82;
                         }
                         OPENWORLD.Mob.moveTo(
                             priest,
                             [
                               [newposx,friendpos.y,0,0.02],
                             ],
                             level: 1,
                             action: "walk",
                             stopaction: "idlestraight",

                             callbackonfinish: (actor){
                               OPENWORLD.Space.faceObjectLerp(priest,threeJs.camera,1);
                             });
                       } else
                         OPENWORLD.Space.faceObjectLerp(priest,threeJs.camera,1, delay:OPENWORLD.Math.random());
                     }
                     OPENWORLD.Mob.moveTo(
                         superintendent,
                         [
                           [ 4.84, -1.74,0,0.02],
                         ],
                         level: 1,
                         action: "walk",
                         stopaction: "idlestraight",

                         callbackonfinish: (actor){
                           OPENWORLD.Space.faceObjectLerp(priest,threeJs.camera,1);
                         });
                     // dont leave them just standing in the chamber of the the hewnstone -remove them so they are not left hanging around during tamid final
                     OPENWORLD.Mob.moveTo(
                         priestfirepanget,
                         [[4.94+0.2, -1.57,0,0.02],],
                         level: 1,
                         action: "walk",
                         stopaction: "idlestraight",
                         callbackonfinish: (actor){
                           OPENWORLD.Space.removeObjFromHide(actor);
                           actor.visible=false;
                         });
                     OPENWORLD.Mob.moveTo(
                         priestfirepan,
                         [[4.9+0.3, -1.62,0,0.02],],
                         level: 1,
                         action: "walk",
                         stopaction: "idlestraight",
                         callbackonfinish: (actor){
                           OPENWORLD.Space.removeObjFromHide(actor);
                           actor.visible=false;
                         });

                  }, callbackonfinish: () {

                    tamidfinal();
                 });

            }

            // restart game so can do the ketoret
            ketoretreset() async {

              OPENWORLD.Time.setTime(8);
              doorssetopen();
              Glob.createTamidCourtCrowd!(50 * 2, 30 * 1.5); //,270);

              Glob.showblood!(true);

              //   var friendhearthx=Glob.tamidhewnstonepriestposx!( 4,false);
              OPENWORLD.Space.worldToLocalSurfaceObj(
                  threeJs.camera, Glob.priestassistantposx,
                  Glob.priestassistantposy,
                  //4.85, -1.80,// friendhearthx-0.05,Glob.tamidhewnstonepriestposy,
                  OPENWORLD.Camera.cameraoffset, level: 1);
              OPENWORLD.Space.objTurn(threeJs.camera, 0); //313);


              OPENWORLD.Space.worldToLocalSurfaceObj(
                  friendhearth, Glob.priestincenseposx, Glob.priestincenseposy,
                  0,
                  level: 1); //4.98, -1.76,0,level:1);// 4.85, -1.76,0, level: 1);
              OPENWORLD.Space.objTurn(friendhearth, 0); //313);
              OPENWORLD.Actor.playAction(
                  friendhearth, action: "idlestraight", randomduration: 0.1);

              await general();

              await general2();

              Glob.meatdropall!(); // put meat on the altar
              Glob.tools!();
              Glob.tamiditems!();


              superintendent = priestlots[0]; // cheat, use an extra priest inside the chamber of the hewnstone instead of the original one outside the chitveh
              OPENWORLD.Space.worldToLocalSurfaceObj(superintendent, hewnstonelotposx, hewnstonelotposy, 0, level: 1);
              OPENWORLD.Space.objTurn(superintendent, 90); //313);
              OPENWORLD.Actor.playAction(
                  superintendent, action: "idlestraight", randomduration: 0.1);

              for (var i = 0; i < priestlots.length; i++) {
                var priest = priestlots[i];
                setcancollide(priest, true);
                if (priest != superintendent) {
                  OPENWORLD.Actor.removeObjectFromPlayActionsLoop(priest);
                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                      priest,
                      hewnstonelotposx + poshewstonelotsdiff[i][0] * 0.07,
                      hewnstonelotposy + poshewstonelotsdiff[i][1] * 0.07, 0,
                      level: 1, 4);
                  OPENWORLD.Space.faceObject(priest, superintendent);
                  var newpos = OPENWORLD.Math.vectorMoveForward(
                      hewnstonelotposx + poshewstonelotsdiff[i][0] * 0.07,
                      hewnstonelotposy + poshewstonelotsdiff[i][1] * 0.07,
                      OPENWORLD.Space.getObjTurn(priest) - 180, 0.08);
                  if (newpos.y > -1.58) // So doesn't stick in the wall
                    newpos.y = -1.58;

                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                      priest, newpos.x, newpos.y, 0,
                      level: 1, 4);
                  OPENWORLD.Actor.playAction(
                      priest, action: "idle",
                      randomduration: 0.1);
                }
              }

              callwhenloaded(() {
                ketoret();
              });
            }

            if (gamestart == GameStart.hearth &&
                gamestartpos[gamestart]['progress'].contains('shema')) {
              // If done the shema then start the ketoret
              print("ketoretreset start");
              ketoretreset();
            } else {
              // Do the shema in the chamber of the hewnstone
              shema() async
              {
                saveGameState('tamid');
                //OPENWORLD.Config.updatePoolObjects();
                //  if (OPENWORLD.Time.time<7.75)
                friendhearth.extra['followhearth'] = true;

                OPENWORLD.Time.setTimeLerp(7.75, 60, onlyifover: true);
                OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                    threeJs.camera, Glob.tamidhearthposx, Glob.tamidhearthposy,
                    //4.85, -1.79,// friendhearthx-0.05,Glob.tamidhewnstonepriestposy,
                    OPENWORLD.Camera.cameraoffset, 4, level: 1);
                OPENWORLD.Space.objTurnLerp(
                    threeJs.camera, 15, 1, delay: 4); //7,1, delay:4);//313);

                superintendent = priestlots[0]; // cheat, use an extra priest inside the chamber of the hewnstone instead of the original one outside the chitveh
                var extrapriests = [];
                for (var i = 0; i < priestlots.length; i++) {
                  var priest = priestlots[i];
                  if (priest != friendhearth) {
                    if (i == 1 || i > 8)
                      extrapriests.add(priest);
                  }
                }
                // Have the extra priests on the sides of the hewnstone move east and west to be closer to the superintendent
                var incwest = 0;
                var inceast = 0;
                for (var i = 0; i < extrapriests.length; i++) {
                  var priest = extrapriests[i];
                  OPENWORLD.Actor.unwield(priest, "Bip01_R_Hand");  // make sure no priest are wielding anything
                  var friendpos = OPENWORLD.Space.localToWorldObj(priest);

                  var posx;
                  var posy;
                  if (friendpos.x < 4.92) {
                    posx = 4.77 + 0.04;
                    posy = -1.63 - 0.05 - incwest * 0.05;
                    incwest++;
                  } else {
                    posx = 5.04 - 0.02;
                    posy = -1.63 - 0.05 - inceast * 0.05;
                    inceast++;
                  }
                  OPENWORLD.Mob.moveTo(
                      priest,
                      [
                        [posx, posy, 0, 0.02],
//                      [posx,friendpos.y, 0, 0.02],
                      ],
                      level: 1,
                      action: "walk",
                      stopaction: "idle",
                      //straight",
                      actionrandomduration: 0.1,
                      surfaceonly: true,
                      // delay:5,
                      callbackonfinish: (actor) {
                        OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1, delay: 7);
                        //  OPENWORLD.Space.objTurnLerp(actor,90,1);
                      });
                }

                // Have the priests on the edges of the line to move forward to see the superintendent
                // var moveforwardpriests=[sixpriests[0],sixpriests[1],threepriests[1]];//,threepriests[2]];
                var moveforwardpriests = [
                  sixpriests[1],
                  threepriests[1]
                ]; //,threepriests[2]];
                for (var i = 0; i < moveforwardpriests.length; i++) {
                  var priest = moveforwardpriests[i];
                  OPENWORLD.Actor.unwield(priest, "Bip01_R_Hand");  // make sure no priest are wielding anything
                  var friendpos = OPENWORLD.Space.localToWorldObj(priest);
                  var distforward;
                  //if (i==0)//||i==moveforwardpriests.length-1)
                  //    distforward=0.08;
                  // else
                  distforward = 0.04;
                  OPENWORLD.Mob.moveTo(
                      priest,
                      [
                        [friendpos.x, friendpos.y + distforward, 0, 0.02],
                      ],
                      level: 1,
                      action: "walk",
                      stopaction: "idlestraight",
                      actionrandomduration: 0.1,
                      surfaceonly: true,
                      callbackonfinish: (actor) {
                        OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1, delay: 10);
                      });
                }
                // Fill in sort of gap left - needs an extra priest to left of superintedent
                var speakpriests = [sixpriests[0], threepriests[2]];
                // Eastern priest next to superintednent
                OPENWORLD.Mob.moveTo(
                    sixpriests[0],
                    [
                      [5.01, -1.63, 0, 0.02],
                    ],
                    level: 1,
                    action: "walk",
                    stopaction: "idlestraight",
                    actionrandomduration: 0.1,
                    surfaceonly: true,
                    callbackonfinish: (actor) {
                      OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1, delay: 10);
                      OPENWORLD.Actor.playActionsLoop(actor,
                          [
                            "idlestraight",
                            "handsouttogether",
                            "idlestraight",
                            "lookup"
                          ],
                          durations: [20, 20, 20, 20],
                          randomdurations: [0.1, 0.1, 0.1, 0.1],
                          fadein: null,
                          fadeout: 2,
                          randomaction: true,
                          delay: 15); //fadeout:null);//fadein:0.5); //,fadeout:0.7);
                      //    ["lookleft","lookright"],
//                        ["idlestraight", "idle","handsouttogether","lookleft","lookright"],
                      //      durations: [10,10,10],randomdurations:[0.1,0.1,0.1],randomaction:true,fadein:1,fadeout:1, delay:15);//fadeout:null);//fadein:0.5); //,fadeout:0.7);

                    });
                // Western priest next to superintednent
                OPENWORLD.Mob.moveTo(
                    threepriests[2],
                    [
                      [4.81, -1.60, 0, 0.02],
                    ],
                    level: 1,
                    action: "walk",
                    stopaction: "idlestraight",
                    actionrandomduration: 0.1,
                    surfaceonly: true,
                    callbackonfinish: (actor) {
                      OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1, delay: 10);
                      OPENWORLD.Actor.playActionsLoop(actor,
                          [
                            "idlestraight",
                            "handsouttogether",
                            "idlestraight",
                            "lookdown"
                          ],
                          durations: [20, 20, 20, 20],
                          randomdurations: [0.1, 0.1, 0.1, 0.1],
                          fadein: null,
                          fadeout: 2,
                          randomaction: true,
                          delay: 15); //fadeout:null);//fadein:0.5); //,fadeout:0.7);
                      // ["lookright", "lookleft"],
                      //   ["idlestraight", "lookleft","idlestraight","lookright","idlestraight","lookright"],
//                        ["idlestraight", "idle","handsouttogether","lookleft","lookright"],
                      //  durations: [20,10,20,10,20,10],randomdurations:[0.1,0.1,0.1],fadein:2,fadeout:2, randomaction:true,delay:15);//fadeout:null);//fadein:0.5); //,fadeout:0.7);

                    });


                for (var i = 0; i < securitylist.length; i++) {

                  var securitypriest = securitylist[i];
                  if (securitypriest != superintendent) {
                    if (i<10) {
                      // Original Security Priests on edge of hewnstone - move them forward a bit

                    } else {
                      // have priests outside the hewnstone looking toward the hewnstone when start shema
                      if (OPENWORLD.Space.getDistanceBetweenObjs(securitypriest, superintendent)<1.4)//35)
                        OPENWORLD.Space.faceObjectLerp(securitypriest,superintendent,1,delay:OPENWORLD.Math.random()*10);
                    }
                  }
                }

                // This is the lines coming out of the priests mouth
                var speechplane = await OPENWORLD.Plane.loadPlane(
                    'assets/textures/speech.png', 15, 15, z: 65,
                    flipx: true,
                    doublesided: true,
                    ambient: false);
                OPENWORLD.Texture.setEmissive(
                    speechplane, THREE.Color.fromHex32(0xffffff));
                speechplane.position.z = 15.0;

                friendhearth.add(speechplane);
                for (var priest in moveforwardpriests) {
                  var speechplane2 = speechplane.clone();
                  priest.add(speechplane2);
                  OPENWORLD.Texture.setOpacity(speechplane2, 0);
                  //priest.extra['speechplane']=speechplane2;
                }
                for (var priest in extrapriests) {
                  var speechplane2 = speechplane.clone();
                  priest.add(speechplane2);
                  OPENWORLD.Texture.setOpacity(
                      speechplane2, 0);
                //  priest.extra['speechplane']=speechplane2;
                }
                //  superintendent.add(speechplane.clone()..visible=false);
                friendhearth.extra['speechplane'] = speechplane;
                speechplane.visible = false;
              // var minwait = 0.5;
               // var waitbetweenverses = 5;
                var minwait = 2;
                var waitbetweenverses = 25;
                final String response = await rootBundle.loadString(
                    'assets/tamid.json');
                var tamidtexts = await json.decode(response);
                //  tamidtexts.removeRange(1, tamidtexts.length);
                var tamidtextschopped = [];
                var totaltime = 0.0;
                for (var i = 0; i <
                    tamidtexts.length; i++) { //verse in tamidtexts) {
                  var verse = tamidtexts[i];
                  var verselines = OPENWORLD.Mob.chopText(verse['text']);
                  tamidtextschopped.add(verselines);
                  totaltime += verselines.length * minwait + waitbetweenverses;
                }
                var friendlotteryposx = 4.96 - 0.02 - 0.02;
                var friendlotteryposy = -1.72 + 0.03;

                var friendpos = OPENWORLD.Space.localToWorldObj(superintendent);
                // This is a massive set of actions for the superintendent including the shema and two lotteries!
                List<Map> actions = [
                  {"p": [friendpos.x, friendpos.y, 0], "v": 0.02},
                  {"p": [ 4.82, -1.62, 0], "v": 0.02},
                  {"p": [4.92, -1.49 - 0.06, 0], "v": 0.02},
                  {
                    "action": "idlestraight",
                    "time": 1,
                    "t": 180,
                    "callback": (actor) async {
                      // This action you do the shema
                      versefinish(actor) {

                        //   print("finished speed tamid"+actor.extra['verseindex'].toString());
                        if (actor.extra['verseindex'] + 1 < tamidtexts.length) {
                          setState(() {
                            roomname = 'Chamber of the Hewnstone\n' +
                                tamidtexts[actor.extra['verseindex'] +
                                    1]['title'];
                          });
                          if (tamidtexts[actor.extra['verseindex'] +
                              1]['mode'] == 'unison') {
                            for (var i = 0; i < 3; i++) {
                              //    OPENWORLD.BaseObject.l
                              // Is this doing the opacity lerp for all the priests because sharing the texture?
                              OPENWORLD.Texture.opacityLerp(
                                  friendhearth.extra['speechplane'], 1, 1,
                                  delay: 20 + i * 15);
                              OPENWORLD.Texture.opacityLerp(
                                  friendhearth.extra['speechplane'], 0, 1,
                                  delay: 25 + i * 15);
                              /*OPENWORLD.BaseObject.setVisible(
                                  friendhearth.extra['speechgroup'], true,
                                  delay: 5+i*15);
                              OPENWORLD.BaseObject.setVisible(
                                  friendhearth.extra['speechgroup'], false,
                                  delay: 10+i*15);*/
                            }
                          }
                        } else {
                          // Finished shema all together
                        }
                      }

                      var time = 0.0;
                      setState(() {
                        roomname = 'Chamber of the Hewnstone\n' +
                            tamidtexts[0]['title'];
                      });
                      // var minwait=2;
                      actor.extra['verseindex'] = 0;
                      for (var i = 0; i < tamidtexts.length; i++) { //verse in tamidtexts) {
                        var verse = tamidtexts[i];
                        var verselines = tamidtextschopped[i]; //OPENWORLD.Mob.chopText(verse['text']);
                        if (verse['title'] == 'Opening Blessing')
                          verselines.insert(0, 'Recite one blessing.');
                        Future.delayed(Duration(
                            milliseconds: (time * 1000).round()), () async {
                          if (verse['mode'] == 'leader_with_response') {
                            // print("tamid"+verse['mode']+' '+verse['title']+' '+verselines.length.toString()+" "+time.toString());
                            OPENWORLD.Mob.setSpeech(actor,
                                verselines.toList(), z: 90,
                                //allverselines,
                                width: 300,
                                clearwhendone: true,
                                minwait: minwait,
                                scale: 0.4,
                                randwait: 0,
                                //   delay: time,
                                callbackonfinish: (actor) {
                                  versefinish(actor);


                                  actor.extra['verseindex']++;

                                  for (var priest in speakpriests)
                                    OPENWORLD.Mob.setSpeech(priest,
                                        ['Amen'], z: 90,
                                        //allverselines,
                                        width: 300,
                                        clearwhendone: true,
                                        minwait: 3,
                                        scale: 0.4,
                                        delay: OPENWORLD.Math.random(),
                                        randwait: 0);
                                });
                          } else if (verse['mode'] == 'unison') {
                            //   print("tamidzz"+verse['mode']+' '+verse['title']+' '+verselines.length.toString()+" "+time.toString());
                            OPENWORLD.Mob.setSpeech(actor,
                                verselines.toList(), z: 90,
                                y: -50.0,
                                //allverselines,
                                width: 300,
                                clearwhendone: true,
                                minwait: minwait,
                                scale: 0.7,
                                //  delay: time,
                                tails: { 'bottomleft', 'bottomright', 'bottomcenter' },
                                callbackonfinish: (actor) {
                                  versefinish(actor);

                                  actor.extra['verseindex']++;
                                },
                                randwait: 0);
                          }
                        });
                        time +=
                            verselines.length * minwait +
                                waitbetweenverses; //25;

                        // allverselines.addAll(verselines);
                      }

                      // high priest doing the shema
                      OPENWORLD.Actor.playActionsLoop(actor,
                          ["idle", "point", "idle", "hitup", "armsup", "idle"
                          ],
                          durations: [2 * 2, 3 * 2, 2 * 2, 2 * 2, 5 * 2, 5 * 2],
                          fadein: 0,
                          fadeout: 2); // fadeout:null);//fadein:0.5); //,*/fadeout:0.7);

                    }
                  },
                  {
                    "action": "idlestraight",
                    "time": totaltime,
                    "callback": (actor) {
                      // Now that finished the shema superintent and actors stop moving there hands and looking up and down
                      OPENWORLD.Actor.removeObjectFromPlayActionsLoop(
                          superintendent);
                      OPENWORLD.Actor.removeObjectFromPlayActionsLoop(
                          threepriests[2]);
                      OPENWORLD.Actor.removeObjectFromPlayActionsLoop(
                          sixpriests[0]);
                      // Walk the priests into a circle to start the ketoret lottery
                      for (var i = 0; i < priestlots.length; i++) {
                        var priest = priestlots[i];
                        if (priest != superintendent) {
                          OPENWORLD.Mob.moveTo(
                              priest,
                              [
                                [
                                  hewnstonelotposx +
                                      poshewstonelotsdiff[i][0] * 0.07,
                                  hewnstonelotposy +
                                      poshewstonelotsdiff[i][1] * 0.07,
                                  0,
                                  0.02
                                ],
                              ],
                              level: 1,
                              action: "walk",
                              stopaction: "idlestraight",
                              actionrandomduration: 0.1,
                              surfaceonly: true,
                              callbackonfinish: (actor) {
                                OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1);
                              });
                        }
                      }
                      if (friendisclose())
                        OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1);
                      OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1);

                      // You are in shema and starting the lottery
                      friendhearth.extra['hewnstonepos'] = OPENWORLD.Space.localToWorldObj(friendhearth);
                      //   print("friendhearth hewnstone"+friendhearth.extra['hewnstonepos'].toString());
                      threeJs.camera.extra['hewnstonepos'] = OPENWORLD.Space.localToWorldObj(threeJs.camera);
                      //  print("camera hewnstone"+threeJs.camera.extra['hewnstonepos'].toString());
                      OPENWORLD.Mob.setSpeech(friendhearth, [
                        "Now we do the lottery",
                        "for the ketoret",
                      ], z: 75,
                          width: 300,
                          clearwhendone: true,
                          scale: 0.2,
                          randwait: 0,
                          callbackonfinish: (actor) {
                            // You take your spot in lottery
                            if (friendisclose())
                              OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                threeJs.camera, 4.86, -1.77 + 0.03 + 0.02,
                                OPENWORLD.Camera.cameraoffset, 1, level: 1);
                            if (friendisclose())
                              OPENWORLD.Space.worldToLocalSurfaceObj(
                                threeJs.camera, 4.86, -1.77 + 0.03 + 0.02,
                                OPENWORLD.Camera.cameraoffset, level: 1,
                                delay: 1);
                            if (friendisclose())
                              OPENWORLD.Space.faceObjectLerp( threeJs.camera, superintendent, 1, delay: 2); //25 degrees
                            // Your friend takes his place in the lottery
                            OPENWORLD.Mob.moveTo(
                                friendhearth,
                                [
                                  [
                                    friendlotteryposx,
                                    friendlotteryposy,
                                    0,
                                    0.02
                                  ],
                                ],
                                level: 1,
                                action: "walk",
                                stopaction: "idlestraight",
                                actionrandomduration: 0.1,
                                surfaceonly: true,
                                callbackonfinish: (actor) {
                                  OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1);
                                });
                          }
                      );
                    }
                  },
                  {
                    "p": [hewnstonelotposx, hewnstonelotposy, 0],
                    "v": 0.01,
                    "callback": (actor) {
                      if (friendisclose())
                        OPENWORLD.Space.faceObjectLerp( threeJs.camera, superintendent, 1);
                    }
                  },
                  // super walks to the lottery pos
                  // {"action":"starjump",}
                ];
                var ketoretwinner = friendhearth; //priestlots[priestlots.length-5-4];


                // Now add the ketoret lottery
                actions = lotteryactions(
                    actions, -45, priestlots[1], 90 + 45, ketoretwinner);
                //     actions=lotteryactions(actions,-45, priestlots[1],5270,ketoretwinner);
                actions.add({"time": 10, "callback": (actor) {
                  // Mave back to your place before the lottery
                  OPENWORLD.Mob.moveTo(
                      friendhearth,
                      [
                        [
                          friendhearth.extra['hewnstonepos'].x - 0.02,
                          friendhearth.extra['hewnstonepos'].y + 0.03+0.01,
                          0,
                          0.02
                        ],
                      ],
                      level: 1,
                      delay: 2,
                      action: "walk",
                      stopaction: "idlestraight",
                      actionrandomduration: 0.1,
                      surfaceonly: true,
                      callbackonfinish: (actor) {
                        if (friendisclose())
                          OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1, delay: 2);
                        OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 2);
                        OPENWORLD.Mob.setSpeech(friendhearth, [
                          "I won the ketoret!",
                          "You can be my assistant.",
                          "Now we do the lottery",
                          "to bring the lamb",
                          "pieces up the ramp.",
                          "Because I won the ketoret",
                          "we'll sit this one out"
                        ], z: 75,
                            width: 300,
                            clearwhendone: true,
                            scale: 0.2,
                            delay: 2,
                            callbackonfinish: (actor) {
                              // OPENWORLD.Space.faceObjectLerp(actor, superintendent,1);
                              OPENWORLD.Mob.moveTo(
                                  friendhearth,
                                  [
                                    [friendhearth.extra['hewnstonepos'].x + 0.03,
                                      friendhearth.extra['hewnstonepos'].y - 0.01,// might make friend hearth further a way so not too close when speaks to you 0.02,
                                      0,
                                      0.02
                                    ],
                                    // [friendlotteryposx, friendlotteryposy, 0, 0.02],
                                  ],
                                  level: 1,
                                  action: "walk",
                                  stopaction: "idlestraight",
                                  actionrandomduration: 0.1,
                                  surfaceonly: true,
                                  callbackonfinish: (actor) {
                                    OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1);
                                  });
                            },
                            randwait: 0);
                      });
                  if (friendisclose())
                    OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                      threeJs.camera, threeJs.camera.extra['hewnstonepos'].x,
                      threeJs.camera.extra['hewnstonepos'].y,
                      OPENWORLD.Camera.cameraoffset, 1, level: 1);
                }});
                actions.add({"time": 30, "callback": (actor) {

                  OPENWORLD.Space.faceObjectLerp( threeJs.camera, superintendent, 1);
                  // Priests back to their spot
                  for (var i = 0; i < priestlots.length; i++) {
                    var priest = priestlots[i];
                    if (priest != superintendent && priest != ketoretwinner) {
                      OPENWORLD.Mob.moveTo(
                          priest,
                          [
                            [hewnstonelotposx +
                                poshewstonelotsdiff[i][0] * 0.07,
                              hewnstonelotposy +
                                  poshewstonelotsdiff[i][1] * 0.07, 0, 0.02],
                          ],
                          level: 1,
                          action: "walk",
                          stopaction: "idlestraight",
                          actionrandomduration: 0.1,
                          surfaceonly: true,
                          callbackonfinish: (actor) {
                            OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1);
                          });
                    }
                  }
                }
                });

                // lottery for the carrying the pieces
                actions = lotteryactions(
                    actions, 45, priestlots[7], 90, priestlots[6],
                    exclude: [ketoretwinner]);
                actions.add({"time": 10, "callback": (actor) {
                  ketoret();
                }});
                OPENWORLD.Mob.moveToLoop(
                    superintendent,
                    actions,
                    level: 1,
                    action: "walk",
                    randomduration: 0.1,
                    looptype: OPENWORLD.Mob.LoopTypeStop,

                    surfaceonly: true
                );
              }

              // Allow restart game at the shema putting priests etc in correct place
              shemareset() async {
                //  if (OPENWORLD.Time.time<7.75)
                OPENWORLD.Time.setTime(7.75);

                doorssetopen();
                Glob.createTamidCourtCrowd!(50 * 2, 30 * 1.5); //,270);

                Glob.showblood!(true);

                //   var friendhearthx=Glob.tamidhewnstonepriestposx!( 4,false);
                OPENWORLD.Space.worldToLocalSurfaceObj(
                    threeJs.camera, Glob.tamidhearthposx, Glob.tamidhearthposy,
                    //4.85, -1.79,// friendhearthx-0.05,Glob.tamidhewnstonepriestposy,
                    OPENWORLD.Camera.cameraoffset, level: 1);
                OPENWORLD.Space.objTurn(threeJs.camera, 0); //313);


                await general();

                await general2();

                // friendhearth.extra['followhearth'] = true;
                sixpriests = [
                  priestlots[2],
                  priestlots[3],
                  priestlots[4],
                  priestlots[5],
                  friendhearth
                ]; // and you !
                threepriests = [priestlots[6], priestlots[7], priestlots[8]];

                for (var i = 0; i < sixpriests.length; i++) {
                  var priest = sixpriests[i];
                  var posx = Glob.tamidhewnstonepriestposx!(i, false);
                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                      priest, posx,
                      Glob.tamidhewnstonepriestposy, 0, level: 1, 4);
                  OPENWORLD.Space.objTurn(priest, -45);
                  OPENWORLD.Actor.playAction(
                      priest, action: "idlestraight", randomduration: 0.1);
                  if (priest == friendhearth)
                    print('friendhearthposx' + posx.toString()); //4.9
                  priest.extra['priestposx'] = posx;
                  priest.extra['priestposy'] = Glob.sixprieststartposy;
                  priest.extra['priestnum'] = i;
                  Glob.meatdropaltar!(i, false);
                }

                for (var i = 0; i < threepriests.length; i++) {
                  var priest = threepriests[i];
                  var posx = Glob.tamidhewnstonepriestposx!(i, true);
                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                      priest, posx, Glob.tamidhewnstonepriestposy, 0, level: 1,
                      4);
                  OPENWORLD.Space.objTurn(priest, 45);
                  OPENWORLD.Actor.playAction(
                      priest, action: "idlestraight", randomduration: 0.1);
                  priest.extra['priestposx'] = posx;
                  priest.extra['priestposy'] = Glob.threeprieststartposy;
                  priest.extra['threepriest'] = true;
                  priest.extra['priestnum'] = i;
                  Glob.meatdropaltar!(i, true);
                }
                // Glob.threepriestswield!(threepriests);

                // Put left over priests in the chamber of hewnstone
                // Move the priests not in the tamid to the sides
                var inc = 0;
                for (var i = 0; i < priestlots.length; i++) {
                  var priest = priestlots[i];
                  if (priest != friendhearth) {
                    if (i == 0 || i == 1 || i > 8) {
                      OPENWORLD.Actor.playAction(
                          priest, action: "idlestraight", randomduration: 0.1);

                      if (inc % 2 == 0) { //OPENWORLD.Math.random()<0.5) {
                        OPENWORLD.Space.worldToLocalSurfaceObjHide(
                            priest, 4.56 + OPENWORLD.Math.randFloatSpread(0.1),
                            -1.64 + OPENWORLD.Math.randFloatSpread(0.08), 0,
                            level: 1, 4);
                        OPENWORLD.Space.objTurn(priest, 90);
                      } else {
                        OPENWORLD.Space.worldToLocalSurfaceObjHide(
                            priest, 5.23 + OPENWORLD.Math.randFloatSpread(0.1),
                            -1.64 + OPENWORLD.Math.randFloatSpread(0.08), 0,
                            level: 1, 4);
                        OPENWORLD.Space.objTurn(priest, 270);
                      }
                      inc++;
                    }
                  }
                }

                //Future.delayed(Duration(milliseconds: 10000), () async {
                callwhenloaded(() {
                  shema();
                });
               // });
              }

              if (gamestart == GameStart.hearth &&
                  gamestartpos[gamestart]['progress'].contains('tamid')) {
                // If have done the tamid then start the shema
                print("shemareset start");
                shemareset();
              } else {
                // Do the tamid
                tamid()
                {
                  saveGameState('lambslaughter');
                //  OPENWORLD.Config.updatePoolObjects();
                  friendhearthanglediff = 180; // Increase angle threshhold as the tamid has some big turns
                  //if (OPENWORLD.Time.time<7.5)
                  OPENWORLD.Time.setTimeLerp(7.5, 60, onlyifover: true);
                  Glob.createTamidCourtCrowd!(50 * 2, 30 * 1.5); //,270);

                  // Do the general tamid
                  Glob.tamid!(
                      sixpriests, threepriests, pickupcallback: (actor) {
                    if (actor == friendhearth) {
                      Future.delayed(Duration(milliseconds: 1000), () async {
                        if (friendisclose())
                          OPENWORLD.Space.objTurnLerp(threeJs.camera, 270, 1);
                        for (var i = Glob.meatlist.length - 1 - 5; i <
                            Glob.meatlist.length; i++) {
                          _hotload.remove(Glob.meatlist[i]);
                        }
                      });
                    }
                  }, dropoffcallback: (actor) {
                        // Callback when drop off meat on the ramp
                    if (actor == friendhearth) {
                      if (friendisclose())
                        OPENWORLD.Space.objTurnLerp(threeJs.camera, 270, 1);
                      if (friendisclose())
                          OPENWORLD.Space.setZLerp(
                          threeJs.camera, OPENWORLD.Camera.cameraoffset * 0.75,
                          0.4,
                          level: 1);
                      if (friendisclose())
                       OPENWORLD.Space.setZLerp(
                          threeJs.camera, OPENWORLD.Camera.cameraoffset, 1.0,
                          level: 1, delay: 0.5);
                      OPENWORLD.BaseObject.setVisible(
                          threepriests[0], false, delay: 1);
                      OPENWORLD.BaseObject.setVisible(threepriests[0], true, delay: 15); // dodgy cheat hide priest behind you so he doesn't walk through you while you're on the ramp
                      // Move the priests not in the tamid to the sides
                      var inc = 0;
                      for (var i = 0; i < priestlots.length; i++) {
                        var priest = priestlots[i];
                        if (priest != friendhearth) {
                          if (i == 0 || i == 1 || i > 8) {
                            if (inc % 2 == 0) { //OPENWORLD.Math.random()<0.5) {
                              OPENWORLD.Mob.moveTo(
                                  priest,
                                  [
                                    [4.56 + OPENWORLD.Math.randFloatSpread(0.1), -1.64 + OPENWORLD.Math.randFloatSpread(0.1), 0, 0.02],
                                  ],
                                  level: 1,
                                  action: "walk",
                                  stopaction: "idlestraight",
                                  actionrandomduration: 0.1,
                                  surfaceonly: true,
                                  callbackonfinish: (actor) {
                                    OPENWORLD.Space.objTurnLerp(actor, 90, 1);
                                  });
                            } else {
                              OPENWORLD.Mob.moveTo(
                                  priest,
                                  [
                                    [5.23 + OPENWORLD.Math.randFloatSpread(0.1), -1.64 + OPENWORLD.Math.randFloatSpread(0.1), 0, 0.02],
                                  ],
                                  level: 1,
                                  action: "walk",
                                  stopaction: "idlestraight",
                                  actionrandomduration: 0.1,
                                  surfaceonly: true,
                                  callbackonfinish: (actor) {
                                    OPENWORLD.Space.objTurnLerp(actor, 270, 1);
                                  });
                            }
                            inc++;
                          }
                        }
                      }
                    }
                  }, callbackonfinish: (actor) {
                    // callback when have finished the tamid
                    if (actor == friendhearth) {
                      // This is that awkward part where trying to move through the priests in the chamber of the hearth and going through them if any in the way
                      var friendpos = OPENWORLD.Space.localToWorldObj(friendhearth);
                      friendhearth.extra['followhearth'] = false;

                      OPENWORLD.Mob.moveTo(
                          threeJs.camera,
                          [
                            [
                              friendpos.x - 0.05,
                              friendpos.y,
                              OPENWORLD.Camera.cameraoffset,
                              0.02
                            ],
                            [
                              friendpos.x - 0.05,
                              friendpos.y - 0.05,
                              OPENWORLD.Camera.cameraoffset,
                              0.02
                            ],
                            [
                              Glob.tamidhearthposx,
                              Glob.tamidhearthposy - 0.05,
                              OPENWORLD.Camera.cameraoffset,
                              0.02
                            ],
                            [
                              Glob.tamidhearthposx,
                              Glob.tamidhearthposy,
                              OPENWORLD.Camera.cameraoffset,
                              0.02
                            ],
                          ],
                          level: 1,
                          surfaceonly: true,
                          callbackonfinish: (actor) {
                            for (var priest in [...priestlots,...sixpriests,...threepriests])
                              if (priest!=friendhearth)
                                OPENWORLD.Space.facePointLerp(priest,4.9,-1.48,1, delay:2*OPENWORLD.Math.random());
                            if (friendisclose()) {
                              // force into correct position
                              OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera,Glob.tamidhearthposx, Glob.tamidhearthposy, OPENWORLD.Camera.cameraoffset,level:1);
                              OPENWORLD.Space.objTurnLerp(threeJs.camera, 52, 1);
                            }
                            Future.delayed(Duration(
                                milliseconds: 10000), () async {
                              shema();
                            });
                          });


                      OPENWORLD.Mob.moveTo(
                          friendhearth,
                          [
                            [friendpos.x, friendpos.y - 0.1, 0, 0.02],
                            [4.9, -1.76, 0, 0.02],
                          ],
                          level: 1,
                          action: "walk",
                          stopaction: "idlestraight",
                          surfaceonly: true,
                          delay: 1,
                          callbackonfinish: (actor) {
                            OPENWORLD.Space.objTurnLerp(
                                actor, -10, 1); //, angle, time)

                          });
//                  OPENWORLD.Space.objTurnLerp(threeJs.camera, 0, 1, delay: 4);
                      OPENWORLD.You.room?.extra.remove('distfollow');
                      /* Future.delayed(Duration(milliseconds: 10000), () async {
                 //   shema();
                  });*/
                    }
                  });
                  OPENWORLD.You.room?.extra['distfollow'] = 0.10;
                }

                // Reset to start of tamid where priests line up along the altar including yourself
                tamidreset() async {
                  // if (OPENWORLD.Time.time<7.5)
                  OPENWORLD.Time.setTimeLerp(7.5, 60, onlyifover: true);
                  doorssetopen();

                  //firealtarblood.visible = true;
                 // firealtarbloodse.visible = true;
                  Glob.showblood!(true);

                  OPENWORLD.Space.worldToLocalSurfaceObj(
                      threeJs.camera,
                      Glob.sixprieststartposx + 6 * Glob.sixpriestsdiff,
                      Glob.sixprieststartposy,
                      OPENWORLD.Camera.cameraoffset, level: 1);
                  OPENWORLD.Space.objTurn(threeJs.camera, -45); //313);

                  OPENWORLD.Space.objTurn(friendhearth, -45); //313);
                  OPENWORLD.Space.objTurnLerp(
                      friendhearth, -45, 1, delay: 10); //313

                  Glob.meatonpillar!();

                  await general();

                  await general2();

                  sixpriests = [
                    priestlots[2],
                    priestlots[3],
                    priestlots[4],
                    priestlots[5],
                    friendhearth
                  ]; // and you !
                  threepriests = [priestlots[6], priestlots[7], priestlots[8]];

                  for (var i = 0; i < sixpriests.length; i++) {
                    var priest = sixpriests[i];
                    var posx = Glob.sixprieststartposx +
                        i * Glob.sixpriestsdiff +
                        OPENWORLD.Math.randFloatSpread(0.015);
                    OPENWORLD.Space.worldToLocalSurfaceObjHide(
                        priest, posx,
                        Glob.sixprieststartposy, 0, level: 1, 4);
                    OPENWORLD.Space.objTurn(priest, -45);
                    OPENWORLD.Actor.playAction(
                        priest, action: "idlestraight", randomduration: 0.1);
                    priest.extra['priestposx'] = posx;
                    priest.extra['priestposy'] = Glob.sixprieststartposy;
                    priest.extra['priestnum'] = i;
                  }

                  for (var i = 0; i < threepriests.length; i++) {
                    var priest = threepriests[i];
                    var posx = Glob.threeprieststartposx +
                        i * Glob.sixpriestsdiff +
                        OPENWORLD.Math.randFloatSpread(0.015);
                    OPENWORLD.Space.worldToLocalSurfaceObjHide(
                        priest, posx, Glob.threeprieststartposy, 0, level: 1,
                        4);
                    OPENWORLD.Space.objTurn(priest, -45);
                    OPENWORLD.Actor.playAction(
                        priest, action: "idlestraight", randomduration: 0.1);
                    priest.extra['priestposx'] = posx;
                    priest.extra['priestposy'] = Glob.threeprieststartposy;
                    priest.extra['threepriest'] = true;
                    priest.extra['priestnum'] = i;
                  }
                  Glob.threepriestswield!(threepriests);

                  // Put left over priests in the chamber of hewnstone
                  for (var i = 0; i < priestlots.length; i++) {
                    var priest = priestlots[i];
                    OPENWORLD.Actor.removeObjectFromPlayActionsLoop(priest);
                    if (priest != friendhearth) {
                      // OPENWORLD.Actor.playAction(
                      //    priest, action: "idlestraight",
                      //   randomduration: 0.1);
                      if (i == 0 || i == 1 || i > 8) { // priestlots.length/2) {
                        OPENWORLD.Actor.playAction(
                            priest, action: "idlestraight",
                            randomduration: 0.1);

                        OPENWORLD.Space.worldToLocalSurfaceObjHide(
                            priest, 4.9 - OPENWORLD.Math.random() * 0.2,
                            -1.6 + OPENWORLD.Math.randFloatSpread(0.4), 0,
                            level: 1,
                            4);
                        OPENWORLD.Space.objTurn(priest, 0);
                      }
                    }
                  }
                  //Future.delayed(Duration(milliseconds: 20000), () async {
                  callwhenloaded(() {
                    friendhearth.extra['followhearth'] = true;

                    tamid();
                  });
               //   });
                }

                if (gamestart == GameStart.hearth &&
                    gamestartpos[gamestart]['progress'].contains('lambslaughter')) {
                  // If have done the lamb slaughter then start the tamid
                  print("tamidreset start");
                  tamidreset();
                } else {
                  // Do the lamb slaughter
                  // slaughter lamb and cut up the pieces on the pillar
                  lambslaughter() async
                  {
                    saveGameState('getlamb');
                  //  OPENWORLD.Config.updatePoolObjects();
                    // looks obsolete as origpos not used anywhere
                    for (var i = 0; i < priestlots.length; i++) {
                      var priest = priestlots[i];
                      if (priest != friendhearth && i < priesttamidneeded) { //priestlots.length / 2) {
                        priest.extra['origpos'] = OPENWORLD.Space.localToWorldObj(priest);
                      }
                    }
                    var vesselmizrak = await OPENWORLD.Model.createModel(
                        'assets/models/vesselmizrak.glb');
                    OPENWORLD.Texture.setMaterial(vesselmizrak, goldmaterial!, groupname: 'gold');
                    final bloodmaterial = THREE.MeshStandardMaterial.fromMap({
                      //  'normalMap': bumpTexture,
                      'color': 0xff3333,
                      'metalness': 1.0, // 0,
                      //'map': goldii,
                      'shininess': 1.0,
                      'roughness': 0.5,
                      // 'em'
                      'emissive': THREE.Color.fromHex32(0xff0000)
                      //'envMap': gold,
                      //'envMapIntensity': 1.0,// api['envMapIntensity'],
                    });
                    OPENWORLD.Texture.setMaterial(vesselmizrak, bloodmaterial, groupname: 'blood');
                    OPENWORLD.BaseObject.setVisible(vesselmizrak, false, groupname: "blood");
                    var vesselmizrak2 = vesselmizrak.clone();
                    vesselmizrak2.scale.setValues(0.0015, 0.0015, 0.0015);

                    // priest get lamb helps with the slaughter
                    OPENWORLD.Mob.moveTo(
                        priestgetlamb,
                        [
                          [sheepfinalposx - 0.04, sheepfinalposy, 0, 0.02],
                          //   [sheepfinalposx-0.04,sheepfinalposy+0.03, 0, 0.02],  0.73
                          // [5, -0.97, 0, 0.02],
                          //    [4.88, 0.69,0,0.02],
                          //    [4.73, 0.69,0,0.02]//4.97,0.69,0,0.02]
                        ],
                        level: 1,
                        action: "walk",
                        stopaction: "squatwork",
                        actionrandomduration: 0.1,
                        surfaceonly: true,
                        callbackonfinish: (actor) {
                          OPENWORLD.Space.faceObjectLerp( priestgetlamb, sheepslaughter, 1);
                        });
                    // Your friend helps with the slaughter
                    OPENWORLD.Mob.moveTo(
                        friendhearth,
                        [
                          [sheepfinalposx + 0.04, sheepfinalposy, 0, 0.03],
                        ],
                        level: 1,
                        action: "walkstraight",
                        stopaction: "squatwork",
                        actionrandomduration: 0.1,
                        surfaceonly: true,
                        callbackonfinish: (actor) {
                          OPENWORLD.Space.faceObjectLerp( friendhearth, sheepslaughter, 1);
                        });
                    // with mizrak

                    var vesselmizrakwield = vesselmizrak.clone();

                    OPENWORLD.Space.setTurnPitchRoll(
                        vesselmizrakwield, 0, 90,
                        90 + 90); //walkstraight is good!
                    // for walkstraight

                    vesselmizrakwield.position.z = 4.0; // forward (reverse)
//    vesselspoon.position.y = 5.0;//  left right
                    vesselmizrakwield.position.x = 5.0; // up down

                    // OPENWORLD.Space.setTurnPitchRoll(vesselmizrak, 0, 90 - 20, 180 + 60);
                    // OPENWORLD.Space.setTurnPitchRoll(vesselbowl, 0,130, 100);
                    //   vesselbowl.position.z=0.0;//-4.0;
                    //   vesselbowl.position.y=7.0;//5.0;
                    //   vesselbowl.position.x=0.0;
                    // Have the mizrak priest who collects the blood at the slaughter
                    var priestmizrak = priestlots[0];
                    // This is where the priestmizrak should be - lerp him there so he makes it on time to collect the blood - this about 1 unit norht of the north east corner of the altar
                    OPENWORLD.Space.worldToLocalSurfaceObj(
                        priestmizrak, 4.08 + 0.02 +  0.05 +
                        OPENWORLD.Math.randFloatSpread(0.01),
                        0.49 + OPENWORLD.Math.randFloatSpread(0.01), 0,
                        level: 1);
                    OPENWORLD.Actor.wield(priestmizrak, vesselmizrakwield, "Bip01_L_Hand");
                    OPENWORLD.Mob.moveTo(
                        priestmizrak,
                        [
                          [sheepfinalposx, sheepfinalposy - 0.04, 0, 0.02],
                          [sheepfinalposx - 0.04, sheepfinalposy - 0.03, 0, 0.02
                          ],
                        ],
                        level: 1,
                        action: "walkstraight",
                        //walkhandright",
                        stopaction: "stoopidle",
                        //squat",
                        actionrandomduration: 0.1,
                        surfaceonly: true,
                        callbackonfinish: (actor) {
                          OPENWORLD.Actor.unwield(
                              priestmizrak, "Bip01_L_Hand", delay: 1);

                          OPENWORLD.Space.objTurnLerp(priestmizrak, 90,
                              1); //faceObjectLerp(priestmizrak, sheepslaughter,1);

                          OPENWORLD.Space.worldToLocalSurfaceObjHide(
                              vesselmizrak2, sheepfinalposx - 0.04 + 0.01,
                              sheepfinalposy - 0.03, 0.015, level: 1, 4);
                          //   vesselmizrak2.children[0].scale.setValues(0.1, 0.1, 0.1);

                          OPENWORLD.Space.objTurn(vesselmizrak2, -90); //faceObjectLerp(priestmizrak, sheepslaughter,1);
                          Future.delayed(
                              Duration(milliseconds: 1000), () async {
                            _hotload.add(vesselmizrak2);
                          });
                          // Sheep is meant to face west
                          OPENWORLD.Actor.playAction(
                              sheepslaughter, action: "eatright",
                              randomduration: 0.1);
                          OPENWORLD.Space.objTurnLerp(
                              friendhearth, 270 - 45,
                              1); // turn the sheeps head

                          //    OPENWORLD.Space.faceObjectLerp(priestmizrak, sheepslaughter,1);
                        });
                    // with knife - the priest who slaughters the lamb with a knife goes to the sheep slaughter position
                    var priestslaughter = priestlots[1];
                    OPENWORLD.Space.worldToLocalSurfaceObj(
                        priestslaughter, 4.08 + 0.02 +  2*0.05 + OPENWORLD.Math.randFloatSpread(0.01),
                        0.49 + OPENWORLD.Math.randFloatSpread(0.01), 0,
                        level: 1);

                    OPENWORLD.Actor.wield(priestslaughter, knifewield, "Bip01_R_Hand");
                    OPENWORLD.Mob.moveTo(
                        priestslaughter,
                        [
                          [sheepfinalposx + 0.04, sheepfinalposy - 0.03, 0, 0.015
                          ],
                        ],
                        level: 1,
                        action: "walkstraight",
                        //handright",
                        stopaction: "idle",
                        //stoopidle",
                        actionrandomduration: 0.1,
                        surfaceonly: true,
                        callbackonfinish: (actor) {
                          OPENWORLD.Space.objTurnLerp(priestslaughter, 270,
                              1); //faceObjectLerp(priestmizrak, sheepslaughter,1);
                          OPENWORLD.BaseObject.setVisible(
                              vesselmizrak2, true, groupname: "blood", delay: 1);

                          OPENWORLD.Actor.playAction(priestslaughter, action: "stoopidle",
                              randomduration: 0.1, delay: 3);
                          OPENWORLD.Actor.playAction(
                              priestslaughter, action: "idle",
                              randomduration: 0.1, delay: 6);
                          OPENWORLD.Space.objTurnLerp(
                              priestslaughter, 0, 1, delay: 9);

                          OPENWORLD.BaseObject.setVisible(
                              vesselmizrak2, false, groupname: "blood", delay: 1);
                          OPENWORLD.Actor.playAction(
                              sheepslaughter, action: "layidle",
                              randomduration: 0.1, delay: 6);
                          // Now priest with mizrak walks to edge of altar when sheep dead
                          OPENWORLD.Mob.moveTo(
                              priestmizrak,
                              [
                                [3.85, 0.50, 0, 0.02], //3.81, 0.51,0, 0.02],
                              ],
                              level: 1,
                              action: "walkstraight",
                              //walkhandright",
                              stopaction: "idle",
                              //squat",
                              actionrandomduration: 0.1,
                              surfaceonly: true,
                              delay: 6,
                              callbackonfinish: (actor) {

                              });
                          OPENWORLD.BaseObject.setVisible(
                              vesselmizrak2, false, delay: 5);
                          OPENWORLD.Actor.wield(
                              priestmizrak, vesselmizrakwield, "Bip01_L_Hand",
                              delay: 5);
                          var finalpillarposx = 4.11 - 0.02; //3.98;
                          var finalpillarposy = 1.19; //1.19;


                          Future.delayed(
                              Duration(milliseconds: 20000), () async {
                            // Move to the pillar to start cutting up the lamb
                            priestslaughter.extra['meatinc'] = 0;

                            var friendpos = OPENWORLD.Space.localToWorldObj(
                                priestslaughter);
                            List<Map> actions = [
                              {"p": [friendpos.x, friendpos.y, 0], "v": 0.02},
                              { "p": [ finalpillarposx, finalpillarposy + 0.03, 0 ], "v": 0.02 },
                            ];
                            // var i=0;
                            // while (priestslaughter.extra['meatinc']<Glob.meatlist.length) {
                            for (var i = 0; i < Glob.meatlist.length; i += 2) {
                              actions.add(
                                  {"action": "work", "t": 270 - 30, "time": 5});
                              //   actions.add({"p":[finalpillarposx, finaltableposy-0.02, 0], "v":0.04});  // 0.02 so dont need to walk as far
                              actions.add({
                                "action": "armsup",
                                "t": 270 + 35,
                                "time": 3,
                                "callback": (actor) {
                                  // Do two pieces of meat so doesn't take forever
                                  var cnt;
                                  if (priestslaughter.extra['meatinc'] == Glob.meatlist.length - 4)
                                    cnt = 3;
                                  else
                                    cnt = 2;
                                  for (var j = 0; j < cnt; j++) {
                                    if (priestslaughter.extra['meatinc'] <
                                        Glob.meatlist.length) {
                                      var meat = Glob.meatlist[priestslaughter
                                          .extra['meatinc']];
                                      _hotload.add(meat);
                                      OPENWORLD.Space.worldToLocalSurfaceObjHide(meat, Glob.finaltableposx +
                                          OPENWORLD.Math.randFloatSpread(0.04),
                                          //3.93
                                          Glob.finaltableposy +
                                              OPENWORLD.Math.randFloatSpread(
                                                  0.04),
                                          0.058,
                                          // 1.28
                                          1, level: 1);

                                      ///          meat, 2.89+OPENWORLD.Math.randFloatSpread(0.04), 1.84+OPENWORLD.Math.randFloatSpread(0.04), 0.058, 3); // 3.2,2.5, 0.0);
                                      meat.scale.setValues(
                                          0.00065, 0.00065, 0.00065);
                                      OPENWORLD.Space.objTurn(
                                          meat, OPENWORLD.Math.random() * 360);

                                      priestslaughter.extra['meatinc']++;
                                    }
                                  }

                                  //   i++;
                                }
                              });
                              //  actions.add({"p":[finalpillarposx, finalpillarposy+0.02, 0], "v":0.04});  // 0.02 so dont need to walk as far


                            }
                            actions.add({"time": 1, "callback": (actor) {
                              // Now that the priest slaughter has finished everyone lines up - priestlots[0] is priestlaughter and has gone and priestmizrak priestlots[1] has gone
                              friendhearth.extra['followhearth'] = true;
                              sixpriests = [
                                priestlots[2],
                                priestlots[3],
                                priestlots[4],
                                priestlots[5],
                                friendhearth
                              ]; // and you !
                              // This is towards the end of lamb slaughter
                              for (var i = 0; i < sixpriests.length; i++) {
                                var priest = sixpriests[i];

                                List<List> actions = [];
                                if (priest == friendhearth) {
                                  var friendpos = OPENWORLD.Space
                                      .localToWorldObj(
                                      friendhearth);
                                  actions.add(
                                      [
                                        friendpos.x,
                                        friendpos.y + 0.04,
                                        0,
                                        0.02
                                      ]);
                                 // actions.add([4.77, 0.53, 0, 0.02]);  // northeast corner of great altar  this is your friend going back to his spot - this is a bug
                                  actions.add([
                                    Glob.sixprieststartposx + i * Glob.sixpriestsdiff,
                                    friendpos.y,
                                    0,
                                    0.02
                                  ]);
                                }
                                var posx = Glob.sixprieststartposx +
                                    i * Glob.sixpriestsdiff +
                                    OPENWORLD.Math.randFloatSpread(0.015);
                                actions.add([
                                  posx,
                                  Glob.sixprieststartposy,
                                  0,
                                  0.02
                                ]);
                                priest.extra['priestnum'] = i;
                                priest.extra['priestposx'] = posx;
                                priest.extra['priestposy'] =
                                    Glob.sixprieststartposy;

                                OPENWORLD.Mob.moveTo(
                                    priest,
                                    actions,
                                    level: 1,
                                    action: "walkstraight",
                                    stopaction: "idlestraight",
                                    //squat",
                                    actionrandomduration: 0.1,
                                    surfaceonly: true,
                                    callbackonfinish: (actor) {
                                      if (actor == friendhearth) {
                                        OPENWORLD.Space.objTurnLerp(friendhearth, 0, 1);
                                        OPENWORLD.Actor.playAction(friendhearth, action: "lookright");
                                        OPENWORLD.Mob.setSpeech(friendhearth, [
                                          "Now we carry the pieces",
                                          "to the altar",
                                        ], z: 80,
                                            width: 300,
                                            clearwhendone: true,
                                            scale: 0.2,
                                            randwait: 0,
                                            callbackonfinish: (actor) {
                                              OPENWORLD.Space.objTurnLerp(friendhearth, -45, 1);
                                              //OPENWORLD.Actor.playAction(friendhearth,
                                              //     action: "idlestraight");
                                              //   print("tamid sixpriest"+sixpriests.toString()+ " "+threepriests.toString());
                                              tamid();
                                            }
                                        );
                                        if (friendisclose()){
                                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, 4.20, 0.50, OPENWORLD.Camera.cameraoffset, 1, level: 1);
                                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, 4.44, 0.56, OPENWORLD.Camera.cameraoffset, 1, level: 1, delay: 1);
                                          OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera, 4.44, 0.56, OPENWORLD.Camera.cameraoffset,  level: 1, delay: 2);
                                          OPENWORLD.Space.objTurnLerp(threeJs.camera, 270, 1, delay: 2);
                                        }
                                      } else
                                        OPENWORLD.Space.objTurnLerp(
                                            actor,
                                            -45 +
                                                OPENWORLD.Math.randFloatSpread(
                                                    10),
                                            1);
                                    }
                                  //  delay:7,
                                  // facedir: false
                                );
                              } // 6 priests
                            } // last action callback
                            });
                            actions.add(
                                { "p": [4.92, finalpillarposy + 0.05, 0], "v": 0.04 });
                            actions.add({ "p": [4.88, -1.56, 0], "v": 0.04 }); // priest slaughter goes back to the chamber of the hewn stone
                            //  actions.add({"p":[priestslaughter.extra['origpos'].x,priestslaughter.extra['origpos'].y,0],"v": 0.04});
                            actions.add({ "action": "idlestraight", "t": slaughterviewangle, "time": 5 });

                            OPENWORLD.Mob.moveToLoop(
                              priestslaughter,
                              actions,
                              level: 1,
                              action: "walkstraight",
                              //walkhandright",
                              // stopaction: "work",
                              //squat",
                              randomduration: 0.1,
                              looptype: OPENWORLD.Mob.LoopTypeStop,

                              surfaceonly: true,
                              //  delay: 20,
                              //  callbackonfinish: (actor) {
                              //   OPENWORLD.Space.objTurnLerp(priestslaughter, 270, 1);
                              // }
                            );
                            // This is confusing but while the priest is slaughtering have the three priests make their way to their place at the altar
                            threepriests = [priestlots[6], priestlots[7], priestlots[8]];
                            // Sort by dist so the closest is at position 1 - so dont walk through eachother
                            for (var priest in threepriests) {
                              var friendpos = OPENWORLD.Space.localToWorldObj(priest);
                              priest.extra['dist'] =
                                  OPENWORLD.Math.vectorDistance(friendpos,
                                      THREE.Vector3(
                                          4.93, Glob.threeprieststartposy,
                                          0.0));
                            }
                            threepriests.sort((a, b) {
                              num distA = a.extra['dist'] ?? 0;
                              num distB = b.extra['dist'] ?? 0;
                              //   return distB.compareTo(distA);
                              return distA.compareTo(distB);
                            });
                            Glob.threepriestswield!(threepriests);
                            for (var i = 0; i < threepriests.length; i++) {
                              var priest = threepriests[i];
                              priest.extra['priestnum'] = i;
                              priest.extra['threepriest'] = true;
                              var posx = Glob.threeprieststartposx + i *
                                  Glob.sixpriestsdiff;
                              priest.extra['priestposx'] = posx;
                              priest.extra['priestposy'] =
                                  Glob.threeprieststartposy;

                              OPENWORLD.Mob.moveTo(
                                  priest,
                                  [
                                    [ 4.93, -1.31, 0, 0.021], // outside chamber of hewnstone
                                 //   [ 4.83, 0.65, 0, 0.021], // north east corner great altar - lambslaughter
                                    [4.93, Glob.threeprieststartposy, 0, 0.021],
                                    [posx, Glob.threeprieststartposy, 0, 0.021],
                                  ],
                                  level: 1,
                                  action: "walkstraight",
                                  // walkstraight
                                  stopaction: "idlestraight",
                                  //squat",
                                  actionrandomduration: 0.1,
                                  surfaceonly: true,
                                  callbackonfinish: (actor) {
                                    OPENWORLD.Space.objTurnLerp(
                                        actor,
                                        -45 +
                                            OPENWORLD.Math.randFloatSpread(10),
                                        1);
                                  }
                              );
                            }
                          });
                          // Slaughter priest goes back to his original pos in line along altar



                          OPENWORLD.Space.objTurnLerp(
                              priestgetlamb, 90, 1, delay: 6);
                          //   OPENWORLD.Space.objTurnLerp(priestgetlamb, 45, 1, delay:6);
                          OPENWORLD.Actor.playAction(
                              priestgetlamb, action: "work",
                              //walkstraight",//work",
                              randomduration: 0.1,
                              delay: 6);

                          // OPENWORLD.Space.objTurnLerp(friendhearth, -45, 1, delay:6);
                          OPENWORLD.Space.objTurnLerp(
                              friendhearth, 270, 1, delay: 6);
                          OPENWORLD.Actor.playAction(
                              friendhearth, action: "work",
                              //walkstraight",//work",
                              randomduration: 0.1,
                              delay: 6);

                          // Move the sheep to the pillar
                          OPENWORLD.BaseObject.setVisible(
                              sheepslaughter, false, groupname: "collar");
                          //OPENWORLD.Space.setZ(sheepslaughter,0.03,level:1,delay:6);
                          // Raise the sheep
                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                              sheepslaughter, sheepfinalposx,
                              sheepfinalposy + 0.01,
                              0.05,
                              1, level: 1, delay: 6);

                          OPENWORLD.Mob.moveTo(
                              priestgetlamb,
                              [
                                [
                                  finalpillarposx + 0.01,
                                  finalpillarposy - 0.02,
                                  0,
                                  0.02,
                                  45
                                ],
                              ],
                              level: 1,
                              action: "walkhandright",
                              // walkstraight
                              stopaction: "armsup",
                              //squat",
                              actionrandomduration: 0.1,
                              surfaceonly: true,
                              delay: 7,
                              facedir: false,
                              callbackonfinish: (actor) {
                                OPENWORLD.Space.objTurnLerp(
                                    priestgetlamb, 270, 1);
                                OPENWORLD.Actor.playAction(
                                    priestgetlamb, action: "work",
                                    //walkstraight",//work",
                                    randomduration: 0.1,
                                    delay: 1);
                                // After putting the lamb on the pillar  goes back to around the corner
                                OPENWORLD.Mob.moveTo(
                                    priestgetlamb,
                                    [
                                      [3.76, sheepfinalposy, 0, 0.03],
                                      [3.81, 1.61, 0, 0.03],
                                      // corner of santuary stairs
                                    ],
                                    level: 1,
                                    action: "walkstraight",
                                    //walkhandright",
                                    stopaction: "idlestraight",
                                    //squat",
                                    actionrandomduration: 0.1,
                                    surfaceonly: true,
                                    delay: 3,
                                    callbackonfinish: (actor) {
                                      OPENWORLD.Space.objTurnLerp(priestgetlamb,
                                          180, 1); // slaughterviewangle, 1);
                                    });
                              });
                          // Move lamb to pillar
                          OPENWORLD.Mob.moveTo(
                              sheepslaughter,
                              [
                                [
                                  finalpillarposx - 0.01,
                                  finalpillarposy,
                                  0.05,
                                  0.02
                                ],
                              ],
                              level: 1,
                              action: "layidle",
                              //walkhandright",
                              // stopaction: "idle",//squat",
                              actionrandomduration: 0.1,
                              surfaceonly: true,
                              delay: 7,
                              facedir: false,
                              callbackonfinish: (actor) {
                                sheepslaughter.visible = false;
                                OPENWORLD.Space.removeObjFromHide(
                                    sheepslaughter);
                                OPENWORLD.BaseObject.setVisible(
                                    Glob.pillarcarcass, true,
                                    groupname: "carcass"); //,delay:2);
                              });
                          // Carry lamb to pillar
                          OPENWORLD.Mob.moveTo(
                              friendhearth,
                              [
                                [
                                  finalpillarposx + 0.01,
                                  finalpillarposy + 0.02,
                                  0,
                                  0.02,
                                  -45
                                ],
                              ],
                              level: 1,
                              action: "walkhandleft",
                              //walkhandright",
                              stopaction: "armsup",
                              //squat",
                              actionrandomduration: 0.1,
                              surfaceonly: true,
                              delay: 7,
                              // facedir: false,
                              callbackonfinish: (actor) {
                                //  OPENWORLD.Space.objTurnLerp(friendhearth,270,1);
                                OPENWORLD.Actor.playAction(
                                    friendhearth, action: "work",
                                    //walkstraight",//work",
                                    randomduration: 0.1,
                                    delay: 2);
                                // After putting the lamb on the pillar your friend goes back to his position at the altar
                                OPENWORLD.Mob.moveTo(
                                    friendhearth,
                                    [
                                      [
                                        finalpillarposx + 0.01 + 0.03,
                                        finalpillarposy + 0.02,
                                        0,
                                        0.02
                                      ],
                                      [
                                        friendhearthaltarposx,
                                        friendhearthaltarposy + 0.03,
                                        0,
                                        0.04
                                      ],
                                      // +0.03 so you can see priestmizrak sprinkle the blood
                                    ],
                                    level: 1,
                                    action: "walkstraight",
                                    //walkhandright",
                                    stopaction: "idlestraight",
                                    //squat",
                                    actionrandomduration: 0.1,
                                    surfaceonly: true,
                                    delay: 3,
                                    callbackonfinish: (actor) {
                                      // Your friend is now back at the altar - the priest mizrak is ready to sprinkle the blood
                                      if (friendisclose())
                                        OPENWORLD.Space.objTurnLerp(threeJs.camera, 270, 1, delay: 1);
                                      OPENWORLD.Space.faceObjectLerp( friendhearth, priestmizrak, 1, delay: 1);
                                      OPENWORLD.Space.objTurnLerp(priestmizrak,
                                          180 - 45, 1);
                                      //     OPENWORLD.Space.setTurnPitchRoll(vesselmizrakwield, -90/2, 90/2, 180/2);  // Does this help make it jump less
                                      Future.delayed(Duration(
                                          milliseconds: 5000), () async {
                                        // Splash the blood
                                        var friendpos = OPENWORLD.Space
                                            .localToWorldObj(priestmizrak);
                                        OPENWORLD.Mob.moveToLoop(
                                          priestmizrak,
                                          [
                                            {"p": [friendpos.x, friendpos.y, 0], "v": 0.02,
                                              "callback": (actor) {
                                                vesselmizrakwield.position.z =
                                                0.0; // forward (reverse)
                                                //    vesselspoon.position.y = 5.0;//  left right
                                                vesselmizrakwield.position.x =
                                                0.0; // up down
                                                OPENWORLD.Actor.playAction(
                                                    priestmizrak,
                                                    action: "pointleft"); //idle");//idle");
                                                OPENWORLD.Space
                                                    .setTurnPitchRoll(
                                                    vesselmizrakwield, -90, 0,
                                                    0);
                                                // orignal           OPENWORLD.Space.setTurnPitchRoll(vesselmizrakwield, 0, 90, 90 + 90); //walkstraight is good!
                                                OPENWORLD.Space.objTurnLerp(
                                                    priestmizrak, 180 + 45, 0.4,
                                                    delay: 0.5);
                                              }
                                            },
                                            {
                                              "action": "idle",
                                              "time": 1,
                                              "callback": (actor) {
                                                OPENWORLD.Actor.playAction(
                                                    priestmizrak,
                                                    action: "idle"); //idle");//idle");
                                                // OPENWORLD.Texture.setOpacity(
                                                //     firealtarblood,
                                                //     1.0); // show the blood on the altar
                                                firealtarblood.visible = true;
                                                OPENWORLD.BaseObject.setVisible(
                                                    vesselmizrakwield, true,
                                                    groupname: "blood");
                                                OPENWORLD.BaseObject.setVisible(
                                                    vesselmizrakwield, false,
                                                    groupname: "blood",
                                                    delay: 0.5);
                                                //   OPENWORLD.Space.setTurnPitchRoll(
                                                //        vesselmizrakwield, 0, 180 - 45,
                                                //       90 + 90); //walkstraight is good!
                                                OPENWORLD.Space.setTurnPitchRoll(vesselmizrakwield, 0, 90, 90 + 90); //walkstraight is good!

                                                vesselmizrakwield.position.z = 4.0; // forward (reverse)
                                                //    vesselspoon.position.y = 5.0;//  left right
                                                vesselmizrakwield.position.x = 5.0; // up down
                                                OPENWORLD.Space.objTurnLerp(priestmizrak, 180, 0.4, delay: 0.5);
                                              }
                                            },
                                            {"time": 1},
                                            {"p": [3.89, -1.21, 0], "v": 0.04},  // priest mizrak to south west courner of altar
                                            {"p": [4.7, -1.21, 0], "v": 0.04},  // priest mizrak outside chamber of hewnstone but doesnt go in, still to do the second flick
                                            {"p": [4.7, -0.41, 0],
                                              "v": 0.04,
                                              "callback": (actor) {
                                                // Now at south east corner of the altar
                                                // I think after flicking the mizrak with blood you put it in your hand back to the way it was
                                                vesselmizrakwield.position.z = 0.0; // forward (reverse)
                                                //    vesselspoon.position.y = 5.0;//  left right
                                                vesselmizrakwield.position.x = 0.0; // up down
                                                OPENWORLD.Actor.playAction(
                                                    priestmizrak,
                                                    action: "pointleft"); //idle");//idle");
                                                OPENWORLD.Space
                                                    .setTurnPitchRoll(
                                                    vesselmizrakwield, -90, 0,
                                                    0);
                                                OPENWORLD.Space.objTurnLerp(priestmizrak, 0 + 45, 0.4, delay: 0.5);
                                              }
                                            },
                                            {
                                              "action": "idle",  // Remember the priest mizrak is flicking blood twice -
                                              "time": 1,
                                              "callback": (actor) {
                                                OPENWORLD.Actor.playAction(
                                                    priestmizrak,
                                                    action: "idle"); //idle");//idle");
                                                // OPENWORLD.Texture.setOpacity(
                                                //     firealtarblood,
                                                //     1.0); // show the blood on the altar
                                                firealtarbloodse.visible = true;
                                                OPENWORLD.BaseObject.setVisible(vesselmizrakwield, true, groupname: "blood");
                                                OPENWORLD.BaseObject.setVisible(vesselmizrakwield, false, groupname: "blood", delay: 0.5);
                                                OPENWORLD.Space.setTurnPitchRoll(vesselmizrakwield, 0, 90, 90 + 90);
                                                vesselmizrakwield.position.z = 4.0; // forward (reverse)
                                                //    vesselspoon.position.y = 5.0;//  left right
                                                vesselmizrakwield.position.x = 5.0; // up down
                                                OPENWORLD.Space.objTurnLerp(priestmizrak, 0, 0.4, delay: 0.5);
                                                OPENWORLD.Actor.unwield(priestmizrak,"Bip01_L_Hand", delay:10); // stop case where when finish slaughterlamb and priest is giving shema holding the mizrak
                                              }
                                            },
                                            {"time": 1},

                                          ],
                                          level: 1,
                                          action: "walkstraight",
                                          randomduration: 0.1,
                                          looptype: OPENWORLD.Mob.LoopTypeStop,

                                          //stopaction: "idlehold",
                                          //actionrandomduration: 0.1,
                                          surfaceonly: true,

                                        );
                                      });
                                      //  OPENWORLD.Space.faceObjectLerp(threeJs.camera, priestmizrak,1,delay:1);
                                      // This is pretty confusing but this where friendhearth reaches the corner of the altar
                                      // You wait till priestmizrak sprinkles the blood, then you turn to look back at the priestslaughter who is carving up the lamb
                                      OPENWORLD.Mob.setSpeech(friendhearth, [
                                        "Now the priest flays & divides",
                                        "the lamb into 6 main parts",
                                        "and we bring them to the altar",
                                      ], z: 80,
                                          width: 300,
                                          scale: 0.2,
                                          randwait: 0,
                                          delay: 10,
                                          callbackonfinish: (actor) {
                                            // Now look back at priestslaughter
                                            if (friendisclose())
                                                OPENWORLD.Space.faceObjectLerp( threeJs.camera, priestslaughter, 1);
                                            OPENWORLD.Space.faceObjectLerp( friendhearth, priestslaughter, 1);
                                          },
                                          clearwhendone: true);
                                      if (friendisclose())
                                        OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1, delay: 10);
                                      OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 10);
                                    });


                                // Glob.pillarcarcass
                              });
                        });
                  }

                  // Priests lined up along the altar waiting for the slaughter to take place, including yourself
                  lambslaughterreset() async {
                    //  if (OPENWORLD.Time.time<7.3)
                    //  OPENWORLD.Time.setTimeLerp(7.3, 60,onlyifover: true);
                    OPENWORLD.Time.setTime(7.3);
                    Glob.createTamidCourtCrowd!(50, 30); //,270);

                    doorssetopen();

                    OPENWORLD.Space.worldToLocalSurfaceObj(
                        threeJs.camera, 3.98 + 0.05, 0.51,
                        OPENWORLD.Camera.cameraoffset, level: 1);
                    OPENWORLD.Space.objTurn(
                        threeJs.camera, slaughterviewangle); //313);

                    OPENWORLD.Space
                        .worldToLocalSurfaceObjHide( // Corner of altar
                        friendhearth, friendhearthaltarposx,
                        friendhearthaltarposy,
                        0,
                        level: 1, 4);

                    OPENWORLD.Space.objTurn(friendhearth, slaughterviewangle); //313);
                    OPENWORLD.Space.objTurnLerp(friendhearth, slaughterviewangle, 1, delay: 10); //313
                    OPENWORLD.Actor.playAction(friendhearth, action: "idle", randomduration: 0.1);


                    await general();
                    await general2();

                    for (var i = 0; i < priestlots.length; i++) {
                      var priest = priestlots[i];
                      OPENWORLD.Actor.removeObjectFromPlayActionsLoop(priest);
                      if (priest != friendhearth) {
                        OPENWORLD.Actor.playAction(
                            priest, action: "idlestraight",
                            randomduration: 0.1);

                        if (i < priesttamidneeded) { // priestlots.length/2) {
                          OPENWORLD.Space.worldToLocalSurfaceObjHide(
                              priest, 4.08 + 0.02 + i * 0.05 +
                              OPENWORLD.Math.randFloatSpread(0.01),
                              0.49 + OPENWORLD.Math.randFloatSpread(0.01), 0,
                              level: 1, 4);

                          OPENWORLD.Space.objTurnLerp(
                              priest, slaughterviewangle,
                              1); // face the lamb coming south 313
                        } else {
                          OPENWORLD.Space.worldToLocalSurfaceObjHide(
                              priest, 4.9 - OPENWORLD.Math.random() * 0.2,
                              -1.6 + OPENWORLD.Math.randFloatSpread(0.4), 0,
                              level: 1,
                              4);
                          OPENWORLD.Space.objTurn(priest, 0);
                        }
                      }
                    }

                    sheepslaughter = await OPENWORLD.Actor.copyActor(
                        sheeporig, randomduration: 0.1, action: "eat");
                    //  OPENWORLD.Space.resetPosRot(sheep12);
                    OPENWORLD.Space.worldToLocalSurfaceObjHide(
                        sheepslaughter, sheepfinalposx, sheepfinalposy, 0,
                        //3.78+0.02+0.03, 0.72+0.02, 0,
                        4,
                        level: 1); // 2.89, 0.71+0.13,0,3);//1.06+0.13,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
                    _hotload.add(sheepslaughter);

                    OPENWORLD.Space.objTurn(
                        sheepslaughter.children[0], 180); // Why this be done
                    OPENWORLD.Space.objTurn(
                        sheepslaughter.children[1], 180); // Why this be done
                    //  OPENWORLD.Space.objTurn(sheep.children[0], 0);
                    //  OPENWORLD.Space.objTurn(sheep.children[1], 0);
                    //  OPENWORLD.Space.objTurn(sheep, 90+OPENWORLD.Math.randFloatSpread(95));
                    OPENWORLD.BaseObject.setVisible(
                        sheepslaughter, true, groupname: "collar");

                    priestgetlamb = await OPENWORLD.Actor.copyActor(
                        OPENWORLD.Math.randPick(priestlist),
                        randomduration: 0.1, action: "squatwork");

                    _hotload.add(priestgetlamb);
                    OPENWORLD.Space.worldToLocalSurfaceObjHide(
                        priestgetlamb, sheepfinalposx, sheepfinalposy - 0.06, 0,
                        level: 1, 4); //, 2.30,4.24-level: 2, 4);
                    OPENWORLD.Space.objTurn(priestgetlamb, 0);

                  //  Future.delayed(Duration(milliseconds: 10000), () async {
                    callwhenloaded(() {
                      lambslaughter();
                    });
                  //  });
                  }

                  if (gamestart == GameStart.hearth &&
                      gamestartpos[gamestart]['progress'].contains('getlamb')) {
                    print("lambslaughterreset start");
                    // if have gotten the lamb then start the lamb slaughter
                    lambslaughterreset();
                  } else {

                    // Get the lamb and place at the slaughter position
                    getlamb() async
                    {
                      saveGameState('tamidlottery');
                      OPENWORLD.Config.updatePoolObjects();
                      friendhearth.extra['followhearth'] = true;
                      var v = 0.03;

                      OPENWORLD.Mob.moveTo(
                          superintendent,
                          [
                            [4.89, -1.44, 0, 0.02],
                            [meetupposy, meetupposy, 0.02]
                            // [5, -0.97, 0, 0.02],
                            //    [4.88, 0.69,0,0.02],
                            //    [4.73, 0.69,0,0.02]//4.97,0.69,0,0.02]
                          ],
                          level: 1,
                          action: "walkhandright",
                          stopaction: "idlehold",
                          actionrandomduration: 0.1,
                          surfaceonly: true,
                          callbackonfinish: (actor) {
                            //  /()OPENWORLD.Space.objTurnLerp(superintendent, 90, 1);
                            OPENWORLD.Space.objTurnLerp(
                                superintendent, 270, 1, delay: 4);
                          }

                      );
                      for (var priest in priestlots) {
                        priest.extra['dist'] =
                            OPENWORLD.Space.getDistanceBetweenObjs2D(priest, Glob.doornicanornorth); // Cheat just get dist to nicanor door

                      }
                      priestlots.sort((a, b) {
                        num distA = a.extra['dist'] ?? 0;
                        num distB = b.extra['dist'] ?? 0;
                        //   return distB.compareTo(distA);
                        return distA.compareTo(distB);
                      });
                      for (var i = 0; i < priestlots.length; i++) {
                        var priest = priestlots[i];
                        if (priest != friendhearth) {
                          if (i >= priesttamidneeded) { //priestlots.length / 2) {
                            // Half the priests stay in the chamber of the hearth
                            OPENWORLD.Mob.moveTo(
                                priest,
                                [[hewnstonelotposx + OPENWORLD.Math.randFloatSpread(0.2), hewnstonelotposy + OPENWORLD.Math.randFloatSpread(0.1), 0, 0.02
                                  ]
                                ],
                                level: 1,
                                action: "walk",
                                stopaction: "idle",
                                actionrandomduration: 0.1,
                                surfaceonly: true,
                                delay: 10 + i + OPENWORLD.Math.random(),
                                callbackonfinish: (actor) {
                                  OPENWORLD.Space.objTurnLerp(actor, 0, 1);
                                  //    OPENWORLD.Space.faceObjectLerp(actor, superintendent, 1);
                                }


                            );
                          } else {
                            // Half go the altar
                            var rnd = OPENWORLD.Math.randFloatSpread(0.2);
                            OPENWORLD.Mob.moveTo(
                                priest,
                                [
                                  [4.91 + rnd, -1.44, 0, 0.02],
                                  //   [5, -0.97, 0, 0.02],
                                  [4.97 + rnd, 0.84 - i * 0.03, 0, v]
                                ],
                                level: 1,
                                action: "walk",
                                stopaction: "idle",
                                actionrandomduration: 0.1,
                                surfaceonly: true,
                                delay: i + OPENWORLD.Math.random(),
                                callbackonfinish: (actor) {
                                  OPENWORLD.Space.faceObjectLerp( actor, superintendent, 1);
                                }
                            );
                          }
                        }
                      }
                      OPENWORLD.Mob.setSpeech(friendhearth, [
                        "Now we'll get the lamb.",
                        "If there is enough daylight",
                        "a lamb is brought to the court",
                      ], z: 80,
                          width: 300,
                          scale: 0.2,
                          randwait: 0,
                          clearwhendone: true);
                      Future.delayed(Duration(milliseconds: 6000), () async {
                        // Check if there is enough daylight
                        var friendpos = OPENWORLD.Space.localToWorldObj(friendhearth);
                        OPENWORLD.Mob.moveToLoop(
                          friendhearth,
                          [
                            {"p": [friendpos.x, friendpos.y, 0], "v": 0.02},
                            {"p": [4.89, -1.44, 0], "v": 0.02},
                            //{"p": [5, -0.97, 0], "v": 0.02},
                            // {"p": [4.97,0.69, 0], "v": 0.02},
                            {"p": [ 4.81 - 0.08, 0.82, 0], "v": v},

                            {
                              "action": "idle3",
                              "t": 270,
                              "time": 5,
                              "callback": (actor) async {
                                // Now that have reached spot near rings, ask if its bright enough
                                var priestlookout = await OPENWORLD.Actor.copyActor(OPENWORLD.Math.randPick(priestlist),
                                    randomduration: 0.1);

                                _hotload.add(priestlookout);
                                OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                    priestlookout, 2.27, 2.24, 4.24 - 3.53,
                                    level: 1,
                                    4); //, 2.30,4.24-level: 2, 4);

                                print('priest on roof');
                                //priestlots.add(priest);
                                OPENWORLD.Space.faceObject(
                                    priestlookout, friendhearth);

                                friendhearth.extra['followhearth'] = false;

                                for (var i = 0; i < priesttamidneeded; i++) { //priestlots.length/2; i++) {
                                  var priest = priestlots[i];
                                  if (priest != friendhearth)
                                    OPENWORLD.Space.objTurnLerp(priest, 270, 1);
                                }

                                if (friendisclose())
                                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                    threeJs.camera, 4.95 - 0.08, 0.76,
                                    //5.04, -1.79,// 5.04, -1.83,
                                    OPENWORLD.Camera.cameraoffset, 1, level: 1);
                                if (friendisclose())
                                  OPENWORLD.Space.worldToLocalSurfaceObj(
                                    threeJs.camera, 4.95 - 0.08, 0.76,
                                    //5.04, -1.79,// 5.04, -1.83,
                                    OPENWORLD.Camera.cameraoffset, level: 1,
                                    delay: 1);
                                if (friendisclose())
                                  OPENWORLD.Space.objTurnLerp(
                                    threeJs.camera, 270, 1);
                                // OPENWORLD.Space.faceObjectLerp(threeJs.camera, friendhearth, 1,delay:1);
                                OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 1);

                                OPENWORLD.Space.faceObjectLerp( friendhearth, priestlookout, 1, delay: 4); // look at the lookout
                                //  OPENWORLD.Space.objTurnLerp(friendhearth,270,1,delay:4);  // look at the observer
                                OPENWORLD.Actor.playAction(
                                    friendhearth, action: "lookup", delay: 5);
                                // Ask if enough light
                                var chat = [
                                  {0: "Go out and see whether the time"},
                                  {0: "for slaughtering has arrived."},
                                  {1: "It is bright!"},
                                  {0: "As far as Hebron?"},
                                  {1: "Yes"},
                                ];
                                var priestlookoutchatarr = createChat(chat);
                                var priestfriendhearthchatter = priestlookoutchatarr[0];
                                var priestlookoutchatter = priestlookoutchatarr[1];
                                OPENWORLD.Mob.setSpeech(friendhearth,
                                    priestfriendhearthchatter, z: 80,
                                    width: 300,
                                    scale: 0.3,
                                    randwait: 0,
                                    clearwhendone: true,
                                    callbackonfinish: (actor) async {
                                      // Now that have asked if it is bright enough bring the lamb
                                      OPENWORLD.Actor.playAction(
                                          friendhearth, action: "idle3");
                                      OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 1);
                                      OPENWORLD.Mob.setSpeech(friendhearth,
                                          [ "Now a priest will bring",
                                            "a lamb to the altar",
                                            "Lets wait at the altar"
                                          ]
                                          , z: 80,
                                          width: 300,
                                          scale: 0.3,
                                          randwait: 0,
                                          clearwhendone: true,
                                          callbackonfinish: (actor) {
                                            friendhearth.extra['followhearth'] = true;
                                          },
                                          delay: 2);

                                      OPENWORLD.Space.worldToLocalSurfaceObjLerp(priestlookout, 2.27, 2.24 + 0.1,
                                          4.24 - 3.53,
                                          1, level: 1);
                                      priestgetlamb = priestlookout;
                                      var priestlambstartx = 2.86;
                                      var priestlambstarty = 1.63;
                                      var priestlambdiff = 0.06;
                                      OPENWORLD.Space.worldToLocalSurfaceObj(
                                          priestgetlamb, priestlambstartx,
                                          priestlambstarty, 0, level: 1,
                                          delay: 1);
                                      OPENWORLD.Mob.moveTo(
                                          priestgetlamb,
                                          [
                                            [3.81, 1.61, 0, v],
                                            // corner of santuary stairs
                                            [3.76, sheepfinalposy, 0, v],
                                            [
                                              sheepfinalposx,
                                              sheepfinalposy - priestlambdiff,
                                              0,
                                              0.02
                                            ],
                                            //3.78, 0.76,0,v],//3.81,0.67, 0,v],
                                            ///                                [3.78+0.02+0.03+0.02, 0.72-priestlambdiff,0,0.02],//3.78, 0.76,0,v],//3.81,0.67, 0,v],
                                          ],
                                          level: 1,
                                          action: "walkhandright",
                                          stopaction: "squatwork",
                                          surfaceonly: true,
                                          callbackonfinish: (actor) {},
                                          delay: 2);
                                      //  OPENWORLD.Space.faceObjectAlways(friendhearth,priestlamb,delay:10);

                                      sheepslaughter = await OPENWORLD.Actor.copyActor(sheeporig, randomduration: 0.1,);
                                      //  OPENWORLD.Space.resetPosRot(sheep12);
                                      OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                          sheepslaughter,
                                          priestlambstartx - priestlambdiff,
                                          priestlambstarty, 0,
                                          4,
                                          level: 1); // 2.89, 0.71+0.13,0,3);//1.06+0.13,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
                                      _hotload.add(sheepslaughter);

                                      OPENWORLD.Space.objTurn(
                                          sheepslaughter.children[0],
                                          180); // Why this be done
                                      OPENWORLD.Space.objTurn(
                                          sheepslaughter.children[1],
                                          180); // Why this be done
                                      //  OPENWORLD.Space.objTurn(sheep.children[0], 0);
                                      //  OPENWORLD.Space.objTurn(sheep.children[1], 0);
                                      //  OPENWORLD.Space.objTurn(sheep, 90+OPENWORLD.Math.randFloatSpread(95));
                                      OPENWORLD.BaseObject.setVisible(
                                          sheepslaughter, true,
                                          groupname: "collar");
                                      OPENWORLD.Mob.moveTo(
                                          sheepslaughter,
                                          [
                                            [3.81, 1.61, 0, v],
                                            // corner of santuary stairs
                                            [3.76, sheepfinalposy, 0, v],
                                            [
                                              sheepfinalposx,
                                              sheepfinalposy,
                                              0,
                                              0.02
                                            ],
                                          ],
                                          level: 1,
                                          action: "walk",
                                          stopaction: "eat",
                                          stopactionduration: 6,
                                          surfaceonly: true,
                                          callbackonfinish: (actor) {
                                            OPENWORLD.Space.faceObjectLerp( priestgetlamb, sheepslaughter, 1);
                                            OPENWORLD.Space.faceObjectLerp( sheepslaughter, priestgetlamb, 1);
                                            lambslaughter();
                                          },
                                          delay: 2);
                                    },
                                    delay: 7);
                                // Lookout speeks from roof
                                OPENWORLD.Mob.setSpeech(priestlookout,
                                    priestlookoutchatter, z: 90,
                                    width: 500,
                                    scale: 2,
                                    randwait: 0,
                                    clearwhendone: true,
                                    delay: 7 - 4);
                              }
                            },
                            {"time": 40},
                            {"p": [3.98, 0.51, 0], "v": v, "callback": (actor) {
                              //print("at corner of altar");
                              // Have reached the spot at the altar near the ring where the sheep will be slaughtered
                              friendhearth.extra['followhearth'] = false;

                              if (friendisclose())
                                OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                  threeJs.camera, 4.08, 0.49,
                                  //5.04, -1.79,// 5.04, -1.83,
                                  OPENWORLD.Camera.cameraoffset, 1, level: 1);
                              if (friendisclose())
                                OPENWORLD.Space.objTurnLerp(
                                  threeJs.camera, slaughterviewangle,
                                  1); //313 face the lamb coming south
                              // Have the 6 priests line up along the altar
                              for (var i = 0; i < priesttamidneeded; i++) { //priestlots.length/2; i++) {
                                var priest = priestlots[i];
                                if (priest != friendhearth) {
                                  OPENWORLD.Mob.moveTo(
                                      priest,
                                      [
                                        [ 4.82,0.58,0,v ],  // north east corner great altar - getlamb
                                        [
                                          4.08 + 0.02 + i * 0.05 + OPENWORLD.Math.randFloatSpread(0.01),
                                          0.49 + OPENWORLD.Math.randFloatSpread(0.01),
                                          0,
                                          v
                                        ], //3.81,0.67, 0,v],
                                      ],
                                      level: 1,
                                      action: "walk",
                                      stopaction: "idlestraight",
                                      surfaceonly: true,
                                      callbackonfinish: (actor) {
                                        OPENWORLD.Space.objTurnLerp(actor, slaughterviewangle, 1); // 313 face the lamb coming south

                                      },
                                      delay: i * 2);
                                }
                              }
                            },
                            },
                            { "action": "idle3", "t": slaughterviewangle, "time": 5 }//313
                          ], action: "walk", //handright",
                          // stopaction: "idle",
                          surfaceonly: true,
                          level: 1,
                          looptype: OPENWORLD.Mob.LoopTypeStop,
                        );
                        if (friendisclose())
                          OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1, delay: 9);

                        for (var i = 0; i < 10; i++) {
                          var securitypriest = securitylist[i];
                          if (securitypriest != superintendent) {
                            OPENWORLD.Mob.moveTo(
                                securitypriest,
                                [
                                  [4.92, -1.61, 0, 0.02],
                                  [4.89, -1.44, 0, 0.02],
                                  //   [5, -0.97, 0, 0.02],
                                  [
                                    meetupposx +
                                        OPENWORLD.Math.randFloatSpread(0.2),
                                    meetupposy +
                                        OPENWORLD.Math.randFloatSpread(0.4),
                                    0,
                                    0.02
                                  ]
                                ],
                                level: 1,
                                action: "walk",
                                stopaction: "idle",
                                actionrandomduration: 0.1,
                                surfaceonly: true,
                                delay: 4 + i + OPENWORLD.Math.random(),
                                callbackonfinish: (actor) {
                                  OPENWORLD.Space.objTurnLerp(actor, 270, 1);
                                  //    OPENWORLD.Space.objTurnLerp(superintendent, 270, 1);
                                }


                            );
                          }
                        }
                      });
                    }

                    // start of getting the lamb where you check if enough light - starting off hewnstone after the lottery
                    getlambreset() async {
                      OPENWORLD.Time.setTimeLerp(7, 60, onlyifover: true);
                      Glob.createTamidCourtCrowd!(50, 30); //,270);

                      doorssetopen();

                      OPENWORLD.Space.worldToLocalSurfaceObj(
                          threeJs.camera, 4.96, -1.58 - 0.01,
                          OPENWORLD.Camera.cameraoffset, level: 1);

                      OPENWORLD.Space.removeFaceObjectAlways(superintendent);
                      OPENWORLD.Space.worldToLocalSurfaceObjHide(
                          superintendent, hewnstonelotposx, hewnstonelotposy, 0,5,  // why did you have it as 1 instead of 5
                          level: 1);
                      OPENWORLD.Space.objTurn(superintendent, 270);
                      OPENWORLD.Actor.playAction(
                          superintendent, action: "idlehold",
                          randomduration: 0.1);
                      OPENWORLD.Space.faceObject(
                          threeJs.camera, superintendent);

                      await general();

                      OPENWORLD.Space.worldToLocalSurfaceObjHide(
                          friendhearth, 4.86, -1.77 + 0.04, 0, level: 1, 4);

                      OPENWORLD.Space.faceObject(
                          friendhearth, threeJs.camera);
                      OPENWORLD.Actor.playAction(
                          friendhearth, action: "idle",
                          randomduration: 0.1);

                      var priestpickedlist=[];
                      for (var i = 0; i < 4; i++) {
                        var priestpicked=OPENWORLD.Math.randPick(priestlist,exclude:priestpickedlist);
                        var priest = await OPENWORLD.Actor.copyActor(priestpicked, randomduration: 0.1);
                        priestpickedlist.add(priestpicked);
                        priest.extra['clothed']=priestpicked.extra['clothed'];

                        _hotload.add(priest);
                        OPENWORLD.Space.worldToLocalSurfaceObjHide(
                            priest, 4.2 - OPENWORLD.Math.random() * 0.2,
                            0 + OPENWORLD.Math.randFloatSpread(0.4), 0,
                            level: 1,
                            4);
//                  priest, 3.89+OPENWORLD.Math.randFloatSpread(0.4),-1.24+OPENWORLD.Math.randFloatSpread(0.4), 0, level: 1, 4);
                        priestlots.add(priest);
                        OPENWORLD.Space.objTurn(priest, 90);
                      }


                      for (var i = 0; i < priestlots.length; i++) {
                        var priest = priestlots[i];
                        OPENWORLD.Actor.removeObjectFromPlayActionsLoop(priest);
                        OPENWORLD.Space.worldToLocalSurfaceObjHide(
                            priest,
                            hewnstonelotposx + poshewstonelotsdiff[i][0] * 0.07,
                            hewnstonelotposy + poshewstonelotsdiff[i][1] * 0.07,
                            0,
                            level: 1, 4);
                        OPENWORLD.Space.faceObject(priest, superintendent);
                        var newpos = OPENWORLD.Math.vectorMoveForward(
                            hewnstonelotposx + poshewstonelotsdiff[i][0] * 0.07,
                            hewnstonelotposy + poshewstonelotsdiff[i][1] * 0.07,
                            OPENWORLD.Space.getObjTurn(priest) - 180, 0.08);
                        OPENWORLD.Space.worldToLocalSurfaceObjHide(
                            priest, newpos.x, newpos.y, 0,
                            level: 1, 4);
                        OPENWORLD.Actor.playAction(
                            priest, action: "idle",
                            randomduration: 0.1);
                      }

                      var prevlist = [];
                      var meetuposs = [];
                      //   prevlist.add([meetupposx, meetupposy,0,0.02]);
                      // prevlist.add([startterumatposx,startterumatposy,0,0.02]);
                      for (var i = 0; i < securitylist.length; i++) {
                        var nextpos = nextdonthit(
                            prevlist, meetupposx, 0.2, meetupposy, 0.4, 0.05);
                        meetuposs.add([nextpos[0], nextpos[1], 0, 0.02]);
                        prevlist.add(nextpos);
                      }

                      // Place the priests outside the chitveh
                      for (var i = 10; i < securitylist.length; i++) {
                        var securitypriest = securitylist[i];
                        if (securitypriest != superintendent) {
                          OPENWORLD.Actor.playAction(
                              securitypriest, action: "idle3",
                              randomduration: 0.1);
                          if (securitypriest != friendhearth) {
                            OPENWORLD.Space.worldToLocalSurfaceObj(
                                securitypriest, meetuposs[i][0],
                                meetuposs[i][1],
                                0,
                                level: 1); //meetupposx+diffx,meetupposy-diffy-0.1, 0,  level: 1);//,5);


                            OPENWORLD.Space.faceObject(
                                securitypriest, superintendent);
                          }
                        }
                      }

                      for (var i = 0; i < 10; i++) {
                        var securitypriest = securitylist[i];
                        if (securitypriest != superintendent) {
                          var westside = OPENWORLD.Math.random() < 0.5;
                          var finalpos = [];
                          if (westside)
                            finalpos = [
                              4.58 + OPENWORLD.Math.random() * 0.1,
                              -1.64 + OPENWORLD.Math.randFloatSpread(0.2)
                            ]; // west side
                          else
                            finalpos = [
                              5.32 - OPENWORLD.Math.random() * 0.1,
                              -1.64 + OPENWORLD.Math.randFloatSpread(0.2)
                            ]; // eastside
                          OPENWORLD.Space.worldToLocalSurfaceObj(
                              securitypriest, finalpos[0], finalpos[1], 0,
                              level: 1); //meetupposx+diffx,meetupposy-diffy-0.1, 0,  level: 1);//,5)

                          OPENWORLD.Space.faceObject(
                              securitypriest, superintendent);
                        }
                      }


                      //Future.delayed(Duration(milliseconds: 10000), () async {
                      callwhenloaded(() {
                        getlamb();
                      });
                      //});
                    }

                    if (gamestart == GameStart.hearth && gamestartpos[gamestart]['progress'].contains('tamidlottery')) {
                      print("getlambreset start");
                      // If have done the tamid lottery then start getting the lamb to the slaughter position
                      getlambreset();
                    } else {
                      // Do the tamid lottery in the chamber of the hewnstone
                      tamidlottery() async
                      {
                        saveGameState('opendoors');
                        OPENWORLD.Config.updatePoolObjects();
                        friendhearth.extra['followhearth'] = true;
                        // Add more priests as 8 isn't enough!
                        // Looks like your placing them on the altar
                        var priestpickedlist=[];
                        for (var i = 0; i < 4; i++) {
                          var priestpicked=OPENWORLD.Math.randPick(priestlist,exclude:priestpickedlist);
                          var priest = await OPENWORLD.Actor.copyActor(priestpicked, randomduration: 0.1);
                          priestpickedlist.add(priestpicked);
                          priest.extra['clothed']=priestpicked.extra['clothed'];
                          _hotload.add(priest);
                          OPENWORLD.Space.worldToLocalSurfaceObjHide(
                              priest, 4.2 - OPENWORLD.Math.random() * 0.2,
                              0 + OPENWORLD.Math.randFloatSpread(0.4), 0,
                              level: 1,
                              4);
                          priestlots.add(priest);
                          OPENWORLD.Space.objTurn(priest, 90);
                        }
                        for (var priest in priestlots)
                          OPENWORLD.Actor.unwield(priest, "Bip01_R_Hand");  // Some priests are still wielding when do the tamid lottery


                        OPENWORLD.Space.faceObjectLerp(friendhearth,threeJs.camera,1,delay:5);
                        OPENWORLD.Mob.setSpeech(friendhearth, [
                          "While the priests",
                          "continue preparing the",
                          "altar we can check the",
                          "chamber of the hewn stone.",
                          "Lets go"
                        ], z: 80,
                            width: 300,
                            scale: 0.2,
                            randwait: 0,
                            clearwhendone: true,
                            callbackonfinish: (actor) {
                              OPENWORLD.Actor.unwield(friendhearth, "Bip01_R_Hand", delay: 1);
                              var friendpos = OPENWORLD.Space.localToWorldObj(friendhearth);

                              // Now that have finished speech go to the chamber of the hewnstone
                              OPENWORLD.Mob.moveToLoop(
                                friendhearth,
                                [
                                  { "p": [friendpos.x, friendpos.y, 0], "v": 0.03 },
                                  {"p": [4.91, -1.42, 0], "v": 0.03}, // doorway
                                  {
                                    "p": [ 5.01, -1.71, 0],
                                    "v": 0.03,
                                    "callback": (
                                        actor) { //5.02, -1.76, 0],"v":0.03,
                                      // Now that at the chamber of the hewnstone priests should start coming in
                                      friendhearth.extra['followhearth'] = false;
                                      if (friendisclose())
                                        OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, 5.07, -1.71, OPENWORLD.Camera.cameraoffset, 1, level: 1);
                                      if (friendisclose())
                                        OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, 5.04, -1.79, OPENWORLD.Camera.cameraoffset, 1, level: 1, delay: 1);
                                      if (friendisclose())
                                        OPENWORLD.Space.objTurnLerp(
                                          threeJs.camera, 339, 1, delay: 2);
                                      OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 3);
                                      OPENWORLD.Mob.setSpeech(friendhearth, [
                                        "This next lottery",
                                        "is for slaughtering",
                                        "the lamb. We should both",
                                        "take part in it this time.",
                                      ], z: 80,
                                          width: 300,
                                          scale: 0.2,
                                          randwait: 0,
                                          clearwhendone: true,
                                          callbackonfinish: (actor) {
                                            OPENWORLD.Space.objTurnLerp(
                                                friendhearth, 339,
                                                1);
                                            OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 15);
                                            OPENWORLD.Space.faceObjectLerp( friendhearth, priestkey, 1, delay: 20);
                                            OPENWORLD.Space.faceObjectLerp( friendhearth, superintendent, 1, delay: 30);
                                          },
                                          delay: 4
                                      );

                                      inc = 0;
                                      for (var i = 0; i < 10; i++) {
                                        var securitypriest = securitylist[i];
                                        if (securitypriest != superintendent &&
                                            securitypriest != priestkey) {
                                          var finalpos;
                                          var westside = OPENWORLD.Math
                                              .random() <
                                              0.5;
                                          if (westside)
                                            finalpos = [
                                              4.58 + OPENWORLD.Math.random() * 0.1, -1.64 + OPENWORLD.Math.randFloatSpread(0.2),
                                              0,
                                              0.02
                                            ]; // west side
                                          else
                                            finalpos = [
                                              5.32 -  OPENWORLD.Math.random() * 0.1, -1.64 + OPENWORLD.Math.randFloatSpread(0.2),
                                              0,
                                              0.02
                                            ]; // eastside
                                          OPENWORLD.Mob.moveTo(
                                              securitypriest,
                                              [
                                                [
                                                  // right at door of hewnstone
                                                  4.91 + OPENWORLD.Math.randFloatSpread(0.02),
                                                  -1.42 + OPENWORLD.Math.randFloatSpread(0.02),
                                                  0,
                                                  0.02
                                                ],
                                                [
                                                  4.96 + OPENWORLD.Math.randFloatSpread(0.02),
                                                  -1.71 + 0.02 + OPENWORLD.Math.randFloatSpread(0.01),
                                                  0,
                                                  0.02
                                                ],
                                                finalpos
                                              ],
                                              action: "walk",
                                              stopaction: OPENWORLD.Math
                                                  .random() <
                                                  0.3 ? "wave" : "idle",
                                              actionrandomduration: 0.1,
                                              surfaceonly: true,
                                              callbackonfinish: (actor) {
                                                OPENWORLD.Space.faceObjectLerp( actor, westside ? superintendent : priestkey, 1);
                                                OPENWORLD.Actor.playAction(
                                                    actor, action: "idle3",
                                                    delay: 1);
                                                OPENWORLD.Space.faceObjectLerp( actor, friendhearth, 1, delay: OPENWORLD.Math .random() * 5);
                                              },
                                              level: 1,
                                              delay: inc * 5
                                          );
                                          inc++;
                                        }
                                      }

                                      // inc = 0;

                                      // moving all priests back to chamber of hewnstone from altar
                                      for (var i = 0; i < priestlots.length; i++) {
                                        var priest = priestlots[i];
                                        var finalpos = [
                                          hewnstonelotposx + poshewstonelotsdiff[i][0] * 0.07,
                                          hewnstonelotposy + poshewstonelotsdiff[i][1] * 0.07,
                                          0,
                                          0.02
                                        ];
                                        OPENWORLD.Mob.moveTo(
                                            priest,
                                            [
                                              [4.3, -0.28, 0, 0.025],
                                              // top of ramp
                                              [4.3, -1.3, 0, 0.025],
                                              //bottom of ramp
                                              [4.92, -1.3, 0, 0.025],
                                              [
                                                // right at door of hewnstone
                                                4.91 + OPENWORLD.Math.randFloatSpread(0.02),
                                                -1.42 + OPENWORLD.Math.randFloatSpread(0.02),
                                                0,
                                                0.02
                                              ],
                                              [
                                                // inside door of hewnstone
                                                4.96 + OPENWORLD.Math.randFloatSpread(0.02),
                                                -1.53 + OPENWORLD.Math.randFloatSpread(0.02),
                                                0,
                                                0.02
                                              ],
                                              finalpos
                                            ],
                                            action: "walk",
                                            stopaction: "idle",
                                            actionrandomduration: 0.1,
                                            surfaceonly: true,
                                            callbackonfinish: (actor) {
                                              OPENWORLD.Space.facePointLerp(
                                                  actor, hewnstonelotposx,
                                                  hewnstonelotposy, 1);
                                              if (actor == priestlots[0]) {
                                                // Superintenent moves to the center of the circle

                                                var friendpos = OPENWORLD.Space.localToWorldObj(superintendent);
                                                List<Map> actions = [
                                                  { "p": [ friendpos.x, friendpos.y, 0 ], "v": 0.02 },
                                                  {
                                                    "p": [
                                                      hewnstonelotposx,
                                                      hewnstonelotposy,
                                                      0
                                                    ],
                                                    "v": 0.02,
                                                    "callback": (actor) {
                                                      // OPENWORLD.Actor.wield(friendhearth, turbanwield, "Bip01_R_Hand",delay:1);
                                                    }
                                                  },
                                                ];

                                                // Lottery for the tamid
                                                actions = lotteryactions(actions, 180,
                                                        priestlots[priestlots.length - 3 - 4],
                                                        270, priestlots[priestlots.length - 5 - 4]);
                                                //    actions=lotteryactions(actions,180, priestlots[5],270,priestlots[3]);
                                                //  actions=lotteryactions(actions,180, priestlots[priestlots.length-3],270,priestlots[priestlots.length-5]);
                                                actions.add({"time": 10,
                                                  "callback": (actor) {
                                                    // This is just for the superintendent not for every priest - this is the end of the lottery
                                                    Glob.createTamidCourtCrowd!(
                                                        50, 30); //,270);
                                                    // if (OPENWORLD.Time.time<7)
                                                    OPENWORLD.Time.setTimeLerp(7, 60, onlyifover: true);
                                                    getlamb();
                                                  }
                                                });

                                                OPENWORLD.Mob.moveToLoop(
                                                  superintendent,
                                                  actions,
                                                  level: 1,
                                                  action: "walkhandright",
                                                  randomduration: 0.1,
                                                  looptype: OPENWORLD.Mob.LoopTypeStop,
                                                  surfaceonly: true,
                                                );

                                                OPENWORLD.Mob.setSpeech(
                                                    friendhearth, [
                                                  "Lets join",
                                                  "the lottery"
                                                ], z: 80,
                                                    width: 300,
                                                    scale: 0.2,
                                                    randwait: 0,
                                                    clearwhendone: true,
                                                    delay: 1);
                                                OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1);

                                                // Your friend takes his place in the circle
                                                OPENWORLD.Mob.moveTo(
                                                    friendhearth,
                                                    [[4.86, -1.77 + 0.04, 0, 0.02]],
                                                    level: 1,
                                                    action: "walk",
                                                    //handright",
                                                    stopaction: "idle",
                                                    actionrandomduration: 0.1,
                                                    surfaceonly: true,
                                                    delay: 5,
                                                    callbackonfinish: (actor) {
                                                      OPENWORLD.Space
                                                          .facePointLerp(
                                                          friendhearth,
                                                          hewnstonelotposx,
                                                          hewnstonelotposy, 1);
                                                    }

                                                );
                                                // You take your place in the circle
                                                if (friendisclose())
                                                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                                    threeJs.camera, 4.96,
                                                    -1.58 - 0.01,
                                                    OPENWORLD.Camera
                                                        .cameraoffset,
                                                    1,
                                                    level: 1, delay: 6);
                                                if (friendisclose())
                                                  OPENWORLD.Space.facePointLerp(
                                                    threeJs.camera,
                                                    hewnstonelotposx,
                                                    hewnstonelotposy, 1,
                                                    delay: 7);
                                              }
                                            },
                                            level: 1,
                                            delay: i * 4
                                        );
                                        //  inc++;
                                      }
                                    }
                                  },

                                  {"action": "idle3", "t": 270}
                                ], action: "walk", //handright",
                                // stopaction: "idle",
                                surfaceonly: true,
                                level: 1,
                                looptype: OPENWORLD.Mob.LoopTypeStop,

                              );
                            }
                        );
                      }


                      // Allow to resume opendoors
                      //  This is used twice to place priests at the chitveh
                      opendoorsreset() async {
                        print('opendoors start');
                        OPENWORLD.Space.worldToLocalSurfaceObj(
                            threeJs.camera, opendoorsstartposx,
                            opendoorsstartposy,
                            OPENWORLD.Camera.cameraoffset, level: 1);
                        OPENWORLD.Space.objTurn(threeJs.camera, 280);
                        //OPENWORLD.Space.faceObjectLerp(friendhearth,threeJs.camera,1);
                        OPENWORLD.Actor.wield(
                            friendhearth, torch, "Bip01_R_Hand");
                        addflametotorch(torch, true);

                        //OPENWORLD.Space.faceObjectLerp(threeJs.camera,friendhearth,1);
                        OPENWORLD.Actor.playAction(
                            friendhearth, action: "idlehold");
                        OPENWORLD.Space.worldToLocalSurfaceObj(
                            priestkey, meetupposx, meetupposy, 0, level: 1);
                        OPENWORLD.Space.objTurn(priestkey, 180);
                        OPENWORLD.Actor.playAction(
                            priestkey, action: "idlehold");
                        var torch2 = torch.clone();
                        OPENWORLD.Actor.wield(
                            priestkey, torch2, "Bip01_R_Hand", delay: 2);
                        addflametotorch(torch2, false);

                        await general();
                        // print("priestlotsa len"+priestlots.length.toString());
                        var prevlist = [];
                        var meetuposs = [];
                        //   prevlist.add([meetupposx, meetupposy,0,0.02]);
                        // prevlist.add([startterumatposx,startterumatposy,0,0.02]);
                        for (var i = 0; i < securitylist.length; i++) {
                          var nextpos = nextdonthit(
                              prevlist, meetupposx, 0.2, meetupposy, 0.4, 0.05);
                          meetuposs.add([nextpos[0], nextpos[1], 0, 0.02]);
                          prevlist.add(nextpos);
                        }

                        // Place the priests outside the chitveh
                        for (var i = 0; i < securitylist.length; i++) {
                          var securitypriest = securitylist[i];

                          OPENWORLD.Actor.playAction(
                              securitypriest, action: "idle3",
                              randomduration: 0.1);
                          if (securitypriest != friendhearth &&
                              securitypriest != priestkey) {
                            OPENWORLD.Space.worldToLocalSurfaceObj(
                                securitypriest, meetuposs[i][0],
                                meetuposs[i][1],
                                0,
                                level: 1); //meetupposx+diffx,meetupposy-diffy-0.1, 0,  level: 1);//,5);


                            //  OPENWORLD.Space.faceObject(securitypriest,friendhearth);
                          }
                        }
                        // have those priests face eachother
                        for (var i = 0; i < securitylist.length; i++) {
                          var closestind = -1;
                          var closestdist = 9999.0;
                          for (var j = 0; j < securitylist.length; j++) {
                            if (j != i) {
                              var dist = OPENWORLD.Space
                                  .getDistanceBetweenObjs2D(
                                  securitylist[i], securitylist[j]);
                              if (dist < closestdist) {
                                closestdist = dist;
                                closestind = j;
                              }
                            }
                          }
                          OPENWORLD.Space.faceObjectLerp( securitylist[i], securitylist[closestind], 1, delay: OPENWORLD.Math.random() * 4);
                        }

                        for (var i = 0; i < priestlots.length; i++) {
                          // Have priests doing their jobs on the ramp
                          OPENWORLD.Space.worldToLocalSurfaceObj(
                              priestlots[i], priestaltarposs[i][0],
                              priestaltarposs[i][1],
                              0, level: 1);
                          OPENWORLD.Space.objTurn(
                              priestlots[i], OPENWORLD.Math.random() * 360);
                          var v = 0.02;
                          List<Map> actions = [];
                          actions.add({ "p": [ priestaltarposs[i][0] + OPENWORLD.Math.randFloatSpread(0.02), priestaltarposs[i][1] + OPENWORLD.Math.randFloatSpread(0.02), 0 ], "v": v },); //go to your work pos
                          for (var j = 0; j < 4; j++) {
                            actions.add(
                                { "action": OPENWORLD.Math.randPick( ["stoopidle", "work", "squatwork"]), "time": 8 + OPENWORLD.Math.random() * 4 });
                            actions.add({ "p": [ priestaltarposs[i][0] + OPENWORLD.Math.randFloatSpread(0.02), priestaltarposs[i][1] + OPENWORLD.Math.randFloatSpread(0.02), 0 ], "v": v },); //go to your work pos
                          }
                          actions.add(
                              { "action": OPENWORLD.Math.randPick( ["stoopidle", "work", "squatwork"]), "time": 8 + OPENWORLD.Math.random() * 4 });

                          OPENWORLD.Mob.moveToLoop(
                            priestlots[i],
                            actions,
                            action: i >= 4 ? "walk" : "walkhandright",
                            level: 1,
                            //  stopaction:"idle",
                            //  reset:true,
                            randomduration: 0.1,
                            looptype: OPENWORLD.Mob.LoopTypeStop,
                            surfaceonly: true,

                            //   delay:10+i*(10+OPENWORLD.Math.random()*10)

                          );
                        }
                        OPENWORLD.Space.worldToLocalSurfaceObjHide(
                            friendhearth, opendoorsstartposx - 0.08,
                            opendoorsstartposy + 0.03, 0, level: 1, 4);
                        //// OPENWORLD.Space.placeBeforeCamera(
                        //   friendhearth, 0.08, offset: 0.03);//, level:1);

                        OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 5);
                      }


                      // Reset game to so can restart tamidlottery
                      tamidlotteryreset() async {
                        await opendoorsreset();
                        doorssetopen();

                        // Why doesn't this work - cannot get superintendent to face 90 or idlehold
                        OPENWORLD.Space.removeFaceObjectAlways(superintendent);
                        OPENWORLD.Space.worldToLocalSurfaceObjHide(
                            superintendent, 4.49, -1.67, 0, 5,//why was it hidedist 1 instead of 5
                            level: 1); //3.124, -0.35, -0.005, 4); // 3.2,2.5, 0.0);
                        OPENWORLD.Space.objTurnLerp(
                            superintendent, 90, 1, delay: 4);
                        OPENWORLD.Actor.playAction(
                            superintendent, action: "idlehold",
                            randomduration: 0.1,
                            delay: 4);

                        OPENWORLD.Space.worldToLocalSurfaceObjHide(
                            priestkey, 5.33, -1.67, 0, 1,
                            level: 1); //3.124, -0.35, -0.005, 4); // 3.2,2.5, 0.0);
                        OPENWORLD.Space.objTurn(
                            priestkey, 270);

                      //  Future.delayed(Duration(milliseconds: 20000), () async {
                        callwhenloaded(() {
                          tamidlottery();
                        });
                      //  });
                      }

                      if (gamestart == GameStart.hearth &&
                          gamestartpos[gamestart]['progress'].contains(
                              'opendoors')) {
                        // If have opened the doors then start the tamid lottery
                        print("tamidlotteryreset start");
                        tamidlotteryreset();
                      } else {
                        // Priests open the doors in the inner court after the security check
                        opendoors() {
                          saveGameState('terumat');

                          print("begin opendoors");
                          OPENWORLD.Config.updatePoolObjects();

                          // Make sure all the priest outside the hewnstone are idling and facing eachother
                          var securitystillatmeetup=[];
                          for (var i = 0; i < securitylist.length; i++) {
                            var pos = OPENWORLD.Space.localToWorldObj(securitylist[i]);
                            var dist = OPENWORLD.Math.vectorDistance(THREE.Vector3(meetupposx, meetupposy, 0.0), pos);
                            if (dist < 0.4) {
                              securitystillatmeetup.add(securitylist[i]);

                              // make
                              OPENWORLD.Actor.playAction(
                                  securitylist[i], action: "idle3",
                                  randomduration: 0.1,
                                  startat: OPENWORLD.Math.random(),
                                  delay: OPENWORLD.Math.random() * 4);
                              // Move any that are too far forward back a bit so dont block the way
                              if (pos.x<5.05)
                                OPENWORLD.Space.worldToLocalSurfaceObjLerp(securitylist[i], 5.05, pos.y,0, 1.0, level: 1);

                            }
                          }
                          for (var i=0; i<securitystillatmeetup.length; i++) {
                            // This where you pick the priest closest to the another priest and they face eachother like they're talking
                            var closestind = -1;
                            var closestdist = 9999.0;
                            for (var j = 0; j < securitystillatmeetup.length; j++) {
                              if (j!=i) {
                                var dist = OPENWORLD.Space.getDistanceBetweenObjs2D(securitystillatmeetup[i], securitystillatmeetup[j]);
                                if (dist < closestdist) {
                                  closestdist = dist;
                                  closestind = j;
                                }
                              }
                            }
                            OPENWORLD.Space.faceObjectLerp(
                                securitystillatmeetup[i], securitystillatmeetup[closestind], 1,
                                delay: OPENWORLD.Math.random() * 4);
                          }


                          friendhearth.extra['followhearth'] = true;
                          var v = 0.04;
                          OPENWORLD.Space.faceObjectLerp(friendhearth,threeJs.camera,1);
                          OPENWORLD.Mob.setSpeech(friendhearth, [
                            "We open up some gates.",
                            "I'll open the wicket by the",
                            "Nicanor gate",
                            "Lets go"
                          ], z: 80,
                              width: 300,
                              scale: 0.2,
                              randwait: 0,
                              clearwhendone: true,
                              delay:5,
                              callbackonfinish: (actor) {
                                var friendpos = OPENWORLD.Space.localToWorldObj(
                                    friendhearth);
                                OPENWORLD.Mob.moveToLoop(
                                  friendhearth,
                                  [
                                    { "p": [friendpos.x, friendpos.y, 0], "v": v },
                                    {"p": [4.98, 0.7, 0], "v": v},
                                    {
                                      "p": [5.39 + 0.01, 0.79, 0],
                                      "v": v,
                                      "callback": (actor) { //5.34, 0.85
                                        friendhearth.extra['followhearth'] = false;
                                        // Cheat and open this gate even though no one is there
                                       /* OPENWORLD.Space.objTurn(
                                            Glob.doorgoldnicanoreastgatesouth,
                                            90);*/
                                        Glob.doorwaynicanoreastgatesouth.setOpenClose(true);

                                        OPENWORLD.Space.objTurnLerp(
                                            friendhearth, 90, 1);
                                        OPENWORLD.Actor.playAction(friendhearth, action: "armsup");
                                        OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                            threeJs.camera, 5.18, 1.03,
                                            OPENWORLD.Camera.cameraoffset, 1.0,
                                            level: 1,
                                            delay: 1);
                                        //   OPENWORLD.Space.faceObjectLerp(threeJs.camera, friendhearth,1);
                                        OPENWORLD.Space.objTurnLerp(
                                            threeJs.camera, 158,
                                            1,
                                            delay: 2); //, angle, time)

                                        Future.delayed(
                                            Duration(
                                                milliseconds: 2100), () async {
                                          OPENWORLD.Actor.playAction(
                                              friendhearth, action: "walk");
                                          OPENWORLD.Actor.playAction(
                                              friendhearth, action: "idle",
                                              randomduration: 0.1,
                                              delay: 1);
                                          //     OPENWORLD.Actor.playActionThen(actor, "walk", "idle", duration:1, delay:1);
                                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                              friendhearth, 5.39 + 0.01 - 0.06,
                                              0.79,
                                              0,
                                              1.0,
                                              level: 1);
                                          // Open nicanor north
                                          OPENWORLD.Sound.play(
                                              path: 'sounds/doorlarge.mp3');
                                        /*  OPENWORLD.Space.objTurnLerp(Glob
                                              .doorgoldnicanoreastgatenorth, 90,
                                              2);*/
                                          Glob.doorwaynicanoreastgatenorth.setOpenClose(true);
                                          friendhearth.extra['followhearth'] = true;

                                          //  OPENWORLD.Space.objTurnLerp(Glob.doornicanornorth, -90,1);
                                        });
                                        //, volume: 0.2);

                                        // Cheat and open this wicket door by itself
                                        // OPENWORLD.Sound.play(
                                        //     path: 'sounds/doorlarge.mp3', delay:10);
                                        //  OPENWORLD.Space.objTurnLerp(Glob.doorgoldnicanoreastgatesouth, 90,2, delay:10);


                                        OPENWORLD.Mob.setSpeech(friendhearth, [
                                          "Now they'll open the ",
                                          "chamber of the Hewnstone",

                                        ], z: 80,
                                            width: 300,
                                            scale: 0.2,
                                            randwait: 0,
                                            clearwhendone: true,
                                            delay: 20
                                        );
                                        //This is where now that you've reached the northern nicanor wicket the superintendent and priestkey open the chamber of the hearth doors
                                        // east side hearth door
                                        var priestkeypos = OPENWORLD.Space.localToWorldObj(priestkey);
                                        OPENWORLD.Space.removeFaceObjectAlways(priestkey);
                                        OPENWORLD.Mob.moveToLoop(
                                          priestkey,
                                          [
                                            { "p": [ 4.97 - 0.1, priestkeypos.y, 0 ], "v": 0.03 },
                                            {
                                              "p": [4.97 - 0.02, -1.40, 0],
                                              "v": 0.03,
                                              "callback": (actor) {
                                                OPENWORLD.Actor.playAction(
                                                    priestkey, action: "idle");
                                              }
                                              // at hearth east door
                                            },
                                            {"time": 15},
                                            { "p": [4.97 - 0.02, -1.67, 0], "v": 0.03 },
                                            {"p": [5.33, -1.67, 0], "v": 0.03},
                                            {
                                              "action": "armsup",
                                              "time": 10,
                                              "callback": (actor) {
                                                // Light the lamp in the chamber of the hewn stone
                                                Glob.grouplamphewnstoneeast.visible = true;
                                              }
                                            },
                                            {"action": "idle", "t": 270}
                                          ], action: "walk",
                                          // stopaction: "idle",
                                          surfaceonly: true,
                                          level: 1,
                                          looptype: OPENWORLD.Mob.LoopTypeStop,
                                          // callbackonfinish: (dooropener){
                                          // OPENWORLD.Space.objTurnLerp(dooropener,0,1);
                                          // OPENWORLD.Space.faceObjectAlways(dooropener,superintendent);

                                          // },

                                        );

                                        // west side hearth door
                                        var superintendentpos = OPENWORLD.Space.localToWorldObj(superintendent);
                                        OPENWORLD.Space.removeFaceObjectAlways(superintendent);
                                        OPENWORLD.Mob.moveToLoop(
                                          superintendent,
                                          [
                                            { "p": [ 4.86 - 0.1, superintendentpos.y, 0 ], "v": 0.025 },
                                            {
                                              "p": [4.86 + 0.04, -1.40, 0],
                                              "v": 0.025,
                                              "callback": (
                                                  actor) { // at hearth west door

                                                OPENWORLD.Actor.playAction(
                                                    priestkey, action: "armsup",
                                                    delay: 1);
                                                OPENWORLD.Actor.playAction(
                                                    superintendent,
                                                    action: "armsup",
                                                    delay: 1);
                                                Future.delayed(
                                                    Duration(
                                                        milliseconds: 3100), () async {
                                                      print("open hewnstone doors");
                                                  OPENWORLD.Actor.playAction(priestkey, action: "walk");
                                                  OPENWORLD.Actor.playAction(priestkey, action: "idle",
                                                      randomduration: 0.1,
                                                      delay: 1);
                                                  //     OPENWORLD.Actor.playActionThen(actor, "walk", "idle", duration:1, delay:1);
                                                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(priestkey, 4.97,
                                                      -1.40 - 0.06, 0, 1.0, level: 1);
                                                  // Open hewn stone doors
                                                  OPENWORLD.Sound.play(path: 'sounds/doorlarge.mp3'); //, volume: 0.2);

                                                  //OPENWORLD.Space.objTurnLerp(
                                                   //   Glob.doorwoodhewnstoneeast, 0, 1);

                                                  OPENWORLD.Actor.playAction(
                                                      superintendent,
                                                      action: "walk");
                                                  OPENWORLD.Actor.playAction(
                                                      superintendent,
                                                      action: "idle",
                                                      randomduration: 0.1,
                                                      delay: 1);
                                                  //     OPENWORLD.Actor.playActionThen(actor, "walk", "idle", duration:1, delay:1);
                                                  OPENWORLD.Space
                                                      .worldToLocalSurfaceObjLerp(
                                                      superintendent, 4.86, -1.40 - 0.06,
                                                      0,
                                                      1.0, level: 1);
                                                  Glob.doorwayhewnstone.setOpenClose(true);
                                                  //OPENWORLD.Space.objTurnLerp(
                                                  //    Glob.doorwoodhewnstonewest, 0, 1);
                                                });
                                              }
                                            },
                                            {"time": 10},
                                            { "p": [4.86 + 0.04, -1.67, 0], "v": 0.025, },
                                            {"p": [4.49, -1.67, 0], "v": 0.03},
                                            {
                                              "action": "armsup",
                                              "time": 10,
                                              "callback": (actor) {
                                                // Light the lamp in the chamber of the hewn stone
                                                Glob.grouplamphewnstonewest.visible = true;
                                              }
                                            },
                                            {"action": "idle", "t": 90}
                                          ], action: "walk",
                                          //  stopaction: "idle",
                                          surfaceonly: true,
                                          level: 1,
                                          looptype: OPENWORLD.Mob.LoopTypeStop,

                                        );
                                      }
                                    },
                                    // friendhearth has reached the northern nicanor wicket
                                    {"time": 8},
                                    // friend hearth waiting at the northern nicanor wicket
                                    //{"p": [4.93, 0.082,0], "v":v},
                                    {"p": [5.00, 0.082, 0], "v": v},
                                    {
                                      "p": [friendpos.x, friendpos.y, 0],
                                      "v": v,
                                      "callback": (actor) {
                                        // Back to where you started
                                        OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 2);
                                        if (friendisclose())
                                          OPENWORLD.Space.worldToLocalSurfaceObj(
                                            threeJs.camera, opendoorsstartposx,
                                            opendoorsstartposy,
                                            OPENWORLD.Camera.cameraoffset,
                                            level: 1);
                                        if (friendisclose())
                                          OPENWORLD.Space.objTurnLerp(
                                            threeJs.camera, 280,
                                            1);
                                      }
                                    },
                                    // friend hearth now back where he started
                                    {
                                      "action": "idlehold",
                                      "time": 10,
                                      "callback": (actor) {
                                        for (var doorway in doorways)
                                          doorway.setOpenClose(true);
                                        tamidlottery();
                                      }
                                    }

                                  ],
                                  action: "walkhandright", //traight",
                                  level: 1,
                                  //  stopaction:"idle",
                                  //  reset:true,
                                  looptype: OPENWORLD.Mob.LoopTypeStop,
                                  surfaceonly: true,

                                  //   delay:10+i*(10+OPENWORLD.Math.random()*10)

                                );
                                v = 0.02;

                                var meetupposlist=[];
                                for (var priest in securitylist) {
                                  var priestpos=OPENWORLD.Space.localToWorldObj(priest);
                                  var dist=OPENWORLD.Math.vectorDistance(priestpos,THREE.Vector3(meetupposx,meetupposy,0.0));
                                  if (dist<0.3)
                                    meetupposlist.add(priest);
                                };
                                var nicanornorthpriest = OPENWORLD.Math.randPick(meetupposlist,//meetuposs,//  priestsextra,// priestgrounds,//securitylist,  if come from teramat then security list will contain priests standing on the altar so use priestgrounds
                                    exclude: [
                                      friendhearth,
                                      superintendent,
                                      priestkey
                                    ]);
                                var nicanorsouthpriest = OPENWORLD.Math.randPick(meetupposlist,//priestsextra,// priestgrounds,//  securitylist,
                                    exclude: [
                                      friendhearth,
                                      superintendent,
                                      priestkey,
                                      nicanornorthpriest
                                    ]);
                                friendpos = OPENWORLD.Space.localToWorldObj(
                                        nicanornorthpriest);
                                OPENWORLD.Mob.moveToLoop(
                                  nicanornorthpriest,
                                  [
                                    { "p": [friendpos.x, friendpos.y, 0], "v": v },
                                    {"p": [5.34, 0.455, 0], "v": v},
                                    {
                                      "p": [5.34 + 0.04, 0.455, 0],
                                      "v": v,
                                      "callback": (actor) { //5.34, 0.85
                                        OPENWORLD.Space.objTurnLerp(
                                            nicanornorthpriest, 90, 1);
                                        OPENWORLD.Actor.playAction(
                                            nicanornorthpriest,
                                            action: "armsup");

                                        Future.delayed(
                                            Duration(
                                                milliseconds: 2100), () async {
                                          OPENWORLD.Actor.playAction(
                                              nicanornorthpriest,
                                              action: "walk");
                                          OPENWORLD.Actor.playAction(
                                              nicanornorthpriest,
                                              action: "idle",
                                              randomduration: 0.1,
                                              delay: 1);

                                          //     OPENWORLD.Actor.playActionThen(actor, "walk", "idle", duration:1, delay:1);
                                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                              nicanornorthpriest,
                                              5.34 + 0.02 - 0.04,
                                              0.455,
                                              0, 1.0, level: 1);
                                          //  Open nicanor doors
                                          OPENWORLD.Sound.play(path: 'sounds/doorlarge.mp3');
                                         /* OPENWORLD.Space.objTurnLerp(
                                              Glob.doornicanornorth,
                                              90, 2);*/
                                          //  OPENWORLD.Space.objTurnLerp(Glob.doornicanornorth, -90,1);

                                          Glob.doorwaynicanor.setOpenClose(true);
                                          OPENWORLD.Actor.playAction(
                                              nicanorsouthpriest,
                                              action: "walk");
                                          OPENWORLD.Actor.playAction(
                                              nicanorsouthpriest,
                                              action: "idle",
                                              randomduration: 0.1,
                                              delay: 1);
                                          //     OPENWORLD.Actor.playActionThen(actor, "walk", "idle", duration:1, delay:1);
                                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(nicanorsouthpriest,
                                              5.34 + 0.02 - 0.04,
                                              0.28,
                                              0,
                                              1.0, level: 1);
                                         /* OPENWORLD.Space.objTurnLerp(
                                              Glob.doornicanorsouth,
                                              90, 2);*/
                                        });

                                        Future.delayed(
                                            Duration(
                                                milliseconds: 2100), () async {
                                          //  OPENWORLD.Space.objTurnLerp(Glob.doornicanornorth, -90,1);
                                        });

                                        //, volume: 0.2);

                                      }
                                    },
                                    {"time": 10},
                                    {"p": [5.34, 0.455, 0], "v": v},
                                    { "p": [friendpos.x, friendpos.y, 0], "v": v, 'callback':(actor){
                                      OPENWORLD.Actor.playAction(actor, action: "idle");

                                    }},

                                  ],
                                  action: "walk",
                                  //traight",
                                  level: 1,
                                  randomduration: 0.1,
                                  looptype: OPENWORLD.Mob.LoopTypeStop,
                                  surfaceonly: true,

                                  //   delay:10+i*(10+OPENWORLD.Math.random()*10)

                                );


                                friendpos = OPENWORLD.Space.localToWorldObj(nicanorsouthpriest);
                                OPENWORLD.Mob.moveToLoop(
                                  nicanorsouthpriest,
                                  [
                                    { "p": [friendpos.x, friendpos.y, 0], "v": v },
                                    {"p": [5.34, 0.28, 0], "v": v},
                                    {
                                      "p": [5.34 + 0.04, 0.28, 0],
                                      "v": v,
                                      "callback": (actor) { //5.34, 0.85
                                        OPENWORLD.Space.objTurnLerp(
                                            nicanorsouthpriest, 90, 1);
                                        OPENWORLD.Actor.playAction(nicanorsouthpriest, action: "armsup");
                                      }
                                    },
                                    {"time": 20},
                                    {"p": [5.34, 0.28, 0], "v": v},
                                    { "p": [friendpos.x, friendpos.y, 0], "v": v, 'callback':(actor){
                                      OPENWORLD.Actor.playAction(actor, action: "idle");

                                    }
                                    },
                                  ],
                                  action: "walk",
                                  //traight",
                                  level: 1,

                                  looptype: OPENWORLD.Mob.LoopTypeStop,
                                  randomduration: 0.1,
                                  surfaceonly: true,

                                  //   delay:10+i*(10+OPENWORLD.Math.random()*10)

                                );
                              }
                          );
                        }

                        if (gamestart == GameStart.hearth &&
                            gamestartpos[gamestart]['progress'].contains('terumat')) {
                          print("opendoorsreset start");
                          // Game restart for the opening of the doors
                          await opendoorsreset(); // This is shared
                          opendoors();
                        } else {
                          // Do the terumat
                          terumat()
                          {
                            saveGameState('security');
                            OPENWORLD.Config.updatePoolObjects();
                            var winningpriest = priestlots[3];
                            var altarposx = 4.33;
                            var altarposy = -0.22;
                            var firepanwield = firepan.clone();
                            firepanwield.scale.setValues(5.0, 5.0, 5.0);
                            //   OPENWORLD.Space.resetPosRot(firepanwield);
                            OPENWORLD.Space.setTurnPitchRoll(
                                firepanwield, 90, -90, 0);

                            var pos = OPENWORLD.Space.localToWorldObj(
                                winningpriest);

                            var v = 0.03;
                            OPENWORLD.Mob.moveToLoop(
                              winningpriest,
                              [
                                { "p": [pos.x, pos.y, 0], "v": v, "action": "walkstraight" },
                                { "p": [ 4.41, -1.33, 0], "v": v, "action": "walkstraight" },// edge of ramp
                                { "p": [ 4.14, -1.33, 0], "v": v, "action": "walkstraight" },
                                { "p": [3.66, -1.02 - 0.04, 0], "v": v, "action": "walkstraight" },// at laver
                                {"action": "work", "time": 3},
                                {"action": "worklow", "time": 3},
                                {"action": "squatwork", "time": 4},
                                {
                                  "action": "work",
                                  "time": 3,
                                  "callback": (actor) {
                                    OPENWORLD.Mob.setSpeech(friendhearth, [
                                      "Now he'll get the silver maḥtah",
                                    ], z: 80,
                                      width: 300,
                                      scale: 0.2,
                                      randwait: 0,
                                      clearwhendone: true,
                                    );
                                  }
                                },
                                { "p": [Glob.firepanposx, Glob.firepanposy, 0], "v": v, "action": "walkstraight" },
                                {
                                  "action": "stoopidle",
                                  "time": 3,
                                  "callback": (actor) {
                                    Glob.firepanground.visible = false;
                                    OPENWORLD.Space.removeObjFromHide(Glob
                                        .firepanground);
                                    OPENWORLD.Actor.wield(
                                        actor, firepanwield, "Bip01_R_Hand");
                                    OPENWORLD.Mob.setSpeech(friendhearth, [
                                      "Now he's going up to collect",
                                      "ash from the altar"
                                    ], z: 80,
                                      width: 300,
                                      scale: 0.2,
                                      randwait: 0,
                                      clearwhendone: true,
                                    );
                                  }
                                },
                                {"p": [ 4.10, -1.38, 0], "v": v},
                                {"p": [4.27, -1.38, 0], "v": v},
                                // bottom of ramp
                                {"p": [altarposx, altarposy, 0], "v": v},
                                //4.33, -0.22, 0], "v": v},   // embers
                                {
                                  "action": "squatwork",
                                  "time": 8,
                                  "callback": (actor) {
                                    OPENWORLD.Mob.setSpeech(friendhearth, [
                                      "Now he'll place the",
                                      "ash next to the altar"
                                    ], z: 80,
                                      width: 300,
                                      scale: 0.2,
                                      randwait: 0,
                                      clearwhendone: true,
                                    );
                                    OPENWORLD.BaseObject.setVisible(
                                        firepanwield, true, groupname: "ash");
                                  }
                                },
                                {"p": [4.27, -1.38, 0], "v": v},
                                // bottom of ramp
                                {"p": [4.53, -1.38, 0], "v": v},
                                {"p": [ ashposx, ashposy - 0.05, 0], "v": v},
                                // where puts the ash
                                {
                                  "action": "squatwork",
                                  "time": 6,
                                  "callback": (actor) {
                                    var ash = saltpile.clone();
                                    ash.scale.setValues(0.009, 0.009, 0.009);

                                    _hotload.add(ash);
                                    OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                        ash, ashposx, ashposy, -0.005,
                                        1,
                                        level: 1); //3.124, -0.35, -0.005, 4); // 3.2,2.5, 0.0);
                                    //OPENWORLD.Texture.setNormalMap(ash, normalsalt, normalScale: 2.0);
                                    OPENWORLD.BaseObject.setVisible(
                                        firepanwield, false, groupname: "ash");

                                    OPENWORLD.Space.removeFaceObjectAlways(friendhearth);
                                    OPENWORLD.Space.faceObjectLerp(friendhearth,threeJs.camera,1);
                                    OPENWORLD.Mob.setSpeech(friendhearth, [

                                      "Now the ash is collected",
                                      "other priests come and help",
                                      "prepare the altar"
                                    ], z: 80,
                                      width: 300,
                                      scale: 0.2,
                                      randwait: 0,
                                      clearwhendone: true,
                                      callbackonfinish: (actor) {
                                        OPENWORLD.Space.faceObjectAlways(friendhearth, winningpriest);
                                       // OPENWORLD.Space.faceObjectLerp(friendhearth,winningpriest,1,delay:5);

                                      }
                                    );

                                    // Positions of priests around the laver
                                    var inc = 0;
                                    var laverposx = 3.58;
                                    var laverposy = -1.02;
                                    var laverdiff = 0.03;

                                    var laverpos = [
                                      //  [3.66, -1.02 - 0.04],
                                      [laverposx, laverposy - laverdiff],
                                      [laverposx, laverposy + laverdiff],
                                      [laverposx + 0.1, laverposy + laverdiff],
                                      [laverposx + 0.1, laverposy],
                                      [laverposx + 0.1, laverposy - laverdiff],
                                      [laverposx - 0.1, laverposy - laverdiff],
                                      [laverposx - 0.1, laverposy + laverdiff],
                                    ];

                                    for (var priest in priestlots) {
                                      if (priest != winningpriest &&
                                          priest != friendhearth) {
                                        priest.extra['toolinc'] = inc;
                                        var pos = OPENWORLD.Space
                                            .localToWorldObj(
                                            priest);
                                        List<Map>actions = [
                                          { "p": [pos.x, pos.y, 0], "v": v + OPENWORLD.Math.randFloatSpread( 0.02), "action": "walkstraight" },
                                          { "p": [ 4.41, -1.33, 0], "v": v + OPENWORLD.Math.randFloatSpread( 0.02), "action": "walkstraight" }, // edge of ramp
                                          { "p": [ 4.14, -1.33, 0], "v": v + OPENWORLD.Math.randFloatSpread( 0.02), "action": "walkstraight" },
                                          {
                                            "p": [
                                              laverpos[inc][0] + OPENWORLD.Math.randFloatSpread(laverdiff / 2),
                                              laverpos[inc][1] + OPENWORLD.Math.randFloatSpread(laverdiff / 2),
                                              0
                                            ],
                                            "v": v +
                                                OPENWORLD.Math.randFloatSpread(
                                                    0.02),
                                            "action": "walkstraight",
                                            "callback": (actor) {
                                              OPENWORLD.Space.facePointLerp(
                                                  actor, laverposx, laverposy,
                                                  1);
                                            }
                                          }, // at laver
                                          { "action": "work", "time": 3 + OPENWORLD.Math.randFloatSpread( 1) },
                                          { "action": "worklow", "time": 3 + OPENWORLD.Math.randFloatSpread( 1) },
                                          { "action": "squatwork", "time": 4 + OPENWORLD.Math.randFloatSpread( 1) }
                                        ];
                                        if (inc < 4) {
                                          actions.add({ "p": [ tools[inc]["p"][0] - 0.05, tools[inc]["p"][1], 0 ], "v": v + OPENWORLD.Math.randFloatSpread( 0.02), "action": "walkstraight", });
                                          actions.add(
                                              {
                                                "action": "stoopidle",
                                                "time": 4 + OPENWORLD.Math.randFloatSpread(1),
                                                "callback": (actor) {
                                                  var obj = tools[actor
                                                      .extra['toolinc']]["obj"];
                                                  var wield = tools[actor
                                                      .extra['toolinc']]["wield"];
                                                  OPENWORLD.Space
                                                      .removeObjFromHide(
                                                      obj);
                                                  obj.visible = false;
                                                  OPENWORLD.Actor.wield(
                                                      actor, wield,
                                                      "Bip01_R_Hand");
                                                }
                                              });
                                        }
                                        actions.add({ "p": [ 4.10, -1.38, 0], "v": v + OPENWORLD.Math.randFloatSpread( 0.02) },);
                                        actions.add({ "p": [4.27, -1.38, 0], "v": v + OPENWORLD.Math.randFloatSpread( 0.02) },); // bottom of ramp
                                        actions.add({ "p": [4.29, -0.32, 0], "v": v + OPENWORLD.Math.randFloatSpread( 0.02) },); // top of ramp


                                        actions.add({
                                          "p": [
                                            priestaltarposs[inc][0],
                                            priestaltarposs[inc][1],
                                            0
                                          ],
                                          "v": v,
                                          "callback": (actor) {
                                            if (actor.extra['toolinc'] == 0) {
                                              OPENWORLD.Space.removeFaceObjectAlways(friendhearth);
                                              opendoors(); // Only call it once
                                            }
                                          }
                                        },); //go to your work pos
                                        for (var j = 0; j < 4; j++) {
                                          actions.add(
                                              { "action": OPENWORLD.Math .randPick( [ "stoopidle", "work", "squatwork" ]), "time": 8 + OPENWORLD.Math.random() * 4 });
                                          actions.add({ "p": [ priestaltarposs[inc][0] + OPENWORLD.Math .randFloatSpread(0.02), priestaltarposs[inc][1] + OPENWORLD.Math .randFloatSpread(0.02), 0 ], "v": v },); //go to your work pos
                                          actions.add({"action":"idle","time":1}); // so dont moon walk at the end
                                        }

                                        // print("priestinc"+inc.toString());
                                        OPENWORLD.Mob.moveToLoop(
                                          priest,
                                          actions,
                                          action: inc >= 4
                                              ? "walk"
                                              : "walkhandright",
                                          level: 1,
                                          //  stopaction:"idle",
                                          //  reset:true,
                                          randomduration: 0.1,
                                          looptype: OPENWORLD.Mob.LoopTypeStop,
                                          surfaceonly: true,

                                          //   delay:10+i*(10+OPENWORLD.Math.random()*10)

                                        );
                                        inc++;
                                      }
                                    }
                                  }
                                },
                                {"action": "idlehold", "time": 3},

                                {"p": [ 4.56, -1.29, 0], "v": v},
                                {"p": [4.27, -1.38, 0], "v": v},
                                // bottom of ramp
                                {"p": [ 4.10, -1.38, 0], "v": v},
                                { "p": [Glob.firepanposx, Glob.firepanposy, 0], "v": v },// put the shovel back down
                                {
                                  "action": "stoopidle",
                                  "time": 6,
                                  "callback": (actor) {
                                    Glob.firepanground.visible = true;
                                    OPENWORLD.Space.readdObjFromHide(Glob
                                        .firepanground);
                                    OPENWORLD.Actor.unwield(actor, "Bip01_R_Hand");
                                  }
                                },
                                {"p": [ 4.10, -1.38, 0], "v": v},
                                {"p": [4.27, -1.38, 0], "v": v},
                                // bottom of ramp
                                {"p": [altarposx, altarposy, 0], "v": v},
                                // embers
                                {"p": [ 4.56, -0.2, 0], "v": v},
                                // south east wood bundle
                                {"action": "stoopidle", "time": 10},

                              ],
                              action: "walkhandright", //traight",
                              level: 1,
                              //  stopaction:"idle",
                              //  reset:true,
                              looptype: OPENWORLD.Mob.LoopTypeStop,
                              surfaceonly: true,

                              //   delay:10+i*(10+OPENWORLD.Math.random()*10)

                            );
                            for (var i = 0; i < securitylist.length; i++) {
                              if (securitylist[i] != winningpriest) {
                                setcancollide(securitylist[i], true);
                                OPENWORLD.Actor.playAction(
                                    securitylist[i], action: "idle3",
                                    randomduration: 0.1,
                                    startat: OPENWORLD.Math.random(),
                                    delay: OPENWORLD.Math.random() * 4);

                                //  print("security i"+i.toString());
                                // This where you pick the priest closest to the another priest and they face eachother like they're talking
                                var closestind = -1;
                                var closestdist = 9999.0;
                                for (var j = 0; j < securitylist.length; j++) {
                                  if (j != i && securitylist[j] != winningpriest) {
                                    var dist = OPENWORLD.Space.getDistanceBetweenObjs2D(securitylist[i], securitylist[j]);
                                    if (dist < closestdist) {
                                      closestdist = dist;
                                      closestind = j;
                                    }
                                  }
                                }
                                OPENWORLD.Space.faceObjectLerp( securitylist[i], securitylist[closestind], 1, delay: OPENWORLD.Math.random() * 4);
                                // }
                              }
                            }

                            OPENWORLD.Space.faceObjectAlways(priestkey, winningpriest);
                            //  OPENWORLD.Space.faceObjectAlways(friendhearth, winningpriest);
                            Future.delayed(
                                Duration(milliseconds: 5000), () async {
                              if (friendisclose())
                                OPENWORLD.Space.objTurnLerp(
                                  threeJs.camera, 288, 1);
                              if (friendisclose())
                                OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                  threeJs.camera, opendoorsstartposx,
                                  opendoorsstartposy,
                                  // meetupposx - 0.1, meetupposy - 0.2,
                                  OPENWORLD.Camera.cameraoffset, 1.0,
                                  level: 1); // so that dont have priests blocking your view
                              OPENWORLD.Mob.placeBeforeCamera(
                                  friendhearth, 0.08, offset: 0.03,
                                  time: 3,
                                  action: "walkhandright",
                                  stopaction: "idle",
                                  callbackonfinish: (actor) {
                                    OPENWORLD.Mob.setSpeech(friendhearth, [
                                      "The winner of the lottery",
                                      "now does the ",
                                      "terumat ha-deshen.",
                                      "He'll wash at the laver",
                                      "then get the silver maḥtah",
                                      "and go up to the altar",
                                      "and collect ash which he",
                                      "places next to the altar"
                                    ], z: 80,
                                        width: 300,
                                        scale: 0.2,
                                        randwait: 0,
                                        clearwhendone: true,
                                        callbackonfinish: (actor) {
                                          OPENWORLD.Space.faceObjectAlways(friendhearth, winningpriest);
                                        }
                                    );
                                  },
                                  /* level: 1,*/
                                  delay: 2);
                            });
                          }

                          // Game restart for the terumat
                          terumatreset() async {
                            print('terumat start');
                            var startterumatposx = meetupposx + 0.05;
                            var startterumatposy = meetupposy - 0.2;
                            OPENWORLD.Space.worldToLocalSurfaceObj(
                                threeJs.camera, startterumatposx,
                                startterumatposy,
                                OPENWORLD.Camera.cameraoffset, level: 1);
                            OPENWORLD.Space.objTurn(threeJs.camera, 0);
                            //OPENWORLD.Space.faceObjectLerp(friendhearth,threeJs.camera,1);
                            OPENWORLD.Actor.wield(
                                friendhearth, torch, "Bip01_R_Hand");
                            addflametotorch(torch, true);
                            OPENWORLD.Space.worldToLocalSurfaceObj(
                                friendhearth, meetupposx, meetupposy - 0.1, 0,
                                level: 1);

                            //OPENWORLD.Space.faceObjectLerp(threeJs.camera,friendhearth,1);
                            OPENWORLD.Actor.playAction(
                                friendhearth, action: "idlehold");
                            OPENWORLD.Space.worldToLocalSurfaceObj(
                                priestkey, meetupposx, meetupposy, 0, level: 1);
                            OPENWORLD.Space.objTurn(priestkey, 180);
                            OPENWORLD.Actor.playAction(
                                priestkey, action: "idlehold");
                            var torch2 = torch.clone();
                            OPENWORLD.Actor.wield(
                                priestkey, torch2, "Bip01_R_Hand", delay: 2);
                            addflametotorch(torch2, false);

                            // print("priestlotsa len"+priestlots.length.toString());
                            await dresspriests();
                            //  print("priestlotsb len"+priestlots.length.toString());

                            priestlots.remove(friendhearth); // Only put him in so can clothe him properly and is in correct position
                            _hotload.add(superintendent);

                            for (var i = 0; i < priestlots.length; i++) {
                              var priestlot = priestlots[i];
                              // if (priestlot==friendhearth)
                              //   print("found friend"+i.toString());
                              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(
                                  priestlot);
                            }

                            doorwaysouthhearth.setOpenClose(true);
                            //OPENWORLD.Space.objTurn(doorgold, 180);

                            priestgroundstolottery();
                            priestsleepstoground();
                            friendcloth();
                            OPENWORLD.Space.resetRot(friendhearth);
                            OPENWORLD.Space.setZ(friendhearth, 0, level: 1);

                            securitylist.clear();
                            securitylist.addAll(priestlots);
                            securitylist.addAll(priestgrounds);
                            for (var i = 0; i < 10; i++)
                              securitylist.add(priestsextra[i]);
                            //securitylist.shuffle();

                            for (var securitypriest in securitylist) {
                              securitypriest.extra.remove('hittrigger');
                            }
                            securitylist.shuffle();
                            securitylist.insert(0, superintendent);

                            // var finalposs=setsecurityfinalpos(securitylist);
                            for (var i = 0; i < securitylist.length; i++) {
                              var securitypriest = securitylist[i];
                              OPENWORLD.BaseObject.removeDistanceTrigger(
                                  securitypriest);
                              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(
                                  securitypriest);
                              //      OPENWORLD.Space.faceObjectAlways(securitypriest,i%2==1?priestkey:friendhearth);//superintendent,1.0);
                              /// OPENWORLD.Space.worldToLocalSurfaceObjHide(
                              //    securitypriest, finalposs[i][0],finalposs[i][1],0,level:1, 2); //, level:1);
                              //   OPENWORLD.Actor.playAction(
                              //      securitypriest,action:"idle");

                            }
                            var prevlist = [];
                            var meetuposs = [];
                            prevlist.add([meetupposx, meetupposy, 0, 0.02]);
                            prevlist.add(
                                [startterumatposx, startterumatposy, 0, 0.02]);
                            for (var i = 0; i < securitylist.length; i++) {
                              var nextpos;
                              if (i % 2 == 0)
                                nextpos = nextdonthit(
                                    prevlist, meetupposx, 0.2, meetupposy - 0.1,
                                    0.4,
                                    0.05);
                              else
                                nextpos = nextdonthit(
                                    prevlist, meetupposx, 0.2, meetupposy + 0.1,
                                    0.4,
                                    0.05);
                              meetuposs.add([nextpos[0], nextpos[1], 0, 0.02]);
                              prevlist.add(nextpos);
                            }
                            for (var i = 0; i < securitylist.length; i++) {
                              var securitypriest = securitylist[i];

                              OPENWORLD.Actor.playAction(
                                  securitypriest,
                                  action: securitypriest == superintendent
                                      ? "idlehold"
                                      : "idle", randomduration: 0.1);
                              if (securitypriest != friendhearth &&
                                  securitypriest != priestkey) {
                                //var diffx=OPENWORLD.Math.randFloatSpread(0.2);
                                //  var diffy=OPENWORLD.Math.random()*0.4;
                                //if (i % 2 == 0) {
                                OPENWORLD.Space.worldToLocalSurfaceObj(
                                    securitypriest, meetuposs[i][0],
                                    meetuposs[i][1],
                                    0,
                                    level: 1); //meetupposx+diffx,meetupposy-diffy-0.1, 0,  level: 1);//,5);

                                // westgroup.add(securitypriest);

                                //   } else {
                                // eastgroup.add(securitypriest);
                                //  print("aaaa"+i.toString()+" "+ (meetupposx+0.1+diffx).toString()+" "+(meetupposy+diffy).toString());
                                //   OPENWORLD.Space.worldToLocalSurfaceObj(
                                //       securitypriest , meetupposx+diffx,meetupposy+0.1+diffy, 0,  level: 1);//,5);
                                //  }
                                OPENWORLD.Space.faceObject(
                                    securitypriest, friendhearth);
                              }
                            }
                            OPENWORLD.Space.objTurn(friendhearth, 0);

                           // Future.delayed(
                           //     Duration(milliseconds: 20000), () async {
                            callwhenloaded(() {
                              terumat();
                            });
                          //  });
                          }

                          if (gamestart == GameStart.hearth &&
                              gamestartpos[gamestart]['progress'].contains(
                                  'security')) {
                            // If have done the security check then do the terumat next
                            print("terumatreset start");
                            terumatreset();
                          } else {
                            // Do the security check
                            security() {
                              saveGameState('tosecurity');
                              OPENWORLD.Config.updatePoolObjects();
                              friendhearth.extra['followhearth'] = true;

                              var priestspeed = 0.03;

                              OPENWORLD.Space.objTurnLerp(
                                  friendhearth, 180 + 45, 1);
                              OPENWORLD.Space.objTurnLerp(
                                  friendhearth, 0 - 45, 1, delay: 2);
                              OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 3);
                              OPENWORLD.Mob.setSpeech(friendhearth, [
                                "Be vigilante."
                              ], z: 80,
                                  width: 300,
                                  scale: 0.2,
                                  randwait: 0,
                                  clearwhendone: true,
                                  callbackonfinish: (actor) {
                                  },
                                  delay: 4);
                              var westgroup = [];
                              var eastgroup = [];
                              for (var i = 0; i < securitylist.length; i++) {
                                var securitypriest = securitylist[i];

                                OPENWORLD.Actor.playAction(
                                    securitypriest,
                                    action: securitypriest == superintendent
                                        ? "idlehold"
                                        : "idle", randomduration: 0.1);
                                if (i % 2 == 0)
                                  westgroup.add(securitypriest);
                                else
                                  eastgroup.add(securitypriest);
                              }
                              westgroup.add(superintendent);
                              eastgroup.add(priestkey);
                              westgroup.add(friendhearth);
                              var prevlist = [];
                              var meetuposs = [];
                                           // 5.15,         -0.81
                              prevlist.add([meetupposx, meetupposy, 0, 0.02]);
                              for (var i = 0; i < westgroup.length; i++) {
                                // +0.03 so that security slightly more east and dont block off the court of israel as leave for final tamid
                                var nextpos = nextdonthit(prevlist, meetupposx, 0.16, meetupposy - 0.1, 0.4, 0.04);
                                meetuposs.add(
                                    [nextpos[0], nextpos[1], 0, 0.02]);
                                prevlist.add(nextpos);
                              }

                              //   print("meetuppos"+meetuposs.toString());
                              for (var i = 0; i < westgroup.length; i++) {
                                var priest = westgroup[i];
                                setcancollide(priest, true);
                                OPENWORLD.Space.removeFaceObjectAlways(priest);
                                OPENWORLD.Mob.moveTo(
                                    priest,
                                    [
                                      [
                                        0.82 + (priest == friendhearth ? 0 : OPENWORLD.Math.randFloatSpread(0.4)), //0.79
                                        -0.94 + (priest == friendhearth ? 0 : OPENWORLD.Math.randFloatSpread(0.4)), //-1.12
                                        0,
                                        priestspeed
                                      ],
                                      [  // north east of ramp
                                        4.02 + (priest == friendhearth ? 0 : OPENWORLD.Math.randFloatSpread(0.4)),
                                        //5.15 3.8
                                        -1.34 + (priest == friendhearth ? 0 : OPENWORLD.Math.randFloatSpread(0.2)),
                                        //-1.18
                                        0,
                                        priestspeed
                                      ],
                                      [  // south east of ramp
                                        4.62 + (priest == friendhearth ? 0 : OPENWORLD.Math.randFloatSpread(0.4)),
                                        //5.15 3.8
                                        -1.34 +0.1+ (priest == friendhearth ? 0 : OPENWORLD.Math.randFloatSpread(0.3)),
                                        //-1.18
                                        0,
                                        priestspeed
                                      ],
                                      [
                                        priest == friendhearth ? meetupposx : meetuposs[i][0],
                                        //OPENWORLD.Math.randFloatSpread(0.4)),  //3.8
                                        priest == friendhearth ? meetupposy : meetuposs[i][1],
                                        //OPENWORLD.Math.randFloatSpread(0.4)),
                                        0,
                                        priestspeed
                                      ]
                                    ],
                                    action: priest == superintendent ||
                                        priest == friendhearth
                                        ? "walkhandright" : OPENWORLD.Math.random() < 0.5 ? "walkscan" : "walk",
                                    actionrandomduration: 0.1,
                                    stopaction: priest == superintendent ||
                                        priest == friendhearth
                                        ? "idlehold"
                                        : "idle",
                                    surfaceonly: true,
                                    level: 1,
                                    callbackonfinish: (actor) {
                                      if (actor == friendhearth) {
                                        for (var i = 0; i < westgroup.length; i++) {
                                          var priest = westgroup[i];
                                          setcancollide(priest, false);
                                        }

                                        OPENWORLD.Mob.setSpeech(friendhearth, [
                                          "Shalom. All is well"
                                        ], z: 80,
                                            width: 300,
                                            scale: 0.2,
                                            randwait: 0,
                                            clearwhendone: true
                                        );
                                        OPENWORLD.Mob.setSpeech(priestkey, [
                                          "All is well"
                                        ], z: 90,
                                            width: 300,
                                            scale: 0.3,
                                            randwait: 0,
                                            clearwhendone: true,
                                            delay: 3
                                        );
                                        for (var priest in eastgroup)
                                          OPENWORLD.Space.faceObjectLerp( priest, friendhearth, 1.0, delay: OPENWORLD.Math.random());
                                        Future.delayed(
                                            Duration(
                                                milliseconds: 15000), () async {
                                          friendhearth.extra['followhearth'] = false;
                                          terumat();
                                        });
                                      }
                                    },
                                    delay: 20 +
                                        (priest == friendhearth ? 0 : 4 +
                                            OPENWORLD.Math.random() * 2)
                                );
                              }


                              // Delay so you both meet up at the chaviten around the same time
                              Future.delayed(
                                  Duration(milliseconds: 30000), () async {
                                for (var i = 0; i < eastgroup.length; i++) {
                                  var priest = eastgroup[i];
                                  OPENWORLD.Space.setObjHideDist(
                                      priest,
                                      5); // so can see them across the inner court
                                  OPENWORLD.Space.removeFaceObjectAlways(
                                      priest);
                                  OPENWORLD.Mob.moveTo(
                                      priest,
                                      [
                                        [5.16 + OPENWORLD.Math.randFloatSpread(0.4),
                                          1.88 + OPENWORLD.Math.randFloatSpread(0.4),
                                          0,
                                          priestspeed
                                        ],
                                        [
                                          5.24 + OPENWORLD.Math.randFloatSpread(0.2),
                                          0.87 + OPENWORLD.Math.randFloatSpread(0.2),

                                          priestspeed
                                        ],
                                        [
                                          meetupposx + (priest == priestkey ? 0 : OPENWORLD.Math.randFloatSpread(0.35)),
                                          //3.8
                                          meetupposy + (priest == priestkey ? 0.07 : OPENWORLD.Math.random() * 0.4),
                                          ///OPENWORLD.Math.randFloatSpread(0.4),
                                          0,
                                          priestspeed
                                        ]


                                      ],
                                      action: priest == priestkey
                                          ? "walkhandright" : OPENWORLD.Math.random() < 0.5 ? "walkscan" : "walk",
                                      stopaction: priest == priestkey ? "idlehold" : "idle",
                                      surfaceonly: true,
                                      level: 1,
                                      delay: priest == priestkey ? null : 4 +
                                          OPENWORLD.Math.random() * 2
                                  );
                                }
                              });

                              //
                              //
                            }


                            // Allow restart of the security check
                            securityreset() async {
                              print('security start');
                              OPENWORLD.Space.worldToLocalSurfaceObj(
                                  threeJs.camera, mysecuritystartposx,
                                  mysecuritystartposy,
                                  OPENWORLD.Camera.cameraoffset, level: 1);
                              OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1);
                              OPENWORLD.Actor.wield(
                                  friendhearth, torch, "Bip01_R_Hand");
                              addflametotorch(torch, true);
                              OPENWORLD.Space.worldToLocalSurfaceObj(
                                  friendhearth, securitywestposx,
                                  securitywestposy,
                                  0,
                                  level: 1);

                              OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1);
                              OPENWORLD.Actor.playAction(
                                  friendhearth, action: "idlehold");
                              OPENWORLD.Space.worldToLocalSurfaceObj(
                                  priestkey, securityeastposx, securityeastposy,
                                  0,
                                  level: 1);
                              OPENWORLD.Actor.playAction(
                                  priestkey, action: "idle");
                              var torch2 = torch.clone();
                              OPENWORLD.Actor.wield(
                                  priestkey, torch2, "Bip01_R_Hand", delay: 2);
                              addflametotorch(torch2, false);

                              // print("priestlotsa len"+priestlots.length.toString());
                              await dresspriests();
                              //  print("priestlotsb len"+priestlots.length.toString());

                              priestlots.remove(
                                  friendhearth); // Only put him in so can clothe him properly and is in correct position
                              _hotload.add(superintendent);

                              for (var i = 0; i < priestlots.length; i++) {
                                var priestlot = priestlots[i];
                                // if (priestlot==friendhearth)
                                //   print("found friend"+i.toString());
                                OPENWORLD.Actor.removeObjectFromPlayActionsLoop(
                                    priestlot);
                              }

                              doorwaysouthhearth.setOpenClose(true);
                              //OPENWORLD.Space.objTurn(doorgold, 180);

                              priestgroundstolottery();
                              priestsleepstoground();
                              friendcloth();
                              OPENWORLD.Space.resetRot(friendhearth);
                              OPENWORLD.Space.setZ(friendhearth, 0, level: 1);

                              securitylist.clear();
                              securitylist.addAll(priestlots);
                              securitylist.addAll(priestgrounds);
                              for (var i = 0; i < 10; i++)
                                securitylist.add(priestsextra[i]);
                              //securitylist.shuffle();

                              for (var securitypriest in securitylist) {
                                securitypriest.extra.remove('hittrigger');
                              }
                              securitylist.shuffle();
                              securitylist.insert(0, superintendent);

                              var finalposs = setsecurityfinalpos(securitylist);
                              for (var i = 0; i < securitylist.length; i++) {
                                var securitypriest = securitylist[i];
                                OPENWORLD.BaseObject.removeDistanceTrigger(
                                    securitypriest);
                                OPENWORLD.Actor.removeObjectFromPlayActionsLoop(
                                    securitypriest);
                                OPENWORLD.Space.faceObjectAlways(securitypriest,
                                    i % 2 == 1
                                        ? priestkey
                                        : friendhearth); //superintendent,1.0);
                                OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                    securitypriest, finalposs[i][0],
                                    finalposs[i][1],
                                    0,
                                    level: 1,
                                    2); //, level:1);
                                OPENWORLD.Actor.playAction(
                                    securitypriest, action: "idle");
                              }
                             // Future.delayed(
                            //      Duration(milliseconds: 10000), () async {
                              callwhenloaded(() {
                                security();
                              });
                            //  });
                            }

                            if (gamestart == GameStart.hearth &&
                                gamestartpos[gamestart]['progress'].contains(
                                    'tosecurity')) {
                              // Restart game so If have reached the security start spot start the security check
                              print("securityreset start");
                              securityreset();
                            } else {
                              // Move priests outside chamber of the hearth to the inner court so they can start the security check
                              tosecurity() async {
                                saveGameState('lottery');
                                await OPENWORLD.Config.updatePoolObjects();
                                friendhearth.extra['followhearth'] = true;
                                if (friendisclose())
                                  OPENWORLD.Space.objTurnLerp(threeJs.camera, 129, 1);

                                OPENWORLD.Mob.setSpeech(friendhearth, [
                                  "Now we do an inspection ",
                                  "of the inner court.",
                                  "We split into 2 groups",
                                  "and meet up at the ",
                                  "Place of the Makers of the Chavitin.",
                                  "I shall lead one of the groups",
                                  "We'll just let the other priests leave"
                                ], z: 80,
                                    width: 300,
                                    scale: 0.2,
                                    randwait: 0,
                                    clearwhendone: true,
                                    callbackonfinish: (actor) {
                                      OPENWORLD.Space.facePointLerp(
                                          friendhearth, doorposx, doorposy, 1);
                                      OPENWORLD.Mob.setSpeech(friendhearth, [
                                        "Lets go"
                                      ], z: 80,
                                        width: 300,
                                        scale: 0.2,
                                        randwait: 0,
                                        clearwhendone: true,
                                        //  delay:10
                                      );
                                    });

                                //var securitylist=[];
                                securitylist.addAll(priestlots);
                                securitylist.addAll(priestgrounds);
                                for (var i = 0; i < 10; i++)
                                  securitylist.add(priestsextra[i]);
                                //securitylist.shuffle();

                                for (var securitypriest in securitylist) {
                                  securitypriest.extra['dist'] =
                                      OPENWORLD.Space.getDistanceBetweenObjs2D(
                                          securitypriest,doorsouthhearth);// doorwaysouthhearth);
                                  securitypriest.extra.remove('hittrigger');
                                }
                                securitylist.sort((a, b) {
                                  num distA = a.extra['dist'] ?? 0;
                                  num distB = b.extra['dist'] ?? 0;
                                  //   return distB.compareTo(distA);
                                  return distA.compareTo(distB);
                                });

                                securitylist.insert(0, superintendent);
                                var finalposs = setsecurityfinalpos(securitylist);

                                for (var i = 0; i < securitylist.length; i++) {
                                  var securitypriest = securitylist[i];
                                  OPENWORLD.BaseObject.removeDistanceTrigger(
                                      securitypriest);
                                  OPENWORLD.Actor
                                      .removeObjectFromPlayActionsLoop(
                                      securitypriest);
                                  OPENWORLD.Space.removeFaceObjectAlways(
                                      securitypriest);
                                  var v;
                                  v = 0.02;
                                  //  var secondsperpriest=3;


                                  List<List> poslist = [
                                    [doorposx + 0.02, doorposy + 0.04, 0, v],
                                    [doorposx, doorposy, 0, v],
                                    [doorposx, doorposy - 0.04, 0, v],
                                    finalposs[i]
                                  ];
                                  var priestpos = OPENWORLD.Space.localToWorldObj(securitypriest);
                                  if (priestpos.y > 2.76)
                                    poslist.insert(0, [
                                      0.92 +
                                          OPENWORLD.Math.randFloatSpread(0.4),
                                      2.76,
                                      0,
                                      v
                                    ]); // So sleeping priests dont walk up the sides
                                  // You want someone going through the wicket every second
                                  OPENWORLD.Mob.moveTo(
                                      securitypriest,
                                      poslist,
                                      action: i==0?"walkhandright":"walk",  // superintendent with lamp should be walkhandstraight
                                      stopaction: "idle",
                                      surfaceonly: true,
                                      level: 1,
                                      callbackonfinish: (actor) {
                                        if (i % 2 == 0)
                                          OPENWORLD.Space.faceObjectAlways(actor,
                                              friendhearth); //superintendent,1.0);
                                        else
                                          OPENWORLD.Space.faceObjectAlways(
                                              actor,
                                              priestkey); //superintendent,1.0);

                                      },
                                      delay: i *
                                          4 // if still in the northern part then have them walk up immediately
//                  delay: priestsleeps.contains(securitypriest)?null: i*4   // if still in the northern part then have them walk up immediately
                                  );
                                }
                                //   var friendpos=OPENWORLD.Space.localToWorldObj(friendhearth);

                                OPENWORLD.Actor.wield(
                                    priestkey, torch, "Bip01_R_Hand");

                                // Have priest key walk to your friend and hand it to him
                                OPENWORLD.Mob.moveTo(
                                    priestkey,
                                    [
                                      [0.78 + 0.03, 2.47, 0, 0.02],
                                      //friendpos.x-0.05,friendpos.y, 0, 0.02],
                                    ], action: "walk",
                                    stopaction: "idlehold",
                                    surfaceonly: true,
                                    level: 1,
                                    callbackonfinish: (actor) async {
                                      OPENWORLD.Mob.setSpeech(priestkey, [
                                        "There you are"
                                      ], z: 80,
                                          width: 300,
                                          scale: 0.2,
                                          randwait: 0,
                                          clearwhendone: true
                                      );
                                      OPENWORLD.Space.faceObjectLerp( priestkey, friendhearth, 1);
                                      OPENWORLD.Space.faceObjectLerp( friendhearth, priestkey, 0.5);
                                      OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 3);
                                      // priestkey hand over torch to your friend
                                      OPENWORLD.Actor.unwield(
                                          priestkey, "Bip01_R_Hand", delay: 3);
                                      OPENWORLD.Actor.wield(
                                          friendhearth, torch, "Bip01_R_Hand",
                                          delay: 3);
                                      OPENWORLD.Actor.playAction(
                                          friendhearth, action: "idlehold",
                                          delay: 2);

                                      // priest key move to the eastern security group
                                      OPENWORLD.Mob.moveTo(
                                          priestkey,
                                          [
                                            [doorposx + 0.02, doorposy + 0.04, 0, 0.02],
                                            [doorposx, doorposy, 0, 0.02],
                                            [doorposx, doorposy - 0.04, 0, 0.02],
                                            [securityeastposx, securityeastposy, 0, 0.02]
                                            //1.47, 1.66 ]
                                          ], action: "walk",
                                          stopaction: "idle",
                                          surfaceonly: true,
                                          level: 1,
                                          callbackonfinish: (actor) {
                                            // priestkey will lead and have a torch
                                            Future.delayed(Duration(
                                                milliseconds: 9000), () async {
                                              var torch2 = torch.clone();
                                              OPENWORLD.Actor.wield(
                                                  priestkey, torch2,
                                                  "Bip01_R_Hand");
                                              addflametotorch(torch2, false);
                                            });
                                          },
                                          delay: 3
                                      );
                                    },
                                    delay: 1
                                );

                                Future.delayed(Duration(
                                    milliseconds: 2000 +
                                        1000 * (securitylist.length - 10) *
                                            4), () async {
                                  var friendpos = OPENWORLD.Space.localToWorldObj(friendhearth);
                                  OPENWORLD.Mob.moveToLoop(
                                    friendhearth,
                                    [
                                      { "p": [friendpos.x, friendpos.y, 0], "v": 0.02 },
                                      { "p": [ doorposx + 0.02, doorposy + 0.04, 0 ], "v": 0.02 },
                                      {"p": [doorposx, doorposy, 0], "v": 0.02},
                                      { "p": [doorposx, doorposy - 0.04, 0], "v": 0.02, },
                                      {
                                        "action": "work",
                                        "time": 3,
                                        "callback": (actor) {
                                          // Delay a bit so move along a bit that the hearth lamps have gone out
                                          Future.delayed(Duration(
                                              milliseconds: 8000), () async {
                                            addflametotorch(torch, true);
                                          });
                                        }
                                      },
                                      { "p": [ securitywestposx, securitywestposy, 0 ], "v": 0.02 },//0.75, 1.51, 0]
                                      {
                                        "action": "idlehold",
                                        "time": 3,
                                        "callback": (actor) {
                                          // So you are looking at the second security group in the background
                                          if (friendisclose())
                                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                              threeJs.camera, 0.66, 1.51,
                                              OPENWORLD.Camera.cameraoffset,
                                              1.0,
                                              level: 1);
                                          OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 2);
                                          if (friendisclose())
                                            OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1, delay: 2);
                                          security();
                                        }
                                      },
                                    ],
                                    action: "walkhandright", //traight",
                                    level: 1,
                                    //  stopaction:"idle",
                                    //  reset:true,
                                    looptype: OPENWORLD.Mob.LoopTypeStop,
                                    surfaceonly: true,

                                    //   delay:10+i*(10+OPENWORLD.Math.random()*10)

                                  );
                                });
                              }

                              // Allow restart of priests going to the security start spot
                              tosecurityreset() async {
                                print("tosecurity start");
                                OPENWORLD.Space.worldToLocalSurfaceObj(
                                    threeJs.camera, playerlotterystartposx,
                                    playerlotterystartposy,
                                    OPENWORLD.Camera.cameraoffset, level: 1);
                                await dresspriests();
                                priestlots.remove(
                                    friendhearth); // Only put him in so can clothe him properly and is in correct position
                                OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                    superintendent, 0.95, 2.37, 0, level: 1,
                                    5); //why was hidedist 2 instead of 5 priestposs[0][0],priestposs[0][1], 0.00,level:1, 2); //, level:1);  1.5, 3.5
                                _hotload.add(superintendent);
                                OPENWORLD.Space.objTurn(superintendent, 270);
                                OPENWORLD.Space.faceObject(
                                    threeJs.camera,
                                    superintendent); //,superintendent,1);

                                for (var i = 0; i < priestlots.length; i++) {
                                  var priestlot = priestlots[i];
                                  // if (priestlot==friendhearth)
                                  //   print("found friend"+i.toString());
                                  OPENWORLD.Actor
                                      .removeObjectFromPlayActionsLoop(
                                      priestlot);

                                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                      priestlot, poslots[i][0], poslots[i][1],
                                      0,
                                      level: 1,
                                      2); //, level:1);

                                  OPENWORLD.Space.faceObject(
                                      priestlot, superintendent);
                                  var priestpos = OPENWORLD.Space
                                      .localToWorldObj(
                                      priestlot);
                                  var newpos = OPENWORLD.Math.vectorMoveForward(
                                      priestpos.x, priestpos.y,
                                      OPENWORLD.Space.getObjTurn(priestlot) -
                                          180,
                                      0.1);
                                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                      priestlot, newpos.x, newpos.y, 0,
                                      level: 1,
                                      2); //, level:1);
                                  OPENWORLD.Actor.playAction(
                                      priestlot, action: "idle");
                                  if (priestlot != friendhearth)
                                    OPENWORLD.Space.faceObjectAlways(priestlot, superintendent); //,superintendent,1);
                                }
                                OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                    priestkey, priestkeyfinalposx,
                                    priestkeyfinalposy,
                                    0,
                                    level: 1,
                                    2); //, level:1);
                                OPENWORLD.Space.faceObjectLerp( priestkey, superintendent, 1); //,superintendent,1);
                                //  OPENWORLD.Actor.playAction(priestkey, action:"starjump");

                                doorwaysouthhearth.setOpenClose(true);
                               // OPENWORLD.Space.objTurn(doorgold, 180);

                                priestgroundstolottery();
                                priestsleepstoground();
                                friendcloth();
                                OPENWORLD.Space.resetRot(friendhearth);
                                OPENWORLD.Space.setZ(friendhearth, 0, level: 1);

                                OPENWORLD.BaseObject.setVisible(beddingkey,
                                    false);
                                OPENWORLD.Space.placeBeforeCamera(
                                    friendhearth, 0.08, offset: -0.03,
                                    //  time: 3,
                                    //  action: "walk",
                                    //  stopaction: "idle",
                                    level: 1
                                );
                                OPENWORLD.Actor.playAction(
                                    friendhearth, action: "idle");
                                OPENWORLD.Space.faceObject(
                                    friendhearth, threeJs.camera);
                                //  OPENWORLD.Space.faceObject(threeJs.camera,friendhearth);
                               // Future.delayed(
                               //     Duration(milliseconds: 15000), () async {
                                callwhenloaded(() {
                                  tosecurity();
                                });
                               // });
                              }


                              if (gamestart == GameStart.hearth &&
                                  gamestartpos[gamestart]['progress'].contains(
                                      'lottery')) {
                                print("tosecurityreset start");
                                // Allow game restart where if have done the lottery then move to the security start spot
                                tosecurityreset();
                              } else {

                                // Do the lottery in the chamber of the hearth
                                lottery() {
                                  saveGameState('tolottery'); // have done to lottery
                                  OPENWORLD.Config.updatePoolObjects();
                                  OPENWORLD.Space.faceObjectLerp( friendhearth, superintendent, 1.0);
                                  OPENWORLD.Space.worldToLocalSurfaceObj(
                                      threeJs.camera, playerlotterystartposx,
                                      playerlotterystartposy,
                                      OPENWORLD.Camera.cameraoffset, level: 1);

                                  // priests extend their finger
                                  Future.delayed(
                                      Duration(milliseconds: 3000), () async {
                                    OPENWORLD.Space.faceObjectLerp( superintendent, friendhearth, 1.0); //,delay:5);
                                    OPENWORLD.Actor.playAction(
                                        friendhearth, action: "idlehold",
                                        randomduration: 0.1,
                                        duration: 4);
                                    for (var priestlot in priestlots) {
                                      OPENWORLD.Actor.playAction(
                                          priestlot, action: "idlehold",
                                          randomduration: 0.1,
                                          delay: OPENWORLD.Math.random(),
                                          duration: 4);
                                    }
                                  });

                                  OPENWORLD.Mob.setSpeech(superintendent, [
                                    "Extend a finger.",
                                    "I'll start with you.",
                                    "Take off your turban"
                                  ], z: 90,
                                      width: 300,
                                      scale: 0.4,
                                      randwait: 0,
                                      clearwhendone: true,
                                      callbackonfinish: (actor) async {
                                        // Friend takes his\ turban off
                                        OPENWORLD.Actor.playActionThen(
                                            friendhearth, "armsup", "idlehold",
                                            randomdurationthen: 0.1);

                                        friendhearth.extra['turban'] =
                                            OPENWORLD.Texture
                                                .getMaterialByGroupname(
                                                friendhearth, "citizen_3");
                                        OPENWORLD.Texture.setMaterial(
                                            friendhearth,
                                            friendhearth.extra['hair'],
                                            groupname: "citizen_3");
                                        // Hold turban in hands

                                        OPENWORLD.Actor.wield(
                                            friendhearth, turbanwield,
                                            "Bip01_R_Hand",
                                            delay: 1);
                                        //  OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                        //      threeJs.camera,  0.80, 2.51, OPENWORLD.Camera.cameraoffset, 1.0, level: 1);
                                        var timespread = 0.5;
                                        var anglespread = 45.0; // Dont want the superintendant rotating too smoothly
                                        List<Map> actions = [
                                          { "p": [ superlotteryx, superlotteryy, 0 ], "v": 0.02 },
                                          {
                                            "action": "idlehold",
                                            "time": 10,
                                            "t": 0,
                                            "callback": (actor) {}
                                          },
                                          { "action": "walkhandrightpoint", "duration": 1.5, "time": 1, "t": 90 },
                                          { "time": 1 + OPENWORLD.Math.randFloatSpread( timespread), "t": 180 + OPENWORLD.Math.randFloatSpread( anglespread) },
                                          { "time": 1 + OPENWORLD.Math.randFloatSpread( timespread), "t": 270 + OPENWORLD.Math.randFloatSpread( anglespread) },
                                          { "time": 1 + OPENWORLD.Math.randFloatSpread( timespread), "t": 0 + OPENWORLD.Math.randFloatSpread( anglespread) },
                                        ];
                                        for (var i = 0; i < 4; i++) {
                                          for (var j = 0; j < 8; j++)
                                            actions.add({ "time": 1 + OPENWORLD.Math .randFloatSpread( timespread), "t": j * 45 + OPENWORLD.Math .randFloatSpread( anglespread) });

                                        }
                                        actions[actions.length - 1]['callback'] =
                                            (actor) {
                                          // The priest is chosen who won it
                                          var winningpriest = priestlots[3]; // bottom right was the winner
                                          OPENWORLD.Space.faceObjectLerp( superintendent, winningpriest, 1.0);
                                          OPENWORLD.Mob.setSpeech(
                                              superintendent, ["You!"], z: 90,
                                              width: 300,
                                              scale: 0.4,
                                              randwait: 0,
                                              clearwhendone: true,
                                              delay: 1);
                                          OPENWORLD.Actor.playActionThen(
                                              superintendent, "idleholdpoint",
                                              "idlehold",
                                              duration: 2);

                                          for (var priestlot in priestlots) {
                                            OPENWORLD.Space
                                                .removeFaceObjectAlways(
                                                priestlot);
                                            OPENWORLD.Actor.playAction(
                                                priestlot,
                                                action: priestlot != winningpriest ? "lookdown" : "lookup",
                                                randomduration: 0.1,
                                                delay: 2 + 3 * OPENWORLD.Math.random());
                                            var priestpos = OPENWORLD.Space.localToWorldObj(priestlot);
                                            var newpos = OPENWORLD.Math
                                                .vectorMoveForward(
                                                priestpos.x, priestpos.y,
                                                OPENWORLD.Space.getObjTurn(
                                                    priestlot) -
                                                    180,
                                                0.1);
                                            OPENWORLD.Mob.moveTo(
                                                priestlot,
                                                [
                                                  [newpos.x, newpos.y, 0, 0.01]
                                                ], action: "walk",
                                                stopaction: "idle",
                                                surfaceonly: true,
                                                level: 1,
                                                callbackonfinish: (actor) {
                                                  OPENWORLD.Space .faceObjectLerp( actor, superintendent, 1.0);
                                                },
                                                delay: 8 +
                                                    6 * OPENWORLD.Math.random()
                                            );
                                          }
                                          OPENWORLD.Space.removeFaceObjectAlways(friendhearth);
                                          Future.delayed(
                                              Duration(
                                                  milliseconds: 10000), () async {
                                            OPENWORLD.Mob.placeBeforeCamera(
                                              friendhearth, 0.08, offset: -0.03,
                                              time: 3,
                                              action: "walk",
                                              stopaction: "idle",
                                              //   level: 1
                                            );
                                            OPENWORLD.Mob.setSpeech(
                                                friendhearth, [
                                              "The superintendent gets the key",
                                              "from under the slab and",
                                              "unlocks the wicket door."
                                            ], z: 80,
                                                width: 300,
                                                scale: 0.2,
                                                randwait: 0,
                                                clearwhendone: true,
                                                delay: 3);

                                            // friend puts his turban back on
                                            OPENWORLD.Actor.playActionThen(
                                                friendhearth, "armsup", "idle",
                                                delay: 4);
                                            //    OPENWORLD.Actor.unwieldAll(friendhearth, delay: 5);
                                            OPENWORLD.Actor.unwield(
                                                friendhearth, "Bip01_R_Hand",
                                                delay: 5);
                                            Future.delayed(Duration(
                                                milliseconds: 5000), () async {
                                              OPENWORLD.Texture.setMaterial(
                                                  friendhearth,
                                                  friendhearth.extra['turban'],
                                                  groupname: "citizen_3");
                                            });
                                          });
                                        };
                                        actions.add(
                                            { "time": 20 }); // time waiting for lottery to end
                                        actions.add({
                                          "p": [0.95, 2.37, 0],
                                          "v": 0.02,
                                          "callback": (actor) { //0.96,2.33,0
                                            // OPENWORLD.Actor.playAction(
                                            //    superintendent, action: "idlehold",randomduration:0.1,duration:4);
                                            OPENWORLD.Space.facePointLerp(
                                                superintendent, superlotteryx,
                                                superlotteryy,
                                                1.0);
                                          }
                                          // now step back to remove the key
                                        });
                                        actions.add(
                                            { "action": "idlehold", "time": 2 }); //
                                        actions.add({
                                          "time": 2,
                                          "callback": (actor) async {
                                            // Slide slab back
                                            OPENWORLD.Actor.playAction(superintendent, action: "stoopidle");
                                            OPENWORLD.Space.objTurnLerp(
                                                superintendent, 270 - 45, 1,
                                                delay: 1);
                                            OPENWORLD.Space.objTurnLerp(
                                                superintendent, 270, 1,
                                                delay: 4);
                                            OPENWORLD.Space
                                                .worldToLocalSurfaceObjLerp(
                                                slabkey, 0.91, 2.33, 0, 1.0,
                                                level: 1,
                                                delay: 1); // slide slab north
                                            OPENWORLD.Sound.play(
                                                path: 'sounds/dragslab.mp3',
                                                delay: 1);

                                            // OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                            //    slabkey, 0.91,2.37-0.044, 0, 1.0, level: 1,delay:1);  // slide slab north

                                            OPENWORLD.Actor.playAction(
                                                superintendent,
                                                action: "squatwork",
                                                delay: 5);

                                            var key = await OPENWORLD.Model
                                                .createModel(
                                                'assets/models/key.glb');
                                            key.scale.setValues(7.0, 7.0, 7.0);
                                            OPENWORLD.Space.setTurnPitchRoll(
                                                key, 90, -90, 0);
                                            OPENWORLD.Texture.setMaterial(
                                                key, bronzematclean!,
                                                groupname: "key");

                                            OPENWORLD.Actor.wield(
                                                superintendent, key,
                                                "Bip01_L_Hand",
                                                delay: 6);
                                            OPENWORLD.Space.faceObjectLerp( friendhearth, superintendent, 1.0);
                                            for (var priestlot in priestlots)
                                              OPENWORLD.Space.faceObjectAlways(priestlot, superintendent);
                                          }
                                        });
                                        actions.add(
                                            {"time": 10}); // time getting key
                                        actions.add(
                                            {"action": "idlehold", "time": 5});
                                        actions.add({
                                          "p": [0.88, 2.18 + 0.02, 0],
                                          "v": 0.02,
                                          "t": 270 - 45,
                                          "callback": (actor) {}
                                        }); // at the door
                                        actions.add({
                                          "action": "work",
                                          "time": 10,
                                          "t": 180,
                                          "callback": (actor) {
                                            //  OPENWORLD.Space.objTurnLerp(superintendent, 0, 1);
                                            // OPENWORLD.Space.setTurnPitchRoll(
                                            //OPENWORLD.Space.objTurnLerp(doorgold, 180, 1,);
                                            // Door south hearth gets opened
                                            doorwaysouthhearth.setOpenClose(true);
                                            OPENWORLD.Sound.play(path: 'sounds/doorlarge.mp3');
                                          }
                                        });
                                        actions.add({
                                          "p": [0.95, 2.37, 0],
                                          "v": 0.02,
                                          "t": 90 - 20,
                                          "callback": (actor) {
                                            //  OPENWORLD.Space.facePointLerp(superintendent, superlotteryx, superlotteryy, 1.0);

                                          }
                                          // return to the slab to put it back
                                        });
                                        actions.add({
                                          "action": "stoopidle",
                                          "time": 5,
                                          "t": 270 - 45,
                                          "callback": (actor) {
                                            OPENWORLD.Actor.unwield(
                                                superintendent, "Bip01_L_Hand",
                                                delay: 1); // drop the key
                                            OPENWORLD.Space
                                                .worldToLocalSurfaceObjLerp(
                                                slabkey, 0.91, 2.37 + 0.004,
                                                -0.003,
                                                1.0,
                                                level: 1,
                                                delay: 2); //0.91,2.33, 0, 1.0, level: 1,delay:2);  // slide slab back over
                                            OPENWORLD.Sound.play(
                                                path: 'sounds/dragslab.mp3',
                                                delay: 2);

                                            OPENWORLD.Space.facePointLerp(
                                                superintendent, superlotteryx,
                                                superlotteryy,
                                                1.0,
                                                delay: 2);
                                            OPENWORLD.Actor.playAction(
                                                superintendent,
                                                action: "idlehold",
                                                delay: 5);
                                          }
                                        });
                                        actions.add(
                                            {"time": 10, "callback": (actor) {
                                              tosecurity();
                                            }
                                            });

                                        //   actions.add({"p": [0.95+0.02,2.37,0],"v":0.01});  // move back as slide


                                        OPENWORLD.Mob.moveToLoop(
                                          superintendent,
                                          facedir: false,
                                          actions,
                                          action: "walkhandright",
                                          //traight",
                                          level: 1,
                                          //  stopaction:"idle",
                                          //  reset:true,
                                          looptype: OPENWORLD.Mob.LoopTypeStop,
                                          surfaceonly: true,

                                          //   delay:10+i*(10+OPENWORLD.Math.random()*10)

                                        );
                                      }
                                  );
                                }

                                // Allow the restart of the lottery
                                lotteryreset() async {
                                  print("lottery start");
                                  OPENWORLD.Space.worldToLocalSurfaceObj(
                                      threeJs.camera, playerlotterystartposx,
                                      playerlotterystartposy,
                                      OPENWORLD.Camera.cameraoffset, level: 1);
                                  await dresspriests();
                                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                      superintendent, superlotteryx,
                                      superlotteryy,
                                      0,
                                      level: 1,
                                     5);; // why was hidedist 2  ); //priestposs[0][0],priestposs[0][1], 0.00,level:1, 2); //, level:1);  1.5, 3.5
                                  _hotload.add(superintendent);
                                  OPENWORLD.Space.objTurn(superintendent, 45);
                                  OPENWORLD.Space.faceObject(
                                      threeJs.camera,
                                      superintendent); //,superintendent,1);

                                  // OPENWORLD.Space.faceObjectLerp(threeJs.camera,superintendent,1);//,superintendent,1);
                                  print(
                                      "priest lots length" +
                                          priestlots.length.toString());
                                  for (var i = 0; i < priestlots.length; i++) {
                                    var priestlot = priestlots[i];
                                    // if (priestlot==friendhearth)
                                    //   print("found friend"+i.toString());
                                    OPENWORLD.Actor
                                        .removeObjectFromPlayActionsLoop(
                                        priestlot);

                                    OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                        priestlot, poslots[i][0], poslots[i][1],
                                        0,
                                        level: 1,
                                        2); //, level:1);
                                    OPENWORLD.Space.faceObjectAlways(priestlot, superintendent); //,superintendent,1);
                                    OPENWORLD.Actor.playAction(
                                        priestlot, action: "idle");
                                  }
                                  priestlots.remove(
                                      friendhearth); // Only put him in so can clothe him properly and is in correct position
                                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                      priestkey, priestkeyfinalposx,
                                      priestkeyfinalposy,
                                      0,
                                      level: 1,
                                      2); //, level:1);
                                  OPENWORLD.Space.faceObjectLerp( priestkey, superintendent, 1); //,superintendent,1);


                                  priestgroundstolottery();
                                  priestsleepstoground();

                                  friendcloth();
                                  OPENWORLD.Space.resetRot(friendhearth);
                                  OPENWORLD.Space.setZ(
                                      friendhearth, 0, level: 1);

                                  OPENWORLD.BaseObject.setVisible(beddingkey,
                                      false);
                                  // OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                  //      friendhearth, poslots[7][0],poslots[7][1],0,level:1, 2); //, level:1);

                                  //Future.delayed(
                                  //    Duration(milliseconds: 10000), () async {
                                  callwhenloaded(() {
                                    lottery();
                                  });
                                 // });
                                }
                                if (gamestart == GameStart.hearth &&
                                    gamestartpos[gamestart]['progress'].contains('tolottery')) {
                                  print("lotteryreset start");
                                  // Game restart where if have moved to the lottery the start the lottery
                                  lotteryreset();
                                } else {
                                  // Priests walk to the chamber of hearth lottery
                                  tolottery() async
                                  {
                                    saveGameState('mikveh');  // have done mikveh
                                    OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1);
                                    if (friendisclose())
                                      OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1);

                                    // You friend should put his arms up when puts clothes on
                                    OPENWORLD.Actor.playActionThen(
                                        friendhearth, "hitup", "idle");
                                    friendcloth();

                                    OPENWORLD.Mob.setSpeech(friendhearth, [
                                      "The superintendant",
                                      "should knock soon.",
                                      'Then the lottery will start',
                                      'for the Terumat HaDeshen',
                                      'to clear the ashes from the altar.',
                                      'Thats him now'], z: 80,
                                      width: 300,
                                      scale: 0.4,
                                      randwait: 0,
                                      clearwhendone: true,
                                      //  delay:8
                                    );


                                    OPENWORLD.Space.worldToLocalSurfaceObjHide(
                                        superintendent, 0.85, 2.48, 0, level: 1,
                                       5);// why was this 2); //priestposs[0][0],priestposs[0][1], 0.00,level:1, 2); //, level:1);
                                    _hotload.add(superintendent);
                                    OPENWORLD.Space.objTurn(superintendent, 0);
                                    OPENWORLD.Mob.moveToLoop(
                                      superintendent,
                                      [
                                        {"p": [1.5, 3.5, 0], "v": 0.02},
                                        //,null,1],
                                        {"p": [0.92, 3.42, 0], "v": 0.02,
                                          'callback': (actor) {
                                            OPENWORLD.Space.faceObjectLerp(friendhearth, superintendent, 1.0);
                                            print("superintendent knocks");
                                            OPENWORLD.Sound.play(path: 'sounds/knock.mp3'); //, volume: 0.2);
                                            //     OPENWORLD.Space.faceObjectLerp(threeJs.camera,superintendent, 1.0, delay:2);
                                            OPENWORLD.Space.objTurnLerp(
                                                threeJs.camera, 0, 2);
                                            OPENWORLD.Space.objTurnLerp(actor, 180, 2);
                                            OPENWORLD.Actor.playActionThen(
                                                dooropenereast, "kneel", "idle",
                                                delay: 2);
                                            OPENWORLD.Space.resetRot(
                                                dooropenereast);
                                            OPENWORLD.Space.setZ(
                                                dooropenereast, 0, level: 1);
                                            OPENWORLD.Space.resetRot(
                                                dooropenerwest);
                                            OPENWORLD.Space.setZ(
                                                dooropenerwest, 0, level: 1);
                                            OPENWORLD.Mob.moveTo(
                                                dooropenereast,
                                                [
                                                  [0.92 + 0.015, 3.33, 0, 0.02]
                                                  //                      [0.97,3.33, 0,0.02]
                                                ], action: "walk",
                                                stopaction: "idle",
                                                surfaceonly: true,
                                                level: 1,
                                                callbackonfinish: (dooropener) {
                                                  // OPENWORLD.Space.objTurnLerp(dooropener,0,1);
                                                  OPENWORLD.Space.faceObjectAlways(dooropener, superintendent);

                                                  OPENWORLD.Actor.playAction(
                                                      dooropener,
                                                      action: "armsup");
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 2100), () async {
                                                    OPENWORLD.Actor.playAction(
                                                        dooropener,
                                                        action: "walk");
                                                    OPENWORLD.Actor.playAction(
                                                        dooropener,
                                                        action: "idle",
                                                        randomduration: 0.1,
                                                        delay: 1);
                                                    //     OPENWORLD.Actor.playActionThen(actor, "walk", "idle", duration:1, delay:1);
                                                    OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                                                        dooropener,
                                                        0.92 + 0.015 + 0.02,
                                                        3.33 - 0.06,
                                                        0,
                                                        1.0, level: 1);
                                                    OPENWORLD.Space.objTurnLerp(doorwoodhearthnortheast, 20,
                                                        1);
                                                    doorwayhearth.obstacle.enabled=false;//true;
                                                  });
                                                },
                                                delay: 4
                                            );
                                            OPENWORLD.Actor.playActionThen(dooropenerwest, "kneel", "idle",
                                                delay: 3.1);
                                            OPENWORLD.Mob.moveTo(
                                                dooropenerwest,
                                                [
                                                  [0.87 + 0.015, 3.33, 0, 0.02]
                                                ], action: "walk",
                                                stopaction: "idle",
                                                surfaceonly: true,
                                                level: 1,
                                                callbackonfinish: (dooropener) {
                                                  // OPENWORLD.Space.objTurnLerp(dooropener,0,1);
                                                  OPENWORLD.Space.faceObjectAlways(dooropener, superintendent);
                                                  //   OPENWORLD.Actor.playAction(actor,  action:"die",delay:1);
                                                  //                      OPENWORLD.Actor.playAction(actor,loopmode:THREE.LoopRepeat,  action:"die",delay:1);
                                                  OPENWORLD.Actor.playAction(dooropener, action: "armsup");
                                                  Future.delayed(
                                                      Duration(
                                                          milliseconds: 1000), () async {
                                                    OPENWORLD.Actor.playAction(dooropener, action: "walk");
                                                    // OPENWORLD.Actor.playAction(
                                                    //    actor, action: "idle", delay: 1);
                                                    OPENWORLD.Actor
                                                        .playActionThen(
                                                        dooropener, "wave",
                                                        "idle",
                                                        duration: 2,
                                                        delay: 1);
                                                    OPENWORLD.Space.worldToLocalSurfaceObjLerp(dooropener,
                                                        0.87 + 0.015 - 0.02,
                                                        3.33 - 0.06,
                                                        0,
                                                        1.0, level: 1);
                                                    OPENWORLD.Space.objTurnLerp(doorwoodhearthnorthwest, -20, 1);
                                                    OPENWORLD.Space .faceObjectLerp( friendhearth, superintendent, 1.0);
                                                    OPENWORLD.Actor
                                                        .playActionThen(
                                                        friendhearth, "wave",
                                                        "idle",
                                                        duration: 2,
                                                        delay: 10);
                                                    // north Doors in hewnstone get opened
                                                    OPENWORLD.Sound.play(path: 'sounds/doorlarge.mp3'); //, volume: 0.2);

                                                  });
                                                },
                                                delay: 7
                                            );
                                          },},
                                        //,null,0],
                                        {"action": "idlehold", "time": 19},
                                        {"action": "wave", "time": 2},
                                        // super intendant waves
                                        {
                                          "p": [0.90, 3.16 + 0.03, 0],
                                          "v": 0.02,
                                          'callback': (actor) {
                                            for (var priest in priestlots) {
                                              OPENWORLD.Actor
                                                  .removeObjectFromPlayActionsLoop(
                                                  priest);
                                              OPENWORLD.Actor.playAction(
                                                  priest, action: "idle",
                                                  delay: 1);
                                              OPENWORLD.Space.faceObjectAlways(priest, superintendent);
                                            }

                                            OPENWORLD.Actor.playActionThen(
                                                superintendent, "lookleft",
                                                "idlehold");
                                            OPENWORLD.Actor.playActionThen(
                                                superintendent, "lookright",
                                                "idlehold",
                                                delay: 2);
                                            OPENWORLD.Mob.setSpeech(
                                                superintendent,
                                                [
                                                  "Whoever has immersed,",
                                                  "come and cast lots."
                                                ],
                                                z: 90,
                                                width: 300,
                                                scale: 0.4,
                                                randwait: 0,
                                                clearwhendone: true,
                                                delay: 3
                                            );
                                          }
                                        },
                                        //super intendant tell everyone about casting lots
                                        {"action": "idlehold", "time": 8},
                                        { "action": "lookleft", "time": 2, "t": 160 },
                                        {"action": "idlehold", "time": 8},
                                        { "action": "lookright", "time": 2, "t": 200 },
                                        {"action": "idlehold", "time": 4},
                                        // super intendant looks around
                                        {
                                          "p": [0.85 - 0.02, 3.05, 0],
                                          "v": 0.03,
                                          "callback": (actor) {
                                            // Now you watch the super intendant go to the lottery
                                            if (friendisclose())
                                              OPENWORLD.Space.faceObjectAlways(threeJs.camera, superintendent);
                                          }
                                        },
                                        // superintendant past the fire
                                        {"p": [0.87, 2.95, 0], "v": 0.03, },// superintendant  past the fire center
                                        {
                                          "p": [0.92, 2.57, 0],
                                          "v": 0.03,
                                          "callback": (actor) {
                                            // Callback when superintendant at top of steps
                                            // Ring around the superintendant
                                            // Looks like where priests walk up steps to the lottery in the chamber of hewnstone
                                            // Sort them so the closest leave first so dont walk through eachother
                                            // Why did you comment this out?  - possibly becuase it doesn't work - still walks through everyone
                                          /*  for (var priest in priestlots) {
                                              priest.extra['dist'] = OPENWORLD.Space.getDistanceBetweenObjs2D(priest,superintendent);// doorwaysouthhearth);
                                             // securitypriest.extra.remove('hittrigger');
                                            }
                                          //  var priestlotsorted=[];
                                          //  for (var priest in priestlots)
                                          //    priestlotsorted.add(priest);
                                            priestlots.sort((a, b) {
                                         //   priestlotsorted.sort((a, b) {
                                              num distA = a.extra['dist'] ?? 0;
                                              num distB = b.extra['dist'] ?? 0;
                                              //   return distB.compareTo(distA);
                                              return distA.compareTo(distB);
                                            });*/

                                            for (var i = 0; i < priestlots.length; i++) {
                                              var priestlot = priestlots[i];
                                              var priestpos = OPENWORLD.Space.localToWorldObj(priestlot);
                                              var startpos = [];
                                              if (priestpos.x > 1.07)
                                                startpos = [1.07, priestpos.y, 0, 0.02];
                                              else if (priestpos.y < 0.74)
                                                startpos = [0.74, priestpos.y, 0, 0.02];
                                              else
                                                startpos = [priestpos.x, priestpos.y, 0, 0.02];
                                              var lastpos = [
                                                poslots[i][0],
                                                poslots[i][1],
                                                0,
                                                0.02
                                              ];
                                              OPENWORLD.Mob.moveTo(priestlot, [
                                                startpos,
                                                [ startpos[0], 2.8, 0, 0.02],   // bottom of steps
                                                [ startpos[0], 2.57, 0, 0.02],   // top of steps
                                                [ startpos[0], lastpos[1], 0, 0.02],   // Stop priests overlapping with eachother
                                            //    [ lastpos[0], 2.57, 0, 0.02],   // top of steps
                                                lastpos
                                              ], action: "walk",
                                                  level: 1,
                                                  surfaceonly: true,
                                                  stopaction: "idle",
                                                  callbackonfinish: (actor) {
                                                    //  OPENWORLD.Space.faceObjectLerp(priestkey,superintendent,1);
                                                  },
                                                  delay: i *  1.5
                                              );
                                            }
                                            // Move your friend seperately
                                            OPENWORLD.Mob.moveTo(
                                                friendhearth, [
                                              [0.87, 2.95, 0, 0.02],
                                              // your friend past the fire
                                              [ 0.85, 2.48, 0, 0.02],
                                              // final spot where your friend talks to you near the lottery   0.8, 2.4
                                            ], action: "walk",
                                                level: 1,
                                                surfaceonly: true,
                                                stopaction: "idle",
                                                callbackonfinish: (actor) {
                                                  // When your friend reaches his spot
                                                  friendhearth.extra['followhearth'] = false;

                                                  //0.78, 2.50  0.76, 2.52
                                                  // Final place where you watch the lottery
                                                  if (friendisclose())
                                                     OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp( threeJs.camera, playerlotterystartposx, playerlotterystartposy, OPENWORLD.Camera .cameraoffset, 1.0, level: 1, delay: 1);

                                                  OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 2); //,superintendent,1);
                                                  OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 15); //,superintendent,1);
                                                  if (friendisclose())
                                                    OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1, delay: 2); //,superintendent,1);

                                                  OPENWORLD.Mob.setSpeech(
                                                      friendhearth, [
                                                    "Now the superintendant casts lots",
                                                    "He chooses a priest at random",
                                                    "and picks a large random number",
                                                    "counting that number until the",
                                                    "final priest is reached.",
                                                    "And that priest is the winner.",
                                                    "Maybe you watch this time.",
                                                    "I'm going to try the lottery.",
                                                    "Wish me luck"
                                                  ], z: 90,
                                                      width: 300,
                                                      scale: 0.3,
                                                      randwait: 0,
                                                      clearwhendone: true,
                                                      callbackonfinish: (
                                                          actor) {
                                                        OPENWORLD.Mob.moveTo(
                                                            friendhearth, [
                                                          [0.91, 2.41, 0, 0.02],
                                                          // take his spot at the lottery
                                                        ], action: "walk",
                                                            level: 1,
                                                            surfaceonly: true,
                                                            stopaction: "idle",
                                                            callbackonfinish: (
                                                                actor) {
                                                              //OPENWORLD.Actor.playAction(
                                                              //    friendhearth, action: "idlehold");
                                                              OPENWORLD.Space .faceObjectLerp( friendhearth, superintendent, 1.0);
                                                            }
                                                        );
                                                      }

                                                    //   delay: 3
                                                  );


                                                  for (var i = 0; i < priestgrounds.length; i++) {
                                                    var priestground = priestgrounds[i];
                                                    OPENWORLD.Space.removeFaceObjectAlways(priestground);
                                                    OPENWORLD.Space.resetRot(
                                                        priestground);
                                                    OPENWORLD.Space.setZ(
                                                        priestground, 0,
                                                        level: 1);
                                                    OPENWORLD.Actor
                                                        .playActionThen(
                                                        priestground, "kneel",
                                                        "idle");
                                                    var priestpos = OPENWORLD.Space.localToWorldObj(
                                                        priestground);
                                                    var startpos = [];
                                                    if (priestpos.x > 1.07)
                                                      startpos =
                                                      [1.07, priestpos.y, 0, 0.02];
                                                    else if (priestpos.y < 0.74)
                                                      startpos =
                                                      [0.74, priestpos.y, 0, 0.02
                                                      ];
                                                    else
                                                      startpos = [priestpos.x, priestpos.y, 0, 0.02];
                                                    var lastpos = [posgrounds[i][0], posgrounds[i][1],
                                                      0,
                                                      0.02
                                                    ];
                                                    OPENWORLD.Mob.moveTo(
                                                        priestground, [
                                                      startpos,
                                                      [
                                                        lastpos[0], 2.57, 0, 0.02
                                                      ],
                                                      lastpos
                                                    ], action: "walk",
                                                        level: 1,
                                                        surfaceonly: true,
                                                        stopaction: "idle",
                                                        callbackonfinish: (
                                                            actor) {
                                                          OPENWORLD.Space .faceObjectLerp( actor, superintendent, 1);
                                                        },
                                                        delay: i
                                                    );
                                                  }
                                                  // Move priests that are in the cubicles onto the ground
                                                  priestsleepstoground();
                                                },
                                                delay: 5
                                            );
                                            // Priest on key gets up and leaves
                                            OPENWORLD.Actor.playActionThen(
                                                priestkey, "stoopidle", "idle");
                                            OPENWORLD.BaseObject.setVisible(
                                                beddingkey, false, delay: 2);
                                            var priestkeypos = OPENWORLD.Space
                                                .localToWorldObj(
                                                priestkey);
                                            OPENWORLD.Space
                                                .worldToLocalSurfaceObj(
                                                priestkey, priestkeypos.x,
                                                priestkeypos.y + 0.01,
                                                0.0,
                                                level: 1);
                                            OPENWORLD.Mob.moveTo(priestkey,
                                                [ [priestkeyfinalposx, priestkeyfinalposy, 0, 0.02]
                                                ],
                                                action: "walkstraight",
                                                level: 1,
                                                surfaceonly: true,
                                                stopaction: "idle",
                                                callbackonfinish: (priestkey) {
                                                  OPENWORLD.Space.faceObjectLerp(priestkey, superintendent, 1);
                                                },
                                                delay: 3
                                            );
                                          }
                                        },
                                        // super intendant top of steps
                                        {
                                          "p": [superlotteryx, superlotteryy, 0], "v": 0.03,
                                          "callback": (actor) { //0.92, 2.43
                                            OPENWORLD.Actor.playAction(
                                                superintendent,
                                                action: "idlehold");
                                            OPENWORLD.Space.objTurnLerp(
                                                superintendent, 0, 1);

                                            OPENWORLD.Space.removeFaceObjectAlways(threeJs.camera);
                                            friendhearth.extra['followhearth'] = true;
                                          }
                                        },
                                        // super intendant at key
                                        { "action": "idlehold", "t": 0, "time": 80 },
                                        {
                                          "action": "idlehold",
                                          "t": 45,
                                          "time": 10,
                                          "callback": (actor) {
                                            // Start the lottery now everyone is in a circle


                                            lottery();
                                          }
                                        },
                                        {"action": "idlehold", "time": 20},
                                        // wait till start of lottery and start spinning and counting
                                      ],
                                      action: "walkhandright", //traight",
                                      level: 1,
                                      //  stopaction:"idle",
                                      //  reset:true,
                                      looptype: OPENWORLD.Mob.LoopTypeStop,
                                      surfaceonly: true,
                                    );
                                  }

                                  // Game restart for moving to the lottery
                                  tolotteryreset() async {
                                    var friendpos = OPENWORLD.Space.localToWorldObj(friendhearth);

                                    OPENWORLD.Space.resetRot(friendhearth);
                                    OPENWORLD.Space .worldToLocalSurfaceOnlyObjLerp( friendhearth, friendpos.x, friendpos.y + 0.01, 0, 1.0, level: 1);

                                    OPENWORLD.Actor.playActionThen(
                                        friendhearth, "kneel", "idle");
                                    OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 3);
                                    OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 5);
                                    if (friendisclose())
                                      OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1, delay: 3);

                                    var pos = [
                                      [1.18, 2.81, 0],
                                      [1.17, 2.90, 0],
                                      [ 0.70, 2.85, 0],
                                      [ 0.68, 3.02, 0]
                                    ]; //[ 0.70, 2.85, 0, 0.03]);
                                    for (var i = 0; i < 4; i++) {
                                      priest = await OPENWORLD.Actor.copyActor(
                                        //      priestlist[i % priestlist.length], randomduration: 0.2);
                                          priestlist[(i + 4) % priestlist.length].extra['clothed'],
                                          randomduration: 0.2);
                                      priest.extra['robes'] = priestlist[(i + 4) % priestlist.length];
                                      priest.extra['robes'].extra['clothed']=priestlist[(i + 4) % priestlist.length].extra['clothed'];
                                      priest.extra['clothed']=priestlist[(i + 4) % priestlist.length].extra['clothed'];
                                      OPENWORLD.Space
                                          .worldToLocalSurfaceObjHide(
                                          priest, pos[i][0], pos[i][1], 0,
                                          level: 1,
                                          2); //, level:1);

                                      // part of lotterysetset
                                      priestlots.add(priest);
                                      _hotload.add(priest);

                                      // Put your robes on
                                      var mat1 = OPENWORLD.Texture.getMaterialByGroupname(priest.extra['robes'], "citizen_2");
                                      var mat2 = OPENWORLD.Texture
                                          .getMaterialByGroupname(
                                          priest.extra['robes'], "citizen_1");
                                      var mathead = OPENWORLD.Texture
                                          .getMaterialByGroupname(
                                          priest.extra['robes'], "citizen_3");
                                      OPENWORLD.Texture.setMaterial(
                                          priest, mat1, groupname: "citizen_2");
                                      OPENWORLD.Texture.setMaterial(
                                          priest, mat2, groupname: "citizen_1");
                                      OPENWORLD.Texture.setMaterial(
                                          priest, mathead,
                                          groupname: "citizen_3");
                                      // To lottery reset priests hitup etc
                                      OPENWORLD.Actor.playActionsLoop(priest, ["stoopidle", "armsup", "hitup", "stoopidle", "kneel", "idle",

                                      ], randomaction: true,
                                          durations: [10, 5, 5, 10, 5, 10]);
                                    }

                                    callwhenloaded(() {
                                      tolottery();
                                    });
                                  }

                                  if (gamestart == GameStart.hearth &&
                                      gamestartpos[gamestart]['progress'].contains('mikveh')) {
                                    // Game restart where if done the mikveh then go to the lottery
                                    tolotteryreset();
                                  } else {
                                    // Bathe in the mikveh with your friend
                                    mikveh() async
                                    {
                                      // Hide the default people in the mikveh
                                      var friendpos = OPENWORLD.Space.localToWorldObj(friendhearth);

                                      OPENWORLD.Space.resetRot(friendhearth);
                                      OPENWORLD.Space .worldToLocalSurfaceOnlyObjLerp( friendhearth, friendpos.x, friendpos.y + 0.01, 0, 1.0, level: 1);

                                      OPENWORLD.Actor.playActionThen(friendhearth, "kneel", "idle");
                                      OPENWORLD.Space.faceObjectLerp(friendhearth, threeJs.camera, 1, delay: 3);
                                      OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 5);
                                      if (friendisclose())
                                        OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1, delay: 3);

                                      bather.visible = false;
                                      priestwarming.visible = false;
                                      waiter.visible = false;
                                      clothespilemikveh.visible = false;

                                      OPENWORLD.Space.removeObjFromHide(bather);
                                      OPENWORLD.Space.removeObjFromHide(
                                          priestwarming);
                                      OPENWORLD.Space.removeObjFromHide(waiter);
                                      OPENWORLD.Space.removeObjFromHide(
                                          clothespilemikveh);

                                      // The priests coming up from the mikveh
                                      var priestposs = [
                                        [0.55, 3.27],
                                        [0.63, 3.11],
                                        //0.66, 3.06], //0.91, 3.23],
                                        [ 0.72, 2.99],
                                        //1.05, 2.87],
                                        [0.77, 2.89],
                                        // [0.91, 2.10],
                                        //  [2.68, 1.87]
                                      ];
                                      List<Map> pos = [];
                                      for (var priestpos in priestposs)
                                        //  pos.add( [priestpos[0], priestpos[1], 0,0.03]);
                                        pos.add({ "p": [priestpos[0], priestpos[1], 0], "l": 1, "v": 0.03 });
                                      //  pos.add({ "action": "idle3", "time": 1});
                                      //  priests from the mikveh make their way up
                                      for (var i = 0; i < 4; i++) {
                                        //List<List> poscopy=pos.toList();
                                        List<Map> poscopy = pos.toList();
                                        poscopy.insert(1, { "action": "idle3", "time": i * (10 + OPENWORLD.Math.random() * 10) });
//              poscopy.insert(1,{"action":"idle3","time":10+i*(10+OPENWORLD.Math.random()*10)});
                                        var lastpos = {};
                                        if (i == 0)
                                          lastpos = { "p": [1.18, 2.81, 0], "l": 1, "v": 0.03 };
                                        // poscopy.add([1.18, 2.81, 0, 0.03]);
                                        else if (i == 1)
                                          lastpos = { "p": [1.17, 2.90, 0], "l": 1, "v": 0.03 };
                                        //  poscopy.add([1.17, 2.90, 0, 0.03]);
                                        else if (i == 2)
                                          lastpos = { "p": [ 0.70, 2.85, 0], "l": 1, "v": 0.03 }; //[ 0.70, 2.85, 0, 0.03]);
                                        else if (i == 3)
                                          lastpos = { "p": [ 0.68, 3.02, 0], "l": 1, "v": 0.03 }; //[ 0.70, 2.85, 0, 0.03]);
                                        poscopy.add(lastpos);
                                        poscopy.add(
                                            { "action": "stoopidle", "time": 10 });
                                        poscopy.add(
                                            {"action": "armsup", "time": 5});
                                        poscopy.add(
                                            {"action": "hitup", "time": 5});
                                        poscopy.add(
                                            { "action": "stoopidle", "time": 10 });
                                        poscopy.add(
                                            {"action": "kneel", "time": 5});
                                        // part of mikveh
                                        // 85 i last inc - help with duplicates?
                                        priest = await OPENWORLD.Actor.copyActor(priestlist[(i + 1+85) % priestlist.length].extra['clothed'], randomduration: 0.2);

                                        priestlots.add(priest);

                                        priest.extra['robes'] = priestlist[i % priestlist.length];
                                        priest.extra['robes'].extra['clothed']=priestlist[(i + 1+85) % priestlist.length].extra['clothed'];
                                        priest.extra['clothed']=priestlist[(i + 1+85) % priestlist.length].extra['clothed'];
                                        poscopy.add(
                                            {"action": "idle", "time": 10,
                                              "callback": (actor) {
                                                // Put your robes on
                                                var mat1 = OPENWORLD.Texture.getMaterialByGroupname(actor.extra['robes'], "citizen_2");
                                                var mat2 = OPENWORLD.Texture.getMaterialByGroupname(actor.extra['robes'], "citizen_1");
                                                var mathead = OPENWORLD.Texture
                                                    .getMaterialByGroupname(
                                                    priest.extra['robes'],
                                                    "citizen_3");
                                                OPENWORLD.Texture.setMaterial(
                                                    actor, mat1,
                                                    groupname: "citizen_2");
                                                OPENWORLD.Texture.setMaterial(
                                                    actor, mat2,
                                                    groupname: "citizen_1");
                                                OPENWORLD.Texture.setMaterial(
                                                    actor, mathead,
                                                    groupname: "citizen_3");
                                                OPENWORLD.Actor.playActionsLoop(
                                                    actor, ["stoopidle", "armsup", "hitup", "stoopidle", "kneel", "idle"
                                                ], durations: [10, 5, 5, 10, 5, 10
                                                ]);
                                              }
                                            });

                                        //setcancollide(priest,true);
                                        OPENWORLD.Space
                                            .worldToLocalSurfaceObjHide(
                                            priest, priestposs[0][0],
                                            priestposs[0][1],
                                            0.00,
                                            level: 1,
                                            2); //, level:1);

                                        _hotload.add(priest);

                                        OPENWORLD.Mob.moveToLoop(
                                            priest, poscopy, action: "walk",
                                            //straight",
                                            looptype: OPENWORLD.Mob.LoopTypeStop,
                                            // level:1,
                                            surfaceonly: true

                                        );
                                      }

                                      OPENWORLD.Space.objTurnLerp(friendhearth, 180, 1, delay: 7); // Make it look like your friend is looking priests coming past
                                      OPENWORLD.Space.faceObjectLerp( friendhearth, threeJs.camera, 1, delay: 10);
                                      if (friendisclose())
                                        OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(threeJs.camera, 0.83, 2.97, OPENWORLD.Camera.cameraoffset, 1.0, level: 1);
                                      Glob.mikvehportal.lerp=15.0;
                                      OPENWORLD.Mob.setSpeech(friendhearth, [
                                        "Shalom",
                                        "Sleep well?",
                                        'Everyones getting ready',
                                        'for the superintendent to come',
                                        'for the first lottery.',
                                        "I'll show you the mikveh",
                                        "We'll just wait for the",
                                        "other priests",
                                        "to finish",], z: 80,
                                          width: 300,
                                          scale: 0.4,
                                          randwait: 0,
                                          clearwhendone: true,
                                          delay: 3,
                                          callbackonfinish: (actor) {
                                            friendhearth.extra['followhearth'] = true;
                                            OPENWORLD.Mob.moveToLoop(
                                              friendhearth,
                                              [
                                                { "p": [ friendpos.x, friendpos.y, 0 ], "v": 0.01 },
                                                {"p": [0.63, 3.1, 0], "v": 0.01, "callback":(actor){  // entrance to mikveh
                                                  // Make sure you are in the correct place so can follow down the stairs
                                              //    print("----------------mikveh top of steps");
                                                  if (friendisclose()){
                                                    OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp( threeJs.camera, 0.63, 3.1, OPENWORLD.Camera.cameraoffset, 1.0, level: 1, delay: 2);
                                                    OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera, 0.63, 3.1, OPENWORLD.Camera.cameraoffset, level: 1, delay: 3);
                                                  }

                                                }
                                                },
                                                {
                                                  "p": [0.64, 3.34, 0],   // bottom of mikveh steps
                                                  "v": 0.015,
                                                  "callback": (actor) {
                                                 //   print("--------mikveh bottom of steps");
                                                    var addseconds=0;
                                                    Glob.mikvehportal.lerp=3.0;
                                                    friendhearth.extra['followhearth'] = false; // So stay in the same place
                                                    // Move you to the bottom of mikveh stairs
                                                    //OPENWORLD.Space .worldToLocalSurfaceOnlyObjLerp( threeJs.camera, 0.64, 3.34, OPENWORLD.Camera .cameraoffset, 1.0, level: 1, delay: 2+1+addseconds);
                                                  //  OPENWORLD.Space.worldToLocalSurfaceObj(threeJs.camera, 0.64, 3.34, OPENWORLD.Camera.cameraoffset,
                                                    //    level: 1,
                                                    //    delay: 3+1+addseconds);
                                                    if (friendisclose())
                                                      OPENWORLD.Space.faceObjectLerp( threeJs.camera, friendhearth, 1.0, delay: 3+addseconds);
                                                    if (friendisclose())
                                                      OPENWORLD.Space.faceObjectLerp(threeJs.camera, friendhearth, 1.0, delay: 5+addseconds);
                                                  }
                                                },

                                                { "p": [0.6, 3.34, 0], "v": 0.02, "callback":(actor){
                                                  //print("-----------mikveh slightly accross");
                                                }
                                                },  // across slightly
                                                {"p": [0.6, 3.15, 0], "v": 0.02}, // waiter position
                                                {
                                                  "action": "stoopidle", "t": 270,
                                                  "time": 5,
                                                  "callback": (actor) {
                                                    clothespilemikveh.visible = true; // stoop to look like taking off clothes
                                                  }
                                                },
                                                {"action": "hitup", "time": 5,
                                                  "callback": (actor) {
                                                    // This is where you swap yourfriend with the bather

                                                    OPENWORLD.Space.readdObjFromHide(clothespilemikveh);
                                                    // THREE.Vector3 dog=THREE.Vector3(0,0,0);
                                                    OPENWORLD.Space.objTurn(actor, 270);
                                                    bather.position = actor.position.clone();
                                                    //     bather.rotation=actor.rotation.clone();//.setFrom(actor.rotation);
                                                    friendhearth.visible = false;
                                                    OPENWORLD.Space.removeObjFromHide(friendhearth);
                                                    //var actordpos = OPENWORLD.Space.localToWorldObj(
                                                    //     actor);

                                                    OPENWORLD.Space.readdObjFromHide(bather);
                                                    bather.visible = true;
                                                    OPENWORLD.Space.objTurn(bather, 270);
                                                    OPENWORLD.Actor.playAction(bather, action: "stoopidle");
                                                    // OPENWORLD.Space.readdObjFromHide(friendhearth);
                                                    Future.delayed(Duration(
                                                        milliseconds: 2000), () async {
                                                      print("friend enters pool");
                                                      var batherpos = OPENWORLD.Space.localToWorldObj(bather);
                                                      playSplash(delay:3);
                                                      OPENWORLD.Mob.moveToLoop(
                                                          bather, [
                                                        {"p": [batherpos.x, batherpos.y, 0], "v": 0.02},
                                                        { "p": [0.5, 3.24 + 0.02, -0.01], "v": 0.02 , "callback":(actor){  // in pool
                                                        }
                                                        },
                                                        {"action": "idle", "time": 5, "t": 180, "callback":(actor ){
                                                          if (friendisclose())
                                                            playSplash();
                                                        }
                                                        },
                                                        {"action": "squat", "t": 180, "time": 5,"callback":(actor ){
                                                          if (friendisclose())
                                                            playSplash();
                                                        }
                                                        }, // immerse
                                                        {"action": "idle", "time": 5,
                                                          "callback":(actor){
                                                            if (friendisclose())
                                                              playSplash();
                                                           // OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick( ['sounds/splash.mp3','sounds/splash2.mp3','sounds/splash3.mp3']));
                                                          }
                                                        },
                                                        {"p": [brazierposx + 0.045, brazierposy, 0], "v": 0.02},
                                                        // warm in front of the brazier
                                                        {
                                                          "action": "stoopidle",
                                                          "t": 90,
                                                          "time": 5,
                                                          "callback": (actor) {
                                                            clothespilemikveh.visible = false;
                                                            OPENWORLD.Space.removeObjFromHide(clothespilemikveh);
                                                          }
                                                        },
                                                        {
                                                          "action": "hitup",
                                                          "time": 3,
                                                          "t": 90,
                                                          "callback": (actor) {
                                                            print("friehdhearth reappears");
                                                            //  yorufriend reappears and hopefully is less than 60 seconds and the next time the next action after this for yourfiend can occur
                                                            //    -possibly need to put yourfriend z=100 to hide sot aht the movetoloop doesn't quit
                                                            bather.visible = false;
                                                            OPENWORLD.Space.removeObjFromHide(bather);
                                                            OPENWORLD.Space.readdObjFromHide(friendhearth);
                                                            friendhearth.visible = true;
                                                            //  OPENWORLD.Space.objTurn(friendhearth,90);
                                                            friendhearth.position = bather.position.clone();
                                                            OPENWORLD.Actor
                                                                .playAction(
                                                                friendhearth,
                                                                action: "hitup");
                                                            OPENWORLD.Space.objTurnLerp(friendhearth,
                                                                300,
                                                                1,
                                                                delay: 2);
                                                            OPENWORLD.Mob.setSpeech(friendhearth,
                                                                ["Your turn"],
                                                                z: 60,
                                                                width: 300,
                                                                scale: 0.4,
                                                                randwait: 0,
                                                                clearwhendone: true,
                                                                callbackonfinish: (
                                                                    actor) {
                                                                  var worldpos = OPENWORLD.You.getWorldPos();
                                                                  OPENWORLD.Mob.moveToLoop(threeJs.camera, [
                                                                        { "p": [ worldpos.x, worldpos.y, OPENWORLD.Camera.cameraoffset], "v": 0.02},
                                                                        { "p": [0.6, worldpos.y, OPENWORLD .Camera .cameraoffset ], "v": 0.02 },
                                                                        { "p": [ 0.6, 3.15, OPENWORLD.Camera.cameraoffset ], "v": 0.02 },// waiter position
                                                                        { "p": [ 0.6 + 0.001, 3.15, OPENWORLD.Camera.cameraoffset / 2 ], "v": 0.01, "t": 270},// bend down to take off clothes
                                                                        { "p": [ 0.6, 3.15, OPENWORLD.Camera.cameraoffset ], "v": 0.02, "t": -45 },// stand up again
                                                                        { "time": 5},
                                                                        {
                                                                          "p": [0.5, 3.24 + 0.02, OPENWORLD.Camera.cameraoffset], "v": 0.02, "callback": (actor) {
                                                                          if (friendisclose())
                                                                            playSplash(); // splash when you go into the water
                                                                          OPENWORLD.Camera.setPitch(15); // Looks at your friend
                                                                          }
                                                                        },
                                                                        //,"t":270},  // walk into mikveh
                                                                        {"time": 5, "t": 180,
                                                                          "callback": (actor) {
                                                                            OPENWORLD.Actor.playAction(friendhearth, action: "squat");
                                                                            OPENWORLD.Space.objTurnLerp(friendhearth, 270, 1, delay: 1);
                                                                          }
                                                                        },
                                                                        {
                                                                          "p": [0.5, 3.24 + 0.02 - 0.005, 0.75 * OPENWORLD.Camera.cameraoffset
                                                                          ], "v": 0.02, "t": 180, "callback":(actor){
                                                                          if (friendisclose())
                                                                            playSplash();
                                                                        }
                                                                        },
                                                                        // immerse
                                                                        {
                                                                          "time": 5, "callback":(actor){
                                                                          if (friendisclose())
                                                                            playSplash();
                                                                        }
                                                                        },
                                                                        {"p": [0.5, 3.24 + 0.02 + 0.005, OPENWORLD.Camera.cameraoffset], "v": 0.01, "t": 180, "callback":(actor){
                                                                          if (friendisclose())
                                                                            playSplash();
                                                                        }}, // up again
                                                                        {"time": 5, "callback":(actor){
                                                                          if (friendisclose())
                                                                            playSplash();
                                                                        }},
                                                                        //                                       {"p":[batherpos.x,batherpos.y,0],"v":0.02},
                                                                        //   {"p":[0.5,3.24+0.02, -0.01],"v":0.02},

                                                                      ],
                                                                      looptype: OPENWORLD.Mob.LoopTypeStop,
                                                                      level: 1,
                                                                      surfaceonly: true);

                                                                },
                                                                delay: 1); // set speech
                                                          }
                                                        },
                                                      ], action: "walk",
                                                          //straight",
                                                          looptype: OPENWORLD.Mob.LoopTypeStop,
                                                          level: 1,
                                                          surfaceonly: true

                                                      );
                                                    });
                                                  }
                                                },
                                                {
                                                  "action": "squatright",
                                                  "t": 270,
                                                  "time": 95,
                                                  "callback": (actor) {
                                                    // Waiting for you to finish the mikveh
                                                    // OPENWORLD.Actor.playAction(
                                                    //    friendhearth, action: "squat", delay:5);
                                                  }
                                                },
                                                {
                                                  "p": [0.6, 3.15, 0],
                                                  "v": 0.02,
                                                  "callback": (actor) {
                                                    OPENWORLD.Mob.setSpeech(
                                                        friendhearth, ["Easy"],
                                                        z: 90,
                                                        width: 300,
                                                        scale: 0.4,
                                                        randwait: 0,
                                                        clearwhendone: true);
                                                    OPENWORLD.Camera.setPitch(
                                                        0);

                                                    // Move you to in front of brazier after the mikveh
                                                    if (friendisclose()) {
                                                      OPENWORLD.Mob.moveTo(
                                                          threeJs.camera,
                                                          [
                                                            [
                                                              brazierposx + 0.045,
                                                              brazierposy, OPENWORLD.Camera.cameraoffset, 0.02
                                                            ],
                                                            // warmer position

                                                          ],
                                                          surfaceonly: true,
                                                          callbackonfinish: (
                                                              actor) {
                                                            if (friendisclose()) {
                                                              OPENWORLD.Space.objTurnLerp(
                                                                  threeJs.camera, 270, 1);
                                                              OPENWORLD.Space.setZLerp(threeJs.camera,
                                                                  OPENWORLD.Camera.cameraoffset * 0.5, 1.0,
                                                                  level: 1,
                                                                  delay: 1);
                                                            }
                                                          },
                                                          level: 1);
                                                    }
                                                  }
                                                },
                                                // yourfriend back to the waiter position after drying at the brazier
                                                {
                                                  "action": "handsouttogether",
                                                  "t": 270,
                                                  "time": 15,
                                                  "callback": (actor) {
                                                    if (friendisclose())
                                                      OPENWORLD.Space .faceObjectLerp( threeJs.camera, friendhearth, 1);
                                                    friendhearth.extra['followhearth'] = true; // start following your friend again

                                                  }
                                                },
                                                {
                                                  "p": [0.6, 3.34, 0],
                                                  "v": 0.02,
                                                  "callback": (actor) {

                                                  }
                                                },
                                                // yourfriend leaving
                                                {
                                                  "p": [0.64, 3.34, 0],
                                                  "v": 0.02,
                                                  "callback": (actor) {
                                                    if (friendisclose()) {
                                                      OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(threeJs.camera, 0.64,
                                                          3.34, OPENWORLD.Camera.cameraoffset, 1.0,
                                                          level: 1, delay: 1);
                                                      OPENWORLD.Space.faceObjectLerp(threeJs.camera,
                                                          friendhearth, 1,
                                                          delay: 2.0);
                                                    }

                                                  }
                                                },
                                                // bottome of mikveh steps
                                                { "p": [0.63, 3.1, 0], "v": 0.02 },// out of mikveh
                                                {
                                                  "p": [
                                                    friendpos.x,
                                                    friendpos.y,
                                                    0
                                                  ],
                                                  "v": 0.02,
                                                  "callback": (actor) {
                                                    OPENWORLD.Actor.playAction(
                                                        friendhearth,
                                                        action: "idle");
                                                    if (friendisclose()) {
                                                      OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(
                                                          threeJs.camera, 0.83, 2.97, OPENWORLD.Camera.cameraoffset, 1.0, level: 1);
                                                      OPENWORLD.Space.faceObjectLerp(threeJs.camera, friendhearth, 1,
                                                          delay: 2.0);
                                                    }
                                                  }
                                                },
                                                {
                                                  "action": "stoopidle",
                                                  "time": 5,
                                                  "callback": (actor) {
                                                    // your friend will put his robes in lottery
                                                    tolottery();
                                                  }
                                                }


                                                // {"action":"squatright","t":180},
                                              ], action: "walk",
                                              // stopaction: "idle",
                                              surfaceonly: true,
                                              looptype: OPENWORLD.Mob
                                                  .LoopTypeStop,

                                              level: 1,
                                            );
                                          }
                                      );
                                    }
                                    if (gamestart == GameStart.hearth &&
                                        !gamestartpos[gamestart]['progress']
                                            .contains(
                                            'mikveh')) {
                                      callwhenloaded(() {
                                      //  OPENWORLD.Sound.play(path: 'sounds/knock.mp3');
                                        mikveh();
                                      });
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }



        };
        if (gamestartpos[gamestart]['progress'].length==0)
           hasmovedhandler=runhearth;  // end on firstmove
        else
          runhearth();
      }

    } else {
      // This looks like priests during the day

      // Looks like priests on the western side
      var priest = await OPENWORLD.Actor.copyActor(manlist[0], randomduration: 0.2, duration: 7,
          action: "sittableleft");

      var posx=0.58+0.03;
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[0]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, posx, 2.96, 0.0,level:1, 3); //-0.032, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 90);

      priest = await OPENWORLD.Actor.copyActor(
          manlist[1], randomduration: 0.2, duration: 7,
          action: "sittableright");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname:getShoesGroup(manlist[1]));// "citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, posx, 2.96 + 0.04, 0,level:1, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 90);

      priest = await OPENWORLD.Actor.copyActor(
          manlist[2], randomduration: 0.2, duration: 7,
          action: "sittableidle");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[2]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, posx, 2.96 - 0.04 * 3, 0,level:1, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 90);

      priest = await OPENWORLD.Actor.copyActor(
          manlist[3], randomduration: 0.2, duration: 7,
          action: "sittableright");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[3]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, posx, 3.1, 0,level:1, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 90);
      priest = await OPENWORLD.Actor.copyActor(
          manlist[4], randomduration: 0.2, duration: 7,
          action: "sittableleft");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[4]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, posx, 3.1 - 0.04, 0, level:1,3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 90);

      priest = await OPENWORLD.Actor.copyActor(
          manlist[5], randomduration: 0.2,
          action: "idle3");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[5]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, 0.73, 2.92 + 0.2, 0,level:1, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 90);

      priest = await OPENWORLD.Actor.copyActor(
          manlist[6], randomduration: 0.2,
          action: "lookright");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[6]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, 0.73, 2.99 + 0.2, 0,level:1, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 90 + 45);


      // Looks like this is the priests on the eastern side
      priest = await OPENWORLD.Actor.copyActor(
          manlist[7], randomduration: 0.2, duration: 7,
          action: "sittableright");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[7]));///"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, 1.23, 2.83, 0.005,level:1, 3); //-0.032, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 270);
      priest = await OPENWORLD.Actor.copyActor(
          manlist[8], randomduration: 0.2, duration: 7,
          action: "sittableleft");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[8]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, 1.23, 2.83 + 0.04, 0.005,level:1, 3); //-0.032, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 270);

      priest = await OPENWORLD.Actor.copyActor(
          manlist[0], randomduration: 0.2, duration: 7,
          action: "sittableidle");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[9]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, 1.22, 2.83 + 3 * 0.04, 0.005,level:1, 3); //-0.032, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 270);

      priest = await OPENWORLD.Actor.copyActor(
          manlist[1], randomduration: 0.2, duration: 7,
          action: "sittableleft");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname:getShoesGroup(manlist[1]));// "citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, 1.22, 3.08, 0.032,level:1, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 270);
      priest = await OPENWORLD.Actor.copyActor(
          manlist[2], randomduration: 0.2, duration: 7,
          action: "sittableright");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[2]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, 1.22, 3.03, 0.032,level:1, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 270);
      priest = await OPENWORLD.Actor.copyActor(
          manlist[3], randomduration: 0.2,
          action: "idle3");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[3]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, 1.12, 2.99, 0,level:1, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 270);
      priest = await OPENWORLD.Actor.copyActor(
          manlist[4], randomduration: 0.2,
          action: "lookleft");
      OPENWORLD.BaseObject.setVisible(
          priest, false, groupname: getShoesGroup(manlist[4]));//"citizen_2"); // remove shoes
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priest, 1.12, 2.99 + 0.04, 0,level:1, 3);
      _hotload.add(priest);
      OPENWORLD.Space.objTurn(priest, 270 - 45);
      // This is during the day when the priests are sitting on the benches
      callwhenloaded(() {
        var priestposs = [
          [0.55, 3.27],
          [0.66, 3.06], //0.91, 3.23],
          [1.05, 2.87],
          [0.91, 2.10],
          [2.68, 1.87]
        ];
        List<Map> pos = [];
        for (var priestpos in priestposs)
          pos.add({ "p": [priestpos[0], priestpos[1], 0], "l": 1, "v": 0.03});
        pos.add({ "action": "idle3", "time": 1});
        for (var i = 0; i < 4; i++) {
          // this wont work in reality because if not in vicintiy all will start the same time!
          Future.delayed(
              Duration(milliseconds: (i * 2000).round()), () async {
            print("doing hearth day walking priest " + i.toString());
            priest = await OPENWORLD.Actor.copyActor(
                priestlist[i % priestlist.length], randomduration: 0.2);
            OPENWORLD.Mob.setName(priest,"priestwalker"+i.toString());
          //  priest.extra['hearthwalker']=true;
            OPENWORLD.Mob.moveToLoop(
                priest, pos, action: "walkstraight",
                // looptype: OPENWORLD.Mob.LoopTypeStop,
                looptype: OPENWORLD.Mob.LoopTypeReverseLoop,
                level: 1,
                lerpopacity: 0,
                surfaceonly: true

            );
            _hotload.add(priest);
          });
        }
      });


    }


    // mikveh

    final waterGeometryii = THREE.PlaneGeometry(20.0, 20.0);
    var watermikveh = Water(waterGeometryii, WaterOptions(
      color: 0xbbddff,
      //a08a73,//ffffff,//a08a73,//params['color'],
      scale: 4 / 32.0,
      //80,//4.0/scale,//params['scale'],
      reflectivity: 0.5,
      // clipBias: 0.5,
      flowDirection: THREE.Vector2(0.05, 0.05),
      //1.0/scale,1.0/scale),// params['flowX'], params['flowY'] ),
      textureWidth: 128,//256,
      //(1024/scale).round(),
      textureHeight: 128,//256, // (1024/scale).round(),
    ));

    watermikveh!.scale.setValues(0.01, 0.01, 1.0); // 1.7/20.0);

    OPENWORLD.Space.setTurnPitchRoll(watermikveh!, 0, 0, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
      //wateri, -10,-47.5,0.0, 3); //7.7, 1.0, 0.05);
        watermikveh!, 0.52, 3.27, 0.05,level:1,
        0.2); //-9.9, -47.5, 0.063, 2.5); //7.7, 1.0, 0.05);
    hotloadAdd(firsthotload, false,watermikveh!);
    watermikveh!.reflectionUpdateInterval =3;
    threeJs.scene.traverse((obj) {
      //   if ( obj.name!='surfaceaerialshadow') {
      if (obj is THREE.Mesh && obj.name!='chamberhearthwallnormaltile2'&&obj.name!='hearthnormalswalls'&&
          obj.name!='chamberhearthfloorsurfacenormalshadow'
         // && obj.name!='surface1normalshadowsoreg'
      ) {
        //  wateri.excludeFromReflection.add(obj);
        // wateri) {
        final pos = THREE.Vector3();
        obj.getWorldPosition(pos);

        // Get the water's world position
        final waterPos = THREE.Vector3();
        watermikveh!.getWorldPosition(waterPos);

        final dx = pos.x - waterPos.x;
        final dz = pos.z - waterPos.z;
        final distSq = dx * dx + dz * dz;

        // Exclude anything more than e.g. 8 world units from the pool
        if (distSq > 0.15*0.15) {
        watermikveh!.excludeFromReflection.add(obj);
        }
      }/*else if (obj.name=='clouds') {
        wateri.excludeFromReflection.add(obj);
        obj.renderOrder = 999;
      }*/


    });
    waterlist.add(watermikveh);


    var brazier = await OPENWORLD.Model.createModel(
        'assets/models/brazier.glb');
    _hotload.add(brazier);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        brazier, brazierposx, brazierposy, 0.001,level:1,
        0.3);
    brazier.scale.setValues(0.013, 0.013, 0.013);
    OPENWORLD.Texture.setMaterial(brazier, bronzematclean!,groupname:"brazier");
    OPENWORLD.Space.objTurn(brazier,90);
    var brazierfire = new VolumetricFire(
        Glob.fireWidth, Glob.fireHeight, Glob.fireDepth, Glob.sliceSpacing, threeJs.camera);
    await brazierfire.init();

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        brazierfire?.mesh,brazierposx, brazierposy, 0.04,level:1,
       0.3); //1.46-0.05, 4.22-0.05, 0.11, 3); // 3.35, 0.51, 0.3,3); //3.7);
    brazierfire?.mesh.scale.x = 0.005;
    brazierfire?.mesh.scale.y = 0.005;
    brazierfire?.mesh.scale.z = 0.005;
    _hotload.add(brazierfire?.mesh);
    OPENWORLD.Updateables.add(brazierfire);
    var groupbrazier = THREE.Group();
    var lightbrazier = new THREE.PointLight(
        0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

    lightbrazier.intensity = 0.05; // 0.6;
    lightbrazier.distance = 0.3; //1.2;
    lightbrazier.castShadow=true;
    lightbrazier.shadow?.mapSize.width = 32;
    lightbrazier.shadow?.mapSize.height = 32;;
    lightbrazier.shadow?.camera?.near = 0.01;
    lightbrazier.shadow?.camera?.far = 0.5;
    // light.position.y = 0.33;
    OPENWORLD.Light.addFlicker(lightbrazier);
    groupbrazier.add(lightbrazier);
    _hotload.add(groupbrazier);
    OPENWORLD.Space.worldToLocalSurfaceObj(
        groupbrazier, brazierposx, brazierposy,0.05,level:1);//, 0.3); //1.46-0.05, 4.22-0.05, 0.0, 3);
    groupbrazier.visible=false;

    var woodbundle6ii = woodbundle.clone();
    // _hotload.add(woodbundle6);
    hotloadAdd(firsthotload, false, woodbundle6ii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        woodbundle6ii, brazierposx,brazierposy-0.015, 0.01, level:1,0.5);
    OPENWORLD.Space.objTurn(woodbundle6ii, 90);
    woodbundle6ii.scale.setValues(0.005, 0.005, 0.005);

    var woodbundle6iii = woodbundle6ii.clone();
    // _hotload.add(woodbundle6);
    hotloadAdd(firsthotload, false, woodbundle6iii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        woodbundle6iii, brazierposx,brazierposy+0.018, 0.01,level:1, 0.5);

    // Enter mikveh to mikveh corner
    var poolsound=null;
    Glob.mikvehportal=OPENWORLD.Portals.createPortal(
        0.64, 3.12,
        level: 1,
        0.04,
        0.04,
        0.64, 3.33,
        0.0,
        level2: 1,
     //   marker:_hotload,
        //finalturn:227,//70,
        lerp:3,//friendhearth.extra.containsKey('followhearth')&&friendhearth.extra['followhearth']?16:3,///3,
        callback:(){
          OPENWORLD.Space.objTurnLerp(threeJs.camera, 227,1);
          groupbrazier.visible=true;
          hearthlightgroup.visible=false;
          OPENWORLD.Space.removeObjFromHide(hearthlightgroup);
          OPENWORLD.You.immobileturn=true;
          OPENWORLD.You.setImmobileTurn(false,delay:1.0);
            OPENWORLD.Camera.setPitch(-15);
            // I think this is needed because the reflection is so slow
            OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, 0.64, 3.33,OPENWORLD.Camera.cameraoffset,1.0,level:1);


          OPENWORLD.Actor.playActionsLoop(bather,
              bathingactions,
              randomaction: true,
            //  fadeout: 0.7
          );
          poolsound= OPENWORLD.Sound.getAudioPlayer();
          OPENWORLD.Sound.play(sound:poolsound,path: 'sounds/pool.mp3', loop:true,volume: 1, fadein:3);
         /* threeJs.camera.lookAt(bather.position);
           Future.delayed(
               Duration(milliseconds: 1100), () async {
             threeJs.camera.lookAt(bather.position);
             OPENWORLD.You.immobileturn=true;
           });*/

        }
    );
    // Exit mikveh
    OPENWORLD.Portals.createPortal(
        0.64, 3.12+0.09,
//        0.64, 3.12+0.05,
        level: 1,
        0.04,
        0.04,
        0.64, 3.12-0.03,
        0.0,
        level2: 1,
        callback:(){
          groupbrazier.visible=false;
          hearthlightgroup.visible=true;
          OPENWORLD.Space.readdObjFromHide(hearthlightgroup);
          if (poolsound!=null) {
            print("mikveh pool sound fadeout");
            OPENWORLD.Sound.fadeOut(poolsound, 1.0);
          }

        },
        //marker:_hotload,
    //    finalturn:270,
        lerp: 1);


    // Latrine
    OPENWORLD.Portals.createPortal(
        0.67, 3.33,
        0.01,
        0.04,
        0.75, 3.33,
        0.0,
      //  marker:_hotload,
        //initturn:180,
        finalturn:270,  // face looking out from toilet
        level:1,
        level2: 0,
        //   reverse:true,
        lerp: 1,
        callback:(){
          // squat
          OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(threeJs.camera, 0.75, 3.335,OPENWORLD.Camera.cameraoffset/2, 1.0);
         // print("callback in kitchen");
        //  OPENWORLD.Space.objTurnLerp(threeJs.camera, 318,1);
        });

    OPENWORLD.Portals.createPortal(
        0.69, 3.33,
        0.01,
        0.04,
        0.64, 3.33,
        0.0,
       // marker:_hotload,
        finalturn:180, // face looking up stairs
        level2: 1,
        //   reverse:true,
        lerp: 1);

    OPENWORLD.Portals.createPortal(
        0.69, 3.33,
        0.01,
        0.04,
        0.64, 3.33,
        0.0,
        // marker:_hotload,
        finalturn:180, // face looking up stairs
        level2: 1,
        //   reverse:true,
        lerp: 1);
    var doorwoodlatrine = doorwood.clone();
    _hotload.add(doorwoodlatrine);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodlatrine,0.67+0.005, 3.35, 0.00,level:1,
        0.5);
    hotloadAdd(firsthotload, false,doorwoodlatrine);
    doorwoodlatrine.scale.setValues(0.2/3.4, 0.2/2.9, 0.2/3.1);

    OPENWORLD.Space.objTurn(doorwoodlatrine, 0);
    OPENWORLD.BaseObject.setDistanceTrigger(
        doorwoodlatrine, name:"latrine", dist: 0.05, event:(action) {
      if (action) {
        // Open the door as get close
        OPENWORLD.Space.objTurnLerp(doorwoodlatrine, -90,1);

      } else {
        // Close door when leave
        OPENWORLD.Space.objTurnLerp(doorwoodlatrine, 0,1);

      }
    });

    var doorwoodsheep = doorwood.clone();
    _hotload.add(doorwoodsheep);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodsheep,0.685, 2.42+0.007-0.028, 0.00,level:1,
        1);

    doorwoodsheep.scale.setValues(0.05, 0.12, 0.09);

    OPENWORLD.Space.objTurn(doorwoodsheep, 0);
    OPENWORLD.BaseObject.setDistanceTrigger(
        doorwoodsheep, dist: 0.1, name:"doorwoodsheep", event:(action) {
      if (action) {
        // Open the door as get close
        OPENWORLD.Space.objTurnLerp(doorwoodsheep, -90,1);

      } else {
        // Close door when leave
        OPENWORLD.Space.objTurnLerp(doorwoodsheep, 0,1);

      }
    });

    var ropehanging = await OPENWORLD.Model.createModel(
        'assets/models/ropehanging.glb');
    //  _hotload.add(ring);
    ropehanging.scale.setValues(0.004, 0.0035, 0.005);

    for (var j = 0; j < 6; j++) {
        var ring2 = ring.clone();
        _hotload.add(ring2);
        //ring.scale.setValues(0.002, 0.002, 0.002);
      //  OPENWORLD.Space.objPitch(ring2,90);
        ring2.scale.setValues(0.0008, 0.0008, 0.0008);
        OPENWORLD.Space.setTurnPitchRoll(ring2, 90, 0,-90);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            ring2, 0.46+0.015, 2.4-0.15 + j * 0.08, 0.013, 0.5,level:1);

        var ropehanging2 = ropehanging.clone();
        _hotload.add(ropehanging2);
        //ring.scale.setValues(0.002, 0.002, 0.002);
        //  OPENWORLD.Space.objTurn(ring2,90);
        //  OPENWORLD.Space.objPitch(ring2,90);
        //OPENWORLD.Space.setTurnPitchRoll(ropehanging2, 90, 0,-90);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            ropehanging2, 0.46+0.02, 2.4-0.15 + j * 0.08, -0.015, 0.5,level:1);
        OPENWORLD.Space.objTurn(ropehanging2,-90);
        ropehanging.scale.setValues(0.004, 0.003+OPENWORLD.Math.randFloatSpread(0.0006), 0.005);

        var action=OPENWORLD.Math.random()<0.3?"layidle":"eat";
        var sheep12 = await OPENWORLD.Actor.copyActor(sheeporig, duration: 8,
            action: action,
            randomduration: 0.5,
           // castshadow: true
        );
      //  OPENWORLD.Space.resetPosRot(sheep12);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            sheep12,  0.46+0.05+OPENWORLD.Math.randFloatSpread(0.03), 2.4-0.14 + j * 0.08+OPENWORLD.Math.randFloatSpread(0.03), 0,
            0.5,level:1); // 2.89, 0.71+0.13,0,3);//1.06+0.13,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
        _hotload.add(sheep12);

        OPENWORLD.Space.objTurn(sheep12.children[0], 0); // Why this be done
        OPENWORLD.Space.objTurn(sheep12.children[1], 0);
        OPENWORLD.Space.objTurn(sheep12, 90+OPENWORLD.Math.randFloatSpread(95));
        OPENWORLD.BaseObject.setVisible(sheep12, action=='eat', groupname: "collar");


       /* var hay14ii = hay.clone();
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            hay14ii,  0.46+0.03+OPENWORLD.Math.randFloatSpread(0.02), 2.4-0.15 + j * 0.08+OPENWORLD.Math.randFloatSpread(0.02), 0.0,0.5, level:1);
        // _hotload.add(hay14);
        hotloadAdd(firsthotload, false, hay14ii);*/
        instancedHaysHearth.place(0,0.46+0.03+OPENWORLD.Math.randFloatSpread(0.02), 2.4-0.15 + j * 0.08+OPENWORLD.Math.randFloatSpread(0.02),0.0, level:1);//,5);
        /*var hay14iii = hay.clone();
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            hay14iii,  0.46+0.07+OPENWORLD.Math.randFloatSpread(0.04), 2.4-0.15 + j * 0.08+OPENWORLD.Math.randFloatSpread(0.04), -OPENWORLD.Math.random()*0.002, 0.5, level:1);
        // _hotload.add(hay14);
        hotloadAdd(firsthotload, false, hay14iii);*/
        instancedHaysHearth.place(0, 0.46+0.07+OPENWORLD.Math.randFloatSpread(0.04), 2.4-0.15 + j * 0.08+OPENWORLD.Math.randFloatSpread(0.04), -OPENWORLD.Math.random()*0.002, level:1);//,5);



        if (j<5) {

          var boxlimestone2=boxlimestone.clone();
          _hotload.add(boxlimestone2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              boxlimestone2,  0.46 + 0.04, 2.4 - 0.15 + 0.05+ j * 0.08, -0.003, 0.5, level:1); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(boxlimestone2,0);
          boxlimestone2.scale.setValues(0.04, 0.012+OPENWORLD.Math.randFloatSpread(0.002), 0.006+OPENWORLD.Math.randFloatSpread(0.002));

          var boxlimestone3=boxlimestone2.clone();
          _hotload.add(boxlimestone3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              boxlimestone3,  0.46 + 0.04, 2.4 - 0.15 + 0.05+ j * 0.08, -0.003, 0.5, level:1); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objPitch(boxlimestone3,90);

          var boxlimestone4=boxlimestone2.clone();
          _hotload.add(boxlimestone4);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              boxlimestone4,  0.46 , 2.4 - 0.15 + 0.05+ j * 0.08, -0.003, 0.5, level:1); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objRoll(boxlimestone4,90);
        }
//        OPENWORLD.Space.worldToLocalSurfaceObjHide(ring2, 2.89 + i*0.13, 1.06+j*0.13, 0.0, 10);
    }
    var boxlimestone2=boxlimestone.clone();
    _hotload.add(boxlimestone2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        boxlimestone2,  0.46 + 0.01, 2.4 - 0.15 + 0.05+ 2 * 0.08, -0.003, 0.5, level:1); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(boxlimestone2,90);
    boxlimestone2.scale.setValues(0.25, 0.012, 0.001);


    var doorwoodshowbread = doorwoodsheep.clone();
    _hotload.add(doorwoodshowbread);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodshowbread,1.14, 2.42+0.007-0.028, 0.00,level:1,
        1);

    OPENWORLD.Space.objTurn(doorwoodshowbread, 180);
    OPENWORLD.BaseObject.setDistanceTrigger(
        doorwoodshowbread, dist: 0.1,name:"doorwoodshowbread", event:(action) {
      if (action) {
        // Open the door as get close
        OPENWORLD.Space.objTurnLerp(doorwoodshowbread, -90,1);

      } else {
        // Close door when leave
        OPENWORLD.Space.objTurnLerp(doorwoodshowbread, 180,1);

      }
    });
    var doorwoodstones = doorwood.clone();
    doorwoodstones.scale.setValues(0.05, 0.09, 0.09);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodstones,1.21,3.12, 0.00,level:1,
        1);
    hotloadAdd(firsthotload, false,doorwoodstones);

    OPENWORLD.Space.objTurn(doorwoodstones, 90);
    OPENWORLD.BaseObject.setDistanceTrigger(
        doorwoodstones, dist: 0.1, name:"doorwoodstones",event:(action) {
      if (action) {
        // Open the door as get close
        OPENWORLD.Space.objTurnLerp(doorwoodstones, 0,1);

      } else {
        // Close door when leave
        OPENWORLD.Space.objTurnLerp(doorwoodstones, 90,1);

      }
    });


    _hotload.add(oven);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        oven, 1.25+0.01, 2.69-0.035,0.035,level:1,
        0.5);
    OPENWORLD.Space.objTurn(oven, 180);

    _hotload.add(tablelimestone);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tablelimestone, 1.35-0.03, 2.53,-0.001,level:1,
        0.5);
    OPENWORLD.Space.objTurn(tablelimestone, 180);

    var tablelimestone2= tablelimestone.clone();
    _hotload.add(tablelimestone2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tablelimestone2, 1.35-0.03, 2.53-0.2,-0.001,level:1,
        0.5);

    var baker=await OPENWORLD.Actor.copyActor(OPENWORLD.Math.randPick(priestlist),randomduration: 0.1);
    _hotload.add(baker);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        baker, 1.25, 2.69-0.03-0.1,0.0,level:1,0.5); //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);
    //   threeJs.scene.add(priest3iv);
    OPENWORLD.Space.objTurn(baker, 180);

    for (var i=0; i<7; i++) {
      var pot15ii = pot.clone();
      _hotload.add(pot15ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot15ii,1.35,2.57-i*0.05, 0.05, 0.5,level:1);
      OPENWORLD.Space.objTurn(
          pot15ii, 180);
    }



    //  lampbronze.material=bronzemat;
    var lampposx= 1.13+0.008;
    var lampposy=2.5-0.006;
    var lampposz=0.072;//068;
    var lampbronze1=lampbronze.clone();
      OPENWORLD.Space.setTurnPitchRoll(lampbronze1, 0,0,0);
  //  OPENWORLD.Space.objTurn(lampbronze1,-90);
    lampbronze1.scale.setValues(0.01, 0.01, 0.01);
    _hotload.add(lampbronze1);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        lampbronze1, lampposx,lampposy,lampposz,level:1,0.5);//0.88, 2.99,0,level:1, //0.01,//0.87, 2.79
     //   3); //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);

    var grouplamp = THREE.Group();
    var lightlamp = new THREE.PointLight(
        0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

    lightlamp.intensity = 0.02; // 0.6;
    lightlamp.distance = 0.3; //1.2;
    /*lightlamp.castShadow=true;
    lightlamp.shadow?.mapSize.width = 64;
    lightlamp.shadow?.mapSize.height = 64;;
    lightlamp.shadow?.camera?.near = 0.01;
    lightlamp.shadow?.camera?.far = 0.5;
    // light.shadow?.radius = 4;
    lightlamp.shadow?.blurSamples=10.0;*/
    // light.position.y = 0.33;
    OPENWORLD.Light.addFlicker(lightlamp);
    grouplamp.add(lightlamp);
    _hotload.add(grouplamp);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        grouplamp, lampposx-0.01,lampposy+0.005,lampposz+0.01,level:1,0.5); //1.46-0.05, 4.22-0.05, 0.0, 3);

    var lampposx2=0.69;
    var lampbronze2=lampbronze1.clone();
    _hotload.add(lampbronze2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        lampbronze2, lampposx2,lampposy,lampposz,level:1,0.5); //1.46-0.05, 4.22-0.05, 0.0, 3);

    var grouplamp2 = THREE.Group();
    var lightlamp2 = new THREE.PointLight(
        0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

    lightlamp2.intensity = 0.02; // 0.6;
    lightlamp2.distance = 0.3; //1.2;
    OPENWORLD.Light.addFlicker(lightlamp2);
    grouplamp2.add(lightlamp2);
    _hotload.add(grouplamp2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        grouplamp2, lampposx2+0.01,lampposy+0.005,lampposz+0.01,level:1,0.5); //1.46-0.05, 4.22-0.05, 0.0, 3);


    roomHewnstone = OPENWORLD.Room.createRoom(4.85,-1.79,name:"Chamber of the Hewnstone",
        volume: 0.05, roomspeed:1.5 / 20,soundpath:!OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/temple.mp3":"sounds/hearth.mp3"); //THREE.Object3D();
   // roomHewnstone.extra['name'] = "Hewnstone";
    //   soundpath: "sounds/courtyard.mp3",
    roomHewnstone.extra['guide'] = [
      "You are at the chamber of the Hewnstone",
    ];
    //OPENWORLD.Room.setIndoors(roomBethspage,true);
    OPENWORLD.Room.setAutoIndoors(roomHewnstone, true);
    _hotload.add(roomHewnstone);

    OPENWORLD.Room.setDistanceTrigger(roomHewnstone,
        maxy: -1.5, miny: -2.17, minx:4.44, maxx:5.3, event:(action) {
          if (action) {
            setState(() {
              if (mounted)
                roomname = "Chamber of the Hewnstone";
            });
          } else {
            setState(() {
              if (mounted)
                roomname = "";
            });
          }
        });




  /* var priest = await OPENWORLD.Actor.copyActor(priestlist[0],//citizen2,//manlist[9],
     //  citizen4,
          randomduration: 0.1, action: "walkhandright");//walkstraightlookleft");//idlestraight");//,duration:10, delay:5);
 //  OPENWORLD.Actor.playAction(
  //      priest, action: "walkscan", duration: 10, fadein:0, fadeout: 0);
    setcancollide(priest,true);
    _hotload.add(priest);
   // var speech = await OPENWORLD.Sprite.loadSprite(
   //     'assets/textures/speech.png', 1, 1, ambient: false);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        priest, 0.88, 2.99,0,level:1, 3);*/ //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);
   /* var turbanwield2=basketwickerfigs.clone();
    turbanwield2.position.x=3.0;//7.0;
    turbanwield2.position.y= 3.0;
    turbanwield2.position.z=0.0;// -1.0;
    turbanwield2.scale.setValues(5.0,5.0,5.0);
    OPENWORLD.Space.setTurnPitchRoll(
        turbanwield2, -45, 90, 0);
    OPENWORLD.Actor.wield(priest, turbanwield2, "Bip01_R_Hand");*/
  /*  var trumpetwield = trumpet.clone();
    OPENWORLD.Space.setTurnPitchRoll(trumpetwield, -90, 0, 0);
    trumpetwield.position.z=-1.0;
    OPENWORLD.Actor.wield(priest, trumpetwield, "Bip01_R_Hand");*/
   /* Future.delayed(Duration(milliseconds: 20000), () async {
      OPENWORLD.Actor.unwield(priest, "Bip01_R_Hand");
      Future.delayed(Duration(milliseconds: 2000), () async {
        var dove2=dove.clone();
        dove2.scale.setValues(1.0,1.0,1.0);
        OPENWORLD.Space.resetPosRot(dove2);
        dove2.position.x=-4.0;
        OPENWORLD.Space.setTurnPitchRoll(
            dove2, 0, 90, 90 + 90);
        OPENWORLD.Actor.wield(priest, dove2, "Bip01_R_Hand");
      });

    });*/
      /*  var turbanwield2=turbanwield.clone();
    turbanwield2.position.x=7.0;
    turbanwield2.position.y=-1.0;
    turbanwield2.scale.setValues(5.0,5.0,5.0);
    OPENWORLD.Space.setTurnPitchRoll(
        turbanwield2, 0, -90, 0);
    OPENWORLD.Actor.wield(priest, turbanwield2, "Bip01_Head");*/
   /* var dove2=dove.clone();
    dove2.scale.setValues(1.0,1.0,1.0);
    OPENWORLD.Space.resetPosRot(dove2);
    dove2.position.x=-4.0;
    OPENWORLD.Space.setTurnPitchRoll(
       dove2, 0, 90, 90 + 90);
    OPENWORLD.Actor.wield(priest, dove2, "Bip01_R_Hand");*/
  /*  var birdcagepigeon2 = birdcagedoves.clone();

    OPENWORLD.Space.setTurnPitchRoll(
        birdcagepigeon2, 0, 90, 90 + 90); //walkstraight is good!

    //OPENWORLD.Space.setTurnPitchRoll(
   //     birdcagepigeon2, -45, 90, 90 + 90); //walkstraight is good!
    birdcagepigeon2.scale.setValues(1.2,1.2,1.2);
    birdcagepigeon2.traverse( (child) {
      if(child is THREE.Mesh ){
        // print("oo"+(child.material as THREE.MeshStandardMaterial).name.toString());
        print('upppo'+child.name.toString()+" "+child.material.toString());
      }
    });

    for (var dove in birdcagepigeon2.children[0].children)
      dove.visible=false;
    // OPENWORLD.Space.setTurnPitchRoll(vesselmizrak, 0, 90 - 20, 180 + 60);
    // OPENWORLD.Space.setTurnPitchRoll(vesselbowl, 0,130, 100);
    //   vesselbowl.position.z=0.0;//-4.0;
    //   vesselbowl.position.y=7.0;//5.0;
    //   vesselbowl.position.x=0.0;

    OPENWORLD.Actor.wield(priest, birdcagepigeon2, "Bip01_R_Hand");*/
  /*     OPENWORLD.Actor.playActionsLoop(priest,
        ["wave", "idle", "point", "idle", "hitup", "armsup", "idle"],
        durations: [2*2, 3*2,     2*2,    2*2,     5*2, 5*2],fadeout:2);*///,fadein:2);//fadein:0.5); //,fadeout:0.7);
 /*   OPENWORLD.Actor.playActionsLoop2(priest,
        ["wave", "idle", "point", "idle", "hitup", "armsup", "idle"],
        durations: [2*2, 3*2,     2*2,    2*2,     5*2, 5*2],fadeout:2);//fadeout:null);//fadein:0.5); //,fadeout:0.7);
   */
   /*  var friendpos = OPENWORLD.Space.localToWorldObj(priest);
    OPENWORLD.Mob.moveToLoop(
        priest,
        [{"p":[friendpos.x,friendpos.y,0],"v":0.02},
          {"action":"wave", "time":2*2},
          {"action":"idle", "time":3*2},
          {"action":"point", "time":2*2},
            {"action":"idle", "time":2*2},
            {"action":"hitup", "time":5*2},
            {"action":"armsup", "time":5*2},
            {"action":"idle"}
        ],
       // looptype: OPENWORLD.Mob.LoopTypeStop,


        level:1,
        surfaceonly: true);*/


  /*  var speech=await OPENWORLD.Plane.loadPlane(
       'assets/textures/speech.png', 15,15,z:65, flipx:true,doublesided:true,ambient:false);
    OPENWORLD.Texture.setEmissive(speech,THREE.Color.fromHex32(0xffffff));
    speech.position.z=20.0;
    priest.add(speech);*/
/*
    OPENWORLD.Actor.playActionsLoop(priest,
        ["wave", "idle", "point", "idle", "hitup", "armsup", "idle"],
        durations: [2*2, 3*2,     2*2,    2*2,     5*2, 5*2],fadein:null,fadeout:2);//fadeout:null);//fadein:0.5); //,fadeout:0.7);
*/
    /* var points = [];
    points.add( new THREE.Vector3(  0,67 ,5) );
    points.add( new THREE.Vector3( 0, 67,12 ) );
//    points.add( new THREE.Vector3(  -100,0, 0 ) );
//    points.add( new THREE.Vector3(  100,0, 0 ) );
//    points.add( new THREE.Vector3( 0, -100, 0 ) );
//    points.add( new THREE.Vector3( 0, 100, 0 ) );
    var geometryii = new THREE.BufferGeometry().setFromPoints( points );
    THREE.Group speechgroup=THREE.Group();
    for (var i=0; i<4; i++) {
      var materiali = new THREE.LineBasicMaterial.fromMap(
          { 'color': 0xffffff,
           // 'linewidth': 100,
          }); //888888});
     // materiali.linewidth=100.0;
      var line = new THREE.Line(geometryii, materiali);
      //materiali.transparent = true;
     // materiali.opacity = 0.13;

      line.visible = true;
      //line.scale.setValues(0.1,0.1,0.1);
      //line.position = Camera._camera.position.clone();
      //line.position.y -= Camera.cameraoffset;
      //line.rotation.y = Camera._camera.rotation.y;
      //line.translateZ(-0.5);
      line.rotation.y=THREE.MathUtils.degToRad(10);
      line.translateX(OPENWORLD.Math.randFloatSpread(2));//1.3 * ((OPENWORLD.Math.random() - 0.5)));
      line.translateY(OPENWORLD.Math.randFloatSpread(2));//1.3 * ((OPENWORLD.Math.random() - 0.5)));
      speechgroup.add(line);
    }
    priest.add(speechgroup);
    priest.extra['speechgroup']=speechgroup;
    OPENWORLD.BaseObject.setVisible(priest.extra['speechgroup'],false,delay:15);*/
 /*   var finaltableposx=4.05;
    var finaltableposy=1.28;
    var meat=meatlist[0];
    _hotload.add(meat);
    /*OPENWORLD.Space.worldToLocalSurfaceObjHide(
        meat, 0.88, 2.99, 0.058,  // 1.28
        3, level: 1);*/

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        meat, finaltableposx + OPENWORLD.Math.randFloatSpread(0.04),  //3.93
        finaltableposy + OPENWORLD.Math.randFloatSpread(0.04), 0.058,  // 1.28
        3, level: 1);

    OPENWORLD.Space.objTurn(meat, OPENWORLD.Math.random() * 360);
    ///          meat, 2.89+OPENWORLD.Math.randFloatSpread(0.04), 1.84+OPENWORLD.Math.randFloatSpread(0.04), 0.058, 3); // 3.2,2.5, 0.0);
    meat.scale.setValues(0.00065, 0.00065, 0.00065);

    var vesselmizrak = await OPENWORLD.Model.createModel(
        'assets/models/vesselmizrak.glb');
    OPENWORLD.Texture.setMaterial(
        vesselmizrak, goldmaterial!, groupname: 'gold');
    final bloodmaterial = THREE.MeshStandardMaterial.fromMap({
      //  'normalMap': bumpTexture,
      'color': 0xff3333,
      'metalness': 1.0, // 0,
      //'map': goldii,
      'shininess': 1.0,
      'roughness': 0.5,
      // 'em'
      'emissive':THREE.Color.fromHex32(0xff0000)
      //'envMap': gold,
      //'envMapIntensity': 1.0,// api['envMapIntensity'],
    });
    OPENWORLD.Texture.setMaterial(
        vesselmizrak, bloodmaterial, groupname: 'blood');
    OPENWORLD.BaseObject.setVisible(vesselmizrak, false, groupname: "blood");
    var vesselmizrak2=vesselmizrak.clone();
    vesselmizrak2.scale.setValues(0.0015, 0.0015, 0.0015);

    var vesselmizrakwield=vesselmizrak.clone();

    OPENWORLD.Space.setTurnPitchRoll(
        vesselmizrakwield, 0, 90, 90 + 90); //walkstraight is good!
    // for walkstraight


    // OPENWORLD.Space.setTurnPitchRoll(vesselmizrak, 0, 90 - 20, 180 + 60);
    // OPENWORLD.Space.setTurnPitchRoll(vesselbowl, 0,130, 100);
    //   vesselbowl.position.z=0.0;//-4.0;
    //   vesselbowl.position.y=7.0;//5.0;
    //   vesselbowl.position.x=0.0;

    OPENWORLD.Actor.wield(priest, vesselmizrakwield, "Bip01_L_Hand");
    OPENWORLD.Actor.playAction(
        priest, action: "idle");//idle");
    OPENWORLD.Space.setTurnPitchRoll(
        vesselmizrakwield, 0, 180-45, 90 + 90); //walkstraight is good!
    vesselmizrakwield.position.z = 4.0; // forward (reverse)
//    vesselspoon.position.y = 5.0;//  left right
    vesselmizrakwield.position.x = 5.0; // up down

    Future.delayed(Duration(milliseconds: 20000), () async {
      vesselmizrakwield.position.z = 0.0; // forward (reverse)
//    vesselspoon.position.y = 5.0;//  left right
      vesselmizrakwield.position.x = 0.0; // up down
      OPENWORLD.Actor.playAction(
          priest, action: "pointleft");//idle");//idle");
      OPENWORLD.Space.setTurnPitchRoll(
          vesselmizrakwield, -90, 0,0); //walkstraight is good!
      OPENWORLD.Space.objTurnLerp(priest, -90, 0.4,delay:0.5);
      Future.delayed(Duration(milliseconds: 1000), () async {
        OPENWORLD.Actor.playAction(
            priest, action: "idle"); //idle");//idle");
        OPENWORLD.BaseObject.setVisible(vesselmizrakwield, true, groupname: "blood");
        OPENWORLD.BaseObject.setVisible(vesselmizrakwield, false, groupname: "blood",delay:0.5);
        OPENWORLD.Space.setTurnPitchRoll(
            vesselmizrakwield, 0, 180 - 45, 90 + 90); //walkstraight is good!
        vesselmizrakwield.position.z = 4.0; // forward (reverse)
//    vesselspoon.position.y = 5.0;//  left right
        vesselmizrakwield.position.x = 5.0; // up down
       });

      });
*/
    /*   var pitchforkwield=pitchfork.clone();
    OPENWORLD.Space.setTurnPitchRoll(pitchforkwield.children[0], 90, 0, 0);
    OPENWORLD.Actor.wield(priest, pitchforkwield, "Bip01_R_Hand");*/
    /*  var firepan=  await OPENWORLD.Model.createModel('assets/models/firepan.glb');

    OPENWORLD.Texture.setMaterial(firepan, silvermaterial!);
   // _hotload.add(firepan);
   // firepan.scale.setValues(0.01,0.01,0.01);
   // OPENWORLD.Space.worldToLocalSurfaceObjHide(
   //     firepan, 0.88, 2.99-0.1, 0.005,level:1, 1);
   firepan.scale.setValues(5.0, 5.0, 5.0);
    OPENWORLD.Space.setTurnPitchRoll(firepan, 90, -90, 0);
    OPENWORLD.Actor.wield(priest, firepan, "Bip01_R_Hand");*/
   /* var torch = await OPENWORLD.Model.createModel('assets/models/torch.glb');

    torch.scale.setValues(5.0, 5.0, 5.0);
    OPENWORLD.Space.setTurnPitchRoll(torch, 90, -90, 0);
    OPENWORLD.Actor.wield(priest, torch, "Bip01_R_Hand");
    var brandfire = new VolumetricFire(
        fireWidth, fireHeight, fireDepth, sliceSpacing, threeJs.camera);
    await brandfire.init();
    // _space.worldToLocalSurfaceObj(fire?.mesh, 7.0, 2.0, 0.33); //3.7);
   // brandfire.mesh.scale.x = 5; //0.05;
  //  brandfire.mesh.scale.y = 5; //0.05;
   // brandfire.mesh.scale.z = 5; //0.05;
    brandfire.mesh.position.y = 2;//18;//0.25; //33;
    brandfire.mesh.position.z =5;//8;//0.25; //33;
    OPENWORLD.Space.objPitch(brandfire.mesh, 20);//-90);
    //scene.add(fire?.mesh);
    torch.add(brandfire.mesh);

    OPENWORLD.Updateables.add(brandfire);
     light= new THREE.PointLight(0xFFA500); //PointLight(0xffffff)

    light.intensity = 0.1; // 0.6;
    light.distance = 0.8;
    light.position.y =2;//0.33;
    light.position.z = 5;//0.33;
    OPENWORLD.Light.clock=clock;
    OPENWORLD.Light.addFlicker(light);
    OPENWORLD.Light.addNightOnly(light);
    torch.add(light);
    */
     /* var anim = OPENWORLD.Actor.getAnimationByName(priest, "idlehold");

      var idle = await priest.extra['mixer'].clipAction(anim);
        idle?.setDuration(10);*/

     /* if (startat!=null) {
        if (duration==null)
          idle?.startAt(startat.toDouble()*idle?.getClip().duration);
        else
          idle?.startAt(startat.toDouble()*duration.toDouble());

      }*/
      //cowidle?.setDuration(10);
    //  idle?.reset().play();

    /*var turban = await OPENWORLD.Model.createModel('assets/models/turban.glb');

    turban.scale.setValues(5.0, 5.0, 5.0);
    OPENWORLD.Space.setTurnPitchRoll(turban, 90, -90, 0);
    OPENWORLD.Actor.wield(priest, turban, "Bip01_R_Hand");*/
   /* var lampbronzewield=lampbronze.clone();
    var lightlampwield = new THREE.PointLight(
        0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

    lightlampwield.intensity = 0.08; // 0.6;
    lightlampwield.distance = 0.6; //1.2;

    OPENWORLD.Light.addFlicker(lightlampwield);
    lightlampwield.position.y=1.0;
    lightlampwield.position.z=1.0;
  //  var sphereAxis = new AxesHelper(2000);
   // lightlampwield.add(sphereAxis );
    lampbronzewield.add(lightlampwield);
    lampbronzewield.scale.setValues(5.0, 5.0, 5.0);
    //lampbronzewield.position.y=2.0;// right
    //lampbronzewield.position.x=2.0;// in out
    lampbronzewield.position.z=-2.0;// in out
    OPENWORLD.Space.setTurnPitchRoll(lampbronzewield, 90, -90, 0);
    OPENWORLD.Actor.wield(priest, lampbronzewield, "Bip01_R_Hand");*/
   // OPENWORLD.Space.objTurn(priest, 0);
  //  OPENWORLD.Space.setTurnPitchRoll2(priest, 90.0,20.0,0.0);
  // OPENWORLD.Space.setTurnPitchRoll(priest, 0.0,0.0,20.0);

  //  OPENWORLD.Time.setTimeLerp(9,60);

   // Future.delayed(Duration(milliseconds: 20000), () async {
  //    print("added new config");



    instancedHaysHearth.finish();
    instancedBeddings.finish();
    instancedPillows.finish();

  }
}
