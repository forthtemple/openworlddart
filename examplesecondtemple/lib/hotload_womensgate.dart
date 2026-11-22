// Code for the womensgate journey
// Go from the north outside of jerusalem, through bethesda, then pool of bethesda, then fishgate, the western wall, then robinsons arch, then stoa and then court of women
part of 'SecondTemplePage.dart';

extension HotloadWomensgateExt on SecondTemplePageState {
  hotloadWomensgate(firsthotload, ) async {
    //// womensgate
    // gate of the woman hotload

    // Womensgate doors
    var doorwomensgateeast = doorwood.clone();
    //  doorgoldnorthgateeast.scale.setValues(0.2, 0.37, 0.2);
    // OPENWORLD.Texture.setMaterial(doorgoldnorthgateeast, goldmaterialnormal!);
    _hotload.add(doorwomensgateeast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwomensgateeast,-13.66+0.04, 63.15-0.05, 0.00,
        10);
    doorwomensgateeast.scale.setValues(0.2, 0.25, 0.2);

    var doorwomensgatewest = doorwomensgateeast.clone();
    _hotload.add(doorwomensgatewest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwomensgatewest, -13.86, 63.15-0.04-0.07, 0.00,
        10);

    var doorwaywomensgate=OPENWORLD.Doorway();
    doorwaywomensgate.addDoor(doorwomensgateeast,166-180,90-14);
    doorwaywomensgate.addDoor(doorwomensgatewest,166-180,-90-14);

    doorwaywomensgate.obstacle=  OPENWORLD.Obstacles.createObstacle(-13.75,63.15,0.4,0.2);//,marker:_hotload);
    doorwaywomensgate.setOpenClose(!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwaywomensgate);

    // These need to be defined up here as used everywhere
    // Some sellers at the womensgate here
    var birdsellerposx = -14.47 - 0.01;
    var birdsellerposy = 64.62;
    var birdseller = await OPENWORLD.Actor.copyActor(
        manlist[manlist.length - 1], randomduration: 0.1, duration: 2.0,
        action: "sittableidle"); //idle3"); //, action:"idlehold");
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          birdseller, birdsellerposx, birdsellerposy, -0.01,//0.01, //-13.64, 62.71, 0,
          4,
          lerpopacity: 1); //-14.12, 63.32,0,3);//-14.18, 63.44,0,3);// -14.08, 64.13,0,3);//-13.51, 64.25, 0.0, 3); //3.42);
      _hotload.add(birdseller);
      OPENWORLD.Mob.setInitTurn(birdseller, 90);

      var stool2 = stool.clone();
      _hotload.add(stool2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          stool2,birdsellerposx, birdsellerposy, 0, //-3.55, -12.63, 0,
          1.5); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
      OPENWORLD.Space.objTurn(stool2, 90);
    }


    var foodseller = await OPENWORLD.Actor.copyActor(
        manlist[manlist.length - 5], randomduration: 0.1,
        action: "squatwork");
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          foodseller, -13.63, 64.08, 0.00, 4, lerpopacity: 1);
      _hotload.add(foodseller);
      OPENWORLD.Space.objTurn(foodseller, -90);
    }

    if (gamestart == GameStart.womensgate) {
      // Horse that player can ride
      _horse = await OPENWORLD.Actor.copyActor(
          donkeypack, randomduration: 0.1); //, action:null);
      _horse.extra['riding'] = await OPENWORLD.Model.createModel(
          'assets/actors/donkey.glb'); // why must I do this - if you dont it flutters
      _horse.extra['riding'].scale.setValues(0.04, 0.04, 0.04);
      OPENWORLD.Space.objTurn(_horse.extra['riding'], 0);
      //                          up    forward
      _horse.extra['riding'].position.setValues(0.0, -0.095, -0.06);
      OPENWORLD.Space.objTurn(_horse, 166);
      if (OPENWORLD.System.isDesktop()) {
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
        // _horse = await OPENWORLD.Model.createModel('assets/actors/donkey29.glb');
        _horse.scale.setValues(0.04, 0.04,
            0.04);
      }
      //  _horse = await OPENWORLD.Actor.copyActor(horse, randomduration: 0.1);


      if (OPENWORLD.System.isDesktop())
        horseKeypress();
      OPENWORLD.BaseObject.setDistanceTrigger(_horse, dist: 0.5, event:(action) {
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

      // If the horse has been stabled then put it in the stable otherwise it is based on your progress
      Map dict = getusedict(); //gamestartpos[gamestart];
      //  if (dict.containsKey('p')) {
      Glob.hasstabled = gamestartpos[gamestart]['progress'].contains('stables');

      List posi = dict['p'];

      if (Glob.hasstabled) //posi[1] < 22)
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            _horse, 4.29, 22.41, 0,
            6); //-25.49, 116.86,0,6);//12.67, 5.22, 0, 6); // 9.8,1.1, 0.14,3); //3.42);
      else
        //-25.51, 117.12
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            _horse, posi[0], posi[1], 0, // -25.51, 117.12, 0.0,
            6); //-25.49, 116.86,0,6);//12.67, 5.22, 0, 6); // 9.8,1.1, 0.14,3); //3.42);
      _hotload.add(_horse);

      ///  OPENWORLD.BaseObject.setDistanceTrigger(_horse, dist: 0.1);
      threeJs.camera.children.clear();

      List<Map> spritemsg=[];
      if (OPENWORLD.System.isDesktop())
        spritemsg.add({'message': 'E', 'textcolor': Colors.white,
          'backgroundcolor': Colors.black,
          'backgroundopacity': 1.0,
          'paddingLeft': 5, 'paddingRight': 5});
      spritemsg.add(
          {'message': 'Mount', 'textcolor': Colors.white,
            'backgroundcolor': Colors.black,
            'backgroundopacity': 0.02});
      OPENWORLD.Mob.setMultiText(
          _horse,spritemsg, scale: 0.008, y: 0.0, z: 1.8); //, fontfamily: "Roboto");


      // if you havent stabled the horse then ride it automatically
      if (!Glob.hasstabled) {
        callwhenloaded(() {
          if (OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, _horse) < 1)
            mount();

        });
      }

      // Boxthrorn vgetation north of jerusalem
      for (var y = 120; y > 64; y -= 2) {
        //
        var x = OPENWORLD.Math.interpolateX(y.toDouble(), citizenpath) +
            OPENWORLD.Math.randFloatSpread(0.4);
        for (var i = 0; i < 2; i++) {
          //  var tree=Tree();
          var treei = await Tree.createTree([
            ["assets/textures/boxthorn.png", 0.8], // leafscale
            ["assets/textures/boxthorn2.png", 0.8],
            ["assets/textures/boxthorn3.png", 1.4]
          ],
              leafspritescale: 1.2,
              // is redundant because have specified in leafpaths
              // treehollowness: 0.2,
              spreadx: 3.0,
              spreadz: 3.0,
              spready: 1.0,
              //   useplanes: false,
              leafspritespertree: 128,
              spreadytapertop: 0.5);
          //   OPENWORLD.Updateables.add(tree);


          treei.scale.setValues(0.1 * 2.5, 0.1 * 2.5,
              0.1 * 2.5);
          var diff;
          if (i == 0)
            diff = -1.5;
          else
            diff = 1.5;
          var yval = y.toDouble() + OPENWORLD.Math.randFloatSpread(0.4);
          OPENWORLD.Space.objTurn(treei, OPENWORLD.Math.random() * 360);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              treei, x + diff, yval, 0.0,
              10
            //,lerpopacity: 4.0
          ); // -25.51, 116.5,0.0,6);//-25.49, 116.86,0,6);//12.67, 5.22, 0, 6); // 9.8,1.1, 0.14,3); //3.42);
          OPENWORLD.Obstacles.createObstacle(x + diff, yval, 0.7, 0.7);

          //  blocklist.add(
          //    [x + diff, yval, 0.7]); //-25.51, 116.5,0.2]);//,0.5]);
          _hotload.add(treei);
        }
      }

      womensgategroup = []; // This is the list of citizens that make up your group - it will have numfriends citizens in it
      var hasmissed = false;
      var numfriends = 5;
      // This seems to be the places where friendreach() will be called by moveto - also this is the path your friends travel

      // Friendrellist just has releative position of friends in local coords - children at the front -adults at the back
      var friendrellist = [
        [0.05, 0.2], //man
        [-0.05, 0.2], //woman
        [0.1, 0.4], //kid
        [0.0, 0.4], //kid
        [-0.1, 0.4] //kid
/*      [-0.05 , 0.2], //man
      [0.05, 0.2], //woman
      [-0.1 , 0.4], //kid
      [0.0 , 0.4], //kid
      [0.1 , 0.4]*/ //kid
/*      [-0.05 + 0.05, 0.2], //man
      [0.05 + 0.05, 0.2], //woman
      [-0.1 + 0.05, 0.4], //kid
      [0.0 + 0.05, 0.4], //kid
      [0.1 + 0.05, 0.4]*/ //kid
      ];
      /* for (var y in ylist) {
      friendrellist.add([ OPENWORLD.Math.randFloatSpread(dist / 3), y]);
    }*/

      // Given these relative position, place them in world coordianates based upon the world position of your friends and the angle facing
      globpos(num globx, num globy, num angle, num relx, num rely) {
        final double rad = angle * math.pi / 180.0;
        final double cosA = math.cos(rad);
        final double sinA = math.sin(rad);

        // Local +x = right of facing direction, local +y = forward
        // Angle 0 = North, increasing clockwise (standard bearing)
        final double offsetX = relx * cosA + rely * sinA;
        final double offsetY = -relx * sinA + rely * cosA;

        return [globx + offsetX, globy + offsetY];
      }

      // Have your female friend hold the dove
      wielddove() {
        var birdcagedove2 = birdcagedoves.clone();

        OPENWORLD.Space.setTurnPitchRoll(
            birdcagedove2, 0, 90,
            90 + 90); //walkstraight is good!

        //OPENWORLD.Space.setTurnPitchRoll(
        //     birdcagepigeon2, -45, 90, 90 + 90); //walkstraight is good!
        birdcagedove2.scale.setValues(1.0, 1.0, 1.0);
//      birdcagedove2.scale.setValues(1.4, 1.4, 1.4);
        //   vesselbowl.position.z=0.0;//-4.0;
        //   vesselbowl.position.y=7.0;//5.0;
        //   vesselbowl.position.x=0.0;
        OPENWORLD.Actor.wield(womensgategroup[1], birdcagedove2,
            "Bip01_R_Hand");
      }

      // Friends sing a psalm
      var lastverse = null;
      psalm(actor, {againy = 74, first = true, msg}) {
        if (actor.extra['friend'] == 0) {
          // verselines.insert(0,"Lets sing a psalm");
          if (first)
            lookback(actor);
          if (msg==null)
            msg=[first ? "Let's sing a psalm" : OPENWORLD.Math.randPick(["One more?","Let's sing another psalm","Shall we sing another?"])];
          OPENWORLD.Mob.setSpeech(actor,
              msg, z: 90,
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
                    scale: 0.7,
                    randwait: 0,
                    delay: 2,
                    tails: {
                      'bottomleft',
                      'bottomright',
                      'bottomcenter'
                    },
                    callbackonfinish: (actor) {
                      if (actor
                          .visible) { //&&OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, actor)<)
                        var friendposition = OPENWORLD.Space.localToWorldObj(
                            actor);
                        // If more time then do another psalm
                        //74
                        if (friendposition.y > againy &&
                            OPENWORLD.Space.getDistanceBetweenObjs(
                                threeJs.camera, actor) < 1)
                          psalm(actor, againy: againy, first: false);
                      }
                    });
              }
            //   delay:9
          );
        }
      }

      // For a friend in  womensgategroup, get its positions so that can put in movetoloop - is based upon the current position of the friend
      // This for the path around the Second Temple - stoa to court of women
      getFriendToTemplePos(i) {
        List<Map> poslist = [];
        if (OPENWORLD.System.loaded && womensgategroup.length <= i)
          return poslist;
        var posfriend = friendrellist[i]; // This is the releative position of this friend

        // Add the first position which will be 0.2 ahead of the players start pos
        print("is loading" + OPENWORLD.System.loaded.toString() + " " + i.toString());
        THREE.Vector3 startpos;
        var firstpos;
        if (OPENWORLD.System.loaded) {
          startpos = OPENWORLD.Space.localToWorldObj(womensgategroup[i]);
          firstpos = [
            startpos.x,
            startpos.y
          ];
          //startfacingangle=OPENWORLD.Space.getObjTurn(womensgategroup[i]);
        } else {
          // ! loaded
          startpos = THREE.Vector3(
              0.0, 0.0, 0.0);
          Map dict = getusedict(); //gamestartpos[gamestart];
          if (dict.containsKey('p')) {
            List posi = dict['p'];
            if (posi != null && posi.length >= 2) {
              startpos = THREE.Vector3(
                  posi[0], posi![1], 0.0);
              //gamestartpos[gamestart]!['p']?[0].toDouble(),
              //  gamestartpos[gamestart]!['p']?[1].toDouble(), 0.0);
              firstpos = [
                startpos.x, //+ 0.1,
                startpos.y //- 0.2
              ];
            }
          }
        }

        /// var facingnorth=startfacingangle>270||startfacingangle<90;
        /// This wont work if you're restarting as
        var foundind = OPENWORLD.Math.findClosestNextIndex(
            friendpathtemple, startpos[0], startpos[1]);

        var facingangle;
        var dist = OPENWORLD.Math.vectorDistance(startpos,
            THREE.Vector3(
                friendpathtemple[foundind][0], friendpathtemple[foundind][1],
                0));
        if (dist > 0.5) {
          facingangle = OPENWORLD.Math.getAngleBetweenPoints(startpos,
              THREE.Vector3(
                  friendpathtemple[foundind][0], friendpathtemple[foundind][1],
                  0));
          //  print('templefacingangle' + facingangle.toString() + " " +
          //     startpos.toString() + " " + friendpathtemple[foundind].toString() +
          //     " " + foundind.toString());
          if (OPENWORLD.System.loaded)
            poslist.insert(0, {
              "p": [firstpos[0], firstpos[1], 0],
              "v": horsespeed / 2,
              "l": 1,
              //"callback": friendreach
            });
          else {
            var posi = globpos(
                firstpos[0], firstpos[1], facingangle, posfriend[0],
                posfriend[1]);
            poslist.insert(0, {
              "p": [posi[0], posi[1], 0],
//        "p": [firstpos[0] + posfriend[0], firstpos[1] - posfriend[1], 0],
              "v": horsespeed / 2,
              "l": 1,

              //"callback": friendreach
            });
          }

          // print("polist" + poslist.toString());
        }
        // for (var posfriend in friendrellist)
        // For this friend in  womensgategroup add all his walking positions relative to the group


        for (var j = foundind; j <
            friendpathtemple.length; j++) { //pos in friendpos)
          var pos = friendpathtemple[j];
          //  if (pos[1] <
          //      startpos.y - posfriend[1]) { // gamestartpos[gamestart]![1]) {
          Map item;
          //  var xdiff =0.0;// 0.15;
          var facingangle;
          if (j == friendpathtemple.length - 1) {
            facingangle = 270;
          } else if (j == 1) {
            facingangle = 180;
            ;
          } else if (j < friendpathtemple.length - 1)
            facingangle = OPENWORLD.Math.getAngleBetweenPoints(
                THREE.Vector3(
                    friendpathtemple[j][0], friendpathtemple[j][1], 0),
                THREE.Vector3(
                    friendpathtemple[j + 1][0], friendpathtemple[j + 1][1], 0));
          else
            facingangle = OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(
                friendpathtemple[j - 1][0], friendpathtemple[j - 1][1], 0),
                THREE.Vector3(
                    friendpathtemple[j][0], friendpathtemple[j][1], 0));
          print('jfacinganglej' + j.toString() + " " + facingangle.toString());

          //   print("uuufacingangle"+facingangle.toString());
          var fct;
          fct = 0.5;
          var posfriendy;
          if (j == friendpathtemple.length - 1) {
            if (i == 0 || i == 1)
              posfriendy = 0.07; //  parents at front
            else
              posfriendy =
                  OPENWORLD.Math.randFloatSpread(0.02); //  kids at back
          } else if (j == 1)
            posfriendy = 0.1 + OPENWORLD.Math.randFloatSpread(
                0.02); // so everyone lines up at the dove seller
          else
            posfriendy = posfriend[1] * fct;
          var posi = globpos(
              pos[0], pos[1], facingangle, posfriend[0] * fct,
              posfriendy); // posfriend[1]*fct);

          item = {"p": [posi[0], posi[1], 0], "l": 1};
          //  if (j!=9)
          item['v'] = horsespeed / 2;
          // else
          //   item['time']=10.0;
          // item['callback'] = friendreach;
          if (j == 1) {
            item['callback'] = (actor) {
              OPENWORLD.Space.objTurnLerp(actor, 180, 1);
              if (actor == womensgategroup[0]) {
                OPENWORLD.Space
                    .worldToLocalSurfaceObjLerp(
                    threeJs.camera, -3.47, -12.52,
                    OPENWORLD.Camera.cameraoffset, 0.5, level: 1, delay: 1);
                // Player must reach this spot of error with doveseller
                OPENWORLD.Space
                    .worldToLocalSurfaceObj(
                    threeJs.camera, -3.47, -12.52,
                    OPENWORLD.Camera.cameraoffset, level: 1, delay: 2);
                OPENWORLD.Space.objTurnLerp(threeJs.camera, 180, 1, delay: 1);
                OPENWORLD.Actor.playActionThen(
                    actor, "worklow", duration: 4, "idle");
                OPENWORLD.Actor.playActionThen(
                    womensgategroup[1], "worklow", duration: 4,
                    "idle",
                    delay: 2);
                // This is the dove seller in the stoa
                var dovesellerpositionjsons = OPENWORLD.Config
                    .getPositionsByLabel(OPENWORLD.Config
                    .config['positions']['poolpositions'][1]['positions'],
                    'dovesellerwomensgate');
                Future.delayed(
                    Duration(
                        milliseconds: 5000), () async {
                  var doveseller = OPENWORLD.Config.getPoolPositionObject(
                      dovesellerpositionjsons[0]);
                  OPENWORLD.Mob.setSpeech(
                    doveseller, ["You wont find better",
                  "than this dove"], z: 80,
                    width: 400,
                    scale: 0.2,
                    minwait: 3,
                    randwait: 0,
                  //  delay: 2,
                    clearwhendone: true,
                    callbackonfinish: (actor) {
                      OPENWORLD.Space.faceObjectLerp(
                          womensgategroup[1], threeJs.camera, 1, delay: 4);
                      OPENWORLD.Space.objTurnLerp(
                          womensgategroup[1], 180, 1, delay: 8);
                      OPENWORLD.Actor.playActionThen(
                          womensgategroup[1], "worklow", duration: 4, "idle");
                      OPENWORLD.Mob.setSpeech(
                          womensgategroup[1], ["Yes, it looks perfect.",
                        "Should we get it?"], z: 80,
                          width: 400,
                          scale: 0.2,
                          minwait: 3,
                          randwait: 0,
                          delay: 2,
                          clearwhendone: true,
                          callbackonfinish: (actor) {
                            //   lookback(actor);
                            OPENWORLD.Actor.playActionThen(
                                doveseller, "sittablearmsup", duration: 4,
                                "sittableidle",
                                delay: 2);

                            Future.delayed(
                                Duration(
                                    milliseconds: 5000), () async {
                              wielddove();
                              OPENWORLD.Actor.playActionThen(
                                  womensgategroup[1], "worklow", duration: 4,
                                  "idlestraight");

                              OPENWORLD.Mob.setSpeech(
                                  womensgategroup[1], ["We'll take it.",
                                "Shalom",
                                "Let's go"], z: 80,
                                  width: 400,
                                  scale: 0.2,
                                  minwait: 5,
                                  randwait: 0,
                                  clearwhendone: true,
                                  callbackonfinish: (actor) {

                                  });
                              //  OPENWORLD.Space.faceObjectLerp(doveseller, womensgategroup[0],1.0,delay:6);
                              OPENWORLD.Mob.setSpeech(
                                  doveseller, ["Shalom"], z: 80,
                                  width: 400,
                                  scale: 0.2,
                                  minwait: 3,
                                  randwait: 0,
                                  delay: 6,
                                  clearwhendone: true);
                              OPENWORLD.Actor.playActionThen(
                                  doveseller, "sittablelookup", duration: 3,
                                  "sittableidle",
                                  delay: 6);
                            });
                          }
                      );
                    });
                    });
              }
            };
          } else if (j == 4) {
            item['callback'] = (actor) {
              saveGameState('soreg');
            };
          } else if (j == 5) {
            item['callback'] = (actor) {
              if (actor == womensgategroup[0]) {
                OPENWORLD.Mob.setSpeech(
                    womensgategroup[0], [ "The court of women.",
                  "We'll go to the Nicanor gate"], z: 90,
                    width: 400,
                    scale: 0.4,
                    minwait: 5,
                    randwait: 0,
                    clearwhendone: true);
                lookback(actor);
              }
            };
          } else if (j == 6) {
            item['callback'] = (actor) {
              saveGameState('courtofwomen');
            };
          } else if (j == friendpathtemple.length - 1) {
            /*  item['callback']=(actor ){
            OPENWORLD.Actor.playAction(
                actor, action: "idle",
              );
          //  5.99, 0.41
            if (actor==womensgategroup[0])  {
              womensgategroup[0].extra.remove('followingfriend');

            }
          };*/
          }
          if (i == 1 && j >= 1)
            item['action'] = 'walkstraight'; // so can hold the bird cage
          poslist.add(item);
          if (j == 1) {
            poslist.add({"action": "idle", "time": 38, "callback": (actor) {
              OPENWORLD.Space.faceObjectLerp(
                  threeJs.camera, womensgategroup[0], 1, delay: 2);
            }
            });
          } else if (j == friendpathtemple.length - 1) {
            poslist.add({
              "action": i == 1 ? "idlestraight" : "idle",
              "t": 270,
              "time": 1,
              "callback": (actor) async {
                if (actor == womensgategroup[0]) {
                  womensgategroup[0].extra.remove('followingfriend');

                  OPENWORLD.Space
                      .worldToLocalSurfaceObjLerp(
                      threeJs.camera, 5.77, 0.49,
                      //5.78, 0.46,//5.94, 0.43,//5.99, 0.41,
                      OPENWORLD.Camera.cameraoffset, 1, level: 1);
                  OPENWORLD.Mob.setSpeech(
                      womensgategroup[0], [ "Here comes a priest now."], z: 80,
                      width: 400,
                      scale: 0.3,
                      minwait: 5,
                      randwait: 0,
                      delay: 2,
                      clearwhendone: true);

                  OPENWORLD.Space.objTurnLerp(threeJs.camera, 260, 1);
                  var priest32ii = await OPENWORLD.Actor.copyActor(
                      priest32, randomduration: 0.1);
                  _hotload.add(priest32ii);
                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                      priest32ii, 4.91, -0.59, 0, 3,
                      level: 1); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
                  OPENWORLD.Space.objTurn(priest32ii, 0);
                  OPENWORLD.Mob.moveTo(priest32ii, [
                    [5.17, 0.42 - 0.2, 0, 0.06],
                    [5.4 + 0.1, 0.37, 0, 0.04]], action: "walk",
                      stopaction: "idle",
                      surfaceonly: true,
                      level: 1,
                      callbackonfinish: (actor) {
                        OPENWORLD.Space.faceObjectLerp(
                            womensgategroup[0], priest32ii, 1.0);
                        OPENWORLD.Space.faceObjectLerp(
                            womensgategroup[2], priest32ii, 1.0,
                            delay: OPENWORLD.Math.random());
                        OPENWORLD.Space.objTurnLerp(actor, 90, 1);
                        // OPENWORLD.Actor.playActionThen(
                        //    actor, "idleholdleft", duration:6,"idle");
                        OPENWORLD.Actor.playActionThen(
                            actor, "squateat", duration: 6,
                            "idle"); // squatwork
                        // OPENWORLD.Actor.playActionThen(
                        //    womensgategroup[1], "idlehold", duration:6,"idle");
                        OPENWORLD.Actor.playActionThen(
                            womensgategroup[1], "lookright", "idlestraight",
                            delay: 4); // squatwork

                        OPENWORLD.Mob.setSpeech(
                            womensgategroup[0], [ "Let's watch him",
                          "sacrifice the turtle doves"], z: 80,
                            width: 400,
                            scale: 0.3,
                            minwait: 5,
                            randwait: 0,
                            delay: 14,
                            clearwhendone: true);

                        var cage = OPENWORLD.Actor.getWielding(
                            womensgategroup[1]);
                        OPENWORLD.BaseObject.setVisible(
                            cage, false, groupname: "pigeon");
                        var dove2 = dove.clone();
                        dove2.scale.setValues(1.0, 1.0, 1.0);
                        OPENWORLD.Space.resetPosRot(dove2);
                        dove2.position.x = -4.0;
                        OPENWORLD.Space.setTurnPitchRoll(
                            dove2, 0, 90, 90 + 90);
                        OPENWORLD.Actor.wield(
                            priest32ii, dove2, "Bip01_R_Hand", delay: 2);
                        var dove3 = dove2.clone();
                        OPENWORLD.Actor.wield(
                            priest32ii, dove3, "Bip01_L_Hand", delay: 3);
                        OPENWORLD.Mob.moveTo(priest32ii, [
                          [5.17, 0.42 - 0.2, 0, 0.08],
                          [4.49, -1.25, 0, 0.08],
                          [4.29, -1.25, 0, 0.08],
                          [4.29, -0.13 + 0.05, 0, 0.08],
                        ], action: "walk",
                            stopaction: "idle",
                            surfaceonly: true,
                            level: 1,
                            delay: 10,
                            callbackonfinish: (actor) {
                              // Womensgate done
                              OPENWORLD.Actor.playActionThen(
                                  priest32ii, "armsup", duration: 5,
                                  "idle"); // squatwork
                              OPENWORLD.Space.faceObjectLerp(
                                  actor, womensgategroup[0], 1, delay: 8);
                              for (var friend in womensgategroup)
                                 OPENWORLD.Space.faceObjectLerp(
                                   friend, threeJs.camera,1, delay: 12+OPENWORLD.Math.random()*4);
                              OPENWORLD.Mob.setSpeech(
                                  womensgategroup[0], ["You are now purified.",
                                  ], z: 80,
                                  width: 400,
                                  scale: 0.2,
                                  minwait: 3,
                                  randwait: 0,
                                  delay:16,
                                  clearwhendone: true);
                              for (var friend in womensgategroup)
                                OPENWORLD.Space.objTurnLerp(
                                    friend, 270,1, delay: 20+OPENWORLD.Math.random()*4);
                              /* for (var jj=0; jj<numfriends; jj++) {
                            OPENWORLD.Space.faceObjectLerp(womensgategroup[jj], threeJs.camera, 1.0,delay:OPENWORLD.Math.random()*2);
                          }*/

                            });

                        /*cage.traverse( (child) {
                      if(child is THREE.Mesh ){
                        // print("oo"+(child.material as THREE.MeshStandardMaterial).name.toString());
                        print('upppo'+child.name.toString()+" "+child.material.toString());
                      }
                    });   */ //  for (var dove in cage.children)
                        //   dove.visible=false;
                      });
                }
              }
            });
            //OPENWORLD.Actor.playAction(
            //  actor, action: "idle",
            //);
          }
        }
        return poslist;
      }


      // For a friend in  womensgategroup, get its positions so that can put in movetoloop - is based upon the current position of the friend
      // I think this starts at fish gate and then to top of robinsons gate
      getFriendToRobinsonsPos(i) {
        List<Map> poslist = [];
        if (OPENWORLD.System.loaded && womensgategroup.length <= i)
          return poslist;
        var posfriend = friendrellist[i]; // This is the releative position of this friend

        // Add the first position which will be 0.2 ahead of the players start pos
        print("is loading" + OPENWORLD.System.loaded.toString() + " " + i.toString());
        THREE.Vector3 startpos;
        var firstpos;
        if (OPENWORLD.System.loaded) {
          startpos = OPENWORLD.Space.localToWorldObj(womensgategroup[i]);
          firstpos = [
            startpos.x,
            startpos.y
          ];
          //startfacingangle=OPENWORLD.Space.getObjTurn(womensgategroup[i]);
        } else {
          // ! loaded
          startpos = THREE.Vector3(
              0.0, 0.0, 0.0);
          Map dict = getusedict(); //gamestartpos[gamestart];
          if (dict.containsKey('p')) {
            List posi = dict['p'];
            if (posi != null && posi.length >= 2) {
              startpos = THREE.Vector3(
                  posi[0], posi![1], 0.0);
              //gamestartpos[gamestart]!['p']?[0].toDouble(),
              //  gamestartpos[gamestart]!['p']?[1].toDouble(), 0.0);
              firstpos = [
                startpos.x, //+ 0.1,
                startpos.y //- 0.2
              ];
            }
          }
        }

        /// var facingnorth=startfacingangle>270||startfacingangle<90;
        /// This wont work if you're restarting as
        var foundind = OPENWORLD.Math.findClosestNextIndex(
            friendpathrobinsons, startpos[0], startpos[1]);

        var facingangle;
        var dist = OPENWORLD.Math.vectorDistance(startpos,
            THREE.Vector3(friendpathrobinsons[foundind][0],
                friendpathrobinsons[foundind][1], 0));
        if (dist > 0.5) {
          /* if (dist < 0.5) {
          if (foundind < friendpathrobinsons.length - 1)
            facingangle = OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(
                friendpathrobinsons[foundind][0], friendpathrobinsons[foundind][1],
                0),
                THREE.Vector3(friendpathrobinsons[foundind + 1][0],
                    friendpathrobinsons[foundind + 1][1], 0));
          else
            facingangle = OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(
                friendpathrobinsons[foundind - 1][0],
                friendpathrobinsons[foundind - 1][1], 0),
                THREE.Vector3(friendpathrobinsons[foundind][0],
                    friendpathrobinsons[foundind][1], 0));
        } else*/
          facingangle = OPENWORLD.Math.getAngleBetweenPoints(startpos,
              THREE.Vector3(
                  friendpathrobinsons[foundind][0],
                  friendpathrobinsons[foundind][1],
                  0));
          print('templefacingangle' + facingangle.toString() + " " +
              startpos.toString() + " " +
              friendpathrobinsons[foundind].toString() +
              " " + foundind.toString());
          if (OPENWORLD.System.loaded)
            poslist.insert(0, {
              "p": [firstpos[0], firstpos[1], 0],
              "v": horsespeed / 2,
              //"callback": friendreach
            });
          else {
            var posi = globpos(
                firstpos[0], firstpos[1], facingangle, posfriend[0],
                posfriend[1]);
            poslist.insert(0, {
              "p": [posi[0], posi[1], 0],
//        "p": [firstpos[0] + posfriend[0], firstpos[1] - posfriend[1], 0],
              "v": horsespeed / 2,
              //"callback": friendreach
            });
          }

          print("polist" + poslist.toString());
        }
        // for (var posfriend in friendrellist)
        // For this friend in  womensgategroup add all his walking positions relative to the group


        for (var j = foundind; j <
            friendpathrobinsons.length; j++) { //pos in friendpos)
          var pos = friendpathrobinsons[j];
          //  if (pos[1] <
          //      startpos.y - posfriend[1]) { // gamestartpos[gamestart]![1]) {
          Map item;
          //  var xdiff =0.0;// 0.15;
          var facingangle;
          if (j == 0)
            facingangle = OPENWORLD.Math.getAngleBetweenPoints(
                THREE.Vector3(
                    friendpathrobinsons[j][0], friendpathrobinsons[j][1], 0),
                THREE.Vector3(
                    friendpathrobinsons[j + 1][0],
                    friendpathrobinsons[j + 1][1], 0));
          else
            facingangle = OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(
                friendpathrobinsons[j - 1][0], friendpathrobinsons[j - 1][1],
                0),
                THREE.Vector3(
                    friendpathrobinsons[j][0], friendpathrobinsons[j][1], 0));
          print('jfacinganglej' + j.toString() + " " + facingangle.toString());

          //   print("uuufacingangle"+facingangle.toString());
          var fct;
          if (friendpathrobinsons[j][1] < 1.7)
            fct = 0.5; // if going along western wall then move closer together
          else
            fct = 1.0;
          var posi = globpos(
              pos[0], pos[1], facingangle, posfriend[0] * fct, posfriend[1]);

          item = {"p": [posi[0], posi[1], 0]};
          //  if (j!=9)
          item['v'] = horsespeed / 2;
          // else
          //   item['time']=10.0;
          // item['callback'] = friendreach;
          if (j == 0)
            item['callback'] = (actor) {
              saveGameState('fishgate');
            };
          else if (j == 1)
            item['callback'] = (actor) {
              psalm(actor,msg:["We're getting close to","the temple"]);
            };
          else if (j == 2)
            item['callback'] = (actor) {
              if (actor == womensgategroup[0]) {
                OPENWORLD.Mob.setSpeech(
                    womensgategroup[0], ["Our feet are standing",
                    "within your gates,",
                  "O Jerusalem"], z: 90,
                    width: 400,
                    scale: 0.4,
                    minwait: 3,
                    randwait: 0,
                    delay:20,
                    clearwhendone: true);
              }
            };
          else if (j == 6)
            item['callback'] = (actor) {
              saveGameState('westernwall');
            };
          else if (j == 8)
            item['callback'] = (actor) {
              saveGameState('wilsonsarch');
              if (actor == womensgategroup[0]) {
                OPENWORLD.Mob.setSpeech(
                    womensgategroup[0], ["Lets go up through",
                  "Robinsons arch to the stoa"], z: 80,
                    width: 400,
                    scale: 0.2,
                    minwait: 3,
                    randwait: 0,
                    clearwhendone: true,
                   delay:8);
              }
            };
          else if (j == friendpathrobinsons.length - 1) {
            item['callback'] = (actor) {
              // This is what gets them up the robinsons arch stairs
              var fct = 0.5; // so can fit through arch
              var finalpositions = [
                [-6.02, -13.93 + 0.2, 0],
                [-6.04, -13.93 + 0.2, 1],
                //  [-6.24,-13.93,0],
                //  [-6.26,-13.93, 1  ],
                [ -6.46, -13.93 + 0.2, 1],
                [ -7.61 + 0.2, -13.93 + 0.2, 1],
                [ -7.61 + 0.2, -11.69, 1],
                [ -4.96, -11.69, 1],
              ];
              List<List> poslist = [];
              //   var friendpos=OPENWORLD.Space.localToWorldObj(actor);
              //          for (var ii=0; ii< 1; ii++) {
              for (var ii = 0; ii < 4; ii++) { //finalpositions.length
                var angle;
                if (ii < 4) //finalpositions.length-1)
                  angle = 270.0;
                else
                  angle = 0.0;
                /*  if (ii==0)
                angle=OPENWORLD.Math.getAngleBetweenPoints(friendpos, THREE.Vector3(finalpositions[0][0].toDouble(),finalpositions[0][1].toDouble(),0.0));
              else if (ii==finalpositions.length-1)
                angle=OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(finalpositions[ii-1][0].toDouble(),finalpositions[ii-1][1].toDouble(),0.0),THREE.Vector3(finalpositions[ii][0].toDouble(),finalpositions[ii][1].toDouble(),0.0));
              else
                angle=OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(finalpositions[ii][0].toDouble(),finalpositions[ii][1].toDouble(),0.0),THREE.Vector3(finalpositions[ii+1][0].toDouble(),finalpositions[ii+1][1].toDouble(),0.0));
              */
                var pos = finalpositions[ii];
                var posi = globpos(pos[0], pos[1], angle, posfriend[0] * fct,
                    posfriend[1] * fct);
                //  var posi=[pos[0],pos[1],pos[2]];

                var v;
                if (ii <= 1)
                  v = womensgategroup.indexOf(actor) <= 1 ? 0.1 / 2 : 0.15 / 2;
                else
                  v = 0.1;
                poslist.add([
                  posi[0],
                  posi[1],
                  0.00,
                  v,
                  null,
                  pos[2]
                ]); //  [x,y,z,v,turn, level]
              }
              OPENWORLD.Mob.moveTo(actor, poslist, action: "walk",
                  stopaction: "idle",
                  surfaceonly: true,
                  callbackonfinish: (actor) {
                    OPENWORLD.Space
                        .worldToLocalSurfaceObjLerp(
                        threeJs.camera, -7.35, -13.80,
                        OPENWORLD.Camera.cameraoffset, 0.5, level: 1,
                        delay: 1);

                    if (actor == womensgategroup[3]) {
                      for (var jj = 0; jj < numfriends; jj++) {
                        OPENWORLD.Mob.clearText(womensgategroup[jj]);

                        List<List> poslist = [];
                        var posfriend2 = friendrellist[jj];
                        for (var iii = 4; iii < finalpositions.length; iii++) {
                          var pos = finalpositions[iii];
                          var angle;
                          if (iii == 4)
                            angle = 0;
                          else
                            angle = 90;

                          var posi = globpos(
                              pos[0], pos[1], angle, posfriend2[0] * fct,
                              posfriend2[1] * fct);
                          poslist.add([
                            posi[0],
                            posi[1],
                            0.00,
                            0.1,
                            null,
                            pos[2]
                          ]); //  [x,y,z,v,turn, level]
                        }
                        OPENWORLD.Mob.moveTo(
                            womensgategroup[jj], poslist, action: "walk",
                            stopaction: "idle",
                            surfaceonly: true,
                            callbackonfinish: (actor) {
                              if (actor == womensgategroup[0]) {
                                OPENWORLD.Mob.setSpeech(
                                    womensgategroup[0], ["Theres a dove seller",
                                  "over there",
                                  "Let's go"], z: 80,
                                    // Scatophagē!
                                    width: 400,
                                    scale: 0.2,
                                    minwait: 3,
                                    randwait: 0,
                                    clearwhendone: true);
                                OPENWORLD.Space.objTurnLerp(actor, 120, 1.0);
                                OPENWORLD.Actor.playActionThen(
                                    actor, "point", duration: 2, "idle");
                                Future.delayed(
                                    Duration(
                                        milliseconds: 5000), () async {
                                  lookback(actor);
                                });


                                Future.delayed(
                                    Duration(
                                        milliseconds: 8000), () async {
                                  for (var j = 0; j <
                                      womensgategroup.length; j++) {
                                    OPENWORLD.Mob.clearText(womensgategroup[j]);
                                    var poslist = getFriendToTemplePos(j);
                                    var friendpos = OPENWORLD.Space
                                        .localToWorldObj(womensgategroup[j]);
                                    poslist.insert(0, {
                                      "p": [
                                        friendpos.x,
                                        friendpos.y,
                                        0
                                      ],
                                      "v": 0.02,
                                      "l": 1
                                    });
                                    OPENWORLD.Mob.moveToLoop(
                                        womensgategroup[j],
                                        //  [
                                        poslist,
                                        looptype: OPENWORLD.Mob
                                            .LoopTypeStop,
                                        //.LoopTypeReverseLoop,
                                        surfaceonly: true,
                                        action: "walk");
                                  }
                                });
                              }
                            });
                      }
                    }
                  }
              );
            };
          }
          poslist.add(item);
        }
        return poslist;
      }


      // For a friend in  womensgategroup, get its positions so that can put in movetoloop - is based upon the current position of the friend
      // Takes you from pool of bethesda to fishgate
      getFriendToFishgatePos(i) {
        List<Map> poslist = [];
        if (OPENWORLD.System.loaded && womensgategroup.length <= i)
          return poslist;
        var posfriend = friendrellist[i]; // This is the releative position of this friend

        // Add the first position which will be 0.2 ahead of the players start pos
        print("is loading" + OPENWORLD.System.loaded.toString() + " " + i.toString());
        THREE.Vector3 startpos;
        var firstpos;
        if (OPENWORLD.System.loaded) {
          startpos = OPENWORLD.Space.localToWorldObj(womensgategroup[i]);
          firstpos = [
            startpos.x,
            startpos.y
          ];
          //startfacingangle=OPENWORLD.Space.getObjTurn(womensgategroup[i]);
        } else {
          // ! loaded
          startpos = THREE.Vector3(
              0.0, 0.0, 0.0);
          Map dict = getusedict(); //gamestartpos[gamestart];
          if (dict.containsKey('p')) {
            List posi = dict['p'];
            if (posi != null && posi.length >= 2) {
              startpos = THREE.Vector3(
                  posi[0], posi![1], 0.0);
              //gamestartpos[gamestart]!['p']?[0].toDouble(),
              //  gamestartpos[gamestart]!['p']?[1].toDouble(), 0.0);
              firstpos = [
                startpos.x, //+ 0.1,
                startpos.y //- 0.2
              ];
            }
          }
        }

        /// var facingnorth=startfacingangle>270||startfacingangle<90;
        /// This wont work if you're restarting as
        var foundind = OPENWORLD.Math.findClosestNextIndex(
            friendpathfishgate, startpos[0], startpos[1]);

        var facingangle = OPENWORLD.Math.getAngleBetweenPoints(startpos,
            THREE.Vector3(friendpathfishgate[foundind][0],
                friendpathfishgate[foundind][1], 0));
        if (OPENWORLD.System.loaded)
          poslist.insert(0, {
            "p": [firstpos[0], firstpos[1], 0],
            "v": horsespeed / 2,
            //"callback": friendreach
          });
        else {
          var posi = globpos(
              firstpos[0], firstpos[1], facingangle, posfriend[0],
              posfriend[1]);
          poslist.insert(0, {
            "p": [posi[0], posi[1], 0],
//        "p": [firstpos[0] + posfriend[0], firstpos[1] - posfriend[1], 0],
            "v": horsespeed / 2,
            //"callback": friendreach
          });
          print('xxxfacingangle' + facingangle.toString() + " " + i.toString() +
              " " + firstpos.toString() + " " + posfriend.toString() + " " +
              posi.toString() + " " + foundind.toString());
        }

        // For this friend in  womensgategroup add all his walking positions relative to the group


        for (var j = foundind; j < friendpathfishgate.length; j++) { //pos in friendpos)
          var pos = friendpathfishgate[j];
          //  if (pos[1] <
          //      startpos.y - posfriend[1]) { // gamestartpos[gamestart]![1]) {
          Map item;
          var xdiff = 0.15;
          var facingangle;
          if (j == 0)
            facingangle = OPENWORLD.Math.getAngleBetweenPoints(
                THREE.Vector3(
                    friendpathfishgate[j][0], friendpathfishgate[j][1], 0),
                THREE.Vector3(
                    friendpathfishgate[j + 1][0], friendpathfishgate[j + 1][1],
                    0));
          else
            facingangle = OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(
                friendpathfishgate[j - 1][0], friendpathfishgate[j - 1][1], 0),
                THREE.Vector3(
                    friendpathfishgate[j][0], friendpathfishgate[j][1], 0));
          print('jfacinganglej' + j.toString() + " " + facingangle.toString());

          //   print("uuufacingangle"+facingangle.toString());
          var posi = globpos(
              pos[0], pos[1], facingangle, (posfriend[0] + xdiff),
              posfriend[1]);

          item = {"p": [posi[0], posi[1], 0]};
          //  if (j!=9)
          item['v'] = horsespeed / 2;
          // else
          //   item['time']=10.0;
          // item['callback'] = friendreach;

          if (j == 3)
            item['callback'] = (actor) {
              saveGameState('goingnorth');
            };
          else if (j == 5)
            item['callback'] = (actor) {
              if (actor == womensgategroup[0]) {
                lookback(womensgategroup[0]);
                OPENWORLD.Mob.setSpeech(
                    womensgategroup[0], [
                  "We'll go up to the fish gate",
                  "then down Tyropoeon valley",
                  "",
                  "How about we sing 'song of the Vineyard'?"],
                    //Spring up, O well'?"],
                    z: 100,
                    width: 400,
                    scale: 0.4,
                    randwait: 0,
                    minwait: 5,
                    clearwhendone: true,
                    callbackonfinish: (actor) {
                      lookback(womensgategroup[1]);
/*
                  var chat = [
                    {0: "Spring up, O well!"},
                    {1: "Sing to it!"},
                    {0: "The well the princes dug"},
                    {1: "Spring up, O well!"},
                    {0: "The nobles opened with their staffs"},
                    {1: "Sing to it!"},
                    {0:''},
                    {0: "Another?"},
                    {0:"How about 'song of the Vineyard?'"},
                  ];
                  var springarr = createChat(chat);//,blank:' ');
                  var springleaderchatter = springarr[0];
                  var springgroupchatter =  springarr[1];
                 // print("mmm"+springleaderchatter.toString()+" "+springgroupchatter.toString());
                  //[Spring up, O well!, The well the princes dug, The nobles opened with their staffs] [, Sing to it!, Spring up, O well!, Sing to it!]
                  OPENWORLD.Mob.setSpeech(womensgategroup[0],
                      springleaderchatter, z: 90,
                      width: 300,
                      clearwhendone: true,
                      minwait: 10,
                      scale: 0.5,
                      delay:2,
                      randwait: 0,
                    callbackonfinish: (actor) {*/
                      OPENWORLD.Mob.setSpeech(womensgategroup[0],
                        [ "Let me sing for my beloved",
                          "a song of my beloved’s vineyard.",
                          "My beloved had a vineyard",
                          "on a rich and fruitful hill.",
                          "He dug it and cleared it of stones,",
                          "and planted it with choice vines.",
                          "he built a watchtower in the middle of it,",
                          "and hewed out a wine vat in it.",

                          "He expected it to yield grapes,",
                          "but it yielded wild grapes.",

                          "And now, inhabitants of Jerusalem",
                          "and people of Judah,",
                          "judge between me and my vineyard.",

                          "What more was there to do for my vineyard",
                          "that I have not done in it?",
                          "When I expected it to yield grapes,",
                          "why did it yield wild grapes?",

                          "And now I will tell you",
                          "what I will do to my vineyard:",
                          "I will remove its hedge,",
                          "and it shall be devoured;",
                          "I will break down its wall,",
                          "and it shall be trampled down.",

                          "I will make it a waste;",
                          "it shall not be pruned or hoed,",
                          "and it shall be overgrown with briers and thorns;",
                          "I will also command the clouds",
                          "that they rain no rain upon it.",
                        ], z: 90,
                        width: 300,
                        clearwhendone: true,
                        minwait: 5,
                        scale: 0.7,
                        randwait: 0,
                        //  delay: 2,
                        delay: 2,
                        callbackonfinish: (actor){
                        },
                        tails: {
                          'bottomleft',
                          'bottomright',
                          'bottomcenter'
                        },
                      );
                    }
                  //  );


                  //  }

                );
              }
            };
          else if (j == 6)
            item['callback'] = (actor) {
              saveGameState('eastwest');
            };
          else if (j == 7) {
            item['callback'] = (actor) {

            };
          }
          else if (j == 8) {
            item['callback'] = (actor) {
              OPENWORLD.Space.objTurnLerp(threeJs.camera, 180, 1);
            };
          }
          poslist.add(item);
          if (j == 9) {
            var item = {
              "action": "idle",
              "time": 1,
              'callback': (actor) {
                //    var worldpos = OPENWORLD.You.getWorldPos();
                var lastposx = -25.54 +
                    0.15; //-28.4;//friendpathfishgate[friendpathfishgate.length-1];
                var lastposy = 31.08; //34.53; // lastpos[0],lastpos[1]
                var fct = 0.6; // so can fit through arch
                var posi = globpos(
                    lastposx, lastposy, 144, posfriend[0] * fct,
                    posfriend[1] * fct);
                OPENWORLD.Mob.moveTo(actor, [
                  //   [xpos, ypos, 0, horsespeed/2],
                  [posi[0], posi[1], 0, 0.1],
                ], action: "walk",
                    stopaction: "idle",
                    surfaceonly: true,
                    callbackonfinish: (actor) {
                      OPENWORLD.Space.faceObjectLerp(actor, threeJs.camera, 1);
                      if (actor == womensgategroup[2]) // Kid looks at mum
                        OPENWORLD.Space.faceObjectLerp(
                            actor, womensgategroup[1], 1, delay: 2);
                      else
                      if (actor == womensgategroup[1]) { // mum looks at dad
                        OPENWORLD.Space.faceObjectLerp(
                            actor, womensgategroup[0], 1, delay: 4);
                        OPENWORLD.Space.faceObjectLerp(
                            actor, threeJs.camera, 1, delay: 8);
                      }
                      if (actor == womensgategroup[0]) {
                        OPENWORLD.Mob.setSpeech(
                            womensgategroup[0], [
                          "Finally, fish gate.",
                          "Just a bit further",
                          "to Robinson's arch.",
                          "Lets go."],
                            //Spring up, O well'?"],
                            z: 100,
                            width: 400,
                            scale: 0.4,
                            randwait: 0,
                            minwait: 4,
                            delay: 1,
                            clearwhendone: true,
                            callbackonfinish: (actor) {
                              for (var j = 0; j <
                                  womensgategroup.length; j++) {
                                var poslist = getFriendToRobinsonsPos(j);
                                var friendpos = OPENWORLD.Space
                                    .localToWorldObj(
                                    womensgategroup[j]);
                                poslist.insert(0, {
                                  "p": [
                                    friendpos.x,
                                    friendpos.y,
                                    0
                                  ],
                                  "v": 0.02
                                });
                                OPENWORLD.Mob.moveToLoop(
                                    womensgategroup[j],
                                    //  [
                                    poslist,
                                    //   {"p":[xpos, ypos, 0], "v":horsespeed/2},
                                    //   {"p":[walktox,walktoy,0],"v":horsespeed/2}//-24.26, 111.83, 0], "v":horsespeed}
                                    //  ],
                                    looptype: OPENWORLD.Mob
                                        .LoopTypeStop,
                                    //.LoopTypeReverseLoop,
                                    surfaceonly: true,
                                    action: "walk");
                              }
                            }


                        );
                      }
                    },
                    delay: OPENWORLD.Math.random()
                );
              }
            };
            poslist.add(item); //, "t": 270, "duration": 2.0});

          }

          //  }
        }
        return poslist;
      }


      // Start of journey with banter with your friends
      friendreach(actor) {
        var worldpos = OPENWORLD.You.getWorldPos();
        print('friendreach callback');

        var friendposition = OPENWORLD.Space.localToWorldObj(actor);
        if (actor.extra['friend'] == 0 || actor.extra['friend'] == 1) {
          if (worldpos.y - friendposition.y > 0 &&
              worldpos.y - friendposition.y < 1.5) {
            OPENWORLD.Mob.setSpeech(actor,
              actor.extra['friend'] == 0
                  ? ["We're approaching the gate of the women"]
                  : ['Nearly there!',
              "After you gave birth to Leah",
                "I'm glad grandma could take care",
              "of her while you are purified",//of little Leah while",
               // "you purify yourself",
                "at the temple"// after the birth of Leah"//so you are no longer a yoledet "
              ]
            , z: 100,
                width: 300, /*scale:actor.extra['friend']==0?0.2:0.4,*/
                clearwhendone: true,
                minwait: 3,
                delay:actor.extra['friend'] * 4
//                delay: 2 + actor.extra['friend'] * 4
            );

            if (actor.extra['friend']==1) {
              // have lady turn round and look at you when talks about leah
              Future.delayed(
                  Duration(
                      milliseconds: 12000), () async {
                lookback(actor);

              });


            }
            if (friendposition.x < worldpos.x + 0.1) {
              OPENWORLD.Actor.playAction(
                  actor, action: "walkstraightlookleft",
                  //clampWhenFinished: true,
                  //  stopallactions: true,
                  delay: 0.1 + actor.extra['friend'] * 4);
              OPENWORLD.Space.objTurnLerp(
                  actor, 90, 1, delay: 0.1 + actor.extra['friend'] * 4);
            } else {
              OPENWORLD.Actor.playAction(
                  actor, action: "walkstraightlookright",
                  //clampWhenFinished: true,
                  //   stopallactions: true,
                  delay: 0.1 + actor.extra['friend'] * 4);
              OPENWORLD.Space.objTurnLerp(
                  actor, -90, 1, delay: 0.1 + actor.extra['friend'] * 4);
            }
            OPENWORLD.Actor.playAction(
                actor, action: "walk",
                //   clampWhenFinished: true,
                //  stopallactions: true,
                delay: 5 + actor.extra['friend'] * 4);
            OPENWORLD.Space.objTurnLerp(
                actor, 180, 1, delay: 5 + actor.extra['friend'] * 4);
            // have you look at your companion

            OPENWORLD.Space.facePointLerp(
                threeJs.camera, friendpath[friendpath.length - 1][0],
                friendpath[friendpath.length - 1][1], 1.0);
          }
        }
      }

      // Second lof of banter after starting the journey
      banter(actor) {
        if (actor.extra['friend'] == 0) {

          var chat = [
            {0: "We should check out the offerings at the gate"},
            {1: "Yes, but remember last time"},
            {1: "our dove had a mite"},
            {1: "I didnt spot it"},
            {0: "Yes, better double check"},
            {0: "Might be better to go to the Stoa"},
            {0: "rather than buy something we have to let free"},
            {1: "Yes"},
            {1: ""},
            {1: ""},
            {0: "Hope the pool of bethesda isnt too busy"},
            {1: "Might have to trek down to the pool of Siloam"},
            {0: "I hope not"},
          ];
          // have you look at your companion - would be nice

          var citizenmeetchatterarr = createChat(chat);
          var citizenmeetchatter = citizenmeetchatterarr[0];
          var citizenmeet2chatter = citizenmeetchatterarr[1];
          print("banter" + citizenmeetchatter.toString() + " " +
              citizenmeet2chatter.toString());
          //var delay=5.0;
          OPENWORLD.Mob.setSpeech(actor, citizenmeetchatter, z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
          );
          OPENWORLD.Mob.setSpeech(
              womensgategroup[1], citizenmeet2chatter, z: 130,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true);
          var worldpos = OPENWORLD.You.getWorldPos();
          var friendposition = OPENWORLD.Space.localToWorldObj(actor);
          if (friendposition.x < worldpos.x + 0.1) {
            OPENWORLD.Actor.playAction(
                actor, action: "walkstraightlookleft",
                //clampWhenFinished: true,
                //  stopallactions: true,
                delay: 1.0);
            OPENWORLD.Space.objTurnLerp(
                actor, 90, 1, delay: 1.0);
          } else {
            OPENWORLD.Actor.playAction(
                actor, action: "walkstraightlookright",
                //clampWhenFinished: true,
                //   stopallactions: true,
                delay: 1.0);
            OPENWORLD.Space.objTurnLerp(
                actor, -90, 1, delay: 1.0);
          }

          /* OPENWORLD.Actor.playAction(
            actor, action: "walkstraightlookright", //clampWhenFinished: true,
            //   stopallactions: true,
            delay: 1.0);
        OPENWORLD.Space.objTurnLerp(
            actor, -90, 1, delay: 1.0);*/
          OPENWORLD.Actor.playAction(
              actor, action: "walk",
              //   clampWhenFinished: true,
              //  stopallactions: true,
              delay: 3.0);
          OPENWORLD.Space.objTurnLerp(
              actor, 180, 1, delay: 3.0);
          OPENWORLD.Mob.setSpeech(
              actor, ["Could that be Moshe?", "It is", "Somethings up"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 100);
        }
      }


      // This is moshe
      var friend2posx = -22.05 + 0.05;
      var friend2posy = 99.6; //99.9;
      var friend2man = await OPENWORLD.Actor.copyActor(
          manlist[(numfriends + 8) % manlist.length], randomduration: 0.1,
          action: 'squatwork'); //, duration:2.5);//idle3');
      _hotload.add(friend2man);
      //-22.34, 101.01
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          friend2man, friend2posx, friend2posy, 0.0,
          3); //-22.05, 99.9, 0.0, 3); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
      OPENWORLD.Space.objTurn(friend2man, 45);

      var donkey = await OPENWORLD.Actor.copyActor(
          donkeypack, randomduration: 0.1); //, action:null);
      OPENWORLD.Space.objTurn(donkey, 180);

      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkey, friend2posx, friend2posy + 0.07, 0.0,
          6); //-22.05, 99.9+0.05,0.0,6);//-22.31, 101.01 -25.49, 116.86,0,6);//12.67, 5.22, 0, 6); // 9.8,1.1, 0.14,3); //3.42);
      _hotload.add(donkey);

      // Third part after starting journey where you see your friend moshe whos donkey has a stone in its foot
      friend2(actor) {
        horseriding = false;
        womensgategroup[0].extra.remove('followingfriend');
        if (actor.extra['friend'] == 0) {
          print('at friend 2');

          //  OPENWORLD.You.drag=0.2;
          OPENWORLD.Space.facePointLerp(
              threeJs.camera, friend2posx, friend2posy, 1.0, delay: 0.5);
          //    OPENWORLD.Space.objTurnLerp(threeJs.camera,250,1.0);
          //   OPENWORLD.Space.faceObject(threeJs.camera, donkey);
          //var time=OPENWORLD.Mob.moveTo(actor, [[ friend2posx+0.095,friend2posy,0,0.05]],action:"walk", stopaction:"idle", delay:0.5);
          var time = 1.0;
          //   OPENWORLD.Space.worldToLocalSurfaceObjLerp(actor, friend2posx+0.095,friend2posy,0,3.0,delay:0.5);//-22.05+0.095, 99.9, 0.0, 1.0,delay:0.5);
          OPENWORLD.Space.faceObjectLerp(actor, friend2man, 1.0, delay: time);
          OPENWORLD.Actor.playActionThen(
              actor, "point", "idle", delay: 1.0 + time);
          OPENWORLD.Actor.playAction(
              friend2man, action: "idle", delay: 2 + time);
          OPENWORLD.Space.faceObjectLerp(
              friend2man, actor, 1.0, delay: 3 + time);

          var chat = [{0: "Shalom Moshe"},
            {1: "Joshua, Shalom."},
            {0: "Good to see you"},
            {0: "Need some help?"},
            {1: "No, my donkey has a stone in its hoof"},
            {1: "Nearly got it out"},
            {0: "Good to hear"},
            {0: "We're going to the temple."},
            {0: "We'll see you there"},
            {1: "See you there for sure."},
            {0: "Shalom"},
            {1: "Shalom"}
          ];

          var citizenmeetchatterarr = createChat(chat);
          var citizenmeetchatter = citizenmeetchatterarr[0];
          var citizenmeet2chatter = citizenmeetchatterarr[1];
          double speechtime1 = OPENWORLD.Mob.setSpeech(
              actor, citizenmeetchatter, z: 100,
              width: 400,
              randwait: 0,
              clearwhendone: true,
              delay: 4 + time);
          double speechtime2 = OPENWORLD.Mob.setSpeech(
              friend2man, citizenmeet2chatter, z: 130,
              width: 400,
              randwait: 0,
              clearwhendone: true,
              delay: 4 + time);
          var speechtime = math.max(speechtime1, speechtime2);
          OPENWORLD.Actor.playActionThen(
              actor, "wave", "idle", delay: speechtime - 1.0);
          OPENWORLD.Actor.playActionThen(
              friend2man, "wave", "idle", delay: speechtime - 1.0); //+1);
          OPENWORLD.Actor.playActionThen(
              womensgategroup[2], "wave", "idle",
              delay: speechtime - 0.5); //+1.5);
          Future.delayed(
              Duration(
                  milliseconds: (1000 * (speechtime + 4)).round()), () async {
            womensgategroup[0].extra['followingfriend']=0;

            horseriding = true;
            // OPENWORLD.You.drag=1.0;
            OPENWORLD.Space.objTurnLerp(threeJs.camera, 166, 1.0);
            OPENWORLD.Actor.playAction(
                friend2man, action: "squatwork", delay: 1);
            OPENWORLD.Actor.playAction(actor, action: "walk", delay: 1);
            OPENWORLD.Actor.playAction(
                womensgategroup[2], action: "walk", delay: 2.0);
            OPENWORLD.Space.objTurnLerp(friend2man, 45, 1.0);
            //OPENWORLD.Persistence.set(gamestart.toString(),['moshe']);
            saveGameState('moshe');
          });
        }
        OPENWORLD.Space.facePointLerp(actor, friend2posx, friend2posy, 1.0,
            delay: 0.5 + OPENWORLD.Math.random() * 3);
      }

      // Next part of journey where kids being naughty
      kids(actor) {
        if (actor.extra['friend'] == 4) {
          OPENWORLD.Actor.playAction(actor, action: "walkup", delay: 2);
          // Spin girl
          for (var i = 0; i < 4; i++) {
            OPENWORLD.Space.objTurnLerp(actor, 0, 1, delay: 4 + i * 4);
            OPENWORLD.Space.objTurnLerp(actor, -90, 1, delay: 5 + i * 4);
            OPENWORLD.Space.objTurnLerp(actor, 166, 1, delay: 6 + i * 4);
          }
          OPENWORLD.Mob.setSpeech(womensgategroup[1], [
            "Stop it Sarah!",
            "I don't want to have to carry you" /*,"if you fall over"*/
          ], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 16);
          OPENWORLD.Mob.setSpeech(actor, ["Yes, mum"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 20);
          OPENWORLD.Actor.playAction(actor, action: "walk", delay: 21);

          /*   OPENWORLD.Space.objTurnLerp(actor,0,1,delay:7);
        OPENWORLD.Space.objTurnLerp(actor,-90,1,delay:8);
        OPENWORLD.Space.objTurnLerp(actor,166,1,delay:9);*/


        } else if (actor.extra['friend'] == 3) {
          OPENWORLD.Mob.setSpeech(actor, ["Are we there yet?"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 34 + 4);
          OPENWORLD.Mob.setSpeech(womensgategroup[1], ["Nearly there"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 37 + 4);

          OPENWORLD.Mob.setSpeech(actor, ["Are we there yet?"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 34 + 38);
          OPENWORLD.Mob.setSpeech(womensgategroup[1], ["Oh, be quiet"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 37 + 38);
        } else if (actor.extra['friend'] == 2) {
          OPENWORLD.Mob.setSpeech(actor, ["Mum, Im hungry"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 34 + 18);
          OPENWORLD.Mob.setSpeech(
              womensgategroup[0], ["Hi Hungry. Im Joshua"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 37 + 18);
          OPENWORLD.Mob.setSpeech(
              womensgategroup[1], ["Haha. Well eat something at the pool"],
              z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: 40 + 18);
        }
      }

      // Next sing a psalm
      psalm2(actor) {
        psalm(actor, againy: 39,first:false); //37);
      }


      /*  Old code to make the journey speed up so not as boring - instead added a psalm
      speedup(actor) {
      if (actor.extra['friend'] == 0) {
        var worldpos = OPENWORLD.You.getWorldPos();
        print('speedup callback');

        var friendposition = OPENWORLD.Space.localToWorldObj(actor);

        if (worldpos.y - friendposition.y > 0 &&
            worldpos.y - friendposition.y < 1.5) {
          OPENWORLD.Mob.setSpeech(actor, ["Lets skip ahead"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true);
          Future.delayed(
              Duration(
                  milliseconds: 1000), () async {
            speedUp(30.0);
            OPENWORLD.Space.facePoint(threeJs.camera, -13.76, 63.31);
            Future.delayed(
                Duration(
                    milliseconds: 4000), () async {
              speedUp(0.0);
            });
          });
        }
      }
    }*/

      // Where approaching the womens gate and the sellers at the gate
      approachgatebanter(actor) {
        if (actor.extra['friend'] == 0) {
          var time = OPENWORLD.Mob.setSpeech(
            actor, [
            "Looks like theyre selling offerings",
            "We should take a look",
            "Might be something good"
          ], z: 100,
            width: 400,
            scale: 0.4,
            randwait: 0,
            clearwhendone: true,
          );
          OPENWORLD.Mob.setSpeech(
              womensgategroup[1], ["Yes", "Better be careful though"], z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              delay: time,
              callbackonfinish: (actor) {
                saveGameState('approachinggate');
              });
        }
      }

      // At the bird seller at the womens gate
      birds(actor) {
        if (actor.extra['friend'] == 0) {
          print('at birds');
          horseriding = false;
          //  OPENWORLD.You.drag=0.2;
         // OPENWORLD.Space.facePointLerp(
         //     threeJs.camera, birdsellerposx, birdsellerposy, 1.0, delay: 0.5);
          // Place camera so can see daughter speaking
          OPENWORLD.Space.worldToLocalSurfaceObjLerp(threeJs.camera, -14.41, 64.85+0.02,//-14.41, 64.86,
              OPENWORLD.Camera.cameraoffset,1.0);
          OPENWORLD.Space.objTurnLerp(threeJs.camera,167,1);
          var time = 1.0;
          OPENWORLD.Space.faceObjectLerp(actor, birdseller, 1.0, delay: time);
          OPENWORLD.Actor.playActionThen(
              actor, "wave", "idle", delay: 1.0 + time);
          OPENWORLD.Actor.playAction(birdseller, clampWhenFinished: true,
              action: "idle",
              delay: 2 + time);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              birdseller, birdsellerposx, birdsellerposy, 0.00,
              4); //delay:2+time);

          OPENWORLD.Space.faceObjectLerp(
              birdseller, actor, 1.0, delay: 3 + time);

          var chat = [{0: "Shalom"},
            {0: "How much are the doves?"},
            {1: "15 small coins"},
            {0: "I'll take a look at them"},
            {1: "Sure take your time"},
          ];

          var citizenmeetchatterarr = createChat(chat);
          var citizenmeetchatter = citizenmeetchatterarr[0];
          var citizenmeet2chatter = citizenmeetchatterarr[1];
          double speechtime1 = OPENWORLD.Mob.setSpeech(
              actor, citizenmeetchatter, z: 100,
              width: 400,
              randwait: 0,
              clearwhendone: true,
              delay: 4 + time);
          double speechtime2 = OPENWORLD.Mob.setSpeech(
              birdseller, citizenmeet2chatter, z: 130,
              width: 400,
              randwait: 0,
              clearwhendone: true,
              delay: 4 + time);
          var speechtime = math.max(speechtime1, speechtime2);
          //  OPENWORLD.Mob.moveTo(actor, [[  -14.43, 64.70,0,0.05]],action:"walk", stopaction:"squatwork", delay:speechtime);
          //  OPENWORLD.Actor.playAction(birdseller, action: "idle", delay: speechtime+5);
          //  OPENWORLD.Space.faceObjectLerp(actor, birdseller, 1.0, delay: speechtime+6);
          OPENWORLD.Space.objTurnLerp(actor, -45, 1.0, delay: speechtime - 2);
          OPENWORLD.Actor.playAction(actor, clampWhenFinished: true,
              action: "squatwork",
              delay: speechtime - 2);


          OPENWORLD.Mob.setSpeech(
              actor, ['I dont like the look of this claw', '', 'No, sorry'],
              z: 100,
              width: 400,
              randwait: 0,
              clearwhendone: true,
              delay: speechtime + 7);
          OPENWORLD.Mob.setSpeech(
              birdseller, ["I'll sell it for 10", "Thats the best I can do"],
              z: 130,
              width: 400,
              randwait: 0,
              clearwhendone: true,
              delay: speechtime + 10);


          Future.delayed(
              Duration(
                  milliseconds: (1000 * (speechtime + 42)).round()), () async {
            horseriding = true;
            // OPENWORLD.You.drag=1.0;
            // OPENWORLD.Space.objTurnLerp(threeJs.camera, 166, 1.0);
            print("dirrrr " + friendpath[8].toString() + " " +
                friendpath.toString());
            OPENWORLD.Space.facePointLerp(
                threeJs.camera, friendpath[8][0], friendpath[8][1], 1.0);
            OPENWORLD.Actor.playAction(
                birdseller, action: "sittableidle", delay: 1);
            OPENWORLD.Actor.playAction(actor, action: "walk");
            //  OPENWORLD.Actor.playAction( womensgategroup[2], action: "walk", delay: 2.0);
            OPENWORLD.Space.objTurnLerp(
                birdseller, OPENWORLD.Mob.getInitTurn(birdseller), 1.0);
          });
        }
        if (actor.extra['friend'] != 4)
          OPENWORLD.Space.facePointLerp(
              actor, birdsellerposx, birdsellerposy, 1.0,
              delay: 0.5 + OPENWORLD.Math.random() * 3);
        else {
          OPENWORLD.Space.faceObjectLerp(
              actor, foodseller, 1.0, delay: 0.5 + OPENWORLD.Math.random() * 3);
          OPENWORLD.Mob.setSpeech(
              actor, ['Mum, can I have some figs?', '', 'Mum, please!'], z: 100,
              width: 400,
              randwait: 0,
              clearwhendone: true,
              delay: 45);
          OPENWORLD.Space.faceObjectLerp(
              actor, womensgategroup[1], 1.0, delay: 45);
          OPENWORLD.Mob.setSpeech(
              womensgategroup[1], ["No, not now.", "After we bathe"], z: 130,
              width: 400,
              randwait: 0,
              clearwhendone: true,
              delay: 48);
          OPENWORLD.Space.faceObjectLerp(
              womensgategroup[1], actor, 1.0, delay: 47);
          OPENWORLD.Space.faceObjectLerp(
              womensgategroup[0], actor, 1.0, delay: 50);
          OPENWORLD.Actor.playAction(
              womensgategroup[0], clampWhenFinished: true,
              action: "idle",
              delay: 50);
        }
      }

      var soldier2ii = await OPENWORLD.Actor.copyActor(
          soldier2, randomduration: 0.1,
          action: "idlehold"); //, action:"idlehold");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          soldier2ii, -13.95, 63.21, 0,
          3); //, lerpopacity: 1);//-14.12, 63.32,0,3);//-14.18, 63.44,0,3);// -14.08, 64.13,0,3);//-13.51, 64.25, 0.0, 3); //3.42);
      _hotload.add(soldier2ii);

      // Like one of your friend knows one of the guards and wave to him
      gate(actor) {
        if (actor.extra['friend'] == 0) {
          OPENWORLD.Space.faceObjectLerp(actor, soldier2ii, 1);
          OPENWORLD.Actor.playActionThen(
              actor, "wave", "walk", delay: 1.0);
          OPENWORLD.Space.faceObjectLerp(soldier2ii, actor, 1, delay: 1);
          OPENWORLD.Actor.playActionThen(
              soldier2ii, "wave", "idlehold", delay: 2.0);
          OPENWORLD.Space.objTurnLerp(actor, 166, 1.0, delay: 2.0);
          OPENWORLD.Space.objTurnLerp(soldier2ii, 0, 1.0, delay: 2.0);
          saveGameState('pastgate');
        }
      }

      // Banter when getting close to the pool of bethseda
      approachbethesdabanter(actor) {
        if (actor.extra['friend'] == 0) {
          OPENWORLD.Mob.setSpeech(
              actor, ["We're getting close",
            "to the pool of bethesda.",
            "Lets tie your donkey",
            "up at the stables",
            "then we'll go to the pool"],
              z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              clearwhendone: true,
              callbackonfinish: (actor) {
                saveGameState('pastgate4');
              }
          );
          lookback(actor);

        }
      }

      // Get off your donkey at pool of bethseda and tie it at the stable
      stables(actor) {
        // Force stop all starting at the same time with the idle3
        OPENWORLD.Actor.playAction( actor, action: "idle",delay:OPENWORLD.Math.random()*2,startat: OPENWORLD.Math.random());
        OPENWORLD.Space.faceObjectLerp(
            actor, threeJs.camera, 1.0, delay: OPENWORLD.Math.random());
        if (actor.extra['friend'] == 0) {
          print('at stables');
          saveGameState('stables');
          horseriding = false;
          OPENWORLD.Mob.setSpeech(
              actor, ["We'll wait for you while",
            "you tie your donkey."],
              z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              minwait: 4,
              clearwhendone: true,
              callbackonfinish: (actor) {
                OPENWORLD.Mob.moveTo(threeJs.camera,
                    [[4.22, 22.36, OPENWORLD.Camera.cameraoffset, 0.1]],
                    callbackonfinish: (actor) {
                      horseriding = true;
                      dismount();
                      Glob.hasstabled=true;
                      OPENWORLD.Mob.moveTo(threeJs.camera,
                          [
                            [
                              3.55 + 0.15,
                              21.8,
                              OPENWORLD.Camera.cameraoffset,
                              0.1
                            ]
                          ],
                          delay: 4,
                          callbackonfinish: (actor) {
                            OPENWORLD.Space.objTurnLerp(threeJs.camera, 166, 1);
                            for (var friend in womensgategroup) {
                              OPENWORLD.Space.faceObjectLerp(
                                  friend, threeJs.camera, 1.0,
                                  delay: OPENWORLD.Math.random());
                            }
                            OPENWORLD.Mob.setSpeech(
                                womensgategroup[0], ["Lets go to the baths"],
                                z: 100,
                                width: 400,
                                scale: 0.4,
                                randwait: 0,
                                delay: 1,
                                minwait: 4,
                                clearwhendone: true
                            );
                            womensgategroup[0].extra['followingfriend'] = 0;
                          }
                      );
                    }
                );
              }
          );
        }
      }

      // Enter the pool of bethseda and bathe with your friend
      pool(actor) {
        OPENWORLD.Space.faceObjectLerp(
            actor, threeJs.camera, 1.0, delay: OPENWORLD.Math.random() * 2);
        actor.extra['origpos'] = OPENWORLD.Space.localToWorldObj(actor);
        //  OPENWORLD.Actor.playAction( actor,
        //       action: "idle3",delay:OPENWORLD.Math.random()*2,startat: OPENWORLD.Math.random());
        if (actor.extra['friend'] == 0) {
          print('at pool');
          saveGameState('bethesda');
          OPENWORLD.Mob.setSpeech(
              actor, ["I'll go to the mens section"],
              z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              delay: 1,
              minwait: 4,
              clearwhendone: true,
              callbackonfinish: (actor) {
                womensgategroup[0].extra['followingfriend'] = 1;
                OPENWORLD.Mob.moveTo(womensgategroup[0], [
                  //   [xpos, ypos, 0, horsespeed/2],
                  [6.95, 15.37, 0, 0.04],
                ], action: "walk",
                    stopaction: "idle",
                    surfaceonly: true,
                    delay: 1 + OPENWORLD.Math.random() * 2

                );
                OPENWORLD.Mob.moveTo(womensgategroup[1], [
                  //   [xpos, ypos, 0, horsespeed/2],
                  [6.95, 16.38 + 0.1, 0, 0.04],  // edge of pool
                ], action: "walk",
                    stopaction: "idle",
                    surfaceonly: true,
                    delay: 1 + OPENWORLD.Math.random() * 2,
                    callbackonfinish: (actor) {
                      womensgategroup[0].extra.remove('followingfriend');
                      var origpos = THREE.Vector3(6.95, 16.59,0.0);
                      OPENWORLD.Mob.moveTo(threeJs.camera,
                          [[origpos.x,origpos.y, OPENWORLD.Camera.cameraoffset, 0.1]],
//                          [[ 6.95, 16.59, OPENWORLD.Camera.cameraoffset, 0.1]],
                          callbackonfinish: (actor) {
                            OPENWORLD.Space.faceObjectLerp(
                                womensgategroup[1], threeJs.camera, 1.0);
                            OPENWORLD.Space.faceObjectLerp(
                                threeJs.camera, womensgategroup[1], 1.0);
                            OPENWORLD.Space.objTurnLerp(
                                threeJs.camera, 90 + 55, 1.0, delay: 4);

                            OPENWORLD.Space.objTurnLerp(
                                womensgategroup[1], 90, 1.0, delay: 2);
                            Future.delayed(
                                Duration(milliseconds: 4000), () async {
                              var friendposition = OPENWORLD.Space.localToWorldObj(womensgategroup[1]);
                              //OPENWORLD.You.getWorldPos();

                              List<Map> actions = [
                                {
                                  "p": [friendposition.x, friendposition.y, 0],
                                  "v": 0.02
                                },
                                //   {"p":[posx+0.1,posy,0],"v":0.02},
                                {"action": "armsup", "time": 1.0,},  // clothes off
                                {"action": "hitup", "time": 1.0,},
                                {"action": "armsup", "time": 1.0,},
                                {
                                  "action": "hitup",
                                  "time": 1.0,
                                  'callback': (actor) {
                                    OPENWORLD.BaseObject.setVisible(
                                        actor, false,
                                        groupname: "citizen_1"); // no shoes
                                    OPENWORLD.BaseObject.setVisible(
                                        actor, false,
                                        groupname: "citizen_2"); // no clothes

                                    OPENWORLD.Mob.moveTo(threeJs.camera, [
                                      //   [xpos, ypos, 0, horsespeed/2],
                                      [
                                        origpos.x + 0.2,
                                        origpos.y,
                                        OPENWORLD.Camera.cameraoffset,
                                        0.04
                                      ],
                                    ],
                                        surfaceonly: true,
                                        callbackonfinish: (actor) {
                                          OPENWORLD.Space.objTurnLerp(
                                              threeJs.camera, 90 + 55, 1);
                                          // Bob you up and down
                                          var worldpos = OPENWORLD.You
                                              .getWorldPos();
                                          for (var i = 0; i < 5; i++) {
                                            playSplash(delay:i*6);

                                            OPENWORLD.Space
                                                .worldToLocalSurfaceObjLerp(
                                                threeJs.camera,
                                                worldpos.x + 0.005,
                                                worldpos.y,
                                                OPENWORLD.Camera.cameraoffset *
                                                    0.85,
                                                0.5, delay: i * 6);
                                            OPENWORLD.Space
                                                .worldToLocalSurfaceObjLerp(
                                                threeJs.camera, worldpos.x,
                                                worldpos.y,
                                                OPENWORLD.Camera.cameraoffset,
                                                0.5,
                                                delay: 2 + i * 6);
                                          }
                                        }
                                    );
                                    // clothespileii.visible = true; // show the clothes on the ground
                                  },
                                },
                                {
                                  "p": [
                                    friendposition.x + 0.2,   // in the water
                                    friendposition.y,
                                    0
                                  ],
                                  "v": 0.02, "callback": (actor) {
                                    playSplash();

                                }
                                },

                              ];
                              for (var j = 0; j < 10; j++) {
                                Map action = {
                                  "action": bathingactions[j %
                                      bathingactions.length]
                                };
                                //  if (j % batheractionlist.length == 0)
                                //    action['t'] = OPENWORLD.Math.randFloatSpread(40);
                                if (j == 9)
                                  action["callback"] = (actor) {
                                    OPENWORLD.Mob.moveTo(threeJs.camera, [
                                      //   [xpos, ypos, 0, horsespeed/2],
                                      [
                                        origpos.x,
                                        origpos.y,
                                        OPENWORLD.Camera.cameraoffset,
                                        0.04
                                      ],
                                    ],
                                        surfaceonly: true,
                                        callbackonfinish: (actor) {
                                          OPENWORLD.Space.objTurnLerp(
                                              threeJs.camera, 213,
                                              1); //180+45,1);
                                          //  OPENWORLD.Space.faceObjectLerp(threeJs.camera, womensgategroup[1], 1);
                                        }
                                    );
                                  };
                                actions.add(action);
                              }
                              actions.add({"p": [
                                friendposition.x,
                                friendposition.y,
                                0
                              ], "v": 0.02,
                              });
                              actions.add({"action": "armsup", "time": 1.0,});
                              actions.add(
                                  {
                                    "action": "hitup",
                                    "time": 1.0,
                                    'callback': (actor) {
                                      OPENWORLD.BaseObject.setVisible(
                                          actor, true,
                                          groupname: "citizen_1"); // no shoes
                                      OPENWORLD.BaseObject.setVisible(
                                          actor, true,
                                          groupname: "citizen_2"); // no clothes
                                      OPENWORLD.Space.faceObjectLerp(
                                          womensgategroup[1], threeJs.camera,
                                          1);
                                    }
                                  });
                              actions.add(
                                  {
                                    "action": "idle3",
                                    "time": 4.0,
                                    "callback": (actor) {
                                      womensgategroup[0].extra['followingfriend'] = 1;  // follow lady
                                      OPENWORLD.Space.objTurnLerp(
                                          threeJs.camera, 270 + 20, 1,
                                          delay: 2); //180+45,1);
                                      //OPENWORLD.Space.faceObjectLerp(threeJs.camera, womensgategroup[1], 1);
                                      OPENWORLD.Mob.setSpeech(
                                          actor, ["We are purified now."],//I feel purified now."],
                                          z: 80,
                                          width: 400,
                                          scale: 0.4,
                                          randwait: 0,
                                          minwait: 4,
                                          clearwhendone: true);


                                      for (var friend in womensgategroup) {
                                        OPENWORLD.Mob.moveTo(friend, [
                                          //   [xpos, ypos, 0, horsespeed/2],
                                          [
                                            friend.extra['origpos'].x,
                                            friend.extra['origpos'].y,
                                            0,
                                            actor == womensgategroup[0]
                                                ? 0.07
                                                : 0.04
                                          ],
                                        ], action: "walk",
                                            stopaction: "idle3",
                                            surfaceonly: true,
                                            callbackonfinish: (actor) {
                                              OPENWORLD.Space.faceObjectLerp(
                                                  actor, threeJs.camera, 1);
                                              if (actor != womensgategroup[0] &&
                                                  actor != womensgategroup[1]) {
                                                OPENWORLD.Space.faceObjectLerp(
                                                    actor, womensgategroup[1],
                                                    1,
                                                    delay: 2 +
                                                        OPENWORLD.Math
                                                            .random() *
                                                            2);
                                              } //else
                                              //  OPENWORLD.Space.faceObjectLerp(actor,threeJs.camera, 1);
                                              if (actor == womensgategroup[1]) {
                                                OPENWORLD.Space.objTurnLerp(
                                                    threeJs.camera, 282, 1);
                                                OPENWORLD.Mob.setSpeech(
                                                    actor,
                                                    ["We'll wait for Joshua",
                                                      "and the children.",
                                                    "They're coming."],
                                                    z: 100,
                                                    width: 400,
                                                    scale: 0.4,
                                                    randwait: 0,
                                                    minwait: 4,
                                                    clearwhendone: true);
                                              } else
                                              if (actor == womensgategroup[0]) {
                                                womensgategroup[0].extra['followingfriend'] = 0;  // follow man again

                                                OPENWORLD.Mob.setSpeech(
                                                    actor, ["Lets go.",
                                                  "We should go up to the",
                                                  "fish gate"],
                                                    z: 100,
                                                    width: 400,
                                                    scale: 0.4,
                                                    randwait: 0,
                                                    minwait: 4,
                                                    clearwhendone: true);
                                                for (var j = 0; j < womensgategroup.length; j++) {
                                                  var friend = womensgategroup[j];
                                                  //if (friend!= womensgategroup[0])
                                                  // OPENWORLD.Space.faceObjectLerp(
                                                  //       friend, womensgategroup[0], 1,delay:1+OPENWORLD.Math.random());
                                                  // Move everyone to there correct spot!
                                                  var posi = globpos(womensgategroup[0].extra['origpos'].x,
                                                      womensgategroup[0].extra['origpos'].y,
                                                      360 - 45,
                                                      friendrellist[j][0],
                                                      friendrellist[j][1]);
                                                  OPENWORLD.Mob.moveTo(friend, [
                                                    //   [xpos, ypos, 0, horsespeed/2],
                                                    [posi[0], posi[1], 0, 0.06],
                                                  ], action: "walk",
                                                      stopaction: "idle3",
                                                      delay: 1 + OPENWORLD.Math.random(),
                                                      surfaceonly: true);
                                                }
                                                Future.delayed(
                                                    Duration(milliseconds: 12000), () async {
                                                  womensgategroup[0].extra['tofishgate'] = true;
                                                  for (var j = 0; j < womensgategroup.length; j++) {
                                                    var poslist = getFriendToFishgatePos(
                                                        j);
                                                    var friendpos = OPENWORLD.Space.localToWorldObj(womensgategroup[j]);
                                                    poslist.insert(0, {
                                                      "p": [
                                                        friendpos.x,
                                                        friendpos.y,
                                                        0
                                                      ],
                                                      "v": 0.02
                                                    });
                                                    OPENWORLD.Mob.moveToLoop(
                                                        womensgategroup[j],
                                                        //  [
                                                        poslist,
                                                        //   {"p":[xpos, ypos, 0], "v":horsespeed/2},
                                                        //   {"p":[walktox,walktoy,0],"v":horsespeed/2}//-24.26, 111.83, 0], "v":horsespeed}
                                                        //  ],
                                                        looptype: OPENWORLD.Mob
                                                            .LoopTypeStop,
                                                        //.LoopTypeReverseLoop,
                                                        surfaceonly: true,
                                                        action: "walk");
                                                  }
                                                });
                                              }
                                            }

                                          // delay:1+OPENWORLD.Math.random()*2

                                        );
                                      }
                                    }
                                  }); //, "t": 90});

                              OPENWORLD.Mob.moveToLoop(
                                womensgategroup[1],
                                actions,
                                //index:k==0?0:5,
                                surfaceonly: true,
                                hidedist: 3,
                                looptype: OPENWORLD.Mob.LoopTypeStop,
                                action: "walk",

                              );
                            });
                          });
                    }
                );
                for (var i = 2; i < womensgategroup.length; i++) {
                  OPENWORLD.Mob.moveTo(womensgategroup[i], [
                    //   [xpos, ypos, 0, horsespeed/2],
                    [6.57, 15.87 - i * 0.1, 0, 0.04],
                  ], action: "walk",
                      stopaction: "idle",
                      surfaceonly: true,
                      delay: 1 + OPENWORLD.Math.random() * 2
                  );
                }
              }
          );

          OPENWORLD.Mob.setSpeech(
              womensgategroup[1], ["Let's go"],
              z: 100,
              width: 400,
              scale: 0.4,
              randwait: 0,
              minwait: 4,
              delay: 7,
              clearwhendone: true
          );
        }
      }


      // For a friend in  womensgategroup, get its positions so that can put in movetoloop - is based upon the current position of the friend
      // This is from start of journey to the north all the way to the pool of bethseda
      getFriendToBathsPos(i) {
        List<Map> poslist = [];
        if (OPENWORLD.System.loaded && womensgategroup.length <= i)
          return poslist;
        var posfriend = friendrellist[i]; // This is the releative position of this friend

        // Add the first position which will be 0.2 ahead of the players start pos
        print("is loading" + OPENWORLD.System.loaded.toString() + " " + i.toString());
        THREE.Vector3 startpos;
        var firstpos;
        //var startfacingangle;
        if (OPENWORLD.System.loaded) {
          startpos = OPENWORLD.Space.localToWorldObj(womensgategroup[i]);
          firstpos = [
            startpos.x,
            startpos.y
          ];
          //  startfacingangle=OPENWORLD.Space.getObjTurn(womensgategroup[i]);
        } else {
          // ! loaded
          startpos = THREE.Vector3(
              0.0, 0.0, 0.0);
          Map dict = getusedict(); //gamestartpos[gamestart];
          if (dict.containsKey('p')) {
            List posi = dict['p'];
            if (posi != null && posi.length >= 2) {
              startpos = THREE.Vector3(
                  posi[0], posi![1], 0.0);
              //gamestartpos[gamestart]!['p']?[0].toDouble(),
              //  gamestartpos[gamestart]!['p']?[1].toDouble(), 0.0);
              firstpos = [
                startpos.x + 0.1,
                startpos.y - 0.2
              ];
            }
            // if (dict.containsKey('turn'))
            //    startfacingangle=dict['turn'];
            //  else
            //    startfacingangle=166;

          }
        }
        //  var facingnorth=startfacingangle>270||startfacingangle<90;
        var foundind = -1;
        /*if (facingnorth&&startpos.y<19) {
        // case where have reached pool of bethesda and now heading north
        foundind = 21;
      } else {*/
        for (var j = 0; j < friendpath.length; j++) { //pos in friendpos)
          var pos = friendpath[j];

          if (pos[1] < startpos.y - posfriend[1] && foundind == -1)
            foundind = j;
        }
        // }
        var facingangle = OPENWORLD.Math.getAngleBetweenPoints(startpos,
            THREE.Vector3(friendpath[foundind][0], friendpath[foundind][1], 0));
//      print('xxxfacingangle'+facingangle.toString());
        var posi = globpos(
            firstpos[0], firstpos[1], facingangle, posfriend[0], posfriend[1]);
        poslist.add({
          "p": [posi[0], posi[1], 0],
//        "p": [firstpos[0] + posfriend[0], firstpos[1] - posfriend[1], 0],
          "v": horsespeed / 2,
          //"callback": friendreach
        });
        // for (var posfriend in friendrellist)
        // For this friend in  womensgategroup add all his walking positions relative to the group

        for (var j = foundind; j < friendpath.length; j++) { //pos in friendpos)
          var pos = friendpath[j];
          //  if (pos[1] <
          //      startpos.y - posfriend[1]) { // gamestartpos[gamestart]![1]) {
          var item;
          if (j == 3 && i == 0) {
            // set pos to near friend2
            item =
            {"p": [friend2posx + 0.095, friend2posy, 0], "v": horsespeed / 2};
          } else if (j == 7) {
            // Set pos everyone around the birdseller
            var posx;
            var posy;
            if (i == 0) {
              posx = birdsellerposx + 0.095;
              posy = birdsellerposy;
            } else if (i == 1) {
              posx = birdsellerposx + 0.095;
              posy = birdsellerposy + 0.095;
            } else if (i == 2) {
              posx = birdsellerposx + 0.095;
              posy = birdsellerposy - 0.095;
            } else if (i == 3) {
              posx = birdsellerposx + 0.12;
              posy = birdsellerposy;
            } else if (i == 4) {
              // by chance must join up with family because exactly correct distance away
              posx = -13.82 + 0.05;
              posy = 64.12;
            }
            /*else {
              posx=pos[0] + posfriend[0];
              posy=pos[1] - posfriend[1];
            }*/

            item = {"p": [posx, posy, 0], "v": horsespeed / 2};
          } else {
            var fct;
            if (j >= 8)
              fct =
              0.4; // so that when go through the gate everyone moves closer together
            else
              fct = 1.0;
            var xdiff;
            if (j < 8)
              xdiff = 0.05;
            else if (j == 11)
              xdiff = 0.35;
            else
              xdiff = 0.15;
            var facingangle;
            if (j < friendpath.length - 1)
              facingangle = OPENWORLD.Math.getAngleBetweenPoints(
                  THREE.Vector3(friendpath[j][0], friendpath[j][1], 0),
                  THREE.Vector3(friendpath[j + 1][0], friendpath[j + 1][1], 0));
            else
              facingangle = OPENWORLD.Math.getAngleBetweenPoints(
                  THREE.Vector3(friendpath[j - 1][0], friendpath[j - 1][1], 0),
                  THREE.Vector3(friendpath[j][0], friendpath[j][1], 0));
            //   print("uuufacingangle"+facingangle.toString());
            var posi = globpos(
                pos[0], pos[1], facingangle, (posfriend[0] + xdiff) * fct,
                posfriend[1]);

            item = {
              "p": [posi[0], posi[1], 0],
//              "p": [pos[0] + (posfriend[0]+xdiff)*fct, pos[1] - posfriend[1], 0],
              "v": horsespeed / 2,
              //"callback": friendreach
            };
          }
          if (j == 1)
            item['callback'] = friendreach;
          else if (j == 2)
            item['callback'] = banter;
          else if (j == 3) {
            item['callback'] = friend2;
          } else if (j == 4) {
            item['callback'] = kids;
          } else if (j == 5) {
            item['callback'] = psalm; //speedup;
          } else if (j == 6) {
            item['callback'] = approachgatebanter;
          } else if (j == 7) {
            item['callback'] = birds;
          } else if (j == 8) {
            item['callback'] = gate;
          } else if (j == 10) { //>8) {
            item['callback'] = psalm2; //turn;
          } else if (j == 13) {
            item['callback'] = (actor) {
              saveGameState('pastgate2');
            };
          } else if (j == 14) {
            item['callback'] = (actor) {
              saveGameState('pastgate3');
            };
          } else if (j == 15) { //>8) {
            item['callback'] = approachbethesdabanter;
          } else if (j == 17) {
            item['callback'] = stables;
          } else if (j == 20) {
            item['callback'] = pool;
          }
          poslist.add(item);
          if (j == 3) {
            /*  if (i == 0)
              poslist.add(
                  {"p":[friend2posx+0.095,friend2posy,0],"v":0.05});//"action": "point", "time": 20, "t": 270, "duration": 2.0});
          */ //else*

            poslist.add(
                {
                  "action": "idle",
                  "time": 60 - 8
                }); //, "t": 270, "duration": 2.0});
          } else if (j == 7) {
            // birds
            poslist.add(
                {
                  "action": "idle",
                  "time": 65
                }); //, "t": 270, "duration": 2.0});

          } else if (j == 17) {
            // stables
            poslist.add(
                {
                  "action": "idle3",
                  "randomduration": 0.1,
                  "startat": OPENWORLD.Math.random(),
                  "time": 35
                }); //, "t": 270, "duration": 2.0});
          } else if (j == 20) {
            // stables
            poslist.add(
                {
                  "action": "idle",
                  "randomduration": 0.1,
                  //"startat":OPENWORLD.Math.random(),
                  "time": 65
                }); //, "t": 270, "duration": 2.0});

          }
          //  }
        }
       // print("friendpath path for friend "+i.toString()+" "+poslist.toString());
        return poslist;
      }

      // The four paths your journey takes
      var friendpaths = [
        friendpath,  // north start of journey to pool of bethseda
        friendpathfishgate,  // then to fishgate
        friendpathrobinsons,  // then to robinsons gate
        friendpathtemple  // then to the temple
      ];

      // Based upon where you are work out which path you are on
      getClosestPath({worldpos}) {
        Map dict = getusedict(); //gamestartpos[gamestart];
        if (worldpos==null)
         worldpos= OPENWORLD.You.getWorldPos();
        var closestind = -1;
        var closestdist = 99999.0;
        for (var i = 0; i < friendpaths.length; i++) {
          for (var pos in friendpaths[i]) {
            var dist;
            if (!OPENWORLD.System.loaded)
              dist = OPENWORLD.Math.vectorDistance(
                  THREE.Vector3(dict['p'][0], dict['p'][1], 0),
                  THREE.Vector3(pos[0], pos[1], 0.0));
            else
              dist = OPENWORLD.Math.vectorDistance(
                  worldpos, THREE.Vector3(pos[0], pos[1], 0.0));
            if (dist < closestdist) {
              closestind = i;
              closestdist = dist;
            }
          }
        }
        return closestind;
      }

      // Of the womensgate paths and the players current position work out which path they should be on
      // Given where you are return the movetoloop actions for that part of the journey
      getFriendPos(i) {
        Map dict = getusedict(); //gamestartpos[gamestart];

        // Closestind is the index to the closest path
        var closestind = getClosestPath();

        var poslist;
        if (closestind == 3) {
          poslist = getFriendToTemplePos(i);
          print("friend pos wait got temple");
        } else if (closestind == 2) {
          poslist = getFriendToRobinsonsPos(i);
          print("friend pos wait got robinsons"+poslist.toString());
        } else
        if ((dict.containsKey('t') && (dict['t'] > 270 || dict['t'] < 90)) ||
            (womensgategroup.length > 0 &&
                womensgategroup[0].extra.containsKey('tofishgate') &&
                womensgategroup[0].extra['tofishgate'])) {
          poslist = getFriendToFishgatePos(i);
          print("friend pos wait got fishgate");
        } else {
          poslist = getFriendToBathsPos(i);
          print("friend pos wait got baths");
        }
        return poslist;
      }


      if (gamestart == GameStart.womensgate) {
        // Actual start of game where create your friends and their movetoloops so they start walking
        print("begin womensgate");
        for (var i = 0; i < numfriends; i++) {
          var actor;
          if (i == 0)
            actor = citizen32;
          else if (i == 1)
            actor = citizenf34;
          else if (i == 2)
            actor = childlist[i % childlist.length];
          else if (i == 4)
            actor = girllist[i % girllist.length];
          else
            actor = childlist[i % childlist.length];
          // for (var actor in uselist) {
          //   if (inc<numcourt)
          var childgirlii = await OPENWORLD.Actor.copyActor(
              actor, randomduration: 0.1, action: 'idle');//walk'); //idle3');
          // actor, randomduration: 0.1, action: i%2==0? 'idle3':'prostrate',startat:OPENWORLD.Math.random());
          _hotload.add(childgirlii);
          childgirlii.extra['friend'] = i;
          // var y=ylist[i];//OPENWORLD.Math.random()*dist;//OPENWORLD.Math.randFloatSpread(dist);//3);
          // if y is 1.5 then width is 0.25
          // if y is -1.5 then width is 1
          //   var width= (y-dist/2)/dist+0.25;
          // 0.1 is a fudge because the road is angled - otherwise all people will be to your right
          // var xpos=-25.51 + xspread+0.1;//width);
          // var ypos= 117.12 - y-0.2;

          //  print("mmm"+xpos.toString());
          //  OPENWORLD.Space.worldToLocalSurfaceObjHide(childgirlii, xpos,ypos, 0, 3); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);


          List<Map> poslist = getFriendPos(i);
          var level;
          if (poslist[0].containsKey('l'))
            level = poslist[0]['l'];
          else
            level = 0;
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              childgirlii, poslist[0]['p'][0], poslist[0]['p'][1], 0, 3,
              level: level);

          callwhenloaded(() {
            OPENWORLD.Mob.moveToLoop(
                childgirlii,
                //  [
                poslist,
                //   {"p":[xpos, ypos, 0], "v":horsespeed/2},
                //   {"p":[walktox,walktoy,0],"v":horsespeed/2}//-24.26, 111.83, 0], "v":horsespeed}
                //  ],
                looptype: OPENWORLD.Mob.LoopTypeStop, //.LoopTypeReverseLoop,
                surfaceonly: true,
                action: "walk");
          }
          );


          // This section is to see if you are away from your friends
          // Deal with you leaving your friends
          // You try again here in 15 seconds
          if (i == 0) {
            OPENWORLD.Mob.setName(childgirlii, "person");
            OPENWORLD.BaseObject.setDistanceTrigger(
                childgirlii, dist: 1.5, event: (action) {
              if (action) {
                print("inside friend ");
              } else {
                // You are away from your friends
                print(
                    "outside friend" +
                        OPENWORLD.Mob.getName(womensgategroup[0]));
                var closestind = getClosestPath(worldpos:OPENWORLD.Space.localToWorldObj(womensgategroup[0]));
                // Awful fudge because you have it that when reach robinsons arch go up the stairs you have a seperate moveto for your friends therefore you cannot stop on the stairs
                // Stops checking for stopping if on the stairs
                if (!(OPENWORLD.You.level == 1 &&
                    friendpaths[closestind] == friendpathrobinsons)) {
                // womensgategroup[0].extra['outsidefriend']=true;
                  for (var j = 0; j < womensgategroup.length; j++) {
                    var delay = OPENWORLD.Math.random() * 3;
                    Future.delayed(
                        Duration(milliseconds: (delay * 1000).round()), () async {
                      OPENWORLD.BaseObject.clearAll(
                          womensgategroup[j]); //childgirlii);  // so forgets previous movetoloop
                      var friendpos = OPENWORLD.Space.localToWorldObj(
                          womensgategroup[j]);
                      // !! why must I do this
                      OPENWORLD.Space.worldToLocalSurfaceObj(
                          womensgategroup[j],
                          friendpos.x, //worldpos.x,
                          friendpos.y, // worldpos.y + 0.52,
                          level: OPENWORLD.You.level,
                          -0.002);

                      OPENWORLD.Actor.playAction(womensgategroup[j],
                          action: "idle");
                      OPENWORLD.Space.faceObjectAlways(
                          womensgategroup[j], threeJs.camera);
                      // OPENWORLD.Space.f.faceObjectLerp(
                      //     womensgategroup[j], threeJs.camera, 1.0, delay:delay);
                      //  j is your friend number
                      if (j == 0) {
                        OPENWORLD.Mob.setSpeech(womensgategroup[j], [
                          !hasmissed
                              ? 'Where are you going?'
                              : 'Whats up with you?',
                          //  'Are you coming with us?',
                          // 'We should get going'
                        ], z: 100, width: 300, clearwhendone: true, delay: 1);
                      } else if (j == 1) {
                        OPENWORLD.Mob.setSpeech(womensgategroup[j], [
                          !hasmissed
                              ? 'Are you coming with us?'
                              : 'Again? Keep up',
                          'We should get going'
                        ], z: 100, width: 300, clearwhendone: true, delay: 1);
                      } else if (j == 2) {
                        OPENWORLD.Mob.setSpeech(womensgategroup[j], [
                          !hasmissed ? 'Lets go!' : "We can't keep stopping"
                        ], z: 100, width: 300, delay: 2);
                      }
                      if (j == 2) {
                        // This is where you restart is again if move back in
                        var donemove = false;
                        OPENWORLD.BaseObject.setDistanceTrigger(
                            womensgategroup[j], dist: 0.7, event: (action) {
                          if (action && !donemove) {
                            donemove = true;

                            OPENWORLD.Mob.clearText(womensgategroup[2]);
                            //    womensgategroup[0].extra.remove('outsidefriend');
                            for (var jj = 0; jj < numfriends; jj++) {
                              OPENWORLD.Space.removeFaceObjectAlways(
                                  womensgategroup[jj]);

                              print("inside friendii so startup again");
                              var poslist = getFriendPos(jj);

                              var friendpos = OPENWORLD.Space.localToWorldObj(
                                  womensgategroup[jj]);
                              poslist.insert(0, {
                                "p": [friendpos.x, friendpos.y, 0],
                                "v": 0.02,
                                "l": OPENWORLD.You.level,
                              });
                              poslist.insert(1, {
                                "action": "idle",
                                "callback": (actor) {
                                  donemove = false;
                                },
                              });
                              OPENWORLD.Mob.moveToLoop(
                                  womensgategroup[jj],
                                  //  [
                                  poslist,
                                  //   {"p":[xpos, ypos, 0], "v":horsespeed/2},
                                  //   {"p":[walktox,walktoy,0],"v":horsespeed/2}//-24.26, 111.83, 0], "v":horsespeed}
                                  //  ],
                                  looptype: OPENWORLD.Mob.LoopTypeStop,
                                  //.LoopTypeReverseLoop,
                                  surfaceonly: true,
                                  action: "walk");
                            }
                          } else {

                          }
                        });
                      }

                    });

                  }
                  //childgirlii

                }
              }
            });
          }
          // This is part of i<numfriends where actually creating womensgategroup
          womensgategroup.add(childgirlii);
        }

        // Follow the man initially with your donkey
        womensgategroup[0].extra['followingfriend'] = 0;
        var closestind = getClosestPath();
        var worldpos = OPENWORLD.You.getWorldPos();
        // If past the stoa the the woman should be wielding a bird
        if (closestind >= 0 && friendpaths[closestind] == friendpathtemple &&
            worldpos.y > -10.95)
          wielddove();
        //  });
      }

      if (OPENWORLD.Time.isDay(OPENWORLD.Time.time)) {
        // Looks like people sitting on your right as you start womensgate
        // Southern most
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  adultlist[numfriends]),
              'p': [-25.76 + 0.25, 116.54 - 1.0, -0.03],
              //   'l': i==0?1:0,
              't': 90, //OPENWORLD.Math.random() * 360, //270,
              "action": 'sittableleft',
              "duration": 2.5,
              'randomduration': 0.1,
              //  'startat': OPENWORLD.Math.random(),
              //  'label': 'courtwomen',
              "lerpopacity": 1,
              "callbackonvisible":(actor) {

                  OPENWORLD.BaseObject.setDistanceTrigger(
                      actor, dist: 0.2, event: (action) {
                    if (action) {
                      OPENWORLD.Mob.setSpeech(
                        actor,
                        ["Shalom"],
                        z: 100,
                        width: 300,
                        clearwhendone: true,
                        minwait: 6,
                        scale: 0.4,
                        randwait: 0,
                      );

                    } else {

                    }
                  });
              },
              "callbackonhide":(actor) {
                OPENWORLD.BaseObject.removeDistanceTrigger(actor);

              }
            });


        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  adultlist[numfriends + 3]),
              'p': [-25.77 + 0.25, 116.61 - 1.0, -0.03],
              //   'l': i==0?1:0,
              't': 90, //OPENWORLD.Math.random() * 360, //270,
              "action": 'sittableleft',
              "duration": 2.5,
              'randomduration': 0.1,
              //  'startat': OPENWORLD.Math.random(),
              //  'label': 'courtwomen',
              "lerpopacity": 1
            });

        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  adultlist[numfriends + 2]),
              'p': [-25.78 + 0.25, 116.65 - 1.0, -0.03],
              //   'l': i==0?1:0,
              't': 90, //OPENWORLD.Math.random() * 360, //270,
              "action": 'sittableright',
              "duration": 2.5,
              'randomduration': 0.1,
              //'startat': OPENWORLD.Math.random(),
              //  'label': 'courtwomen',
              "lerpopacity": 1
            });



        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  adultlist[numfriends + 1]),
              'p': [-25.78 + 0.25, 116.73 - 1.0, 0],
              //   'l': i==0?1:0,
              't': 90, //OPENWORLD.Math.random() * 360, //270,
              "action": 'sitidle',
              "duration": 2.5,
              'randomduration': 0.1,
              'startat': OPENWORLD.Math.random(),
              //  'label': 'courtwomen',
              "lerpopacity": 1
            });
        /*var childgirliii = await OPENWORLD.Actor.copyActor(
        actorlist[numfriends+1], randomduration: 0.1, action:  'sitidle');
    _hotload.add(childgirliii);
   // OPENWORLD.Space.worldToLocalSurfaceObjHide(childgirliii,-25.73, 116.73, -0.01, 3); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(childgirliii,-25.78+0.25, 116.73-1.0, 0, 3, lerpopacity: 1.0); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
    OPENWORLD.Space.objTurn(childgirliii,90);*/


        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  actorlist[numfriends + 4]),
              //citizen3),
              'p': [-23.78, 111.32, -0.03],
              't': -90,
              "action": 'sittableidle',
              "duration": 2.5,
              'randomduration': 0.1,
              "lerpopacity": 1,
              "callbackonvisible": (actor) {
                OPENWORLD.BaseObject.setDistanceTrigger(
                    actor, dist: 1.0, event: (action) {
                  if (action) {
                    OPENWORLD.Mob.setSpeech(actor, [
                      'Shalom',
                    ], z: 100, width: 300, clearwhendone: true);
                    OPENWORLD.Actor.playActionThen(
                        actor, "sittablewave", "sittableidle", duration: 5);
                    OPENWORLD.Space.objTurnLerp(
                        womensgategroup[2], 90 + 45, 1, delay: 1);
                    OPENWORLD.Space.objTurnLerp(
                        womensgategroup[2], 180, 1, delay: 4);
                    OPENWORLD.Mob.setSpeech(womensgategroup[2], [
                      'Shalom',
                    ], z: 100, width: 300, clearwhendone: true, delay: 1.5);
                    OPENWORLD.Actor.playActionThen(
                        womensgategroup[2], "wave", "walk", duration: 1,
                        delay: 1.5);
                  } else {

                  }
                });
              },
              "callbackonhide": (actor) {
                OPENWORLD.BaseObject.removeDistanceTrigger(actor);
                // OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
              }
            });


        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  actorlist[numfriends + 5]),
              'p': [-23.77, 111.24, -0.02, 0],
              't': -90, //OPENWORLD.Math.random() * 360, //270,
              "action": 'sittableidle',
              "duration": 2.5,
              'randomduration': 0.1,
              "lerpopacity": 1
            });
        /* var childgirlvii = await OPENWORLD.Actor.copyActor(
        actorlist[numfriends+5], randomduration: 0.1, action:  'sittableidle', duration:2.5);//idle3');
    _hotload.add(childgirlvii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(childgirlvii,-23.77, 111.24, -0.02, 3,lerpopacity: 1); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
    OPENWORLD.Space.objTurn(childgirlvii,-90);*/

        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  actorlist[numfriends + 6]),
              'p': [-23.76, 111.2, -0.03, 0],
              't': -90, //OPENWORLD.Math.random() * 360, //270,
              "action": 'sittableidle',
              "duration": 2.5,
              'randomduration': 0.1,
              "lerpopacity": 1
            });
        /* var childgirlviii = await OPENWORLD.Actor.copyActor(
        actorlist[numfriends+6], randomduration: 0.1, action:  'sittableidle', duration:2.5);//idle3');
    _hotload.add(childgirlviii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(childgirlviii,-23.76, 111.2, -0.03, 3,lerpopacity: 1); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
    OPENWORLD.Space.objTurn(childgirlviii,-90);*/

        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  actorlist[numfriends + 7]),
              'p': [-23.79, 111.29, 0.0],
              't': -90, //OPENWORLD.Math.random() * 360, //270,
              "action": 'sitidle',
              "duration": 2.5,
              'randomduration': 0.1,
              "lerpopacity": 1
            });
      }
    }

    // Tombs around the north
    var tomb = await OPENWORLD.Model.createModel(
        'assets/models/tomb.glb'); //,texture:"assets/detailmap.png");
    _hotload.add(tomb);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb, -29.1, 105.6, -0.07, 6); // 3.2,2.5, 0.0);
    tomb.scale.setValues(0.1, 0.1, 0.1);
    OPENWORLD.Space.objTurn(tomb, 100);

    var tomb12 = tomb.clone(); //,texture:"assets/detailmap.png");
    _hotload.add(tomb12);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb12, -17.49, 108.9, -0.07, 6); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tomb12, 70);

    var tomb3 = tomb.clone(); //,texture:"assets/detailmap.png");
    _hotload.add(tomb3);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb3, -8.60, 79.90, -0.07, 6, lerpopacity: 1); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tomb3, 70);

    var tomb4 = tomb.clone(); //,texture:"assets/detailmap.png");
    _hotload.add(tomb4);
    // hotloadAdd(firsthotload, false, rock);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tomb4, -25.32, 79.35, -0.07, 6, lerpopacity: 1); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tomb4, 100);


    // People working around the north
    OPENWORLD.Config
        .config['positions']['poolpositions'][1]['positions'].add(
        {
          'name': OPENWORLD.Config.getObjectName(citizen2),
          //citizen3),
          'p': [-29.21, 116.31, 0],
          't': 180,
          "action": 'shovel',
          //  "duration":2.5,
          'randomduration': 0.1,
          "lerpopacity": 1,
          "callbackonvisible": (actor) {
            var pitchfork5 = pitchfork.clone();
            OPENWORLD.Space.setTurnPitchRoll(pitchfork5.children[0], 90, 0, 0);
            OPENWORLD.Actor.wield(actor, pitchfork5, "Bip01_L_Hand");
          },
          "callbackonhide": (actor) {
            OPENWORLD.Actor.unwield(actor, "Bip01_L_Hand");
          }
        });
    /*  var citizen2v = await OPENWORLD.Actor.copyActor(
        citizen2, action: "shovel");
    hotloadAdd(firsthotload, false, citizen2v);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizen2v, -29.21, 116.31, 0,
        2,lerpopacity: 1); //centerx+(-17.27-centerx)*0.5, centery+(-45.26-centery)*0.5,0.0);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
    OPENWORLD.Space.objTurn(citizen2v, 180);
    var pitchfork5=pitchfork.clone();
    OPENWORLD.Space.setTurnPitchRoll(pitchfork5.children[0], 90, 0, 0);
    OPENWORLD.Actor.wield(citizen2v, pitchfork5, "Bip01_L_Hand");*/

    OPENWORLD.Config
        .config['positions']['poolpositions'][1]['positions'].add(
        {
          'name': OPENWORLD.Config.getObjectName(citizen22),
          //citizen3),
          'p': [ -28.92, 116.44, 0],
          't': 180,
          "action": 'shovel',
          //  "duration":2.5,
          'randomduration': 0.1,
          "lerpopacity": 1,
          "callbackonvisible": (actor) {
            var pitchfork5 = pitchfork.clone();
            OPENWORLD.Space.setTurnPitchRoll(pitchfork5.children[0], 90, 0, 0);
            OPENWORLD.Actor.wield(actor, pitchfork5, "Bip01_L_Hand");

            OPENWORLD.BaseObject.setDistanceTrigger(
                actor, dist: 1.0, event: (action) {
              if (action) {
                //OPENWORLD.Space.faceObjectAlways(citizen22iv, threeJs.camera);
                OPENWORLD.Space.faceObjectAlways(actor, threeJs.camera);
                OPENWORLD.Actor.playAction(actor, action: "idle");
                OPENWORLD.Actor.playActionThen(actor, "wave", "idle", delay: 2);
                OPENWORLD.Mob.setSpeech(actor, [
                  'Hey, what you doing here?',
                  'Are you visiting a tomb?' //Whos tomb are you going to?'
                ], z: 100, width: 300, clearwhendone: true, delay: 4);
                //  OPENWORLD.Mob.startChatter(actor);
              } else {
                // OPENWORLD.Mob.pauseChatter(actor);
                // OPENWORLD.Mob.clearText(actor);
                OPENWORLD.Space.removeFaceObjectAlways(actor);
                OPENWORLD.Space.objTurnLerp(
                    actor, OPENWORLD.Mob.getInitTurn(actor), 1);
                OPENWORLD.Actor.playAction(actor, action: "shovel", delay: 2);
              }
            });
          },
          "callbackonhide": (actor) {
            OPENWORLD.BaseObject.removeDistanceTrigger(actor);
            OPENWORLD.Actor.unwield(actor, "Bip01_L_Hand");
          }
        });

    var sheepx = -28.92 + 0.5;
    var sheepy = 116.44 - 1.0;
    for (var i = 0; i < 3; i++) {
      var sheep = await OPENWORLD.Actor.copyActor(sheeporig);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep,
          sheepx + OPENWORLD.Math.randFloatSpread(1.0),

          ///5 * (OPENWORLD.Math.random() - 0.5),
          sheepy + OPENWORLD.Math.randFloatSpread(1.0),
          //5 * (OPENWORLD.Math.random() - 0.5),
          0, 5, lerpopacity: 1);
      OPENWORLD.Space.objTurn(sheep.children[0], 180);
      //  OPENWORLD.Space.objTurn(crab  ,90);  //e
      _hotload.add(sheep);
      // addnpc(sheep, "sheep", true, deathsoundpath: "sounds/bah.mp3");
      OPENWORLD.BaseObject.setDistanceTrigger(sheep, dist: 5, event: (action) {
        if (action) {
          if (OPENWORLD.Math.random() < 0.05)
            OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5);
          OPENWORLD.Mob.randomwalk(sheep, 1, 0.05, 0.3,
              action: "walk",
              actionduration: 1,
              stopaction: "idle",
              reset: true,
              surfaceonly: true
          );
        }
      });
    }

    // Field works around the north
    var fieldworkerposs = [
      [-20.97, 118.42],
      [-29.52, 112.26],
      [-18.04, 104.01],
      [-6.0 + 1.0, 78.5],
      [-28.0 - 1.0, 76.5]
    ];
    var inc = 0;
    for (var fieldworkerpos in fieldworkerposs) {
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(
                manlist[inc % manlist.length]),
            //citizen3),
            'p': [ fieldworkerpos[0], fieldworkerpos[1], 0],
            't': 180,
            "action": 'shovel',
            //  "duration":2.5,
            'randomduration': 0.1,
            "lerpopacity": 1,
            "callbackonvisible": (actor) {
              var pitchfork5 = pitchfork.clone();
              OPENWORLD.Space.setTurnPitchRoll(
                  pitchfork5.children[0], 90, 0, 0);
              OPENWORLD.Actor.wield(actor, pitchfork5, "Bip01_L_Hand");

              OPENWORLD.BaseObject.setDistanceTrigger(
                  actor, dist: 1.0, event: (action) async {
                if (action) {
                  //OPENWORLD.Space.faceObjectAlways(citizen22iv, threeJs.camera);
                  OPENWORLD.Space.faceObjectAlways(actor, threeJs.camera);
                  OPENWORLD.Actor.playAction(actor, action: "idle");
                  // OPENWORLD.Actor.playActionThen(citizen4ii, "point", "idle", delay:2);
                  OPENWORLD.Mob.setSpeech(actor, [
                    'Get out!',
                    'Your not supposed to be here'
                    //Whos tomb are you going to?'
                  ], z: 100,
                      width: 300,
                      clearwhendone: true,
                      minwait: 3,
                      randwait: 0,
                      delay: 4);
                  OPENWORLD.Mob.placeBeforeCamera(actor, 0.3, action: "walk",
                      stopaction: "idle",
                      time: 1,
                      delay: 5);
                  OPENWORLD.Mob.placeBeforeCamera(actor, 0.1, action: "walk",
                      stopaction: "idle",
                      time: 1,
                      delay: 10);
                  OPENWORLD.Actor.playActionThen(
                      actor, "push", "idle", delay: 12);
                  var worldpos = OPENWORLD.You.getWorldPos();

                  var mindist = 9999.0;
                  var minind = -1;
                  for (var i = 0; i < citizenpath.length; i++) {
                    var dist = OPENWORLD.Math.vectorDistance(THREE.Vector3(
                        citizenpath[i][0], citizenpath[i][1], 0.0),
                        THREE.Vector3(worldpos.x, worldpos.y, 0.0));
                    if (dist < mindist) {
                      mindist = dist;
                      minind = i;
                    }
                  }
                  OPENWORLD.Mob.moveTo(threeJs.camera,
                      [
                        [
                          citizenpath[minind][0],
                          citizenpath[minind][1],
                          OPENWORLD.Camera.cameraoffset,
                          0.8
                        ]
                      ],

                      ///]][[-25.41, 117.12,
                      delay: 15);
                  //  OPENWORLD.Mob.placeBeforeCamera(citizen4ii,  0.1,action:"walk",stopaction:"idle",time:1, delay:20);
                  //  OPENWORLD.Mob.moveTo(citizen4ii, [[-25.21, 117.12,0,0.4]], delay:15);
                  // OPENWORLD.Mob.moveTo(threeJs.camera, [[-25.41, 117.12,0,0.1]]);

                  var delay = await OPENWORLD.Mob.moveTo(
                      actor, [[fieldworkerpos[0], fieldworkerpos[1], 0, 0.4]],
                      delay: 16); //-20.97, 118.42, 0, 0.4]]);
                  OPENWORLD.Space.objTurnLerp(
                      actor, OPENWORLD.Mob.getInitTurn(actor), 1,
                      delay: delay);
                  OPENWORLD.Actor.playAction(
                      actor, action: "shovel", delay: delay + 1);

                  //  OPENWORLD.Mob.startChatter(actor);
                } else {
                  //var delay = await OPENWORLD.Mob.moveTo(
                  //    citizen4ii, );//-20.97, 118.42, 0, 0.4]]);
                  var delay = await OPENWORLD.Mob.moveTo(
                      actor, [
                    [fieldworkerpos[0], fieldworkerpos[1], 0, 0.4]
                  ]); //-20.97, 118.42, 0, 0.4]]);
                  OPENWORLD.Space.objTurnLerp(
                      actor, OPENWORLD.Mob.getInitTurn(actor), 1,
                      delay: delay);
                  OPENWORLD.Actor.playAction(
                      actor, action: "shovel", delay: delay + 1);


                  //  OPENWORLD.Space.faceObjectAlwaysRemove(citizen22iv);
                  //  OPENWORLD.Space.objTurnLerp(citizen22iv, OPENWORLD.Mob.getInitTurn(citizen22iv), 1);
                  //  OPENWORLD.Actor.playAction(citizen22iv,action:"shovel",delay:2);
                }
              });
            },
            "callbackonhide": (actor) {
              OPENWORLD.Actor.unwield(actor, "Bip01_L_Hand");
              OPENWORLD.BaseObject.removeDistanceTrigger(actor);
            }
          });

      inc++;
    }

    var goatx = -22.11;
    var goaty = 117.34;
    for (var i = 0; i < 3; i++) {
      var sheep = await OPENWORLD.Actor.copyActor(goat);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep,
          goatx + OPENWORLD.Math.randFloatSpread(1.0),

          ///5 * (OPENWORLD.Math.random() - 0.5),
          goaty + OPENWORLD.Math.randFloatSpread(1.0),
          //5 * (OPENWORLD.Math.random() - 0.5),
          0, 5);
      OPENWORLD.Space.objTurn(sheep.children[0], 180);
      //  OPENWORLD.Space.objTurn(crab  ,90);  //e
      _hotload.add(sheep);
      // addnpc(sheep, "sheep", true, deathsoundpath: "sounds/bah.mp3");
      OPENWORLD.BaseObject.setDistanceTrigger(sheep, dist: 5, event: (action) {
        if (action) {
          //if (OPENWORLD.Math.random() < 0.05)
          // OPENWORLD.Sound.play(path: 'sounds/bah.mp3', volume: 0.5);
          OPENWORLD.Mob.randomwalk(sheep, 1, 0.05, 0.3,
              action: "walk",
              actionduration: 1,
              stopaction: "idle",
              reset: true,
              surfaceonly: true
          );
        }
      });
    }
    //120 - 100 0
    //80 - 100  1
    //60 - 80 2
    // This is for the vegetation north of the third wall
    var spriteambiencecolor=null;
    if (!OPENWORLD.Time.isDay(OPENWORLD.Time.time)&&OPENWORLD.Time.ambience != null) {
      //spriteMaterial.color = THREE.Color.fromHex32(0x000000);//Time._ambience!.color as THREE.Color;
      spriteambiencecolor = OPENWORLD.Time.ambience!.color as THREE.Color;
      //  print("mmcol"+spriteMaterial.color.red.toString()+" "+spriteMaterial.color.green.toString()+" "+spriteMaterial.color.blue.toString());
    }

    for (var i = 0; i < 3; i++) {
      var grassi = Vegetation();

      var grassposx = -24.12 + i * 5; //-25.51;//2.3;//-2.5;
      //   var grasspos2x=-25.51-(boundarywidth2/2)-0.3;//2.3;//-2.5;
      var grassposy = 110.0 + 2 - i * 20; //117.12;  //121

      // var grassposx = -19.65+i*5;
      //var grassposy = 90.0 + 2-i*20;
      var boundarywidth2 = 20;
      var boundarylength2 = 20;

      var maxy = grassposy + boundarylength2 / 2;
      var miny = grassposy - boundarylength2 / 2;
      var diff = 1.0;
      List<List<double>> excludeSquares = [];
      for (var y = miny; y < maxy + 0.5; y += diff) {
        // Array format: [x, y]
        // print('yyyy'+y.toString()+' '+OPENWORLD.Math.interpolateX(y, citizenpath).toString()); // Output: 5.0
        excludeSquares.add(
            [OPENWORLD.Math.interpolateX(y, citizenpath), y, 0.6, diff]);
      }
      if (i == 2) {
        // food seller remove grass
        excludeSquares.add(
            [ -13.72, 64.06, 0.2, 0.2]);
      }
      var grassgroup = await grassi.createGrass(threeJs.camera,
          grassShadow: 0.2,
          boundaryWidth: boundarywidth2,
          boundaryLength: boundarylength2,
          color:spriteambiencecolor,
          edgeFalloff: 0,
          worldposx: grassposx,
          worldposy: grassposy,
          layerFadeAngle: 0.25,
          seed: 9999,
          surfaceTexture: !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?
            SurfaceTextureSpec(
              asset: 'assets/models/temple/detailmap.jpg',
              blendStrength: 0.25,
              tilingScale: 0.3, // texture repeats every 12 world metres
              edgeFade: 0.02
            //edgeFade: 0.25, // fades over the outer 25% of the boundary
          ):null,
          plants: [
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
                count: 50,
                width: 0.6 * 3,
                height: 0.6 * 3,
                billboard: 3,
                heightVariation: 0.3,
                widthVariation: 0.3,
                layers: 2,
                flipProbability: 0.5,
                planeSize: 100,
                edgeFadeWidth: 2,
                exclusionOffset: 0.1
              //   renderMode: PlantRenderMode.sprite,
            ),
            PlantSpec(
                spriteAsset: 'assets/textures/boxthorn.png',//models/temple/boxthorn.png',
                //shaders/grass2.png',
                count: 160,
                width: 2 * 9,
                height: 0.65 * 9,
                billboard: 3,
                heightVariation: 0.3,
                widthVariation: 0.3,
                layers: 6,
                flipProbability: 0.5,
                planeSize: 300,
                edgeFadeWidth: 5,
                pitchVariation: 0.0,
                //17
                useFootprintExclusion: true,
                exclusionOffset: 1.8,
                excludeSquares: i == 0 ? [[-28.95, 106.26, 0.6, 0.6], // tomb
                  [-29.21, 116.31, 1.5, 1.5],
                  [-20.97, 118.42, 1.2, 1.2],
                  [-30.86, 110.72, 1.0, 1.0], //house
                  [-16.82, 104.11, 1.0, 1.0] // house 2
                ] : i == 1 ? [[-7.62, 81.49, 1.0, 1.0]] :
                i == 2 ? [[-6.0, 78.5, 1.0, 1.0], //house
                  [-28.0, 76.5, 1.0, 1.0]] // house 2
                    : null,
                zOffset: -0.1

              // renderMode: PlantRenderMode.sprite,
            ),
            PlantSpec(
              spriteAsset: 'assets/models/temple/cyprus.png',
              //shaders/grass2.png',
              count: 40,
              width: 4,
              height: 12,
              billboard: 3,
              heightVariation: 0.3,
              widthVariation: 0.3,
              layers: 2,
              flipProbability: 0.5,
              planeSize: 300,
              edgeFadeWidth: 5,
              pitchVariation: 0.0,
              //17
              excludeSquares: i == 0
                  ? [[-28.95, 106.26, 0.6, 0.6]]
                  : null, //tomb
              //  exclusionOffset: 0.3
              // useFootprintExclusion: true,
              // zOffset: -0.1

              // renderMode: PlantRenderMode.sprite,
            )
          ],
          excludeSquares: excludeSquares,
          showHeightGrid: false,
          heightGridDivisions: 10,
          heightGridColor: 0xff6a00,
          heightGridOffset: 0.0,
          planeSize: 50);
      OPENWORLD.Space.worldToLocalSurfaceObjHide( //pitch            yaw
          grassgroup, grassposx, grassposy, 0.0,
          20); //-25.51, 117.12,0, 10);//,normalize2world:true);  //-1.8531121927940284 0.5194031433548219
      hotloadAdd(firsthotload, false, grassgroup);
      OPENWORLD.Updateables.add(grassi);
    }


    // Grass south of third wall
    for (var j = 0; j < 4; j++) {
      var grassi = Vegetation();
      var maxx, minx, maxy, miny;
      if (j == 0) {
        maxx = 1.5;
        minx = -20.5;
        maxy = 62.0;
        miny = 42.0;
      } else if (j==1) {
        maxx = 1.5;
        minx = -20.5;
        maxy = 42.0;
        miny = 25.0;
      } else if (j==2){
        maxx = -20.5;
        minx = -40.5;
        maxy = 42.0;
        miny = 25.0;

      } else {
        maxx = -6.0;
        minx = -26.0;
        maxy = 25.0;
        miny = 2.0;//10.0;

      }

//    var maxx=-5.5,  minx=-20.5, maxy=62.0, miny=32.0;//42.0;
      var boundarywidth2 = maxx - minx;
      var boundarylength2 = maxy - miny;

      var grassposx = (maxx + minx) / 2;
      var grassposy = (maxy + miny) / 2;

      /*  var grassposx=-13.0;//-24.12+3*5;//-25.51;//2.3;//-2.5;
    //   var grasspos2x=-25.51-(boundarywidth2/2)-0.3;//2.3;//-2.5;
    var grassposy=110.0+2-3*20;//52 117.12;  //121

    // var grassposx = -19.65+i*5;
    //var grassposy = 90.0 + 2-i*20;
    var boundarywidth2=15;
    var boundarylength2=20;

    var maxy = grassposy + boundarylength2 / 2;
    var miny = grassposy - boundarylength2 / 2;*/
      // Works assuming close to being northsouth
      var diff = 0.6;
      //var j1inc=0;
      List<List<double>> excludeSquares = [];
      for (var y = miny - 0.5; y < maxy + 0.5; y += diff) {

        var xdiff;
        if (y > 51.564 && y < 55.47)
          xdiff = 0.25;
        else if (y < 51.56 && y > 48.75)
          xdiff = 0.7;
        else
          xdiff = 0.5;

        var x=OPENWORLD.Math.interpolateX(y, friendpath);
        if (x>minx-0.5&&x<maxx+0.5) {
          excludeSquares.add(
              [x, y, xdiff, diff]);
         // if (j==1)
          //  print("bj1inc"+(j1inc++).toString());
        }
      }

      // For the east west road leading the typerion valley
      if (j==1||j==2||j==3) {
        var points=OPENWORLD.Math.interpolateByIncrement(friendpathfishgate,diff);
        for (var point in points) {
          var x=point[0];
          var y=point[1];
          if ((y>miny-0.5&&y<maxy+0.5&&(j==1||(j==2&&y>34)))&&x>minx-0.5&&x<maxx+0.5) {
            excludeSquares.add(
                [x, y, diff, 0.4]);
          ///  if (j==1)
           ///   print("cj1inc"+(j1inc++).toString());
          }
        }
        var points2=OPENWORLD.Math.interpolateByIncrement(citizenpath,diff);
        for (var point in points2) {
          var x=point[0];
          var y=point[1];
          if (y>miny-0.5&&y<maxy+0.5&&x>minx-0.5&&x<maxx+0.5) {
            excludeSquares.add(
                [x, y, diff,diff]);// 0.4]);
            ///  if (j==1)
            ///   print("cj1inc"+(j1inc++).toString());
          }
        }

      }


   //   print("mmmmexclude"+j.toString()+" "+excludeSquares.length.toString());
      List<PlantSpec> plants=[];
      if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time))
        plants = [
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

      ];
      // Area closer to pool of bethesda should have more plants
      if (j == 1)
        plants.add(PlantSpec(
            spriteAsset: 'assets/models/temple/figtree.png',
            //shaders/grass2.png',
            count: 50,
            width: 0.7 * 2,
            height: 0.7 * 2,
            billboard: 3,
            heightVariation: 0.3,
            widthVariation: 0.3,
            layers: 2,
            flipProbability: 0.5,
            planeSize: 100,
            exclusionOffset: 0.5
          //   renderMode: PlantRenderMode.sprite,
        ));
      var grassgroup = await grassi.createGrass(threeJs.camera,
          grassShadow: 0.2,
          color:spriteambiencecolor,
          boundaryWidth: boundarywidth2,
          boundaryLength: boundarylength2,
          edgeFalloff: 0,
          worldposx: grassposx,
          worldposy: grassposy,
          layerFadeAngle: 0.25,
          seed: 9999,
          surfaceTexture: SurfaceTextureSpec(
              asset: 'assets/models/temple/detailmap.jpg',
              blendStrength: 0.25,
              tilingScale: 0.3, // texture repeats every 12 world metres
              edgeFade: 0.02
            //edgeFade: 0.25, // fades over the outer 25% of the boundary
          ),
          plants: plants,
          excludeSquares: excludeSquares,
          showHeightGrid: false,
          heightGridDivisions: 10,
          heightGridColor: 0xff6a00,
          heightGridOffset: 0.0,
          planeSize: 50);

      OPENWORLD.Space.worldToLocalSurfaceObjHide( //pitch            yaw
          grassgroup, grassposx, grassposy, 0.0,
          20); //-25.51, 117.12,0, 10);//,normalize2world:true);  //-1.8531121927940284 0.5194031433548219
      hotloadAdd(firsthotload, false, grassgroup);
      OPENWORLD.Updateables.add(grassi);
    }


    /// !! is this needed??
    _hotload.add(threeJs.camera);

    // Soldiers at womensgate
    var soldier22ii = await OPENWORLD.Actor.copyActor(
        soldier22, randomduration: 0.1,
        //  texture:"assets/actors/soldier/head2.jpg",
        //   groupname:"soldier_3",
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier22ii, -13.95 - 0.1, 63.21, 0.0,
        3); //, lerpopacity: 1);//-14.12, 63.32,0,3);//-14.18, 63.44,0,3);// -14.08, 64.13,0,3);//-13.51, 64.25, 0.0, 3); //3.42);
    _hotload.add(soldier22ii);
    // OPENWORLD.Model.setTexture(soldier22, "assets/actors/soldier/head2.jpg",groupname:"soldier_3");

    // var spear4=spear.clone();
    //  OPENWORLD.Actor.wield(soldier2ii, spear4, "Bip01_R_Hand");

    var soldier23ii = await OPENWORLD.Actor.copyActor(
        soldier23, randomduration: 0.1,
        //    texture: "assets/actors/soldier/head3.jpg",
        //   groupname:"soldier_3",
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier23ii, -13.64, 63.28, 0,
        3,
        lerpopacity: 1); //-14.12, 63.32,0,3);//-14.18, 63.44,0,3);// -14.08, 64.13,0,3);//-13.51, 64.25, 0.0, 3); //3.42);
    _hotload.add(soldier23ii);
    //  var spear2=spear.clone();
    // OPENWORLD.Actor.wield(soldier3, spear2, "Bip01_R_Hand");
    // OPENWORLD.Model.setTexture(soldier23, "assets/actors/soldier/head3.jpg",groupname:"soldier_3");

    var soldier24ii = await OPENWORLD.Actor.copyActor(
        soldier24, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier24ii, -13.64 + 0.1, 63.28 + 0.1, 0,
        3,
        lerpopacity: 1); //-14.12, 63.32,0,3);//-14.18, 63.44,0,3);// -14.08, 64.13,0,3);//-13.51, 64.25, 0.0, 3); //3.42);
    _hotload.add(soldier24ii);
    //OPENWORLD.Model.setTexture(soldier24, "assets/actors/soldier/head4.jpg",groupname:"soldier_3");

    var soldier2iii = await OPENWORLD.Actor.copyActor(
        soldier2, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier2iii, -13.47, 63.0, 0.015, //-13.64, 62.71, 0,
        5, level: 1,
        lerpopacity: 1); //-14.12, 63.32,0,3);//-14.18, 63.44,0,3);// -14.08, 64.13,0,3);//-13.51, 64.25, 0.0, 3); //3.42);
    _hotload.add(soldier2iii);


    // The sellers as womensgate
    if (OPENWORLD.Time.isDay(OPENWORLD.Time.time)) {
      //  var birdcagegroup=THREE.Group();
      //  birdcagegroup.add(birdcageorig);
      // Why must I do this?
      OPENWORLD.Texture.setColor(
          birdcageorig, THREE.Color.fromHex32(0x000000), groupname: "base");
      OPENWORLD.Texture.setEmissive(
          birdcageorig, THREE.Color.fromHex32(0x000000), groupname: "base");

      var birdcagepigeon2 = birdcagepigeon
          .clone(); //birdcageorig.clone();//true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          birdcagepigeon2, -14.47, 64.57, 0.03,
          3, lerpopacity: 1);

      _hotload.add(birdcagepigeon2);
      // OPENWORLD.Mob.setInitTurn(pigeon2, OPENWORLD.Math.random()*360);

      var birdcagedove2 = birdcagedoves.clone(); //orig.clone();//true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          birdcagedove2, -14.47, 64.67, 0.03,
          3, lerpopacity: 1);
      /* var dove=await OPENWORLD.Model.copyModel(pigeon,texture:"assets/actors/dove.jpg");//pigeon.clone();
    OPENWORLD.Mob.setInitTurn(dove, OPENWORLD.Math.random()*360);
    birdcagedove.add(dove);*/
      _hotload.add(birdcagedove2);

      var birdcage4 = birdcageorig.clone(); //true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          birdcage4, -14.43, 64.64, 0.03,
          3, lerpopacity: 1);
      var dove2 = dove
          .clone(); //await OPENWORLD.Model.copyModel(pigeon,texture:"assets/actors/dove.jpg");//pigeon.clone();
      OPENWORLD.Mob.setInitTurn(dove2, OPENWORLD.Math.random() * 360);
      birdcage4.add(dove2);
      _hotload.add(birdcage4);

      var birdcage5 = birdcageorig.clone(); //true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          birdcage5, -14.52, 64.65, 0.03, //0.065,
          3, lerpopacity: 1);
      var pigeon3 = pigeon
          .clone(); //await OPENWORLD.Model.copyModel(pigeon,texture:"assets/actors/dove.jpg");//pigeon.clone();
      birdcage5.add(pigeon3);
      _hotload.add(birdcage5);
      OPENWORLD.Mob.setInitTurn(pigeon3, OPENWORLD.Math.random() * 360);

      var birds=[pigeon3,dove2];//,
      //  these birds are upside down for some reason
    //    OPENWORLD.BaseObject.getGroupByName(birdcagepigeon2,"pigeon"),
    ///    OPENWORLD.BaseObject.getGroupByName(birdcagedove2,"pigeon")];
   // groupname)birdcagepigeon2.children[0],birdcagedove2.children[0]];
      // Note this is inersecting with surface so shouldn't really be working
      // OPENWORLD.Mob.randomwalk(pigeon2, 0.02, 0.01, 0.1,z:-0.1);
      OPENWORLD.BaseObject.setDistanceTrigger(
          birdcagepigeon2, dist: 1.0, event: (action) {
        if (action) {
          var t = Timer.periodic(const Duration(seconds: 2), (timer) {
            //  OPENWORLD.Space.objPitch(pigeon2,OPENWORLD.Math.randFloatSpread(1.0));
            for (var bird in birds) {
              OPENWORLD.Space.objTurnLerp(bird,
                  OPENWORLD.Mob.getInitTurn(bird,def:0.0) +
                      OPENWORLD.Math.randFloatSpread(30), 1.0);

            }

            if (OPENWORLD.Math.random()<0.1)
              OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/pigeon.mp3','sounds/pigeon2.mp3']), volume: 0.2);
          });
          pigeon3.extra['pecktimer'] = t;
        } else {
          if (pigeon3.extra.containsKey('pecktimer')) {
            pigeon3.extra['pecktimer'].cancel();
            pigeon3.extra.remove('pecktimer');
          }
        }
      });


      //var cart2= await OPENWORLD.Model.createModel('assets/actors/cart.glb');//cart.clone();
      var cart2 = await OPENWORLD.Actor.copyActor(
          cart, action: "idle");
      OPENWORLD.BaseObject.setVisible(cart2, false, groupname: "figs");

      cart2.scale.setValues(0.015, 0.015, 0.015);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cart2, -14.67, 64.53, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(cart2);
//       OPENWORLD.Space.objPitch(cart2,20);
      var birdcage6 = birdcageorig.clone(); //true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          birdcage6, -14.67, 64.53, 0.075,
//        birdcage6, -14.67, 64.56,0.075,
          3, lerpopacity: 1);
      // var pigeon3=pigeon.clone();//await OPENWORLD.Model.copyModel(pigeon,texture:"assets/actors/dove.jpg");//pigeon.clone();
      // birdcage5.add(pigeon3);
      _hotload.add(birdcage6);
     // OPENWORLD.Space.objTurn(cart2, -90);
     // OPENWORLD.Space.objRoll(cart2,20);
      //OPENWORLD.Mob.setInitTurn(pigeon3, OPENWORLD.Math.random()*360);
      OPENWORLD.Space.setTurnPitchRoll(
          cart2, 90,0,-20);

      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(
                manlist[manlist.length - 2]),
            'p': [-14.44, 64.37, 0],
            //   'l': i==0?1:0,
            't': 90, //OPENWORLD.Math.random() * 360, //270,
            "action": 'idle3',
            //   "duration":2.5,
            'randomduration': 0.1,
            'startat': OPENWORLD.Math.random(),
            //  'label': 'courtwomen',
            "lerpopacity": 1
          });


      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(
                womanlist[womanlist.length - 2]),
            'p': [-14.44 + 0.1, 64.37, 0],
            //   'l': i==0?1:0,
            't': -90, //OPENWORLD.Math.random() * 360, //270,
            "action": 'idle3',
            //   "duration":2.5,
            'randomduration': 0.1,
            'startat': OPENWORLD.Math.random(),
            "lerpopacity": 1
          });
      /* var fruitbuyer2 = await OPENWORLD.Actor.copyActor(
        womanlist[womanlist.length-2], randomduration: 0.1,// duration:2.0,
        action: "idle3");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fruitbuyer2, -14.44+0.1, 64.37,0.00, 4, lerpopacity: 1);
    _hotload.add(fruitbuyer2);
    OPENWORLD.Space.objTurn(fruitbuyer2,-90);*/

      var basketwickerdeeppears2ii = basketwickerdeeppears.clone();
      // hotloadAdd(firsthotload, false, clotheshanging3);
      _hotload.add(basketwickerdeeppears2ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeeppears2ii, -14.40, 64.41, 0.00, 2, lerpopacity: 1.0);
      OPENWORLD.Space.objTurn(
          basketwickerdeeppears2ii, 180);

      var basketwickerdeepapples7ii = basketwickerdeepapples.clone();
      _hotload.add(basketwickerdeepapples7ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          basketwickerdeepapples7ii, -14.40, 64.35, 0.00, 2);
      OPENWORLD.Space.objTurn(
          basketwickerdeepapples7ii, 180);

      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(
                manlist[manlist.length - 3]),
            'p': [-13.65, 64.71, -0.01],
            //   'l': i==0?1:0,
            't': -90, //OPENWORLD.Math.random() * 360, //270,
            "action": "sittableidle",
            "duration": 2.5,
            'randomduration': 0.1,
            'startat': OPENWORLD.Math.random(),
            "lerpopacity": 1
          });
      var stool2 = stool.clone();
      _hotload.add(stool2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          stool2,-13.65, 64.71, 0, //-3.55, -12.63, 0,
          1.5); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
      OPENWORLD.Space.objTurn(stool2, 90);

      /* var hayseller = await OPENWORLD.Actor.copyActor(
        manlist[manlist.length-3], randomduration: 0.1, duration:2.0,
        action: "sittableidle");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hayseller,  -13.65, 64.71,0.00, 4, lerpopacity: 1);
    _hotload.add(hayseller);
    OPENWORLD.Space.objTurn(hayseller,-90);*/

      var donkey2 = await OPENWORLD.Actor.copyActor(
          donkeypack, randomduration: 0.1); //, action:null);
      OPENWORLD.Space.objTurn(donkey2, 180);

      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkey2, -13.65 + 0.1, 64.71, 0.00,
          6); //-22.05, 99.9+0.05,0.0,6);//-22.31, 101.01 -25.49, 116.86,0,6);//12.67, 5.22, 0, 6); // 9.8,1.1, 0.14,3); //3.42);
      _hotload.add(donkey2);

      OPENWORLD.BaseObject.setDistanceTrigger(
          donkey2, dist: 0.4, event: (action) {
        if (action ) {
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick([ 'sounds/donkey.mp3','sounds/donkey2.mp3']), volume: 0.5, delay:OPENWORLD.Math.random()*20);
        }
      });
      var pitchfork7 = pitchfork.clone();
      pitchfork7.children[0].scale.setValues(0.01, 0.01, 0.01);
      //   turn
      OPENWORLD.Space.setTurnPitchRoll(
          pitchfork7.children[0], 0, 90, 45 + 90 + 90);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pitchfork7, -13.65, 64.7, 0.07,
          2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(pitchfork7);


      for (var i = 0; i < 6; i++) {
        var hay3 = hay.clone();
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            hay3, -13.78 + OPENWORLD.Math.randFloatSpread(0.07),
            64.69 + OPENWORLD.Math.randFloatSpread(0.07), 0.0,
            2); // 3.2,2.5, 0.0);
        _hotload.add(hay3);
        OPENWORLD.Space.objTurn(hay3, OPENWORLD.Math.random() * 360);
        hay3.scale.setValues(0.03 * 0.5 + OPENWORLD.Math.random() * 0.02,
            0.03 * 0.5 + OPENWORLD.Math.random() * 0.02,
            0.03 * 0.5 + OPENWORLD.Math.random() * 0.02);
      }

      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(
                manlist[manlist.length - 4]),
            'p': [-13.68, 64.39, 0],
            //   'l': i==0?1:0,
            't': -90, //OPENWORLD.Math.random() * 360, //270,
            "action": "idle3",
            // "duration":2.5,
            'randomduration': 0.1,
            'startat': OPENWORLD.Math.random(),
            "lerpopacity": 1
          });
      /* var drinkseller = await OPENWORLD.Actor.copyActor(
        manlist[manlist.length-4], randomduration: 0.1,
        action: "idle3");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        drinkseller, -13.68, 64.39,0.00, 4, lerpopacity: 1);
    _hotload.add(drinkseller);
    OPENWORLD.Space.objTurn(drinkseller,-90);*/

      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(
                womanlist[womanlist.length - 1]),
            'p': [-13.68 - 0.1, 64.39, 0],
            //   'l': i==0?1:0,
            't': 90, //OPENWORLD.Math.random() * 360, //270,
            "action": "idle3",
            // "duration":2.5,
            'randomduration': 0.1,
            'startat': OPENWORLD.Math.random(),
            "lerpopacity": 1
          });

      /*   var drinkbuyer = await OPENWORLD.Actor.copyActor(
        womanlist[womanlist.length-1], randomduration: 0.1,
        action: "idle3");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        drinkbuyer, -13.68-0.1, 64.39,0.00, 4, lerpopacity: 1);
    _hotload.add(drinkbuyer);
    OPENWORLD.Space.objTurn(drinkbuyer,90);*/

      var jug7 = jug.clone();
      _hotload.add(jug7);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          jug7, -13.68, 64.39 + 0.05, 0.00, 2);
      OPENWORLD.Space.objTurn(
          jug7, 180);

      var pot15 = pot.clone();
      _hotload.add(pot15);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pot15, -13.68, 64.39 - 0.05, 0.00, 2);
      OPENWORLD.Space.objTurn(
          pot15, 180);

      var cup14 = cup.clone();
      _hotload.add(cup14);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cup14, -13.68 - 0.02, 64.39, 0.00, 2);
      OPENWORLD.Space.objTurn(
          cup14, 180);
      var cup15 = cup.clone();
      _hotload.add(cup15);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cup15, -13.68 - 0.02, 64.39 + 0.02, 0.00, 2);
      OPENWORLD.Space.objTurn(
          cup15, 180);

      var cart3 = await OPENWORLD.Actor.copyActor(
          cart,
          action: "idle"); //cart2.clone(true);//await OPENWORLD.Model.copyModel(cart2);
      // OPENWORLD.BaseObject.setVisible(cart3, true,groupname:"cartbone_skeleton");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cart3, -13.47, 64.35, 0.01, 2); // 3.2,2.5, 0.0);
      _hotload.add(cart3);


      var matiii = mati.clone();
      //_hotload.add(matii);
      hotloadAdd(firsthotload, false, matiii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          matiii, -13.66, 64.08, 0.00, 2);

      var board10 = board.clone();
      //  _hotload.add(board2);
      hotloadAdd(firsthotload, false, board10);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          board10, -13.68, 64.08, 0.005,
          2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
      board10.scale.setValues(0.006, 0.004, 0.004);

      _hotload.add(bread);
      // hotloadAdd(firsthotload, false, rock);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          bread, -13.69, 64.08, 0.01, 2); // 3.2,2.5, 0.0);
      OPENWORLD.Space.objTurn(bread, 0);
      var bread2 = breadleavened.clone();
      _hotload.add(bread2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          bread2, -13.69, 64.07, 0.005, 2); // 3.2,2.5, 0.0);
      var bread3 = breadleavened.clone();
      _hotload.add(bread3);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          bread3, -13.71, 64.075, 0.005, 2); // 3.2,2.5, 0.0);
      var jug8 = jug.clone();
      _hotload.add(jug8);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          jug8, -13.67, 64.14, 0.01, 2); // 3.2,2.5, 0.0);
      var figs2 = figs.clone();
      _hotload.add(figs2);
      figs2.scale.setValues(0.012, 0.012, 0.012);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          figs2, -13.67, 64.12, 0.01, 2); // 3.2,2.5, 0.0);
      var cheese = await OPENWORLD.Model.createModel(
          'assets/models/cheese.glb'); //,texture:"assets/detailmap.png");
      // hotloadAdd(firsthotload, false, rock);
      cheese.scale.setValues(0.002, 0.002, 0.002);
      for (var i = 0; i < 4; i++) {
        var cheese2 = cheese.clone();
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            cheese2, -13.67 + OPENWORLD.Math.randFloatSpread(0.02),
            64.03 + OPENWORLD.Math.randFloatSpread(0.02), 0.002,
            2); // 3.2,2.5, 0.0);
        _hotload.add(cheese2);
        OPENWORLD.Space.objTurn(cheese2, OPENWORLD.Math.random() * 360);
      }
    }

    // Soldiers before stable who are rude
    var soldierposlist=[
      [1.57-0.1,27.7],  // before stables east of road
      [1.81,23.39]   // right near stables west of road
    ];
    for (var j=0;j<soldierposlist.length; j++) {
      var soldiers=[];
      var soldierposx = soldierposlist[j][0];//1.57 - 0.1; //0.76
      var soldierposy = soldierposlist[j][1];//27.7; //29.82
      for (var i=0; i<5; i++) {
        var soldier22iii = await OPENWORLD.Actor.copyActor(
            soldierlist[i % soldierlist.length], randomduration: 0.1,
            //  texture:"assets/actors/soldier/head2.jpg",
            //   groupname:"soldier_3",
            action: j==0?"idlehold":"sitidle"); //, action:"idlehold");
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            soldier22iii, soldierposx + OPENWORLD.Math.randFloatSpread(0.3),
            soldierposy + OPENWORLD.Math.randFloatSpread(0.3), 0.0,
            // -0.83 ,31.36, 0.0,
            3); //, lerpopacity: 1);//-14.12, 63.32,0,3);//-14.18, 63.44,0,3);// -14.08, 64.13,0,3);//-13.51, 64.25, 0.0, 3); //3.42);
        _hotload.add(soldier22iii);
        if (j==0) {
          soldiers.add(soldier22iii);
          if (i > 0)
            OPENWORLD.Space.faceObject(soldier22iii, soldiers[0]);

          OPENWORLD.BaseObject.setDistanceTrigger(
              soldier22iii, dist: 1.0, event: (action) {
            if (action) {
              OPENWORLD.Space.faceObjectLerp(soldier22iii, threeJs.camera, 1.0);
              OPENWORLD.Mob.setSpeech(
                  soldiers[0], ["Baneuse!"], z: 90,
                  // Scatophagē!
                  width: 400,
                  scale: 0.4,
                  randwait: 0,
                  delay: 1,
                  clearwhendone: true,
                  callbackonfinish: (actor) {
                    if (womensgategroup.length > 0)
                      OPENWORLD.Mob.setSpeech(
                          womensgategroup[0], ["Stay close kids.."], z: 80,
                          // Scatophagē!
                          width: 400,
                          scale: 0.2,
                          randwait: 0,
                          clearwhendone: true);
                    lookback(womensgategroup[3]); // have kid look back

                  }
              );
            }
          });
        }
      }
    }


    // This is along eastwest road to make it more interesting
    var ovenposx=-13.41;//16;
    var ovenposy=40.29;//14;
    var oven2 = tannur.clone();
    //  _hotload.add(oven2);
    hotloadAdd(firsthotload, false, oven2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        oven2, ovenposx,ovenposy, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(oven2, 90);


    var smoke5 = Smoke();
    var smokeGroup5 = await smoke5.createSmoke(
        'assets/textures/smoke/clouds64.png');

    //var smokeGroup2=smokeGroup.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smokeGroup5, ovenposx,ovenposy, 0.05, 3);

    smokeGroup5.scale.setValues(0.00004, 0.00004, 0.00004);
    OPENWORLD.Updateables.add(smoke5);
    //  _hotload.add(smokeGroup5);
    hotloadAdd(firsthotload, false, smokeGroup5);

    OPENWORLD.Config
        .config['positions']['poolpositions'][1]['positions'].add(
        {
          'name':'citizenoldwoman',
          'p': [-13.58, 40.37,0],
          //   'l': i==0?1:0,
          't': 180, //OPENWORLD.Math.random() * 360, //270,
          "action": 'squatwork',
     //     "duration": 2.5,
          'randomduration': 0.1,
          //  'startat': OPENWORLD.Math.random(),
          //  'label': 'courtwomen',
          "lerpopacity": 1
        });

    var ladder2 = ladder.clone();
    // _hotload.add(ladder2);
    hotloadAdd(firsthotload, false, ladder2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        ladder2,-10.87,41.2, 0.0,3,lerpopacity: 1.0);

    OPENWORLD.Config
        .config['positions']['poolpositions'][1]['positions'].add(
        {
          'name':OPENWORLD.Config.getObjectName(
              OPENWORLD.Math.randPick(manlist)),
          'p': [-15.65,40.88,0.2],
          //   'l': i==0?1:0,
          't': 270, //OPENWORLD.Math.random() * 360, //270,
          "action": 'squatwork',
          //     "duration": 2.5,
          'randomduration': 0.1,
          //  'startat': OPENWORLD.Math.random(),
          //  'label': 'courtwomen',
          "lerpopacity": 1
        });

    OPENWORLD.Config
        .config['positions']['poolpositions'][1]['positions'].add(
        {
          'name':OPENWORLD.Config.getObjectName(
              OPENWORLD.Math.randPick(manlist)),
          'p': [-15.65-0.1,40.88,0.2],
          //   'l': i==0?1:0,
          't': 90, //OPENWORLD.Math.random() * 360, //270,
          "action": 'squatwork',
          //     "duration": 2.5,
          'randomduration': 0.1,
          //  'startat': OPENWORLD.Math.random(),
          //  'label': 'courtwomen',
          "lerpopacity": 1
        });

    var goat4iii = await OPENWORLD.Actor.copyActor(
        goat, randomduration: 0.1, duration: 6);
    _hotload.add(goat4iii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        goat4iii, -19.59, 38.49+0.1, 0.0, 3,
        lerpopacity: 1.0); //, normalize2world:true);
    OPENWORLD.Space.objTurn(goat4iii, 180);
    OPENWORLD.BaseObject.setVisible(goat4iii, true, groupname: "collar");


  //  var numwalkers = 10;
    // This is the walkers you are putting along the eastwest road
    // This is unrelated to citizenpath - more like create walkers
    var v = 0.06;
    List<Map> positions = [];
    for (var i=4; i<friendpathfishgate.length-1; i++)  // minus 1 so dont get the extra point leading up to fish gate causing them to walk thorugh wall
      positions.add({"p": [friendpathfishgate[i][0], friendpathfishgate[i][1],0.0], "v": v});

    for (var j = 0; j < 10; j++) {
      var index = OPENWORLD.Math.randInt(positions.length-1);
      //  print("indexx "+index.toString());
      // So that dont have two walkers on top of eachother
      Map map = positions[index];
      Map prevmap;
      if (index>0)
        prevmap=positions[index-1];
      else
        prevmap=positions[positions.length-1];
      List<dynamic> startpos = OPENWORLD.Math.interpolateTwoPoints( map['p'],prevmap['p'],OPENWORLD.Math.random());
      OPENWORLD.Config
          .config['positions']['poolpositions'][2]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(
                walkerlist[j % walkerlist.length]),
            //citizen3),
            'p': [
              startpos[0] ,//+ OPENWORLD.Math.randFloatSpread(0.3),
              startpos[1],// + OPENWORLD.Math.randFloatSpread(0.3),
              0
            ],
            //positions[index]['p'][0]+OPENWORLD.Math.randFloatSpread(0.3),positions[index]['p'][1]+OPENWORLD.Math.randFloatSpread(0.3),0],//-5.79, -13.06, 0], //3.2,-13.26,0],
            // Why must I do this to get the correct turn?
            't': 270,
            'action': "idle",
            'randomduration': 0.1,
            "lerpopacity": 1,
            "label": index,
            //"labelstartpos": startpos,
            // "labeltest":"test",
            "callbackonvisible": (actor) {
              var positionjson = OPENWORLD.Config.getPositionForObject(actor);
              //    print("positionjson"+positionjson.toString());
              setcancollide(actor,true);
              OPENWORLD.Space.resetRot(actor);

              //var worldpos=OPENWORLD.Space.localToWorldObj(actor);
              //  print("callbackonvis"+positionjson!['label'].toString()+" "+worldpos.toString()+" "+newpositions.toString());
              //    OPENWORLD.Space.objTurn(actor, positionjson!['labelangle']);
              var ind=positionjson!['label'];
              var bathsedapathlistcopy=positions.toList();
              bathsedapathlistcopy.insert(ind,{"p":[positionjson['p'][0],positionjson['p'][1],0],"v":v});
              OPENWORLD.Mob.moveToLoop(
                actor,
                bathsedapathlistcopy,
                index: ind,
                action: "walk",
                //   facenow:true,
                  looptype: OPENWORLD.Mob.LoopTypeReverseLoop, //.LoopTypeStop,
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
              setcancollide(actor,false);

              // OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
            }
          });
    }


  }
}
