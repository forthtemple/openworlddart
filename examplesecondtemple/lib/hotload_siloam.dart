// Code related to pool of Siloam
// Shared by bethphage and roam siloam journey
part of 'SecondTemplePage.dart';

extension HotloadSiloamExt on SecondTemplePageState {
  hotloadSiloam(firsthotload,// {

  ) async {
/// Siloam
    // Pool of siloam hotload

    instancedColumnsSiloam.reset();

    roomSiloam = OPENWORLD.Room.createRoom(-16.83, -45.29,
        soundpath: !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/courtyard.mp3":null, volume:0.05,  roomspeed: 1.0 / 20 ,
//        soundpath: OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/pool.mp3":"sounds/courtyard2.mp3", volume:0.05,  roomspeed: 1.0 / 20 ,
        exitroom: roomTerrain); //THREE.Object3D();

    roomSiloam.extra['guide'] = [
      "You are at the pool of Siloam.",
    ];

    _hotload.add(roomSiloam);
    var poolsound = OPENWORLD.Sound.getAudioPlayer();
    OPENWORLD.Room.setDistanceTrigger(roomSiloam,    //-8.38
        maxy: -51.4, miny: -54.31, minx:-11.1, maxx: -7.91, event:(action) {
          if (action) {
            if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time))
              OPENWORLD.Sound.play(sound: poolsound,
                  path: 'sounds/pool.mp3',
                  loop: true,
                  volume: 0.8,
                  fadein: 1.0);
            setState(() {
            //  OPENWORLD.Camera.cameraoffset=SecondTemplePageState.defaultcameraoffset*0.75;
              if (mounted)
                roomname = "Pool of Siloam";
            });
          } else {
          //  OPENWORLD.Camera.cameraoffset=SecondTemplePageState.defaultcameraoffset;

            setState(() {
              if (mounted)
                roomname = "";
              OPENWORLD.Sound.fadeOut(poolsound, 1.0);
            });
          }
        });


    var girlspeed = 0.07;

    var inclusive=true;
    final waterGeometryi = THREE.PlaneGeometry(20.0, 20.0);
    Glob.watersiloam = Water(waterGeometryi, WaterOptions(
      color: 0xbbddff,
      //a08a73,//ffffff,//a08a73,//params['color'],
      scale: 4 / 32.0,
      //80,//4.0/scale,//params['scale'],
      reflectivity: 1.0,
      // clipBias: 0.5,
      flowDirection: THREE.Vector2(0.05, 0.05),
      //1.0/scale,1.0/scale),// params['flowX'], params['flowY'] ),
      textureWidth: 256,
      //(1024/scale).round(),
      textureHeight: 256, // (1024/scale).round(),
      inclusiveOnly:inclusive//true
      //    normalMap0: await textureLoader.fromAsset( 'assets/textures/water/Water_1_M_Normal.jpg'),
      //   normalMap1: await textureLoader.fromAsset( 'assets/textures/water/Water_2_M_Normal.jpg')
    ));
    // var wateri=water4.clone();
    // var waterii=wateri;//.clone();

    Glob.watersiloam!.scale.setValues(1.1*2 / 20.0, 1.1*2.5 * 1.3 / 20, 1.0); // 1.7/20.0);

    OPENWORLD.Space.setTurnPitchRoll(Glob.watersiloam!, 0, 0, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
      //wateri, -10,-47.5,0.0, 3); //7.7, 1.0, 0.05);
        Glob.watersiloam!, -9.3-0.4, -52.62, 0.063,
        2.5); //-9.9, -47.5, 0.063, 2.5); //7.7, 1.0, 0.05);
    hotloadAdd(firsthotload, false, Glob.watersiloam!);

    if (inclusive) {
      // Use inclusive where say what want reflected in the pool
      threeJs.scene.traverse((obj) {
        //   if ( obj.name!='surfaceaerialshadow') {

        if (obj is THREE.Mesh && /*obj.name!='surfaceaerialshadow'&&*/
            obj.name != 'skymesh' && obj.name != 'clouds' &&
            obj.name != 'tentsiloamnormalclotheswall' &&
            obj.name != 'tentsiloamnormalclothes' &&
            obj.name != 'siloaimpoolsurfacehide10shadow') {
          //  wateri.excludeFromReflection.add(obj);
          // wateri) {
          // Why are these items in the reflection?
         /* if (obj.name == 'chamberhearthbeds002' || obj.name == 'olives' ||
              obj.name == 'herbs' || obj.name == 'lamp') {
            //  watersiloam!.excludeFromReflection.add(obj);
          } else {
            final pos = THREE.Vector3();
            obj.getWorldPosition(pos);

            // Get the water's world position
            final waterPos = THREE.Vector3();
            watersiloam!.getWorldPosition(waterPos);

            final dx = pos.x - waterPos.x;
            final dz = pos.z - waterPos.z;
            final distSq = dx * dx + dz * dz;

            // Exclude anything more than e.g. 8 world units from the pool
            if (distSq > 2.0 * 2.0) {
              // watersiloam!.excludeFromReflection.add(obj);
              //  excluded.add(obj.name);
            } else
              watersiloam.includeInReflection.add(obj);

            // print('reflection' + obj.name + " xx " + OPENWORLD.BaseObject.getName(obj));
            //included.add(obj.name);
          }*/
        } else if (obj is THREE.Mesh)
          Glob.watersiloam.includeInReflection.add(obj);
      });
      print('reflect include cnt'+Glob.watersiloam.includeInReflection.length.toString());  // 8
      for (var obj in Glob.watersiloam.includeInReflection)
        print("reflect inclde"+obj.name.toString()+" "+obj!.geometry!.attributes['position']!.length.toString());
    } else {
      threeJs.scene.traverse((obj) {
        //   if ( obj.name!='surfaceaerialshadow') {

        if (obj is THREE.Mesh && /*obj.name!='surfaceaerialshadow'&&*/ obj.name!='skymesh'&&obj.name!='clouds'&&obj.name!='tentsiloamnormalclotheswall'&&obj.name!='tentsiloamnormalclothes'&&obj.name!='siloaimpoolsurfacehide10shadow') {
          //  wateri.excludeFromReflection.add(obj);
          // wateri) {
          // Why are these items in the reflection?
          if (obj.name=='chamberhearthbeds002'||obj.name=='olives'||obj.name=='herbs'||obj.name=='lamp') {
            Glob.watersiloam!.excludeFromReflection.add(obj);
          } else {
            final pos = THREE.Vector3();
            obj.getWorldPosition(pos);

            // Get the water's world position
            final waterPos = THREE.Vector3();
            Glob.watersiloam!.getWorldPosition(waterPos);

            final dx = pos.x - waterPos.x;
            final dz = pos.z - waterPos.z;
            final distSq = dx * dx + dz * dz;

            // Exclude anything more than e.g. 8 world units from the pool
            if (distSq > 3.0 * 3.0) {
              Glob.watersiloam!.excludeFromReflection.add(obj);
              //  excluded.add(obj.name);
            }

            // print('reflection' + obj.name + " xx " + OPENWORLD.BaseObject.getName(obj));
            //included.add(obj.name);
          }


        }



      });

    }
    // Only re-render reflection/refraction every 3 frames — ~3x cheaper,
    // imperceptible for a small still pool like the Pool of Siloam.
    Glob.watersiloam!.reflectionUpdateInterval =4;//3;

    waterlist.add(Glob.watersiloam);

    // So when enter the pool you hear a splash
    var waterdummy=THREE.Object3D();
    OPENWORLD.Space.worldToLocalSurfaceObj(waterdummy, -8.8,-52.66, 0);
    _hotload.add(waterdummy);
    OPENWORLD.BaseObject.setDistanceTrigger(
        waterdummy, dist: 0.1, event: (action) {
      if (action ) {
        playSplash();
      } else {

      }
    });
    waterdummy=THREE.Object3D();
    OPENWORLD.Space.worldToLocalSurfaceObj(waterdummy, -9.18,-52.3, 0);
    _hotload.add(waterdummy);
    OPENWORLD.BaseObject.setDistanceTrigger(
        waterdummy, dist: 0.1, event: (action) {
      if (action ) {
        playSplash();
      } else {

      }
    });


    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      // Some herb sellers in plaza
      var herbposs = [
        [-9.59 - 0.03 - 0.04, -50.64 + 0.05, 180],  // siloam
        [-10.11, -50.86, 0]   // siloam
      ];
      // var herbturn = 180; // -90+18;
      for (var pos in herbposs) {
        createHerbSeller(pos[0], pos[1],pos[2]);
      }

      // People walking around the pool of siloam
      List<List> siloampath = [
        [-8.00, -52.48],
        [-8.95, -51.68],
        [ -9.45, gamestart==GameStart.bethphage?-50.74-0.2:-50.74],
        [ -11.22, gamestart==GameStart.bethphage?-50.75-0.2:-50.75],
        [ -10.93, -53.75],
        [ -9.66, -54.82]];
      List<Map> positions = [];
      var siloamspeed=0.04;
      for (var pos in siloampath)
        positions.add({"p": [pos[0], pos[1], 0], "v": siloamspeed});
      List<List> siloampathreversed = getpathoffset(siloampath.reversed.toList(), true,0.1);  // so dont walk through eachother
      List<Map> positionsreverse = [];
      for (var pos in siloampathreversed)
        positionsreverse.add({"p": [pos[0], pos[1], 0], "v": siloamspeed});
      var startposlist=[];
      for (var j = 0; j < 15; j++) {
        List<dynamic> startpos;
        List<Map> usepositions;
        var reverse=OPENWORLD.Math.random()<0.5;
        var index ;
        var ok;
        do {
          ok=true;
          if (reverse)
            usepositions = positionsreverse;
          else
            usepositions = positions;
          index = OPENWORLD.Math.randInt(usepositions.length - 1);

          Map map = usepositions[index];
          Map prevmap;
          if (index > 0)
            prevmap = usepositions[index - 1];
          else
            prevmap = usepositions[positions.length - 1];
          startpos = OPENWORLD.Math.interpolateTwoPoints(
              map['p'], prevmap['p'], OPENWORLD.Math.random());
          // Dont allow any to be right on top of eachother
          for (var pos in startposlist) {
            if (OPENWORLD.Math.vectorDistance(THREE.Vector3(pos[0],pos[1],0.0), THREE.Vector3(startpos[0],startpos[1],0))<0.1)
              ok=false;
          }
        } while (!ok);
        OPENWORLD.Config
            .config['positions']['poolpositions'][2]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                 actorlist[j % actorlist.length]),
              //citizen3),
              'p': [
                startpos[0], //+ OPENWORLD.Math.randFloatSpread(0.3),
                startpos[1], // + OPENWORLD.Math.randFloatSpread(0.3),
                0
              ],
              //positions[index]['p'][0]+OPENWORLD.Math.randFloatSpread(0.3),positions[index]['p'][1]+OPENWORLD.Math.randFloatSpread(0.3),0],//-5.79, -13.06, 0], //3.2,-13.26,0],
              // Why must I do this to get the correct turn?
            //  't': 270,
              'action': "idle",
              'randomduration': 0.1,
              "lerpopacity": 1,
              "label": index,
              "labelreverse":reverse,
              //"labelstartpos": startpos,
              // "labeltest":"test",
              "callbackonvisible": (actor) {
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                var positionjson = OPENWORLD.Config.getPositionForObject(actor);
                //    print("positionjson"+positionjson.toString());
              //  setcancollide(actor, true);
                OPENWORLD.Space.resetRot(actor);

                //var worldpos=OPENWORLD.Space.localToWorldObj(actor);
                //  print("callbackonvis"+positionjson!['label'].toString()+" "+worldpos.toString()+" "+newpositions.toString());
                //    OPENWORLD.Space.objTurn(actor, positionjson!['labelangle']);
                var ind = positionjson!['label'];
                var reverse= positionjson!['labelreverse'];
                if (reverse)
                  usepositions=positionsreverse;
                else
                  usepositions=positions;

                var pathlistcopy = usepositions.toList();
                pathlistcopy.insert(ind, {
                  "p": [positionjson['p'][0], positionjson['p'][1], 0],
                  "v": girlspeed
                });
                OPENWORLD.Mob.moveToLoop(
                  actor,
                  pathlistcopy,
                  index: ind,
                  action: "walk",
                  //   facenow:true,
               //   looptype: OPENWORLD.Mob.LoopTypeReverseLoop, //.LoopTypeStop,
                  surfaceonly: true,
                  //   randomposition: true,
                  //   level:1

                  //   stopaction: "idle3",
                  // delay:finishedtime
                  // facedir: false
                ); // fadeout:null);//fadein:0.5); //
              },
              "callbackonhide": (actor) {
                OPENWORLD.Mob.removeObjectFromMoveTo(actor);
                OPENWORLD.Actor.disableDistanceThrottle(actor);
               // setcancollide(actor, false);

                // OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
              }
            });
        startposlist.add(startpos);
      }

      // This is for the pool objects standing around the siloam pool with two looking at eachother
      var diff = 0.2;
      var points=OPENWORLD.Math.interpolateByIncrement(siloampath,diff);
//      var points=closestPersonAngle(OPENWORLD.Math.interpolateByIncrement(siloampath,diff));
      var pointsexclude = OPENWORLD.Math.interpolateByIncrement(
          [[-9.07, -51.21, 0], [ -11.33, -50.85, 0],[-11.86,-50.0],[-7.93, -52.53]], diff / 2);
                                                                   // stable boy
      for (var i=0; i<10; i++) {
        var point;
        var point2;
        if (gamestart==GameStart.bethphage) {
          var found = false;
          do {
            found = false;
            point = OPENWORLD.Math.randPick(points);
            point2 = OPENWORLD.Math.vectorMoveForward(
                point[0], point[1], OPENWORLD.Math.random() * 360, 0.05);
            //  print("pointttu"+point.toString()+" "+point2.toString());
            for (var pos in pointsexclude) {
              var dist1 = OPENWORLD.Math.vectorDistance(
                  THREE.Vector3(pos[0], pos[1], 0.0),
                  THREE.Vector3(point[0], point[1], 0.0));
              var dist2 = OPENWORLD.Math.vectorDistance(
                  THREE.Vector3(pos[0], pos[1], 0.0),
                  THREE.Vector3(point2[0], point2[1], 0.0));
              if (dist1 < 0.1 || dist2 < 0.1)
                found = true;
            }
          } while (found);
        } else {
          point = OPENWORLD.Math.randPick(points);
          point2 = OPENWORLD.Math.vectorMoveForward(point[0], point[1], OPENWORLD.Math.random() * 360, 0.05);
        }
       // print("pointtt"+point.toString()+" "+point2.toString());
        var turn=OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(point[0],point[1],0),THREE.Vector3(point2[0],point2[1],0));
        var gender=OPENWORLD.Math.randPick(['men','women']);
        print("point siloam"+point.toString());
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(gender=='men'?manlist:womanlist)),//actorlist)),
              'p': [point[0], point[1]],
//              'p': [point[0]+OPENWORLD.Math.randFloatSpread(0.3), point[1]+OPENWORLD.Math.randFloatSpread(0.3)],
             // 'l': 1,
              't': turn,//point[2], // OPENWORLD.Math.random() * 360, //270,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'idle3',
              'randomduration': 0.1,
              'label':"siloam_"+i.toString(),
            //  'labelpersoninc':i,
             // 'labelperson':1,
              "callbackonvisible": (actor) {
                if (gamestart==GameStart.bethphage)
                  setcancollide(actor,true);
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                if (OPENWORLD.Math.random()<0.1) {
                  var positionjson = OPENWORLD.Config.getPositionForObject(actor);
                  var label=positionjson?['label'];
                  var positionfriendjsons = OPENWORLD.Config.getPositionsByLabel(
                      OPENWORLD.Config
                          .config['positions']['poolpositions'][1]['positions'],
                      label+"_2");
                  actor.extra['friend'] = OPENWORLD.Config.getPoolPositionObject(
                      positionfriendjsons[0]);
                  if (actor.extra['friend']!=null) {
                    var chat=OPENWORLD.Math.randPick(chatsgeneral?[gender]);
                    var citizenmeetchatterarr=createChat(chat);
                    var citizenmeetchatter=citizenmeetchatterarr[0];
                    var citizenmeet2chatter=citizenmeetchatterarr[1];
                    print("found friend"+citizenmeetchatter.toString()+" "+citizenmeet2chatter.toString());
                    var minwait=4;
                    var delay=OPENWORLD.Math.random()*10;
                    OPENWORLD.Mob.setSpeech(
                        actor,
                        citizenmeetchatter,
                        z: 140,
                        //0.5
                        //  scale: 0.3,
                        width: 300,
                        minwait: minwait,
                        clearwhendone: true,
                        randwait: 0,
                      delay:delay);
                    OPENWORLD.Mob.setSpeech(
                        actor.extra['friend'],
                        citizenmeet2chatter,
                        z: 90,//80,
                        minwait: minwait,
                        clearwhendone: true,
                        //0.5
                        //  scale: 0.3,
                        width: 300,
                        randwait: 0,
                        delay:delay+2);
                  } else
                    print("couldnt find your friend");
                }
              },
              "callbackonhide": (actor) {
                if (gamestart==GameStart.bethphage)
                   setcancollide(actor,false);
                OPENWORLD.Actor.disableDistanceThrottle(actor);
                if (actor.extra.containsKey('friend')) {
                  print("hide chat friend");
                  OPENWORLD.Mob.pauseSpeech(actor);
                  OPENWORLD.Mob.clearText(actor);
                  OPENWORLD.BaseObject.clearAll(actor);  // In case because of delay hasn't started speech but then starts laster after onhide
                  OPENWORLD.Mob.pauseSpeech(actor.extra['friend']);
                  OPENWORLD.Mob.clearText(actor.extra['friend']);
                  OPENWORLD.BaseObject.clearAll(actor.extra['friend']);
                }
              },
              'startat': OPENWORLD.Math.random(),
            //  'label': 'courtwomen',
              "lerpopacity": 1
            });
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(gender=='men'?manlist:womanlist)),
              'p': [point2[0], point2[1]],
              // 'l': 1,
              't': turn-180,//point[2], // OPENWORLD.Math.random() * 360, //270,
              'label':"siloam_"+i.toString()+"_2",
              //'label':i,
              //'labelperson':1,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'idle3',
              "callbackonvisible": (actor) {
                setcancollide(actor,true);
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
              },
              "callbackonhide": (actor) {
                setcancollide(actor,false);
                OPENWORLD.Actor.disableDistanceThrottle(actor);
                },
              'randomduration': 0.1,
              'startat': OPENWORLD.Math.random(),
              //  'label': 'courtwomen',
              "lerpopacity": 1
            });
      }

      // Put a path through crowd around plaza for bethphage journey so can get through
      List<List> exclude=[];
      if (gamestart==GameStart.bethphage) {
        var essendiff = 0.4;
        var essenpoints = OPENWORLD.Math.interpolateByIncrement(
            citizenessenpath, essendiff / 2);

        for (var point in essenpoints) {
          if (point[1] > -50.33 && point[1] < -49.38)
            exclude.add([point[0], point[1], essendiff]);
        }
        var pointsexclude = OPENWORLD.Math.interpolateByIncrement(
            [[-9.07, -51.21, 0], [ -11.33, -50.85, 0],[-11.86,-50.0]], diff / 2);
        for (var point in pointsexclude) {
          if (point[1] > -50.33 && point[1] < -49.38)
            exclude.add([point[0], point[1], diff]);

        }
      }
      // Plaza crowd
      var siloamplazapoints = closestPersonAngle(createCrowdPoints(
          -11.67,
          -10.2,
          -50.33,
          -49.38,
          10,
          0.02,
          exclude));
      for (var point in siloamplazapoints) {
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(actorlist)),
              'p': [point[0], point[1]],
              't': point[2], // OPENWORLD.Math.random() * 360, //270,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'idle3',
              "callbackonvisible": (actor) {
                setcancollide(actor,true);
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
              },
              "callbackonhide": (actor) {
                setcancollide(actor,false);
                OPENWORLD.Actor.disableDistanceThrottle(actor);
                },
              'randomduration': 0.1,
              'startat': OPENWORLD.Math.random(),
              "lerpopacity": 1
            });
      }



    }



    // water gate soldiers
    // spear.children[0].scale.setValues(5.0, 5.0, 5.0); //0.15, 0.15, 0.15);

    var doorwatergatesouth = doorwood.clone();
    _hotload.add(doorwatergatesouth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwatergatesouth,-7.4-0.04, -52.83, 0.00,
        10);
    doorwatergatesouth.scale.setValues(0.2, 0.27, 0.12);

    var doorwatergatenorth = doorwatergatesouth.clone();
    _hotload.add(doorwatergatenorth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwatergatenorth, -7.32-0.04, -52.73+0.02, 0.00,
        10);

    var doorwaywatergate=OPENWORLD.Doorway();
    doorwaywatergate.addDoor(doorwatergatesouth,33-180-90,33-180);
    doorwaywatergate.addDoor(doorwatergatenorth,33+90,33);

    doorwaywatergate.obstacle=  OPENWORLD.Obstacles.createObstacle(-7.36,-52.78,0.2,0.2);//,marker:_hotload);
    doorwaywatergate.setOpenClose(!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwaywatergate);


    OPENWORLD.Actor.wield(soldier22, spear, "Bip01_R_Hand");
    var soldier22iii = await OPENWORLD.Actor.copyActor(soldier22, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier22iii, -7.23, -52.71,0,// -7.35, -52.8, 0,
        3, lerpopacity: 1);
    _hotload.add(soldier22iii);
    OPENWORLD.Space.objTurn(soldier22iii, 120);
    OPENWORLD.Actor.enableDistanceThrottle(soldier22iii, minDistance: 0.5, skipFrames: 6);

    var soldier23iii = await OPENWORLD.Actor.copyActor(soldier23, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier23iii,-7.38, -52.90,0,//-7.49, -53.14, 0,//-7.21, -52.96,0,//,  0,//-7.39, -52.92,0,//
        3,lerpopacity: 1);
    _hotload.add(soldier23iii);
    OPENWORLD.Actor.enableDistanceThrottle(soldier23iii, minDistance: 0.5, skipFrames: 6);

    OPENWORLD.Space.objTurn(soldier23iii, 120);
    OPENWORLD.Actor.wield(soldier23iii, spear.clone(), "Bip01_R_Hand");
    if (OPENWORLD.Math.random()<0.05) {
      var hasseen = false;
      OPENWORLD.BaseObject.setDistanceTrigger(
          soldier23iii, dist: 0.3, event: (action) {
        if (action && !hasseen) {
          hasseen = true;
          OPENWORLD.Space.faceObjectLerp(soldier23iii, threeJs.camera, 1.0);
          OPENWORLD.Mob.setSpeech(soldier23iii,
              ["Aren't you?...",
                "Never mind"], z: 100,
              width: 300,
              clearwhendone: true,
              minwait: 4,
              scale: 0.4,
              randwait: 0,
              //   delay:9
              callbackonfinish: (actor) {
                OPENWORLD.Space.objTurnLerp(soldier23iii, 120, 1.0);
              }
          );
        } else {

        }
      });
    }

    // dung gate
    var doordunggatewest = doorwood.clone();
    _hotload.add(doordunggatewest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doordunggatewest,-10.9, -55.95+0.04, 0.00,
        10);
    doordunggatewest.scale.setValues(0.2, 0.27, 0.12);

    var doordunggateeast = doordunggatewest.clone();
    _hotload.add(doordunggateeast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doordunggateeast, -10.75, -55.95+0.04, 0.00,
        10);

    var doorwaydunggate=OPENWORLD.Doorway();
    doorwaydunggate.addDoor(doordunggatewest,180,-90);
    doorwaydunggate.addDoor(doordunggateeast,180,90);

    doorwaydunggate.obstacle=  OPENWORLD.Obstacles.createObstacle(-10.8,-55.95+0.04,0.4,0.7);//,marker:_hotload);
    doorwaydunggate.setOpenClose(true);//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwaydunggate);

    // Dung gate soldiers
    var soldier24iii = await OPENWORLD.Actor.copyActor(soldier24, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier24iii,-10.68, -56.03,0,//-7.49, -53.14, 0,
        3,lerpopacity: 1);
    _hotload.add(soldier24iii);
    OPENWORLD.Space.objTurn(soldier24iii, 180);
    OPENWORLD.Actor.wield(soldier24iii, spear.clone(), "Bip01_R_Hand");
    OPENWORLD.Actor.enableDistanceThrottle(soldier24iii, minDistance: 0.5, skipFrames: 6);

    var soldieriii = await OPENWORLD.Actor.copyActor(soldier2, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldieriii, -10.95, -56.01,0,//-7.49, -53.14, 0,
        3,lerpopacity: 1);
    _hotload.add(soldieriii);
    OPENWORLD.Space.objTurn(soldieriii, 180);
    OPENWORLD.Actor.wield(soldieriii, spear.clone(), "Bip01_R_Hand");
    OPENWORLD.Actor.enableDistanceThrottle(soldieriii, minDistance: 0.5, skipFrames: 6);

    if (gamestart == GameStart.bethphage||(gamestart==GameStart.roam&&!OPENWORLD.Time.isNight(OPENWORLD.Time.time))) {  //gamestart == GameStart.bethphage) {
      // Bathers bathing - just have them loop over and over
      // Both men and women
      Glob.bathingstep=-1;

      // no citizen3 because that is your friend
      var batherlist2 = [
        citizen32,
        citizen33,
        citizen34,
        citizen35,
        citizen36,
        citizen34,
        citizen33
      ];
      var batherlistf2 = [citizenf3, citizenf32, citizenf33, citizenf34];

      // Either do men or women
      for (var k = 0; k < 2; k++) {
        // batherstart pos is the position outside the tent entrance
        var batherstartposx = k == 0
            ? -8.42
            : -10.92; //-8.23+0.1;;//, -9.23;//  -8.49;
        var batherstartposy = k == 0
            ? -52.46
            : -53.18; //-52.48;//-52.61-0.1;//-52.29;//-52.06;
        var batherclothesposx = k == 0
            ? -9.18
            : -10.72; //-9.29;//, -9.23;//  -8.49;
        var batherclothesposy = k == 0
            ? -52.15
            : -52.48; //-52.27;//-52.29;//-52.06;

        var batherfinalposx = k == 0 ? -9.29 : -10.54; //, -9.23;//  -8.49;
        var batherfinalposy = k == 0 ? -52.27 : -52.46; //-52.29;//-52.06;

       // var maxtotaltime = 0.0;
        var batherangle = k == 0 ? 125.90 : 180.0; //0.0;
        var usebatherlist = k == 0 ? batherlist2 : batherlistf2;
        //print("voooot"+k.toString()+" "+ batherangle.toString());

        for (var i = 0; i < 8; i++) {
          var bather = await OPENWORLD.Actor.copyActor(
              usebatherlist[i % usebatherlist.length], action: "idle3",
              randomduration: 0.1,
              startat: OPENWORLD.Math.random());
          if (k==0)
            Glob.watersiloam.includeInReflection.add(bather);
          bather.extra['k'] = k;
          bather.extra['i']=i;
          // get position whether the bathers are in a row outside the tent - but not actual placement here
          var batherpos = OPENWORLD.Math.vectorMoveForward(batherstartposx, batherstartposy, batherangle, i * 0.04);

          // OPENWORLD.Space.worldToLocalSurfaceObjHide(
          //  citizen3ii, batherpos.x + OPENWORLD.Math.randFloatSpread(0.03),
          //  batherpos.y + OPENWORLD.Math.randFloatSpread(0.04), 0,
          //  3); //-11.06., -46.72,0,3);//-10.75, -47.08,0.01,3);//-9.91, -45.75,0,3);//-14.05, 63.96,0,3);//-14.11, 64.25, 0.0, 3); //3.42);
          ///   OPENWORLD.Space.worldToLocalSurfaceObjHide(
          //     citizen3ii, batherpos.x + 0.6,
          //       batherpos.y + 0.6, 0,
          //     3); //-11.06., -46.72,0,3);//-10.75, -47.08,0.01,3);//-9.91, -45.75,0,3);//-14.05, 63.96,0,3);//-14.11, 64.25, 0.0, 3); //3.42);
          _hotload.add(bather);
          //if (i==4)
          // OPENWORLD.Space.objTurn(citizen3ii,
          //      290-180+ OPENWORLD.Math.randFloatSpread(40));
          //else
          OPENWORLD.Space.objTurn(bather,
              batherangle + OPENWORLD.Math.randFloatSpread(40)); // 290


          var batherclothespos = OPENWORLD.Math.vectorMoveForward(
              batherclothesposx, batherclothesposy, batherangle, i * 0.07);


          var batherfinalpos = OPENWORLD.Math.vectorMoveForward(
              batherfinalposx, batherfinalposy, batherangle, i * 0.07);
          // Future.delayed(
          //     Duration(milliseconds: 14000+i*OPENWORLD.Math.randFloat(500,1000).toInt()), () async {
          var clothespileii = clothespile.clone();
          _hotload.add(clothespileii);
          OPENWORLD.Space.worldToLocalSurfaceObj(
              clothespileii, batherclothespos.x, batherclothespos.y, 0);
          //OPENWORLD.Space.worldToLocalSurfaceObjHide(
          //  clothespileii, batherposx + 0.1, batherposy - 0.1 - i * 0.07, 0, 2);
          // OPENWORLD.Space.setTurnPitchRoll(robes2iii, 0,0,0);

          OPENWORLD.Space.objTurn(clothespileii, OPENWORLD.Math.random() * 360);
          clothespileii.visible = false;
          var batheractionlist = bathingactions.toList();
          batheractionlist.shuffle();
          //  var randdist=OPENWORLD.Math.randFloat(0.5, 0.7);
          // var randspeed=girlspeed*randdist/0.6;
          var distback=0.8;
          var rnd = OPENWORLD.Math.randFloat(distback,1.0);//0.6, 1.0);
          var randspeed = girlspeed * rnd;
          //  v=d/t  t=d/v
          var timediff = (distback / randspeed) - (distback / girlspeed);  // Used to work out how long need to idle outside the tent before walk in to in sync
          //var timediff = (0.6 / randspeed) - (0.6 / girlspeed);  // Used to work out how long need to idle outside the tent before walk in to in sync

          // This technique relies on distance from batherpos being 0.6 to get the correct timediff
          var startpos;
          if (k==0)
            // This is where you are placing the bathers in the cliff - the distance is 0.6
            // Have them come out of the watergate instead of the cliff
            startpos = OPENWORLD.Math.vectorMoveForward(batherpos.x, batherpos.y, 90+OPENWORLD.Math.randFloatSpread(1.0),distback);// 0.6); //randdist);// 0.6);
          //  startpos= THREE.Vector3(-7.4+OPENWORLD.Math.randFloatSpread(0.04),-52.74+OPENWORLD.Math.randFloatSpread(0.04),0.0);
          else
            // Female startpos
            startpos = OPENWORLD.Math.vectorMoveForward(batherpos.x, batherpos.y, batherangle - 180 + OPENWORLD.Math.random() * 180, distback);//0.6); //randdist);// 0.6);
//        var startpos=OPENWORLD.Math.vectorMoveForward(batherpos.x, batherpos.y,batherangle/*290*/+OPENWORLD.Math.random()*180, 0.6);//randdist);// 0.6);
          List<Map> actions = [
            {
              // Spot where start before walking to line
              "p": [startpos.x, startpos.y, 0],
              //OPENWORLD.Math.randFloatSpread(0.04), 0],
              "v": girlspeed,
              'callback': (actor) {
                // Make sure at the start they have their clothes on
                Glob.bathingstep=0;
                if (actor.extra['k'] == 0) {
                  //print("bathers clothes onii");
                  OPENWORLD.BaseObject.setVisible(actor, true, groupname: "citizen_3"); //put on pants
                  OPENWORLD.BaseObject.setVisible(actor, true, groupname: "citizen_4"); // put on clothes
                } else {
                  OPENWORLD.BaseObject.setVisible(actor, true, groupname: "citizen_1"); //put on shoes
                  OPENWORLD.BaseObject.setVisible(actor, true, groupname: "citizen_2"); // put on clothes
                }
                clothespileii.visible = false; // show the clothes on the ground

              }
            },
            { // where line up
              "p": [batherpos.x + OPENWORLD.Math.randFloatSpread(0.025),
                batherpos.y + OPENWORLD.Math.randFloatSpread(0.04), 0],
              "v": randspeed, //girlspeed// * OPENWORLD.Math.randFloat(0.6, 1.0)
            },
            {
              "action": "idle3",
              "time": 14 - timediff + i * OPENWORLD.Math.randFloat(0.5, 1.0),
              "startat": OPENWORLD.Math.random(),
              //  "duration": 18.5 + OPENWORLD.Math.randFloatSpread(5),
              "t": (k == 0 ? 290 : 0) + OPENWORLD.Math.randFloatSpread(40),
              "callback":(actor) {
                Glob.bathingstep=1;
              }
            },
            {
              "p": k == 0 ? [-8.49, -52.43, 0] : [ -10.87, -53.13, 0],
              "v": girlspeed
            }, // entrance of the tent   -10.86, -53.20
            {
              "p": k == 0 ? [-8.73, -52.53, 0] : [-10.65, -53.18, 0],
              "v": girlspeed
            }, // the ledge
            // walk to clothes position
            {
              "p": [
                batherclothespos.x + OPENWORLD.Math.randFloatSpread(0.04),
                batherclothespos.y + OPENWORLD.Math.randFloatSpread(0.04),
                0
              ],
              "v": girlspeed
            },
            {"action": "armsup", "time": 1.0,},
            {"action": "hitup", "time": 1.0, 'callback': (actor) {
              Glob.bathingstep=2;
              if (actor.extra['k'] == 0) {
                // print("bathers clothes off");
                OPENWORLD.BaseObject.setVisible(
                    actor, false, groupname: "citizen_3"); // no pants
                OPENWORLD.BaseObject.setVisible(
                    actor, false, groupname: "citizen_4"); // no clothes
              } else {
                OPENWORLD.BaseObject.setVisible(
                    actor, false, groupname: "citizen_1"); // no shoes
                OPENWORLD.BaseObject.setVisible(
                    actor, false, groupname: "citizen_2"); // no clothes
              }

              clothespileii.visible = true; // show the clothes on the ground
            }},
            {"action": "pickupright", "time": 10.0,},
            // Walk into pool
            {
              "p": [
                batherfinalpos.x + OPENWORLD.Math.randFloatSpread(0.04),
                batherfinalpos.y + OPENWORLD.Math.randFloatSpread(0.04),
                0
              ],
              "v": girlspeed / 2,
              "callback":(actor) {
                Glob.bathingstep=3;

                if (actor.extra['k']==0&&OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, actor)<0.5) {
                 // playSplash();
                }
              }

            }
          ];

          // Do 20 bathing actions in the pool
          for (var j = 0; j < 20; j++) {
            Map action = {
              "action": batheractionlist[j % batheractionlist.length]
            };
            if (j % batheractionlist.length == 0) {
              action['t'] = OPENWORLD.Math.randFloatSpread(40);
            }
            if (j % 5 == 0&&i==0) {
              action["callback"]=(actor) {
                if (//actor.extra['i'] == 0 &&
                    OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, actor) < 0.5) {
                  playSplash(volume:0.5);
                }
              };

            }
            actions.add(action);
          }
          // After bathing move back to clothes
          actions.add({
            "p": [
              batherclothespos.x + OPENWORLD.Math.randFloatSpread(0.04),
              batherclothespos.y + OPENWORLD.Math.randFloatSpread(0.04),
              0
            ],
            "v": girlspeed / 2
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
            Glob.bathingstep=4;
            if (actor.extra['k'] == 0) {
              //  print("bathers clothes on");
              OPENWORLD.BaseObject.setVisible(
                  actor, true, groupname: "citizen_3"); //put on pants
              OPENWORLD.BaseObject.setVisible(
                  actor, true, groupname: "citizen_4"); // put on clothes
            } else {
              OPENWORLD.BaseObject.setVisible(
                  actor, true, groupname: "citizen_1"); //put on shoes
              OPENWORLD.BaseObject.setVisible(
                  actor, true, groupname: "citizen_2"); // put on clothes
            }
            clothespileii.visible = false; // show the clothes on the ground
          }});
          actions.add({
            "p": k == 0 ? [-9.19, -52.16, 0] : [ -10.71, -52.55, 0],
            "v": girlspeed
          }); // of the clothes line
          actions.add({
            "p": k == 0 ? [-8.93, -51.97, 0] : [-11.03, -52.53, 0],
            "v": girlspeed
          }); // out of the tent
          actions.add({
            "p": k == 0 ? [-9.49, -50.74, 0] : [-11.21, -50.75, 0],
            "v": girlspeed
          }); // up to the plaza


         // var totaltime =
          OPENWORLD.Mob.moveToLoop(
            bather,
            actions,
            //index:k==0?0:5,
            surfaceonly: true,
            hidedist: 3,
            looptype: OPENWORLD.Mob.LoopTypeStop,
            action: "walk",

          );
          //if (totaltime > maxtotaltime)
          //  maxtotaltime = totaltime;

          // This basically checks if the bather if visible every 3 minutes and if so restart the animation
          // You are restarting it like this because you need all the bathers synced!!
          var t = Timer.periodic(const Duration(seconds: 165 + 2), (timer) {
            // var totaltime =
            // this is happening whenever it is day time
            print("in bathing timer");
            if (bather.visible)
              OPENWORLD.Mob.moveToLoop(
                bather,
                actions,
                // index:k==0?0:5,
                surfaceonly: true,
                // randomduration:0.1,
                looptype: OPENWORLD.Mob.LoopTypeStop,
                action: "walk",

              );
          });
          // print("bather total time"+totaltime.toString());
          // if (totaltime>maxtotaltime)
          //   maxtotaltime=totaltime;

          //});
        }
      }

      // Rabbi at plaza
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(citizen35),//

            'p': [ -10.2, -51.33 - 0.01],
            't': -180,
            'action':  "sittableidle",
            'randomduration': 0.1,
            "lerpopacity": 1,
            "callbackonvisible":(actor) {
              OPENWORLD.Actor.playActionsLoop(actor, [
                "sittablepoint",
                "sittableidle",
                "sittablewave",
                "sittableidle",
                "sittablearmsup",
                "sittableidle"
              ], durations: [2, 5, 2, 5, 3, 5]); //,
              loopspeech(actor,rabbitexts);
              OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
            },
            "callbackonhide":(actor) {
              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
           //   OPENWORLD.Mob.pauseChatter(actor);
              OPENWORLD.Mob.pauseSpeech(actor);
              OPENWORLD.Actor.disableDistanceThrottle(actor);

            }
          });



      List<Map> disciplesu = [
        {
          "p": [-10.2 - 0.04, -51.54 + 0.035],
          "t": 90 + 20,
          "action": "sittableleft"
        },
        {
          "p": [-10.2 - 0.04 - 0.04, -51.54 + 0.035],
          "t": 90 + 20,
          "action": "sittableleft"
        },
        {
          "p": [-10.2 + 0.04, -51.54 + 0.02],
          "t": -90 + 20,
          "action": "sittableright"
        },
        {
          "p": [-10.2 + 0.04 + 0.04, -51.54 + 0.035],
          "t": -90 + 20,
          "action": "sittableright"
        },
        {"p": [ -10.20, -51.59 + 0.02], "t": 0, "action": "idle3"},
        {"p": [ -10.20, -51.46], "t": 0, "action": "squat"},//sitidle"},
        {"p": [ -10.20 - 0.08, -51.46], "t": 20, "action": "squat"},//sitidle"},
        {"p": [ -10.20 + 0.08, -51.46], "t": -20, "action": "squat"},
      ];
      actorlist.shuffle();
      for (var i = 0; i < disciplesu.length; i++) {
        var actor=actorlist[i % actorlist.length];
        var z;
        if (childrenlist.contains(actor) &&
            disciplesu[i]["action"].contains("sittable"))
          z = 0.01;
        else
          z = 0.0;
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(actor),//
                //  OPENWORLD.Math.randPick(adultlist, exclude:[adultpick])),
              'p': [ disciplesu[i]["p"][0], disciplesu[i]["p"][1],  z],
              't': disciplesu[i]["t"].toDouble(),
              'action':  disciplesu[i]["action"],
              'randomduration': 0.1,
              'startat': OPENWORLD.Math.random(),
              "callbackonvisible":(actor) {
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
              },
              "callbackonhide":(actor) {
                OPENWORLD.Actor.disableDistanceThrottle(actor);
              },
              "lerpopacity": 1
            });



      }
      await OPENWORLD.Config.createPoolObjects();//_hotload);

      // Two people in plaza chatting
   /*   var plazacitizen = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(adultlist), action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          plazacitizen, -10.12, -50.70, 0, 3);
      _hotload.add(plazacitizen);
      OPENWORLD.Space.objTurn(plazacitizen, -90); //90+20);
*/
      // I think this is just the two guys you had facing eachother
      var adultpick=OPENWORLD.Math.randPick(adultlist);
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(adultpick),
            'p': [ -10.12, -50.70,  0],
            't':-90,
            'action':  'idle3',
            'randomduration': 0.1,
            "callbackonvisible":(actor) {
              OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
            },
            "callbackonhide":(actor) {
              OPENWORLD.Actor.disableDistanceThrottle(actor);
            },
            'startat': OPENWORLD.Math.random(),
            //  'label':'sleeping',
            /*  "callbackonvisible":(actor) {

                  OPENWORLD.Actor.playActionThen(
                      actor, "wave", "idle",  delay: 5.0);
                },
                "callbackonhide":(actor) {
                 // OPENWORLD.Mob.pauseChatter(actor);

                },*/
            "lerpopacity": 1
          });
    /*  var plazacitizen2 = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(adultlist, exclude: [plazacitizen]),
          action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          plazacitizen2, -10.12 - 0.04, -50.70, 0, 3);
      _hotload.add(plazacitizen2);
      OPENWORLD.Space.objTurn(plazacitizen2, 90 + 5); //90+20);
*/
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(
                OPENWORLD.Math.randPick(adultlist, exclude:[adultpick])),
            'p': [ -10.12 - 0.04, -50.70,  0],
            't':90+5,
            'action':  'idle3',
            'randomduration': 0.1,
            'startat': OPENWORLD.Math.random(),
            "lerpopacity": 1,
            "callbackonvisible":(actor) {
              OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
            },
            "callbackonhide":(actor) {
              OPENWORLD.Actor.disableDistanceThrottle(actor);
            }
          });
      await OPENWORLD.Config.createPoolObjects();//_hotload);

    }

    // Donkey in the animal yard
    roomStableSiloam = OPENWORLD.Room.createRoom(-11.68,-53.74,
        roomspeed: 1.0 / 20 , randomsoundpaths: ['sounds/donkey.mp3','sounds/donkey2.mp3'],
        exitroom: roomTerrain); //THREE.Object3D();
    //OPENWORLD.Room.setIndoors(roomStablebethesda,true);
    //OPENWORLD.Room.setAutoIndoors(roomLowercity, true);
    _hotload.add(roomStableSiloam);

    OPENWORLD.Room.setDistanceTrigger(roomStableSiloam,
        maxy: -53.49, miny: -54.01, minx:-12.16, maxx: -11.23);

    var donkey4 = await OPENWORLD.Actor.copyActor(
        donkeypack); //,action:"walk",resetposition: true);//,action:"idle3");
    donkey4.scale.setValues(0.04, 0.04,
        0.04); //25, 0.0025, 0.0025);
    _hotload.add(donkey4);
    OPENWORLD.Actor.enableDistanceThrottle(donkey4, minDistance: 0.5, skipFrames: 6);
    OPENWORLD.BaseObject.setVisible(
        donkey4, true, groupname: "horse001_1"); // show rope
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        donkey4, -11.99 - 0.015, -53.81 - 0.015, 0.01, 3,
        lerpopacity: 1.0); //, normalize2world:true);
    OPENWORLD.Space.objTurn(donkey4, 90 + 20, normalize2world: true);
    var hay2 = hay.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay2, -11.90, -53.82, 0.01, 2); // 3.2,2.5, 0.0);
    _hotload.add(hay2);
    hay2.scale.setValues(0.04, 0.04, 0.04);
    var manger6 = manger.clone();
    _hotload.add(manger6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        manger6, -12.05, -53.77, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(manger6, 90);


    var donkey5 = await OPENWORLD.Actor.copyActor(
        donkey4); //,action:"walk",resetposition: true);//,action:"idle3");
    _hotload.add(donkey5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        donkey5, -11.42, -53.98 + 0.05, 0.01, 3,
        lerpopacity: 1.0); //, normalize2world:true);
    OPENWORLD.Actor.enableDistanceThrottle(donkey5, minDistance: 0.5, skipFrames: 6);
    OPENWORLD.Space.objTurn(donkey5, 0, normalize2world: true);
    var hay3 = hay2.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay3, -11.44, -53.91 + 0.05, 0.01, 2); // 3.2,2.5, 0.0);
    _hotload.add(hay3);
    var manger7 = manger.clone();
    _hotload.add(manger7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        manger7, -11.37, -53.8, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(manger7, 0);

    var donkey6 = await OPENWORLD.Actor.copyActor(
        donkey4); //,action:"walk",resetposition: true);//,action:"idle3");
    _hotload.add(donkey6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        donkey6, -11.57, -53.52, 0.01, 3,
        lerpopacity: 1.0); //, normalize2world:true);
    OPENWORLD.Actor.enableDistanceThrottle(donkey6, minDistance: 0.5, skipFrames: 6);
    OPENWORLD.Space.objTurn(donkey6, 180, normalize2world: true);
    var hay23 = hay2.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay23, -11.59, -53.59, 0.01, 2); // 3.2,2.5, 0.0);
    _hotload.add(hay23);
    var manger8 = manger.clone();
    _hotload.add(manger7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        manger8, -11.52, -53.52, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(manger8, 0);
    var fence3x = fence3.clone();
    _hotload.add(fence3x);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3x, -11.84 - 0.1, -54.01, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence3x, 90);
    var goativ = await OPENWORLD.Actor.copyActor(goat);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        goativ,
        -11.84 - 0.2, -54.01, 0.02, 5);
    // OPENWORLD.Space.objTurn(sheep.children[0], 180);
    //  OPENWORLD.Space.objTurn(crab  ,90);  //e
    _hotload.add(goativ);
    OPENWORLD.Actor.enableDistanceThrottle(goativ, minDistance: 0.5, skipFrames: 6);
    var fence3xi = fence3.clone();
    _hotload.add(fence3xi);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3xi, -11.92, -53.90, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence3xi, 90);

    // Columns in plaza
    for (var i = 0; i < 10; i++) {
      //instancedRings.place(0, 3.84 + i * 0.13, 0.72 + j * 0.13, 0.0, level:1)
     /* var column2 = column.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          column2, -9.6- i * 0.15, -50.8-0.05, 0,
          10); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);
      column2.scale.setValues(0.4,0.4,0.4);
      OPENWORLD.Space.objTurn(column2, -90);*/
      instancedColumnsSiloam.place(-90,  -9.6- i * 0.15, -50.8-0.05, 0.0,scale:THREE.Vector3(0.4,0.4,0.4));
     /* column2 = column.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          column2, -9.6- i * 0.15, -50.8+0.2+0.05, 0,
          10); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);
      column2.scale.setValues(0.4,0.4,0.4);
      OPENWORLD.Space.objTurn(column2, -90);*/
      instancedColumnsSiloam.place(-90,  -9.6- i * 0.15, -50.8+0.2+0.05, 0.0,scale:THREE.Vector3(0.4,0.4,0.4));

    }

    instancedColumnsSiloam.finish();

  }
}
