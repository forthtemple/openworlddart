// Code for the second temple. Shared between many journeys like hearth, bethphage, womensgate
part of 'SecondTemplePage.dart';

extension HotloadSecondtempleExt on SecondTemplePageState {
  hotloadSecondtemple(firsthotload) async {
//// SecondTemple
    // ----- Second temple

    instancedRings.reset();
    instancedPillars.reset();
    instancedWoodbundle.reset();
    instancedDonationchest.reset();
    instancedTablelow.reset();
    instancedStool.reset();
    instancedParchment.reset();
    instancedMoneychest.reset();
    instancedBasket.reset();
    instancedBasketWicker.reset();
    instancedParchmentroll.reset();
    instancedCup.reset();
    instancedMatrolled.reset();
    instancedColumnsBethesda.reset();

   // var threepriests = [];


    //OPENWORLD.Space.worldToLocalSurfaceObjHide(
    //    _seagull, 7.7, 2.0, 0, 3);  //3.42);
    _hotload.add(seagull);
    //  print("add seagull");
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var seagullz = 3;
      var seagullspeed = 0.1;
      OPENWORLD.Mob.moveToLoop(seagull, [
        {"p": [7.7, 2.0, seagullz], "v": seagullspeed,},
        {"p": [7.7, 2.0 - 10, seagullz], "v": seagullspeed},
        {"p": [7.7, 2.0, seagullz], "v": seagullspeed},
        {"p": [7.7, 2.0 + 10, seagullz], "v": seagullspeed},
        {"p": [7.7, 2.0, seagullz], "v": seagullspeed},
        {"p": [7.7 + 10, 2.0, seagullz], "v": seagullspeed},
        {"p": [7.7, 2.0, seagullz], "v": seagullspeed},
        {"p": [7.7 - 5, 2.0, 1.5], "v": seagullspeed},
      ], level: 1);
    }

    if (OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)||gamestart==GameStart.hearth) {
      // Put in donation chests around the court of women
      for (var i = 0; i < 5; i++) {
        /* var donationchest2 = donationchest.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donationchest2, 5.92 + 0.09 + i * 0.27*2-0.27/2, 1.98 + 0.08+0.1, 0,
          5, level:1); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(donationchest2);*/
        instancedDonationchest.place(
            0, 5.92 + 0.09 + i * 0.27 * 2 - 0.27 / 2, 1.98 + 0.08 + 0.1, 0.0,
            level: 1); //,5);

        /* donationchest2 = donationchest.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donationchest2, 5.92 + 0.09 + i * 0.27*2-0.27/2, -1.29 -0.1, 0,
          5, level:1); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(donationchest2);*/
        instancedDonationchest.place(
            0, 5.92 + 0.09 + i * 0.27 * 2 - 0.27 / 2, -1.29 - 0.1, 0.0,
            level: 1); //,5);
        // column2.scale.setValues(0.5, 0.5, 0.5);
        //OPENWORLD.Space.objTurn(column2, -90);
      }


      instancedDonationchest.place(
          0, 8.74, 0.62, 0.0,
          level: 1); //, scale:THREE.Vector3(1.0,1.0,1.0)); //,5);
      /* OPENWORLD.Space.worldToLocalSurfaceObjHide(
        donationchest, 8.74, 0.62, 0,
        10, level:1); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    _hotload.add(donationchest);*/

    }
    // court of women columns
    for (var i = 0; i < 10; i++) {
      // north side
      /*  var column2 = column.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          column2, 5.92 + 0.09 + i * 0.27, 1.98 + 0.08, 0,
          10); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);
      // column2.scale.setValues(0.5, 0.5, 0.5);
      OPENWORLD.Space.objTurn(column2, -90);*/
      instancedColumns.place(
          -90, 5.92 + 0.09 + i * 0.27, 1.98 + 0.08, 0.0, level: 1); //,5);
      //east side
      /* column2 = column.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          column2, 8.65, 2.01 - 0.44 - i * 0.27, 0,
          10); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);
      //column2.scale.setValues(0.5, 0.5, 0.5);
      OPENWORLD.Space.objTurn(column2, 0);*/
      instancedColumns.place(
          0, 8.65, 2.01 - 0.44 - i * 0.27, 0, level: 1); //,5);


      // south side
      /*   column2 = column.clone();
      // column2.scale.setValues(0.5, 0.5, 0.5);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          column2, 5.92 + 0.09 + i * 0.27, -1.29, 0,
          10); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);
      OPENWORLD.Space.objTurn(column2, 90);*/
      instancedColumns.place(
          90, 5.92 + 0.09 + i * 0.27, -1.29, 0, level: 1); //,5);
    }

    // northern wall of court of gentiles
    for (var i = 0; i < 30; i++) {
      /* var column2 = column.clone();
      //column2.scale.setValues(0.048,0.048, 0.048);
      OPENWORLD.Space.objTurn(column2, -90);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(column2,
          9.93 - 0.42 * (i + 1), 12.5, 0, //12.57, 0,
          10); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);*/
      instancedColumns.place(-90, 9.93 - 0.42 * (i + 1), 6.4 - 0.02 - 0.3, 0,
          level: 1); //12.5, 0); //,5);

      /*column2 = column.clone();
      //column2.scale.setValues(0.048,0.048, 0.048);
      OPENWORLD.Space.objTurn(column2, -90);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(column2,
          9.93 - 0.42 * (i + 1), 12.1, 0, //12.57, 0,
          10); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);*/
      instancedColumns.place(
          -90, 9.93 - 0.42 * (i + 1), 6.4 - 0.02 - 0.4 - 0.3, 0,
          level: 1); // 12.1, 0); //,5);

    }

    // eastern wall of court of gentiles
    for (var i = 0; i < 28; i++) {
      /*var column2 = column.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          column2, 10.0, 5.02 - (i * 0.42), 0,
          10); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);
      // column2.scale.setValues(0.5, 0.5, 0.5);
      OPENWORLD.Space.objTurn(column2, 0);*/
      instancedColumns.place(-90, 10.0, 5.02 - (i * 0.42), 0, level: 1); //,5);

    }

    // eastern wall south
    for (var i = 0; i < 8; i++) {
      /*var column2 = column.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          column2, 10.0, 5.02 - (i * 0.42), 0,
          10); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);
      // column2.scale.setValues(0.5, 0.5, 0.5);
      OPENWORLD.Space.objTurn(column2, 0);*/
      instancedColumns.place(
          -90, 10 + 0.2, -7 - (i * 0.42), 0, level: 1); //,5);
      instancedColumns.place(
          -90, 10 - 0.4 + 0.2, -7 - (i * 0.42), 0, level: 1); //,5);

    }

    // western wall of court of gentiles
    for (var i = 0; i < 40; i++) {
      /*  var column2 = column.clone();
      //column2.scale.setValues(0.048,0.048, 0.048);
      OPENWORLD.Space.objTurn(column2, -180);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(column2,
          -3.30 - 0.5, 12.5 - (i * 0.42), 0, //12.57, 0,
          10,level:1); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);*/
      instancedColumns.place(
          -180, -3.30 - 0.5 - 0.37, 6.1 - (i * 0.42), 0, level: 1); //,5);
//      instancedColumns.place(-180, -3.30 - 0.5,         12.5 - (i * 0.42), 0, level:1); //,5);

      /*   column2 = column.clone();
      //column2.scale.setValues(0.048,0.048, 0.048);
      OPENWORLD.Space.objTurn(column2, -180);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(column2,
          -3.30 + 0.4 - 0.5, 12.5 - (i * 0.42), 0, //12.57, 0,
          10, level:1); // 2.61, 3.32,0,2);//-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      _hotload.add(column2);*/
      instancedColumns.place(
          -180, -3.30 + 0.4 - 0.5 - 0.37, 6.1 - (i * 0.42), 0, level: 1); //,5);
    }

    // Royal stoa
    var stoacolumnpos = [];
    var colwidth = 0.1;
    var columnstartx = 9.29; //9.93
    for (var i = 0; i < 30; i++) {
      var pos = [columnstartx - 0.42 * (i + 1), -10.5, colwidth];
      instancedColumns.place(-90, pos[0], pos[1], 0, level: 1,
          scale: THREE.Vector3(1.0, 1.4, 1.0)); //12.5, 0); //,5);
      stoacolumnpos.add(pos);
      pos = [columnstartx - 0.42 * (i + 1), -11.07, colwidth];
      instancedColumns.place(-90, pos[0], pos[1], 0, level: 1,
          scale: THREE.Vector3(1.0, 1.4, 1.0)); //12.5, 0); //,5);
      stoacolumnpos.add(pos);

      instancedColumns.place(-90, 9.93 - 0.42 * (i + 1), -11.07, 0.8, level: 1,
          scale: THREE.Vector3(1.0, 1.3, 1.0)); //12.5, 0); //,5);

      pos = [columnstartx - 0.42 * (i + 1), -12.04, colwidth];
      instancedColumns.place(-90, pos[0], pos[1], 0, level: 1,
          scale: THREE.Vector3(1.0, 1.4, 1.0)); //12.5, 0); //,5);
      stoacolumnpos.add(pos);
      instancedColumns.place(-90, 9.93 - 0.42 * (i + 1), -12.04, 0.8, level: 1,
          scale: THREE.Vector3(1.0, 1.3, 1.0)); //12.5, 0); //,5);
      // instancedColumns.place(-90, 9.93 - 0.42 * (i + 1), -10.6,0,level:1);// 12.1, 0); //,5);
      pos = [columnstartx - 0.42 * (i + 1), -12.7, colwidth];
      instancedColumns.place(-90, pos[0], pos[1], 0, level: 1,
          scale: THREE.Vector3(1.0, 1.4, 1.0)); //12.5, 0); //,5);
      stoacolumnpos.add(pos);
    }

    // Grape vine on temple
    _hotload.add(grapevine);
    OPENWORLD.Space.objTurn(grapevine, 90); //45+90);
    //  OPENWORLD.Space.setTurnPitchRoll(grapevine, 125,20,0);//, pitch, roll)
    OPENWORLD.Space.worldToLocalSurfaceObjHide(grapevine, 3.25, 0.39, 0.9,
        10,
        level: 1); //2.93, 0.38,0.54,10);//3.33, 0.46,0.44,10);//1.9, 1.27, 0.64, 10);
    var grapevinemat = grapevine.children[0].material;
    final goldgrapevine = THREE.MeshStandardMaterial.fromMap({
      'normalMap': grapevinemat?.map,
      'alphaMap': grapevinemat?.map,
      // 'envMap':grapevinemat?.map,
      'color': 0xffff33,
      'metalness': 1.0, // 0,
      //'map': goldii,
      // 'transparent':true,
      'shininess': 1.0,
      'roughness': 0.5,
      // 'em'
      // 'emissive':THREE.Color.fromHex32(0xffff00)
      //'envMap': gold,
      //'envMapIntensity': 0.5,// api['envMapIntensity'],
    });
    goldgrapevine.alphaTest = 0.1;
    OPENWORLD.Texture.setMaterial(grapevine, goldgrapevine);

    // Second temple curtain
    _hotload.add(curtain);
    OPENWORLD.Space.objTurn(curtain, 90); //45+90);
    //OPENWORLD.Space.worldToLocalSurfaceObjHide(curtain,  1.72, 0.38,0,10);//0.0, 1.3, 0,15);
    // Curtain in the holy of holies
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        curtain, 1.62, 0.38, 0, 10, level: 1); //0.0, 1.3, 0,15);
//    OPENWORLD.Space.worldToLocalSurfaceObjHide(curtain,  -0.87, 1.3, 0,15);
    var curtainmat = curtain.children[1].material;
    final goldcurtain = THREE.MeshStandardMaterial.fromMap({
      //   'normalMap':curtainmat?.map,
      'map': curtainmat?.map,
      // 'alphaMap':curtainmat?.map,
      // 'envMap':grapevinemat?.map,
      'color': 0xffff33,
      'metalness': 1.0, // 0,
      //'map': goldii,
      'transparent': true,
      'shininess': 1.0,
      'roughness': 0.5,
      // 'em'
      // 'emissive':THREE.Color.fromHex32(0xffff00)
      //'envMap': gold,
      //'envMapIntensity': 0.5,// api['envMapIntensity'],
    });
    curtainmat?.alphaTest = 0.1;
    OPENWORLD.Texture.setMaterial(curtain, goldcurtain, groupname: 'gold');

    // Curtain at sanctuary entrance
    var curtain2 = curtain.clone();
    OPENWORLD.Texture.setSide(curtain2, THREE.DoubleSide, groupname: "curtain");
    _hotload.add(curtain2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        curtain2, 3.13, 0.39, 0, 10, level: 1); //0.0, 1.3, 0,15);

    // Add chains to the second temple
    _hotload.add(chain);
    OPENWORLD.Space.objTurn(chain, 20); //45+90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        chain, 3.05, 0.68, 0, 10, level: 1);
    var chainmat = chain.children[0].material;
    final goldchain = THREE.MeshStandardMaterial.fromMap({
      ///   'normalMap':chainmat?.map,
      'map': chainmat?.map,
      // 'alphaMap':curtainmat?.map,
      // 'envMap':grapevinemat?.map,
      'color': 0xffff33,
      'metalness': 1.0, // 0,
      //'map': goldii,
      'transparent': true,
      'shininess': 1.0,
      'roughness': 0.5,
      // 'em'
      // 'emissive':THREE.Color.fromHex32(0xffff00)
      //'envMap': gold,
      //'envMapIntensity': 0.5,// api['envMapIntensity'],
    });
    chainmat?.alphaTest = 0.1;
    OPENWORLD.Texture.setMaterial(chain, goldchain, groupname: 'gold');

    var chain2 = chain.clone();
    _hotload.add(chain2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        chain2, 3.05, 0.15, 0, 10, level: 1); //0.0, 1.3, 0,15);

    // what is this for?? - seems to be a ring at the bottom of door north door  inside second temple entrance
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        ring, 2.89, 1.06, 0.0, 10, level: 1);

    // The pillar position where butcher the sacrifices
    var pillarstartposx = 3.83;
    var pillardiffx = 0.2;

    // The rings where tie the animals to be sacrificed
    for (var i = 0; i < 6; i++) {
      for (var j = 0; j < 4; j++) {
        instancedRings.place(
            0, pillarstartposx + j * pillardiffx, 0.72 + i * 0.08, 0.0,
            level: 1); // 3.84
//        instancedRings.place(
        //          0,pillarstartposx + i * 0.13, 0.72 + j * 0.13, 0.0, level: 1); // 3.84

        /*var ring2 = ring.clone();
        _hotload.add(ring2);
        //ring.scale.setValues(0.002, 0.002, 0.002);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            ring2, 3.84 + i * 0.13, 0.72 + j * 0.13, 0.0, 10,level:1);*/
//        OPENWORLD.Space.worldToLocalSurfaceObjHide(ring2, 2.89 + i*0.13, 1.06+j*0.13, 0.0, 10);
      }
    }

    // If the tamid there will be no goats or extra sheep there but later for sin offerings may be there
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time) && !Glob.roamtamid &&
        !Glob.roamketoret && !Glob.testtamidfinal&&gamestart!=GameStart.bethphage) {
      var animalx = 3.85;
      var animaly = 0.71;
      var goat2 = await OPENWORLD.Actor.copyActor(
          goat, duration: 6, action: "eat", randomduration: 0.5);
      // setActorSize(citizenoldwoman2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          goat2, animalx, animaly, 0,
          3,
          level: 1); //0.71,0,3);//2.89, 1.06,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
      OPENWORLD.Space.objForward(goat2, 0.037);
      OPENWORLD.Space.objTurn(goat2, 0);
      _hotload.add(goat2);
      OPENWORLD.BaseObject.setVisible(goat2, true, groupname: "collar");

      var sheepforward = 0.038;
      //OPENWORLD.Space.objTurn(sheeporig.children[0],0);
      // OPENWORLD.Space.objTurn(sheeporig.children[1],0);

      var sheep10 = await OPENWORLD.Actor.copyActor(sheeporig, duration: 5,
          action: "eat",
          randomduration: 0.5,
          castshadow: true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep10, animalx + 0.13, animaly, 0,
          3,
          level: 1); //  2.89+0.13, 0.71,0,3);//1.06,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
      _hotload.add(sheep10);
      OPENWORLD.Space.objTurn(sheep10.children[0], 0); // Why this be done
      OPENWORLD.Space.objTurn(sheep10.children[1], 0);
      OPENWORLD.Space.setTurnPitchRoll(sheep10, 90, 0, 0); //turn, pitch, roll)
      // OPENWORLD.Space.setTurnPitchRoll(sheep10, 90,0,0);//turn, pitch, roll)
      // OPENWORLD.Space.objForward(sheep10, sheepforward);
      OPENWORLD.BaseObject.setVisible(sheep10, true, groupname: "collar");

      var sheep11 = await OPENWORLD.Actor.copyActor(sheeporig, duration: 5,
          action: "eat",
          randomduration: 0.5,
          castshadow: true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep11, animalx + 0.13, animaly + 0.13, 0,
          3,
          level: 1); //2.89+0.13, 0.71+0.13,0,3);//1.06+0.13,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
      _hotload.add(sheep11);
      OPENWORLD.Space.objTurn(sheep11.children[0], 0); // Why this be done
      OPENWORLD.Space.objTurn(sheep11.children[1], 0);
      OPENWORLD.Space.objTurn(sheep11, 180);
      OPENWORLD.BaseObject.setVisible(sheep11, true, groupname: "collar");
      OPENWORLD.Space.objForward(sheep11, sheepforward);
      var sheep12 = await OPENWORLD.Actor.copyActor(sheeporig, duration: 5,
          action: "eat",
          randomduration: 0.5,
          castshadow: true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep12, animalx, animaly + 0.13, 0,
          3,
          level: 1); // 2.89, 0.71+0.13,0,3);//1.06+0.13,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
      _hotload.add(sheep12);
      OPENWORLD.Space.objTurn(sheep12.children[0], 180); // Why this be done
      OPENWORLD.Space.objTurn(sheep12.children[1], 180);
      OPENWORLD.Space.objTurn(sheep12, 270);
      OPENWORLD.BaseObject.setVisible(sheep12, true, groupname: "collar");
      OPENWORLD.Space.objForward(sheep12, sheepforward);


      var sheep13 = await OPENWORLD.Actor.copyActor(sheeporig, duration: 6,
          action: "eat",
          randomduration: 0.5,
          castshadow: true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          sheep13, animalx + 0.13 * 2, animaly + 0.13, 0,
          3,
          level: 1); //2.89+0.13*2, 0.71+0.13*2,0,3);// 1.06+0.13*2,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
      _hotload.add(sheep13);
      OPENWORLD.BaseObject.setVisible(sheep13, true, groupname: "collar");
      OPENWORLD.Space.objTurn(sheep13.children[0], 0); // Why this be done
      OPENWORLD.Space.objTurn(sheep13.children[1], 0);
      OPENWORLD.Space.objTurn(sheep13, 270);
      OPENWORLD.Space.objForward(sheep13, sheepforward);
    }

    // The pillars where butcher the sacrifices
    for (var i = 0; i < 4; i++) {
      for (var j = 0; j < 2; j++) {
        if (i == 1 && j == 0) {
          //
          Glob.pillarcarcass = pillar.clone();
          // if (i==0)
          //   pillar2.castShadow=true;
          OPENWORLD.BaseObject.setVisible(
              Glob.pillarcarcass, false, groupname: "carcass");
          _hotload.add(Glob.pillarcarcass);
          //ring.scale.setValues(0.002, 0.002, 0.002);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              Glob.pillarcarcass, pillarstartposx + i * pillardiffx,
              1.24 + j * 0.25, 0.0, 10, level: 1); //3.93
        } else
          instancedPillars.place(
              180, pillarstartposx + i * pillardiffx, 1.24 + j * 0.25, 0.0,
              level: 1); //,5);  //3.93

      }
    }

    // Given a priest actor and his number, have the priest wield his vessel
    threepriestwield(priest, priestnum) {
      //,{clone}) {

      if (priestnum == 0) {
        var vesselbowlwield = vesselbowl.clone();
        //vesselbowlwield.visible=true;
        //vesselbowlwield.scale.setValues(1.0,1.0,1.0);
        OPENWORLD.Space.setTurnPitchRoll(vesselbowlwield, 0, 90 - 20, 180 + 60);
        // print("bowl wield");

        OPENWORLD.Actor.wield(priest, vesselbowlwield, "Bip01_L_Hand");
        priest.extra['vesselwield'] = vesselbowlwield;
      } else if (priestnum == 1) {
        //  OPENWORLD.Space.resetPosRot(vesseltray);
        var vesseltraywield = vesseltray.clone();
        OPENWORLD.Space.setTurnPitchRoll(vesseltraywield, 0, 90 - 20, 180 + 40);
        OPENWORLD.Actor.wield(priest, vesseltraywield, "Bip01_L_Hand");
        //  vesseltray.scale.setValues(1.0,1.0,1.0);
        //vesseltray.visible=true;
        vesseltraywield.position.y = 24.0;
        priest.extra['vesselwield'] = vesseltraywield;
      } else if (priestnum == 2) {
        //  OPENWORLD.Space.resetPosRot(vesselpitcher);
        var vesselpitcherwield = vesselpitcher.clone();
        OPENWORLD.Space.setTurnPitchRoll(
            vesselpitcherwield, 0, 90 - 20, 180 + 30);
        // vesselpitcher.scale.setValues(1.0,1.0,1.0);
        // vesselpitcher.visible=true;
        OPENWORLD.Actor.wield(priest, vesselpitcherwield, "Bip01_L_Hand");
        priest.extra['vesselwield'] = vesselpitcherwield;
      }
    }

    // Have all three priests wield there vessels
    threepriestswield(priestlist) {
      for (var i = 0; i < priestlist.length; i++) {
        var priest = priestlist[i];
        threepriestwield(priest, i);

      }
    }

    Glob.threepriestswield = threepriestswield;

    // Place all the pieces of meat on the pillar that priest slaughtered the lamb on
    Glob.meatonpillar = () {
      for (var meat in Glob.meatlist) {
        _hotload.add(meat);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            meat, Glob.finaltableposx + OPENWORLD.Math.randFloatSpread(0.04),
            // 3.93
            Glob.finaltableposy + OPENWORLD.Math.randFloatSpread(0.04), 0.058,
            //1.28
            3, level: 1); // 3.2,2.5, 0.0);
        ///          meat, 2.89+OPENWORLD.Math.randFloatSpread(0.04), 1.84+OPENWORLD.Math.randFloatSpread(0.04), 0.058, 3); // 3.2,2.5, 0.0);
        meat.scale.setValues(0.00065, 0.00065, 0.00065);
        OPENWORLD.Space.objTurn(sheephead, OPENWORLD.Math.random() * 360);
      }
    };

    // Looks like the x position of the priests in the chamber of the hewnstone at the start of shema
    Glob.tamidhewnstonepriestposx = (actorpriestnum, threepriest) {
      var priestnum;
      if (!threepriest)
        priestnum = actorpriestnum;
      else
        priestnum = actorpriestnum + 6; //priestlist.length;
      return 4.90 + 0.05 * 4 - priestnum * 0.05;
    };

    // Put the pieces of meat on the altar that was left after the tamid
    Glob.meatdropall = () {
      // Put the meat on the ramp
      for (var i = 0; i < 6; i++) {
        Glob.meatdropaltar!(i, false);
      }

      for (var i = 0; i < 3; i++) {
        Glob.meatdropaltar!(i, true);
      }
    };

    // Place meat on altar for a particular priest and whether they are the threepriest or sixpriest
    Glob.meatdropaltar = (actorpriestnum, threepriest) {
      var meatx = 4.16; // 3.124
      if (!threepriest) {
        if (actorpriestnum != 5) {
          var meat1 = Glob.meatlist[actorpriestnum * 2];
          var meat2 = Glob.meatlist[actorpriestnum * 2 + 1];
          meat1.scale.setValues(0.00065, 0.00065, 0.00065);
          meat2.scale.setValues(0.00065, 0.00065, 0.00065);
          _hotload.add(meat1);
          _hotload.add(meat2);
          var meaty = -0.84 - 0.04 - actorpriestnum * 0.04; //-0.39
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              meat1, meatx, meaty, 0.005, 3, level: 1);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              meat2, meaty, meaty + 0.02, 0.005, 3, level: 1);
        } else {
          var inc = 0;
          for (var i = Glob.meatlist.length - 1 - 5; i <
              Glob.meatlist.length; i++) {
            _hotload.add(Glob.meatlist[i]);
            var meaty = -0.84 - 0.04 - (5 + 1 + inc) * 0.02;
//          var meaty=-0.39-0.04-(5+1+inc)*0.02;
            OPENWORLD.Space.worldToLocalSurfaceObjHide(
                Glob.meatlist[i], meatx, meaty, 0.005, 2, level: 1);
            inc++;
          }
        }
      } else {
        var vessel = vessellist[actorpriestnum].clone();
        vessellist[actorpriestnum].extra['vesselground'] = vessel;
        vessel.scale.setValues(0.001, 0.001, 0.001);
//      vessel.scale.setValues(0.00065, 0.00065, 0.00065);
        OPENWORLD.Space.setTurnPitchRoll(vessel, 0, 0, 0);
        _hotload.add(vessel);
        var meaty = -0.84 - 0.02 - actorpriestnum * 0.04; //-0.39
        var z;
        if (actorpriestnum == 0)
          z = 0.005;
        else if (actorpriestnum == 1)
          z = 0.003;
        else if (actorpriestnum == 2)
          z = 0.01;

        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            vessel, meatx + 0.03, meaty, z, 3, level: 1);
      }
    };

    // General tamid with six priests and the three priests who trail after holding the vessels
    // Shared by hearth, bethphage and the roam tamid
    Glob.tamid = (sixpriests, threepriests,
        {pickupcallback, dropoffcallback,callbackonfinish}) {
      Glob.showblood!(true);

      // Function within a function just to get a particular priests path
      // Works out who they are by priestnum and threepriest in extra
      List<Map> getpriestpath(priest) {

        var finalx = Glob.tamidhewnstonepriestposx!(priest.extra['priestnum'],
            !priest.extra.containsKey('threepriest'));

        List<Map> ret = [
          { //=0
            "p": [priest.extra['priestposx'], priest.extra['priestposy'], 0],
            "v": 0.03
          },
          {"p": [3.77, 0.56, 0], "v": 0.03},
          // northwest corner altar  =1
          //2.77, 0.88, 0],"v":0.03},
          {"p": [3.75, 0.98, 0], "v": 0.03, "action": "walkstraightlookleft"},
          // continue along to pillars =2
          //2.79, 1.49, 0],"v": 0.03,"action":"walkstraightlookleft"},
          {
            "p": [Glob.finaltableposx + 0.06, 1.13, 0],
            "v": 0.03,
            "action": "walkstraightlookleft"
          },
          // =3 4.05
          //2.99, 1.64, 0],"v": 0.03,"action":"walkstraightlookleft"},
          {
            "p": [Glob.finaltableposx + 0.04, 1.28, 0], //=4   4.04 - 0.06
            "v": 0.03,
            "action": "walkstraightlookleft"
          },
          //2.94, 1.85,0],"v": 0.03,"action":"walkstraightlookleft"},
          { "action": "work", "time": 1, "t": 270, 'callback': (actor) { //= 5
            // Handle priest reaching the marble table with meat and each priest collects the correct meat to take to the altar
            if (pickupcallback != null)
              pickupcallback(actor);
            if (actor.extra['priestnum'] != 5) {
              if (actor.extra['priestnum'] < 3) {
                print("Start the three priests walking");
                // Start the three priests walking
                List<Map> priestpath = getpriestpath(
                    threepriests[actor.extra['priestnum']]);
                Future.delayed(Duration(milliseconds: 50000), () async {
                  print("three priest" + actor.extra['priestnum'].toString() +
                      " " + priestpath.toString());
                  OPENWORLD.Mob.moveToLoop(
                      threepriests[actor.extra['priestnum']], priestpath,
                      action: "walkstraight",
                      looptype: OPENWORLD.Mob.LoopTypeStop,
                      surfaceonly: true,
                      level: 1

                    //   stopaction: "idle3",
                    // delay:finishedtime
                    // facedir: false
                  );
                });
              }
              print("actor callback " + actor.extra['priestnum'].toString());
              var meat1ind = actor.extra['priestnum'] * 2;
              THREE.Object3D meati = Glob.meatlist[meat1ind]; //actor.extra['priestnum']];
              _hotload.remove(meati);
              var meat = meati.clone();
              Glob.meatlist[meat1ind] = meat;
              OPENWORLD.Actor.wield(actor, meat, "Bip01_R_Hand");
              OPENWORLD.Space.setTurnPitchRoll(meat, 0, 0, 180);
              meat.position.setValues(0.0, 0.0, 0.0);
              meat.scale.setValues(0.7, 0.7, 0.7); //1.0, 1.0, 1.0);
              var meat2ind = actor.extra['priestnum'] * 2 + 1;
              THREE.Object3D meat2i = Glob
                  .meatlist[meat2ind]; //actor.extra['priestnum']];
              _hotload.remove(meat2i);
              var meat2 = meat2i.clone(); // why must I do this?
              Glob.meatlist[meat2ind] = meat2;
              OPENWORLD.Actor.wield(actor, meat2, "Bip01_L_Hand");
              OPENWORLD.Space.setTurnPitchRoll(meat2, 0, 0, 180);
              meat2.position.setValues(0.0, 0.0, 0.0);
              meat2.scale.setValues(0.7, 0.7, 0.7); //1.0, 1.0, 1.0);

              //if (actor.extra['priestnum']%2==0)
              //else
            } else {
              for (var i = Glob.meatlist.length - 1 - 5; i <
                  Glob.meatlist.length; i++) {
                _hotload.remove(Glob.meatlist[i]);
                //  meatlist[i].visible=false;
              }
            }
          }
          },
          {
            "p": [Glob.finaltableposx + 0.06, 1.38, 0],
            "v": 0.03,
            "action": "walkstraightlookleft"
          },
          //=6   4.04
          //3.01, 1.92, 0],"v": 0.03,"action":"walkstraightlookleft"},
          {"p": [3.75, 1.34, 0], "v": 0.03},
          //=7
          //2.79, 1.95, 0],"v": 0.03},
          { // south west corner of altar
            "p": [ 3.79, -0.45, 0],
            "v": 0.03,
            "t": 180 + 30,
            "action": "walkstraightlookright"
          },
          //2.70, -0.14, 0],"v": 0.03,"t":180+30,"action":"walkstraightlookright"},
          {
            "p": [4.13, -1.28, 0],
            "v": 0.03,
            "t": 180,
            "action": "walkstraightlookright"
          },
          //3.07, -0.89, 0],"v": 0.03,"t":180,"action":"walkstraightlookright"},
          {
            "p": [ 4.25, -1.28, 0],
            "v": 0.02,
            "t": 90 - 30,
            "action": "walkstraightlookleft",
            "duration": 1.5
          },
          // bottom of the ramp //3.26, -0.87
          {
            "p": [ 4.22, -0.84 - priest.extra['priestnum'] * 0.04, 0],
            "v": 0.02,
            "t": -30,
            "action": "walkstraightlookleft",
            "duration": 1.5
          },
          // part of the way up ramp to drop of meat
          //  {"p":[  3.16, -0.39-0.04-priest.extra['priestnum']*0.04, 0],"v": 0.02,"t":-30,"action":"walkstraightlookleft", "duration":1.5},  // part of the way up ramp to drop of meat
          {
            "action": "kneel",
            "time": 3.0,
            "t": 270,
            'callback': (actor) {
              print("priest drop");
              if (dropoffcallback != null)
                dropoffcallback(actor);
              Glob.meatdropaltar!(actor.extra['priestnum'],
                  actor.extra.containsKey('threepriest'));
              // var meatx = 4.16; // 3.124
              if (!actor.extra.containsKey('threepriest')) {
                if (actor.extra['priestnum'] != 5) {
                  OPENWORLD.Actor.unwield(actor, "Bip01_R_Hand");
                  OPENWORLD.Actor.unwield(actor, "Bip01_L_Hand");

                } else {

                }
              } else {
                OPENWORLD.Actor.unwield(actor, "Bip01_L_Hand");

              }
            }
          },
          // top of the ramp
          {
            "p": [ 4.22, -0.84, 0],
            "v": 0.02,
            "t": -30,
            "action": "walkstraightlookleft",
            "duration": 1.5
          },
          // top of the ramp
          // {"p":[  3.16, -0.39, 0],"v": 0.02,"t":-30,"action":"walkstraightlookleft", "duration":1.5},  // top of the ramp
          {"p": [ 4.31, -0.84, 0], "v": 0.02, "duration": 1.5},
          // top of the ramp
          // {"p":[  3.35, -0.39, 0],"v": 0.02, "duration":1.5},  // top of the ramp
          {
            "p": [ 4.25, -1.28, 0],
            "v": 0.03,
            "t": 180 + 30,
            "action": "walkstraightlookright"
          },
          // walking to bottom of ramp
          // {"p":[  3.26, -0.87, 0],"v": 0.03,"t":180+30,"action":"walkstraightlookright"},  // walking to bottom of ramp
          {
            "p": [ 4.90, -1.39, 0],
            "v": 0.03,
            "t": 90 - 30,
            "action": "walkstraightlookleft"
          },
          // entrance of hewnstone
          {
            "p": [ 4.90, -1.55, 0],
            "v": 0.03,
            // "t": 90 - 30,
            //  "action": "walkstraightlookleft"
          },
          // past doorway of hewn stone
          // 3.50, -0.86,
          //  {"p":[  4.90, -1.76+priest.extra['priestnum']*0.05,  0],"v": 0.03,"t":90-30,"action":"walkstraightlookleft"},// into the chamber of hewn stone
          {
            "p": [ finalx, Glob.tamidhewnstonepriestposy, 0], "v": 0.03,
            //   "t": 90 - 30,
            //  "action": "walkstraightlookleft"
          },
          // into the chamber of hewn stone
          {
            "action": "idlestraight",
            "t": (priest.extra.containsKey('threepriest') ? 45 : -45) +
                OPENWORLD.Math.randFloatSpread(10),
            "time": 1, "callback": (actor) {
              print("completed tamid");
            if (callbackonfinish != null)
              callbackonfinish(actor);
          }
          },


        ];
       // print("tamid ret"+ret.toString());
        // The three priests dont have the entire tamid, just the part where they join in later
        if (priest.extra.containsKey('threepriest'))
          return [
            ...ret.sublist(0, 2),
            ...ret.sublist(8)
          ];
        // return ret.sublist(startNode);
        else
          return ret;
      }
      // Note, the three extra priests are actually added inside getpriestpath() !!
      for (var priest in sixpriests) {
        // OPENWORLD.Space.objTurn(priest,0);//setTurnPitchRoll(priest,0,0,0);
        //  OPENWORLD.Space.setTurnPitchRoll(priest.children[0],0,0,0);
        //var priestpath=getpriestpath(priest);
        List<Map> priestpath = getpriestpath(priest);

        print("priest"+priestpath.toString());
        OPENWORLD.Mob.moveToLoop(
            priest, [...priestpath], action: "walkstraight",
            looptype: OPENWORLD.Mob.LoopTypeStop,
            surfaceonly: true,
            level: 1

          //   stopaction: "idle3",
          // delay:finishedtime
          // facedir: false
        );
      }
    };

    // Put the tools next to the ramp
    tools() {
      List<Map> tools = [
        {"p": [ 4.12 + 0.02, -0.47, 0.1]}, //pictforkk
        {"p": [4.12 + 0.02, -0.47 + 0.05, 0.05]}, // firepan dark
        {"p": [4.12 + 0.02, -0.47 - 0.05, 0.05]}, //firepandark2
        {"p": [ 4.12 + 0.02, -0.47 - 0.1, 0.1]}, //pitchfork3

      ];
      var pitchfork2 = pitchfork.clone();
      pitchfork2.children[0].scale.setValues(0.01, 0.01, 0.01);
      OPENWORLD.Space.setTurnPitchRoll(pitchfork2.children[0], 90, 0, -100);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pitchfork2, tools[0]["p"][0], tools[0]["p"][1], tools[0]["p"][2],
          level: 1, //4.12+0.02, -0.47, 0.1, level:1,
          2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      // _hotload.add(pitchfork2);
      hotloadAdd(firsthotload, false, pitchfork2);
      tools[0]['obj'] = pitchfork2;
      var pitchforkwield = pitchfork.clone();
      OPENWORLD.Space.setTurnPitchRoll(
          pitchforkwield.children[0], 90, 0, 0);
      tools[0]['wield'] = pitchforkwield;


      var bronzematdark = THREE.MeshStandardMaterial.fromMap({
        //  'normalMap':grapevinemat?.map,
        //  'alphaMap':grapevinemat?.map,
        // 'envMap':grapevinemat?.map,
        'color': OPENWORLD.ColorLib.brighten(0xff9933, 0.5), // 0xff9933,
        'metalness': 1.0, // 0,
        //'map': goldii,
        // 'transparent':true,
        'shininess': 100.0,
        'roughness': 0.5,
        // 'em'
        // 'emissive':THREE.Color.fromHex32(0xffff00)
        //'envMap': gold,
        //'envMapIntensity': 0.5,// api['envMapIntensity'],
      });
      var firepandark = firepan.clone();
      OPENWORLD.Texture.setMaterial(firepandark, bronzematdark!);
      _hotload.add(firepandark);
      firepandark.scale.setValues(0.01, 0.01, 0.01);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          firepandark, tools[1]["p"][0], tools[1]["p"][1], tools[1]["p"][2],
          level: 1, 1); //4.12+0.02, -0.47+0.05,0.05,level:1, 1);
      OPENWORLD.Space.setTurnPitchRoll(
          firepandark.children[0], 90, 0, -100);
      tools[1]['obj'] = firepandark;
      var firepandarkwield = firepan.clone();
      OPENWORLD.Texture.setMaterial(firepandarkwield, bronzematdark!);
      firepandarkwield.scale.setValues(5.0, 5.0, 5.0);
      //   OPENWORLD.Space.resetPosRot(firepanwield);
      OPENWORLD.Space.setTurnPitchRoll(firepandarkwield, 90, -90, 0);
      tools[1]['wield'] = firepandarkwield;

      var firepandark2 = firepandark.clone();
      _hotload.add(firepandark2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          firepandark2, tools[2]["p"][0], tools[2]["p"][1],
          tools[2]["p"][2], level: 1,
          1); //4.12+0.02, -0.47-0.05,0.05,level:1, 1);
      tools[2]['obj'] = firepandark2;
      var firepandarkwield2 = firepandarkwield.clone();
      tools[2]['wield'] = firepandarkwield2;

      var pitchfork3 = pitchfork2.clone();
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          pitchfork3, tools[3]["p"][0], tools[3]["p"][1], tools[3]["p"][2],
          level: 1, // 4.12+0.02, -0.47-0.1, 0.1, level:1,
          2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
      // _hotload.add(pitchfork2);
      hotloadAdd(firsthotload, false, pitchfork3);
      tools[3]['obj'] = pitchfork3;
      var pitchforkwield2 = pitchforkwield.clone();
      tools[3]['wield'] = pitchforkwield2;
      return tools;
    }
    Glob.tools = tools;

    // items like libation bowl for tamid put on the altar
    Glob.tamiditems = () {
      var libationbowl = bowl.clone();
      _hotload.add(libationbowl);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          libationbowl, Glob.libationbowlposx, Glob.libationbowlposy, 0,
          level: 1, 1); //4.55,-0.23, 0.00, level: 1, 1);
      OPENWORLD.Texture.setMaterial(
          libationbowl, silvermaterial!);

      Glob.firepanground = firepan.clone();
      _hotload.add(Glob.firepanground);
      Glob.firepanground.scale.setValues(0.01, 0.01, 0.01);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          Glob.firepanground, Glob.firepanposx, Glob.firepanposy, 0.005,
          level: 1, 1);
      OPENWORLD.Space.objTurn(Glob.firepanground, 0);
    };

    // For every journey or roam that includes the tamid
    if (gamestart == GameStart.hearth || gamestart == GameStart.bethphage ||
      //  gamestart == GameStart.womensgate ||  tamid not shown for womensgate journey
        (gamestart == GameStart.roam && (Glob.roamtamid || Glob.roamketoret ||
            Glob.testtamidfinal))) { //) {
      // Create the pieces of meat
      var meatfrontleg2 = meatfrontleg.clone();
      //  var meatchunk = await OPENWORLD.Model.createModel(
      //     'assets/models/meat/meatchunk.glb');
      var sheepleg2 = sheepleg.clone();
      var meatchunk2 = meatchunk.clone(); // breast
      var meatchunk3 = meatchunk.clone(); // neck
      //  var rib = await OPENWORLD.Model.createModel('assets/models/meat/rib.glb');
      var rib2 = rib.clone();
      // var intestines = await OPENWORLD.Model.createModel(
      //     'assets/models/meat/intestines.glb');
      //  var shank = await OPENWORLD.Model.createModel(
      //      'assets/models/meat/shank.glb');
      var shank2 = shank.clone();
      var shank3 = shank.clone();
      var shank4 = shank.clone();
      Glob.meatlist = [
        sheephead, //0
        sheepleg, //1
        meatfrontleg, //2
        meatfrontleg2, //3
        meatchunk, //4
        sheepleg2, //5
        meatchunk2, //6
        meatchunk3, //7
        rib, //8
        rib2, //9
        intestines, //10
        shank, //11
        shank2, //12
        shank3, //13
        shank4 //14
      ];
      for (var meat in Glob.meatlist)
        meat.scale.setValues(0.00065, 0.00065, 0.00065);


      if (Glob.roamtamid||(gamestart==GameStart.bethphage&&!gamestartpos[gamestart].containsKey('donetamid'))) {
        // If doing the roam tamid, or bethphage then meat should already be on the pillars
        Glob.meatonpillar!();

        // The six priests along altar
        Glob.sixpriests = [];
        for (var i = 0; i < 6; i++) {
          var priest34iv = await OPENWORLD.Actor.copyActor(
              priestlist[i % priestlist.length], randomduration: 0.1,
              action: "lookright",
             // logtext: true
          ); //armsidle");
          Glob.sixpriests.add(priest34iv);
          _hotload.add(priest34iv);
          var posx = Glob.sixprieststartposx + i * Glob.sixpriestsdiff +
              OPENWORLD.Math.randFloatSpread(0.015); //3.94  0.1
          //var posx=3.05+i*0.1+OPENWORLD.Math.randFloatSpread(0.015);
          // var posy = 0.57; //0.86;
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              priest34iv, posx, Glob.sixprieststartposy, 0,
              4, level: 1); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
          priest34iv.extra['priestposx'] = posx;
          priest34iv.extra['priestposy'] = Glob.sixprieststartposy;
          //  priest34iv.extra['priestfinalposx']=2.58;
          // priest34iv.extra['priestfinalposy']=-0.33+i*0.01;
          priest34iv.extra['priestnum'] = i;

          OPENWORLD.Space.objTurn(
              priest34iv, -45 + OPENWORLD.Math.randFloatSpread(
              10)); //setTurnPitchRoll(priest34iv, -45,0,0);// pitch, roll)
          if (i == 5) {
            OPENWORLD.Space.setTurnPitchRoll(vesselbazichtamid, 0, 130, 100);
            vesselbazichtamid.position.z = 0.0; //-4.0;
            vesselbazichtamid.position.y = 7.0; //5.0;
            vesselbazichtamid.position.x = 0.0;
            OPENWORLD.Actor.wield(
                priest34iv, vesselbazichtamid, "Bip01_L_Hand");
          }
        }

        // Have the three priests along the altar
        Glob.threepriests = [];
        for (var i = 0; i < 3; i++) {
          var priest34iv = await OPENWORLD.Actor.copyActor(
              priestlist[i % priestlist.length], randomduration: 0.1,
              action: "lookright",
              //logtext: true
          ); //armsidle");
          Glob.threepriests.add(priest34iv);
          _hotload.add(priest34iv);
          var posx = Glob.threeprieststartposx + i * Glob.sixpriestsdiff +
              OPENWORLD.Math.randFloatSpread(0.015); //4.13   0.1
          //var posx=3.05+i*0.1+OPENWORLD.Math.randFloatSpread(0.015);
          // var posy = 0.48; //0.86;
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              priest34iv, posx, Glob.threeprieststartposy, 0,
              4, level: 1); //.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
          priest34iv.extra['priestposx'] = posx;
          priest34iv.extra['priestposy'] = Glob.threeprieststartposy;
          //  priest34iv.extra['priestfinalposx']=2.58;
          // priest34iv.extra['priestfinalposy']=-0.33+i*0.01;
          priest34iv.extra['priestnum'] = i;
          priest34iv.extra['threepriest'] = true;

          OPENWORLD.Space.objTurn(
              priest34iv, -45 + OPENWORLD.Math.randFloatSpread(
              10)); //setTurnPitchRoll(priest34iv, -45,0,0);// pitch, roll)

        }
        // Have the three priest wield their vessels
        threepriestswield(Glob.threepriests);

        // Move the priests - including the three priests
        if (Glob.roamtamid)
           callwhenloaded(() {
             // Now the priests are set up do the tamid
             Glob.tamid!(Glob.sixpriests, Glob.threepriests);
           });
      }
    }
    //  these are the two citizens cutting up the lamb which wouldn't have happened except sin offering
    // Is this ever called? Shouldn't these two citizens be cutting up the meat during womens gate?
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time) && !Glob.roamtamid &&
        !Glob.roamketoret && !Glob.testtamidfinal &&
        gamestart != GameStart.hearth &&
        gamestart != GameStart.bethphage && gamestart != GameStart.womensgate) {
      var citizen2iiin = await OPENWORLD.Actor.copyActor(
          citizen2); //, randomduration: 0.1);//,action:"work", duration:2.0);
      _hotload.add(citizen2iiin);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen2iiin, 3.99 - 0.01, 1.29, 0,
          3,
          level: 1); // 2.94, 1.85,0,3);// 2.89, 1.88,0,3);//.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
      OPENWORLD.Space.objTurn(citizen2iiin, 270);

      OPENWORLD.BaseObject.setDistanceTrigger(
          citizen2iiin, dist: 3, ignoreifhidden: false, event: (action) {
        if (action) {
          citizen2iiin.visible = true;
          OPENWORLD.Actor.playAction(
              citizen2iiin, action: "work", duration: 2, startat: 0.5);
          OPENWORLD.Actor.wield(citizen2iiin, knifewield.clone(), "Bip01_R_Hand");

          var finishedtime = 45; //OPENWORLD.Math.random()*
          Future.delayed(
              Duration(milliseconds: (finishedtime * 1000).round()), () async {
            if (citizen2iiin.visible) {
              double reachtime = await OPENWORLD.Mob.moveTo(
                citizen2iiin, [
                [ 4.07, 1.36, 0, 0.03],
                //2.96, 1.92,0,0.03],
                [5.17, 1.35, 0, 0.03, 90 + 30]
                //3.80, 1.92, 0, 0.03,90+30]  // Angle to the right so isn't being disrepectful
              ], action: "walkstraightlookright",
                stopaction: "idle3",
                level: 1,
                // delay:finishedtime
                // facedir: false
              );

            }
          });
          //  OPENWORLD.Actor.unwieldAll(citizen2iii,delay:finishedtime);
        } else {
          citizen2iiin.visible = false;
        }
      });

      var citizen22ii = await OPENWORLD.Actor.copyActor(
          citizen22, randomduration: 0.1,
          action: "work"); //    OPENWORLD.Actor.wield(citizen2iii, knife, "Bip01_R_Hand");
      _hotload.add(citizen22ii);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          citizen22ii, 4.185, 1.19, 0,
          3,
          level: 1); //3.15, 1.75,0,3);//3.09, 1.815,0,3);//.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
      OPENWORLD.Space.objTurn(citizen22ii, 270); //180);
      var knife2 = knifewield.clone();
      OPENWORLD.Actor.wield(citizen22ii, knife2, "Bip01_R_Hand");
    }

    // Add obstacle to stop non priests going too far into the temple
    if (gamestart!=GameStart.hearth&&!(gamestart==GameStart.roam&&Glob.roamketoret)) {
      // Only priests can go beyond the court of israel
      var maxx = 4.87+0.05,
          miny = -1.42,
          minx = maxx - 0.2,
          maxy = 2.19;
      OPENWORLD.Obstacles.createObstacle(
          (maxx + minx) / 2, (maxy + miny) / 2, maxx - minx,
          maxy - miny,level:1);//,marker:_hotload);
    }

    // Show the altar fire
    _fire = VolumetricFire(
        Glob.fireWidth, Glob.fireHeight, Glob.fireDepth, Glob.sliceSpacing,
        threeJs.camera);
    await _fire?.init();

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        _fire?.mesh, 4.32, 0.02, 0,
        4, level: 1,
        lerpopacity: 1.0); // 3.29, 0.25, 0, 3); // 3.35, 0.51, 0.3,3); //3.7);
    _fire?.mesh.scale.x = 0.15 * 0.5;
    _fire?.mesh.scale.y =
    OPENWORLD.Time.isNight(OPENWORLD.Time.time) ? 0.1 * 0.5 : 0.4 *
        0.5; // lower flame at night
    _fire?.mesh.scale.z = 0.15 * 0.5;
    _hotload.add(_fire?.mesh);
    OPENWORLD.Updateables.add(_fire);

    print('added fire');


    // add the altar to the eternal flame and if click give information about it
    // the altar is actually just the embers and fire and not a brazier
    _hotload.add(altargreat);

    OPENWORLD.Texture.setNormalMap(
        altargreat, normalsalt, normalScale: 20.0, groupname: "embers");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        altargreat, 4.32, 0.02, 0.00, //-0.005,
        7, level: 1); // 3.25, 0.3, -0.01, 7); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(altargreat, 180);


    var housefire = new VolumetricFire(
        Glob.fireWidth, Glob.fireHeight, Glob.fireDepth, Glob.sliceSpacing,
        threeJs.camera);
    await housefire.init();

    // So dont fall off edge of altar
    var maxx = 4.67, miny = -0.33, minx =  3.89, maxy =0.43;
   // var maxx = 4.64, miny = -0.3, minx =  3.92, maxy =0.39;
    // west side
    OPENWORLD.Obstacles.createObstacle(
        minx, (maxy + miny) / 2, 0.1,//marker:_hotload,
        maxy - miny,level:1);
    // east side
    OPENWORLD.Obstacles.createObstacle(
        maxx, (maxy + miny) / 2, 0.1,//marker:_hotload,
        maxy - miny,level:1);

    // North side
    OPENWORLD.Obstacles.createObstacle(
        (maxx + minx) / 2, maxy, maxx - minx,//marker:_hotload,
       0.1,level:1);

    // South
    OPENWORLD.Obstacles.createObstacle(
        4.04,miny, 0.2,//marker:_hotload,
        0.1,level:1);
    OPENWORLD.Obstacles.createObstacle(
        4.54,miny, 0.2, 0.1,level:1//,marker:_hotload
    );
    OPENWORLD.Obstacles.createObstacle(
        4.32, 0.02, 0.2, 0.2,level:1,//,marker:_hotload
      callback: (obstacle) {
          print("hit altar");
          OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick(['sounds/pain.mp3','sounds/pain2.mp3','sounds/pain3.mp3']),volume: 0.1);
      },
      callbacknextwait: 1
    );
    if (OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      // Great altar light
      var group = THREE.Group();
      var light = new THREE.PointLight(
          0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

      light.intensity = 1.0; // 0.6;
      light.distance = 10.0; //1.2;
      // light.position.y = 0.33;
      /*   light.castShadow=true;
      light.shadow?.mapSize.width = 32;
      light.shadow?.mapSize.height = 32;;
      light.shadow?.camera?.near = 0.01;
      light.shadow?.camera?.far = 3;*/
      OPENWORLD.Light.addFlicker(light);
      group.add(light);
      //  _hotload.add(group);
      _hotload.add(group);

      // For hearth needs to be dist 4 or else have too many lights on down at the hearth - but ok to be bigger otherwise
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          group, 4.32, 0.02, 0, gamestart==GameStart.hearth?4:6, level: 1, lerplight: 1.0);
    }

    OPENWORLD.Texture.setMaterial(altargreat, bronzemat!, groupname: 'gold');

    Glob.showblood=(visible)
    {
      firealtarblood.visible=visible;
      firealtarbloodse.visible=visible;
    };

    /*  OPENWORLD.BaseObject.setHighlight(
        altargreat, threeJs.scene, THREE.Color.fromHex32(0x0000ff),
        0.35); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(
        altargreat, true, scale: 1.05, opacity: 0.2);
    OPENWORLD.BaseObject.setTouchTrigger(altargreat);
    altargreat.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      print("touched");
      OPENWORLD.BaseObject.highlight(
          altargreat, true, scale: 1.02, opacity: 0.35);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The Brazen altar"});
        menuitems.add({"text": "is where burnt animal offerings were made."});
        menuitems.add({
          "text": "The sacrifices were made at atonements for sins of the people."
        });
        menuitems.add(
            {"text": "The fire of the alter is kept lit at all times."});
        menuobj = altargreat;
      });
    });

    OPENWORLD.BaseObject.setDistanceTrigger(altargreat, dist: 0.5);
    altargreat.extra['trigger'].addEventListener(
        'trigger', (THREE.Event event) async {
      if (event.action) {
        OPENWORLD.Sound.play(delay: OPENWORLD.Math.random() * 3,
            path: 'sounds/die.mp3',
            volume: 0.5);
      }
    });
*/



    // south east bundle

    for (var j = 0; j < 3; j++) {
      for (var i = 0; i < 5; i++) {
        instancedWoodbundle.place(
            0, 4.56 - 0.02 * i, -0.2 + 0.02, 0.01 + (j * 0.02), level: 1,
            scale: THREE.Vector3(0.01, 0.01, 0.02)); //,5);
        /*  var woodbundlealtar2 = woodbundle.clone();
        woodbundlealtar2.scale.setValues(0.01, 0.01, 0.02);
        _hotload.add(woodbundlealtar2);
        OPENWORLD.Space.objTurn(woodbundlealtar2, 0);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            woodbundlealtar2, 4.56 - 0.02 * i, -0.2, 0.01 + (j * 0.02),
            3,level:1);*/ // 3.2,2.5, 0.0);
//            woodbundlealtar2, 3.54 - 0.02 * i, 0.04, 0.01+ (j*0.02), 3); // 3.2,2.5, 0.0);

      }
    }
    // south west bundle
    for (var j = 0; j < 2; j++) {
      for (var i = 0; i < 5; i++) {
        instancedWoodbundle.place(
            0, 4.10 - 0.02 * i, -0.2, 0.01 + (j * 0.02), level: 1,
            scale: THREE.Vector3(0.01, 0.01, 0.02)); //,5);

        /* var woodbundlealtar2 = woodbundle.clone();
        woodbundlealtar2.scale.setValues(0.01, 0.01, 0.02);
        _hotload.add(woodbundlealtar2);
        OPENWORLD.Space.objTurn(woodbundlealtar2, 0);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            woodbundlealtar2, 4.10 - 0.02 * i, -0.2, 0.01 + (j * 0.02),
            3,level:1);*/ // 3.2,2.5, 0.0);
        //   woodbundlealtar2, 3.01 - 0.02 * i, 0.04, 0.01+ (j*0.02), 3); // 3.2,2.5, 0.0);

      }
    }

    // north west
    for (var j = 0; j < 2; j++) {
      for (var i = 0; i < 4; i++) {
        instancedWoodbundle.place(
            0, 4.10 - 0.02 * i, 0.2, 0.01 + (j * 0.02), level: 1,
            scale: THREE.Vector3(0.01, 0.01, 0.02)); //,5);

        /*  var woodbundlealtar2 = woodbundle.clone();
        woodbundlealtar2.scale.setValues(0.01, 0.01, 0.02);
        _hotload.add(woodbundlealtar2);
        OPENWORLD.Space.objTurn(woodbundlealtar2, 0);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            woodbundlealtar2, 4.10 - 0.02 * i, 0.2, 0.01 + (j * 0.02),
            3,level:1);*/ // 3.2,2.5, 0.0);
        //   woodbundlealtar2, 3.01 - 0.02 * i, 0.54, 0.01+ (j*0.02), 3); // 3.2,2.5, 0.0);

      }
    }

    // Add the salt pile to the altar
    if (gamestart == GameStart.hearth || gamestart == GameStart.bethphage ||
      //  gamestart == GameStart.womensgate ||
        (gamestart == GameStart.roam &&
        (Glob.roamtamid || Glob.roamketoret))) { //) {
      _hotload.add(saltpile);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          saltpile, 4.165, -0.835, -0.005,
          4, level: 1); //3.124, -0.35, -0.005, 4); // 3.2,2.5, 0.0);
    }


    // In the sanctuary
    // You cannot go into the holy of holies
    maxx = 1.75; miny = 0.12; minx =  0.99; maxy =0.64;
    OPENWORLD.Obstacles.createObstacle(
        (maxx + minx) / 2, (maxy + miny) / 2, maxx - minx,
        maxy - miny,level:1); //,marker:_hotload);
    // Show the minorah
    _hotload.add(menorah);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        menorah, 1.86, 0.25, 0,
        1.5, level: 1); // -0.33+0.7,1.3-0.1, 0.0, 4); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(menorah!, 90);


    var group = THREE.Group();
    THREE.PointLight menorahlight = new THREE.PointLight(
        0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

    menorahlight.intensity = 0.5; // 0.6;
    menorahlight.distance = 1.0; //1.2;
    // light.position.y = 0.33;
    menorahlight.castShadow = true;
    menorahlight.shadow?.mapSize.width = 128;
    menorahlight.shadow?.mapSize.height = 128;
    ;
    menorahlight.shadow?.camera?.near = 0.01;
    menorahlight.shadow?.camera?.far = 0.5;

    OPENWORLD.Light.addFlicker(menorahlight);
    group.add(menorahlight);
    _hotload.add(group);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        group, 1.86, 0.25, 0.1, 1.5, level: 1,
        lerplight: 1.0); //1.46-0.05, 4.22-0.05, 0.0, 3);


    // if( menorahflamemat==null)
    //   print("mennull");
    // else
    //   print("mennotnull");
    // Add message above minorah telling player to click it for info
    /*addMsgToObj(menorah, "Click Minorah", scale: 0.01, z: 3.5);
    // Highlight the minorah to show that can click it
    OPENWORLD.BaseObject.setHighlight(
        menorah, threeJs.scene, THREE.Color.fromHex32(0x0000ff),
        0.25); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(menorah, true, scale: 1.05, opacity: 0.15);
    OPENWORLD.BaseObject.setTouchTrigger(menorah);
    menorah.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      // Display information about the minorah when click it
      print("touched");
      OPENWORLD.BaseObject.highlight(
          menorah, true, scale: 1.05, opacity: 0.25);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The menorah is made of pure gold."});
        menuitems.add(
            {"text": "The design was revealed to Moses by God as follows:"});
        menuitems.add({"text": "'Make a lampstand of pure gold."});
        menuitems.add({
          "text": "Hammer out its base and shaft, and make its flowerlike cups,"
        });
        menuitems.add({"text": "buds and blossoms of one piece with them.'"});
        menuobj = menorah;
      });
    });*/

    // Display and show information about showbread when clicked
    _hotload.add(shewbread);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        shewbread, 1.86, 0.51 + 0.08, 0,
        4, level: 1); //-0.38+0.7, 1.3+0.1, 0.0, 4); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(shewbread, 0);
    OPENWORLD.Texture.setMaterial(shewbread, goldmaterial!, groupname: "gold");

    /* addMsgToObj(shewbread, "Click showbread", scale: 0.005, z: 1);
    OPENWORLD.BaseObject.setHighlight(
        shewbread, threeJs.scene, THREE.Color.fromHex32(0x0000ff),
        0.35); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(shewbread, true, scale: 1.0, opacity: 0.2);
    OPENWORLD.BaseObject.setTouchTrigger(shewbread);
    shewbread.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      print("touched");
      OPENWORLD.BaseObject.highlight(
          shewbread, true, scale: 1.05, opacity: 0.35);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The showbread are cakes of bread that"});
        menuitems.add({"text": "are always present as an offering to God."});
        menuitems.add({"text": "The 12 cakes are baked from fine flour,"});
        menuitems.add({"text": "arranged in two rows on a table"});
        menuitems.add({"text": "each cake was to contain"});
        menuitems.add({"text": "'two tenth parts of an ephah' of flour."});
        menuitems.add({"text": "The table is made of gold"});
        menuobj = shewbread;
      });
    });
    */


    var altar = await OPENWORLD.Model.createModel(
        'assets/models/altar.glb', castshadow: true);
    _hotload.add(altar);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        altar, 1.88, 0.37 + 0.027, 0,
        1.5,
        level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
    altar.scale.setValues(0.03, 0.03, 0.03);
    OPENWORLD.Space.objTurn(altar, 90);
    OPENWORLD.BaseObject.setVisible(
        altar, false, groupname: "embers");
    OPENWORLD.Texture.setMaterial(altar, goldmaterial!, groupname: "altar");

    var smoke1 = Smoke();
    var smokeGroup =
    await smoke1.createSmoke('assets/textures/smoke/clouds64.png');

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smokeGroup, 1.88, 0.37 + 0.028, 0.11,
        3, level: 1); //1.86, 0.62,0.21,3);//-0.42+0.7, 1.35, 0.21, 3);
//        smokeGroup,   1.88, 0.37+0.027,0.21,3);//1.86, 0.62,0.21,3);//-0.42+0.7, 1.35, 0.21, 3);

    smokeGroup.scale.setValues(0.00001, 0.00001, 0.00001);
//    smokeGroup.scale.setValues(0.00003, 0.00003, 0.00003);
//    smokeGroup.scale.setValues(0.00007, 0.00007, 0.00007);
    OPENWORLD.Updateables.add(smoke1);
    _hotload.add(smokeGroup);
    smokeGroup.visible = false;
    OPENWORLD.Space.removeObjFromHide(smokeGroup);

    /*
        // Show and display information when altar is clicked

    OPENWORLD.BaseObject.setHighlight(
        altar, threeJs.scene, THREE.Color.fromHex32(0x0000ff),
        0.35); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(altar, true, scale: 1.0, opacity: 0.2);
    OPENWORLD.BaseObject.setTouchTrigger(altar);
    addMsgToObj(altar, "Click altar", scale: 0.002, z: 0.3);
    altar.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      print("touched");
      OPENWORLD.BaseObject.highlight(altar, true, scale: 1.05, opacity: 0.35);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add(
            {"text": "The altar of incense is made of shittim wood"});
        menuitems.add({"text": "and is covered in pure gold. "});
        menuitems.add({"text": "As God said in Exodus:"});
        menuitems.add(
            {"text": "'Place it in front of the curtain that is over'"});
        menuitems.add(
            {"text": "the Ark of the Pact—in front of the cover that is"});
        menuitems.add({"text": "over the Pact—where I will meet with you.'"});
        menuobj = altar;
      });
    });
*/

    // General code to do the ketoret
    // Shared by hearth, bethphage and roam ketoret
    // Can handle no priestassistant as in the case of heath which is  where you just follow your friend
    Glob.ketoret =
        (priestfirepanget, priestfirepan, priestassistant, priestincense,
        {callbackapproachhewnstone, callbackonfinish}) async {
          Glob.showblood!(true);

          setState(() {
            roomname='Ketoret\nCollection of ash from the great altar';
          });

      // Priest who gets the gold firepan and puts it at the bottom of the ramp
      OPENWORLD.BaseObject.setCastShadow(priestfirepanget, true);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          priestfirepanget, 4.02, -0.5, 0,
          3, level: 1);
      var firepangoldwield = firepan.clone();
      OPENWORLD.Texture.setMaterial(firepangoldwield, goldmaterial!);
      firepangoldwield.scale.setValues(
          4.5, 4.5, 4.5); // Little bit smaller than the other firepan

      OPENWORLD.Space.setTurnPitchRoll(firepangoldwield, 90, -90, 0);
      OPENWORLD.Actor.playAction(
          priestfirepanget, action: "idlehold");
      OPENWORLD.Actor.wield(priestfirepanget, firepangoldwield, "Bip01_R_Hand");
      var firepangoldground = firepan.clone();
      OPENWORLD.Texture.setMaterial(firepangoldground, goldmaterial!);

      print("ketoret start firepanget move");
      OPENWORLD.Mob.moveTo(
          priestfirepanget,
          [
            [4.08, -1.28, 0, 0.02],
            [4.3, -1.28 - 0.02, 0, 0.02]  //bottom of ramp
          ], action: "walkhandright",
          stopaction: "stoopidle",
          surfaceonly: true,
          level: 1,
          callbackonfinish: (actor) {
            setState(() {
              roomname='Ketoret\nCollection of ash from the great altar';
            });
            OPENWORLD.Actor.unwield(priestfirepanget, "Bip01_R_Hand");
            OPENWORLD.Space.objTurnLerp(priestfirepanget, 0, 1);
            Future.delayed(Duration(milliseconds: 1000), () async {
              _hotload.add(firepangoldground); // delay when drop the firepan
            });
            firepangoldground.scale.setValues(0.008, 0.008, 0.008);
            OPENWORLD.Space.worldToLocalSurfaceObjHide(
                firepangoldground, 4.3, -1.28, 0.005, level: 1, 1);
            OPENWORLD.Space.objTurn(firepangoldground, 0);
            //  OPENWORLD.Actor.playAction(
            //     priestfirepanget, action: "idlehold",delay:2);
            OPENWORLD.Mob.moveTo(
                priestfirepanget,
                [
                  // [4.93,-1.52,0,0.02],
                  [4.92, -1.4, 0, 0.02],
                  [4.94+0.05, -1.57, 0, 0.02]  // back in the hewnstone
                ], action: "walkstraight",
                stopaction: "idlestraight",
                surfaceonly: true,
                level: 1,
                delay: 2,
                callbackonfinish: (actor) {
                  OPENWORLD.Space.objTurnLerp(priestfirepanget, 0, 1);
                });
          });
      if (priestassistant != null) {
        OPENWORLD.BaseObject.setCastShadow(priestassistant, true);
        OPENWORLD.Mob.moveTo(
            priestassistant,
            [
              [4.93, -1.52, 0, 0.02],
              [ 4.85, -1.29, 0, 0.02]
            ], action: "walkstraight",
            stopaction: "idlestraight",
            surfaceonly: true,
            level: 1,
            delay: 4,
            callbackonfinish: (actor) {
              OPENWORLD.Space.faceObjectAlways(priestassistant, priestfirepan);
            });
      }
      OPENWORLD.BaseObject.setCastShadow(priestincense, true);
      OPENWORLD.Mob.moveTo(
          priestincense,
          [
            [4.93, -1.52, 0, 0.02],
            [ 4.95, -1.29, 0, 0.02]  // outside chamber of hewnstone
          ], action: "walkstraight",
          stopaction: "idlestraight",
          surfaceonly: true,
          level: 1,
          delay: 4,
          callbackonfinish: (actor) {
            if (priestassistant == null) { // If you are following the incense priest then turn camera to firepan priest

              //OPENWORLD.Space.faceObjectLerp(threeJs.camera, priestfirepan, 1);
              OPENWORLD.Space.objTurnLerp(threeJs.camera,293,1);
              OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                 threeJs.camera,5.01, -1.35, OPENWORLD.Camera.cameraoffset,1, level: 1); //4.96, -1.33
              OPENWORLD.Space.faceObjectLerp(priestincense,threeJs.camera,1);
              OPENWORLD.Space.faceObjectLerp(priestincense,threeJs.camera,1, delay:10);
              OPENWORLD.Space.faceObjectAlways(priestincense, priestfirepan, delay:15);

              OPENWORLD.Mob.setSpeech(priestincense, [
                "The priest collects",
                "ash from the altar",
                "and puts it into the",
                "firepan placed at the",
                "bottom of the altar.",
                "Then the other priest",
                "places the ashes into",
                "firepan and we follow",
                "him to the sanctuary",
                "and burn the incense",
                "with the ash."
              ], z: 80,
                  width: 300,
                  scale: 0.2,
                  randwait: 0,
                  clearwhendone: true);


                  // OPENWORLD.Space.objForwardLerp(threeJs.camera, 0.1, 1, level: 1,
              //    z: OPENWORLD.Camera.cameraoffset); // 4.95, -1.35
            } else
              OPENWORLD.Space.faceObjectAlways(priestincense, priestfirepan);

          });
      var vesselspoon = null;
      if (priestassistant != null) {
        vesselspoon = await OPENWORLD.Model.createModel(
            'assets/models/vesselspoon.glb');
        OPENWORLD.Texture.setMaterial(vesselspoon, goldmaterialnormal!);

        OPENWORLD.Space.setTurnPitchRoll(
            vesselspoon, 0, 90, 90 + 90); //walkstraight is good!
//    OPENWORLD.Space.setTurnPitchRoll(vesselspoon, 45, 90,90+45);
//      OPENWORLD.Space.setTurnPitchRoll(vesselspoon, 0, 130, 100);

        // for walkstraight

        vesselspoon.position.z = 4.0; // forward (reverse)
//    vesselspoon.position.y = 5.0;//  left right
        vesselspoon.position.x = 5.0; // up down

        //   OPENWORLD.Actor.wield(priestassistant,groupi, "Bip01_L_Hand");
        OPENWORLD.Actor.wield(priestassistant, vesselspoon, "Bip01_L_Hand");
        var vesselbazichketoret = await OPENWORLD.Model.createModel(
            'assets/models/vesselbazichketoret.glb');
        OPENWORLD.Texture.setMaterial(vesselbazichketoret, goldmaterial!);
        vesselbazichketoret.position.z =
        -14.0; // 14.0; //5.0;    // y forward  x up
        vesselspoon.add(vesselbazichketoret);
      }

      var firepanwield = firepan.clone();
      firepanwield.scale.setValues(5.0, 5.0, 5.0);

      //   OPENWORLD.Space.resetPosRot(firepanwield);
      OPENWORLD.Space.setTurnPitchRoll(firepanwield, 90, -90, 0);
      //OPENWORLD.Space.setTurnPitchRoll(firepanwield, 150, -90, -45);
      //OPENWORLD.Actor.playAction(
      //    priestfirepan, action: "idlehold");

      OPENWORLD.Actor.wield(priestfirepan, firepanwield, "Bip01_R_Hand");

      // Firepan priest collect coals
      var priestspeed = 0.03;
      var friendpos = OPENWORLD.Space.localToWorldObj(priestfirepan);
      print("priest firepan pos"+friendpos.toString());
      OPENWORLD.Mob.moveToLoop(priestfirepan,
          [
            {'p': [friendpos.x,friendpos.y, 0], 'v': priestspeed},
            {'p': [4.91, -1.5, 0], 'v': priestspeed},
            {'p': [4.91, -1.28, 0], 'v': priestspeed},
            {'p': [4.3, -1.28, 0], 'v': priestspeed},
            {'p': [4.3, -0.13, 0], 'v': priestspeed},
            {'action': "stoopidle", "time": 3, "callback": (actor) {
              OPENWORLD.BaseObject.setVisible(
                  firepanwield, true, groupname: "ash");
              var embers = OPENWORLD.Texture.getMaterialByGroupname(
                  altargreat, "embers");
              OPENWORLD.Texture.setMaterial(
                  firepanwield, embers, groupname: "ash");
            } // at top of altar so scoop up embers
            },
            {
              'p': [4.3, -1.28 + 0.07, 0],
              'v': priestspeed,
              "callback": (actor) {
                OPENWORLD.Space.setTurnPitchRoll(firepanwield, 150, -90, -45);

                OPENWORLD.BaseObject.setVisible(
                    firepanwield, false, groupname: "ash");
                OPENWORLD.BaseObject.setVisible(
                    firepangoldground, true, groupname: "ash");
                var embers = OPENWORLD.Texture.getMaterialByGroupname(
                    altargreat, "embers");
                OPENWORLD.Texture.setMaterial(
                    firepangoldground, embers, groupname: "ash");
                OPENWORLD.Actor.unwield(priestfirepan, "Bip01_R_Hand");

                // Drop your silver pan
                Future.delayed(Duration(milliseconds: 1000), () async {
                  var firepanground = firepan.clone();
                  _hotload.add(firepanground);
                  firepanground.scale.setValues(0.01, 0.01, 0.01);
                  OPENWORLD.Space.worldToLocalSurfaceObjHide(
                      firepanground, 4.3 - 0.03, -1.28 + 0.05, 0.005, level: 1,
                      1);
                  OPENWORLD.Space.objTurn(firepanground, 180);
                  OPENWORLD.BaseObject.setVisible(
                      firepangoldground, false);
                  OPENWORLD.Space.removeObjFromHide(firepangoldground);
                  var firepangoldwield2 = firepangoldwield.clone();
                  OPENWORLD.Actor.wield(
                      priestfirepan, firepangoldwield2, "Bip01_R_Hand",
                      delay: 1);
                  priestfirepan.extra['firepanwield'] = firepangoldwield2;
                  OPENWORLD.BaseObject.setVisible(
                      firepangoldwield2, true, groupname: "ash");
                  var embers = OPENWORLD.Texture.getMaterialByGroupname(
                      altargreat, "embers");
                  OPENWORLD.Texture.setMaterial(
                      firepangoldwield2, embers, groupname: "ash");
                });
              }
            },
            // back at bottom of ramp to place the embers
            {'action': "stoopidle", "time": 2},
            {'action': "idlehold", "time": 0.5},
            {'p': [4.78, -1.24, 0], 'v': priestspeed, "callback": (actor) {
              if (priestassistant != null) {
                OPENWORLD.Space.removeFaceObjectAlways(priestassistant);
                OPENWORLD.Mob.moveTo(
                    priestassistant,
                    [
                      [ 4.85, 0.6, 0, priestspeed],
                      [3.96, 0.6 - 0.04, 0, priestspeed],
                      //north west altar corner
                      //     [ 3.14, 0.35, 0, priestspeed]  // sanctuary entrance
                      [ 2.95, 0.35, 0, priestspeed]
                      // sanctuary entrance

                    ], action: "walkstraight",
                    stopaction: "idlestraight",
                    surfaceonly: true,
                    level: 1,
                    delay: 10,
                    callbackonfinish: (actor) {
                      // OPENWORLD.Space.faceObjectAlways(priestassistant, priestfirepan);
                    });
              }
              OPENWORLD.Space.removeFaceObjectAlways(priestincense);
              setState(() {
                roomname='Ketoret\nTaking the ash to the sanctuary';
              });

              OPENWORLD.Mob.moveTo(
                  priestincense,
                  [
                    [ 4.95, 0.6, 0, priestspeed],
                    [ 4.85, 0.69, 0, priestspeed * 1.8],
                    [3.96, 0.69 - 0.04, 0, priestspeed],
                    //north west altar corner
                    // [ 3.14, 0.46, 0, priestspeed]  // sanctuary entrance
                    [ 2.95, 0.4, 0, priestspeed]
                    // sanctuary entrance

                  ], action: "walkstraight",
                  stopaction: "idlestraight",
                  surfaceonly: true,
                  level: 1,
                  delay: 10,
                  callbackonfinish: (actor) {
                    if (priestassistant ==
                        null) { // Move following player next to the incense priest
                      OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                          threeJs.camera, 2.98 - 0.03, 0.49,
                          OPENWORLD.Camera.cameraoffset, 2, level: 1);
                      OPENWORLD.Space.objTurnLerp(threeJs.camera, 270, 1);
                      OPENWORLD.Space.objTurnLerp(
                          threeJs.camera, 270, 1, delay: 1);
                      //OPENWORLD.Space.objTurnLerp(threeJs.camera, 290, 1,delay:2);
                      // OPENWORLD.Space.faceObjectLerp(threeJs.camera,priestfirepan, 1, delay:1);

                      //OPENWORLD.Space.faceObjectAlways(priestincense, priestfirepan);
                    }
                  });
            }
            },
            // close to outside of chamber of hewn stone
            {'p': [4.9, 0.58, 0], 'v': priestspeed},
            // north east corner of altar
            {'p': [3.85, 0.58, 0], 'v': priestspeed},
            // north west corner of alatar
            {'p': [3.14, 0.42, 0], 'v': priestspeed},
            // entrance sanctuary
            {'p': [1.92, 0.4, 0], 'v': priestspeed},
            // at altar
            {"action": "work", "time": 5, "callback": (actor) {
              OPENWORLD.BaseObject.setVisible(
                  altar, true, groupname: "embers");
              smokeGroup.visible = true;
              OPENWORLD.Space.readdObjFromHide(smokeGroup);
              OPENWORLD.BaseObject.setVisible(
                  priestfirepan.extra['firepanwield'], false, groupname: "ash");
              // If bethphage then you can't go into the ketoret so make it faster so doesn't get too boring
              var v;
              if (gamestart!=GameStart.bethphage)
                v=0.03;
              else
                v=0.1; // make it faster for bethphage so dont stand out there for ever
              if (priestassistant != null) {
                // This is the old ketoret for the assistant with the bazich
                OPENWORLD.Mob.moveToLoop(priestassistant,
                    [
                      {'p': [2.95, 0.35, 0], 'v': v},//priestspeed},
                      // start at the santuary entrance like you did in the old ketoret
                      {'p': [ 1.92, 0.34, 0], 'v':v},// priestspeed},
                      {
                        "action": "idlestraight",
                        'time': 5,
                        "duration": 2,
                        "t": 0
                      },
                      {
                        "action": "bazichpour",
                        'time': 5,
                        "duration": 5,
                        "t": 0,
                        "callback": (actor) {
                          print("in assistant leave");

                          OPENWORLD.Space.setTurnPitchRoll(
                              vesselspoon, 0, 90,
                              90 + 90); //walkstraight is good!
                          //    OPENWORLD.Space.setTurnPitchRoll(vesselspoon, 45, 90,90+45);
                          //      OPENWORLD.Space.setTurnPitchRoll(vesselspoon, 0, 130, 100);

                          // for walkstraight

                          vesselspoon.position.z = 4.0; // forward (reverse)
                          //    vesselspoon.position.y = 5.0;//  left right
                          vesselspoon.position.x = 5.0; // up down

                        }
                      },
                      {
                        'p': [ 2.95, 0.35, 0],  // inside sanctuary
                        'v': v,//priestspeed,
                        "t": 45,
                        "duration": 2.0,
                        "action": "walkstraightlookleft"
                      },
                      // { "action": "idlestraight", "t": 270},
                      //     {'p': [ 2.95, 0.35, 0], 'v':priestspeed},  // sanctuary entrance
                      {'p': [3.96, 0.6 - 0.04, 0], 'v': priestspeed},
                      //north west altar corner
                      {'p': [ 4.85, 0.6, 0], 'v': priestspeed},
                      {'p': [ 4.85, -1.29, 0], 'v': 0.02},
                      {
                        'p': [
                          Glob.priestassistantposx,
                          Glob.priestassistantposy,
                          0
                        ],
                        'v': 0.02
                      },
                      // inside the chamber of the hewnstone
                      {"action": "idlestraight", "t": 0, "time": 1}

                      //     [ 3.14, 0.35, 0, priestspeed]  // sanctuary entrance

                    ],
                    //    duration:0.7,
                    //  index:0,
                    randomduration: 0.1,
                    level: 1,
                    looptype: OPENWORLD.Mob.LoopTypeStop,
                    //  reverseloop:true,
                    surfaceonly: true,
                    action: "walkstraight" //straight"
                );
              }
              // This is the old code for ketoret for the priest incense
              OPENWORLD.Mob.moveToLoop(priestincense,
                  [
                    {'p': [2.95, 0.43, 0], 'v': v},//priestspeed},
                    // start at the santuary entrance like you did in the old ketoret
                    {'p': [1.92, 0.4, 0], 'v': v},//priestspeed},
                    {
                      "action": "idlestraight",
                      'time': 5,
                      "duration": 2,
                      "t": priestassistant != null ? 180 : 270,
                      "callback": (actor) {
                        if (priestassistant != null) {
                          print("in incense");
                          //bazich
                          OPENWORLD.Space.setTurnPitchRoll(
                              vesselspoon, -90 + 30, -90, 0); // 90+90+10,90);
                          vesselspoon.position.z = 0.0; // up down
                          vesselspoon.position.y = 0.0; //  left right
                          vesselspoon.position.x = -10.0; // up down
                        } else {
                          friendhearth.extra['followhearth'] = false;
                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                              threeJs.camera, 1.92, 0.34,
                              OPENWORLD.Camera.cameraoffset, 1, level: 1);
                          OPENWORLD.Space.objTurnLerp(threeJs.camera, 0, 1);
                          OPENWORLD.Space.objTurnLerp(friendhearth, 180, 1);
                          OPENWORLD.Space.objForwardLerp(
                              threeJs.camera, -0.1, 1, level: 1,
                              z: OPENWORLD.Camera.cameraoffset,
                              delay: 6);

                          // OPENWORLD.Space.faceObjectLerp(threeJs.camera,priestincense, 1);

                        }
                      }
                    },
                    { "action": "handsouttogether", 'time': 5, "t": 180},
                    { "action": "handsouttogether", 'time': 5, "t": 270},
                    {
                      "action": "handsouttogetherforward",
                      "duration": 0.5,
                      'time': 0.5,
                      "t": 270,
                      "callback": (actor) {
                        print("in incense thrown");

                        if (OPENWORLD.Space.getDistanceBetweenObjs(actor, threeJs.camera)<1)
                          OPENWORLD.Sound.play(path: 'sounds/incensethrow.mp3', volume: 1);
                        setState(() {
                          roomname='Ketoret\nIncense has been thrown onto the embers on the altar';
                        });

                        smokeGroup.scale.setValues(0.00006, 0.00006, 0.00006);
                      }
                    },
                    {
                      "action": "idlestraight",
                      'time': 6,
                      "duration": 2,
                      "t": 270,
                      "callback": (actor) {
                        if (gamestart==GameStart.hearth)
                          friendhearth.extra['followhearth'] = true;
                      }
                    },
                    {
                      'p': [2.95, 0.4, 0], // still inside sanctuary
                      'v':v,// priestspeed,
                      "t": 45,
                      "duration": 2.0,
                      "action": "walkstraightlookleft"
                    },
                    // { "action": "idlestraight", "t": 270},
                    {"p": [3.96, 0.69 - 0.04, 0], "v":  priestspeed},  // outside sanctuary
                    //north west altar corner
                    {"p": [ 4.85, 0.69, 0], "v": priestspeed * 1.8},
                    {"p": [ 4.95, 0.6, 0], "v": priestspeed},
                    {"p": [ 4.95, -1.29, 0], "v":priestspeed,
                      "callback":(actor){
                      if (callbackapproachhewnstone!=null)
                        callbackapproachhewnstone();
                      }
                    },
                    // outside chamber of hewnstone
                    {
                      "p": [ Glob.priestincenseposx, Glob.priestincenseposy, 0],
                      "v": priestspeed
                    },
                    // Inside chamber of hearth at start pos
                    {
                      "action": "idlestraight",
                      "t": 0,
                      "time": 1,
                      "callback": (actor) {
                        print("finished ketoret");
                        if (priestassistant == null) {
                          // Put the player back to their starting pos
                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                              threeJs.camera, 4.85, -1.48,
                              OPENWORLD.Camera.cameraoffset, 1, level: 1,
                              delay: 2);

                          OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                              threeJs.camera,Glob.ketoretstartposx,Glob.ketoretstartposy,// Glob.priestassistantposx,
                            //  Glob.priestassistantposy,
                              // friendhearthx-0.05,Glob.tamidhewnstonepriestposy,
                              OPENWORLD.Camera.cameraoffset, 1, level: 1,
                              delay: 4);
                          OPENWORLD.Space.worldToLocalSurfaceObj(
                              threeJs.camera,Glob.ketoretstartposx,Glob.ketoretstartposy,// Glob.priestassistantposx,
                              //  Glob.priestassistantposy,
                              // friendhearthx-0.05,Glob.tamidhewnstonepriestposy,
                              OPENWORLD.Camera.cameraoffset,  level: 1,
                              delay: 5);
                          OPENWORLD.Space.objTurnLerp(
                              threeJs.camera, 0, 1, delay: 4);
                        }
                        if (callbackonfinish != null) {

                          Future.delayed(
                              Duration(milliseconds: 5000), () async {
                            callbackonfinish();
                          });
                        };
                      }
                    }


                  ],
                  //    duration:0.7,
                  //  index:0,
                  randomduration: 0.1,
                  level: 1,
                  looptype: OPENWORLD.Mob.LoopTypeStop,
                  //  reverseloop:true,
                  surfaceonly: true,
                  action: "walkstraight" //straight"
              );
            }},
            {'p': [3.14, 0.42 + 0.1, 0], 'v': priestspeed},
            // entrance sanctuary - dodge the priest incense
            {'p': [3.85, 0.58, 0], 'v': priestspeed},
            // north west corner of altar
            {'p': [4.9, 0.58, 0], 'v': priestspeed},
            // north east corner of altar
            {'p': [4.9, -1.62, 0], 'v': priestspeed},  // ketoret
            // chamber of the henw stone
            {"action": "idlestraight", "t": 0, "time": 1}

          ],
          //    duration:0.7,
          //  index:0,
          randomduration: 0.1,
          level: 1,
          looptype: OPENWORLD.Mob.LoopTypeStop,
          //  reverseloop:true,
          surfaceonly: true,
          action: "walkhandright" //straight"
      );

    };

    // General code for the final part of the tamid where put meat that has been left ont he ramp into the altar fire
    // This is shared by hearth, bethphage
    // hewnstonepriestlist is the 9 priests who pick up the meat
    Glob.tamidfinal = (hewnstonpriestlist, {callbackonfinish}) async {
      var trumpeter = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(priestlist), randomduration: 0.1,
          action: "idlestraight"); //armsidle");
      _hotload.add(trumpeter);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          trumpeter, 4.98 - 0.09 - 0.02 - 0.13, -1.61 - 0.03 - 0.03, 0,
          3, level: 1);
      OPENWORLD.Space.objTurn(trumpeter, 0);

      var trumpetwield = trumpet.clone();
      OPENWORLD.Space.setTurnPitchRoll(trumpetwield, -90, 0, 0);
      trumpetwield.position.z=-1.0;
      OPENWORLD.Actor.wield(trumpeter, trumpetwield, "Bip01_R_Hand");
      OPENWORLD.Mob.moveTo(
          trumpeter, [
        [ 4.91 - 0.03, -1.58, 0, 0.02],
        //2.96, 1.92,0,0.03],
        [ 5.0 - 0.03, 0.47, 0, 0.02],
        [ 5.0, 0.47, 0, 0.02],
//            [4.91-Glob.sixpriestsdiff*(hewnstonpriestlist.length-i), -1.28, 0, 0.03],
      ], action: "walkstraightlookleft",
          stopaction: "idlestraight",
          level: 1,
          delay: 60,
          callbackonfinish: (actor) {
            OPENWORLD.Space.objTurn(trumpeter, 270);
            OPENWORLD.Space.objTurnLerp(trumpeter, 270, 1);
          });

      var trumpeter2 = await OPENWORLD.Actor.copyActor(
          OPENWORLD.Math.randPick(priestlist), randomduration: 0.1,
          action: "idlestraight"); //armsidle");
      _hotload.add(trumpeter2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          trumpeter2, 4.98 - 0.09 - 0.02 + 0.16, -1.61 - 0.03 - 0.03, 0,
          3, level: 1);
      OPENWORLD.Space.objTurn(trumpeter2, 0);

      OPENWORLD.Actor.wield(trumpeter2, trumpetwield.clone(), "Bip01_R_Hand");
      OPENWORLD.Mob.moveTo(
          trumpeter2, [
        [ 4.91 + 0.03, -1.58, 0, 0.02],
        //2.96, 1.92,0,0.03],
        [ 5.0, 0.24, 0, 0.02],
//            [4.91-Glob.sixpriestsdiff*(hewnstonpriestlist.length-i), -1.28, 0, 0.03],
      ], action: "walkstraightlookleft",
          stopaction: "idlestraight",
          level: 1,
          delay: 60,
          callbackonfinish: (actor) {
            OPENWORLD.Space.objTurnLerp(trumpeter2, 270, 1);
            //  OPENWORLD.Actor.wield(trumpeter, trumpetwield, "Bip01_R_Hand");

          });


      for (var priest in hewnstonpriestlist) {
        var friendpos = OPENWORLD.Space.localToWorldObj(priest);
        priest.extra['dist'] = OPENWORLD.Math.vectorDistance(friendpos, THREE.Vector3(4.91, -1.28, 0.0));
        OPENWORLD.BaseObject.setCastShadow(priest, true);
      }
      hewnstonpriestlist.sort((a, b) {
        num distA = a.extra['dist'] ?? 0;
        num distB = b.extra['dist'] ?? 0;
        //   return distB.compareTo(distA);
        return distA.compareTo(distB);
      });
      var sixpriests = [];
      for (var i = 0; i < 6; i++) {
        sixpriests.add(hewnstonpriestlist[i]);
        hewnstonpriestlist[i].extra.remove('threepriest');
        hewnstonpriestlist[i].extra['priestnum'] = i;
        if (i == 5) {
          OPENWORLD.Space.setTurnPitchRoll(vesselbazichtamid, 0, 130, 100);
          vesselbazichtamid.position.z = 0.0; //-4.0;
          vesselbazichtamid.position.y = 7.0; //5.0;
          vesselbazichtamid.position.x = 0.0;
          OPENWORLD.Actor.wield(
              hewnstonpriestlist[i], vesselbazichtamid, "Bip01_L_Hand");
        }
      }
      var threepriests = [];
      for (var i = 0; i < 3; i++) {
        threepriests.add(hewnstonpriestlist[i + 6]);
        hewnstonpriestlist[i + 6].extra['priestnum'] = i;
        hewnstonpriestlist[i + 6].extra['threepriest'] = true;
      }
      var priestlibation = threepriests[2];

      for (var i = 0; i < hewnstonpriestlist.length; i++) {
        var priest = hewnstonpriestlist[i];
        // move every hewnstone priest in a line outside hewnstone
        print("start move tamidfinalpriest"+i.toString());
        OPENWORLD.Mob.moveTo(
            priest, [
          [ 4.91, -1.58, 0, 0.02],
          //2.96, 1.92,0,0.03],
          [4.91, -1.28, 0, 0.03], // door outside hewnstone
          [4.91 - 0.05 * (hewnstonpriestlist.length - i), -1.28, 0, 0.03],
//            [4.91-Glob.sixpriestsdiff*(hewnstonpriestlist.length-i), -1.28, 0, 0.03],
        ], action: "walkstraight",
            stopaction: "idlestraight",
            level: 1,
            delay: i * 2 + 10,
            callbackonfinish: (actor) {
              // only when the last in line do you start them walking up the altar
              if (actor.extra['priestnum'] == 2 &&
                  actor.extra.containsKey('threepriest')) {
                for (var j = 0; j < hewnstonpriestlist.length; j++) {
                  var priest = hewnstonpriestlist[j];
                  // Have finished lining up
                  var friendpos = OPENWORLD.Space.localToWorldObj(priest);
                  // Future.delayed(Duration(milliseconds: i*5000), () async {
                  List<Map> actions = [
                    {"p": [friendpos.x, friendpos.y, 0], "v": 0.02,},
                    // Outside Chamber of hewnstone

                    {
                      "p": [ 4.25, -1.28, 0],
                      "v": 0.02,
                      //  "t": 90 - 30,
                      "action": "walkstraight", //lookleft",
                      "duration": 1.5
                    },
                    // bottom of the ramp //3.26, -0.87
                    {
                      "p": [ 4.22, -0.84 - priest.extra['priestnum'] * 0.04, 0],
                      "v": 0.02,
                      "t": -30,
                      "action": "walkstraightlookleft",
                      "duration": 1.5
                    },
                    // part of the way up ramp to drop of meat
                    //  {"p":[  3.16, -0.39-0.04-priest.extra['priestnum']*0.04, 0],"v": 0.02,"t":-30,"action":"walkstraightlookleft", "duration":1.5},  // part of the way up ramp to drop of meat
                    {
                      "action": "kneel",
                      "time": 3.0,
                      "t": 270,
                      'callback': (actor) {
                        print("priest pickup");
                        if (!actor.extra.containsKey('threepriest')) {
                          if (actor.extra['priestnum'] != 5) {
                            var meat1ind = actor.extra['priestnum'] * 2;
                            THREE.Object3D meati = Glob
                                .meatlist[meat1ind]; //actor.extra['priestnum']];
                            _hotload.remove(meati);
                            var meat = meati.clone();
                            Glob.meatlist[meat1ind] = meat;
                            OPENWORLD.Actor.wield(actor, meat, "Bip01_R_Hand");
                            OPENWORLD.Space.setTurnPitchRoll(meat, 0, 0, 180);
                            meat.position.setValues(0.0, 0.0, 0.0);
                            meat.scale.setValues(0.7, 0.7,
                                0.7); //1.0, 1.0, 1.0);
                            var meat2ind = actor.extra['priestnum'] * 2 + 1;
                            THREE.Object3D meat2i = Glob
                                .meatlist[meat2ind]; //actor.extra['priestnum']];
                            _hotload.remove(meat2i);
                            var meat2 = meat2i.clone(); // why must I do this?
                            Glob.meatlist[meat2ind] = meat2;
                            OPENWORLD.Actor.wield(actor, meat2, "Bip01_L_Hand");
                            OPENWORLD.Space.setTurnPitchRoll(meat2, 0, 0, 180);
                            meat2.position.setValues(0.0, 0.0, 0.0);
                            meat2.scale.setValues(
                                0.7, 0.7, 0.7); //1.0, 1.0, 1.0);
                          } else {
                            for (var i = Glob.meatlist.length - 1 - 5; i < Glob
                                .meatlist.length; i++)
                              _hotload.remove(Glob.meatlist[i]);
                          }
                        } else {
                          print("three priest pick up item"+actor.extra.toString());
                         // if (vessellist[actor.extra['priestnum']].extra.containsKey('vesselground')) {
                            vessellist[actor.extra['priestnum']].extra['vesselground'].visible = false;
                            OPENWORLD.Space.removeObjFromHide(vessellist[actor.extra['priestnum']].extra['vesselground']);
                        //  }
                          threepriestwield(actor, actor.extra['priestnum']); //, clone:true);
                        }

                      }
                    },
                    {
                      "p": [ 4.22, -0.84, 0],
                      "v": 0.02,
                      "t": -30,
                      "action": "walkstraightlookleft",
                      "duration": 1.5
                    }
                  ];

                  if (priest == priestlibation) { //priest.extra['priestnum']==2&&priest.extra.containsKey('threepriest')) {
                    // libation bearer priest
                    actions.add({
                      "p": [4.22, Glob.libationbowlposy, 0],
                      "v": 0.02,
                      "action": "walkstraightlookleft",
                      "duration": 1.5,
                      "t": -30
                    }); // top of ramp
                    actions.add({"action": "idlestraight", "time": 20});
                    actions.add({
                      "p": [
                        Glob.libationbowlposx + 0.03,
                        Glob.libationbowlposy,
                        0
                      ],
                      "v": 0.02,
                      "action": "walkstraightlookright",
                      "duration": 1.5,
                      "t": 90 + 30
                    }); // libation bowl
                    actions.add(
                        {"action": "idlestraight", "t": 270, "time": 1});
                  } else {
                    actions.add({
                      "p": [4.22, -0.13, 0],
                      "v": 0.02,
                      "action": "walkstraightlookleft",
                      "duration": 1.5,
                      "t": -30
                    }); // top of ramp
                    actions.add({
                      "p": [ 4.31, -0.13, 0], "v": 0.02,
                      "t": 60,
                      "action": "walkstraightlookleft",
                      "duration": 1.5
                    });
                    actions.add(
                        {
                          "action": !priest.extra.containsKey('threepriest')
                              ? "worklow"
                              : "idlehold",
                          "time": 1,
                          "t": 0,
                          "callback": (actor) {
                            if (actor.extra['priestnum'] < 5 &&
                                !actor.extra.containsKey('threepriest')) {
                              OPENWORLD.Actor.unwield(actor, "Bip01_R_Hand");
                              OPENWORLD.Actor.unwield(actor, "Bip01_L_Hand");
                              OPENWORLD.Actor.playAction(
                                  actor, action: "worklow");
                            } else if (actor.extra.containsKey('threepriest')) {
                              if (actor.extra['priestnum'] == 0)
                                OPENWORLD.BaseObject.setVisible(
                                    priest.extra['vesselwield'], false,
                                    groupname: "flour");
                              else if (actor.extra['priestnum'] == 1)
                                OPENWORLD.BaseObject.setVisible(
                                    priest.extra['vesselwield'], false,
                                    groupname: "showbread");
                            }
                          }
                        });
                    actions.add({
                      "p": [ 4.31, -1.28, 0], "v": 0.04,
                      "t": 210,
                      "action": "walkstraightlookright",
                      //  "duration": 1.5
                    }); // bottom of ramp
                    actions.add({
                      "p": [ 5, -1.28, 0], "v": 0.04,
                      "t": 90 - 30,
                      "action": "walkstraightlookleft",
                      "duration": 1
                    }); // outside chamber of hewnstone
                    actions.add({
                      "p": [
                        5 + OPENWORLD.Math.randFloatSpread(0.01),
                        OPENWORLD.Math.randFloatSpread(0.01) - j * 0.04,
                        0
                      ], "v": 0.04,
                      "t": -30,
                      "action": "walkstraightlookleft",
                      "duration": 1
                    }); // outside chamber of hewnstone
                    actions.add({
                      "action": "idlestraight",
                      "t": 270 + OPENWORLD.Math.randFloatSpread(30),
                      "time": 1,
                      "callback": (actor) {
                        //  print("reached end"+actor.extra.toString());
                        if (actor.extra['priestnum'] == 1 &&
                            actor.extra.containsKey('threepriest')) {
                          // print("reached end right end");
                          // Last priest arrived at their spot so end the tamid
                          OPENWORLD.Actor.unwield(
                              priestlibation, "Bip01_L_Hand");
                          OPENWORLD.Actor.playActionThen(
                              priestlibation, "kneel", "prostrate",
                              duration: 3);
                          OPENWORLD.Actor.playAction(
                              trumpeter, action: "hornidle", delay: 3);
                          OPENWORLD.Actor.playAction(
                              trumpeter2, action: "hornidle", delay: 3);
                          OPENWORLD.Sound.play(path: 'sounds/trumpets.mp3', volume: 1,delay:3);
                          for (var priest in hewnstonpriestlist) {
                            if (priest != priestlibation) {
                              if (priest.extra.containsKey("wielding")) {
                                OPENWORLD.Actor.unwield(priest, "Bip01_R_Hand");
                                OPENWORLD.Actor.unwield(priest, "Bip01_L_Hand");
                              }
                              OPENWORLD.Actor.playActionThen(
                                  priest, "kneel", "prostrate",
                                  delay: OPENWORLD.Math.random() * 2);
                              //OPENWORLD.Actor.playAction(
                              //     priest, action: "prostrate",
                              //    delay: 3 + OPENWORLD.Math.random() * 2);
                            }
                          }
                          var courtwomenpositions = OPENWORLD.Config
                              .getPositionsByLabel(OPENWORLD.Config
                              .config['positions']['poolpositions'][1]['positions'],
                              'courtwomen');
                          for (var position in courtwomenpositions) {
                            var actor = OPENWORLD.Config.getPoolPositionObject(
                                position);
                            if (actor != null) {
                              OPENWORLD.Actor.playActionThen(
                                  actor, "kneel", "prostrate", duration: 3,
                                  delay: OPENWORLD.Math.random() * 2);
                              //  OPENWORLD.Actor.playAction(actor, action: 'wave');
                            }
                            position['action'] = "prostrate";
                          }
                          var courtisraelpositions = OPENWORLD.Config
                              .getPositionsByLabel(OPENWORLD.Config
                              .config['positions']['poolpositions'][1]['positions'],
                              'courtisrael');
                          for (var position in courtisraelpositions) {
                            var actor = OPENWORLD.Config.getPoolPositionObject(
                                position);
                            if (actor != null) {
                              OPENWORLD.Actor.playActionThen(
                                  actor, "kneel", "prostrate", duration: 3,
                                  delay: OPENWORLD.Math.random() * 2);
                              //  OPENWORLD.Actor.playAction(actor, action: 'wave');
                            }
                            position['action'] = "prostrate";
                          }
                          if (callbackonfinish != null)
                            callbackonfinish();
                        }

                      }
                    });
                  }


                  OPENWORLD.Mob.moveToLoop(
                      priest, actions, action: "walkstraight",
                      looptype: OPENWORLD.Mob.LoopTypeStop,
                      surfaceonly: true,
                      level: 1
                  );
                }
              }
            }

        );
      }
    };

    //This does the ketoret for the roam ketoret
    // It also puts priests in the chamber of the hewnstone for roam tamid
    // These are the priests in the chamber of the hewn stone for the tamid
    if (Glob.roamtamid || Glob.roamketoret ||
        Glob.testtamidfinal||gamestart==GameStart.bethphage) { //!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var priesthewnstone = [
        [5.02, -1.61], //0  incense
        [4.96, -1.61 - 0.03], //2  // firepan
        [4.98 - 0.09 - 0.02, -1.61 - 0.03], // 4.87
        [4.98 - 2 * 0.07 - 0.02, -1.61], // 4.82
        [5.02 - 0.02, -1.61 - 0.02], // 5.0   // 1  assistant
        [4.96 - 0.02 - 0.02, -1.61 - 0.03], //  4.94  //4
        [4.98 - 0.09 - 0.02 - 0.02, -1.61 - 0.03 - 0.02], //  4.85
        [4.98 - 2 * 0.07 - 0.02 - 0.02, -1.61 - 0.02], // 4.85
        [4.98 - 0.09 - 0.02, -1.61 - 0.03 - 0.03],
      ];
      Glob.hewnstonpriestlist = [];
      var inc = 0;
      for (var pos in priesthewnstone) {
        var priest3ii = await OPENWORLD.Actor.copyActor(
            priestlist[inc % priestlist.length], randomduration: 0.1,
            action: "idlestraight",
            castshadow: inc < 3);
        _hotload.add(priest3ii);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            priest3ii, pos[0], pos[1], 0,
            5,
            level: 1); //4.61, -0.26,0,3);//3.53, -0.01,0,3);//.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
        OPENWORLD.Space.objTurn(priest3ii, 0);
        Glob.hewnstonpriestlist.add(priest3ii);
        inc++;
      }
      // Put the tools next to the ramp
      Glob.tools!();

      if (Glob.roamtamid || Glob.roamketoret || Glob.testtamidfinal||(gamestart==GameStart.bethphage))
        Glob.tamiditems!();
      if (Glob.roamketoret || Glob.testtamidfinal || (gamestart==GameStart.bethphage&&gamestartpos[gamestart].containsKey('donetamid'))) {
        Glob.meatdropall!();
      }

      if (Glob.roamketoret||(gamestart==GameStart.bethphage&&!gamestartpos[gamestart].containsKey('doneketoret'))) { //!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {

        // if (inc==4)
        Glob.priestincense = Glob.hewnstonpriestlist[4]; //riest3ii;
        // else if (inc==0)
        Glob.priestassistant = Glob.hewnstonpriestlist[0]; //priest3ii;
        //else if (inc==1)
        Glob.priestfirepan = Glob.hewnstonpriestlist[1]; //priest3ii;
        //  else if (inc==6)
        Glob.priestfirepanget = Glob.hewnstonpriestlist[6]; //priest3ii;

        if (gamestart!=GameStart.bethphage) {
          // When roam ketoret true then place two priests to your right
          var priest3ii = await OPENWORLD.Actor.copyActor(
              OPENWORLD.Math.randPick(priestlist), randomduration: 0.1,
              action: "idle");
              _hotload.add(priest3ii);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(priest3ii,3.19, 0.37, 0, 5, level: 1); //4.61, -0.26,0,3);//3.53, -0.01,0,3);//.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
          OPENWORLD.Space.objTurn(priest3ii, 150);
          OPENWORLD.Space.faceObjectAlways(priest3ii,Glob.priestincense);

          Glob.ketoret!(
              Glob.priestfirepanget, Glob.priestfirepan, Glob.priestassistant,
              Glob.priestincense)!;
        }
      } else if (Glob.testtamidfinal) {
        Glob.tamidfinal!(Glob.hewnstonpriestlist);
      }
    }


    _hotload.add(laver);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        laver, 3.58, -1.12 + 0.1, 0,
        7,
        level: 1); // 3.72, -0.80,0,7);//3.67, -0.36,0,7);//2.53, -0.51, 0.0, 7); // 3.2,2.5, 0.0);
    //  addMsgToObj(laver, "Click Laver", scale: 0.013, z: 5.5);
    OPENWORLD.Space.objTurn(laver, 0);
    bronzemat?.normalMap = normalcherubum; //tile;

    OPENWORLD.Texture.setMaterial(laver, bronzemat!);

    // Show the laver and if clicked display information
    /*  OPENWORLD.BaseObject.setHighlight(
        laver, threeJs.scene, THREE.Color.fromHex32(0x0000ff),
        0.35); //, scalex:1.4, scaley:1, scalez:1.4);
    OPENWORLD.BaseObject.highlight(laver, true, scale: 1.02, opacity: 0.2);
    OPENWORLD.BaseObject.setTouchTrigger(laver);
    laver.extra['touchtrigger'].addEventListener(
        'trigger', (THREE.Event event) {
      print("touched");
      OPENWORLD.BaseObject.highlight(laver, true, scale: 1.02, opacity: 0.35);
      var clickevent = event.action;
      setState(() {
        menuposx = clickevent.clientX;
        menuposy = clickevent.clientY - 40;
        menuitems.clear();
        menuitems.add({"text": "The bronze laver is for "});
        menuitems.add({"text": "Aaron, his sons and their successors"});
        menuitems.add({"text": "as priests to wash their hands and "});
        menuitems.add({"text": "their feet before making a sacrifice"});
        menuobj = laver;
      });
    });*/


    int seed = 12346; // Your chosen seed
    math.Random seededRandom = math.Random(
        seed); // So get the same group every time when walk to the gate of the women - why do this?
    actorlist.shuffle(seededRandom);

    // Do the lampstands
    var lampstand = await OPENWORLD.Model.createModel(
        'assets/models/lampstand.glb');
    var goldnormaltile = THREE.MeshStandardMaterial.fromMap({
      'color': 0xffff33,
      'metalness': 1.0, // 0,
      //'map': goldii,
      'shininess': 1.0,
      'roughness': 0.5,
      // 'em'
      //   'emissive':THREE.Color.fromHex32(0x000000)
      //'envMap': gold,
      //'envMapIntensity': 1.0,// api['envMapIntensity'],
    });

    goldnormaltile.normalMap = normaltile2;
    //  material?.normalMap?.repeat.setValues(5.0,5.0);//80*2, 80*2);

    goldnormaltile.normalMap?.wrapS = THREE.RepeatWrapping;
    goldnormaltile.normalMap?.wrapT = THREE.RepeatWrapping;
    OPENWORLD.Texture.setMaterial(lampstand, goldnormaltile, groupname: 'gold');

    var lampstands = [
      [ 6.59, 1.16],
      [6.59, -0.36],
      [7.79, -0.36],
      [ 7.79, 1.16]
    ];

    for (var pos in lampstands) {
      ///_hotload.add(fence3);
      // hotloadAdd(firsthotload, false, lampstand);
      var lampstand2 = lampstand.clone();
      _hotload.add(lampstand2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          lampstand2, pos[0], pos[1], 0.0,
          20, level: 1); // 6.59,1.16, 0.0, 20); // 3.2,2.5, 0.0);
      //lampstand.scale.setValues(0.012, 0.012, 0.012);


      if (OPENWORLD.Time.isNight(OPENWORLD.Time.time) && Glob.roamsukkot) {//lampstandslit) {
        // Light them if its the sukkot
        var housefire = new VolumetricFire(
            Glob.fireWidth, Glob.fireHeight, Glob.fireDepth, Glob.sliceSpacing,
            threeJs.camera);
        await housefire.init();
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            housefire.mesh, pos[0], pos[1], 1.3,
            10,level:1); // 3.35, 0.51, 0.3,3); //3.7);
        housefire.mesh.scale.x = 0.07;
        housefire.mesh.scale.y = 0.07;
        housefire.mesh.scale.z = 0.07;
        //  _hotload.add(housefire.mesh);
        _hotload.add(housefire.mesh);
        OPENWORLD.Updateables.add(housefire);

      }
    }

    // If sukkot then light up the temple
    if ( Glob.roamsukkot) {
      group = THREE.Group();
      var light = new THREE.PointLight(
          0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

      light.intensity = 1.0; // 0.6;
      light.distance = 10.0; //1.2;
      // light.position.y = 0.33;
      OPENWORLD.Light.addFlicker(light);
      group.add(light);
      //  _hotload.add(group);
      _hotload.add(group);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          group, 7, 0.5, 1.3, 20, level:1);

    }

    // Used to check if person is inside a lamp stand
    hitlampstand(x, y) {
      for (lampstand in lampstands)
        if ((lampstand[0] - x).abs() < 0.1 && (lampstand[1] - y).abs() < 0.1)
          return true;
      return false;
    }

    // Create rabbis in the court of women teaching
    createRabbi(rabbiposx, rabbiposy, rabbiturn, level) {
      // var rabbiposx= -4.14;//-4.03;
      //var rabbiposy= -12.77;//-12.21;
      //var rabbiturn=0.0;
      var fct = rabbiturn == 0.0 ? -1 : 1;
      var picked=[citizen35];
      OPENWORLD.Config
          .config['positions']['poolpositions'][1]['positions'].add(
          {
            'name': OPENWORLD.Config.getObjectName(citizen35), //
            //
            'p': [rabbiposx, rabbiposy],
            't': rabbiturn, //180,
            'l': level,
            'action': "idle", //sittableidle",
            'randomduration': 0.1,
            "lerpopacity": 1,
            "callbackonvisible": (actor) {
              print("rabbi on");
              OPENWORLD.Actor.playActionsLoop(actor,
                  ["idle","wave", "idle", "point", "idle", "hitup", "armsup"],
                  durations: [2 * 2, 3 * 2, 2 * 2, 2 * 2, 5 * 2, 5 * 2],
                  fadein: 0,
                  fadeout: 2); // fadeout:null);//fadein:0.5); //,*/fadeout:0.7);

              loopspeech(actor, rabbicourtwomen);
            },
            "callbackonhide": (actor) {
              print("rabbi off");
              OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
              OPENWORLD.Mob.pauseSpeech(actor);
              OPENWORLD.Mob.clearText(actor);
            }
          });


      List<Map> disciplesu = [
        {
          "p": [rabbiposx - 0.04 * fct, rabbiposy + (0.035 - 0.21) * fct],
          "t": OPENWORLD.Math.randFloatSpread(30) + rabbiturn - 180,
          "action": "squat"
        },
        {
          "p": [
            rabbiposx - 0.04 * fct,
            rabbiposy + (0.035 - 0.21 - 0.03) * fct
          ],
          "t": OPENWORLD.Math.randFloatSpread(30) + rabbiturn - 180,
          "action": "squat"
        },
        {
          "p": [rabbiposx, rabbiposy + (0.035 - 0.21 - 0.03) * fct],
          "t": OPENWORLD.Math.randFloatSpread(30) + rabbiturn - 180,
          "action": "squat"
        },
        {
          "p": [
            rabbiposx + 0.04 * fct,
            rabbiposy + (0.035 - 0.21 - 0.03) * fct
          ],
          "t": OPENWORLD.Math.randFloatSpread(30) + rabbiturn - 180,
          "action": "squat"
        },
        {
          "p": [rabbiposx + 0.04 * fct, rabbiposy + (0.02 - 0.21) * fct],
          "t": OPENWORLD.Math.randFloatSpread(30) + rabbiturn - 180,
          "action": "squat"
        },
        {
          "p": [
            rabbiposx + (0.04 + 0.04) * fct,
            rabbiposy + (0.035 - 0.21) * fct
          ],
          "t": OPENWORLD.Math.randFloatSpread(30) + rabbiturn - 180,
          "action": "squat"
        },
        {
          "p": [
            rabbiposx + (0.04 + 0.04 + 0.04) * fct,
            rabbiposy + (0.035 - 0.21 + 0.04) * fct
          ],
          "t": -30 + rabbiturn - 180, //OPENWORLD.Math.randFloatSpread(30),
          "action": "idle3"
        },
        {
          "p": [
            rabbiposx + (0.04 + 0.04 + 0.04) * fct,
            rabbiposy + (0.035 - 0.21 + 0.04 + 0.04) * fct
          ],
          "t": -60 + rabbiturn - 180, //OPENWORLD.Math.randFloatSpread(30),
          "action": "idle3"
        },
        {
          "p": [
            rabbiposx - (0.04 + 0.04) * fct,
            rabbiposy + (0.035 - 0.21 + 0.04) * fct
          ],
          "t": 30 + rabbiturn - 180, //OPENWORLD.Math.randFloatSpread(30),
          "action": "idle3"
        },
        {
          "p": [
            rabbiposx - (0.04 + 0.04) * fct,
            rabbiposy + (0.035 - 0.21 + 0.04 + 0.04) * fct
          ],
          "t": 60 + rabbiturn - 180, //OPENWORLD.Math.randFloatSpread(30),
          "action": "idle3"
        },
        {
          "p": [rabbiposx - (0.04) * fct, rabbiposy - 0.3 * fct],
          "t": 0 + rabbiturn - 180, //OPENWORLD.Math.randFloatSpread(30),
          "action": "idle3"
        },
        {
          "p": [rabbiposx + (0.04) * fct, rabbiposy - 0.3 * fct],
          "t": 0 + rabbiturn - 180, //OPENWORLD.Math.randFloatSpread(30),
          "action": "idle3"
        },
        // {"p": [ rabbiposx, -51.59 + 0.02], "t": 0, "action": "idle3"},
        //   {"p": [ rabbiposx, -51.46], "t": 0, "action": "sitidle"},
        //  {"p": [ rabbiposx - 0.08, -51.46], "t": 20, "action": "sitidle"},
        //   {"p": [rabbiposx + 0.08, -51.46], "t": -20, "action": "sitidle"},
      ];

      actorlist.shuffle();
      for (var i = 0; i < disciplesu.length; i++) {
       // var actor = actorlist[i % actorlist.length];
        var actor=OPENWORLD.Math.randPick(actorlist,exclude:picked);
        picked.add(actor);  // so no duplicates

        var z;
        if (disciplesu[i]["action"]=='squat')
          z = -0.005; //0.0;
        else
          z=0.0;
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(actor), //
              //  OPENWORLD.Math.randPick(adultlist, exclude:[adultpick])),
              'p': [ disciplesu[i]["p"][0], disciplesu[i]["p"][1], z],
              't': disciplesu[i]["t"].toDouble(),
              'l': level,
              'action': disciplesu[i]["action"],
              'randomduration': 0.1,
              'startat': OPENWORLD.Math.random(),
              "lerpopacity": 1
            });
      }
    }

    // Create a crowd of people in the court of women and court of israel facing west for the tamid
    // You can add to the number of people eg chamber of hearth where numbers can grow
    createTamidCourtCrowd(courtwomennum, courtisraelnum) async {
      //  court of women
      // So dont add more than the number required
      var direction = 270;
      var courtwomenpositions = OPENWORLD.Config.getPositionsByLabel(
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'],
          'courtwomen');
      List<List> exclude=[];
      if (gamestart==GameStart.bethphage) {
        // So when do bethphage journey there is a path you and your friend can walk through
        var essendiff = 0.4;
        var essenpoints = OPENWORLD.Math.interpolateByIncrement(
            citizenessenpath, essendiff / 2);
        for (var point in essenpoints) {
          if (point[1] > -1.38 && point[1] < 1.8)
            exclude.add([point[0], point[1]]);
        }
        // Your path to nicanor
        var points=OPENWORLD.Math.interpolateByIncrement([[7.23,-1.25],[6.49, -0.86,0],[6.00, 0.20],[5.15-0.1,0.43]],essendiff);  //5.82,0.37
        for (var point in points) {
          if (point[1] > -1.38 && point[1] < 1.8)
            exclude.add([point[0], point[1]]);
        }

      }

      for (var i = courtwomenpositions.length; i < courtwomennum; i++) {
        //  var actor = actorlist[i % actorlist.length];
        var minx=6.0, maxx=7.8, miny=0.36-0.75, maxy=0.36+0.75;
        var centerx=(maxx+minx)/2;
        var centery=(maxy+miny)/2;
        var spreadx=maxx-minx;
        var spready=maxy-miny;
        var x;
        var y;
        var hit;
        do {
          x = centerx+OPENWORLD.Math.randFloatSpread(spreadx);;// 7.05 + OPENWORLD.Math.randFloatSpread(1.5);
          y = centery+OPENWORLD.Math.randFloatSpread(spready);//0.36 + OPENWORLD.Math.randFloatSpread(1.5);
          hit = hitlampstand(x, y);
          if (!hit) {
            for (var pos in exclude) {
              if (!hit&&OPENWORLD.Math.vectorDistance(THREE.Vector3(x,y,0.0), THREE.Vector3(pos[0],pos[1],0.0))<0.2)
                hit=true;
            }
          }

        } while (hit);
        print("added tamid crowd"+x.toString()+" "+y.toString());
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(actorlist)),
              'p': [x, y],
              'l': 1,
              't': direction != null ? direction : OPENWORLD.Math.random() *
                  360, //270,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'idle3',
              'randomduration': 0.1,
              'startat': OPENWORLD.Math.random(),
              'label': 'courtwomen',
              "callbackonvisible":(actor) {
                // Throttle so actor animation so crowd doesn't use too much cpu
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
              },
              "callbackonhide":(actor) {
                OPENWORLD.Actor.disableDistanceThrottle(actor);
              },
              "lerpopacity": 1
            });

      }


      // inner court
      // So dont add more than the number required
      var courtisraelpositions = OPENWORLD.Config.getPositionsByLabel(
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'],
          'courtisrael');

      exclude=[];
      var essendiff=0.3;
      var points=OPENWORLD.Math.interpolateByIncrement([[6.00, 0.20],[5.15-0.1,0.43]/*,[5+0.1,1.37]*/],essendiff);  //5.82,0.37
      for (var point in points) {
        if (point[1] > -1.38 && point[1] < 1.8)
          exclude.add([point[0], point[1]]);
      }

      var positions=[];
      for (var position in courtisraelpositions)
        positions.add(position['p']);

      for (var i = courtisraelpositions.length; i < courtisraelnum; i++) {
        var x;
        var y;
        if (i==0) {
          // Always have a person here for bethphage journey next to you
          x= 5.13;//  5.21;
          y=1.25;//1.24;
        } else {
          var minx=5.3-0.2, maxx=5.3, miny=0.39-1;
          var maxy;
          if (gamestart!=GameStart.bethphage)
            maxy =0.39+1;
          else
            maxy=1.33-0.1; // So that dont have people blocking your way when observing tamid for bethphage journey
          var centerx=(maxx+minx)/2;
          var centery=(maxy+miny)/2;
          var spreadx=maxx-minx;
          var spready=maxy-miny;

          // So none on top of eachother
          var hit;
          do {

            hit=false;
            x = centerx+OPENWORLD.Math.randFloatSpread(spreadx);
            y = centery+OPENWORLD.Math.randFloatSpread(spready);
           // x=5.3 - OPENWORLD.Math.random() * 0.2;
           // y=0.39 + OPENWORLD.Math.randFloatSpread(2.0);
            for (var pos in positions) {
              if (!hit && OPENWORLD.Math.vectorDistance(
                  THREE.Vector3(x, y, 0.0), THREE.Vector3(pos[0], pos[1], 0.0)) < 0.02)
                hit = true;
            }
            if (!hit) {
              for (var pos in exclude) {
                if (!hit&&OPENWORLD.Math.vectorDistance(THREE.Vector3(x,y,0.0), THREE.Vector3(pos[0],pos[1],0.0))<0.2)
                  hit=true;
              }
            }
            if (!hit&&gamestart==GameStart.bethphage) {
              // Clear spot where watch the ketoret
              if (OPENWORLD.Math.vectorDistance(THREE.Vector3(x,y,0.0), THREE.Vector3(5.23, -0.26,0.0))<0.25)
                hit=true;
            }
          } while (hit);
        }
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(malelist)),
              'p': [x, y, 0],
              'l': 1,
              't': direction != null ? direction : OPENWORLD.Math.random() *
                  360, //270,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'idle3',
//                'action': i % 2 == 0 ? 'idle3' : 'prostrate',
              'randomduration': 0.1,
              'startat': OPENWORLD.Math.random(),
              'label': 'courtisrael',
              "callbackonvisible":(actor) {
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
              },
                "callbackonhide":(actor) {
                  if (gamestart==GameStart.bethphage)
                    OPENWORLD.Space.removeFaceObjectAlways(actor);
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                 // OPENWORLD.Mob.pauseChatter(actor);

                },
              "lerpopacity": 1
            });
        positions.add([x,y]);


        // }
      }
      await OPENWORLD.Config.createPoolObjects(); //_hotload);
      await OPENWORLD.Config
          .forceShowPoolObjects(); // Make it show the people without needing to move
      //await OPENWORLD.Config.updatePoolObjects();
      //  OPENWORLD.Config.lastx =null;
      // var worldpos = OPENWORLD.You.getWorldPos();
      // OPENWORLD.Config.showPoolsObjects(worldpos.x, worldpos.y);
    }
    // Is used in hearth journey so is shared
    Glob.createTamidCourtCrowd = createTamidCourtCrowd;

    if (OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {
      // Create the crowds in the south court of gentiles
      // You could find the closest person and face that person so everyone isn't pointing in random directions
      var exclude= [ [ 1.61, -7.35, 0.5],
                     [ 6.06, -7.35, 0.5],
      ];
      var excludewomensgatesouthgentiles=[];
      if (gamestart==GameStart.womensgate) {
        // If womensgate journey clear a path through the crowd
        var diff=0.4;
        var points=OPENWORLD.Math.interpolateByIncrement(friendpathtemple,diff/2);
        for (var point in points) {
          var x=point[0];
          var y=point[1];
          if (y> OPENWORLD.Room.getMinY(roomSouthCourt)-0.5&&
              y< OPENWORLD.Room.getMaxY(roomSouthCourt)+0.5&&
              x>OPENWORLD.Room.getMinX(roomSouthCourt)-0.5&&
              x<OPENWORLD.Room.getMaxX(roomSouthCourt)+0.5) {
            excludewomensgatesouthgentiles.add(
                [x, y, diff, diff]);
          }
        }
      }
      var excludebethphagesouthgentiles=[];
      if (gamestart==GameStart.bethphage) {
        // Clear a path through the crowd for the bethphage journey
        var essendiff = 0.4;
        var essenpoints = OPENWORLD.Math.interpolateByIncrement(
            citizenessenpath, essendiff / 2);
        for (var point in essenpoints) {
          if (point[1] > -6.76 && point[1] < -2.59)
            excludebethphagesouthgentiles.add([point[0], point[1], essendiff]);
        }
      }
      // Get a set of point for every person in the crowd in the south court including paths that have been excluded
      var southgentilespoints = closestPersonAngle(createCrowdPoints(
          OPENWORLD.Room.getMinX(roomSouthCourt),
          OPENWORLD.Room.getMaxX(roomSouthCourt),
          OPENWORLD.Room.getMinY(roomSouthCourt),
          OPENWORLD.Room.getMaxY(roomSouthCourt),
          10,
          0.02,
        [...exclude,...excludewomensgatesouthgentiles,...excludebethphagesouthgentiles]
          )); // Two passage ways

      // Create the vendors in the royal stoa
      var numvendors = 50;
      var excludestoasellers = [];
      var sellerstartx = -3.55 - 0.05;
      var sellernextx = sellerstartx;
      var sellery = -12.63 - 0.09;

      for (var j = 0; j < numvendors; j++) {
        var picked;
        if (j==1)
          picked=1;  // for womens gate journey so always dove seller at that point
        else
          picked=OPENWORLD.Math.randInt(4);
        var vendor=OPENWORLD.Math.randPick(manlist);
        if (picked == 0) {
          var moneychangerposx = sellernextx; //-3.55;
          var moneychangerposy = sellery; // -12.63 - 0.09;

          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                   vendor// manlist[j % manlist.length]
                ),
                'p': [ moneychangerposx, moneychangerposy, -0.01],
                'l': 1,
                't': 0, // OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'sittableidle',
                'randomduration': 0.1,
                //  'startat': OPENWORLD.Math.random(),
                //  'label': 'courtwomen',
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },
                "lerpopacity": 1
              });
          /*  var tablelow2=tablelow.clone();
          _hotload.add(tablelow2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              tablelow2, moneychangerposx, moneychangerposy + 0.05, 0,
              //-3.55, -12.58, 0,
              1.5, level: 1);
          OPENWORLD.Space.objTurn(tablelow2, 90);*/
          instancedTablelow.place(
              90, moneychangerposx, moneychangerposy + 0.05, 0.0, level: 1);
          var money2 = money.clone();
          _hotload.add(money2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              money2, moneychangerposx - 0.015, moneychangerposy + 0.05, 0.03,
              // -3.55, -12.58, 0.026,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          var scales2 = scales.clone();
          _hotload.add(scales2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              scales2, moneychangerposx + 0.02, moneychangerposy + 0.05, 0.03,
              //-3.55+0.02, -12.58, 0.026,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(scales2, 0);
          /*  var moneychest2=moneychest.clone();
          _hotload.add(moneychest2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              moneychest2, moneychangerposx - 0.03, moneychangerposy + 0.02, 0,
              // -3.55-0.03, -12.63+0.02, 0,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(moneychest2, 90);*/
          instancedMoneychest.place(
              90, moneychangerposx - 0.03, moneychangerposy + 0.02, 0.0,
              level: 1);
          /* var stool2=stool.clone();
          _hotload.add(stool2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              stool2, moneychangerposx, moneychangerposy, 0, //-3.55, -12.63, 0,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(stool2, 90);*/
          instancedStool.place(
              90, moneychangerposx, moneychangerposy, 0.0, level: 1);
        } else if (picked == 1) {
          var dovesellerposx = sellernextx; //-3.55 + 0.15;
          var dovesellerposy = sellery; // -12.63 - 0.09;
          /* var doveseller = await OPENWORLD.Actor.copyActor(
              manlist[j % manlist.length],
              action: "sittableidle");
          // setActorSize(citizenoldwoman2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              doveseller, dovesellerposx, dovesellerposy, -0.01, 3,
              level: 1); // 1.25, 4.22, 0.0, 3); //3.42);
          _hotload.add(doveseller);
          OPENWORLD.Space.objTurn(doveseller, 0);*/
          var config={
            'name': OPENWORLD.Config.getObjectName(  vendor// manlist[j % manlist.length]
            ),
            'p': [ dovesellerposx, dovesellerposy, -0.01],
            'l': 1,
            't': 0, // OPENWORLD.Math.random() * 360, //270,
            // 'pitch': pitch,
            //   'roll': roll,
            'action': 'sittableidle',
            'randomduration': 0.1,
            //  'startat': OPENWORLD.Math.random(),
            //  'label': 'courtwomen',
            "lerpopacity": 1,
            "callbackonvisible":(actor) {
              OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
            },
            "callbackonhide":(actor) {
              OPENWORLD.Actor.disableDistanceThrottle(actor);
            },

          };
          if (j==1) {
            // This is the dove seller in the stoa
            config['label'] = 'dovesellerwomensgate'; // so womensgate can lookup this seller
            config['t']=20;  // so sort of offset looking at womensgategroup[1]
          }
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(config);

          /*var tablelow2 = tablelow.clone();
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              tablelow2, dovesellerposx, dovesellerposy + 0.05, 0,
              //-3.55, -12.58, 0,
              1.5, level: 1);
          _hotload.add(tablelow2);
          OPENWORLD.Space.objTurn(tablelow2, 90);*/
          instancedTablelow.place(
              90, dovesellerposx, dovesellerposy + 0.05, 0.0, level: 1);

          var birdcagepigeon2 = birdcagepigeon.clone();
          _hotload.add(birdcagepigeon2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              birdcagepigeon2, dovesellerposx - 0.015, dovesellerposy + 0.05,
              0.055,
              // -3.55, -12.58, 0.026,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          var birdcagedove2 = birdcagedoves.clone();
          _hotload.add(birdcagedove2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              birdcagedove2, dovesellerposx + 0.015, dovesellerposy + 0.05,
              0.055,
              // -3.55, -12.58, 0.026,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          /*   var stool2 = stool.clone();
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              stool2, dovesellerposx, dovesellerposy, 0, //-3.55, -12.63, 0,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          _hotload.add(stool2);*/
          instancedStool.place(
              90, dovesellerposx, dovesellerposy, 0.0, level: 1);
          /*  var basket2 = basket.clone();
          _hotload.add(basket2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              basket2, dovesellerposx - 0.03, dovesellerposy + 0.02, 0,
              // -3.55-0.03, -12.63+0.02, 0,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          basket2.scale.setValues(0.0015, 0.0015, 0.0015);*/
          instancedBasket.place(
              0, dovesellerposx - 0.03, dovesellerposy + 0.02, 0.0, level: 1,
              scale: THREE.Vector3(0.0015, 0.0015, 0.0015));
          /* var basket3 = basket.clone();
          _hotload.add(basket3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              basket3, dovesellerposx + 0.03, dovesellerposy + 0.04, 0,
              // -3.55-0.03, -12.63+0.02, 0,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          basket3.scale.setValues(0.001, 0.001, 0.001);*/
          instancedBasket.place(
              0, dovesellerposx + 0.03, dovesellerposy + 0.04, 0.0, level: 1,
              scale: THREE.Vector3(0.001, 0.001, 0.001));
        } else if (picked == 2) {
          var scribeposx = sellernextx; //-3.55 + 0.15 + 0.15;
          var scribeposy = sellery; //-12.63 - 0.09;
          /*  var scribe = await OPENWORLD.Actor.copyActor(
              manlist[j % manlist.length],
              action: "sittableidle");
          // setActorSize(citizenoldwoman2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              scribe, scribeposx, scribeposy, -0.01, 3,
              level: 1); // 1.25, 4.22, 0.0, 3); //3.42);
          _hotload.add(scribe);
          OPENWORLD.Space.objTurn(scribe, 0);*/
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    vendor),//manlist[j % manlist.length]),
                'p': [ scribeposx, scribeposy, -0.01],
                'l': 1,
                't': 0, // OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'sittableidle',
                'randomduration': 0.1,
                //  'startat': OPENWORLD.Math.random(),
                //  'label': 'courtwomen',
                "lerpopacity": 1,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },

              });
          /*  var tablelow3 = tablelow.clone();
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              tablelow3, scribeposx, scribeposy + 0.05, 0, //-3.55, -12.58, 0,
              1.5, level: 1);
          OPENWORLD.Space.objTurn(tablelow3, 90);
          _hotload.add(tablelow3);*/
          instancedTablelow.place(
              90, scribeposx, scribeposy + 0.05, 0.0, level: 1);
          /*    var parchment3=parchment.clone();
          _hotload.add(parchment3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              parchment3, scribeposx + 0.015, scribeposy + 0.05, 0.03,
              1.5, level: 1);
          OPENWORLD.Space.objTurn(parchment3, 90);*/
          instancedParchment.place(
              90, scribeposx + 0.015, scribeposy + 0.05, 0.03, level: 1);
          /* var parchment2 = parchment.clone();
          _hotload.add(parchment2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              parchment2, scribeposx + 0.025, scribeposy + 0.05, 0.03,
              1.5, level: 1);
          OPENWORLD.Space.objTurn(parchment2, 95);*/
          instancedParchment.place(
              90, scribeposx + 0.025, scribeposy + 0.05, 0.03, level: 1);
          var penreed2 = penreed.clone();
          _hotload.add(penreed2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              penreed2, scribeposx + 0.015, scribeposy + 0.05, 0.03,
              1.5, level: 1);
          OPENWORLD.Space.objTurn(penreed2, 45);
          /*  var parchmentroll3=parchmentroll.clone();
          _hotload.add(parchmentroll3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              parchmentroll3, scribeposx + 0.025, scribeposy + 0.05, 0.03,
              1.5, level: 1);
          OPENWORLD.Space.objTurn(parchmentroll3, 90);*/
          instancedParchmentroll.place(
              90, scribeposx + 0.025, scribeposy + 0.05, 0.03, level: 1);

          /*var parchmentroll2 = parchmentroll.clone();
          _hotload.add(parchmentroll2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              parchmentroll2, scribeposx - 0.025, scribeposy + 0.05, 0.03,
              1.5, level: 1);
          OPENWORLD.Space.objTurn(parchmentroll2, 45);*/
          instancedParchmentroll.place(
              45, scribeposx - 0.025, scribeposy + 0.05, 0.03, level: 1);
          /* var parchment4 = parchment.clone();
          _hotload.add(parchment4);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              parchment4, scribeposx - 0.01, scribeposy + 0.05, 0.03,
              1.5, level: 1);*/
          instancedParchment.place(
              0, scribeposx - 0.01, scribeposy + 0.05, 0.03, level: 1);

          var inkwell = bowl.clone();
          _hotload.add(inkwell);
          OPENWORLD.BaseObject.setVisible(inkwell, true, groupname: "liquid");
          //OPENWORLD.Texture.setColor(inkwell, THREE.Color.fromHex32(0x000000),groupname:"liquid");
          OPENWORLD.Texture.setColor(inkwell, THREE.Color.fromHex32(0x000000));
          inkwell.scale.setValues(0.005, 0.005, 0.005);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              inkwell, scribeposx, scribeposy + 0.05, 0.03, level: 1,
              1); //4.55,-0.23, 0.00, level: 1, 1);
          /*var stool3 = stool.clone();
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              stool3, scribeposx, scribeposy, 0, //-3.55, -12.63, 0,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          _hotload.add(stool3);*/
          instancedStool.place(90, scribeposx, scribeposy, 0.0, level: 1);
          /*var moneychest2 = moneychest.clone();
          _hotload.add(moneychest2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              moneychest2, scribeposx + 0.03, scribeposy + 0.02, 0,
              1.5, level: 1);
          OPENWORLD.Space.objTurn(moneychest2, 90);*/
          instancedMoneychest.place(90, scribeposx, scribeposy, 0.0, level: 1);
        } else if (picked == 3) {
          var sellerposx = sellernextx; //-3.55 + 0.15 + 0.15 + 0.15;
          var sellerposy = sellery; //-12.63 - 0.09;
          /*var seller = await OPENWORLD.Actor.copyActor(
              manlist[j % manlist.length],
              action: "sittableidle");
          // setActorSize(citizenoldwoman2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              seller, sellerposx, sellerposy, -0.01, 3,
              level: 1); // 1.25, 4.22, 0.0, 3); //3.42);
          _hotload.add(seller);
          OPENWORLD.Space.objTurn(seller, 0);*/
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    vendor//  manlist[j % manlist.length]
                ),
                'p': [ sellerposx, sellerposy, -0.01],
                'l': 1,
                't': 0, // OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'sittableidle',
                'randomduration': 0.1,
                //  'startat': OPENWORLD.Math.random(),
                //  'label': 'courtwomen',
                "lerpopacity": 1,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },

              });

          /*var tablelow4 = tablelow.clone();
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              tablelow4, sellerposx, sellerposy + 0.05, 0, //-3.55, -12.58, 0,
              1.5, level: 1);
          _hotload.add(tablelow4);
          OPENWORLD.Space.objTurn(tablelow4, 90);*/
          instancedTablelow.place(
              90, sellerposx, sellerposy + 0.05, 0.0, level: 1);
          var jug2 = jug.clone();
          _hotload.add(jug2);
          jug2.scale.setValues(0.01, 0.01, 0.01);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              jug2, sellerposx + 0.015, sellerposy + 0.05, 0.03,
              1.5, level: 1);
          var pot2 = pot.clone();
          _hotload.add(pot2);
          pot2.scale.setValues(0.01, 0.01, 0.01);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              pot2, sellerposx + 0.025, sellerposy + 0.07, 0.03,
              1.5, level: 1);
          var rope2 = rope.clone();
          _hotload.add(rope2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              rope2, sellerposx - 0.015, sellerposy + 0.05, 0.03,
              1.5, level: 1);
          /*var cup2 = cup.clone();
          _hotload.add(cup2);
          cup2.scale.setValues(0.0002, 0.0002, 0.0002);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              cup2, sellerposx - 0.03, sellerposy + 0.05, 0.03,
              1.5, level: 1);*/
          instancedCup.place(
              0, sellerposx - 0.03, sellerposy + 0.05, 0.03, level: 1,
              scale: THREE.Vector3(0.0002, 0.0002, 0.0002));

          /*var cup3 = cup2.clone();
          _hotload.add(cup3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              cup3, sellerposx - 0.03, sellerposy + 0.07, 0.03,
              1.5, level: 1);*/
          instancedCup.place(
              0, sellerposx - 0.03, sellerposy + 0.07, 0.03, level: 1,
              scale: THREE.Vector3(0.0002, 0.0002, 0.0002));
          /*   var matrolled2 = matrolled.clone();
          _hotload.add(matrolled2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              matrolled2, sellerposx + 0.025, sellerposy - 0.1, 0.0,
              1.5, level: 1);
          matrolled2.scale.setValues(0.005, 0.005, 0.005);*/
          instancedMatrolled.place(
              0, sellerposx + 0.025, sellerposy - 0.1, 0.0, level: 1,
              scale: THREE.Vector3(0.005, 0.005, 0.005));
          /*  var matrolled3 = matrolled2.clone();
          _hotload.add(matrolled3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              matrolled3, sellerposx - 0.025, sellerposy - 0.1, 0.0,
              1.5, level: 1);*/
          instancedMatrolled.place(
              0, sellerposx - 0.025, sellerposy - 0.1, 0.0, level: 1,
              scale: THREE.Vector3(0.005, 0.005, 0.005));
          var amphora2 = amphora.clone();
          _hotload.add(amphora2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              amphora2, sellerposx, sellerposy - 0.1, 0.0,
              1.5, level: 1);
          /*   var basketwicker2 = basketwicker.clone();
          _hotload.add(basketwicker2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              basketwicker2, sellerposx + 0.03, sellerposy + 0.03, 0.0,
              1.5, level: 1);*/
          instancedBasketWicker.place(
              0, sellerposx + 0.03, sellerposy + 0.03, 0.0, level: 1);

          /* var basketwicker3 = basketwicker.clone();
          _hotload.add(basketwicker3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              basketwicker3, sellerposx - 0.03, sellerposy + 0.03, 0.0,
              1.5, level: 1);*/
          instancedBasketWicker.place(
              0, sellerposx - 0.03, sellerposy + 0.03, 0.0, level: 1);
          /* var stool4 = stool.clone();
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              stool4, sellerposx, sellerposy, 0, //-3.55, -12.63, 0,
              1.5,
              level: 1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          _hotload.add(stool4);*/
          instancedStool.place(90, sellerposx, sellerposy, 0.0, level: 1);
        }
        // Place some buyers in front the vendor
        var numbuyers;
        if (j!=1)
          numbuyers=OPENWORLD.Math.randInt(3);
        else
          numbuyers=0; // for womens gate so dove seller never has people in front
        if (numbuyers == 1) {
          /* var buyer = await OPENWORLD.Actor.copyActor(
              OPENWORLD.Math.randPick(actorlist),
              action: "idle3", randomduration: 0.1);
          // setActorSize(citizenoldwoman2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              buyer, sellernextx, sellery+0.1, 0, 3,
              level: 1); // 1.25, 4.22, 0.0, 3); //3.42);
          _hotload.add(buyer);
          OPENWORLD.Space.objTurn(buyer, 180);*/
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    OPENWORLD.Math.randPick(actorlist)),
                'p': [ sellernextx, sellery + 0.1, 0],
                'l': 1,
                't': 180, // OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'idle3',
                'randomduration': 0.1,
                //  'startat': OPENWORLD.Math.random(),
                //  'label': 'courtwomen',
                "lerpopacity": 1,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },

              });
        } else if (numbuyers == 2) {
          /*  var buyer = await OPENWORLD.Actor.copyActor(
              OPENWORLD.Math.randPick(actorlist),
              action: "idle3", randomduration: 0.1);
          // setActorSize(citizenoldwoman2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              buyer, sellernextx-0.02, sellery+0.1, 0, 3,
              level: 1); // 1.25, 4.22, 0.0, 3); //3.42);
          _hotload.add(buyer);
          OPENWORLD.Space.objTurn(buyer, 180);*/
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    OPENWORLD.Math.randPick(actorlist)),
                'p': [sellernextx - 0.02, sellery + 0.1, 0],
                'l': 1,
                't': 180, // OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'idle3',
                'randomduration': 0.1,
                //  'startat': OPENWORLD.Math.random(),
                //  'label': 'courtwomen',
                "lerpopacity": 1,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },

              });

          /* var buyer2 = await OPENWORLD.Actor.copyActor(
              OPENWORLD.Math.randPick(actorlist),
              action: "idle3", randomduration: 0.1);
          // setActorSize(citizenoldwoman2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              buyer2, sellernextx+0.02, sellery+0.1,0, 3,
              level: 1); // 1.25, 4.22, 0.0, 3); //3.42);
          _hotload.add(buyer2);
          OPENWORLD.Space.objTurn(buyer2, 180);*/
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    OPENWORLD.Math.randPick(actorlist)),
                'p': [sellernextx + 0.02, sellery + 0.1, 0],
                'l': 1,
                't': 180, // OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'idle3',
                'randomduration': 0.1,
                //  'startat': OPENWORLD.Math.random(),
                //  'label': 'courtwomen',
                "lerpopacity": 1,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },

              });
        }
        excludestoasellers.add([sellernextx, sellery, 0.25]);
        if (j % 2 == 0)
          sellernextx += 0.42 / 3; //15;
        else
          sellernextx += 2 * 0.42 / 3; //15;
        /* [moneychangerposx,moneychangerposy,0.15],
          [dovesellerposx,dovesellerposy,0.15],
          [scribeposx,scribeposy,0.15],
          [sellerposx,sellerposy,0.15],*/
      }

      // Put some rabbis in the stoa
      var excluderabbi = [];
      var rabbis=[
         [-4.14, -12.77],        // Rabbi in stoa on west side
        [8.26, -12.75]   // Rabbi in stoa on east side
      ];
      for (var rabbi in rabbis) {
        createRabbi(rabbi[0],rabbi[1], 0.0, 1);
        excluderabbi.add([rabbi[0],rabbi[1], 0.4]);
      }

      var excludewomensgatestoa=[];
      var diff=0.4;
      if (gamestart==GameStart.womensgate) {
        // if womensgate journey create a path through the crowd in the stoa
        var points=OPENWORLD.Math.interpolateByIncrement(friendpathtemple,diff/2);
        for (var point in points) {

          var x=point[0];
          var y=point[1];

          if (y> OPENWORLD.Room.getMinY(roomStoa)-0.5&&
              y< OPENWORLD.Room.getMaxY(roomStoa)+0.5&&
              x>OPENWORLD.Room.getMinX(roomStoa)-0.5&&
              x<OPENWORLD.Room.getMaxX(roomStoa)+0.5) {
            excludewomensgatestoa.add(
                [x, y, diff, x<-4.25?0.8:diff]);  // use 0.6 so a bit wider so dont block player
            ///  if (j==1)
            ///   print("cj1inc"+(j1inc++).toString());
          }
        }

      }

      // Create a crowd of points for the royal stoa including excluded paths
      var stoapoints = closestPersonAngle(createCrowdPoints(
          OPENWORLD.Room.getMinX(roomStoa),
          OPENWORLD.Room.getMaxX(roomStoa),
          OPENWORLD.Room.getMinY(roomStoa),
          OPENWORLD.Room.getMaxY(roomStoa),
          30,
          0.02,
          [...stoacolumnpos, ...excludestoasellers, ...excluderabbi,...excludewomensgatestoa]));
      // Have people near the rabbis watching them
      for (var rabbi in rabbis) {
        for (var point in stoapoints) {
          if (OPENWORLD.Math.vectorDistance(THREE.Vector3(rabbi[0],rabbi[1],0),THREE.Vector3(point[0],point[1],0))<0.5) {
             var angle=OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(point[0],point[1],0),THREE.Vector3(rabbi[0],rabbi[1],0));
             point[2]=angle;
          }
        }
      }

      // Create a crowd of point for the northern part of court of gentiles
      var northgentilespoints = closestPersonAngle(createCrowdPoints(
          OPENWORLD.Room.getMinX(roomNorthCourt),
          OPENWORLD.Room.getMaxX(roomNorthCourt),
          OPENWORLD.Room.getMinY(roomNorthCourt),
          OPENWORLD.Room.getMaxY(roomNorthCourt),
          10,
          0.02,
          []));

      // Create the crowds in the court of gentiles and stoa now that have got all the points
      for (var point in [
        ...southgentilespoints,
        ...stoapoints,
        ...northgentilespoints
      ]) {

        var doshalom=OPENWORLD.Math.random()<0.01;
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(actorlist)),
              'p': [point[0], point[1]],
              'l': 1,
              't': point[2], // OPENWORLD.Math.random() * 360, //270,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'idle3',
              'randomduration': 0.1,
              'startat': OPENWORLD.Math.random(),
           //   'label': 'courtwomen',
              'doshalom':doshalom,
              "lerpopacity": 1,
              "callbackonvisible":(actor) {
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.1, skipFrames: 6);
                var positionjson = OPENWORLD.Config.getPositionForObject(actor);
                var doshalom=positionjson!['doshalom'];

                if (doshalom)
                  OPENWORLD.BaseObject.setDistanceTrigger(
                      actor, dist: 0.3, event: (action) {
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
                      OPENWORLD.Space.faceObjectAlways(actor, threeJs.camera);
                      // OPENWORLD.Space.faceObjectLerp(citizenf32ii, threeJs.camera, 1.0);
                    } else {
                      OPENWORLD.Space.removeFaceObjectAlways(actor);
                    }
                  });
              },
              "callbackonhide":(actor) {
                OPENWORLD.Actor.disableDistanceThrottle(actor);
                var positionjson = OPENWORLD.Config.getPositionForObject(actor);
                var doshalom=positionjson!['doshalom'];
                if (doshalom) {
                  OPENWORLD.Space.removeFaceObjectAlways(actor);
                  OPENWORLD.BaseObject.removeDistanceTrigger(actor);
                }
              }
            });
      }

      // These are people sitting on the hel
      var southhelpoints=createCrowdPoints(0.24,9.35,-2.41,-2.31,10,0.02,[[7.25,-2.35,0.4],[4.86,-2.35,0.4]]);
      for (var point in southhelpoints) {
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(actorlist)),
              'p': [point[0], point[1]],
              'l': 1,
              't': 180,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'squat',
              'randomduration': 0.1,
              "callbackonvisible":(actor) {
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
              },
              "callbackonhide":(actor) {
                OPENWORLD.Actor.disableDistanceThrottle(actor);
              },
              'startat': OPENWORLD.Math.random(),
              //  'label': 'courtwomen',
              "lerpopacity": 1
            });
      }
      var northhelpoints=createCrowdPoints(1.86,9.33,2.91,3.15,10,0.02,[[7.25,3.03,0.4]]);
      for (var point in northhelpoints) {
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(actorlist)),
              'p': [point[0], point[1]],
              'l': 1,
              't': 0,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'squat',
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

      // Random person in the crowd asks if you are lost
      var oldfriend = await OPENWORLD.Actor.copyActor(OPENWORLD.Math.randPick(adultlist), randomduration: 0.1,
          action: "idle3"); //, action:"idlehold");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          oldfriend,6.46, -5.86,0, 3,lerpopacity: 1,level:1);
      _hotload.add(oldfriend);
      OPENWORLD.Space.objTurn(oldfriend, 120);
      if (OPENWORLD.Math.random()<0.05) {
        var hasseen = 0;
        OPENWORLD.BaseObject.setDistanceTrigger(
            oldfriend, dist: 0.3, event: (action) {
          if (action && hasseen<2) {
            hasseen++;
            OPENWORLD.Space.faceObjectAlways(oldfriend, threeJs.camera);
//            OPENWORLD.Space.faceObjectLerp(oldfriend, threeJs.camera, 1.0);
            OPENWORLD.Mob.setSpeech(oldfriend,
                [hasseen==1?"Are you lost?":"Where are you going?"], z: 100,
                width: 300,
                clearwhendone: true,
                minwait: 4,
                scale: 0.4,
                randwait: 0,
                //   delay:9
                callbackonfinish: (actor) {
                    OPENWORLD.Space.removeFaceObjectAlways(actor);
                //  OPENWORLD.Space.objTurnLerp(oldfriend, 120, 1.0);
                }
            );
          } else {

          }
        });
      }
    }

    // This is the crowd of people in the court of women and court of israel that are not part of the tamid so are not all facing west
    // They are people there eg during say womensgate or sukkot
    if (Glob.roamsukkot||(OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)&&!Glob.roamtamid && !Glob.roamketoret && !Glob.testtamidfinal &&
        gamestart != GameStart.hearth &&
        gamestart != GameStart.bethphage)
    //   gamestart != GameStart.womensgate
    ) {
      print("create non tamid court women crowd");
      var west = 5.65;
      var east = 8.82;
      var south = -1.3;
      var north = 2.19;
      // var minx, maxx, miny, maxy;
      var diff = 0.3;

      var minmaxlist = [

        [ north - diff, north, west, east, 30], // north
        [ south, south + diff, west, east, 30], //south
        [ south, north, east - diff, east, 30], // east
        [
          south + diff,
          north - diff,
          west + diff,
          east - diff,
          Glob.roamsukkot ? 60 : 10
        ], // centre
        [ -1.21, 2.15, 5.04, 5.29, Glob.roamsukkot ? 60 : 20] // court israel!
      ];
      var friendpathtemplepoints = [];
      var pathdiff = 0.4;
      if (gamestart == GameStart.womensgate)
        friendpathtemplepoints = OPENWORLD.Math.interpolateByIncrement(
            friendpathtemple, pathdiff / 2);
      List allpoints = [];

      for (var i = 0; i < minmaxlist.length; i++) {
        var minmax = minmaxlist[i];
        var miny = minmax[0],
            maxy = minmax[1],
            minx = minmax[2],
            maxx = minmax[3],
            density = minmax[4];
        var exclude = [];
        for (var point in friendpathtemplepoints) {
          var x = point[0];
          var y = point[1];
          if (y > miny - 0.5 &&
              y < maxy + 0.5 &&
              x > minx - 0.5 &&
              x < maxx + 0.5) {
            exclude.add(
                [x, y, pathdiff, pathdiff]);
          }
        }
        if (i == 3) {
          for (var point in lampstands)
            exclude.add([point[0], point[1], 0.1]);
        }
        // This is for the non tamid crowd in the court of women
        var points = closestPersonAngle(createCrowdPoints(
            minx,
            maxx,
            miny,
            maxy,
            density,
            0.02,
            exclude));
        allpoints.addAll(points);
      }
      // Create the crowd from all the points
      for (var point in allpoints) {
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                // if west of nicanor then male only
                  OPENWORLD.Math.randPick(
                      point[0] > 5.6 ? actorlist : malelist)),
              'p': [point[0], point[1]],
              'l': 1,
              't': point[2], //OPENWORLD.Math.random() * 360, //270,
              'pitch': 0,
              'roll': 0,
              'action': 'idle3',
              'randomduration': 0.1,
              'startat': OPENWORLD.Math.random(),
              'label': 'courtwomennontamid',
              "lerpopacity": 1,
              "callbackonvisible": (actor) {
                var positionjson = OPENWORLD.Config.getPositionForObject(actor);
                var x = positionjson!['p'][0];
                var y = positionjson!['p'][1];
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5,
                    skipFrames: gamestart == GameStart.womensgate && y > 5.6 &&
                        x < 1.0 && x > 0.29
                        ? 3
                        : 6); // So that womensgate and looking at priest the people arent jerky as look at the altar
              },
              "callbackonhide": (actor) {
                OPENWORLD.Actor.disableDistanceThrottle(actor);
              },
            });
      }

      // Create a rabbi with his students in the court of women
      createRabbi(5.80, 1.35 - 0.25 + 0.21, 180.0, 1); //-4.14,-12.77,0.0);

      // Put a line of priests on the temple steps - probably not accurate
      for (var i = 0; i < 3; i++) {
        var priest3ii = await OPENWORLD.Actor.copyActor(
            OPENWORLD.Math.randPick(priestlist), randomduration: 0.1,
            action: "idle");
        _hotload.add(priest3ii);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            priest3ii, 3.19, 0.67 + i * 0.1, 0, 5,
            level: 1); //4.61, -0.26,0,3);//3.53, -0.01,0,3);//.015);//1.15, 4.24,0);//1.47, 3.80,0.0);
        OPENWORLD.Space.objTurn(priest3ii, 150);

     }

    } else if (OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {
      // If tamid then you create a tamid court crowd facing west instead
      print("create tamid court women crowd");

      createTamidCourtCrowd(100, 40); //,270);
    }




    /* women on the balcony - if add passover where women were on the balcony instead of standing in the court of women
    for (var actor in womanlist) {
      var citizenoldwoman3 = await OPENWORLD.Actor.copyActor(
          actor, castshadow: false); //,action:"walk");

      // setActorSize(citizenoldwoman2);
      // OPENWORLD.Space.worldToLocalSurfaceObjHide(
      //     citizenoldwoman3, 7.62, 3.72,0.13,3,level:1);//  8.33, 1.30, 0.0, 3); //3.42);
      _hotload.add(citizenoldwoman3);
      var girlspeed = 0.025;
      var girlz = 0.1;
      OPENWORLD.Mob.moveToLoop(citizenoldwoman3,
          [
            {'p':[4.92, 2.95, girlz],'v': girlspeed},
            { "action":"idle", "time":5, "duration":null, "z":girlz, "t":180},
            {'p':[6.03, 2.95, girlz],'v': girlspeed},
            { "action":"idle", "time":10, "duration":null, "z":girlz, "t":180},
            {'p':[5.98, 3.69, girlz],'v': girlspeed},
            {'p':[7.0, 3.69, girlz],'v': girlspeed},
            { "action":"idle", "time":10, "duration":null, "z":girlz, "t":180},
            {'p':[8.26, 3.69, girlz],'v': girlspeed},
            {'p':[8.26, 3.32, girlz],'v': girlspeed},
            { "action":"idle", "time":10, "duration":null, "z":girlz, "t":180},
            {'p':[8.98, 3.36, girlz],'v': girlspeed},
            {'p':[8.93, -0.83, girlz],'v': girlspeed},
            {'p':[8.22, -0.84, girlz],'v': girlspeed},
            { "action":"idle", "time":10, "duration":null, "z":girlz, "t":0},
            {'p':[8.22, -1.30, girlz],'v': girlspeed},
            {'p':[5.99, -1.25, girlz],'v': girlspeed},
            {'p':[6.01, -0.46, girlz],'v': girlspeed},
            { "action":"idle", "time":10, "duration":null, "z":girlz, "t":0},
            {'p':[4.90, -0.36, girlz],'v': girlspeed}
          ]


          randomposition: true,
          //  duration:0.7,
          //  index:0,
          // randomduration: 0.1,
          looptype:OPENWORLD.Mob.LoopTypeReverseLoop,// reverseloop: true,
          //  surfaceonly: true,
          level: 1,
          action: "walk"
      );
    }*/
    /* were these so you could walk up to the balcony?
    OPENWORLD.Portals.createPortal(
        5.35, -0.20,
        level: 1,
        0.2,
        0.2,
        5.35+1, -0.20,
        0.0,
        level2: 0,
         marker:_hotload,
        finalturn:270,
        lerp: 1);



    OPENWORLD.Portals.createPortal(
        5.64, -0.15,
        level: 0,
        0.2,
        0.2,
        5.64, -0.15-0.5,
        0.0,
        level2: 1,
        marker:_hotload,
        //   finalturn:270,
        lerp: 1);
    */


    var doorgoldsouthgateeast = doorwood.clone();
    doorgoldsouthgateeast.scale.setValues(0.2, 0.35,0.2);//37, 0.2);
    OPENWORLD.Texture.setMaterial(doorgoldsouthgateeast, goldmaterialnormal!);
    _hotload.add(doorgoldsouthgateeast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(doorgoldsouthgateeast, 7.34 + 0.02, -1.49, 0.00, level: 1, 10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    var doorgoldsouthgateeast2 = doorgoldsouthgateeast.clone();
    _hotload.add(doorgoldsouthgateeast2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(doorgoldsouthgateeast2, 7.34 + 0.02, -2.01, 0.00, level: 1, 10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
    //doorgold.scale.setValues(0.2, 0.38, 0.2);

    var doorgoldsouthgatewest = doorgoldsouthgateeast.clone();
    _hotload.add(doorgoldsouthgatewest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorgoldsouthgatewest, 7.16 - 0.02, -1.49, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    var doorgoldsouthgatewest2 = doorgoldsouthgateeast.clone();
    _hotload.add(doorgoldsouthgatewest2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorgoldsouthgatewest2, 7.16 - 0.02, -2.01, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    doorwaysOpen()
    {
      return !OPENWORLD.Time.isNight(OPENWORLD.Time.time)||Glob.roamsukkot;
    }

    // Doors south of the court of women - made up of two sets on the inside and outside
    var doorwaysouthgate=OPENWORLD.Doorway();
    doorwaysouthgate.addDoor(doorgoldsouthgateeast,0,90);
    doorwaysouthgate.addDoor(doorgoldsouthgatewest,0,-90);
    doorwaysouthgate.addDoor(doorgoldsouthgateeast2,180,90);
    doorwaysouthgate.addDoor(doorgoldsouthgatewest2,180,-90);
    doorwaysouthgate.obstacle=  OPENWORLD.Obstacles.createObstacle(7.22, -1.72,0.4,0.7,level:1);//,marker:_hotload);
//    doorwaysouthgate.obstacle=  OPENWORLD.Obstacles.createObstacle(7.22, -1.49,0.4,0.2,level:1);//,marker:_hotload);
    doorwaysouthgate.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwaysouthgate);

    if (gamestart==GameStart.womensgate||gamestart==GameStart.lowercity) {
      // Women are not allow in the court of israel
      var maxx = 5.63,
          miny = -0.31,
          minx = maxx - 0.2,
          maxy = 1.02;
      OPENWORLD.Obstacles.createObstacle(
          (maxx + minx) / 2, (maxy + miny) / 2, maxx - minx,
          maxy - miny,level:1);//marker:_hotload);
    }

    // These are the gold doors either side of the nicanor gate
    var doorgoldnorthgateeast = doorgoldsouthgateeast.clone();
    //  doorgoldnorthgateeast.scale.setValues(0.2, 0.37, 0.2);
    // OPENWORLD.Texture.setMaterial(doorgoldnorthgateeast, goldmaterialnormal!);
    _hotload.add(doorgoldnorthgateeast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorgoldnorthgateeast, 7.34 + 0.02 - 0.02, 2.23, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    var doorgoldnorthgateeast2 = doorgoldsouthgateeast.clone();
    //  doorgoldnorthgateeast.scale.setValues(0.2, 0.37, 0.2);
    // OPENWORLD.Texture.setMaterial(doorgoldnorthgateeast, goldmaterialnormal!);
    _hotload.add(doorgoldnorthgateeast2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorgoldnorthgateeast2, 7.34 + 0.02 - 0.02, 2.7, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    var doorgoldnorthgatewest = doorgoldnorthgateeast.clone();
    _hotload.add(doorgoldnorthgatewest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorgoldnorthgatewest, 7.16 - 0.04, 2.23, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    var doorgoldnorthgatewest2 = doorgoldnorthgateeast.clone();
    _hotload.add(doorgoldnorthgatewest2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorgoldnorthgatewest2, 7.16 - 0.04, 2.7, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    // Doorway for the north entrance of court of women - two sets
    var doorwaynorthgate=OPENWORLD.Doorway();
    doorwaynorthgate.addDoor(doorgoldnorthgateeast,180,90);
    doorwaynorthgate.addDoor(doorgoldnorthgatewest,180,-90);
    doorwaynorthgate.addDoor(doorgoldnorthgateeast2,0,90);
    doorwaynorthgate.addDoor(doorgoldnorthgatewest2,0,-90);
    doorwaynorthgate.obstacle=  OPENWORLD.Obstacles.createObstacle(7.22,2.42,0.4,0.7,level:1);//,marker:_hotload);
//    doorwaynorthgate.obstacle=  OPENWORLD.Obstacles.createObstacle(7.22,2.23,0.4,0.2,level:1);//,marker:_hotload);
    doorwaynorthgate.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwaynorthgate);

    // Doors on eastern most side of court of women
    var doorgoldeastgatenorth = doorgoldsouthgateeast.clone();

    _hotload.add(doorgoldeastgatenorth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorgoldeastgatenorth, 8.91, 0.48, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    var doorgoldeastgatesouth = doorgoldeastgatenorth.clone();
    _hotload.add(doorgoldeastgatesouth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorgoldeastgatesouth, 8.91, 0.23, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    var doorwayeastgate=OPENWORLD.Doorway();
    doorwayeastgate.addDoor(doorgoldeastgatenorth,-90,0);
    doorwayeastgate.addDoor(doorgoldeastgatesouth,270,180);
    doorwayeastgate.obstacle=  OPENWORLD.Obstacles.createObstacle(8.91, 0.36,0.2,0.4,level:1);//,marker:_hotload);
    doorwayeastgate.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwayeastgate);


    // wicket on north side of nicanor gates
    Glob.doorgoldnicanoreastgatenorth = doorgoldsouthgateeast.clone();
    Glob.doorgoldnicanoreastgatenorth.scale.setValues(0.2, 0.37, 0.36);
    //  doorgoldnicanoreastgateeast.scale.setValues(0.2, 0.37, 0.2);
    // OPENWORLD.Texture.setMaterial(doorgoldnicanoreastgateeast, goldmaterialnormal!);
    _hotload.add(Glob.doorgoldnicanoreastgatenorth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.doorgoldnicanoreastgatenorth, 5.5 + 0.02, 0.97, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
    //doorgold.scale.setValues(0.2, 0.38, 0.2);
   /* if (OPENWORLD.Time.isNight(OPENWORLD.Time.time))
      OPENWORLD.Space.objTurn(Glob.doorgoldnicanoreastgatenorth, 90 - 90);
    else
      OPENWORLD.Space.objTurn(Glob.doorgoldnicanoreastgatenorth, 90);*/

    Glob.doorwaynicanoreastgatenorth=OPENWORLD.Doorway();
    Glob.doorwaynicanoreastgatenorth.addDoor(Glob.doorgoldnicanoreastgatenorth,90,0);
    Glob.doorwaynicanoreastgatenorth.obstacle=  OPENWORLD.Obstacles.createObstacle(5.5,0.87,0.2,0.3,level:1);//,marker:_hotload);
    Glob.doorwaynicanoreastgatenorth.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(Glob.doorwaynicanoreastgatenorth);

    // Wicket on south side on nicanor gate
    Glob.doorgoldnicanoreastgatesouth =
        Glob.doorgoldnicanoreastgatenorth.clone();
    _hotload.add(Glob.doorgoldnicanoreastgatesouth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.doorgoldnicanoreastgatesouth, 5.5 + 0.02, -0.22 - 0.02, 0.00,
        level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
  /*  if (OPENWORLD.Time.isNight(OPENWORLD.Time.time))
      OPENWORLD.Space.objTurn(Glob.doorgoldnicanoreastgatesouth, -90 + 90);
    else
      OPENWORLD.Space.objTurn(Glob.doorgoldnicanoreastgatesouth, 180 + 90);*/
    Glob.doorwaynicanoreastgatesouth=OPENWORLD.Doorway();
    Glob.doorwaynicanoreastgatesouth.addDoor(Glob.doorgoldnicanoreastgatesouth,90,0);//180);
    Glob.doorwaynicanoreastgatesouth.obstacle=  OPENWORLD.Obstacles.createObstacle(5.5,-0.13,0.2,0.3,level:1);//,marker:_hotload);
    Glob.doorwaynicanoreastgatesouth.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(Glob.doorwaynicanoreastgatesouth);


    // This is the actual nicanor gate
    Glob.doornicanornorth = doornicanor.clone();
    _hotload.add(Glob.doornicanornorth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.doornicanornorth, 5.5-0.01-0.01, 0.51 + 0.01, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
    //doorgold.scale.setValues(0.2, 0.38, 0.2);
 /*   if (OPENWORLD.Time.isNight(OPENWORLD.Time.time))
      OPENWORLD.Space.objTurn(Glob.doornicanornorth, 0); //90-90);
    else
      OPENWORLD.Space.objTurn(Glob.doornicanornorth, -90);*/

    Glob.doornicanorsouth = Glob.doornicanornorth.clone();
    _hotload.add(Glob.doornicanorsouth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.doornicanorsouth, 5.5-0.01-0.01, 0.23 + 0.02-0.02, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
 /*   if (OPENWORLD.Time.isNight(OPENWORLD.Time.time))
      OPENWORLD.Space.objTurn(Glob.doornicanorsouth, -90 + 90);
    else
      OPENWORLD.Space.objTurn(Glob.doornicanorsouth, 180 + 90);
*/
    Glob.doorwaynicanor=OPENWORLD.Doorway();
    Glob.doorwaynicanor.addDoor(Glob.doornicanorsouth,90,180);  // 90 is the angle in chamber of hearth going inwards
    Glob.doorwaynicanor.addDoor(Glob.doornicanornorth,  90,0);
  //  Glob.doorwaynicanor.addDoor(Glob.doornicanorsouth,-90,0);
   // Glob.doorwaynicanor.addDoor(Glob.doornicanornorth, 180 + 90,0);
    Glob.doorwaynicanor.obstacle=  OPENWORLD.Obstacles.createObstacle(5.5, 0.37,0.2,0.6,level:1);//,marker:_hotload);
    Glob.doorwaynicanor.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(Glob.doorwaynicanor);


    // Chamber of the hewnstone onto the inner court
    Glob.doorwoodhewnstoneeast = doorwood.clone();
    //doorwood.scale.setValues(0.2, 0.52, 0.2);

    _hotload.add(Glob.doorwoodhewnstoneeast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.doorwoodhewnstoneeast, 5.03, -1.46 + 0.02, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
    Glob.doorwoodhewnstoneeast.scale.setValues(0.2, 0.38, 0.2);
   /* if (OPENWORLD.Time.isNight(OPENWORLD.Time.time))
      OPENWORLD.Space.objTurn(Glob.doorwoodhewnstoneeast, 90);
    else
      OPENWORLD.Space.objTurn(Glob.doorwoodhewnstoneeast, 0);*/

    Glob.doorwoodhewnstonewest =
        Glob.doorwoodhewnstoneeast.clone(); //doorwood.clone();
    _hotload.add(Glob.doorwoodhewnstonewest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.doorwoodhewnstonewest, 4.82 - 0.01, -1.46 + 0.02, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
   /* if (OPENWORLD.Time.isNight(OPENWORLD.Time.time))
      OPENWORLD.Space.objTurn(Glob.doorwoodhewnstonewest, -90);
    else
      OPENWORLD.Space.objTurn(Glob.doorwoodhewnstonewest, 180);*/
    Glob.doorwayhewnstone=OPENWORLD.Doorway();
    Glob.doorwayhewnstone.addDoor(Glob.doorwoodhewnstoneeast,0,90);  // 90 is the angle in chamber of hearth going inwards
    Glob.doorwayhewnstone.addDoor(Glob.doorwoodhewnstonewest,  0,-90);
    Glob.doorwayhewnstone.obstacle=  OPENWORLD.Obstacles.createObstacle(4.91,  -1.46 + 0.02,0.3,0.2,level:1);//,marker:_hotload);
    Glob.doorwayhewnstone.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(Glob.doorwayhewnstone);

    // Lamp in the east side of hewnstone
    var lampposx = 5.4;
    var lampposy = -1.68 - 0.01 + 0.03;
    var lampposz = 0.115; //068;
    Glob.lampbronzehewnstoneeast = lampbronze.clone();
    OPENWORLD.Space.setTurnPitchRoll(Glob.lampbronzehewnstoneeast, 0, 0, 0);
    //  OPENWORLD.Space.objTurn(lampbronze1,-90);
    Glob.lampbronzehewnstoneeast.scale.setValues(0.01, 0.01, 0.01);
    _hotload.add(Glob.lampbronzehewnstoneeast);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.lampbronzehewnstoneeast, lampposx, lampposy, lampposz, level: 1,
        1.0); //0.88, 2.99,0,level:1, //0.01,//0.87, 2.79
    //   3); //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);

    Glob.grouplamphewnstoneeast = THREE.Group();
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)||gamestart==GameStart.hearth) {
      var lightlamp = new THREE.PointLight(
          0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

      lightlamp.intensity = 0.02; // 0.6;
      lightlamp.distance = 0.3; //1.2;
      // light.position.y = 0.33;
      OPENWORLD.Light.addFlicker(lightlamp);
      Glob.grouplamphewnstoneeast.add(lightlamp);
    }
    _hotload.add(Glob.grouplamphewnstoneeast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.grouplamphewnstoneeast, lampposx - 0.01, lampposy + 0.005,
        lampposz + 0.01, level: 1, 1.0); //1.46-0.05, 4.22-0.05, 0.0, 3);
    Glob.grouplamphewnstoneeast.visible = false;
    OPENWORLD.Space.removeObjFromHide(Glob.grouplamphewnstoneeast);

    // Lamp on west side of chamber of the hewnstone
    var lampposxwest = 4.43;
    Glob.lampbronzehewnstonewest = Glob.lampbronzehewnstoneeast.clone();
    _hotload.add(Glob.lampbronzehewnstonewest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.lampbronzehewnstonewest, lampposxwest, lampposy, lampposz,
        level: 1, 1.0); //1.46-0.05, 4.22-0.05, 0.0, 3);

    Glob.grouplamphewnstonewest = THREE.Group();
    var lightlamphewnstone2 = new THREE.PointLight(
        0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

    lightlamphewnstone2.intensity = 0.02; // 0.6;
    lightlamphewnstone2.distance = 0.3; //1.2;
    OPENWORLD.Light.addFlicker(lightlamphewnstone2);
    Glob.grouplamphewnstonewest.add(lightlamphewnstone2);
    _hotload.add(Glob.grouplamphewnstonewest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        Glob.grouplamphewnstonewest, lampposxwest + 0.01, lampposy + 0.005,
        lampposz + 0.01, level: 1, 1.0); //1.46-0.05, 4.22-0.05, 0.0, 3);
    Glob.grouplamphewnstonewest.visible = false;
    OPENWORLD.Space.removeObjFromHide(Glob.grouplamphewnstonewest);


    // south east column in chamber of hewnstone
    instancedColumns.place(
        90, 5.36, -2.15, 0.0, level: 1, scale: THREE.Vector3(1.0, 1.5, 1.0));
    // south west column
    instancedColumns.place(
        90, 4.45, -2.15, 0.0, level: 1, scale: THREE.Vector3(1.0, 1.5, 1.0));
    // north east
    instancedColumns.place(
        -90, 5.36, -1.52, 0.0, level: 1, scale: THREE.Vector3(1.0, 1.2, 1.0));
    //north weast
    instancedColumns.place(
        -90, 4.45, -1.52, 0.0, level: 1, scale: THREE.Vector3(1.0, 1.2, 1.0));
    //mid east
    instancedColumns.place(
        90, 5.36, -1.8 + 0.05, 0.0, level: 1,
        scale: THREE.Vector3(1.0, 1.2, 1.0));
    //mid west
    instancedColumns.place(
        90, 4.45, -1.8 + 0.05, 0.0, level: 1,
        scale: THREE.Vector3(1.0, 1.2, 1.0));

    // Doors on wilsons arch
    var doorwilsonsarchnorth = doorwood.clone();
    doorwilsonsarchnorth.scale.setValues(0.05*2, 0.12*3.3, 0.09*2.8);

    //  doorgoldeastgateeast.scale.setValues(0.2, 0.37, 0.2);
    // OPENWORLD.Texture.setMaterial(doorgoldeastgateeast, goldmaterialnormal!);
    _hotload.add(doorwilsonsarchnorth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwilsonsarchnorth, -5.21-0.1, -2.59, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
    var doorwilsonsarchsouth = doorwilsonsarchnorth.clone();
    _hotload.add(doorwilsonsarchsouth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwilsonsarchsouth, -5.21-0.1,-2.28-0.02, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    var doorwaywilsonarch=OPENWORLD.Doorway();
    doorwaywilsonarch.addDoor(doorwilsonsarchnorth,-90,180);
    doorwaywilsonarch.addDoor(doorwilsonsarchsouth,270,0);
    doorwaywilsonarch.obstacle=  OPENWORLD.Obstacles.createObstacle(-5.21-0.1, -2.45,0.2,0.4,level:1);//,marker:_hotload);
    doorwaywilsonarch.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwaywilsonarch);

    // Portal to get you on and off the wilsons arch bridge
    OPENWORLD.Portals.createPortal(
       -16.55,-4.92,
        0.04,
        0.4,
        level: 0,
        -16.3,-4.86,
        0.0,
        //  marker:_hotload,
        angleentry: 90,
        angleentrythresh: 140,
        level2:1,
        lerp: 3,
    );

    OPENWORLD.Portals.createPortal(
        -16.55,-4.92,
        0.04,
        0.4,
        level: 1,
        -16.74 ,
        -4.94,
        0.0,
        level2: 0,
        angleentry: 270,
        angleentrythresh: 140,
        // marker:_hotload,
        lerp:3);


    // Doors of robinsons arch
    var doorrobinsonsarchnorth = doorwood.clone();
    doorrobinsonsarchnorth.scale.setValues(0.05*2, 0.12*4.8, 0.09*7.66);
    //  doorgoldeastgateeast.scale.setValues(0.2, 0.37, 0.2);
    // OPENWORLD.Texture.setMaterial(doorgoldeastgateeast, goldmaterialnormal!);
    _hotload.add(doorrobinsonsarchnorth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorrobinsonsarchnorth, -5.21-0.1,-11.22, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);
    var doorrobinsonsarchsouth = doorrobinsonsarchnorth.clone();
    _hotload.add(doorrobinsonsarchsouth);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorrobinsonsarchsouth, -5.21-0.1,-12.09, 0.00, level: 1,
        10); //1.46-0.05, 4.22-0.05, 0.01, 2); // 3.2,2.5, 0.0);

    var doorwayrobinsonsarch=OPENWORLD.Doorway();
    doorwayrobinsonsarch.addDoor(doorrobinsonsarchnorth,-90,0);
    doorwayrobinsonsarch.addDoor(doorrobinsonsarchsouth,270,180);
    doorwayrobinsonsarch.obstacle=  OPENWORLD.Obstacles.createObstacle(-5.21-0.1, -11.66,0.2,0.9,level:1);//,marker:_hotload);
    doorwayrobinsonsarch.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorwayrobinsonsarch);

    // Security patrol around second temple at night
    if (OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var poslist=[
        [-4.22,5.93],
        [9.89,5.77],
        [9.88,-10.02],
        [-4.33,-10.4]
      ];
      var torch2 = torch.clone();
      addflametotorch(torch2, false);
      var index=OPENWORLD.Math.randInt(poslist.length-1);
      for (var i=0; i<3; i++) {
        var security = await OPENWORLD.Actor.copyActor(
            OPENWORLD.Math.randPick(manlist) , action: "idle");
        // setActorSize(citizenoldwoman2);
        _hotload.add(security);
        if (i==0)
          OPENWORLD.Actor.wield(security, torch2, "Bip01_R_Hand");
        List<Map> path=[];
        for (var pos in poslist) {
          var xdiff=0.0, ydiff=0.0;
          if (i==1) {
            xdiff=0.05;
            ydiff=-0.05;
          } else if (i==2) {
            xdiff=-0.05;
            ydiff=0.05;
          }
          path.add({"p":[pos[0]+xdiff,pos[1]+ydiff,0],"l":1,"v":0.04});
        }
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            security, path[index]['p'][0],path[index]['p'][1],0, 15,
            level: 1); // 1.25, 4.22, 0.0, 3); //3.42);
        OPENWORLD.Mob.moveToLoop(
            security, path,
            action: i==0?"walkhandright":"walk",
            index:index,
            //randomposition: true,
            // hidedist: 15,
            // looptype: OPENWORLD.Mob.LoopTypeStop,
            surfaceonly: true,
            level: 1
          //   stopaction: "idle3",
          // delay:finishedtime
          // facedir: false
        );
      }
    }

    // Gentiles court south passageways
    // western huldah tunnel
    OPENWORLD.Portals.createPortal(
        1.61 + 0.05,
        -6.93,
        0.6,
        0.04,
        level: 1,
        1.61 + 0.05,
        -7.32,
        0.0,
        //  marker:_hotload,
        angleentry: 180,
        angleentrythresh: 140,
        level2: 0,
        //   reverse:true,
        lerp: 3,
        adjacent: true,
        callback: () {
          //   OPENWORLD.Weather.su
        }
    );

    OPENWORLD.Portals.createPortal(
        1.61 + 0.05,
        -7.1,
        0.6,
        //27,
        0.04,
        level: 0,
        1.61 + 0.05,
        -6.75,
        0.0,
        level2: 1,
        adjacent: true,
        angleentry: 0,
        angleentrythresh: 140,
        // marker:_hotload,

        //   reverse:true,
        lerp:3);

    // eastern huldah tunnel
    OPENWORLD.Portals.createPortal(
        5.85,
        -6.93,
        1.0,
        0.04,
        level: 1,
        5.85,
        -7.32,
        0.0,
        //    marker:_hotload,

        level2: 0,
        //   reverse:true,
        lerp: 1,
        adjacent: true,
        callback: () {
          //   OPENWORLD.Weather.su
        }
    );

    OPENWORLD.Portals.createPortal(
        5.85,
        -7.1,
        1.0,
        0.04,
        level: 0,
        5.85,
        -6.7,
        0.0,
        level2: 1,
        adjacent: true,
        //  marker:_hotload,

        //   reverse:true,
        lerp: 1);

    // Lamps in the huldah gate tunnels
    List<dynamic> lamps = [
      [ 1.76 - 0.02 + 0.22, -8.16, 0.115], // stoa passage west
      [ 1.76 - 0.02 - 0.07 + 0.26, -10.09 - 0.01, 0.17],
      [ 1.6, -12.4, 0.17, false],
      [ 5.97 - 0.03 - 0.54, -8.16, 0.115], // stoa passage east
      [ 6.0 + 0.01 - 0.58, -10.09 - 0.01, 0.17],
      [ 5.96, -12.4, 0.17, false],

    ];
    var dist =2.0;
    // Here you just placing the lamp in the stoa passageway
    for (var lamp in lamps) {
      lampposx = lamp[0]; //1.76 - 0.02;
      lampposy = lamp[1]; //-8.16;
      lampposz = lamp[2]; // 0.115; //42;//068;
      if (lamp.length == 3 || lamp[3]) {
        var lampbronze1 = lampbronze.clone();
        OPENWORLD.Space.setTurnPitchRoll(lampbronze1, 0, 0, 0);
        //  OPENWORLD.Space.objTurn(lampbronze1,-90);
        lampbronze1.scale.setValues(0.01, 0.01, 0.01);
        _hotload.add(lampbronze1);

        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            lampbronze1, lampposx, lampposy, lampposz, dist,

            lerpopacity: 1.0); //0.88, 2.99,0,level:1, //0.01,//0.87, 2.79
        //   3); //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);
      }
      // Here you are adding the actual light
      if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
        var grouplamp = THREE.Group();
        grouplamp.extra['grouplamp']=true;
        var lightlamp = new THREE.PointLight(
            0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)
        lightlamp.intensity = 0.4; // 0.6;
        lightlamp.distance = dist; //1.2;
        lightlamp.decay = 0.3;
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
        if (gamestart != GameStart.bethphage) {
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              grouplamp, lampposx - 0.01, lampposy + 0.005, lampposz + 0.01, dist, lerplight: 1);
          print("stoa lamp "+ lampposx.toString()+" "+lampposy.toString()+" "+lampposz.toString()+" "+ dist.toString());
        } else {
          // do it like this so that don't get big jump when the light turns on during bethspage journey
          OPENWORLD.Space.worldToLocalSurfaceObj(
              grouplamp, lampposx - 0.01, lampposy + 0.005, lampposz + 0.01);
          grouplamp.visible = false;
          OPENWORLD.BaseObject.setDistanceTrigger(
              grouplamp, dist: dist,
              level: 0,
              ignoreifhidden: false,
              event: (action) {
                if (action) {
                  // print("light tunnel on");
                  grouplamp.visible = true;
                  // OPENWORLD.Light.intensityLerpObj(lightlamp, 1.0, 1.0);
                  //  OPENWORLD.Light.intensityLerp(lightlamp, 0.4, 1.0);
                  //lightlamp.visible=true;
                  //lightlamp.intensity=1.0;
                  //grouplamp.updateMatrix();
                  // lightlamp.updateMatrix();

                  // OPENWORLD.Texture.opacityLerp(lampbronze1, 1.0, 1.0);

                } else {
                  // print("light tunnel off");
                  // OPENWORLD.Light.intensityLerpObj(lightlamp, 0.0, 1.0);
//          OPENWORLD.Light.intensityLerp(lightlamp, 0.01, 1.0);
                  //  OPENWORLD.BaseObject.setVisible(grouplamp,false,delay:1);  //unecessary as intensitylerp switches it off for you if zero intensity
                  grouplamp.visible = false;
                }
              });
        }
      }
    }

    // Columns in west passageway
    var columnys = [
      [1.69, -7.05 + 0.04, 0.43],
      [1.69 - 0.03, -7.41, 0.55],
      [1.69 - 0.03, -8.04, 0.65],
      [1.69 - 0.05, -9.15, 0.6],
      [ 1.62, -9.9, 0.94],
      [1.69 - 0.08, -10.87, 1.32],
      [1.69 - 0.06 - 0.08, -13.1 + 0.03, 0.6]];
    for (var pos in columnys) {
      instancedColumns.place(180, pos[0], pos[1], 0.0, level: 0,
          scale: THREE.Vector3(pos[2], pos[2], pos[2])); //,5);  //3.93
      //instancedColumns.place(180, pos[0]+4.47, pos[1], 0.0, level: 0,
      //    scale: THREE.Vector3(pos[2], pos[2], pos[2])); //,5);  //3.93

      //  5.93
    }
    //Columns east passageway
    columnys = [
      [1.69 + 4.35, -7.05 + 0.04, 0.43],
      [1.69 - 0.03 + 4.35, -7.41, 0.55],
      [1.69 - 0.03 + 4.36, -8.04, 0.65],
      [1.69 - 0.05 + 4.39, -9.15, 0.6],
      [ 1.62 + 4.45, -9.9, 0.94],
      [1.69 - 0.08 + 4.47, -10.87, 1.32],
      [1.69 - 0.06 - 0.08 + 4.58, -13.1 + 0.03, 0.6]
    ];

    for (var pos in columnys) {
      instancedColumns.place(180, pos[0], pos[1], 0.0, level: 0,
          scale: THREE.Vector3(pos[2], pos[2], pos[2])); //,5);  //3.93
      instancedColumns.place(180, pos[0] - 0.3, pos[1], 0.0, level: 0,
          scale: THREE.Vector3(pos[2], pos[2], pos[2])); //,5);  //3.93

      //  5.93
    }

    // Huldah gate doorways
    var doorwoodhuldahwest = doorwood.clone();
    _hotload.add(doorwoodhuldahwest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodhuldahwest,1.27, -12.91-0.14, 0.00, 4);

    doorwoodhuldahwest.scale.setValues(0.05*2, 0.12*2.6, 0.09*4.9);

   // OPENWORLD.Space.objTurn(doorwoodhuldahwest, 180);
  /*  if (OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      OPENWORLD.Space.objTurn(doorwoodhuldahwest, 270);

    } else
      doorwoodhuldahwest.visible=false;
    //  OPENWORLD.Space.objTurn(doorwoodhuldahwest, 180);
*/
    var doorwoodhuldaheast = doorwoodhuldahwest.clone();
    _hotload.add(doorwoodhuldaheast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodhuldaheast,1.85, -12.91-0.14, 0.00, 4);


  //  OPENWORLD.Space.objTurn(doorwoodhuldaheast, 0);
  /*  if (OPENWORLD.Time.isNight(OPENWORLD.Time.time))
      OPENWORLD.Space.objTurn(doorwoodhuldaheast, 90);
    else
      doorwoodhuldaheast.visible=false;*/
   //   OPENWORLD.Space.objTurn(doorwoodhuldaheast, 180);


    var doorway=OPENWORLD.Doorway();
    doorway.addDoor(doorwoodhuldaheast, 180,90,hideifopen: true);
    doorway.addDoor(doorwoodhuldahwest, 180,270,hideifopen: true);
    doorway.obstacle=  OPENWORLD.Obstacles.createObstacle((1.85+1.27)/2, -12.91-0.14,0.6,0.2);//,marker:_hotload);
    doorway.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorway);


    var doorwoodhuldahtriplewest = doorwoodhuldaheast.clone();
    _hotload.add(doorwoodhuldahtriplewest);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodhuldahtriplewest,5.53, -12.91-0.14, 0.00, 4);
    // OPENWORLD.Space.objTurn(doorwoodhuldahwest, 180);
   /*  if (OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      OPENWORLD.Space.objTurn(doorwoodhuldahtriplewest, 270);
    } else
       doorwoodhuldahtriplewest.visible=false;*/
    var doorwoodhuldahtriplecenter = doorwoodhuldaheast.clone();
    _hotload.add(doorwoodhuldahtriplecenter);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodhuldahtriplecenter,5.88, -12.91-0.14, 0.00, 4);
    // OPENWORLD.Space.objTurn(doorwoodhuldahwest, 180);
  /*  if (OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      OPENWORLD.Space.objTurn(doorwoodhuldahtriplecenter, 270);
    } else
      doorwoodhuldahtriplecenter.visible=false;*/
    var doorwoodhuldahtripleeast = doorwoodhuldaheast.clone();
    _hotload.add(doorwoodhuldahtripleeast);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorwoodhuldahtripleeast,6.42, -12.91-0.14, 0.00, 4);
    // OPENWORLD.Space.objTurn(doorwoodhuldahwest, 180);
   /* if (OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      OPENWORLD.Space.objTurn(doorwoodhuldahtripleeast, 90);
    } else
      doorwoodhuldahtripleeast.visible=false;*/

   // ;//,marker:_hotload);
    doorway=OPENWORLD.Doorway();
    doorway.addDoor(doorwoodhuldahtriplewest, 180,270,hideifopen: true);
    doorway.addDoor(doorwoodhuldahtriplecenter, 180,270,hideifopen: true);
    doorway.addDoor(doorwoodhuldahtripleeast, 180,90,hideifopen: true);
    doorway.obstacle=  OPENWORLD.Obstacles.createObstacle(5.88, -12.91-0.14,1.0,0.2);//,marker:_hotload);
    doorway.setOpenClose(doorwaysOpen());//!OPENWORLD.Time.isNight(OPENWORLD.Time.time));
    doorways.add(doorway);


    var ycorrectiondiff = 0.89;

    // For the southern wall mikveh baths
    // Lamps in the mikveh
    lamps = [
      [ 4.12, -14.48 + 0.015 + ycorrectiondiff, 0.075],
      [ 4.56, -14.48 + 0.02 + ycorrectiondiff, 0.075],

    ];
    for (var lamp in lamps) {
      lampposx = lamp[0]; //1.76 - 0.02;
      lampposy = lamp[1]; //-8.16;
      lampposz = lamp[2]; // 0.115; //42;//068;

      var lampbronze1 = lampbronze.clone();
      OPENWORLD.Space.setTurnPitchRoll(lampbronze1, 0, 0, 0);
      OPENWORLD.Space.objTurn(lampbronze1, -90);
      lampbronze1.scale.setValues(0.01, 0.01, 0.01);
      _hotload.add(lampbronze1);

      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          lampbronze1, lampposx, lampposy, lampposz, dist,
          lerpopacity: 1.0,
          level: -1); //0.88, 2.99,0,level:1, //0.01,//0.87, 2.79
      //   3); //4.2-0.05,0.02,3);//0.005);//1.15, 4.24,0);//1.47, 3.80,0.0);

      if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
        var grouplamp = THREE.Group();
        var lightlamp = new THREE.PointLight(
            0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)
        lightlamp.intensity = 0.4; // 0.6;
        lightlamp.distance = 0.5; //1.2;
        lightlamp.decay = 0.3;
        OPENWORLD.Light.addFlicker(lightlamp);
        grouplamp.add(lightlamp);

        _hotload.add(grouplamp);

        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            grouplamp, lampposx - 0.01, lampposy - 0.01, lampposz + 0.01, dist,
            lerplight: 1, level: -1);
      }
    }
    // Water in the mikveh
    var watermikvehlist = [
      [4.17, -15 + ycorrectiondiff, 0.05],
      [4.55, -15.03 + ycorrectiondiff, 0.035],
    ];
    for (var i=0;i<watermikvehlist.length; i++) {
      var watermikvehpos=watermikvehlist[i];
      final waterGeometryii = THREE.PlaneGeometry(20.0, 20.0);
      var watermikvehsouth = Water(waterGeometryii, WaterOptions(
        color: 0xbbddff,
        //a08a73,//ffffff,//a08a73,//params['color'],
        scale: 4 / 32.0,
        //80,//4.0/scale,//params['scale'],
        reflectivity: 0.5,
        // clipBias: 0.5,
        flowDirection: THREE.Vector2(0.05, 0.05),
        //1.0/scale,1.0/scale),// params['flowX'], params['flowY'] ),
        textureWidth: 128,
        //256,
        //(1024/scale).round(),
        textureHeight: 128, //256, // (1024/scale).round(),
      ));

      if (i==0) {
        var poolsound = OPENWORLD.Sound.getAudioPlayer();
        OPENWORLD.BaseObject.setDistanceTrigger(watermikvehsouth,
            dist: 1, event: (action) {
              if (action) {
                print("pool south mikeveh play");
                OPENWORLD.Sound.play(sound: poolsound,
                    path: 'sounds/pool.mp3',
                    loop: true,
                    volume: 0.8,
                    fadein: 1.0);
              } else {
                print("pool south mikeveh fade");
                OPENWORLD.Sound.fadeOut(poolsound, 1.0);
              }
            });
      }

      watermikvehsouth!.scale.setValues(0.013, 0.013, 1.0); // 1.7/20.0);

      OPENWORLD.Space.setTurnPitchRoll(watermikvehsouth!, 0, 0, 90);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
        //wateri, -10,-47.5,0.0, 3); //7.7, 1.0, 0.05);
          watermikvehsouth!, watermikvehpos[0], watermikvehpos[1],
          watermikvehpos[2], // 4.17, -15, 0.05,
          0.4, level: -1); //-9.9, -47.5, 0.063, 2.5); //7.7, 1.0, 0.05);
      hotloadAdd(firsthotload, false, watermikvehsouth!);
      watermikvehsouth!.reflectionUpdateInterval = 3;
      threeJs.scene.traverse((obj) {
        //   if ( obj.name!='surfaceaerialshadow') {
        if (obj is THREE.Mesh && obj.name != 'bathsroof' &&
            obj.name != 'bathswall') {
          //  wateri.excludeFromReflection.add(obj);
          // wateri) {
          final pos = THREE.Vector3();
          obj.getWorldPosition(pos);

          // Get the water's world position
          final waterPos = THREE.Vector3();
          watermikvehsouth!.getWorldPosition(waterPos);

          final dx = pos.x - waterPos.x;
          final dz = pos.z - waterPos.z;
          final distSq = dx * dx + dz * dz;

          // Exclude anything more than e.g. 8 world units from the pool
          if (distSq > 0.15 * 0.15) {
            watermikvehsouth!.excludeFromReflection.add(obj);
          }
        }
      });
      waterlist.add(watermikvehsouth);
    }

    // If daytime put some bathers in the southern wall mikveh
    if (OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {
      var batherposlist = [
        [3.51, -14.96 + ycorrectiondiff, 270],
        [3.69 + 0.06, -14.95 + ycorrectiondiff, 90],
        [4.89 + 0.04, -15.07 + ycorrectiondiff, 90],
        [5.22 + 0.04, -14.96 + ycorrectiondiff, 90]
      ];
      for (var batherpos in batherposlist) {
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  OPENWORLD.Math.randPick(manlist)), //citizen3), //
              'l': -1,
              'p': [batherpos[0], batherpos[1], 0],
              't': batherpos[2], //180,
              'action': "idle",
              'randomduration': 0.1,
              "lerpopacity": 1,
              "callbackonvisible": (actor) {
                OPENWORLD.Actor.playActionsLoop(actor,
                    ["armsup", "hitup", "pickupright"],
                    randomdurations: [0.1, 0.1, 0.1],
                    randomaction: true
                  //durations: [1,1,10],fadein:0,fadeout:2
                ); // fadeout:null);//fadein:0.5); //,*/fadeout:0.7);
              },
              "callbackonhide": (actor) {
                OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
              }
            });
        var clothespileii = clothespile.clone();
        _hotload.add(clothespileii);
        var clothespos = OPENWORLD.Math.vectorMoveForward(
            batherpos[0], batherpos[1], batherpos[2], 0.03);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            clothespileii, clothespos[0], clothespos[1], 0, 0.5, level: -1);
        //OPENWORLD.Space.worldToLocalSurfaceObjHide(
        //  clothespileii, batherposx + 0.1, batherposy - 0.1 - i * 0.07, 0, 2);
        // OPENWORLD.Space.setTurnPitchRoll(robes2iii, 0,0,0);

        OPENWORLD.Space.objTurn(clothespileii, OPENWORLD.Math.random() * 360);
      }
      var bathermikvehpos = [
        [4.16, -15 + ycorrectiondiff, citizen34],
        [4.56, -15.04 + ycorrectiondiff, citizen32]
      ];
      for (var pos in bathermikvehpos) {
        var bather = await OPENWORLD.Actor.copyActor(
            pos[2], action: "idle3", randomduration: 0.1);
        // setActorSize(citizenoldwoman2);
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            bather, pos[0], pos[1], -0.01,
            1,
            level: -1); //0.71,0,3);//2.89, 1.06,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
        hotloadAdd(firsthotload, false, bather);
        OPENWORLD.Space.objTurn(bather, 180);

        // bather.extra['bather']=true;
        //   OPENWORLD.Mob.setName(bather,"bather"+OPENWORLD.Config.getObjectName(pos[2]));
        OPENWORLD.BaseObject.setVisible(
            bather, false, groupname: "citizen_3"); // no pants
        OPENWORLD.BaseObject.setVisible(
            bather, false, groupname: "citizen_4"); // no clothes
        OPENWORLD.BaseObject.setDistanceTrigger(
            bather, dist: 1, event: (action) {
          if (action) {
            OPENWORLD.Actor.playActionsLoop(bather,
              bathingactions,
              randomaction: true,
              //  fadein:1.0
              //durations: [1,1,10],fadein:0,fadeout:2
            );
          } else {}
        });
      } // fadeout:null);//fadein:0.5); //,*/fadeout:0.7);
      // await OPENWORLD.Config.createPoolObjects();//OPENWORLD.Config.configGroup);//_hotload);

      // Some rabbis outside the southern wall mikveh
      createRabbi(2.9, -14.9 + ycorrectiondiff, 0.0, 0); //-4.14,-12.77,0.0);
      createRabbi(6.08, -15.15 + ycorrectiondiff, 0.0, 0); //-4.14,-12.77,0.0);

    }

    // Portals to get you in and out of the mikveh given there is a level 0 roof above it and this mikveh is level -1
    OPENWORLD.Portals.createPortal(
      3.55,
      -14.47,
      0.12,
      0.04,
      level: 0,
      3.55,
      -14.32,
      0.0,
      //     marker:_hotload,
      level2: -1,
      //   reverse:true,
      lerp: 1,
      // adjacent:true,
      // callback:(){
      //   OPENWORLD.Weather.su
      // }
    );

    OPENWORLD.Portals.createPortal(
        5.11,
        -14.4,
        0.12,
        0.04,
        level: -1,
        5.11,
        -14.57,
        0.0,
        level2: 0,
        //  adjacent:true,
        //   marker:_hotload,
        //   reverse:true,
        lerp: 1);

    OPENWORLD.Portals.createPortal(
      5.11,
      -14.47,
      0.12,
      0.04,
      level: 0,
      5.11,
      -14.32,
      0.0,
      //  marker:_hotload,
      level2: -1,
      //   reverse:true,
      lerp: 1,
      // adjacent:true,
      // callback:(){
      //   OPENWORLD.Weather.su
      // }
    );

    OPENWORLD.Portals.createPortal(
        3.55,
        -14.4,
        0.12,
        0.04,
        level: -1,
        3.55,
        -14.57,
        0.0,
        level2: 0,
        //  adjacent:true,
        //   marker:_hotload,
        //   reverse:true,
        lerp: 1);
    /* var diff=0.1;
    OPENWORLD.Portals.createPortal(
        4.27,-14.28+ycorrectiondiff-diff,
        5.42-3.25+0.1,
        0.04,
        level:0,
        4.27,-14.6+ycorrectiondiff-diff,
        0.0,
        //    marker:_hotload,
        level2: 1,
        //   reverse:true,
        lerp: 1,
        adjacent:true,
        callback:(){
          //   OPENWORLD.Weather.su
        }
    );

    OPENWORLD.Portals.createPortal(
        4.27,-14.46+ycorrectiondiff-diff,
        5.42-3.25+0.1,
        0.04,
        level: 1,
        4.27,-14.03+ycorrectiondiff-diff,
        0.0,
        level2:0,
        adjacent:true,
        //  marker:_hotload,
        //   reverse:true,
        lerp: 1);*/
    //bathingactions
//      instancedColumns.place(180,1.69, -6.97 -0.03- j * 0.35, 0.0, level:0,scale:THREE.Vector3(0.4,0.4,0.4));//,5);  //3.93
//      instancedColumns.place(180,1.69, -6.97 -0.03- j * 0.35, 0.0, level:0,scale:THREE.Vector3(0.5,0.5,0.5));//,5);  //3.93

    // Walkers for temple complex
    // This is the long path along steps up robinsons arch to hulah gate entrance on court of gentiles then down the stairs throug the tunnel then west along the southern wall and start again
    if (OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {
      var numwalkers = 120;
      var v = 0.03;
      List<Map> positions = [
        {"p": [3.2, -13.26, 0.0], "v": v},
        //1  // triple gate entrance
        {"p": [6.0, -13.26, 0.0], "v": v},
        //2
        {"p": [5.86, -11.02, 0.0], "v": v},
        // 3  9.08,0 -11.02
        // {"action":"idle3","time":10},//4
        {"p": [6.0, -13.26, 0.0], "v": v},
        //5
        {"p": [3.2, -13.26, 0.0], "v": v},
        //6
        {"p": [0.0, -13.26, 0.0], "v": v},
        //7
        {"p": [-5.79, -13.26, 0.0], "v": v},   // Bottom of robinsons arch steps
        {"p": [-5.85, -14.0, 0.0], "v": v},//-13.84
        //, "t": 270 - 45}, //8
        // {"p": [-6.26, -13.84, 0.0], "v": v}, //9
        {"p": [-6.14, -14.0, 0.0], "v": v,"rndx":false},
        // Onto the robinsons arch steps
        {"p": [-6.15, -14.0, 0.0], "v": v, "l": 1,"rndx":false},
        //9
        {"p": [-7.79, -14.0, 0.0], "v": v, "l": 1},
        //10
        {"p": [-7.79, -11.64, 0.0], "v": v, "l": 1},  // mid robinsons arch steps
        {"p": [ -4.4, -11.64,0], "v": v, "l": 1},  // top robinsons arch steps
//        {"p": [ -5.04, -11.64,0], "v": v, "l": 1},
//        {"p": [-7.79, -5.04, 0.0], "v": v, "l": 1},
        {"p": [-3.0, -5.04, 0.0], "v": v, "l": 1},
        {"p": [0.0, -5.04, 0.0], "v": v, "l": 1},
        {"p": [3.0, -5.04, 0.0], "v": v, "l": 1},
        {"p": [5.0, -9.0, 0.0], "v": v, "l": 1},
        {"p": [5.0, -8.0, 0.0], "v": v, "l": 1},
        {"p": [5.39, -6.7, 0.0], "v": v, "l": 1},
        // this is court of gentiles passwageway entrance
        {"p": [5.85, -6.74, 0.0], "v": v, "l": 1,"rndy":false},
        {"p": [5.85, -6.76, 0.0], "v": v, "l": 0,"rndy":false},
//        {"p": [5.85, -6.81, 0.0], "v": v, "l": 1,"rndy":false},
 //       {"p": [5.85, -6.83, 0.0], "v": v, "l": 0,"rndy":false},
//        {"p": [5.85, -6.81, 0.0], "v": v, "l": 1,"rndy":false},
        // this is court of gentiles passwageway entrance
    //    {"p": [5.85, -7.04, 0.0], "v": v, "l": 0,"rndy":false},
        // this is court of gentiles passwageway entrance
        {"p": [5.85, -9.5, 0.0], "v": v, "l": 0},
       // {"p": [5.85, -9.5, 0.0], "v": v, "l": 0},
        {"p": [5.85, -11.36, 0.0], "v": v, "l": 0},
        {"p": [5.85, -13.26, 0.0], "v": v, "l": 0},
        // triple gate entrance
        //  {"action":"idle3","time":10},//11
      ]; // 21 length
      createWalkers(positions, numwalkers, walkerlist,true);

      var pointlist = [];
      // npcs over the southern wall baths
      var bathroofpoints = closestPersonAngle(createCrowdPoints(
          3.27,
          5.35,
          -14.4,
          -13.59,
          20,
          0.02,
          []));
      pointlist.add(bathroofpoints);
      var walkwaypoints = closestPersonAngle(createCrowdPoints(
          0.19,
          8.24,
          -15.4,
          -13.06,
          10,
          0.02,
          [
            [4.33, -14.05, 5.35 - 3.27 + 0.2, -13.59 - (-14.4) + 0.2],
            // exclude baths
            [7.62, -13.3, 0.6, 1.2],
            // exclude north east
          ]));
      pointlist.add(walkwaypoints);


      List<List> excludepilgrim=[];
      List<List> excludewesternwalkway=[];
      // For bethpage journey put a path through the crowd along the southern wall so can get past
      if (gamestart==GameStart.bethphage) {
        var essendiff = 0.4;
        var essenpoints = OPENWORLD.Math.interpolateByIncrement(
            citizenessenpath, essendiff / 2);
        for (var point in essenpoints) {
          if (point[1] > -17.5 && point[1] < -14.3)
            excludepilgrim.add([point[0], point[1], essendiff]);
          else if (point[1] > -13.39 && point[1] < -13.06)
            excludewesternwalkway.add([point[0], point[1], 0.4,0.15]);
        }
      }
      // on that steps towards the huldah gates need some people
      var westernwalkwaypoints = closestPersonAngle(createCrowdPoints(
          -5.4,
          -0.25,
          -13.39,
          -13.06-0.03,
          10,
          0.02,
          excludewesternwalkway));
      pointlist.add(westernwalkwaypoints);

      // Crowd at the northern end of the pilgrim road
      var pilgrimpoints = closestPersonAngle(createCrowdPoints(
          -6.16,
          -5.57,
          -17.5,
          -14.3,30,0.02, excludepilgrim ));
      pointlist.add(pilgrimpoints);
      // var walkwaypoints2=closestPersonAngle(createCrowdPoints(-5.39,0.1,-13.46,-13.1,5,0.02,[]));
      // pointlist.add(walkwaypoints2);
      for (var i = 0; i < pointlist.length; i++)
        for (var point in pointlist[i]) { // [...bathroofpoints,walkwaypoints]) {
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    OPENWORLD.Math.randPick(actorlist)),
                'p': [point[0], point[1]],
                //   'l': i==0?1:0,
                't': point[2], //OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                "callbackonvisible": (actor) {
                  if (gamestart==GameStart.bethphage)
                    setcancollide(actor,true);
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);

                },
                "callbackonhide": (actor) {
                  if (gamestart==GameStart.bethphage)
                    setcancollide(actor,false);
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },
                'action': 'idle3',
                'randomduration': 0.1,
                'startat': OPENWORLD.Math.random(),
                "lerpopacity": 1
              });

        }

      if (gamestart!=GameStart.womensgate) {  // Dont want oldfriend standing in the way for womensgate

        // This is an old friend near the western wall who says hello occasionally
        // He walks all the way down to the lowercity shop from the lowercity journey
        var oldfriend = await OPENWORLD.Actor.copyActor(
            citizen2, randomduration: 0.1, //OPENWORLD.Math.randPick(adultlist)
            action: "idle3"); //, action:"idlehold");
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            oldfriend, -6.04, -13.14 + 0.2, 0, 3,
            lerpopacity: 1); //-6.19,-14.65
        _hotload.add(oldfriend);

        OPENWORLD.Space.objTurn(oldfriend, 90);
        if (OPENWORLD.Math.random() < 0.05 ||
            (gamestart == GameStart.roam && widget.progress == 'westernwall')) {
          var hasseen = 0;
          OPENWORLD.BaseObject.setDistanceTrigger(
              oldfriend, dist: 0.3, event: (action) {
            if (action && hasseen < 1) {
              hasseen++;
              OPENWORLD.Space.faceObjectAlways(oldfriend, threeJs.camera);
//            OPENWORLD.Space.faceObjectLerp(oldfriend, threeJs.camera, 1.0);
              OPENWORLD.Mob.setSpeech(oldfriend,
                  ["Shalom.",
                    "Haven't seen you in ages.",
                    "I was just on my way to",
                    "buy the best figs in Jerusalem.",
                    "Theres a shop just down the road.",
                    "You should come"
                    // "We'll have to catch up.",
                    //  "Anyway, I better go."
                  ], z: 90,
                  width: 300,
                 // clearwhendone: true,
                  minwait: 4,
                  scale: 0.4,
                  randwait: 0,
                  //   delay:9
                  callbackonfinish: (actor) {
                    OPENWORLD.Space.removeFaceObjectAlways(actor);
                    OPENWORLD.Mob.moveTo(
                        actor,
                        [
                          [-5.91, -15.86, 0, 0.04],
                          [-6.09, -20.49, 0, 0.04] //5.89,-17.5, 0, 0.2]
                        ], action: "walk",
                        stopaction: "idle",
                        surfaceonly: true,
                        callbackonfinish: (actor) {
                          if (gamestart != GameStart.lowercity) {
                            OPENWORLD.Space.faceObjectLerp(
                                actor, Glob.fruitseller, 1);
                            var chat = [
                              {0: "Shalom. I'm back again."},
                              {0: "Can I have 5 of your figs?"},
                              {1: "There you go."},
                              {1: "I'll see you soon :)"},

                            ];
                            // have you look at your companion - would be nice

                            var citizenmeetchatterarr = createChat(chat);
                            var citizenmeetchatter = citizenmeetchatterarr[0];
                            var citizenmeet2chatter = citizenmeetchatterarr[1];

                            OPENWORLD.Mob.setSpeech(oldfriend,
                                citizenmeetchatter, z: 90,
                                width: 300,
                                clearwhendone: true,
                                minwait: 4,
                                scale: 0.4,
                                randwait: 0,
                                callbackonfinish: (actor) {
                                  var basketwickerfigs2 = basketwickerfigs
                                      .clone();
                                  basketwickerfigs2.visible=true;
                                  basketwickerfigs2.position.x = 3.0; //7.0;
                                  basketwickerfigs2.position.y = 3.0;
                                  basketwickerfigs2.position.z = 0.0; // -1.0;
                                  basketwickerfigs2.scale.setValues(
                                      5.0, 5.0, 5.0);
                                  OPENWORLD.Space.setTurnPitchRoll(
                                      basketwickerfigs2, -45, 90, 0);
                                  OPENWORLD.Actor.wield(
                                      actor, basketwickerfigs2, "Bip01_R_Hand");

                                  OPENWORLD.Space.faceObjectLerp(
                                      actor, threeJs.camera, 1, delay: 2);
                                  OPENWORLD.Mob.setSpeech(oldfriend,
                                      ["I'm going to enjoy these.",
                                       "I think i'll listen to the"
                                        "Rabbi over here for a while.",
                                          "He has hardly anyone listening"

                                      ], z: 90,
                                      width: 300,
                                      clearwhendone: true,
                                      minwait: 4,
                                      scale: 0.4,
                                      randwait: 0,
                                      callbackonfinish: (actor){
                                       // OPENWORLD.Space.objTurnLerp(oldfriend, 90, 1.0);
                                        OPENWORLD.Mob.moveTo(
                                            actor,
                                            [
                                              [-5.88, -20.53, 0, 0.04] //5.89,-17.5, 0, 0.2]
                                            ], action: "walk",
                                            stopaction: "idle",
                                            surfaceonly: true);

                                      },
                                      delay: 3);
                                });
                            OPENWORLD.Mob.setSpeech(Glob.fruitseller,
                                citizenmeet2chatter, z: 90,
                                width: 300,
                                clearwhendone: true,
                                minwait: 4,
                                scale: 0.4,
                                randwait: 0,
                                callbackonfinish: (actor) {
                                  OPENWORLD.Actor.playActionThen(
                                      actor, "push", "idle3",
                                      duration: 3);
                                });
                          }
                          //actor.visible=false;
                          // OPENWORLD.Space.removeObjFromHide(actor);

                        }
                    );
                    //  OPENWORLD.Space.objTurnLerp(oldfriend, 120, 1.0);
                  }
              );
            } else {

            }
          });
        }
      }


    }

    // For the western wall steps - up robinsons arch
    OPENWORLD.Portals.createPortal(
      -6.09 - 0.1,
      -13.94,
      0.04,
      1.1,
      level: 0,
      -6.37+0.1,
      -13.94,
      0.0,
     //      marker:_hotload,
      angleentry: 270,
      angleentrythresh:140,
      level2: 1,
      //   reverse:true,
      lerp: 1,
      adjacent: true,
    );

    OPENWORLD.Portals.createPortal(
      -6.25,
      -13.94,
      0.04,
      1.1,
      level: 1,
      -6.11 ,
      -13.94,
      0.0,
     // marker:_hotload,
      angleentry: 270-180,
      angleentrythresh:140,
      level2: 0,
      //   reverse:true,
      lerp: 1,
      adjacent: true,
    );
   /* OPENWORLD.Portals.createPortal(
        -6.3+0.1,
        -13.94,
        0.04,
        1,
        level: 1,
        -6,
        -13.94,
        0.0,
        level2: 0,
        adjacent: true,
           marker:_hotload,
        //   reverse:true,
        lerp: 1);*/

    // var posx=-5.56-0.03;
    // var posy=-11.69-0.03;

    if (OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {
      // This is for the shops along the westernwall
      var positions = [
        -12.38,
        -12.28,
        -12.16,
        -12.02,
        -11.9,
        -11.79,
        -11.67,
        -11.57,
        -11.42,
        -11.31,
        -11.20,
        -11.08,
        -10.97,
        -10.84,
        -10.7,
        -10.56,
        -10.42
      ];
      for (var j = 0; j < positions.length; j++) {
        var posx = -5.54 - 0.02;
        var posy = positions[j];
        var pick = OPENWORLD.Math.randInt(4);
        OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  manlist[j % manlist.length]),
              'p': [ posx, posy, -0.01],
              'l': -1,
              't': -90, // OPENWORLD.Math.random() * 360, //270,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'sittableidle',
              'randomduration': 0.1,
              //  'startat': OPENWORLD.Math.random(),
              "lerpopacity": 1,
              "callbackonvisible":(actor) {
                OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
              },
              "callbackonhide":(actor) {
                OPENWORLD.Actor.disableDistanceThrottle(actor);
              },

            });

        if (pick == 0) {
          // posx = -5.56 + 0.02;
          // posy = -11.69 - 0.06 + 0.18;
          /* var moneychanger2 = await OPENWORLD.Actor.copyActor(
            OPENWORLD.Math.randPick(manlist), action: 'sittableidle',
            randomduration: 0.1,
            startat: OPENWORLD.Math.random());
//    var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            moneychanger2, posx, posy, 0, 3, level: -1);
        _hotload.add(moneychanger2);
        OPENWORLD.Space.objTurn(moneychanger2, -90);*/
          /*OPENWORLD.Config
            .config['positions']['poolpositions'][1]['positions'].add(
            {
              'name': OPENWORLD.Config.getObjectName(
                  manlist[j % manlist.length]),
              'p': [ posx, posy, -0.01],
              'l': -1,
              't':-90,// OPENWORLD.Math.random() * 360, //270,
              // 'pitch': pitch,
              //   'roll': roll,
              'action': 'sittableidle',
              'randomduration': 0.1,
              //  'startat': OPENWORLD.Math.random(),
              "lerpopacity": 1
            });*/
          var tablelow2 = tablelow.clone();
          _hotload.add(tablelow2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              tablelow2, posx - 0.04, posy, 0, 1.5, level: -1);
          OPENWORLD.Space.objTurn(tablelow2, 0);
          tablelow2.scale.setValues(0.017, 0.017, 0.017 / 2);
          var money3 = money.clone();
          _hotload.add(money3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              money3, posx - 0.05, posy - 0.01, 0.03,
              // -3.55, -12.58, 0.026,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          var scales2 = scales.clone();
          _hotload.add(scales2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              scales2, posx - 0.055, posy + 0.01, 0.03,
              //-3.55+0.02, -12.58, 0.026,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(scales2, 90);
          var moneychest2 = moneychest.clone();
          _hotload.add(moneychest2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              moneychest2, posx + 0.04, posy - 0.02, 0,
              // -3.55-0.03, -12.63+0.02, 0,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(moneychest2, 90);
          //  instancedMoneychest.place(90,moneychangerposx - 0.03, moneychangerposy + 0.02, 0.0,level:1);
          var stool2 = stool.clone();
          _hotload.add(stool2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              stool2, posx, posy, 0, //-3.55, -12.63, 0,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(stool2, 90);
          // instancedTablelow.place(90, posx-0.01,posy, 0.0,level:-1, scale:THREE.Vector3(0.017/2, 0.017, 0.017));
        } else if (pick == 1) {
          // posx -= 0.02;
          // posy += 0.14;

          /* var doveseller = await OPENWORLD.Actor.copyActor(
            OPENWORLD.Math.randPick(manlist), action: 'sittableidle',
            randomduration: 0.1,
            startat: OPENWORLD.Math.random());
//    var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            doveseller, posx, posy, 0, 3, level: -1);
        _hotload.add(doveseller);
        OPENWORLD.Space.objTurn(doveseller, -90);*/

          var stool2 = stool.clone();
          _hotload.add(stool2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              stool2, posx, posy, 0, //-3.55, -12.63, 0,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(stool2, 90);

          var birdcagepigeon2 = birdcagepigeon.clone();
          _hotload.add(birdcagepigeon2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              birdcagepigeon2, posx - 0.05, posy - 0.02,
              0.03, //55,
              // -3.55, -12.58, 0.026,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          var birdcagedove2 = birdcagedoves.clone();
          _hotload.add(birdcagedove2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              birdcagedove2, posx - 0.055, posy + 0.02,
              0.03, //55,
              // -3.55, -12.58, 0.026,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);

          var basket2 = basket.clone();
          _hotload.add(basket2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              basket2, posx + 0.04, posy - 0.02, 0,
              // -3.55-0.03, -12.63+0.02, 0,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          basket2.scale.setValues(0.0015, 0.0015, 0.0015);
          var basket3 = basket.clone();
          _hotload.add(basket3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              basket3, posx + 0.04, posy + 0.02, 0,
              // -3.55-0.03, -12.63+0.02, 0,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          basket3.scale.setValues(0.001, 0.001, 0.001);
        } else if (pick == 2) {
          // posy += 0.12;

          /* var baker = await OPENWORLD.Actor.copyActor(
            OPENWORLD.Math.randPick(manlist), action: 'sittableidle',
            randomduration: 0.1,
            startat: OPENWORLD.Math.random());
//    var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            baker, posx, posy, 0, 3, level: -1);
        _hotload.add(baker);
        OPENWORLD.Space.objTurn(baker, -90);*/
          var tablelow4 = tablelow.clone();
          _hotload.add(tablelow4);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              tablelow4, posx - 0.04, posy, 0, 1.5, level: -1);
          OPENWORLD.Space.objTurn(tablelow4, 0);
          tablelow4.scale.setValues(0.017, 0.017, 0.017 / 2);

          _hotload.add(breadleavened);
          // hotloadAdd(firsthotload, false, rock);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              breadleavened, posx - 0.05, posy, 0.03, 2,
              level: -1); //-7.74, -28.00, 0.05, 2); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(breadleavened, 0);
          var breadleavened2 = breadleavened.clone();
          _hotload.add(breadleavened2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              breadleavened2, posx - 0.05, posy + 0.02, 0.03, 2,
              level: -1); //-7.74, -28.00 + 0.02, 0.05, 2); // 3.2,2.5, 0.0);
          var breadleavened3 = breadleavened.clone();
          _hotload.add(breadleavened3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              breadleavened3, -7.74 - 0.01, -28.03 + 0.02, 0.03,
              2, level: -1); // 3.2,2.5, 0.0);
          //for (var j = 0; j < 2; j++) {
          //  for (var i = 0; i < 4; i++) {
          var bread2 = breadunleaven.clone();
          bread2.scale.setValues(0.2, 0.3, 0.2);
          _hotload.add(bread2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              bread2, posx - 0.04, posy - 0.02, 0.03,
              //-7.74 + 0.01, -28.00 + 0.04 + j * 0.02, 0.05 + i * 0.001,
              2, level: -1); // 3.2,2.5, 0.0);
          //    OPENWORLD.Space.objTurn(bread, OPENWORLD.Math.randFloatSpread(100));
          //   }
          // }*/
          var breadleavened4 = breadleavened.clone();
          _hotload.add(breadleavened4);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              breadleavened4, posx - 0.055, posy + 0.01, 0.03,
              2, level: -1); // 3.2,2.5, 0.0);

          var stool3 = stool.clone();
          _hotload.add(stool3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              stool3, posx, posy, 0, //-3.55, -12.63, 0,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);
          OPENWORLD.Space.objTurn(stool3, 90);

          var sack7 = sack.clone();
          hotloadAdd(firsthotload, false, sack7);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              sack7, posx + 0.04, posy + 0.02, 0, 2, level: -1);

          sack7 = sack.clone();
          hotloadAdd(firsthotload, false, sack7);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              sack7, posx + 0.06, posy - 0.02, 0, 2, level: -1);
        } else if (pick == 3) {
          var tabletri3 = tabletri.clone();
          hotloadAdd(firsthotload, false, tabletri3);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              tabletri3, posx - 0.01 - 0.02, posy + 0.05 - 0.05, 0.0, 2,
              level: -1);
          var money2 = money.clone();
          hotloadAdd(firsthotload, false, money2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              money2, posx - 0.01 - 0.02, posy + 0.05 - 0.05, 0.038, 2,
              level: -1);
          OPENWORLD.Space.objTurn(money2, -90);
          /* var moneychanger = await OPENWORLD.Actor.copyActor(
            OPENWORLD.Math.randPick(manlist), action: "sittableidle",//idle3",
            randomduration: 0.1,
            startat: OPENWORLD.Math.random());
//    var citizen4ii=await OPENWORLD.Actor.copyActor(citizen4,action:"handsouttogether",randomduration: 0.1,startat:OPENWORLD.Math.random());
        OPENWORLD.Space.worldToLocalSurfaceObjHide(
            moneychanger, posx + 0.04-0.02, posy+ 0.05- 0.05, 0, 3, level:-1);
        _hotload.add(moneychanger);
        OPENWORLD.Space.objTurn(moneychanger, -90);*/
          var moneychest2 = moneychest.clone();
          _hotload.add(moneychest2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              moneychest2, posx + 0.04 - 0.02, posy + 0.02 - 0.05, 0,
              // -3.55-0.03, -12.63+0.02, 0,
              1.5,
              level: -1); //1.86, 0.62,0.0,4);// -0.38+0.7, 1.31, 0.0, 4); // 3.2,2.5, 0.0);

        }

        var spread = 0.03;
        var numbuyers = OPENWORLD.Math.randInt(3);
        if (numbuyers == 1) {
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    OPENWORLD.Math.randPick(actorlist)),
                'p': [
                  posx - 0.1 + OPENWORLD.Math.randFloatSpread(spread),
                  posy + OPENWORLD.Math.randFloatSpread(spread),
                  0
                ],
                //  'l': -1,
                't': 90, // OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'idle3',
                'randomduration': 0.1,
                //  'startat': OPENWORLD.Math.random(),
                //  'label': 'courtwomen',
                "lerpopacity": 1,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },

              });
        } else if (numbuyers == 2) {
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    OPENWORLD.Math.randPick(actorlist)),
                'p': [
                  posx - 0.1 + OPENWORLD.Math.randFloatSpread(spread),
                  posy - 0.02 + OPENWORLD.Math.randFloatSpread(spread),
                  0
                ],
                //  'l': -1,
                't': 90, // OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'idle3',
                'randomduration': 0.1,
                //  'startat': OPENWORLD.Math.random(),
                //  'label': 'courtwomen',
                "lerpopacity": 1,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },

              });


          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    OPENWORLD.Math.randPick(actorlist)),
                'p': [
                  posx - 0.1 + OPENWORLD.Math.randFloatSpread(spread),
                  posy + 0.02 + OPENWORLD.Math.randFloatSpread(spread),
                  0
                ],
                //  'l': -1,
                't': 90, // OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'idle3',
                'randomduration': 0.1,
                //  'startat': OPENWORLD.Math.random(),
                "lerpopacity": 1,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                },

              });
        }
      }

      // Some extra herb sellers next to wall
      var herbposs = [
        [-5.67,-9.96, 270],
        [-5.67, -8.46, 270],
      ];
      for (var pos in herbposs) {
        createHerbSeller(pos[0], pos[1],pos[2]);
      }

      var birdsellers = [
        [-5.69, -9.6, 270],
        [-5.67, -7.76, 270],
      ];
      for (var pos in birdsellers) {
        createDoveSeller(pos[0],pos[1],pos[2]);
      }

      var westernwalldiff = 0.4;
      var westernwallpath = OPENWORLD.Math.interpolateByIncrement(
          friendpathrobinsons, westernwalldiff);

      var westernwallcrowds = [
        [-7.18, -5.79, -13.33, -12.2, 30,],
        [ -6.31, -5.79, -12.1, -11.28, 30,],
        [-7.18, -5.79, -11.18, -9, 30,], // Opposite robinson arch shops
        [ -6.51, -5.79, -9.20, -3.45, 20,], // South of wilsons arch
        [ -6.1, -5.5, -2.1, 1.4, 20,] // North of wilsons arch
 //       [ -6.1, -5.5, -2.1, 1.6, 20,] // North of wilsons arch
        //minx  maxx   miny  maxy
      ];
      for (var crowd in westernwallcrowds) {
        var minx = crowd[0],
            maxx = crowd[1],
            miny = crowd[2],
            maxy = crowd[3],
            density = crowd[4];
        List exclude = [];
        if (gamestart == GameStart.womensgate) {
          // Create a path through the crowd so you can walk through it
          for (var point in westernwallpath) {
            if (point[0] > minx - westernwalldiff &&
                point[0] < maxx + westernwalldiff &&
                point[1] > miny - westernwalldiff &&
                point[1] < maxy + westernwalldiff) {
              exclude.add([point[0], point[1], 0.25, westernwalldiff]);
            }
          }
        }
        var westernwallpoints = closestPersonAngle(createCrowdPoints(
            minx,
            maxx,
            miny,
            maxy,
            density,
            0.02,
            exclude,
            clusterlevel: gamestart != GameStart.womensgate ? 0.6 : 0.3));
        for (var point in westernwallpoints)
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    OPENWORLD.Math.randPick(actorlist)),
                'p': [point[0], point[1]],
                //   'l': i==0?1:0,
                't': point[2], //OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'idle3',
                'randomduration': 0.1,
                'startat': OPENWORLD.Math.random(),
                //  'label': 'courtwomen',
                "lerpopacity": 1 ,
                "callbackonvisible":(actor) {
                  OPENWORLD.Actor.enableDistanceThrottle(actor, minDistance: 0.5, skipFrames: 6);
                },
                "callbackonhide":(actor) {
                  OPENWORLD.Actor.disableDistanceThrottle(actor);
                }

              });
      }
      // Create a set of people along the fishgate road - two people talking to eachother
      for (var pos in westernwallpath) {
        if (pos[1]>3.8&&pos[1]<27.6) {
          if (OPENWORLD.Math.random()<0.1) {
            var east=OPENWORLD.Math.random()<0.5;


            var distoffset=0.28;
            OPENWORLD.Config
                .config['positions']['poolpositions'][1]['positions'].add(
                {
                  'name': OPENWORLD.Config.getObjectName(
                      OPENWORLD.Math.randPick(actorlist)),
                  'p': [pos[0]+(east?distoffset:-distoffset), pos[1]],
                  //   'l': i==0?1:0,
                  't':0,//OPENWORLD.Math.random() * 360, //270,
                  // 'pitch': pitch,
                  //   'roll': roll,
                  'action': "idle3",//OPENWORLD.Math.randPick(['idle3',"squatwork","stoopidle","handships"]),
                  'randomduration': 0.1,
                  'startat': OPENWORLD.Math.random(),
                  //  'label': 'courtwomen',
                  "lerpopacity": 1,
                  "callbackonvisible": (actor) {
                    OPENWORLD.Actor.enableDistanceThrottle(
                        actor, minDistance: 0.5, skipFrames: 6);
                  },
                  "callbackonhide": (actor) {
                    OPENWORLD.Actor.disableDistanceThrottle(actor);
                  }
                });
            OPENWORLD.Config
                .config['positions']['poolpositions'][1]['positions'].add(
                {
                  'name': OPENWORLD.Config.getObjectName(
                      OPENWORLD.Math.randPick(actorlist)),
                  'p': [pos[0]+(east?distoffset:-distoffset), pos[1]+0.1],
                  //   'l': i==0?1:0,
                  't':180,//OPENWORLD.Math.random() * 360, //270,
                  // 'pitch': pitch,
                  //   'roll': roll,
                  'action': "idle3",//OPENWORLD.Math.randPick(['idle3',"squatwork","stoopidle","handships"]),
                  'randomduration': 0.1,
                  'startat': OPENWORLD.Math.random(),

                  "lerpopacity": 1,
                  "callbackonvisible": (actor) {
                    OPENWORLD.Actor.enableDistanceThrottle(
                        actor, minDistance: 0.5, skipFrames: 6);
                  },
                  "callbackonhide": (actor) {
                    OPENWORLD.Actor.disableDistanceThrottle(actor);
                  }
                });
          }


        }

      }
    }


    // This is the walks along wilsons arch, through court of gentiles and court of women eastern entrance
    var v = 0.03;
    if (OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {
      List<Map> wilsonsarchpositions = [
        {"p": [-14.5, -4.46, 0.0], "v": v, "l": 1},
        {"p": [-11.83, -3.93, 0.0], "v": v, "l": 1},
        {"p": [-8.84, -3.2, 0.0], "v": v, "l": 1},
        {"p": [-5.38, -2.48, 0.0], "v": v, "l": 1},
        {"p": [-2.22, -2.56, 0.0], "v": v, "l": 1},
        {"p": [1.0, -2.87, 0.0], "v": v, "l": 1},
        {"p": [4.0, -2.87, 0.0], "v": v, "l": 1},
        {"p": [7.0, -2.87, 0.0], "v": v, "l": 1},
        {"p": [9.9, -2.87, 0.0], "v": v, "l": 1},
        {"p": [9.9, 0.36, 0.0], "v": v, "l": 1},
        {"p": [6.97, 0.36, 0.0], "v": v, "l": 1},
        {"p": [5.81, 0.36, 0.0], "v": v, "l": 1},
        //  {"action":"idle3","time":10},//11
      ]; // 21 length
      createWalkers(wilsonsarchpositions, 40, walkerlist, false);
    }

    // Looks like grass near wilsons arch
    var grassiii = Vegetation();
    maxx = -5.9 + 0.1; miny = -2.1; minx = -10.12; maxy = 2.0;//6;//12.26;
    var boundarywidth3 = maxx - minx;
    var boundarylength3 = maxy - miny;

    var grassposx2 = (maxx + minx) / 2;
    var grassposy2 = (maxy + miny) / 2;
    var diff = 0.4;
    var pointscitizenpath = OPENWORLD.Math.interpolateByIncrement(
        citizenpath, diff);

    List<List<double>> excludeSquares = [];
    for (var point in pointscitizenpath) {
      if (point[1] < maxy && point[1] >
          miny) //44&&point[0] >= minx && point[0] <= maxx && point[1] >= miny &&
        //     point[1] <= maxy) {
        // if (i==0)
        //   print("point:"+point.toString());
        excludeSquares.add(
            [
              point[0],
              point[1],
              0.3,
              diff,
            ]);
      // } // bethspagepos),  diff, 0.4]);

    }
    //print("uuu"+grassposx2.toString()+" "+grassposy2.toString());
    var grassgroupii = await grassiii.createGrass(threeJs.camera,
        grassShadow: 0.2,
        boundaryWidth: boundarywidth3,
        //3
        boundaryLength: boundarylength3,
        edgeFalloff: 0,
        worldposx: grassposx2,
        worldposy: grassposy2,
        layerFadeAngle: 0.25,
        seed: 9999,
        excludeSquares: excludeSquares,
        surfaceTexture: SurfaceTextureSpec(
            asset: 'assets/models/temple/detailmap.jpg',
            blendStrength: 0.25,
            tilingScale: 0.3, // texture repeats every 12 world metres
            edgeFade: 0.02
          //edgeFade: 0.25, // fades over the outer 25% of the boundary
        ),
        plants: [
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
            spriteAsset: 'assets/shaders/grass.png',
            count: 10000,
            width: 0.2 / 2,
            height: 0.3,
            billboard: 1,
            flipProbability: 0.5,
            //     exclusionOffset: 0.01,
            //    renderMode: PlantRenderMode.sprite,
          ),

        ],
        showHeightGrid: false,
        heightGridDivisions: 10,
        heightGridColor: 0xff6a00,
        heightGridOffset: 0.0,
        planeSize: 50);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        grassgroupii, grassposx2, grassposy2, 0.0,
        15);
    hotloadAdd(firsthotload, false, grassgroupii);
    OPENWORLD.Updateables.add(grassiii);

    // bethesda pool
    roomBethesda = OPENWORLD.Room.createRoom(7.93, 17.29,
        soundpath: OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/pool.mp3":"sounds/courtyard.mp3",   volume:0.01,//roomspeed: 1.0 / 20 ,
        exitroom: roomTerrain); //THREE.Object3D();

    roomBethesda.extra['guide'] = [
      "You are at the pool of Bethesda.",
    ];
    OPENWORLD.Room.setIndoors(roomBethesda,true);
    //OPENWORLD.Room.setAutoIndoors(roomLowercity, true);
    _hotload.add(roomBethesda);

    OPENWORLD.Room.setDistanceTrigger(roomBethesda,
        maxy: 20.0+0.5, miny: 14.64-0.5, minx:6.8-0.5, maxx: 8.98+0.5, event:(action) {   //2.8
      if (action) {
        if (mounted)
          setState(() {
            roomname = "Pool of Bethesda";
          });
      } else {
          if (mounted)
            setState(() {
              roomname = "";
            });
      }
    });
    // columns on eastern and westrn side of the pool
    for (var i = 0; i < 36; i++) {
      instancedColumnsBethesda.place(-90, 6.82, 14.77 + i * 0.15, 0.0,
          scale: THREE.Vector3(0.4, 0.4, 0.4));
      instancedColumnsBethesda.place(-90, 8.94, 14.77 + i * 0.15, 0.0,
          scale: THREE.Vector3(0.4, 0.4, 0.4));
      // instancedColumnsbethesda.place(-90,  -9.6- i * 0.15, -50.8+0.2+0.05, 0.0,scale:THREE.Vector3(0.4,0.4,0.4));

    }

    // bethesda obstacles
    // South pool so cannot go too far in
    maxx=8.71; miny=14.68; minx=7.18-0.01; maxy=16.84+0.02;
//    maxx=8.71; miny=14.68; minx=7.12; maxy=16.84;
    OPENWORLD.Obstacles.createObstacle((maxx+minx)/2, (maxy+miny)/2,maxx-minx,maxy-miny, callback: (obstacle) {
      var worldpos = OPENWORLD.You.getWorldPos();
      var hitdir=obstacle.hitDirection(worldpos.x,worldpos.y);
      print("hit south pool"+hitdir.toString());
      if (hitdir==270)
        playSplash(volume:0.5);
    },
        callbacknextwait: 1
    );//,marker:_hotload);

    // North pool entirely
    maxx=8.71; miny=17.66; minx=6.97; maxy=20.0;
    OPENWORLD.Obstacles.createObstacle((maxx+minx)/2, (maxy+miny)/2,maxx-minx,maxy-miny);//,marker:_hotload);

    // columns on the northern, center and southern side of pool
    for (var i = 0; i < 15; i++) {
      instancedColumnsBethesda.place(-90, 6.82 + i * 0.15, 14.77 - 0.15, 0.0,
          scale: THREE.Vector3(0.4, 0.4, 0.4));
      instancedColumnsBethesda.place(-90, 6.82 + i * 0.15, 20.19, 0.0,
          scale: THREE.Vector3(0.4, 0.4, 0.4));
      if (i != 0 && i != 14)
        instancedColumnsBethesda.place(-90, 6.82 + i * 0.15, 17.33, 0.0,
            scale: THREE.Vector3(0.4, 0.4, 0.4));
    }



    final waterGeometryii = THREE.PlaneGeometry(20.0, 20.0);
    var waterbethesda = Water(waterGeometryii, WaterOptions(
      color: 0xbbddff,
      //a08a73,//ffffff,//a08a73,//params['color'],
      scale: 4 / 32.0,
      //80,//4.0/scale,//params['scale'],
      reflectivity: 0.5,
      // clipBias: 0.5,
      flowDirection: THREE.Vector2(0.05, 0.05),
      //1.0/scale,1.0/scale),// params['flowX'], params['flowY'] ),
      textureWidth: 128,
      //256,
      //(1024/scale).round(),
      textureHeight: 128, //256, // (1024/scale).round(),
    ));

    waterbethesda!.scale.setValues(0.1, 0.3, 1.0); // 1.7/20.0);

    OPENWORLD.Space.setTurnPitchRoll(waterbethesda!, 0, 0, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
      //wateri, -10,-47.5,0.0, 3); //7.7, 1.0, 0.05);
        waterbethesda!, 7.85, 17.32, -0.1, // 4.17, -15, 0.05,
        5, lerpopacity: 1.0); //-9.9, -47.5, 0.063, 2.5); //7.7, 1.0, 0.05);
    hotloadAdd(firsthotload, false, waterbethesda!);
    waterbethesda!.reflectionUpdateInterval = 3;
    threeJs.scene.traverse((obj) {
      //   if ( obj.name!='surfaceaerialshadow') {
      //obj!=instancedColumnsbethesda&&
      if (!instancedColumnsBethesda.parts.contains(obj) && obj is THREE.Mesh &&
          obj.name != 'bethedaroofcastshadow' &&
          obj.name != 'bethedasurfaceshadow' &&
          obj.name != 'surfaceaerialshadow' && obj.name != 'skymesh' &&
          obj.name != 'clouds') {
        //  wateri.excludeFromReflection.add(obj);
        // wateri) {
        final pos = THREE.Vector3();
        obj.getWorldPosition(pos);

        // Get the water's world position
        final waterPos = THREE.Vector3();
        waterbethesda!.getWorldPosition(waterPos);

        final dx = pos.x - waterPos.x;
        final dz = pos.z - waterPos.z;
        final distSq = dx * dx + dz * dz;

        // Exclude anything more than e.g. 8 world units from the pool
        if (distSq > 3 * 3) {
          waterbethesda!.excludeFromReflection.add(obj);
        }
      }
    });
    waterlist.add(waterbethesda);

    if (OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {
        // bathers in the pool of bathseda -healing so in a while
        var bathermikvehpos = [
          [7.2 - 0.05, 14.84, citizen33], //5.04, citizen33],
          [7.2 - 0.05, 15.06, citizen32], //5.04, citizen33],
          [7.2 - 0.05, 16.4, citizenf3], //5.5, citizenf3],
          [7.2 - 0.05, 16.68, citizenf32], //06, citizenf32]
        ];
        for (var pos in bathermikvehpos) {
          var bather = await OPENWORLD.Actor.copyActor(
              pos[2], action: "idle3", randomduration: 0.1);
          // setActorSize(citizenoldwoman2);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              bather, pos[0], pos[1], 0,
              4,
              lerpopacity: 1.0); //0.71,0,3);//2.89, 1.06,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
          hotloadAdd(firsthotload, false, bather);
          OPENWORLD.Space.objTurn(bather, 90);

          // bather.extra['bather']=true;
          //   OPENWORLD.Mob.setName(bather,"bather"+OPENWORLD.Config.getObjectName(pos[2]));
          // Put them in loincloth
          if (manlist.contains(pos[2])) {
            OPENWORLD.BaseObject.setVisible(
                bather, false, groupname: "citizen_3"); // no pants
            OPENWORLD.BaseObject.setVisible(
                bather, false, groupname: "citizen_4"); // no clothes
          }

          if (womanlist.contains(pos[2])) {
            OPENWORLD.BaseObject.setVisible(
                bather, false, groupname: "citizen_1"); // no shoes
            OPENWORLD.BaseObject.setVisible(
                bather, false, groupname: "citizen_2"); // no clothes
          }
          var clothespileii = clothespile.clone();
          _hotload.add(clothespileii);
          OPENWORLD.Space.worldToLocalSurfaceObj(
              clothespileii, pos[0]-0.1, pos[1], 0);
          //OPENWORLD.Space.worldToLocalSurfaceObjHide(
          //  clothespileii, batherposx + 0.1, batherposy - 0.1 - i * 0.07, 0, 2);
          // OPENWORLD.Space.setTurnPitchRoll(robes2iii, 0,0,0);

          OPENWORLD.Space.objTurn(clothespileii, OPENWORLD.Math.random() * 360);
          OPENWORLD.BaseObject.setDistanceTrigger(
              bather, dist: 4, event: (action) {
            if (action) {
              OPENWORLD.Actor.playActionsLoop(bather,
                bathingactions,
                randomaction: true,
                //  fadein:1.0
                //durations: [1,1,10],fadein:0,fadeout:2
              );
            } else {

            }
          });
        }

        // Bathers who immerse quickly
        var batherimmersepos = [
          [7.2 - 0.05-0.1,15.26, citizen3],
          [7.2 - 0.05-0.1, 16.2, citizenf33],
        ];

        for (var pos in batherimmersepos) {
          var bather = await OPENWORLD.Actor.copyActor(
              pos[2], action: "idle3", randomduration: 0.1);
          // setActorSize(citizenoldwoman2);
          var posx = pos[0];//7.2 - 0.05 - 0.1;
          var posy =pos[1];// 15.26;
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              bather, posx, posy, 0, 4,
              lerpopacity: 1.0); //0.71,0,3);//2.89, 1.06,0,3);// 1.25, 4.22, 0.0, 3); //3.42);
          hotloadAdd(firsthotload, false, bather);
          bather.extra['isman'] = manlist.contains(pos[2]);
          OPENWORLD.Space.objTurn(bather, 90);
          List<Map> actions = [
            {"p": [posx, posy, 0], "v": 0.02},
            //   {"p":[posx+0.1,posy,0],"v":0.02},
            {"action": "armsup", "time": 1.0,},
            {"action": "hitup", "time": 1.0,},
            {"action": "armsup", "time": 1.0,},
            {"action": "hitup", "time": 1.0, 'callback': (actor) {
              if (actor.extra['isman']) {
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

              // clothespileii.visible = true; // show the clothes on the ground
            },
            },
            {"p": [posx + 0.1, posy, 0], "v": 0.02},

          ];
          for (var j = 0; j < 10; j++) {
            Map action = {
              "action": bathingactions[j % bathingactions.length]
            };
            //  if (j % batheractionlist.length == 0)
            //    action['t'] = OPENWORLD.Math.randFloatSpread(40);
            actions.add(action);
          }
          actions.add({"p": [posx, posy, 0], "v": 0.02});
          actions.add({"action": "armsup", "time": 1.0,});
          actions.add({"action": "hitup", "time": 1.0, 'callback': (actor) {
            if (actor.extra['gender'] == 0) {
              // print("bathers clothes off");
              OPENWORLD.BaseObject.setVisible(
                  actor, true, groupname: "citizen_3"); // no pants
              OPENWORLD.BaseObject.setVisible(
                  actor, true, groupname: "citizen_4"); // no clothes
            } else {
              OPENWORLD.BaseObject.setVisible(
                  actor, true, groupname: "citizen_1"); // no shoes
              OPENWORLD.BaseObject.setVisible(
                  actor, true, groupname: "citizen_2"); // no clothes
            }
          }});
          actions.add({"action": "idle3", "time": 50.0, "t": 90});

          OPENWORLD.Mob.moveToLoop(
            bather,
            actions,
            //index:k==0?0:5,
            surfaceonly: true,
            hidedist: 3,
            // looptype: OPENWORLD.Mob.LoopTypeStop,
            action: "walk",

          );
        }


        // People walking around the pool
        var bathsedapathlist = [
          {"p": [6.9, 20.05, 0], "v": v},
          {"p": [8.88, 20.05, 0], "v": v},
          {"p": [8.88, 17.29, 0], "v": v},
          {"p": [6.9, 17.29, 0], "v": v},
          {"p": [6.9, 14.65, 0], "v": v},
          {"p": [8.88, 14.65, 0], "v": v},
          {"p": [8.88, 17.29, 0], "v": v},
          {"p": [8.88, 20.05, 0], "v": v},
        ];

        for (var j = 0; j < 10; j++) {
          var index = OPENWORLD.Math.randInt(bathsedapathlist.length-1);
        //  print("indexx "+index.toString());
          // So that dont have two walkers on top of eachother
          Map map = bathsedapathlist[index];
          Map prevmap;
          if (index>0)
            prevmap=bathsedapathlist[index-1];
          else
            prevmap=bathsedapathlist[bathsedapathlist.length-1];
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
                't': 0,
                //angle,
                //180,
                //   't': OPENWORLD.Math.getAngleBetweenPoints(THREE.Vector3(positions[index]['p'][0].toDouble(),positions[index]['p'][1].toDouble(),0.0),
                //      THREE.Vector3(positions[lastindex]['p'][0].toDouble(),positions[lastindex]['p'][1].toDouble(),0.0)), //180,
                'action': "idle",
                'randomduration': 0.1,
                "lerpopacity": 1,
                "label": index,
                //"labelstartpos": startpos,
               // "labeltest":"test",
                "callbackonvisible": (actor) {
                  var positionjson = OPENWORLD.Config.getPositionForObject(actor);
              //    print("positionjson"+positionjson.toString());
                  OPENWORLD.Space.resetRot(actor);

                  //var worldpos=OPENWORLD.Space.localToWorldObj(actor);
                  //  print("callbackonvis"+positionjson!['label'].toString()+" "+worldpos.toString()+" "+newpositions.toString());
                  //    OPENWORLD.Space.objTurn(actor, positionjson!['labelangle']);
                  var ind=positionjson!['label'];
                 // print('index beth'+ind.toString()+" "+bathsedapathlist.length.toString());
                  var bathsedapathlistcopy=bathsedapathlist.toList();
                  bathsedapathlistcopy.insert(ind,{"p":[positionjson['p'][0],positionjson['p'][1],0],"v":0.02});
                  OPENWORLD.Mob.moveToLoop(
                    actor,
                    bathsedapathlistcopy,
                    index: ind,
                    action: "walk",
                    //   facenow:true,
                    //  looptype: OPENWORLD.Mob.LoopTypeReverseLoop, //.LoopTypeStop,
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
                  // OPENWORLD.Actor.removeObjectFromPlayActionsLoop(actor);
                }
              });
        }
        // -0.5 is used so that dont have men standing around womens section and women standing around mens sections
        var poolsouthminx=6.98-0.7, poolsouthminy=14.72, poolsouthmaxx=8.86, poolsouthmaxy=16.84+0.2;
        var poolnorthminx=6.98, poolnorthminy=17.66, poolnorthmaxx=8.86, poolnorthmaxy=20.08;
        List<dynamic> exclude= [
          [(poolsouthmaxx+poolsouthminx)/2,(poolsouthmaxy+poolsouthminy)/2,poolsouthmaxx-poolsouthminx,poolsouthmaxy-poolsouthminy],// 7.88, 15.77, 2.0, 2.0],
          //  [7.88, 18.97, 2.0, 2.0]
          [(poolnorthmaxx+poolnorthminx)/2,(poolnorthmaxy+poolnorthminy)/2,poolnorthmaxx-poolnorthminx,poolnorthmaxy-poolnorthminy],// 7.88, 15.77, 2.0, 2.0],
        ];

        if (gamestart!=GameStart.womensgate) {
          // Put in some people chatting
          if (OPENWORLD.Math.random() < 0.2 ||
              (gamestart == GameStart.roam && widget.progress == 'bethesda')) {
            createNeightboursChatting(
                6.75, 16.54, 180, 6.74, 16.41 + 0.02, 'women');
            exclude.add([6.75, 16.5, 0.1, 0.1]);
          }
          if (OPENWORLD.Math.random() < 0.2 ||
              (gamestart == GameStart.roam && widget.progress == 'bethesda')) {
            createNeightboursChatting(
                6.75, 17.89, 180, 6.74, 17.89 - 0.1, 'men');
            exclude.add([6.75, 17.89 - 0.05, 0.1, 0.1]);
          }
        }

        // Put crowd of people standing around the pool
        var bethesdapoints = closestPersonAngle(createCrowdPoints(
            6.42,
            9.26,
            14.09,
            20.64,
            5,
            0.02,
           exclude));

        for (var point in bethesdapoints) {
          OPENWORLD.Config
              .config['positions']['poolpositions'][1]['positions'].add(
              {
                'name': OPENWORLD.Config.getObjectName(
                    OPENWORLD.Math.randPick(actorlist)),
                'p': [point[0], point[1]],
                //   'l': i==0?1:0,
                't': point[2], //OPENWORLD.Math.random() * 360, //270,
                // 'pitch': pitch,
                //   'roll': roll,
                'action': 'idle3',
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
    }


    // Vegetation for bethesda pool
    maxx=9.7; miny=8.47; minx= 1.5; maxy=28;//21;// 32;//21;//11.3;
    boundarywidth3=maxx-minx;
    boundarylength3=maxy-miny;

    grassposx2=(maxx+minx)/2;
    grassposy2=(maxy+miny)/2;

    excludeSquares = [
      [7.94,17.44,3.4,7],
      [8.98,8.78,6,3],
      [4.28,22.41,1.4,1.4]
    ];

    diff=0.4;
    var points=OPENWORLD.Math.interpolateByIncrement([
      [-6.0,32],
      [2.49,23.31],
      [5.7,19.0],
      [6.0, 17.5]
    ], diff);
    for (var point in points) {
      if (point[1]<maxy+diff&&point[1]>miny-diff) //44&&point[0] >= minx && point[0] <= maxx && point[1] >= miny &&
        //     point[1] <= maxy) {
        // if (i==0)
        //   print("point:"+point.toString());
        excludeSquares.add(
            [
              point[0],
              point[1],
              diff,
              diff,
            ]);
    }
   // var diff = 0.6;
   /* for (var y = miny; y < maxy+0.5; y += diff) {
      var xdiff=0.5;
      excludeSquares.add(
          [OPENWORLD.Math.interpolateX(y, friendpath), y, xdiff, diff]);
    }*/

    grassgroupii = await grassiii.createGrass(threeJs.camera,
        grassShadow: 0.2,
        boundaryWidth: boundarywidth3,
        boundaryLength: boundarylength3,
        edgeFalloff: 0,
        worldposx: grassposx2,
        worldposy: grassposy2,
        layerFadeAngle: 0.25,
        seed: 9999,
        excludeSquares: excludeSquares,
        surfaceTexture: SurfaceTextureSpec(
            asset: 'assets/models/temple/detailmap.jpg',
            blendStrength: 0.25,
            tilingScale: 0.3, // texture repeats every 12 world metres
            edgeFade: 0.02
          //edgeFade: 0.25, // fades over the outer 25% of the boundary
        ),
        plants:[
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
              spriteAsset: 'assets/models/temple/olive.png',
              count: 150,
              //350,
              width: 1.3  ,
              height: 1.3,
              billboard: 3,
              heightVariation: 0.2,
              widthVariation: 0.2,
              layers: 2,
              flipProbability: 0.5,
              //   scrolling: false,
              planeSize: 200,
              //edgeFadeWidth: 2,
              exclusionOffset: 0.1
            //   renderMode: PlantRenderMode.sprite,
          ),
          PlantSpec(
              spriteAsset: 'assets/models/temple/myrtle.png',
              //shaders/grass2.png',
              count: 100,
              width: 0.4 ,
              height: 0.6 ,
              billboard: 3,
              heightVariation: 0.3,
              widthVariation: 0.3,
              layers: 2,
              flipProbability: 0.5,
              planeSize: 100,
              exclusionOffset: 0.1
            //   renderMode: PlantRenderMode.sprite,
          ),
         /* PlantSpec(
            spriteAsset: 'assets/models/temple/cyprus.png',
            //shaders/grass2.png',
            count: 30,
            width: 3 ,
            height: 10,
            billboard: 1,
            heightVariation: 0.2,
            widthVariation: 0.2,
            layers: 2,
            flipProbability: 0.5,
            //  scrolling: false,
            //planeSize: 200,
            exclusionOffset: 0.5,
             edgeFadeWidth: 5,
            pitchVariation: 0.0, //17
          ),*/
        ],
        showHeightGrid: false,
        heightGridDivisions: 10,
        heightGridColor: 0xff6a00,
        heightGridOffset: 0.0,
        planeSize: 50);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        grassgroupii, grassposx2, grassposy2, 0.0,
        15);
    hotloadAdd(firsthotload, false, grassgroupii);
    OPENWORLD.Updateables.add(grassiii);


    // Pool of israel
    maxx=11.03; miny=7.92; minx=9.64; maxy=6.62;
    OPENWORLD.Obstacles.createObstacle((maxx+minx)/2, (maxy+miny)/2,maxx-minx,maxy-miny);//,marker:_hotload);

    var water = WaterSimple();
    THREE.Mesh waterisrael = water.createWater();
    //var waterisrael = water1.clone(true);
    _hotload.add(waterisrael);
    waterisrael.material?.emissive=THREE.Color.fromHex32(0x000008);//a08a73);//000000);//a08a73);//ffffff);
    waterisrael.material?.opacity=0.9;//75;//ffffff);
    // OPENWORLD.Space.setTurnPitchRoll(water4, -16, 0, 90);
    //  water4.rotation.x = math.pi * - 0.5;
    waterisrael.scale.setValues(4.0, 1.0, 1.5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        waterisrael, 8.78,8.78,0.2, 7); //7.7, 1.0, 0.05);
    OPENWORLD.Updateables.add(water);
    var poolsound = OPENWORLD.Sound.getAudioPlayer();
    OPENWORLD.BaseObject.setDistanceTrigger(waterisrael,
        dist: 2, event:(action) {
          if (action) {
            print("pool israel play");
            OPENWORLD.Sound.play(sound:poolsound,path: 'sounds/pool.mp3',loop:true,
                volume: 0.8,fadein: 1.0);
          } else {
            print("pool israel fade");
            OPENWORLD.Sound.fadeOut(poolsound, 1.0);
          }
        });


    // Stable near bethesda
    roomStablebethesda = OPENWORLD.Room.createRoom(4.3,22.4,
          roomspeed: 1.0 / 20 , randomsoundgap:10,randomsoundpaths: ['sounds/donkey.mp3','sounds/donkey2.mp3','sounds/goat.mp3','sounds/goat2.mp3','sounds/goat3.mp3','sounds/bah.mp3'],
        exitroom: roomTerrain); //THREE.Object3D();


    //OPENWORLD.Room.setIndoors(roomStablebethesda,true);
    //OPENWORLD.Room.setAutoIndoors(roomLowercity, true);
    _hotload.add(roomStablebethesda);

    OPENWORLD.Room.setDistanceTrigger(roomStablebethesda,
        maxy: 23, miny: 21.93, minx:3.96, maxx: 5);

    var donkey4 = await OPENWORLD.Actor.copyActor(
        donkeypack); //,action:"walk",resetposition: true);//,action:"idle3");
    donkey4.scale.setValues(0.04, 0.04,
        0.04); //25, 0.0025, 0.0025);
    _hotload.add(donkey4);
    OPENWORLD.BaseObject.setVisible(
        donkey4, true, groupname: "horse001_1"); // show rope
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        donkey4,  4.29, 22.12, 0.01, 3,
        lerpopacity: 1.0); //, normalize2world:true);
    OPENWORLD.Space.objTurn(donkey4, 90 + 20-40, normalize2world: true);
    var hay2 = hay.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay2,  4.23, 22.12, 0.01, 2); // 3.2,2.5, 0.0);
    _hotload.add(hay2);
    hay2.scale.setValues(0.04, 0.04, 0.04);
    var manger6 = manger.clone();
    _hotload.add(manger6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        manger6, 4.27, 22.06, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(manger6, 90-40);

    var donkey5 = await OPENWORLD.Actor.copyActor(
        donkey4); //,action:"walk",resetposition: true);//,action:"idle3");
    _hotload.add(donkey5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        donkey5, 4.25, 22.66, 0.01, 3,
        lerpopacity: 1.0); //, normalize2world:true);
    OPENWORLD.Space.objTurn(donkey5, 0-40, normalize2world: true);
    var hay3 = hay2.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay3, 4.20, 22.53, 0.0, 2); // 3.2,2.5, 0.0);
    _hotload.add(hay3);
    var manger7 = manger.clone();
    _hotload.add(manger7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        manger7, 4.08, 22.66, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(manger7, 0-40);

    var fence3x = fence3.clone();
    _hotload.add(fence3x);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3x, 4.41+0.1, 22.42+0.02, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence3x, 90-40);
    var goativ = await OPENWORLD.Actor.copyActor(goat);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        goativ,
        4.56, 22.45, 0.0, 5);
    // OPENWORLD.Space.objTurn(sheep.children[0], 180);
    //  OPENWORLD.Space.objTurn(crab  ,90);  //e
    _hotload.add(goativ);
    var fence3xi = fence3.clone();
    _hotload.add(fence3xi);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3xi, 4.44, 22.57, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence3xi, 90-40);



    instancedRings.finish();
    instancedPillars.finish();
    instancedWoodbundle.finish();
    instancedDonationchest.finish();
    instancedTablelow.finish();
    instancedStool.finish();
    instancedParchment.finish();
    instancedMoneychest.finish();
    instancedBasket.finish();
    instancedBasketWicker.finish();
    instancedParchmentroll.finish();
    instancedCup.finish();
    instancedMatrolled.finish();
    instancedColumnsBethesda.finish();

  }
}
