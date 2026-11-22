// Code for the pilgrims road. Shared between different journeys like lowercity, bethphage
part of 'SecondTemplePage.dart';

extension HotloadPilgrimsroadExt on SecondTemplePageState {
  hotloadPilgrimsroad(firsthotload
      ) async {
     //Pilgrimsroad
    // Along the pilgrims road
    var shopawninginstance = true;
    if (shopawninginstance) {
      instancedShopawnings.reset();
    }

    roomPilgrimsroad = OPENWORLD.Room.createRoom(-12.0, -45.98,
        soundpath: !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/courtyard.mp3":null, volume:0.05,  roomspeed: 1.0 / 20 ,
//        soundpath: OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/pool.mp3":"sounds/courtyard2.mp3", volume:0.05,  roomspeed: 1.0 / 20 ,
        exitroom: roomTerrain); //THREE.Object3D();

    roomPilgrimsroad.extra['guide'] = [
      "You are on Pilgrims Road",
    ];
    _hotload.add(roomPilgrimsroad);
    OPENWORLD.Room.setDistanceTrigger(roomPilgrimsroad,
        maxy: -39, miny: -48.9, minx:-12.6, maxx: -11.1, event:(action) {
          if (action) {
            setState(() {
              if (mounted)
                roomname = "Pilgrims Road";
            });
          } else {

            setState(() {
              if (mounted)
                roomname = "";
            });
          }
        });


    // For animals that make a sound along the pilgrims road, what is the chance they do when you pass them
    var animalsoundchance=0.4;

    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var donkey4ii = await OPENWORLD.Actor.copyActor(donkeypack);
      donkey4ii.scale.setValues(0.04, 0.04, 0.04);
      _hotload.add(donkey4ii);
      OPENWORLD.BaseObject.setVisible(
          donkey4ii, true, groupname: "horse001_1"); // show rope
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkey4ii, -11.93, -45.54 - 0.02, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(donkey4ii, 0, normalize2world: true);
      OPENWORLD.BaseObject.setDistanceTrigger(
          donkey4ii, dist: 0.2, event: (action) {
        if (action&&OPENWORLD.Math.random()<animalsoundchance ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/donkey.mp3','sounds/donkey2.mp3']), volume: 0.5, delay:OPENWORLD.Math.random()*10);
        }
      });

      // goat owner
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(OPENWORLD.Math.randPick(adultlist)),
        'p': [-12.14, -44.54, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'label':'goatowner',
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });

      var goat4iii = await OPENWORLD.Actor.copyActor(
          goat, randomduration: 0.1, duration: 6);
      _hotload.add(goat4iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          goat4iii, -12.09 - 0.02, -44.48, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(goat4iii, 180);
      OPENWORLD.BaseObject.setVisible(goat4iii, true, groupname: "collar");
      if (OPENWORLD.Math.random()<0.05) {
        var hasseen = false;
        OPENWORLD.BaseObject.setDistanceTrigger(
            goat4iii, dist: 0.2, event: (action) {
          if (action && !hasseen) {
            hasseen = true;
            // OPENWORLD.Space.faceObjectLerp(goat4iii, threeJs.camera, 1.0);

            OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/goat.mp3','sounds/goat2.mp3','sounds/goat3.mp3']), volume: 0.5, delay:OPENWORLD.Math.random()*10);


            OPENWORLD.Mob.placeBeforeCamera(
                goat4iii, 0.15, time: 2, action: "walk", stopaction: "idle");
            var goatpositions = OPENWORLD.Config.getPositionsByLabel(
                OPENWORLD.Config
                    .config['positions']['poolpositions'][1]['positions'],
                'goatowner');
            var goatowner = OPENWORLD.Config.getPoolPositionObject(
                goatpositions[0]);
            if (goatowner != null) {
              OPENWORLD.Space.faceObjectLerp(goatowner, threeJs.camera, 1.0);
              OPENWORLD.Mob.setSpeech(
                goatowner, ["Sorry about that.",
                "It has a temper",
                "Come back here"], z: 90,
                // Scatophagē!
                width: 400,
                scale: 0.4,
                randwait: 0,
                delay: 1,
                clearwhendone: true,
              );
            }
          } else {
            OPENWORLD.Mob.moveTo(
                goat4iii,
                [
                  [-12.09 - 0.02, -44.48, 0, 0.02],
                ], action: "walk",
                stopaction: "idle",
                actionduration: 2,
                surfaceonly: true);

          }
        });
      }
      var basket9ii = basket.clone();
      hotloadAdd(firsthotload, false, basket9ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket9ii, -11.90, -45.77, 0, 2);
      basket9ii.scale.setValues(0.002, 0.002, 0.002);

      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizen35),
        'p': [-12.22, -44.97, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var citizen35ii = await OPENWORLD.Actor.copyActor(
          citizen35, action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen35ii, -12.22, -44.97, 0.0, 3);
      _hotload.add(citizen35ii);
      OPENWORLD.Space.objTurn(citizen35ii, 90);
      */

      var amphora16ii = amphora.clone();
      hotloadAdd(firsthotload, false, amphora16ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          amphora16ii, -12.24 + 0.02, -45.15, 0.0, 2);
      var jug7ii = jug.clone();
      _hotload.add(jug7ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          jug7ii, -12.24 + 0.03, -45.03, 0.00, 2);
      OPENWORLD.Space.objTurn(jug7ii, 180);

      var pot15ii = pot.clone();
      _hotload.add(pot15ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot15ii, -11.77, -44.28, 0.00, 2);
      OPENWORLD.Space.objTurn(pot15ii, 180);
      var pot15iii = pot.clone();
      _hotload.add(pot15iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot15iii, -11.80, -44.32, 0.00, 2);
      OPENWORLD.Space.objTurn(pot15iii, 180);


      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizen36),
        'p': [-11.75 + 0.02, -44.12, 0.0],
        't': -90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var citizen36ii = await OPENWORLD.Actor.copyActor(
          citizen36, action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen36ii, -11.75 + 0.02, -44.12, 0.0, 3);
      _hotload.add(citizen36ii);
      OPENWORLD.Space.objTurn(citizen36ii, -90);
      */

      var sheep2ii = await OPENWORLD.Actor.copyActor(
          sheeporig, randomduration: 0.1, duration: 6);
      _hotload.add(sheep2ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep2ii, -11.82, -46.71, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(sheep2ii, 180);
      OPENWORLD.Space.objTurn(sheep2ii.children[0], 0); // Why this be done
      OPENWORLD.Space.objTurn(sheep2ii.children[1], 0);
      OPENWORLD.BaseObject.setVisible(sheep2ii, true, groupname: "collar");
      OPENWORLD.BaseObject.setDistanceTrigger(
          sheep2ii, dist: 0.2, event: (action) {
        if (action&&OPENWORLD.Math.random()<animalsoundchance ) {
          OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5, delay:OPENWORLD.Math.random()*10);
        }
      });

      /*
      var citizenf34ii = await OPENWORLD.Actor.copyActor(
          citizenf34, action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizenf34ii, -11.80 + 0.05, -47.32, 0, 3);
      _hotload.add(citizenf34ii);
      OPENWORLD.Space.objTurn(citizenf34ii, -90);
      */

      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': 'citizenf34',
        'p': [-11.80 + 0.05, -47.32, 0],
        't': -90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });

      /*
      var vegetabletable2 = vegetabletable.clone();
      _hotload.add(vegetabletable2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          vegetabletable2, -11.80 + 0.03, -47.15 - 0.08, 0, 2);
      OPENWORLD.Space.objTurn(vegetabletable2, 0);
      */

      var amphora16iii = amphora.clone();
      hotloadAdd(firsthotload, false, amphora16iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          amphora16iii, -11.80, -43.31, 0, 2);
      var pot15iiii = pot.clone();
      _hotload.add(pot15iiii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot15iiii, -11.85, -43.48, 0.00, 2);

      // Two soldiers looking at the rabbi
      var soldier22iiii = await OPENWORLD.Actor.copyActor(
          soldier22, randomduration: 0.1, action: "idle");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          soldier22iiii, -11.41, -42.77, 0, 3, lerpopacity: 1);
      _hotload.add(soldier22iiii);
      OPENWORLD.Space.objTurn(soldier22iiii, -90);
      if (OPENWORLD.Math.random()<0.05) {
        var hasinsulted = false;
        OPENWORLD.BaseObject.setDistanceTrigger(
            soldier22iiii, dist: 0.4, event: (action) {
          if (action && !hasinsulted) {
            hasinsulted = true;
            OPENWORLD.Space.faceObjectLerp(soldier22iiii, threeJs.camera, 1.0);
            OPENWORLD.Mob.setSpeech(
              soldier22iiii, ["Argós!"], z: 90,
              // Scatophagē!  Miarós!
              width: 400,
              scale: 0.4,
              randwait: 0,
              delay: 1,
              clearwhendone: true,
            );
          }
        });
      }


      var soldier23iiii = await OPENWORLD.Actor.copyActor(
          soldier23, randomduration: 0.1, action: "idle");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          soldier23iiii, -11.40, -42.6, 0, 3, lerpopacity: 1);
      _hotload.add(soldier23iiii);
      OPENWORLD.Space.objTurn(soldier23iiii, -90);

      var crateempty = cratelentils.clone();
      OPENWORLD.BaseObject.setVisible(crateempty, false, groupname: "left");
      OPENWORLD.BaseObject.setVisible(crateempty, false, groupname: "middle");
      OPENWORLD.BaseObject.setVisible(crateempty, false, groupname: "right");

      var crateempty6 = crateempty.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateempty6, -11.79, -42.56, 0, 2);
      OPENWORLD.Space.objTurn(crateempty6, 90, normalize2world: true);
      _hotload.add(crateempty6);



      var rabbiposx=-11.79;
      var rabbiposy= -42.56;
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(citizen34), //
            //
            'p': [rabbiposx,rabbiposy, 0.02],
            't': 90, //180,
            'action': "armsup", //sittableidle",
            'randomduration': 0.1,
            "lerpopacity": 1,
            "callbackonvisible": (actor) {
              print("rabbi on");
              OPENWORLD.Actor.playActionsLoop(actor,
                  ["wave", "idle", "point", "idle", "hitup", "armsup", "idle"],
                  durations: [2 * 2, 3 * 2, 2 * 2, 2 * 2, 5 * 2, 5 * 2],
                  fadein: 0,
                  fadeout: 2); // fadeout:null);//fadein:0.5); //,*/fadeout:0.7);

              loopspeech(actor, rabbitexts);

            },
            "callbackonhide": (actor) {
              print("rabbi off");
              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
              OPENWORLD.Mob.pauseSpeech(actor);
              OPENWORLD.Mob.clearText(actor);
            }
          });


      var disciples = [
        [-11.73, -42.60],
        [-11.69, -42.56],
        [-11.64, -42.60],
        [-11.63, -42.56]
      ];

      actorlist.shuffle();
      for (var i = 0; i < disciples.length; i++) {
        var actor = actorlist[i % actorlist.length];
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(actor), //
              //  OPENWORLD.Math.randPick(adultlist, exclude:[adultpick])),
              'p': [ disciples[i][0], disciples[i][1], 0],
              't': OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(disciples[i][0], disciples[i][1], 0), THREE.Vector3(rabbiposx,rabbiposy,0)),
              'action': "idle3",
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
      }

      var goat5iii = await OPENWORLD.Actor.copyActor(
          goat, randomduration: 0.1, duration: 6);
      _hotload.add(goat5iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          goat5iii, -12.09, -48.13, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(goat5iii, 0);
      OPENWORLD.BaseObject.setVisible(goat5iii, true, groupname: "collar");
      OPENWORLD.BaseObject.setDistanceTrigger(
          goat5iii, dist: 0.2, event: (action) {
        if (action&&OPENWORLD.Math.random()<animalsoundchance ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/goat.mp3','sounds/goat2.mp3','sounds/goat3.mp3']), volume: 0.5, delay:OPENWORLD.Math.random()*10);
        }
      });


      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizen35),
        'p': [-11.09, -41.66, 0],
        't': -90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var citizen35iii = await OPENWORLD.Actor.copyActor(
          citizen35, action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen35iii, -11.09, -41.66, 0, 3); // -11.83, -46.84,0.0,3);
      _hotload.add(citizen35iii);
      OPENWORLD.Space.objTurn(citizen35iii, -90);
      */

      _hotload.add(cratelentils);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cratelentils, -11.10 + 0.005, -41.71, 0.00, 2);
      OPENWORLD.Space.objTurn(cratelentils, -90 + 10);
      OPENWORLD.Texture.setMipMap(cratelentils, false);

      var cratesalt = cratelentils.clone();
      _hotload.add(cratesalt);
      await OPENWORLD.Model.setTexture(
          cratesalt, "assets/models/crate/salt.jpg", groupname: "left");
      await OPENWORLD.Model.setTexture(
          cratesalt, "assets/models/crate/garlic.jpg", groupname: "middle");
      await OPENWORLD.Model.setTexture(
          cratesalt, "assets/models/crate/cumin.jpg", groupname: "right");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cratesalt, -11.10 + 0.015 + 0.005, -41.71, 0.02, 2);
      OPENWORLD.Texture.setMipMap(cratesalt, false);
      OPENWORLD.Space.objTurn(
          cratesalt, -90 + 10 + 2, normalize2world: true);

      var basketwickerdeepapples2ii = basketwickerdeepapples.clone();
      _hotload.add(basketwickerdeepapples2ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeepapples2ii, -11.12 + 0.02, -41.76, 0, 2);
      var amphora16iiii = amphora.clone();
      hotloadAdd(firsthotload, false, amphora16iiii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          amphora16iiii, -11.08 + 0.025, -41.61, 0, 2);

      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateclothes, -11.11 - 0.02 - 0.02, -40.83 - 0.04, 0.0, 2);
      OPENWORLD.Texture.setMipMap(crateclothes, false);
      OPENWORLD.Space.objTurn(crateclothes, 90 + 18, normalize2world: true);
      _hotload.add(crateclothes);

      var crateclothes2 = crateclothes.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateclothes2, -11.14 - 0.02, -40.92, 0, 2);
      OPENWORLD.Texture.setMipMap(crateclothes2, false);
      OPENWORLD.Space.objTurn(crateclothes2, 90 + 18, normalize2world: true);
      _hotload.add(crateclothes2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizen36),
        'p': [-11.11, -40.78, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var citizen36iii = await OPENWORLD.Actor.copyActor(
          citizen36, action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen36iii, -11.11, -40.78, 0, 3); // -11.83, -46.84,0.0,3);
      _hotload.add(citizen36iii);
      OPENWORLD.Space.objTurn(citizen36iii, 90);
      */

      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateempty, -10.93, -40.07, 0, 2);
      OPENWORLD.Space.objTurn(crateempty, 90 + 18, normalize2world: true);
      _hotload.add(crateempty);

      var basketwickerfigs3 = basketwickerfigs.clone();
      hotloadAdd(firsthotload, false, basketwickerfigs3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerfigs3, -10.93, -40.07, 0.02, 2);

      var crateempty2 = crateempty.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateempty2, -10.93 - 0.02, -40.13, 0, 2);
      OPENWORLD.Space.objTurn(crateempty2, 90 + 18, normalize2world: true);
      _hotload.add(crateempty2);

      var basketwickerfigs4 = basketwickerfigs.clone();
      hotloadAdd(firsthotload, false, basketwickerfigs4);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerfigs4, -10.93 - 0.02, -40.13, 0.02, 2);

      var citizenf32ii = await OPENWORLD.Actor.copyActor(
          citizenf32, action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizenf32ii, -10.95, -40.25, 0, 3);
      _hotload.add(citizenf32ii);
      OPENWORLD.Space.objTurn(citizenf32ii, 90);
      OPENWORLD.BaseObject.setDistanceTrigger(
          citizenf32ii, dist: 0.3, event: (action) {
        if (action) {
          OPENWORLD.Mob.setSpeech(
            citizenf32ii,
            ["Shalom"],
            z: 100,
            width: 300,
            clearwhendone: true,
            minwait: 6,
            scale: 0.4,
            randwait: 0,
          );
          OPENWORLD.Space.faceObjectAlways(citizenf32ii, threeJs.camera);
          // OPENWORLD.Space.faceObjectLerp(citizenf32ii, threeJs.camera, 1.0);
        } else {
          OPENWORLD.Space.removeFaceObjectAlways(citizenf32ii);
        }
      });

      var basketwickerdeepapples2iii = basketwickerdeepapples.clone();
      _hotload.add(basketwickerdeepapples2iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeepapples2iii, -10.92, -40.07 + 0.04, 0, 2);

      var pot16iiii = pot.clone();
      _hotload.add(pot16iiii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot16iiii, -10.45, -39.50, 0.00, 2);
      var sheep2iii = await OPENWORLD.Actor.copyActor(
          sheep2ii, randomduration: 0.1, duration: 6);
      _hotload.add(sheep2iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep2iii, -10.41, -39.33, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(sheep2iii, 0);
      OPENWORLD.BaseObject.setDistanceTrigger(
          sheep2iii, dist: 0.2, event: (action) {
        if (action&&OPENWORLD.Math.random()<animalsoundchance ) {
          OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5, delay:OPENWORLD.Math.random()*10);
        }
      });

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(
            OPENWORLD.Math.randPick(adultlist)),
        'p': [-10.52, -38.34, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var potter = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(adultlist), action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          potter, -10.52, -38.34, 0, 3);
      _hotload.add(potter);
      OPENWORLD.Space.objTurn(potter, 90);
      */

      var shelf2ii = board.clone();
      hotloadAdd(firsthotload, false, shelf2ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shelf2ii, -10.78, -38.31, 0.1, 2);
      shelf2ii.scale.setValues(0.006, 0.003, 0.0015);
      OPENWORLD.Space.objTurn(shelf2ii, 90);

      var mortar4ii = mortar.clone();
      hotloadAdd(firsthotload, false, mortar4ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          mortar4ii, -10.78, -38.31, 0.1, 2);
      var mortar4iii = mortar.clone();
      hotloadAdd(firsthotload, false, mortar4iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          mortar4iii, -10.78, -38.31 + 0.02, 0.1, 2);
      var mortar4iiii = mortar.clone();
      hotloadAdd(firsthotload, false, mortar4iiii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          mortar4iiii, -10.78, -38.31 - 0.02, 0.1, 2);

      var shelf2iii = shelf2ii.clone();
      hotloadAdd(firsthotload, false, shelf2iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shelf2iii, -10.74, -38.21, 0.1, 2);
      var lamp3ii = lamp.clone();
      hotloadAdd(firsthotload, false, lamp3ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          lamp3ii, -10.74, -38.21 + 0.02, 0.1, 2);
      OPENWORLD.Space.objTurn(lamp3ii, 90);
      var lamp3iii = lamp.clone();
      hotloadAdd(firsthotload, false, lamp3iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          lamp3iii, -10.74, -38.21 - 0.02, 0.1, 2);
      OPENWORLD.Space.objTurn(lamp3iii, 90);

      _hotload.add(bowl);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          bowl, -10.43 - 0.02, -38.33 - 0.01, 0.05, 2);

      var bowl2 = bowl.clone();
      hotloadAdd(firsthotload, false, bowl2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          bowl2, -10.43 - 0.02, -38.33 - 0.01 + 0.015, 0.05, 2);

      _hotload.add(boxlimestone);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          boxlimestone, -10.43 - 0.02, -38.33 - 0.025, 0.05, 2);
      OPENWORLD.Space.objTurn(boxlimestone, 18);

      var cup20 = cup.clone();
      hotloadAdd(firsthotload, false, cup20);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cup20, -10.43 - 0.02, -38.33 - 0.04, 0.05, 2);
      cup20.scale.setValues(0.0003, 0.0003, 0.0003);

      var lamp4iii = lamp.clone();
      hotloadAdd(firsthotload, false, lamp4iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          lamp4iii, -10.43 - 0.03, -38.33 - 0.055, 0.05, 2);
      lamp4iii.scale.setValues(0.003, 0.003, 0.003);
      OPENWORLD.Space.objTurn(lamp4iii, 90);

      var mortar5iiii = mortar.clone();
      hotloadAdd(firsthotload, false, mortar5iiii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          mortar5iiii, -10.43 - 0.04, -38.33 - 0.055 - 0.015, 0.05, 2);
      mortar5iiii.scale.setValues(0.004, 0.004, 0.004);

      var goat5ii = await OPENWORLD.Actor.copyActor(
          goat, randomduration: 0.1, duration: 6);
      _hotload.add(goat5ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          goat5ii, -10.14 + 0.02, -38.32, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(goat5ii, 0);
      OPENWORLD.BaseObject.setVisible(goat5ii, true, groupname: "collar");
      OPENWORLD.BaseObject.setDistanceTrigger(
          goat5ii, dist: 0.2, event: (action) {
        if (action&&OPENWORLD.Math.random()<animalsoundchance ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/goat.mp3','sounds/goat2.mp3','sounds/goat3.mp3']), volume: 0.5, delay:OPENWORLD.Math.random()*10);
        }
      });

      var hay14ii = hay.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          hay14ii, -10.16 + 0.08, -38.21, 0.025, 2);
      hotloadAdd(firsthotload, false, hay14ii);
      var manger5ii = manger.clone();
      hotloadAdd(firsthotload, false, manger5ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          manger5ii, -10.16 + 0.08, -38.21, 0.0, 2);
      OPENWORLD.Space.objTurn(manger5ii, 0);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizenf3),
        'p': [-10.18, -37.39, 0],
        't': 180,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var citizenf3ii = await OPENWORLD.Actor.copyActor(
          citizenf3, action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizenf3ii, -10.18, -37.39, 0, 3); // -11.83, -46.84,0.0,3);
      _hotload.add(citizenf3ii);
      OPENWORLD.Space.objTurn(citizenf3ii, 180);
      */

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(childgirl),
        'p': [-10.20, -37.44, 0],
        't': 0,
        'action': 'idle3',
        'randomduration': 0.1,
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var childgirliiii = await OPENWORLD.Actor.copyActor(
          childgirl, randomduration: 0.1, action: 'idle3'); //idle3');
      // actor, randomduration: 0.1, action: i%2==0? 'idle3':'prostrate',startat:OPENWORLD.Math.random());
      _hotload.add(childgirliiii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          childgirliiii, -10.20, -37.44, 0, 3); // -11.83, -46.84,0.0,3);
      OPENWORLD.Space.objTurn(childgirliiii, 0);
      */

      var lyreplayer2 = await OPENWORLD.Actor.copyActor(
          citizen4, action: "work",
          duration: 12,
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          lyreplayer2, -10.1, -37.2, 0, 3);
      _hotload.add(lyreplayer2);
      OPENWORLD.Space.objTurn(lyreplayer2, 90);
      lyreplayer2.add(lyrewield.clone());
      OPENWORLD.BaseObject.setDistanceTrigger(
          lyreplayer2, dist: 0.4, event: (action) {
        if (action ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/harp.mp3','sounds/harp2.mp3','sounds/harp3.mp3']), volume: 0.3);//, delay:OPENWORLD.Math.random()*20);
        }
      });


      var pot22 = pot.clone();
      _hotload.add(pot22);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot22, -9.80, -37.06, 0.00, 2);
      var jug7iii = jug.clone();
      _hotload.add(jug7iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          jug7iii, -9.84, -37.18, 0.00, 2);
      OPENWORLD.Space.objTurn(jug7iii, 180);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(child12),
        'p': [-9.74, -36.94 + 0.03, 0.00],
        't': 180,
        'action': 'idle3',
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var child2iii = await OPENWORLD.Actor.copyActor(
          child12, action: "idle3"); //idle3");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          child2iii, -9.74, -36.94 + 0.03, 0.00, 2);
      ; // centerx+(-17.74-centerx)*0.5,centery+( -45.58-centery)*0.5,0.0,3);//-13.53, 63.52,0,3);//-13.51, 64.25, 0.0, 3); //3.42);
      _hotload.add(child2iii);
      
      OPENWORLD.Space.objTurn(child2iii, 180);
      */

      var sheep2iv = await OPENWORLD.Actor.copyActor(
          sheep2ii, randomduration: 0.1, duration: 6);
      _hotload.add(sheep2iv);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep2iv, -9.80 + 0.02, -37.01, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(sheep2iv, 180);
      OPENWORLD.BaseObject.setDistanceTrigger(
          sheep2iv, dist: 0.2, event: (action) {
        if (action&&OPENWORLD.Math.random()<animalsoundchance ) {
          OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5, delay:OPENWORLD.Math.random()*10);
        }
      });
      var cratelentils3 = cratelentils.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cratelentils3, -9.69, -36.35, 0, 2);
      OPENWORLD.Space.objTurn(cratelentils3, 90 + 18, normalize2world: true);
      _hotload.add(cratelentils3);

      var crateempty3 = crateempty.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateempty3, -9.69 + 0.02, -36.35, 0, 2);
      OPENWORLD.Space.objTurn(crateempty3, 90 + 18, normalize2world: true);
      _hotload.add(crateempty3);

      var cratesalt3 = cratesalt.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cratesalt3, -9.69 + 0.015, -36.35, 0.02, 2);
      OPENWORLD.Space.objTurn(cratesalt3, 90 + 16, normalize2world: true);
      _hotload.add(cratesalt3);

      var cratemint = cratelentils.clone();
      _hotload.add(cratemint);
      OPENWORLD.Model.setTexture(
          cratemint, "assets/models/crate/mint.jpg", groupname: "left");
      OPENWORLD.Model.setTexture(
          cratemint, "assets/models/crate/hyssop.jpg", groupname: "middle");
      OPENWORLD.Model.setTexture(
          cratemint, "assets/models/crate/coriander.jpg", groupname: "right");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cratemint, -9.69 + 0.015 + 0.015, -36.35, 0.04, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(child12),
        'p': [-9.70 + 0.02, -36.40, 0.00],
        't': -90,
        'action': 'idle3',
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var child2iiii = await OPENWORLD.Actor.copyActor(
          child12, action: "idle3"); //idle3");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          child2iiii, -9.70 + 0.02, -36.40, 0.00, 2);
      ; // centerx+(-17.74-centerx)*0.5,centery+( -45.58-centery)*0.5,0.0,3);//-13.53, 63.52,0,3);//-13.51, 64.25, 0.0, 3); //3.42);
      _hotload.add(child2iiii);
      OPENWORLD.Space.objTurn(child2iiii, -90);
      */

      var donkey4iii = await OPENWORLD.Actor.copyActor(donkey4ii);
      _hotload.add(donkey4iii);
      // OPENWORLD.BaseObject.setVisible(
      //     donkey4ii, true, groupname: "horse001_1"); // show rope
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkey4iii, -9.81 + 0.03, -35.55 + 0.06, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(donkey4iii, 180, normalize2world: true);
      OPENWORLD.BaseObject.setDistanceTrigger(
          donkey4iii, dist: 0.2, event: (action) {
        if (action&&OPENWORLD.Math.random()<animalsoundchance ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/donkey.mp3','sounds/donkey2.mp3']), volume: 0.5, delay:OPENWORLD.Math.random()*10);
        }
      });
      var hay14iii = hay.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          hay14iii, -9.82, -35.64 + 0.06, 0.03, 2);
      hotloadAdd(firsthotload, false, hay14iii);
      var manger5iii = manger.clone();
      hotloadAdd(firsthotload, false, manger5iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          manger5iii, -9.82, -35.64 + 0.06, 0.0, 2);
      OPENWORLD.Space.objTurn(manger5ii, 0);

      var basket9iii = basket9ii.clone();
      hotloadAdd(firsthotload, false, basket9iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket9iii, -9.37, -35.03, 0, 2);
      var basket9iv = basket9ii.clone();
      hotloadAdd(firsthotload, false, basket9iv);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket9iv, -9.31, -34.87, 0, 2);
      var sack4 = sack.clone();
      hotloadAdd(firsthotload, false, sack4);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sack4, -9.35, -34.97, 0, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizenf23oldlady),
        'p': [-9.29 - 0.04, -35.01, 0],
        't': -90,
        'action': 'idle3',
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var grandmaii = await OPENWORLD.Actor.copyActor(
          citizenf23oldlady, action: "idle3");
      hotloadAdd(firsthotload, false, grandmaii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          grandmaii, -9.29 - 0.04, -35.01, 0,
          2); //centerx+(-17.27-centerx)*0.5, centery+(-45.26-centery)*0.5,0.0);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
      OPENWORLD.Space.objTurn(grandmaii, -90);
      */

      var shofarplayer = await OPENWORLD.Actor.copyActor(
          citizen42, action: "hornidle",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shofarplayer, -9.48, -34.12, 0, 3);
      _hotload.add(shofarplayer);
      OPENWORLD.Space.objTurn(shofarplayer, 90);
      // OPENWORLD.Space.setTurnPitchRoll(horn.children[0], -90, 0, 0);
      OPENWORLD.Space.setTurnPitchRoll(shofar, -90, 0, 0);
      OPENWORLD.Actor.wield(shofarplayer, shofar, "Bip01_R_Hand");
      OPENWORLD.BaseObject.setDistanceTrigger(
          shofarplayer, dist: 0.4, event: (action) {
        if (action ) {
          OPENWORLD.Sound.play(path:  'sounds/shofar.mp3', volume: 0.3);//, delay:OPENWORLD.Math.random()*20);
        }
      });


      hotloadAdd(firsthotload, false, basketwicker);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwicker, -9.50 + 0.02, -34.19 + 0.02, 0, 2);

      var fluteplayer = await OPENWORLD.Actor.copyActor(
          citizen43, action: "handsmouth",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          fluteplayer, -8.68, -32.28, 0, 3);
      _hotload.add(fluteplayer);
      OPENWORLD.Space.objTurn(fluteplayer, -90);
      flute.position.x = 3.0;
      OPENWORLD.Space.setTurnPitchRoll(flute, -90, 40, 0);
      OPENWORLD.Actor.wield(fluteplayer, flute, "Bip01_R_Hand");
      OPENWORLD.BaseObject.setDistanceTrigger(
          fluteplayer, dist: 0.4, event: (action) {
        if (action ) {
          OPENWORLD.Sound.play(path:  'sounds/flute.mp3', volume: 0.3);//, delay:OPENWORLD.Math.random()*20);
        }
      });

      var basketwicker2 = basketwicker.clone();
      hotloadAdd(firsthotload, false, basketwicker2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwicker2, -8.71 - 0.02, -32.34 + 0.02, 0, 2);

      var lyreplayer = await OPENWORLD.Actor.copyActor(
          citizen4, action: "work",
          duration: 12,
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          lyreplayer, -8.66, -31.21, 0, 3);
      _hotload.add(lyreplayer);
      OPENWORLD.Space.objTurn(lyreplayer, 90);
      lyreplayer.add(lyrewield);
      OPENWORLD.BaseObject.setDistanceTrigger(
          lyreplayer, dist: 0.4, event: (action) {
        if (action ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/harp.mp3','sounds/harp2.mp3','sounds/harp3.mp3']), volume: 0.3);//, delay:OPENWORLD.Math.random()*20);
        }
      });

      // OPENWORLD.Actor.wield(citizen4ii, lyre, "Bip01_Spine3");

      var basketwicker3 = basketwicker.clone();
      hotloadAdd(firsthotload, false, basketwicker3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwicker3, -8.68 + 0.02, -31.30 + 0.04, 0, 2);

      /*
      var table6ii = table.clone();
      hotloadAdd(firsthotload, false, table6ii);
      table6ii.scale.setValues(0.008, 0.008, 0.008);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          table6ii, -9.00 - 0.01, -33.48, 0.0, 2);
      */

      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          tabletri, -9.00 - 0.01, -33.48, 0.0, 2);
      hotloadAdd(firsthotload, false, tabletri);

      hotloadAdd(firsthotload, false, money);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          money, -9.00 - 0.01, -33.48, 0.038, 2);
      OPENWORLD.Space.objTurn(money, -90);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizen2),
        'p': [-8.98, -33.49, 0],
        't': -90,
        'action': 'worklow',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var citizen2ii = await OPENWORLD.Actor.copyActor(
          citizen2, action: "worklow",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen2ii, -8.98, -33.49, 0, 3);
      _hotload.add(citizen2ii);
      OPENWORLD.Space.objTurn(citizen2ii, -90);
      */

      var tabletri2 = tabletri.clone();
      hotloadAdd(firsthotload, false, tabletri2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          tabletri2, -9.10, -32.70 - 0.06, 0.0, 2);
      var basketwicker4 = basketwickerfigs.clone();
      hotloadAdd(firsthotload, false, basketwicker4);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwicker4, -9.10, -32.70 - 0.06, 0.038, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizen22),
        'p': [-9.10 - 0.04, -32.70 - 0.06, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var citizen22iii = await OPENWORLD.Actor.copyActor(
          citizen22, action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen22iii, -9.10 - 0.04, -32.70 - 0.06, 0, 3);
      _hotload.add(citizen22iii);
      OPENWORLD.Space.objTurn(citizen22iii, 90);
      */

      var donkey5iii = await OPENWORLD.Actor.copyActor(donkey4ii);
      _hotload.add(donkey5iii);
      // OPENWORLD.BaseObject.setVisible(
      //     donkey4ii, true, groupname: "horse001_1"); // show rope
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkey5iii, -8.22 + 0.02, -30.67, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(donkey5iii, 180, normalize2world: true);
      OPENWORLD.BaseObject.setDistanceTrigger(
          donkey5iii, dist: 0.2, event: (action) {
        if (action&&OPENWORLD.Math.random()<animalsoundchance ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/donkey.mp3','sounds/donkey2.mp3']), volume: 0.5, delay:OPENWORLD.Math.random()*10);
        }
      });

      var pot23 = pot.clone();
      _hotload.add(pot23);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot23, -8.27, -30.82, 0.00, 2);

      var basketwickerdeepapples8 = basketwickerdeepapples.clone();
      _hotload.add(basketwickerdeepapples8);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeepapples8, -8.29 - 0.04, -30.00 - 0.05, 0, 2);
      var basketwickerdeeppears8 = basketwickerdeeppears.clone();
      _hotload.add(basketwickerdeeppears8);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeeppears8, -8.29 - 0.04, -30.00 - 0.08, 0, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizen23),
        'p': [-8.29 - 0.04, -30.00 - 0.02, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var citizen23iii = await OPENWORLD.Actor.copyActor(
          citizen23, action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen23iii, -8.29 - 0.04, -30.00 - 0.02, 0, 3);
      _hotload.add(citizen23iii);
      OPENWORLD.Space.objTurn(citizen23iii, 90);
      */

      var birdsellers = [
        [-7.83, -29.28, -90 + 18],
        [-6.43, -23.53, -90 + 18 - 180],
        [-7.02, -25.41, -90 + 18 - 180]
      ];
      for (var pos in birdsellers) {
        createDoveSeller(pos[0],pos[1],pos[2]);
      }

      var fluterplayer2 = await OPENWORLD.Actor.copyActor(
          citizen32, action: "handsmouth",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          fluterplayer2, -7.68, -28.88, 0, 3);
      _hotload.add(fluterplayer2);
      OPENWORLD.Space.objTurn(fluterplayer2, -90);
      var flute2 = flute.clone();
      // OPENWORLD.Space.setTurnPitchRoll(horn.children[0], -90, 0, 0);
      OPENWORLD.Actor.wield(fluterplayer2, flute2, "Bip01_R_Hand");
      OPENWORLD.BaseObject.setDistanceTrigger(
          fluterplayer2, dist: 0.4, event: (action) {
        if (action ) {
          OPENWORLD.Sound.play(path:  'sounds/flute.mp3', volume: 0.3);//, delay:OPENWORLD.Math.random()*20);
        }
      });

      var basketwicker5 = basketwicker.clone();
      hotloadAdd(firsthotload, false, basketwicker5);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwicker5, -7.68, -28.88 - 0.02, 0.0, 2);

      var basket10iv = basket9ii.clone();
      hotloadAdd(firsthotload, false, basket10iv);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket10iv, -7.88 - 0.04, -28.62 - 0.04, 0, 2);
      var basket12iv = basket9ii.clone();
      hotloadAdd(firsthotload, false, basket12iv);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket12iv, -7.88, -28.62 + 0.08, 0, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(
            OPENWORLD.Math.randPick(adultlist)),
        'p': [-7.88, -28.62 + 0.04, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var seller2 = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(adultlist), action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          seller2, -7.88, -28.62 + 0.04, 0, 3);
      _hotload.add(seller2);
      OPENWORLD.Space.objTurn(seller2, 90);
      */

      var amphora17 = amphora.clone();
      hotloadAdd(firsthotload, false, amphora17);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          amphora17, -7.92 - 0.02, -28.73 + 0.01, 0.0, 2);

      _hotload.add(breadleavened);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          breadleavened, -7.74, -28.00, 0.05, 2);
      OPENWORLD.Space.objTurn(breadleavened, 0);
      var breadleavened2 = breadleavened.clone();
      _hotload.add(breadleavened2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          breadleavened2, -7.74, -28.00 + 0.02, 0.05, 2);
      var breadleavened3 = breadleavened.clone();
      _hotload.add(breadleavened3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          breadleavened3, -7.74 - 0.01, -28.03 + 0.02, 0.05, 2);

      for (var j = 0; j < 2; j++) {
        for (var i = 0; i < 4; i++) {
          bread = breadunleaven.clone();
          bread.scale.setValues(0.2, 0.3, 0.2);
          _hotload.add(bread);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              bread,
              -7.74 + 0.01,
              -28.00 + 0.04 + j * 0.02,
              0.05 + i * 0.001,
              1);
          OPENWORLD.Space.objTurn(bread, OPENWORLD.Math.randFloatSpread(100));
        }
      }

      var breadleavened4 = breadleavened.clone();
      _hotload.add(breadleavened4);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          breadleavened4,
          -7.74 + 0.01,
          -28.00 + 0.04 + 0.02 + 0.02,
          0.05,
          2);

      var sack7 = sack.clone();
      hotloadAdd(firsthotload, false, sack7);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sack7, -8.04, -27.94, 0, 2);
      var sack8 = sack.clone();
      hotloadAdd(firsthotload, false, sack8);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sack8, -8.01, -27.90, 0, 2);
      var sack9 = sack.clone();
      hotloadAdd(firsthotload, false, sack9);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sack9, -7.85, -27.84, 0, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(
            OPENWORLD.Math.randPick(adultlist)),
        'p': [-7.80, -27.93, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          var hasseen = 0;
          OPENWORLD.BaseObject.setDistanceTrigger(
             actor, dist: 0.2, event: (action) {
            if (action && hasseen<2) {
              OPENWORLD.Space.faceObjectLerp(actor, threeJs.camera, 1.0);
              OPENWORLD.Mob.setSpeech(actor,
                  hasseen == 1 ? ["The best bread",
                    "in all Jerusalem.",
                    "I'll give you a special price"] : [
                    'I knew you couldnt resist'
                  ], z: 100,
                  width: 300,
                  clearwhendone: true,
                  minwait: 4,
                  scale: 0.4,
                  randwait: 0,
                  //   delay:9
                  callbackonfinish: (actor) {
                    //OPENWORLD.Space.removeFaceObjectAlways(actor);
                    //  OPENWORLD.Space.objTurnLerp(oldfriend, 120, 1.0);
                  }
              );
              hasseen++;
            }
            });
        },
        "callbackonhide":(actor) {
          OPENWORLD.BaseObject.removeDistanceTrigger(actor);
          OPENWORLD.Mob.pauseChatter(actor);
          OPENWORLD.Mob.pauseSpeech(actor);
          OPENWORLD.Mob.clearText(actor);

        }
      });
      /*
      var baker = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(adultlist), action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          baker, -7.80, -27.93, 0, 3);
      _hotload.add(baker);
      OPENWORLD.Space.objTurn(baker, 90);
      */

      var oven3ii = tannur.clone();
      hotloadAdd(firsthotload, false, oven3ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          oven3ii, -7.99, -27.84, 0, 1);
      OPENWORLD.Space.objTurn(oven3ii, 90);
      oven3ii.scale.setValues(0.05, 0.05, 0.05);

      var housefire3 = new VolumetricFire(
          Glob.fireWidth,
          Glob.fireHeight,
          Glob.fireDepth,
          Glob.sliceSpacing,
          threeJs.camera);
      await housefire3.init();

      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          housefire3.mesh, -7.99, -27.84, 0.02, 1);
      housefire3.mesh.scale.x = 0.01;
      housefire3.mesh.scale.y = 0.01;
      housefire3.mesh.scale.z = 0.01;
      hotloadAdd(firsthotload, false, housefire3.mesh);
      OPENWORLD.Updateables.add(housefire3);

      var basket11iii = basket9ii.clone();
      hotloadAdd(firsthotload, false, basket11iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket11iii, -7.54 - 0.06, -27.73 - 0.06 - 0.02, 0, 2);
      var basket12iii = basket9ii.clone();
      hotloadAdd(firsthotload, false, basket12iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket12iii, -7.54 - 0.06, -27.73 + 0.06 - 0.02, 0, 2);
      var pot18iii = pot.clone();
      _hotload.add(pot18iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot18iii, -7.54 - 0.09, -27.73 - 0.06 - 0.08, 0.00, 2);
      OPENWORLD.Space.objTurn(pot18iii, 180);

      var jug9ii = jug.clone();
      _hotload.add(jug9ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          jug9ii, -7.34 - 0.04, -27.06 - 0.06, 0.00, 2);
      OPENWORLD.Space.objTurn(jug9ii, 180);
      var pot18ii = pot.clone();
      _hotload.add(pot18ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot18ii, -7.34 - 0.04, -27.06 + 0.06, 0.00, 2);
      OPENWORLD.Space.objTurn(pot18ii, 180);
      var amphora18iii = amphora.clone();
      hotloadAdd(firsthotload, false, amphora18iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          amphora18iii, -7.34 - 0.08, -27.06 - 0.08, 0.0, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(
            OPENWORLD.Math.randPick(adultlist)),
        'p': [-7.42, -27.16, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var seller3 = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(adultlist), action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          seller3, -7.42, -27.16, 0, 3);
      _hotload.add(seller3);
      OPENWORLD.Space.objTurn(seller3, 90);
      */

      var crateempty5 = crateempty.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateempty5, -7.48, -26.68 + 0.02, 0, 2);
      OPENWORLD.Space.objTurn(crateempty5, 90, normalize2world: true);
      _hotload.add(crateempty5);

      rabbiposx=-7.48;
      rabbiposy=  -26.68 + 0.02;
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(citizen33), //
            //
            'p': [rabbiposx,rabbiposy, 0.02],
            't': 90, //180,
            'action': "armsup", //sittableidle",
            'randomduration': 0.1,
            "lerpopacity": 1,
            "callbackonvisible": (actor) {
              print("rabbi on");
              OPENWORLD.Actor.playActionsLoop(actor,
                  ["wave", "idle", "point", "idle", "hitup", "armsup", "idle"],
                  durations: [2 * 2, 3 * 2, 2 * 2, 2 * 2, 5 * 2, 5 * 2],
                  fadein: 0,
                  fadeout: 2); // fadeout:null);//fadein:0.5); //,*/fadeout:0.7);

              loopspeech(actor, rabbitexts);

            },
            "callbackonhide": (actor) {
              print("rabbi off");
              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
              OPENWORLD.Mob.pauseSpeech(actor);
              OPENWORLD.Mob.clearText(actor);
            }
          });


      disciples = [
        [-7.41, -26.71],
        [-7.39, -26.66],
        [-7.34, -26.69],
        [-7.34, -26.64],
        [-7.41, -26.61],
        [-7.23 - 0.04, -26.71]
      ];

      actorlist.shuffle();
      for (var i = 0; i < disciples.length; i++) {
        var actor = actorlist[i % actorlist.length];
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(actor), //
              //  OPENWORLD.Math.randPick(adultlist, exclude:[adultpick])),
              'p': [ disciples[i][0], disciples[i][1], 0],
              't': OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(disciples[i][0], disciples[i][1], 0), THREE.Vector3(rabbiposx,rabbiposy,0)),
              'action': "idle3",
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
      }

   /*   var rabbi = await OPENWORLD.Actor.copyActor(
          citizen33, action: "armsup",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Mob.setName(rabbi, "rabbi");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          rabbi, -7.48, -26.68 + 0.02, 0.02, 1);
      _hotload.add(rabbi);
      OPENWORLD.Space.objTurn(rabbi, 90);
      OPENWORLD.BaseObject.setDistanceTrigger(
          rabbi, dist: 1, event: (action) {
        if (action) {
          OPENWORLD.Actor.playActionsLoop(
              rabbi,
              ["wave", "idle", "point", "idle", "hitup", "armsup", "idle"],
              durations: [2, 3, 2, 2, 5, 5]);
          loopspeech(rabbi, rabbitexts);
        } else {}
      });

      disciples = [
        [-7.41, -26.71],
        [-7.39, -26.66],
        [-7.34, -26.69],
        [-7.34, -26.64],
        [-7.41, -26.61],
        [-7.23 - 0.04, -26.71]
      ];
      actorlist.shuffle();
      for (var i = 0; i < disciples.length; i++) {
        var disciple = await OPENWORLD.Actor.copyActor(
            actorlist[i % actorlist.length], action: "idle3",
            randomduration: 0.1,
            startat: OPENWORLD.Math.random());
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            disciple, disciples[i][0], disciples[i][1], 0, 2);
        _hotload.add(disciple);
        OPENWORLD.Space.faceObject(disciple, rabbi);
      }*/

      var crateempty6ii = crateempty.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateempty6ii, -7.12 - 0.04, -26.01 - 0.04, 0, 2);
      OPENWORLD.Space.objTurn(crateempty6ii, 90 + 18, normalize2world: true);
      _hotload.add(crateempty6ii);

      var basketwickerfigs4ii = basketwickerfigs.clone();
      hotloadAdd(firsthotload, false, basketwickerfigs4ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerfigs4ii, -7.12 - 0.02, -26.01 - 0.04, 0.02, 2);

      var crateempty6iii = crateempty.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateempty6iii, -7.12 - 0.04, -26.01 - 0.04 - 0.08, 0, 2);
      OPENWORLD.Space.objTurn(crateempty6iii, 90 + 18, normalize2world: true);
      _hotload.add(crateempty6iii);
      var basketwickerolives4iii = basketwickerolives.clone();
      hotloadAdd(firsthotload, false, basketwickerolives4iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerolives4iii, -7.12 - 0.04, -26.01 - 0.04 - 0.08, 0.02, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(
            OPENWORLD.Math.randPick(adultlist)),
        'p': [-7.12 - 0.02, -26.01 - 0.04 - 0.04, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var seller5 = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(adultlist), action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          seller5, -7.12 - 0.02, -26.01 - 0.04 - 0.04, 0, 3);
      _hotload.add(seller5);
      OPENWORLD.Space.objTurn(seller5, 90);
      */


      var herbposs = [
        [-6.59, -25.15, -90 + 18],
        [-7.27, -27.54, -90 + 18],
        [-9.27 + 0.06, -34.60 - 0.01, -90 + 18],
    //    [-9.59 - 0.03 - 0.04, -50.64 + 0.05, 180],  // siloam
     //   [-10.11, -50.86, 0]   // siloam
      ];
      // var herbturn = 180; // -90+18;
      for (var pos in herbposs) {
        createHerbSeller(pos[0], pos[1],pos[2]);
      }

      var tabletri4 = tabletri.clone();
      hotloadAdd(firsthotload, false, tabletri4);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          tabletri4, -6.59 - 0.04, -24.30, 0.0, 2);
      var basketwickerfigs6 = basketwickerfigs.clone();
      hotloadAdd(firsthotload, false, basketwickerfigs6);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerfigs6, -6.59 - 0.04, -24.30, 0.038, 2);
      var basketwickerdeeppears9ii = basketwickerdeeppears.clone();
      _hotload.add(basketwickerdeeppears9ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeeppears9ii, -6.59 - 0.04 - 0.03 - 0.03, -24.30, 0, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(
            OPENWORLD.Math.randPick(adultlist)),
        'p': [-6.59 - 0.04 - 0.03, -24.30, 0],
        't': 90,
        'action': 'worklow',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var figseller = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(adultlist), action: "worklow",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          figseller, -6.59 - 0.04 - 0.03, -24.30, 0, 3);
      _hotload.add(figseller);
      OPENWORLD.Space.objTurn(figseller, 90);
      */

      var matrolled7 = matrolled.clone();
      hotloadAdd(firsthotload, false, matrolled7);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          matrolled7, -6.67, -24.25, 0, 2);

      var basket10iii = basket9ii.clone();
      hotloadAdd(firsthotload, false, basket10iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket10iii, -5.94, -23.01, 0, 2);
      var basket11iv = basket9ii.clone();
      hotloadAdd(firsthotload, false, basket11iv);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket11iv, -5.97, -23.11, 0, 2);
      var sack5 = sack.clone();
      hotloadAdd(firsthotload, false, sack5);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sack5, -5.97 + 0.02, -23.11 + 0.03, 0, 2);

      
      // Retain the source actor for citizenran2's exclusion list.
      var citizenranSource = OPENWORLD.Math.randPick(actorlist);
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(citizenranSource),
        'p': [-5.97, -23.08, 0],
        't': 0,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var citizenran = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(actorlist), action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizenran, -5.97, -23.08, 0, 3);
      _hotload.add(citizenran);
      OPENWORLD.Space.objTurn(citizenran, 0);
      */

      var citizenran2 = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(actorlist, exclude: [citizenranSource]),
          action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizenran2, -5.97, -23.03, 0, 3);
      _hotload.add(citizenran2);
      OPENWORLD.Space.objTurn(citizenran2, 180);

      var tabletri3 = tabletri.clone();
      hotloadAdd(firsthotload, false, tabletri3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          tabletri3, -6.11 + 0.01, -22.39 + 0.05, 0.0, 2);
      var money2 = money.clone();
      hotloadAdd(firsthotload, false, money2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          money2, -6.11 + 0.01, -22.39 + 0.05, 0.038, 2);
      OPENWORLD.Space.objTurn(money2, 90);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(
            OPENWORLD.Math.randPick(manlist)),
        'p': [-6.11 - 0.04, -22.39 + 0.07, 0],
        't': 90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var moneychanger = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(manlist), action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          moneychanger, -6.11 - 0.04, -22.39 + 0.07, 0, 3);
      _hotload.add(moneychanger);
      OPENWORLD.Space.objTurn(moneychanger, 90);
      */

      var crateclothes3 = crateclothes.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateclothes3, -6.10 - 0.03, -22.23 - 0.04, 0.0, 2);
      OPENWORLD.Space.objTurn(crateclothes3, 90 + 18, normalize2world: true);
      _hotload.add(crateclothes3);

      var basketwickerdeepapples9 = basketwickerdeepapples.clone();
      _hotload.add(basketwickerdeepapples9);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeepapples9, -5.76 - 0.02, -21.98 + 0.01, 0, 2);
      var basketwickerdeeppears9 = basketwickerdeeppears.clone();
      _hotload.add(basketwickerdeeppears9);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeeppears9, -5.76 - 0.02, -21.98 - 0.02, 0, 2);

      
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add({
        'name': OPENWORLD.Config.getObjectName(
            OPENWORLD.Math.randPick(manlist)),
        'p': [-5.76 + 0.04, -21.98, 0],
        't': -90,
        'action': 'idle3',
        'randomduration': 0.1,
        'startat': OPENWORLD.Math.random(),
        'lerpopacity': 1,
        "callbackonvisible":(actor) {
          OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
        },
        "callbackonhide":(actor) {
          OPENWORLD.Actor.disableDistanceThrottle(actor);
        }
      });
      /*
      var sellerfruit = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(manlist), action: "idle3",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      // var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sellerfruit, -5.76 + 0.04, -21.98, 0, 3);
      _hotload.add(sellerfruit);
      OPENWORLD.Space.objTurn(sellerfruit, -90);
      */

      var musicianlyre = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(manlist), action: "work",
          duration: 12,
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          musicianlyre, -6.11, -21.57, 0, 3);
      _hotload.add(musicianlyre);
      OPENWORLD.Space.objTurn(musicianlyre, 90);
      musicianlyre.add(lyrewield.clone());
      OPENWORLD.BaseObject.setDistanceTrigger(
          musicianlyre, dist: 0.4, event: (action) {
        if (action ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/harp.mp3','sounds/harp2.mp3','sounds/harp3.mp3']), volume: 0.3);//, delay:OPENWORLD.Math.random()*20);
        }
      });

      var basketwicker8 = basketwicker.clone();
      hotloadAdd(firsthotload, false, basketwicker8);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwicker8, -6.11, -21.57 + 0.03, 0, 2);

      var musician = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(manlist), action: "hornidle",
          randomduration: 0.1,
          startat: OPENWORLD.Math.random());
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          musician, -5.75, -21.15, 0, 3);
      _hotload.add(musician);
      OPENWORLD.Space.objTurn(musician, -90);
      OPENWORLD.Actor.wield(musician, shofar.clone(), "Bip01_R_Hand");
      OPENWORLD.BaseObject.setDistanceTrigger(
          musician, dist: 0.4, event: (action) {
        if (action ) {
          OPENWORLD.Sound.play(path:  'sounds/shofar.mp3', volume: 0.3);//, delay:OPENWORLD.Math.random()*20);
        }
      });
      var basketwicker7 = basketwicker.clone();
      hotloadAdd(firsthotload, false, basketwicker7);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwicker7, -5.75, -21.15 - 0.02, 0, 2);

      var crateempty7 = crateempty.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          crateempty7, -5.65, -20.56, 0, 2);
      OPENWORLD.Space.objTurn(crateempty7, -90, normalize2world: true);
      _hotload.add(crateempty7);

      rabbiposx=-5.65;
      rabbiposy=  -20.56;
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(citizen42), //
            //
            'p': [rabbiposx,rabbiposy, 0.02],
            't': -90, //180,
            'action': "armsup", //sittableidle",
            'randomduration': 0.1,
            "lerpopacity": 1,
            "callbackonvisible": (actor) {
              print("rabbi on");
              OPENWORLD.Actor.playActionsLoop(actor,
                  ["wave", "idle", "point", "idle", "hitup", "armsup", "idle"],
                  durations: [2 * 2, 3 * 2, 2 * 2, 2 * 2, 5 * 2, 5 * 2],
                  fadein: 0,
                  fadeout: 2); // fadeout:null);//fadein:0.5); //,*/fadeout:0.7);

              loopspeech(actor, rabbitexts);

            },
            "callbackonhide": (actor) {
              print("rabbi off");
              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
              OPENWORLD.Mob.pauseSpeech(actor);
              OPENWORLD.Mob.clearText(actor);
            }
          });

      disciples = [
        [-5.78, -20.55],
        [-5.79 + 0.02, -20.61 + 0.02]
      ];

      actorlist.shuffle();
      for (var i = 0; i < disciples.length; i++) {
        var actor = actorlist[i % actorlist.length];
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(actor), //
              //  OPENWORLD.Math.randPick(adultlist, exclude:[adultpick])),
              'p': [ disciples[i][0], disciples[i][1], 0],
              't': OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(disciples[i][0], disciples[i][1], 0), THREE.Vector3(rabbiposx,rabbiposy,0)),
              'action': "idle3",
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
      }

      var donkey6iii = await OPENWORLD.Actor.copyActor(donkey4ii);
      _hotload.add(donkey6iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkey6iii, -6.09, -20.87, 0.0, 3,
          lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(donkey6iii, 180, normalize2world: true);
      OPENWORLD.BaseObject.setDistanceTrigger(
          donkey6iii, dist: 0.2, event: (action) {
        if (action&&OPENWORLD.Math.random()<animalsoundchance ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/donkey.mp3','sounds/donkey2.mp3']), volume: 0.5, delay:OPENWORLD.Math.random()*10);
        }
      });
      var hay15iii = hay.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          hay15iii, -6.11, -20.76, 0.025, 2);
      hotloadAdd(firsthotload, false, hay15iii);
      var manger6iii = manger.clone();
      hotloadAdd(firsthotload, false, manger6iii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          manger6iii, -6.11, -20.76, 0.0, 2);
      OPENWORLD.Space.objTurn(manger6iii, 0);


      var crateposs = [
        [-6.08 - 0.01 - 0.02, -20.59 - 0.03 - 0.02, 90, cratemint], // -18],
        // [-6.08 - 0.01, -20.59 - 0.03, 90, cratemint], // -18],
        [-6.30, -20.42 - 0.01, 180, cratelentils], // 286-90]
        [-6.25, -20.5 - 0.08, 0, cratemint]
      ];
      for (var pos in crateposs) {
        var crateposx = pos[0]; // -6.08 - 0.01;
        var crateposy = pos[1]; // -20.59 - 0.03; // +0.03;
        var crateangle = pos[2];
        var group = THREE.Group();

        var cratelentils4 = cratelentils.clone();
        group.add(cratelentils4);
        cratelentils4.visible = true;
        OPENWORLD.Space.resetPosRot(cratelentils4);
        // cratelentils4.rotation.zero();
        // cratelentils4.position.zero();


        var crateempty9 = crateempty.clone();
        OPENWORLD.Space.resetPosRot(crateempty9);
        group.add(crateempty9);
        crateempty9.visible = true;
        // crateempty9.updateMatrixWorld(true);
        crateempty9.position.z = -0.02;
        // OPENWORLD.Space.worldToLocalSurfaceObjHide(
        //     crateempty9, crateposx - 0.02, crateposy, 0, 2);
        // OPENWORLD.Space.objTurn(crateempty9, crateangle,
        //     normalize2world: true);
        // _hotload.add(crateempty9);

        var cratesalt4 = cratesalt.clone();
        cratesalt4.visible = true;
        OPENWORLD.Space.resetPosRot(cratesalt4);
        group.add(cratesalt4);
        cratesalt4.position.z = -0.015;
        cratesalt4.position.y = 0.02;


        var cratemint2 = pos[3].clone();
        OPENWORLD.Space.resetPosRot(cratemint2);
        group.add(cratemint2);
        cratemint2.position.z = -0.015 - 0.015;
        cratemint2.position.y = 0.04;
        cratemint2.visible = true;
        _hotload.add(group);
        // group.updateMatrixWorld(true);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            group, crateposx, crateposy, 0, 2);
        OPENWORLD.Space.objTurn(group, crateangle);

      }

      // back of shop
      var doorhouse2shop = doorhouse2.clone();
      hotloadAdd(firsthotload, false, doorhouse2shop);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          doorhouse2shop, -6.53 + 0.02, -20.55 - 0.01, 0.00, 2);
      // OPENWORLD.Space.worldToLocalSurfaceObjHide(
      //     doorhouse2, -17.23, -45.217, 0.08, 2);
      OPENWORLD.Space.objTurn(doorhouse2shop, 0);
      OPENWORLD.BaseObject.setDistanceTrigger(
          doorhouse2shop, dist: 0.1, event: (action) {
        if (action) {
          // Open the door as get close
          OPENWORLD.Space.objTurnLerp(doorhouse2shop, -90, 1);
        } else {
          // Close door when leave
          OPENWORLD.Space.objTurnLerp(doorhouse2shop, 0, 1);
        }
      });


      if (gamestart != GameStart.lowercity) {
        // Show the seller only if its not the lowercity game
        Glob.fruitseller = await OPENWORLD.Actor.copyActor(
            womanlist[1], action: "work");
        _hotload.add(Glob.fruitseller);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            Glob.fruitseller, -6.29+0.07, -20.47, -0.01, 2);
        OPENWORLD.Space.objTurn(Glob.fruitseller, 90);
        OPENWORLD.BaseObject.setDistanceTrigger(
            Glob.fruitseller, dist: 2, event: (action) {
          if (action) {
            // Should always be done in a distance trigger
            OPENWORLD.Actor.playActionsLoop(Glob.fruitseller, ["work", "idle3"]);
            OPENWORLD.Mob.setChatter(
                Glob.fruitseller, ["Can I get you anything?","We have the best figs in Jersualem","Try our dates"],
                z: 80,
                scale:0.2,
                width: 300);
          } else {}
        });

      }
      // Stop walking into the shop
      OPENWORLD.Obstacles.createObstacle(-6.17,-20.49,0.1,0.1,callbacknextwait: 1);//,marker:_hotload);

      var basketwickerdeepapples2 = basketwickerdeepapples.clone();
      _hotload.add(basketwickerdeepapples2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeepapples2, -6.49, -20.46, 0.00, 2);
      var basketwickerdeeppears3 = basketwickerdeeppears.clone();
      _hotload.add(basketwickerdeeppears3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeeppears3, -6.48, -20.53 + 0.03, 0.00, 2);
      var basketwickerdeepapples4 = basketwickerdeeppears.clone();
      _hotload.add(basketwickerdeepapples4);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeepapples4, -6.35, -20.54, 0.00, 2);
      var basketwickerdeepapples5 = basketwickerdeepapples.clone();
      _hotload.add(basketwickerdeepapples5);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeepapples5, -6.32, -20.59, 0.00, 2);
      var basketwickerdeepapples6 = basketwickerdeepapples.clone();
      _hotload.add(basketwickerdeepapples6);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeepapples6, -6.17, -20.58, 0.00, 2);

      var shelf = board.clone();
      hotloadAdd(firsthotload, false, shelf);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shelf, -6.49, -20.46, 0.1, 2);
      shelf.scale.setValues(0.003, 0.003, 0.0015);
      OPENWORLD.Space.objTurn(shelf, 90);
      var mortar3 = mortar.clone();
      hotloadAdd(firsthotload, false, mortar3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          mortar3, -6.49, -20.46, 0.1, 2);

      var shelf2 = shelf.clone();
      hotloadAdd(firsthotload, false, shelf2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shelf2, -6.48, -20.53 - 0.04, 0.1, 2);
      var lamp3 = lamp.clone();
      hotloadAdd(firsthotload, false, lamp3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          lamp3, -6.48, -20.53 - 0.04, 0.1, 2);
      OPENWORLD.Space.objTurn(lamp3, 90);
      var amphora16 = amphora.clone();
      hotloadAdd(firsthotload, false, amphora16);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          amphora16, -6.49, -20.43, 0.0, 2);
      var basket9 = basket.clone();
      hotloadAdd(firsthotload, false, basket9);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket9, -6.46, -20.57, 0, 2);

      var basket10 = basket.clone();
      hotloadAdd(firsthotload, false, basket10);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basket10, -6.39, -20.43, 0, 2);
      basket10.scale.setValues(0.002, 0.002, 0.002);

      var benchheight = 0.047;
      _hotload.add(scales);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          scales, -6.18 - 0.02, -20.44 - 0.06, benchheight, 2);
      OPENWORLD.Space.objTurn(scales, 90);

      var weights = await OPENWORLD.Model.createModel(
          'assets/models/weights.glb');
      weights.scale.setValues(0.003, 0.003, 0.003);
      _hotload.add(weights);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          weights, -6.18 - 0.02, -20.44 - 0.1, benchheight, 2);
      var weights2 = weights.clone();
      weights2.scale.setValues(0.002, 0.002, 0.002);
      _hotload.add(weights2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          weights2, -6.18 - 0.02, -20.44 - 0.1, 0.053, 2);

      var cup16 = cup.clone();
      hotloadAdd(firsthotload, false, cup16);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cup16, -6.17, -20.56, benchheight, 2);
      cup16.scale.setValues(0.0004, 0.0004, 0.0004);

      var basketwickerfigs5 = basketwickerfigs.clone();
      hotloadAdd(firsthotload, false, basketwickerfigs5);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerfigs5, -6.17, -20.56 + 0.015, 0.05, 2);

      var herbsmint4 = herbsmint.clone();
      OPENWORLD.Space.objTurn(herbsmint4, 0);
      hotloadAdd(firsthotload, false, herbsmint4);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          herbsmint4, -6.17, -20.56 + 0.03, benchheight, 2);

      hotloadAdd(firsthotload, false, basketwickerolives);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerolives, -6.17, -20.56 + 0.05, benchheight, 2);
      hotloadAdd(firsthotload, false, basketwickerolivesblack);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerolivesblack, -6.17, -20.56 + 0.13, benchheight, 2);
      var herbshyssop4 = herbshyssop.clone();
      OPENWORLD.Space.objTurn(herbshyssop4, 0);
      hotloadAdd(firsthotload, false, herbshyssop4);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          herbshyssop4, -6.17, -20.56 + 0.08, benchheight, 2);
      var herbshyssop5 = herbshyssop.clone();
      OPENWORLD.Space.objTurn(herbshyssop5, 0);
      hotloadAdd(firsthotload, false, herbshyssop5);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          herbshyssop5, -6.17, -20.56 + 0.09, benchheight, 2);
      var onions2 = onions.clone();
      OPENWORLD.Space.objTurn(onions2, 0);
      hotloadAdd(firsthotload, false, onions2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          onions2, -6.17, -20.56 + 0.08 + 0.02, benchheight, 2);
      var onions3 = onions.clone();
      OPENWORLD.Space.objTurn(onions3, 0);
      hotloadAdd(firsthotload, false, onions3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          onions3, -6.17, -20.56 + 0.08 + 0.03, benchheight, 2);


      // This is all the pilgrims standing along the pilgrims road
      var diff=0.05;  // Small so less chance will be two over the top of eachother
      var pointsessen=OPENWORLD.Math.interpolateByIncrement(citizenessenpath,diff);
      var pointspilgrim=[];
      for (var point in pointsessen)
        if (point[1]>-48.96&&point[1]<-14.52) {
          pointspilgrim.add(point);
        }
      var density=2.0;  // 2 groups per 1 unit of length
      var numpilgrims=(-14.52-(-48.96))*density;

//      var points=closestPersonAngle(OPENWORLD.Math.interpolateByIncrement(siloampath,diff));
      for (var i=0; i<numpilgrims; i++) {
        var point=OPENWORLD.Math.randPick(pointspilgrim).toList();
        // So not standing in middle of road
        if (OPENWORLD.Math.random()<0.5)
          point[0]-=0.1;
        else
          point[0]+=0.1;

        var point2=OPENWORLD.Math.vectorMoveForward(point[0], point[1], OPENWORLD.Math.random()*360, 0.04);
        var turn=OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(point[0],point[1],0),THREE.Vector3(point2[0],point2[1],0));
        //print("point pilgrim"+point.toString());
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(actorlist)),
              'p': [point[0], point[1]],
//              'p': [point[0]+OPENWORLD.Math.randFloatSpread(0.3), point[1]+OPENWORLD.Math.randFloatSpread(0.3)],
              // 'l': 1,
              't': turn,//point[2], // OPENWORLD.Math.random() * 360, //270,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'idle3',
              'randomduration': 0.1,
              "callbackonvisible": (actor) {
                  setcancollide(actor,true);
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
              },
              "callbackonhide": (actor) {
                setcancollide(actor,false);
                OPENWORLD.Actor.disableDistanceThrottle(actor);
              },
            'startat': OPENWORLD.Math.random(),
              //  'label': 'courtwomen',
              "lerpopacity": 1
            });
        if (OPENWORLD.Math.random()<0.6)  // So not every person is with a companion
          OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(actorlist)),
              'p': [point2[0], point2[1]],
              // 'l': 1,
              't': turn-180,//point[2], // OPENWORLD.Math.random() * 360, //270,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'idle3',
              'randomduration': 0.1,
              "callbackonvisible": (actor) {
                setcancollide(actor,true);
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
              },
              "callbackonhide": (actor) {
                setcancollide(actor,false);
                OPENWORLD.Actor.disableDistanceThrottle(actor);
              },
              'startat': OPENWORLD.Math.random(),
              //  'label': 'courtwomen',
              "lerpopacity": 1
            });
      }

    }

    if (!shopawninginstance) {
      _hotload.add(shopawning);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning, -11.15 + 0.12, -41.67, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning, -90);
    } else {
      instancedShopawnings.place(-90, -11.15 + 0.12, -41.67, 0.0);
    }

    if (!shopawninginstance) {
      var shopawning2 = shopawning.clone();
      _hotload.add(shopawning2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning2, -11.11 - 0.04, -40.83, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning2, 90);
    } else {
      instancedShopawnings.place(90, -11.11 - 0.04, -40.83, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning3 = shopawning.clone();
      _hotload.add(shopawning3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning3, -10.94 - 0.05, -40.17, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning3, 90);
    } else {
      instancedShopawnings.place(90, -10.94 - 0.05, -40.17, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning4 = shopawning.clone();
      _hotload.add(shopawning4);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning4, -10.43 + 0.04, -39.40, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning4, -90);
    } else {
      instancedShopawnings.place(-90, -10.43 + 0.04, -39.40, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning23 = shopawning.clone();
      _hotload.add(shopawning23);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning23, -10.37 - 0.06, -38.40 + 0.02, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning23, 90);
    } else {
      instancedShopawnings.place(90, -10.37 - 0.06, -38.40 + 0.02, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning5 = shopawning.clone();
      _hotload.add(shopawning5);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning5, -10.08 + 0.04, -38.28, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning5, -90);
    } else {
      instancedShopawnings.place(-90, -10.08 + 0.04, -38.28, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning6 = shopawning.clone();
      _hotload.add(shopawning6);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning6, -10.17 - 0.04, -37.37, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning6, 90);
    } else {
      instancedShopawnings.place(90, -10.17 - 0.04, -37.37, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning7 = shopawning.clone();
      _hotload.add(shopawning7);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning7, -9.66 + 0.04, -36.28, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning7, -90);
    } else {
      instancedShopawnings.place(90, -9.66 + 0.04, -36.28, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning8 = shopawning.clone();
      _hotload.add(shopawning8);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning8, -9.35 + 0.05, -34.91, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning8, -90);
    } else {
      instancedShopawnings.place(-90, -9.35 + 0.05, -34.91, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning9 = shopawning.clone();
      _hotload.add(shopawning9);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning9, -9.02 + 0.04, -33.54, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning9, -90);
    } else {
      instancedShopawnings.place(-90, -9.02 + 0.04, -33.54, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning10 = shopawning.clone();
      _hotload.add(shopawning10);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning10, -9.10 - 0.04, -32.70, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning10, 90);
    } else {
      instancedShopawnings.place(90, -9.10 - 0.04, -32.70, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning11 = shopawning.clone();
      _hotload.add(shopawning11);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning11, -8.25 + 0.04, -30.76, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning11, -90);
    } else {
      instancedShopawnings.place(-90, -8.25 + 0.04, -30.76, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning12 = shopawning.clone();
      _hotload.add(shopawning12);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning12, -8.29 - 0.04, -30.00, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning12, 90);
    } else {
      instancedShopawnings.place(90, -8.29 - 0.04, -30.00, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning24 = shopawning.clone();
      _hotload.add(shopawning24);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning24, -7.88 - 0.04, -28.62 + 0.04, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning24, 90);
    } else {
      instancedShopawnings.place(90, -7.88 - 0.04, -28.62 + 0.04, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning22 = shopawning.clone();
      _hotload.add(shopawning22);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning22, -7.65 - 0.04, -28.00, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning22, 90);
    } else {
      instancedShopawnings.place(90, -7.65 - 0.04, -28.00, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning26 = shopawning.clone();
      _hotload.add(shopawning26);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning26, -7.54 - 0.08, -27.73 - 0.02, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning26, 90);
    } else {
      instancedShopawnings.place(90, -7.54 - 0.08, -27.73 - 0.02, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning25 = shopawning.clone();
      _hotload.add(shopawning25);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning25, -7.34 - 0.08, -27.06, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning25, 90);
    } else {
      instancedShopawnings.place(90, -7.34 - 0.08, -27.06, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning28 = shopawning.clone();
      _hotload.add(shopawning28);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning28, -7.12 - 0.04, -26.01, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning28, 90);
    } else {
      instancedShopawnings.place(90, -7.12 - 0.04, -26.01, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning20 = shopawning.clone();
      _hotload.add(shopawning20);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning20, -6.61 + 0.04, -25.28, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning20, -90);
    } else {
      instancedShopawnings.place(-90, -6.61 + 0.04, -25.28, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning19 = shopawning.clone();
      _hotload.add(shopawning19);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning19, -6.65 - 0.08, -24.36, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning19, 90);
    } else {
      instancedShopawnings.place(90, -6.65 - 0.08, -24.36, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning18 = shopawning.clone();
      _hotload.add(shopawning18);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning18, -5.93 + 0.04, -22.92, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning18, -90);
    } else {
      instancedShopawnings.place(-90, -5.93 + 0.04, -22.92, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning17 = shopawning.clone();
      _hotload.add(shopawning17);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning17, -6.11 - 0.05, -22.39, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning17, 90);
    } else {
      instancedShopawnings.place(90, -6.11 - 0.05, -22.39, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning16 = shopawning.clone();
      _hotload.add(shopawning16);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning16, -5.76 + 0.04, -22.06, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning16, -90);
    } else {
      instancedShopawnings.place(-90, -5.76 + 0.04, -22.06, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning15 = shopawning.clone();
      _hotload.add(shopawning15);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning15, -6.10 - 0.04, -21.62 + 0.045, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning15, 90);
    } else {
      instancedShopawnings.place(90, -6.10 - 0.04, -21.62 + 0.045, 0.00);
    }

    if (!shopawninginstance) {
      var shopawning14 = shopawning.clone();
      _hotload.add(shopawning14);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning14, -6.12 - 0.01, -20.96, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning14, 90);
    } else {
      instancedShopawnings.place(90, -6.12 - 0.01, -20.96, 0.00);
    }

    // The awning outside the lowercity shop
    if (!shopawninginstance) {
      var shopawning13 = shopawning.clone();
      _hotload.add(shopawning13);
      shopawning13.scale.setValues(0.45, 0.45 * 1.2, 0.45);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning13, -6.11 - 0.04, -20.45 - 0.04, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning13, 90);
    } else {

      instancedShopawnings.place(90, -6.11 - 0.04, -20.45 - 0.04, 0.00,
          scale:THREE.Vector3(0.45*1.05, 0.45*1.05, 0.45*1.05)// Make it slightly bigger so customer text can be seen in lowercity journey
      );
    }

    if (!shopawninginstance) {
      var shopawning21 = shopawning.clone();
      _hotload.add(shopawning21);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          shopawning21, -6.58 + 0.04, -20.55, 0.00, 2);
      OPENWORLD.Space.objTurn(shopawning21, -90);
    } else {
      instancedShopawnings.place(-90, -6.58 + 0.04, -20.55, 0.00);
    }

    instancedShopawnings.finish();


  }
}