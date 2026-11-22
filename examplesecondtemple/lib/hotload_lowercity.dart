// code for the lowercity journey along pilgrims road
part of 'SecondTemplePage.dart';

extension HotloadLowercityExt on SecondTemplePageState {
  hotloadLowercity(firsthotload
  ) async {
   //// lowercity

    // hotload of south jerusalem home
    instancedHays.reset();

    var pilgrimspeed = 0.025;

    // Vegetation around lowercity home
    var grassiii = Vegetation();
    var boundarywidth3=20;
    var boundarylength3=20;
    var grassposx2=-17.80;
    var grassposy2=-45.16;
    var  grassgroupii = await grassiii.createGrass(threeJs.camera,
        grassShadow: 0.2,
        boundaryWidth: boundarywidth3,
        //3
        boundaryLength: boundarylength3,
        edgeFalloff: 0,
        worldposx: grassposx2,
        worldposy: grassposy2,
        layerFadeAngle: 0.25,
        seed: 9999,
        surfaceTexture: SurfaceTextureSpec(
            asset: 'assets/models/temple/detailmap.jpg',
            blendStrength: 0.25,
            tilingScale: 0.3, // texture repeats every 12 world metres
            edgeFade: 0.02
          //edgeFade: 0.25, // fades over the outer 25% of the boundary
        ),
        showHeightGrid: false,
        heightGridDivisions: 10,
        heightGridColor: 0xff6a00,
        heightGridOffset: 0.0,
        planeSize: 50);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        grassgroupii, grassposx2, grassposy2, 0.0,
        15);
      hotloadAdd(firsthotload, false, grassgroupii);

    // Door to house the automatically opens when you get near it
    hotloadAdd(firsthotload, false,doorhouse2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        doorhouse2,-17.23, -45.217+0.022, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(doorhouse2, 0);
    OPENWORLD.BaseObject.setDistanceTrigger(
        doorhouse2, dist: 0.15, ignoreifhidden: false,event:(action) {
      if (doorhouse2.extra.containsKey('disabled')&&doorhouse2.extra['disabled'])
        return;
      if (action) {
        // Open the door as get close
        OPENWORLD.Space.objTurnLerp(doorhouse2, 90,1);

      } else {
        // Close door when leave
        OPENWORLD.Space.objTurnLerp(doorhouse2, 0,1);

      }
    });

    var centerx = -16.93;
    var centery = -45.19;

    var ovenposx = -17.14; //-16.85;
    var ovenposy = -45.00; //-45.25;
    //   _hotload.add(oven);
    hotloadAdd(firsthotload, false, tannur);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        tannur, ovenposx, ovenposy, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(tannur, 180); //+180);
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var group = THREE.Group();
      THREE.PointLight light = new THREE.PointLight(
          0xFFA500); //9ae4ff);//9999ff); //PointLight(0xffffff)

      light.intensity = 0.25; // 0.6;
      light.distance = 1.0; //1.2;
      // light.position.y = 0.33;
      OPENWORLD.Light.addFlicker(light);
      group.add(light);
      //  _hotload.add(group);
      hotloadAdd(firsthotload, false, group);

      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          group, ovenposx, ovenposy, 0.0, 3);

      var housefire = new VolumetricFire(
          Glob.fireWidth, Glob.fireHeight, Glob.fireDepth, Glob.sliceSpacing,
          threeJs.camera);
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
    }
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


    var sheep2 = await OPENWORLD.Actor.copyActor(
        sheeporig, duration: 6, randomduration: 1);
    hotloadAdd(firsthotload, false, sheep2);
//    _hotload.add(sheep2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheep2, -17.09 - 0.04, -45.39, 0.0,
        2); // -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
    OPENWORLD.Space.objTurn(sheep2, 0);
    var sheep3 = await OPENWORLD.Actor.copyActor(
        sheeporig, duration: 6, randomduration: 1);
    // _hotload.add(sheep3);
    hotloadAdd(firsthotload, false, sheep3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheep3, -17.07 - 0.04, -45.42, 0.0,
        2); // -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
    OPENWORLD.Space.objTurn(sheep3, 0);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        goat, -17.20, -45.41, 0, 3); // 1.25, 4.22, 0.0, 3); //3.42);
    hotloadAdd(firsthotload, false, goat);
    //_hotload.add(goat);


   /* var hay2=hay.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay2,centerx+(-17.65-centerx)*0.5, centery+(-45.39-centery)*0.5, 0.02, 2); // 3.2,2.5, 0.0);
    _hotload.add(hay2);*/
    instancedHays.place(0,centerx+(-17.65-centerx)*0.5, centery+(-45.39-centery)*0.5, 0.02);//,5);

 /*   var hay3=hay.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay3,centerx+(-17.21-centerx)*0.5, centery+(-45.24-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    _hotload.add(hay3);*/
    instancedHays.place(0,centerx+(-17.21-centerx)*0.5, centery+(-45.24-centery)*0.5, 0.0);//,5);



   /* var hay5 = hay.clone();
    hay5.scale.setValues(0.04, 0.04, 0.04);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay5, -17.15, -45.40, -0.005,
        2); //centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    //_hotload.add(hay5);
    hotloadAdd(firsthotload, false, hay5);*/
    instancedHays.place(0, -17.15, -45.40, -0.005,  scale:THREE.Vector3(0.04,0.04,0.04));//,5);

    /*var hay6 = hay.clone();
    hay6.scale.setValues(0.04, 0.04, 0.04);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay6, -17.23, -45.40, -0.005,
        2); //centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    //_hotload.add(hay6);
    hotloadAdd(firsthotload, false, hay6);*/
    instancedHays.place(0,  -17.23, -45.40, -0.005,  scale:THREE.Vector3(0.04,0.04,0.04));//,5);

    /*var hay7 = hay.clone();
    hay7.scale.setValues(0.04, 0.04, 0.04);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay7, -17.02, -45.41, -0.005,
        2); //centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    // _hotload.add(hay7);
    hotloadAdd(firsthotload, false, hay7);*/
    instancedHays.place(0,   -17.02, -45.41, -0.005,  scale:THREE.Vector3(0.04,0.04,0.04));//,5);

    // var centerx = -16.93;
    // var centery = -45.19;


    var pitchfork2 = pitchfork.clone();
    pitchfork2.children[0].scale.setValues(0.01, 0.01, 0.01);
    OPENWORLD.Space.setTurnPitchRoll(pitchfork2.children[0], 90, 90, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pitchfork2, -16.99, -45.49, 0,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    // _hotload.add(pitchfork2);
    hotloadAdd(firsthotload, false, pitchfork2);

  /*  var hay4 = hay.clone();
    hay4.scale.setValues(0.04, 0.04, 0.04);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay4, -17.02, -45.33, -0.005,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    //_hotload.add(hay4);
    hotloadAdd(firsthotload, false, hay4);*/
    instancedHays.place(0,   -17.02, -45.33, -0.005,  scale:THREE.Vector3(0.04,0.04,0.04));//,5);


    ///_hotload.add(fence3);
    hotloadAdd(firsthotload, false, fence3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3, -17.20, -45.34, 0.0, 2); // 3.2,2.5, 0.0);

    var fence3ii = fence3.clone();
    hotloadAdd(firsthotload, false, fence3ii);
//    _hotload.add(fence3ii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3ii, -17.09 - 0.03, -45.34, 0.0, 2); // 3.2,2.5, 0.0);

    hotloadAdd(firsthotload, false, pot);
//    _hotload.add(pot);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot, -16.925, -45.37 - 0.1, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);


    /* var pot2= pot.clone();
    _hotload.add(pot2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot2,-16.93, -45.43,0.058,2);*/ //-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);

//    hammer.children[0].scale.setValues(0.1, 0.1, 0.1);
    // OPENWORLD.Space.setTurnPitchRoll(hammer.children[0], 90, 90, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        chisel, -16.93, -45.38, 0.057,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    // _hotload.add(chisel);
    hotloadAdd(firsthotload, false, chisel);


//    hammer.children[0].scale.setValues(0.1, 0.1, 0.1);
    // OPENWORLD.Space.setTurnPitchRoll(hammer.children[0], 90, 90, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hammer, -16.94, -45.38, 0.057,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    //_hotload.add(hammer);
    hotloadAdd(firsthotload, false, hammer);


    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        saw, -16.92, -45.38, 0.059,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    //_hotload.add(saw);
    hotloadAdd(firsthotload, false, saw);
    OPENWORLD.Space.objRoll(saw, 90);


    //_hotload.add(board);
    hotloadAdd(firsthotload, false, board);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board, -16.90, -45.51, 0.1,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);

    var board4 = board.clone();
    //_hotload.add(board4);
    hotloadAdd(firsthotload, false, board4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board4, -16.91, -45.51, 0.1,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var hammer2 = hammer.clone();
//    _hotload.add(hammer2);
    hotloadAdd(firsthotload, false, hammer2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hammer2, -16.905, -45.51, 0.1 - 0.026,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objPitch(hammer2, 90);
    var board5 = board.clone();
    // _hotload.add(board5);
    hotloadAdd(firsthotload, false, board5);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board5, -16.916, -45.51, 0.1,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var chisel2 = chisel.clone();
//    _hotload.add(chisel2);
    hotloadAdd(firsthotload, false, chisel2);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        chisel2, -16.915, -45.51, 0.1 - 0.008,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objPitch(chisel2, 90);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        shovel, -16.89, -45.51, 0.0,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    // _hotload.add(shovel);
    hotloadAdd(firsthotload, false, shovel);

    OPENWORLD.Space.objTurn(shovel, 90);

//    _hotload.add(basket);
    hotloadAdd(firsthotload, false, basket);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket, -16.73, -45.51, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);

    //   _hotload.add(plate);
    hotloadAdd(firsthotload, false, plate);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        plate, -16.85, -45.42, 0.054,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);

    var boardposx = -16.74 - 0.02; //-0.1;
    var boardposy = -45.39 ;//+ 0.1;
    //_hotload.add(amphora);
  /*  hotloadAdd(firsthotload, false, amphora);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora, boardposx, boardposy, 0.005,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
*/
    var boardii = board.clone();
    //  _hotload.add(boardii);
    hotloadAdd(firsthotload, false, boardii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        boardii, boardposx, boardposy, 0.005,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    boardii.scale.setValues(0.011, 0.011, 0.008);
    OPENWORLD.Space.objTurn(boardii, 90+15);

   /* var pot3 = pot.clone();
    //  _hotload.add(pot3);
    hotloadAdd(firsthotload, false, pot3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot3, boardposx - 0.04, boardposy + 0.02, 0,
        2); *///-16.79, -45.47,0.0,2);//-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);
    //  _hotload.add(cup);
    hotloadAdd(firsthotload, false, cup);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup, boardposx+0.01, boardposy + 0.01, 0.005,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var cup2 = cup.clone();
    //_hotload.add(cup2);
    hotloadAdd(firsthotload, false, cup2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup2, boardposx - 0.015+0.01, boardposy + 0.01, 0.005,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var platelowercity = plate.clone();
    var breadunleavenlowercity=breadunleaven.clone();
    //_hotload.add(plate2);
    hotloadAdd(firsthotload, false, platelowercity);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        platelowercity, boardposx + 0.02, boardposy + 0.025, 0.01,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    platelowercity.add(breadunleavenlowercity);
   // Future.delayed(Duration(milliseconds: 10000), () async {
    //  print("eat bread");
     // eatbread(plate2ii,10);//breadunleavenlowercity);
     // breadunleavenlowercity.visible=false;
   // });
    var platedad = plate.clone();
    //_hotload.add(plate2);
    hotloadAdd(firsthotload, false, platedad);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        platedad, boardposx -0.01, boardposy + 0.025, 0.01,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    platedad.add(breadunleaven);

    var plateson = platedad.clone();
    //_hotload.add(plate2);
    hotloadAdd(firsthotload, false, plateson);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        plateson, boardposx -0.01, boardposy + 0.025-0.04, 0.01,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var platedaughter = platedad.clone();
    //_hotload.add(plate2);
    hotloadAdd(firsthotload, false, platedaughter);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        platedaughter, boardposx +0.02, boardposy + 0.025-0.04, 0.01,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);

    // add cups and plates to board
    // should add baskets to kitchen which will contain stuff like food
    // also sort of alcove bit that hold plates like in the pic

    // _hotload.add(mortar);
    hotloadAdd(firsthotload, false, mortar);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(mortar, -16.85, -45.40,0.056,//-16.83, -45.11, 0.043,
        2); //-16.71, -45.17,0.0,2);//-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);


    var plate3 = plate.clone();
//    _hotload.add(plate3);
    hotloadAdd(firsthotload, false, plate3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        plate3, -16.85, -45.42 - 0.05, 0.056, 2);

    var cup3 = cup.clone();
    //  _hotload.add(cup3);
    hotloadAdd(firsthotload, false, cup3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup3, -16.87, -45.42 - 0.1, 0.055,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);


    var amphora2 = amphora.clone();
    // _hotload.add(amphora2);
    hotloadAdd(firsthotload, false, amphora2);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora2, -16.82, -45.49, 0.005,
        2); //-17.02+0.08, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(amphora2, 30);

    var amphora3 = amphora.clone();
    //  _hotload.add(amphora3);
    hotloadAdd(firsthotload, false, amphora3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora3, -16.95, -45.48, 0.056,
        2); //-17.02+0.08, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(amphora3, 30);

    // _hotload.add(clothesline);
    hotloadAdd(firsthotload, false, clothesline);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clothesline, centerx + (-17.61 - centerx) * 0.5,
        centery + (-45.49 - centery) * 0.5, 0.08, 2); // 3.2,2.5, 0.0);

    var clothesline2 = clothesline.clone();
    // _hotload.add(clothesline2);
    hotloadAdd(firsthotload, false, clothesline2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clothesline2, centerx + (-17.54 - centerx) * 0.5,
        centery + (-44.92 - centery) * 0.5, 0.08, 2); // 3.2,2.5, 0.0);

    var clothesline3 = clothesline.clone();
    //_hotload.add(clothesline3);
    hotloadAdd(firsthotload, false, clothesline3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clothesline3, -17.67, -45.18, 0.08, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(clothesline3, 0);

    // _hotload.add(table);
    hotloadAdd(firsthotload, false, table);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        table, -16.93, -45.43, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(table, 95);

    // _hotload.add(firepit);
    hotloadAdd(firsthotload, false, firepit);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        firepit, -16.85, -45.25, 0.0,
        2); //-16.93, -45.43, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Texture.setBasicMaterial(firepit, groupname: "embers");
    if (gamestart!=GameStart.lowercity)  // You are a woman in lowercity journey so sounds weird with male pain voices
    OPENWORLD.BaseObject.setDistanceTrigger(firepit,
        dist: 0.05, event: (action) {
          if (action) {
            OPENWORLD.Sound.play(path: OPENWORLD.Math.randPick(['sounds/pain.mp3','sounds/pain2.mp3','sounds/pain3.mp3']),volume: 0.1);
          }
   });

    var smoke4 = Smoke();
    var smokeGroup3 = await smoke4.createSmoke(
        'assets/textures/smoke/clouds64.png');
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smokeGroup3, -16.85, -45.25, 0.01,
        3); //centerx+(-17.02-centerx)*0.5, centery+(-45.58-centery)*0.5, 0.51*0.5, 3);
    /// OPENWORLD.Space.worldToLocalSurfaceObjHide(
    //     smokeGroup2,  -16.85,-45.25, 0.51*0.5, 3);
    smokeGroup3.scale.setValues(0.000015, 0.000015, 0.000015);
    OPENWORLD.Updateables.add(smoke4);
    //  _hotload.add(smokeGroup3);
    hotloadAdd(firsthotload, false, smokeGroup3);
    //OPENWORLD.Texture.setEmissive(firepit, THREE.Color.fromHex32(0xfffff));
    hotloadAdd(firsthotload, false, cistern);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cistern,-16.85-0.02, -45.05,0.005,//-16.92, -45.13,0.003,// -16.89, -45.09, 0.003,
        2); //;-17.16, -45.18,0.0,2);//-16.93, -45.43, 0.0, 2); // 3.2,2.5, 0.0);
    //cistern.scale.setValues(0.02,0.02,0.02);
    OPENWORLD.Texture.setBasicMaterial(cistern, groupname: "pit");
    OPENWORLD.Texture.setColor(
        cistern, THREE.Color.fromHex32(0x000000), groupname: "pit");

    hotloadAdd(firsthotload, false, ladder);
    //OPENWORLD.Space.worldToLocalSurfaceObj(
    //    ladder,-16.51, -45.33,0.0,level:1);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        ladder, -16.51, -45.33, 0.0, 2); //, level:1);
    OPENWORLD.Space.objTurn(ladder, 90);

    var ladder2 = ladder.clone();
    // _hotload.add(ladder2);
    hotloadAdd(firsthotload, false, ladder2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        ladder2, -16.51, -45.33 - 0.2+0.02, 0.0, 2, level: 1);
    ladder2.scale.setValues(0.0135, 0.0135, 0.0135);  //0.013

    var basket2 = basket.clone();
    // _hotload.add(basket2);
    hotloadAdd(firsthotload, false, basket2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket2, -16.66, -45.51, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);

    var sack2 = sack.clone();
    // _hotload.add(basket2);
    hotloadAdd(firsthotload, false, sack2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sack2,-16.55, -45.53, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);

    var sack3 = sack.clone();
    // _hotload.add(basket2);
    hotloadAdd(firsthotload, false, sack3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sack3,-16.63, -45.20, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);

    var amphora4 = amphora.clone();
    //_hotload.add(amphora4);
    hotloadAdd(firsthotload, false, amphora4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora4, -16.52, -45.51, 0.0,
        2); //-17.02+0.08, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(amphora4, 30);
    var basket3 = basket.clone();
    hotloadAdd(firsthotload, false, basket3);
//    _hotload.add(basket3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket3, -16.51, -45.42, 0, 2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    var pot4 = pot.clone();
    hotloadAdd(firsthotload, false, pot4);
    //  _hotload.add(pot4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot4, -16.58, -45.52, 0.0, 2); //-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);

    var grandma;
    // This is the position where you sit at the dinner table - must be here so that grandma knows where to stop and sit and eat with everyone else
    var sitposx = -16.70;
    var sitposy = -45.39 + 0.01;
    var dadisstanding=gamestartpos[gamestart].containsKey('progress')&&gamestartpos[gamestart]['progress'].contains('finishedmeal');
    if (!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      dad = await OPENWORLD.Actor.copyActor(
          citizen2, action: !dadisstanding?"laysideidle2":"idle"); //"shovel");
      // _hotload.add(citizen2iii);
      hotloadAdd(firsthotload, false, dad);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          dad, -16.56 + 0.03, -45.32, -0.005, 2,
          level: 2); //centerx+(-17.27-centerx)*0.5, centery+(-45.26-centery)*0.5,0.0);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
      OPENWORLD.Space.objTurn(dad, 0);
      OPENWORLD.BaseObject.setVisible(
          dad, false, groupname: "citizen_2"); // shoes off
      setcancollide(dad, true);
      OPENWORLD.Mob.setName(dad, "dad");

      grandma = await OPENWORLD.Actor.copyActor(
          citizenf23oldlady, action: null); //"squatwork");//right");
      // _hotload.add(citizenf2ii);
      hotloadAdd(firsthotload, false, grandma);
      // Squatting at the table with food
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          grandma, -16.76, -45.33, 0,
          2); //centerx+(-17.27-centerx)*0.5, centery+(-45.26-centery)*0.5,0.0);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
      OPENWORLD.Space.objTurn(grandma, 180);
      setcancollide(grandma, true);
      //OPENWORLD.Space.setZLerp(dad,0.1,10,level:2,delay:15);
      //OPENWORLD.Space.worldToLocalSurfaceOnlyObjLerp(
      //    dad, -16.56 + 0.03, -45.32, 0.5, //57.59, 13.35
      //    10.0, delay:10);
      //  OPENWORLD.Actor.playActionsLoop(citizenf2ii, ["pickupright","idle","point","pickupright","idlebum","idle","idle","pickupright","pickupright","idle","idlenose","idle"]);
     // var askedbreakfast=0;

      neargrandma()
      {
        return OPENWORLD.You.level==0&& OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, grandma)<0.5;
      }

      List<Map> positions=[
        {
          "action": "squatwork",
          "time": 10,
          "duration": null,
          "z": 0.0,
          "t": 180,
          'callback': (actor) {
            if (gamestart==GameStart.lowercity&&/*askedbreakfast==0&&*/neargrandma()&&(dad.position.y-threeJs.camera.position.y).abs()>0.1) {// OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, dad) >0.1) {
              // askedbreakfast++;
              //  OPENWORLD.Space.facePointLerp(actor, sitposx, sitposy, 1.0);


            } else {
              var worldpos = OPENWORLD.You.getWorldPos();
              //  var grandmapos = OPENWORLD.Space.localToWorldObj(actor);

              if (OPENWORLD.Math.vectorDistance(
                  worldpos, THREE.Vector3(sitposx, sitposy, 0.0)) < 0.1) {
                OPENWORLD.BaseObject.clearAll(grandma);
                print("grandma clear all" +
                    OPENWORLD.Space
                        .getDistanceBetweenObjs(threeJs.camera, dad)
                        .toString());
              }
            }
          }
        },
        { 'p': [-16.79, -45.26 + 0.02, 0], 'v': pilgrimspeed,"callback":(actor){
          // At fire pit

        }
        },
        //
        {  // squatting at nothing
          "action": "squatwork",
          "time": 16,
          "duration": null,
          "z": 0.0,
          "t": 270,
          "callback":(actor) {

          }

       },
        { 'p': [-16.81, -45.16, 0], 'v': pilgrimspeed},
        { 'p': [-17.10, -45.17, 0], 'v': pilgrimspeed, "callback":(actor){
          if ( gamestart==GameStart.lowercity&&/*askedbreakfast==0&&*/ neargrandma()&&
              (dad.position.y-threeJs.camera.position.y).abs()>0.1) {
             // OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, dad) >0.1) {
            OPENWORLD.Space.faceObjectLerp(actor,threeJs.camera,1,delay:1);

            OPENWORLD.Mob.setSpeech(actor, [
              "Gee, they're not up yet.",
              "You should go up and wake them?",
            ], z: 60,
                scale: 0.3,
                minwait: 5,
                randwait: 0,
                width: 300,
                clearwhendone: true,
                callbackonfinish: (actor) {
                  OPENWORLD.Space.objTurnLerp(actor,270,1);
                }
            );
          }
        }
        },
        // squatting at kiln
        {
          "action": "squatwork",
          "time": 16,
          "duration": null,
          "z": 0.0,
          "t": 270,
        },
        { 'p': [-17.14, -45.05, 0], 'v': pilgrimspeed},
        //tannur
        {
          "action": "squatwork",
          "time": 16,
          "duration": null,
          "z": 0.0,
          "t": 0
        },
        { 'p': [-17.14, -45.05, 0], 'v': pilgrimspeed},
        { 'p': [-17.10, -45.18, 0], 'v': pilgrimspeed},
        { 'p': [-16.81, -45.18, 0], 'v': pilgrimspeed},
        { 'p': [-16.76, -45.33, 0], 'v': pilgrimspeed,"callback":(actor) {
          // At the table
          if ( gamestart==GameStart.lowercity&&/*askedbreakfast==0&&*/ neargrandma()&&
              (dad.position.y-threeJs.camera.position.y).abs()>0.1
            //  OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, dad) >0.1
          ) {
            OPENWORLD.Space.faceObjectLerp(
                actor, threeJs.camera, 1); //, object2, time)
            OPENWORLD.Actor.playActionThen(actor, "squatpoint", "squat");

            OPENWORLD.Mob.setSpeech(actor, [
              "I don't think the others",
              "are up yet.",
              "Can you go up and wake them?", //Why don't you sit down?"
            ], z: 60,
                scale: 0.3,
                minwait: 5,
                randwait: 0,
                width: 300,
                clearwhendone: true,
                callbackonfinish: (actor) {
                  OPENWORLD.BaseObject.setDistanceTrigger(actor,
                      dist: 0.1, event: (action) {
                        if (action) {
                          if (OPENWORLD.Space.getDistanceBetweenObjs(
                              threeJs.camera, dad) >
                              0.1) { //&&askedbreakfast==1) {
                            // askedbreakfast++;
                            OPENWORLD.Mob.setSpeech(actor, [
                              "They're still not down?",
                            ], z: 60,
                                scale: 0.3,
                                minwait: 5,
                                randwait: 0,
                                width: 300,
                                clearwhendone: true,
                                callbackonfinish: (actor) {}
                              //  delay: 5
                            );
                          }

                          //  citizen.visible = true;
                        } else {
                          //   citizen.visible = false;
                        }
                      });
                }

              //  delay: 5
            );
          }

        }
        }
      ];

      OPENWORLD.Mob.moveToLoop(grandma,
            positions,//.reversed.toList(),

          //  duration:0.7,
            index:5,
          // randomduration: 0.1,
          // reverseloop:true,
          surfaceonly: true,
          fadeout: 1.0,
          action: "walk"
      );

      // _hotload.add(cistern);

      donkeypackbuckets = await OPENWORLD.Actor.copyActor(donkeyorig);
      // threeJs.scene.add(donkey2);
      _hotload.add(donkeypackbuckets);
      // Placed at the house
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkeypackbuckets, -16.92, -45.14 + 0.02, 0, 5);
      OPENWORLD.Space.objTurn(donkeypackbuckets, 180);

      _hotload.add(packdonkeybuckets);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          packdonkeybuckets, -16.92 + 0.03, -45.14 + 0.02, 0.025,
          5); // -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);

      OPENWORLD.Space.objTurn(packdonkeybuckets, 90);
      OPENWORLD.BaseObject.setVisible(
          packdonkeybuckets, false, groupname: "figs");
      OPENWORLD.BaseObject.setVisible(
          packdonkeybuckets, false, groupname: "apples");
      OPENWORLD.BaseObject.setVisible(
          packdonkeybuckets, false, groupname: "cover");
    }

  /*  var hay8ii = hay.clone();
    hotloadAdd(firsthotload, false, hay8ii);
    hay8ii.scale.setValues(0.04, 0.04, 0.04);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(hay8ii,-16.87, -45.12, 0.00, 2);*/
    // _hotload.add(ladder);
    instancedHays.place(0, -16.87, -45.12, 0.00,  scale:THREE.Vector3(0.04,0.04,0.04));//,5);

    OPENWORLD.You.immobile = false;


    //_hotload.add(mati);
    hotloadAdd(firsthotload, false, mati);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mati, -16.60, -45.43, 0.005, 2, level: 0);
    OPENWORLD.Space.objTurn(mati, 90);
    OPENWORLD.BaseObject.setVisible(
        mati, false, groupname: "olives");  // shoes off


    // Roof of house

    // ground floor to First floor
    OPENWORLD.Portals.createPortal(
        -16.51,
        -45.33,
        0.04,
        0.1,
        -16.6,//57,
        -45.41,
        0.0,
        level2: 1,
        //  marker:_hotload,
        lerp: 1);
    // first floor to ground floor
    var portalgogroundlevel= OPENWORLD.Portals.createPortal(
        -16.52-0.01,
        -45.34,//28,
        level: 1,
        0.06,
        0.18,
        -16.62,
        -45.30,
        0.0,
        level2: 0,
        angleentry: 45,
        angleentrythresh: 100,
        //  marker:_hotload,
        finalturn:270,
        //    name:"lowercityfloor1to0",
        lerp: 1);

    // first floor to second floor
    var portalgoupstairs= OPENWORLD.Portals.createPortal(
        -16.51,
        -45.33 - 0.2,
        level: 1,
        0.07,
        0.1,
        -16.63,
        -45.49,
        0.0,
        // marker:_hotload,
        angleentry: 45,
        angleentrythresh: 140,
        level2: 2,
        lerp: 1);


    // Second floor to first floor
    var portalgodownstairs= OPENWORLD.Portals.createPortal(
        -16.56,
        -45.46-0.02,//4,
        level: 2,
        0.08,
        0.14,
        -16.66, -45.51+0.03,// -16.58,
        //   -45.34,
        0.0,
        angleentry:90+45,
        angleentrythresh:90,//140,
        //  marker:_hotload,
        level2: 1,
        finalturn:30,
        lerp: 1);

    /* var stairsiconii = await OPENWORLD.Sprite.makeTextSprite(
        'Stairs ↓', Colors.white, width:200, sizeattentuation: true, scale:0.03,paddingLeft: 5, paddingRight: 5);
    hotloadAdd(firsthotload, false, stairsiconii);
    stairsiconii.scale.setValues(0.04*0.6,0.02*0.4,1.0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        stairsiconii,-16.64+0.1, -45.47, 0.03, 2,level:2);*/
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

    var stairsdownicon = await OPENWORLD.Sprite.makeMultiTextSprite(spritemsg, scale:0.03);//, x: x, y: y, z: z);
    hotloadAdd(firsthotload, false, stairsdownicon);
    stairsdownicon.scale.setValues(0.08*0.6,0.02*0.6,1.0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        stairsdownicon, -16.64+0.1, -45.47, 0.03, 2,level:2);
    if (gamestart==GameStart.lowercity) {
      // So can't press 'e' while still laying on ground
      OPENWORLD.Space.removeObjFromHide(stairsdownicon);
      stairsdownicon.visible=false;
    }
    OPENWORLD.KeyboardCallbacks.createKeyboardCallback('E',object:stairsdownicon,0.4, facingdiff: 90,keyreactivatetime: 4,
//    OPENWORLD.KeyboardCallbacks.createKeyboardCallback('E', 57.76+0.06, 13.35,0.4,
            (keyboardcallback) {
          print("keypressed stairs go down"+keyboardcallback.toString());
          var worldpos = OPENWORLD.You.getWorldPos();
          var closesthit=portalgodownstairs.closestHit(worldpos.x, worldpos.y);  // so dont get off the level
          OPENWORLD.Mob.moveTo(threeJs.camera, level:2,
              [[closesthit[0],closesthit[1],  OPENWORLD.Camera.cameraoffset, 0.5]],
              callbackonfinish: (actor) {
                portalgodownstairs.enter();
              }
          );

        },
        level:2);

    var matii = mati.clone();
    //_hotload.add(matii);
    hotloadAdd(firsthotload, false, matii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matii, -16.56+0.04, -45.32, 0.002, 2, level: 2);

    var pillow5iii = pillow.clone();
    hotloadAdd(firsthotload, false, pillow5iii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pillow5iii, -16.56+0.03, -45.32-0.05, 0.00, 2,level:2);
    OPENWORLD.Space.objTurn(pillow5iii, 130);

    var matiiii = mati.clone();
    //_hotload.add(matii);
    hotloadAdd(firsthotload, false, matiiii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matiiii, -16.56-0.04, -45.32, 0.002, 2, level: 2);
    var pillow5iiii = pillow.clone();
    hotloadAdd(firsthotload, false, pillow5iiii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pillow5iiii, -16.56-0.04, -45.32-0.05, 0.00, 2,level:2);
    OPENWORLD.Space.objTurn(pillow5iiii, 130);

    var pot5 = pot.clone();
    // _hotload.add(pot5);
    hotloadAdd(firsthotload, false, pot5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot5, -16.49, -45.22, 0.0, 2,
        level: 2); //-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);


/*
    var breadunleaven2ii = breadunleaven.clone();
    OPENWORLD.Space.setTurnPitchRoll(breadunleaven2ii.children[0], 0, 90,-45);
    // OPENWORLD.Space.objRoll(pitchfork.children[0], 90);
    //  OPENWORLD.Space.objTurn(pitchfork.children[0], 20 + 180);
    breadunleaven2ii.position.z = 0.0; //-4.0;
    breadunleaven2ii.position.y = 0.0; //5.0;
    breadunleaven2ii.position.x = 5.0;//7.0;
    OPENWORLD.Actor.wield(citizen2iii, breadunleaven2ii, "Bip01_L_Hand");
*/
  /*  var squatactions=[
      //  "squateat",
      "squateat",
      //    "squateat",
      //   "squateat",
      "squatwork",
      // "squateat", /*"squatwork","squateat",*/
      // "squat"
    ];*/
    // squatactions.shuffle();
   // OPENWORLD.Actor.playActionsLoop(citizen2iii, squatactions, fadein:0.0, fadeout:1.0, randomaction:true, looprepetitionss:[4,1], randomdurations:[0.1,0.1]);
//      OPENWORLD.Actor.playActionsLoop(citizen2iii, ["squateat","squatwork"], fadein:0.0, fadeout:1.0);//,"laysideidle"]);//,delay:25);
//    OPENWORLD.Actor.playActionsLoop(citizen2iii, ["squateat","squateat","squateat", /*"squatwork","squateat","squat"*/]);//,delay:25);

//    OPENWORLD.Space.objPitch(citizen2iii,-8);
  /*  OPENWORLD.Space.setTurnPitchRoll(pitchfork.children[0], 90, 0, 0);
    // OPENWORLD.Space.objRoll(pitchfork.children[0], 90);
    //  OPENWORLD.Space.objTurn(pitchfork.children[0], 20 + 180);
    OPENWORLD.Actor.wield(citizen2iii, pitchfork, "Bip01_L_Hand");
    OPENWORLD.Space.objPitch(citizen2iii,-8);
*/

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

    hotloadAdd(firsthotload, false, stairsupicon);

    stairsupicon.scale.setValues(0.08*0.6,0.02*0.6,1.0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        stairsupicon, -16.64+0.1, -45.47, 0.03, 2,level:1);
    OPENWORLD.KeyboardCallbacks.createKeyboardCallback('E',object:stairsupicon,0.4, facingdiff: 45, level:1, keyreactivatetime: 4,
//    OPENWORLD.KeyboardCallbacks.createKeyboardCallback('E', 57.76+0.06, 13.35,0.4,
            (keyboardcallback) {
          print("keypressed stairs go up"+keyboardcallback.toString());
          var worldpos = OPENWORLD.You.getWorldPos();
          var closesthit=portalgoupstairs.closestHit(worldpos.x, worldpos.y);  // so dont get off the level
          OPENWORLD.Mob.moveTo(threeJs.camera, level:1,
              [[closesthit[0],closesthit[1],  OPENWORLD.Camera.cameraoffset, 0.5]],
              callbackonfinish: (actor) {
                portalgoupstairs.enter();

              }
          );
        });


   /* var stairsiconiii = await OPENWORLD.Sprite.makeTextSprite(
        'Stairs ↑', Colors.white, width:200, sizeattentuation: true, scale:0.03,paddingLeft: 5, paddingRight: 5);
    hotloadAdd(firsthotload, false, stairsiconiii);
    stairsiconiii.scale.setValues(0.04*0.6,0.02*0.4,1.0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        stairsiconiii,-16.64+0.1, -45.47, 0.03, 2,level:1);*/ //-17.78, -44.81


    spritemsg=[];
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
    var stairsdowngroundicon = await OPENWORLD.Sprite.makeMultiTextSprite( spritemsg, scale:0.03);//, x: x, y: y, z: z);
    hotloadAdd(firsthotload, false, stairsdowngroundicon);
    stairsdowngroundicon.scale.setValues(0.08*0.6,0.02*0.6,1.0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        stairsdowngroundicon, -16.52, -45.34, 0.03, 2,level:1);

    OPENWORLD.KeyboardCallbacks.createKeyboardCallback('E',object:stairsdowngroundicon,0.4, facingdiff: 45,keyreactivatetime: 4,
//    OPENWORLD.KeyboardCallbacks.createKeyboardCallback('E', 57.76+0.06, 13.35,0.4,
            (keyboardcallback) {
          print("keypressed stairs go down ground"+keyboardcallback.toString());
          var worldpos = OPENWORLD.You.getWorldPos();
          var closesthit=portalgogroundlevel.closestHit(worldpos.x, worldpos.y);  // so dont get off the level
          OPENWORLD.Mob.moveTo(threeJs.camera, level:1,
              [[closesthit[0],closesthit[1],  OPENWORLD.Camera.cameraoffset, 0.5]],
              callbackonfinish: (actor) {
                portalgogroundlevel.enter();
              }
          );
        },
        level:1);

   /* var stairsiconiv = await OPENWORLD.Sprite.makeTextSprite(
        'Stairs ↓', Colors.white, width:200, sizeattentuation: true, scale:0.03,paddingLeft: 5, paddingRight: 5);
    hotloadAdd(firsthotload, false, stairsiconiv);
    stairsiconiv.scale.setValues(0.04*0.6,0.02*0.4,1.0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        stairsiconiv,-16.52, -45.34, 0.03, 2,level:1);//-17.78, -44.81
*/

    var loom2 = loom.clone();
    hotloadAdd(firsthotload, false, loom2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        loom2, -16.63, -45.47, 0.0, 2, level: 1);
    OPENWORLD.Space.objTurn(loom2, 0);

    // _hotload.add(loomweight);

    hotloadAdd(firsthotload, false, loomweight);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        loomweight, -16.63 - 0.035, -45.47 - 0.02, 0.0, 2, level: 1);
    var loomweight2 = loomweight.clone();
    hotloadAdd(firsthotload, false, loomweight2);
//    _hotload.add(loomweight2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        loomweight2, -16.63 - 0.045, -45.47 - 0.02, 0.0, 2, level: 1);
    var loomweight3 = loomweight.clone();
    hotloadAdd(firsthotload, false, loomweight3);
    //  _hotload.add(loomweight3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        loomweight3, -16.63 - 0.055, -45.47 - 0.03, 0.0, 2, level: 1);
    var loomweight4 = loomweight.clone();
    //  _hotload.add(loomweight4);
    hotloadAdd(firsthotload, false, loomweight4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        loomweight4, -16.63 - 0.045, -45.47 - 0.04, 0.0, 2, level: 1);
    // _hotload.add(bedding);
    bedding.scale.setValues(1.0, 1.0, 1.0);
    OPENWORLD.Texture.setEmissive(bedding, THREE.Color.fromHex32(0x444444));
    var bedding5=bedding.clone();
    bedding5.scale.setValues(0.7,0.7,0.7);
    hotloadAdd(firsthotload, false, bedding5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bedding5, -16.51, -45.20, 0.0, 2, level: 1);
    OPENWORLD.Space.objTurn(bedding5, 90);

    pillow.scale.setValues(1.0, 1.0, 1.0);
    OPENWORLD.Texture.setEmissive(pillow, THREE.Color.fromHex32(0x444444));
    var pillow4iii=pillow.clone();
    pillow4iii.scale.setValues(0.6,0.6,0.6);
    // _hotload.add(pillow);
    hotloadAdd(firsthotload, false, pillow4iii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pillow4iii, -16.51, -45.26, 0.0, 2, level: 1);
    OPENWORLD.Space.objTurn(pillow4iii, 90);

    var bedding4=bedding5.clone();
    hotloadAdd(firsthotload, false, bedding4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bedding4, -16.6+0.03, -45.20, 0.0, 2, level: 1);

    var pillow4ii=pillow4iii.clone();
    hotloadAdd(firsthotload, false, pillow4ii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pillow4ii, -16.6+0.03, -45.26, 0.0, 2, level: 1);

    // _hotload.add(robes);

    var daughter=await OPENWORLD.Actor.copyActor(childgirl,action:"laysideidle");//walkup");//,duration:1.0);
    _hotload.add(daughter);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        daughter, -16.51, -45.20-0.04, 0.005, 2, level: 1);
    OPENWORLD.Space.objTurn(daughter, 0);
    setcancollide(daughter,true);


    var son=await OPENWORLD.Actor.copyActor(child1,action:"laysideidle");//idle3");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        son,-16.6+0.03, -45.20-0.04,0.005,2,level:1);;
    _hotload.add(son);
    OPENWORLD.Space.objTurn(son, 0);
    setcancollide( son,true);
    OPENWORLD.Mob.setName(son,"son");



    // Just put the pack on the donkey
    putonpack()
    {
      print("put on pack");
      var packdonkeybucketswield=packdonkeybuckets.clone();
      packdonkeybucketswield.visible=true;
      OPENWORLD.BaseObject.setVisible(
          packdonkeybucketswield, true, groupname: "cover");
      packdonkeybucketswield.scale.setValues(0.04 , 0.04, 0.04);
      packdonkeybucketswield.position.y=0.4;
      //packdonkey.position.y+=0.4;
      //OPENWORLD.Space.removeObjFromHide(packdonkeybuckets);
      //packdonkey.visible=false;
      packdonkeybucketswield.position.x = 0.0;
      // packdonkey.position.y = 0.028;
      packdonkeybucketswield.position.z = 0.0;//-0.013;
      // !! You must reset rotation because objTurn subtracts 180
      packdonkeybucketswield.rotation.x = 0.0;
      packdonkeybucketswield.rotation.y = 0.0;
      packdonkeybucketswield.rotation.z = 0.0; //-0.013;
      //_hotload.remove(packdonkeybuckets);
      packdonkeybuckets.visible=false;
//      packdonkeybuckets.attach(donkeypackbuckets);
      donkeypackbuckets.extra['packdonkeybuckets']=packdonkeybuckets;
      donkeypackbuckets.extra['packdonkeybucketswield']=packdonkeybucketswield;
      // OPENWORLD.Space.worldToLocalSurfaceObjHide(
      //     packdonkey, -16.92+0.03, -45.14+0.02,0.025,5);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
      OPENWORLD.Actor.wield(donkeypackbuckets,packdonkeybucketswield, "ride");//Bip01_Ponytail1Nub_011");//ride");//Joint31");
      //packdonkeybuckets.updateMatrixWorld(true);
      OPENWORLD.BaseObject.setVisible(
          packdonkeybucketswield, true, groupname: "figs");
      OPENWORLD.BaseObject.setVisible(
          packdonkeybucketswield, true, groupname: "apples");

    }

  //  print("vvvvvv"+OPENWORLD.Mob.chopText("Look our donkey isn't limping at all anymore that was a scare...  thought we might need to carry the goods ourselves this morning").toString());
//    print("vvvvvv"+OPENWORLD.Mob.chopText("Look our donkey isn't limping at all anymore - that was a scare - thought we might need to carry the goods ourselves this morning").toString());

    var girlspeed = 0.05;

    // Fruit Shop hotload
    roomShop = OPENWORLD.Room.createRoom(
        -6.33, -20.5,
        soundpath: "sounds/courtyard.mp3",
        volume: 0.05);

    roomShop.extra['guide'] = [
      "You are at your fruit shop in the lower city.",
    ];
    // OPENWORLD.Room.setIndoors(roombethphage, true);
    OPENWORLD.Room.setAutoIndoors(roomShop, true);
    _hotload.add(roomShop);
    var picked = [];
    var shoppers = [];
    for (var i = 0; i < 10; i++) {
      var shopperactor = OPENWORLD.Math.randPick(adultlist, exclude: picked);
      picked.add(shopperactor);
      var shopper = await OPENWORLD.Actor.copyActor(shopperactor);
      shoppers.add(shopper);
    }
    // Final position of dad in the shop
    var dadfinalposx= -6.25+0.03;
    var dadfinalposy=-20.54+0.02;

    if (gamestart==GameStart.lowercity&&OPENWORLD.Time.isSunRiseSet(OPENWORLD.Time.time)) {

      var shopperinc = 0;
      var chatpicked = [];

      nextshopper()
      {
        var worldpos=OPENWORLD.Space.localToWorldObj(dad);
        if (OPENWORLD.You.getObjDistance(dad)<0.3&&OPENWORLD.Math.vectorDistance(THREE.Vector3( dadfinalposx, dadfinalposy,0), worldpos)<0.02) {
          print("added shopper");
          var fruitbuyer = shoppers[shopperinc % shoppers.length];
          _hotload.add(fruitbuyer);
          var ypos = -20.38 + OPENWORLD.Math.randFloatSpread(1.0);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              fruitbuyer, -5.84, ypos, 0, 2);
          OPENWORLD.Space.objTurn(fruitbuyer, -90);
          var customerrequests = [
            [
              "Shalom. I'm making lentil stew tonight. Can I have a lav of lentils?",
              "Here you go",
              180
            ],
            [
              "Those chickpeas look good. Can I have a half lav? Its 20 prutah isn't it?",
              "Thats right, Shalom",
              180
            ],
            [
              "Those green olives look a bit shrivelled. Ill give you 10 prutah for a kav.",
              "Will 15 prutah and a fig do?",
              95
            ],
            [
              "How many figs for a prutah?",
              "I'll give you 6 of these. They are very fresh",
              95
            ],
            [
              "Shalom. Can I have half a kav of black olives and half a kav of green olives?",
              "There you go. The black olives we just go in this morning",
              45
            ],
            [
              "My son has a cold. Might get some of that mint. Do you have date honey?",
              "Sorry, we should have some tomorrow. Here's the mint",
              105
            ],
            [
              "Can I have quarter kav of dried figs, dates, and raisins. How much would that be?",
              "15 prutah. There you go",
              180
            ],
            [
              "That fig looks good. How much for that one?",
              "2 prutah. Shalom",
              95
            ],
            [
              "I'd like a quarter kav black olives. How much for that?",
              "For you, 10 prutah. Shalom",
              45
            ],
          ];

          // So don't repeat the same every time
          if (chatpicked.length == customerrequests.length) {
            chatpicked.clear();
          }
          var picked = OPENWORLD.Math.randInt(
              customerrequests.length, exclude: chatpicked);
          chatpicked.add(picked);
          List chat = customerrequests[picked];
          var numlines = OPENWORLD.Mob
              .chopText(chat[0])
              .length +
              OPENWORLD.Mob
                  .chopText(chat[1])
                  .length;
          var customertime = numlines * 6;

          OPENWORLD.Mob.moveToLoop(
              fruitbuyer,
              [
                {"p": [-5.84, ypos, 0], "v": girlspeed},
                {
                  "p": [-6.1, -20.5, -0.01],
                  "v": girlspeed,
                  "callback": (actor) async {
                    var time = await OPENWORLD.Mob.setSpeech(
                      actor,
                      OPENWORLD.Mob.chopText(chat[0]),
                      z: 80,
                      width: 300,
                      clearwhendone: true,
                      minwait: 6,
                      scale: 0.3,
                      randwait: 0,
                    );
                    OPENWORLD.Space.objTurnLerp(
                        dad, chat[2], 1, delay: time + 1);
                    OPENWORLD.Space.objTurnLerp(
                        dad, 90, 1, delay: time + 2);
                    OPENWORLD.Actor.playActionThen(
                        dad, "push", "idle3",
                        duration: 3,
                        delay: time + 3);
                    OPENWORLD.Actor.playActionThen(
                        actor, "push", "idle3",
                        duration: 3,
                        delay: time + 3.5);
                    OPENWORLD.Space.objTurnLerp(
                        actor, 270, 1, delay: 1);
                    OPENWORLD.Actor.playActionThen(
                        actor,
                        OPENWORLD.Math.randPick(["wave", "point", "nod"]),
                        "idle3",
                        duration: 3);

                    var time2 = await OPENWORLD.Mob.setSpeech(
                        dad,
                        OPENWORLD.Mob.chopText(chat[1]),
                        z: 80,
                        width: 300,
                        clearwhendone: true,
                        minwait: 6,
                        scale: 0.3,
                        randwait: 0,
                        delay: time);
                    var goodbyes = [
                      "Shalom Aleichem",
                      "Puk b'shlama",
                      "Shalom"
                    ];
                    OPENWORLD.Mob.setSpeech(
                        actor,
                        [OPENWORLD.Math.randPick(goodbyes)],
                        z: 80,
                        width: 300,
                        clearwhendone: true,
                        minwait: 6,
                        scale: 0.3,
                        randwait: 0,
                        delay: time2 - 1);
                    if (OPENWORLD.Math.random() < 0.3) {
                      OPENWORLD.Actor.playActionThen(
                          dad, "wave", "idle3",
                          duration: 3,
                          delay: time2 + 2);
                    }
                  }
                },
                // {"p": [-6.20 - 0.02, -20.45 - 0.01, -0.01], "v": girlspeed},
                // {"action": "point", "time": 1, "t": 270, "duration": 2.0},
                {"action": "idle3", "time": customertime + 3.0, "t": 270},
                // {"action": "work", "time": 20, "t": 270, "duration": 2.0},
                {"p": [-6.1, -20.5, 0], "v": girlspeed},
                {
                  "p": [-5.84, ypos, 0],
                  "v": girlspeed,
                  "callback": (actor) {
                    OPENWORLD.Space.removeObjFromHide(fruitbuyer);
                    fruitbuyer.visible = false;
                  }
                },
              ],
              looptype: OPENWORLD.Mob.LoopTypeStop,
              action: "walk");
          shopperinc++;
        }
      }// end next shopper

      var timer;
      OPENWORLD.Room.setDistanceTrigger(
          roomShop,
          maxy: -20.44,
          miny: -20.61,
          minx: -6.54,
          maxx: -6.20,
          event: (action) {
            if (action) {
              print("in shop");
              setState(() {
                roomname = 'Your shop';
              });
              nextshopper();
              timer = Timer.periodic(const Duration(seconds: 50), (timer) {
                nextshopper();

              });
            } else {
              print("out shop");
              setState(() {
                roomname = '';
              });
              timer.cancel();
            }
          });

    }

    // need this here so you can open the door in reachshop
    var doorhouse2shop=doorhouse2.clone();


    inshop()
    {
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          dad, dadfinalposx,dadfinalposy,0,4);// -6.25+0.03, -20.54+0.02,0,4);// -6.56, -20.58,0.025,2);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
      OPENWORLD.Actor.playAction(dad, action: "idle3",randomduration: 0.1);;
      OPENWORLD.Space.objTurn(dad, 90);
      OPENWORLD.Mob.setSpeech(dad, ["Lets hope we get a lot","of customers today"], z: 90,
        scale: 0.4,
        minwait: 5,
        randwait: 0,
        width: 300,
        clearwhendone:  true,
        // delay: 6+2+5
      );

    }

    //inshop();

    // Where dad unpacks the donkey and then goes into the shop
    reachshop()
    {
      donkeypackbuckets.extra['followdad'] = false;
      dad.extra['followdad'] = false;
      // Back of shop outside
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          dad,-6.54-0.02,-20.44,0,2);;
        //  dad
      OPENWORLD.Actor.playAction(dad, action: "idle");;
      OPENWORLD.Space.faceObjectLerp(dad, threeJs.camera, 1.0, delay:1);

      // Put donkey south of dad
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkeypackbuckets,-6.54-0.02,-20.44-0.07,0,2);;
      OPENWORLD.Actor.playAction(donkeypackbuckets, action: "idle");;
      OPENWORLD.Space.objTurn(donkeypackbuckets, 0);

      putonpack();

      var friendpos = OPENWORLD.Space.localToWorldObj(dad);
      OPENWORLD.Mob.moveTo(
          dad, [
         [friendpos.x, friendpos.y, 0, pilgrimspeed],
        [ -6.62+0.03, -20.42,0,pilgrimspeed],
        [-6.62+0.03, -20.49, 0, pilgrimspeed],
      ], action: "walk",
          stopaction: "idle",
          delay:5,
          callbackonfinish: (actor)
          {
            OPENWORLD.Actor.playAction(donkeypackbuckets, action: "idle");;

            OPENWORLD.Space.faceObjectLerp(dad, donkeypackbuckets,1);
             OPENWORLD.Actor.playAction(dad, action: "work");;
             Future.delayed(Duration(milliseconds: 6000), () async {
               print("finished work on pack");


               donkeypackbuckets.extra['packdonkeybucketswield'].visible=false;
               OPENWORLD.Actor.playAction(donkeypackbuckets, action: "idle",delay:1);;
               OPENWORLD.Actor.playAction(dad, action: "stoopidle");;
               donkeypackbuckets.extra['packdonkeybuckets'].visible=true;
               packdonkeybuckets.scale.setValues(0.002 , 0.002, 0.002);
               OPENWORLD.BaseObject.setVisible(
                   packdonkeybuckets, true, groupname: "figs");
               OPENWORLD.BaseObject.setVisible(
                   packdonkeybuckets, true, groupname: "apples");
               OPENWORLD.Space.worldToLocalSurfaceObjHide(
                   donkeypackbuckets.extra['packdonkeybuckets'],-6.54-0.02,-20.44-0.07,0.06,2);// -6.56, -20.58,0.025,2);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);

               OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                   donkeypackbuckets.extra['packdonkeybuckets'], -6.63, -20.52,0.025,0.8);//,delay:0.8);// -6.56, -20.58,0.025,2);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
               OPENWORLD.Space.objTurn(donkeypackbuckets.extra['packdonkeybuckets'], 90);
               OPENWORLD.Space.objTurnLerp(dad, -90,1);
               OPENWORLD.Space.objTurnLerp(doorhouse2shop, -90,1);
               OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                   donkeypackbuckets.extra['packdonkeybuckets'], -6.47, -20.55,0.025,2,delay:4.5);// -6.56, -20.58,0.025,2);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
               OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                  donkeypackbuckets.extra['packdonkeybuckets'], -6.47, -20.55+0.03,0.025,2,delay:4.5+2);// -6.56, -20.58,0.025,2);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
               OPENWORLD.Space.objTurnLerp(dad, 90,1,delay:4);
               OPENWORLD.Actor.playActionThen(dad, "push","walk",delay:5);

               OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                   dad, -6.54-0.04, -20.56-0.01,0,4,delay:5.5);//  -6.56, -20.58 -6.56, -20.58,0.025,2);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);

               OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                   dad,  -6.25+0.03, -20.54+0.02,0,4,delay:5.5+4);// -6.56, -20.58,0.025,2);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
//-6.25, -20.54
               OPENWORLD.Actor.playAction(dad, action: "idle3",delay:11);;

               if (OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, dad)<0.6) {
                 OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                     threeJs.camera, -6.56, -20.54,//8,
                     OPENWORLD.Camera.cameraoffset, 4,
                     delay: 11);
                 // This is your final spot where you serve
                 OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                     threeJs.camera,  -6.29, -20.46,// -6.27, -20.46,// -6.24, -20.45,  //-6.29+0.07, -20.47
                     OPENWORLD.Camera.cameraoffset, 4, delay: 11 +
                     4); // -6.56, -20.58,0.025,2);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
                 OPENWORLD.Space.faceObjectLerp(
                     threeJs.camera, dad, 1, delay: 8);
                 OPENWORLD.Space.objTurnLerp(threeJs.camera, 121.96, 1, delay: 15); //90
                 Future.delayed(Duration(milliseconds: 20000), () async {
                   // All this seems to do is place dad
                   inshop();
                 });
               }

               /*donkeypackbuckets.extra['packdonkeybucketswield'].visible=true;
               OPENWORLD.Actor.wield(
                   dad,donkeypackbuckets.extra['packdonkeybucketswield'], "Bip01_R_Hand",
                   delay: 4);
               OPENWORLD.BaseObject.setVisible(donkeypackbuckets.extra['packdonkeybuckets'],false,delay:4);*/

               /* OPENWORLD.Mob.moveTo(
                   dad, [
                   [ -6.62+0.03, -20.42,0,pilgrimspeed],
               [-6.62+0.03, -20.49, 0, pilgrimspeed],*/

               });

          }

      );

    }
    if (gamestart == GameStart.lowercity &&
        gamestartpos[gamestart]['progress'].contains('reachshop')) {
      print("restart reachshop");
      OPENWORLD.Space.objTurn(dad, 0);
      OPENWORLD.Space.objTurn(donkeypackbuckets, 0);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          dad,-6.54-0.02,-20.44, 0,
          2); //-11.42, -42.38+0.2, 0, 2); //-17.42, -45.17 - 0.05
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          donkeypackbuckets, -6.54-0.02,-20.44-0.07, 0,
          //-11.42, -42.38+0.1, 0,
          2); //-16.98, -45.23, 0, 2);

      Future.delayed(Duration(milliseconds: 10000), () async {
        reachshop();
      });
    } else {
      //  Outside house and now walk all the  way to the shop
      lefthome() {
        saveGameState('lefthome');

        doorhouse2.extra['disabled'] = false;

        dad.extra['followdad'] = true;
        donkeypackbuckets.extra['followdad'] = true;
        OPENWORLD.Actor.playAction(donkeypackbuckets, action: "walk", delay: 2);
        OPENWORLD.Space.faceObjectLerp(threeJs.camera, dad, 1, delay: 6);

        var talkinc;
        if (!gamestartpos[gamestart]['progress'].contains('pilgrim1'))
          talkinc = 0;
        else if (!gamestartpos[gamestart]['progress'].contains('pilgrim2'))
          talkinc = 2;
        else if (!gamestartpos[gamestart]['progress'].contains('pilgrim3'))
          talkinc = 3;
        else if (!gamestartpos[gamestart]['progress'].contains('pilgrim4'))
          talkinc = 4;
        else
          talkinc = 5;

        var dadspeech = [
          "I hope Simons cold gets better. But he doesn't like mint. Might have to go to the apothecary and get some date honey. Then he'll take it",
          "I'm not sure we should go to the theatre. With the zealots always outside our shop and they find out... I don't want to get a sicae in the stomach... But if the soldier returns and asks how we liked the theatre he'll be offended. Perhaps we should just say our son Simon really wanted to go but he is ill right now. Could be a good excuse",
          "Look, our donkey isn't limping at all anymore - that was a scare - thought we might need to carry the goods ourselves this morning. Imagine carrying all this up Pilgrims Road",
          "Your mum is making salted fish stew with lentils tonight isn't she? Can't wait. She hasn't made it for ages",
          "I think we should get some flour at Esra's bakery on the way back. I think he wants some figs so he'll be happy to trade",
          "Do you think we should hold off getting more dates for the shop? My cousin Saul is coming to the market next week. He always gives me a good discount.",
          "I hope Yohanan doesn't come into our shop again. He does buy a lot but half the time he comes back claiming a fig he bought was bruised and wants a refund even though he's eaten half of it. Might have to tell him to go somewhere else."
        ];

        talkToWife(actor) {
          Future.delayed(Duration(milliseconds: 1000), () async {
            var turn = OPENWORLD.Space.getObjTurn(actor);
            OPENWORLD.Space.objTurnLerp(actor, turn + 45, 1.0);
            OPENWORLD.Space.objTurnLerp(actor, turn, 1.0, delay: 12);
            OPENWORLD.Actor.playAction(actor, action: "walkstraightlookright");
            ;
            //  OPENWORLD.Actor.playAction(actor, action: "walkstraightlookright");;
            //  OPENWORLD.Actor.playActionThen(actor, "walkstraightlookright", "walk",duration:4);
            if (talkinc < dadspeech.length) {
              var lines;
              var dist=OPENWORLD.You.getObjDistance(dad);
              if (dist<1)
                  lines= OPENWORLD.Mob.chopText(dadspeech[talkinc]);
              else
                 lines=["Wheres my wife?"];
              talkinc++;
              OPENWORLD.Mob.setSpeech(actor, lines, z: 90,
                scale: 0.4,
                minwait: 5,
                randwait: 0,
                width: 300,
                clearwhendone: dist<1,// true,
                // delay: 6+2+5
              );
            }
          });
        }

//-17.33, -45.20

        /*{"action":"idle","time":25,
          'callback':(actor) {
            donkeypackbuckets.extra['followdad']=true;
            OPENWORLD.Actor.playAction(donkeypackbuckets, action: "walk",delay:2);
            OPENWORLD.Space.faceObjectLerp( threeJs.camera, dad, 1,delay:6);

          }

        },*/
        var friendpos = OPENWORLD.Space.localToWorldObj(dad);
        List<Map> actionsdad = [
          {"p": [friendpos.x, friendpos.y, 0], "v": pilgrimspeed}
        ];
        if (!gamestartpos[gamestart]['progress'].contains('pilgrim1')) {
          actionsdad.add({"p": [-17.35, -45.52, 0], "v": pilgrimspeed, "callback":(actor){
            OPENWORLD.Mob.setSpeech(dad,["Off for a long day"], z: 90,
              scale: 0.4,
              minwait: 5,
              randwait: 0,
              width: 300,
              clearwhendone:  true,
              // delay: 6+2+5
            );
          }
          });// outside house
          actionsdad.add({"p": [-16.06, -45.83, 0], "v": pilgrimspeed});
          actionsdad.add({"p": [-16.06, -46.02, 0], "v": pilgrimspeed});
          actionsdad.add({"p": [-15.22, -46.20, 0], "v": pilgrimspeed});
          actionsdad.add({
            "p": [-15.14, -46.35, 0],
            "v": pilgrimspeed,
            "callback": talkToWife
          });
          actionsdad.add({"p": [-14.24, -46.52, 0], "v": pilgrimspeed});
          actionsdad.add({
            "p": [-14.00, -46.41, 0],
            "v": pilgrimspeed,
            "callback": talkToWife
          });
          actionsdad.add({"p": [-12.81, -46.63, 0], "v": pilgrimspeed, // near pilgrims road
            "callback": (actor) {
              OPENWORLD.Space.faceObjectLerp(threeJs.camera, dad, 1, delay: 3);

//              OPENWORLD.Space.objTurnLerp(threeJs.camera, dad, 1);
            }
          });
          actionsdad.add({
            "p": [-12.76, -46.04, 0],
            "v": pilgrimspeed,
            "callback":(actor){
              saveGameState('pilgrim1');
            }
          }); // still on path to pilgrims road
        }
        if (!gamestartpos[gamestart]['progress'].contains('pilgrim2')) {
          actionsdad.add({
            "p": [-12.00 - 0.06, -46.14, 0],
            "v": pilgrimspeed
          }); // on pilgrims road
          actionsdad.add({"p": [ -12.10 - 0.06, -44.97, 0], "v": pilgrimspeed});
        }


        var inc = 0;
        for (var pos in citizenessenpath.reversed) {
          if (pos[1] > -44.97 && pos[1] < -22 &&
              (!gamestartpos[gamestart]['progress'].contains('pilgrim2') ||
                  (gamestartpos[gamestart]['progress'].contains('pilgrim2') &&
                      pos[1] > -42)) &&
              (!gamestartpos[gamestart]['progress'].contains('pilgrim3') ||
                  (gamestartpos[gamestart]['progress'].contains('pilgrim3') &&
                      pos[1] > -36)) &&
              (!gamestartpos[gamestart]['progress'].contains('pilgrim4') ||
                  (gamestartpos[gamestart]['progress'].contains('pilgrim4') &&
                      pos[1] > -33)) &&
              (!gamestartpos[gamestart]['progress'].contains('pilgrim5') ||
                  (gamestartpos[gamestart]['progress'].contains('pilgrim5') &&
                      pos[1] > -26))
          ) {
            var action = {
              "p": [pos[0] - 0.05, pos[1], 0],
//              "p": [pos[0] - 0.05, pos[1], 0],
//            "p": [pos[0] - 0.06, pos[1], 0],
              "v": pilgrimspeed * 1.5};
            if (inc % 2 == 0)
              action["callback"] = talkToWife;
            else if (pos[1]>-42&&!gamestartpos[gamestart]['progress'].contains('pilgrim2'))
              action["callback"]=(actor){
                saveGameState('pilgrim2');
              };
            else if (pos[1]>-36&&!gamestartpos[gamestart]['progress'].contains('pilgrim3'))
              action["callback"]=(actor){
                saveGameState('pilgrim3');
              };
            else if (pos[1]>-33&&!gamestartpos[gamestart]['progress'].contains('pilgrim4'))
              action["callback"]=(actor){
                saveGameState('pilgrim4');
              };
            else if (pos[1]>-26&&!gamestartpos[gamestart]['progress'].contains('pilgrim5'))
              action["callback"]=(actor){
                saveGameState('pilgrim5');
              };
            actionsdad.add(action);
            inc++;
          } //pilgrimspeed});
        }
        actionsdad.add(
            {"p": [-6.01, -21.4, 0], "v": pilgrimspeed}); //pilgrimspeed});
        actionsdad.add({
          "p": [-6.59 - 0.03, -21.4, 0],
          "v": pilgrimspeed
        }); //pilgrimspeed});
        actionsdad.add({"p": [-6.54 - 0.02, -20.44, 0], "v": pilgrimspeed,  // this is back of the shop outside
          'callback': (actor) {
            saveGameState('reachshop');
            reachshop();
          }
        }); //pilgrimspeed});

        // print("actionsdad"+actionsdad.toString());
        OPENWORLD.Mob.moveToLoop(
            dad, actionsdad, action: "walk",
            surfaceonly: true,
            looptype: OPENWORLD.Mob.LoopTypeStop
          //    stopaction: "idle",
          //      delay:10

        );
      }

      if (gamestart == GameStart.lowercity &&
          gamestartpos[gamestart]['progress'].contains('lefthome')) {
        OPENWORLD.Space.objTurnLerp(doorhouse2, 90, 1);
        OPENWORLD.Actor.playAction(dad, action: "idle");
        putonpack();
        var usedict = getusedict();
        // Placement of dad based upon your progress
        if (!gamestartpos[gamestart]['progress'].contains('pilgrim1')) {
          // Place dad outside home
          print("restart left home");
          OPENWORLD.Space.objTurn(dad, 180);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              dad, -17.39, -45.19, 0, 2); //-17.42, -45.17 - 0.05
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              donkeypackbuckets, -17.42, -45.17 - 0.05, 0,
              2); //-16.98, -45.23, 0, 2);
        } else if (!gamestartpos[gamestart]['progress'].contains('pilgrim2')) {
          print("restart pilgrim1");
          OPENWORLD.Space.objTurn(dad, 0);
          OPENWORLD.Space.objTurn(donkeypackbuckets, 0);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              dad, -12.00 - 0.06, -46.14 - 0.1, 0, 2); //-17.42, -45.17 - 0.05
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              donkeypackbuckets, -12.00 - 0.06, -46.14 - 0.2, 0,
              2); //-16.98, -45.23, 0, 2);
        } else if (!gamestartpos[gamestart]['progress'].contains('pilgrim3') ||
            !gamestartpos[gamestart]['progress'].contains('pilgrim4') ||
            !gamestartpos[gamestart]['progress'].contains('pilgrim5') ||
            !gamestartpos[gamestart]['progress'].contains('reachshop')
        ) {
          print("restart pilgrim2 or 3 or 4 or 5"+usedict['p'][0].toString()+" "+ usedict['p'][1].toString());
          OPENWORLD.Space.objTurn(dad, 0);
          OPENWORLD.Space.objTurn(donkeypackbuckets, 0);
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              dad, usedict['p'][0], usedict['p'][1] + 0.2, 0,
              2); //-11.42, -42.38+0.2, 0, 2); //-17.42, -45.17 - 0.05
          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              donkeypackbuckets, usedict['p'][0], usedict['p'][1] + 0.1, 0,
              //-11.42, -42.38+0.1, 0,
              2); //-16.98, -45.23, 0, 2);
        }
        Future.delayed(Duration(milliseconds: 15000), () async {
//        Future.delayed(Duration(milliseconds: 20000), () async {
          lefthome();
          // reachshop();
        });
      } else {

        // Youve packed the donkey and are leaving home and go outside
        leavehome() {
          saveGameState('leavehome');

          OPENWORLD.Space.worldToLocalSurfaceObjHide(
              dad, -16.90, -45.25, 0, 2);

          OPENWORLD.Mob.moveTo(
              donkeypackbuckets, [
            [ -16.98, -45.23, 0, pilgrimspeed],
          ], action: "walk",
              stopaction: "idle"
          );

          OPENWORLD.Space.objTurnLerp(doorhouse2, 90, 1);
          doorhouse2.extra['disabled'] = true; // keep the door open while everyone comes out
          OPENWORLD.Actor.playAction(dad, action: "idle");

          OPENWORLD.Space.faceObjectLerp(dad, threeJs.camera, 1, delay: 5);

          OPENWORLD.Mob.setSpeech(dad, [
            "Lets get going",
            "I think we've got everything"
          ], z: 80,
            scale: 0.3,
            minwait: 5,
            randwait: 0,
            width: 300,
            clearwhendone: true,
            //  delay: 5
          );
          putonpack();

          // This is outside - this is for the donkey
          OPENWORLD.Mob.moveTo(
              donkeypackbuckets, [
            [-17.42, -45.17 - 0.05, 0, pilgrimspeed],
          ], action: "walk",
              stopaction: "idle",
              delay: 10

          );

          // Dad walks outside
          dad.extra['followdad'] = true;
          OPENWORLD.Mob.moveTo(
              dad, [[-17.39, -45.19, 0, pilgrimspeed]],
              action: "walk",
              stopaction: "idle",
              delay: 10,
              callbackonfinish: (actor) {
                // Family goes outside to say goodbye
                OPENWORLD.Mob.moveTo(
                    son, [
                  [ -16.81, -45.23, 0, pilgrimspeed * 2],
                  [-17.27, -45.21, 0, pilgrimspeed]
                ], action: "walk",
                    surfaceonly: true,
                    stopaction: "idle",
                    delay: 5 - 5,
                    callbackonfinish: (actor) {
                      OPENWORLD.Mob.setSpeech(son, [
                        "Bye Mum and Dad",
                      ], z: 90,
                        scale: 0.4,
                        minwait: 5,
                        randwait: 0,
                        width: 300,
                        clearwhendone: true,

                        //   delay: 7+4
                      );
                      OPENWORLD.Actor.playActionThen(
                          son, "wave", "idle"); //,delay:7+4);

                    }
                );

                OPENWORLD.Mob.moveTo(
                    daughter, [
                  [ -16.81, -45.23, 0, pilgrimspeed * 2],
                  [-17.32, -45.25 + 0.01, 0, pilgrimspeed]
                ], action: "walk",
                    surfaceonly: true,
                    stopaction: "idle",
                    callbackonfinish: (actor) {
                      OPENWORLD.Actor.playActionThen(
                          daughter, "wave", "idle"); //,delay:8+4);

                    },
                    delay: 6 - 5

                );

                OPENWORLD.Mob.moveTo(
                    grandma, [
                  [ -16.81, -45.23, 0, pilgrimspeed * 2],
                  [-17.23, -45.23, 0, pilgrimspeed]
                ], action: "walk",
                    surfaceonly: true,
                    stopaction: "idle",
                    callbackonfinish: (actor) {
                      OPENWORLD.Actor.playActionThen(
                          grandma, "wave", "idle"); //,delay:12+4);
                      OPENWORLD.Mob.setSpeech(grandma, [
                        "Bye",
                      ], z: 90,
                          scale: 0.4,
                          minwait: 5,
                          randwait: 0,
                          width: 300,
                          clearwhendone: true); //,
                      // delay: 9+4
                      //  );

                    },
                    delay: 7 - 5

                );
                Future.delayed(Duration(milliseconds: 2000), () async {
                  //{"p": [-17.39, -45.19, 0], "v": pilgrimspeed,"callback":(actor){
                  //  OPENWORLD.Actor.playAction(dad, action: "idle");;

                  OPENWORLD.Space.worldToLocalSurfaceObjLerp(
                      threeJs.camera, -17.54, -45.29,
                      OPENWORLD.Camera.cameraoffset, 1.0);
                  OPENWORLD.Space.objTurnLerp(doorhouse2, 90, 1, delay: 2);
                  OPENWORLD.Space.faceObjectLerp(
                      threeJs.camera, dad, 1, delay: 3);

                  //   OPENWORLD.Space.objTurnLerp(threeJs.camera, 90, 1);
                  OPENWORLD.Space.faceObjectLerp(
                      dad, threeJs.camera, 1, delay: 2);
                  OPENWORLD.Space.faceObjectLerp(dad, son, 1, delay: 6);
                  OPENWORLD.Mob.setSpeech(dad, [
                    "Shalom",
                  ], z: 90,
                      scale: 0.4,
                      minwait: 5,
                      randwait: 0,
                      width: 300,
                      clearwhendone: true,
                      delay: 6 + 2 + 5
                  );
                  OPENWORLD.Actor.playActionThen(
                      dad, "wave", "idle", delay: 7 + 5);
                  OPENWORLD.Actor.playActionThen(
                      dad, "wave", "idle", delay: 15);

                  //  }
                  // },
                  Future.delayed(Duration(milliseconds: 25000), () async {
                    lefthome();
                  });
                });
              });
        }

        if (gamestart == GameStart.lowercity &&
            gamestartpos[gamestart]['progress'].contains('leavehome')) {
          print("restart leave home");
          OPENWORLD.Actor.playAction(dad, action: "idle");
          OPENWORLD.Space.worldToLocalSurfaceObjHide(dad, -16.90, -45.25, 0, 2);

          callwhenloaded(() {
            leavehome();
          });

        } else {
          // The meal is finished so dad packs the donkey
          finishedmeal() {
            print("finished meal");
            saveGameState('finishedmeal');
            OPENWORLD.Space.worldToLocalSurfaceObjHide(
                dad, -16.80, -45.36, 0, 2);
            ; // centerx+(-17.74-centerx)*0.5,centery+( -45.58-centery)*0.5,0.0,3);//-13.53, 63.52,0,3);//-13.51, 64.25, 0.0, 3); //3.42);

            OPENWORLD.Mob.setSpeech(dad, [
              "That was good",
              "I'll start packing.",
              "I'll get the figs and apples"
            ], z: 80,
              scale: 0.4,
              minwait: 5,
              randwait: 0,
              width: 300,
              callbackonfinish: (actor) {
                OPENWORLD.Actor.unwield(dad, "Bip01_L_Hand",);
              }
              //  clearwhendone: true,
              //  delay: 5
            );

            OPENWORLD.Mob.moveToLoop(
                dad,
                [
                  {"action": "squat", "time": 8},
                  {"p": [-16.86, -45.14, 0], "v": pilgrimspeed},
                  {"action": "stoopidle", "time": 4},
                  {"action": "work", "time": 4, "t": 45},
                 // {"action": "stoopidle", "time": 4, "t": 270},
                 // {"action": "work", "time": 8, "t": 45},
                  {"action": "stoopidle", "time": 4, "t": 270 + 45,
                    "callback": (actor) {
                      OPENWORLD.BaseObject.setVisible(
                          packdonkeybuckets, true, groupname: "apples");
                    }
                  },
                  {"action": "work", "time": 8, "t": 45},
                  {"action": "stoopidle", "time": 4, "t": 270,
                    "callback": (actor) {
                      OPENWORLD.BaseObject.setVisible(
                          packdonkeybuckets, true, groupname: "figs");
                    }
                  },
                  {"action": "work", "time": 8, "t": 45},
                  {"action": "stoopidle", "time": 4, "t": 270 + 45},
                 // {"action": "work", "time": 8, "t": 45},
                //  {"action": "stoopidle", "time": 4, "t": 270},
                //  {"action": "work", "time": 8, "t": 45},
                //  {"action": "stoopidle", "time": 4, "t": 270 + 45},
                  {"action": "work", "time": 8, "t": 45},
                  {"action": "stoopidle", "time": 4, "t": 270},
                  {"action": "work", "time": 4, "t": 270,
                    "callback": (actor) {
                      // put the pack on the donkey
                      putonpack();
                      OPENWORLD.Mob.moveTo(
                          donkeypackbuckets, [
                        [ -16.98, -45.23, 0, pilgrimspeed],
                      ], action: "walk",
                          stopaction: "idle",
                          delay: 2

                      );

                      //OPENWORLD.Space.objTurn(packdonkey, 90);
                    },


                  },
                  {"p": [-16.90, -45.25, 0], "v": pilgrimspeed,
                    'callback': (actor) {
                      OPENWORLD.Space.faceObjectLerp(threeJs.camera, dad, 1);
                      leavehome();
                    }
                  },

                ]
                //,267]//-16.63, -45.00,0,pilgrimspeed,291]//-16.89, -45.30,0,pilgrimspeed,134]
                , action: "walk",
                looptype: OPENWORLD.Mob.LoopTypeStop
              //     stopaction: "idle",
              //   delay:10
            );
          }

          if (gamestart == GameStart.lowercity &&
              gamestartpos[gamestart]['progress'].contains('finishedmeal')) {
            print("start finished meal");
            //  var dictfinishedmeal=gamestartpos[gamestart]['finishedmeal'];
            //  setPlayerPos(dictfinishedmeal);
            finishedmeal();
          }

          // When player on roof at lowercity and first moves to get up - husband gets up too
          firstmovelowercity() async {
            print("voot has moved");
            // cheat to make you rise - this is all it does
          //  OPENWORLD.Space.setZLerp(threeJs.camera, Glob.defaultcameraoffset*0.75, 1,level: 2);
            var tick = 0;
            Timer.periodic(const Duration(milliseconds: 100), (timer) async {
              var lerp = tick / 20.0;
              var offset = Glob.defaultcameraoffset * (0.25 + 0.5 * lerp);
              print("lowercity offset" + lerp.toString() + " offet" +
                  offset.toString());
              OPENWORLD.Camera.cameraoffset = offset;
              OPENWORLD.Space.setZ(threeJs.camera, offset, level: 2);
              //     SecondTemplePageState.defaultcameraoffset * 0.25;
              // OPENWORLD.Camera.cameraoffset =
              //     SecondTemplePageState.defaultcameraoffset * 0.75;
              if (tick == 20)
                timer.cancel();
              tick++;
            });

            OPENWORLD.Actor.playActionThen(dad, "kneel", "squatwork", delay: 2);
            OPENWORLD.Space.faceObjectLerp(dad, threeJs.camera, 1, delay: 2);
            // OPENWORLD.Actor.playActionThen(citizenf3iv, "laysideidle", "squatwork",delay:2);

            //  OPENWORLD.Actor.playActionThen(citizenf3iv, "laysideidle", "kneel",delay:2);
            //  OPENWORLD.Actor.playAction(citizenf3iv, action: "squatwork");
            OPENWORLD.Space.objPitch(dad, 0);
            // Check if you are looking at your husband
            //var ticks = 0;
            callwhentrue(() {
             return   OPENWORLD.You.isfacing(dad, 45) && OPENWORLD.You.level == 2;
             },delay:6,() {
              //  });
              //Timer.periodic(const Duration(seconds: 1), (timer) async {
              //   if (ticks > 6 && OPENWORLD.You.isfacing(dad, 45) && OPENWORLD.You.level == 2) {
              print("callwhentrue is true");
              OPENWORLD.Space.readdObjFromHide(
                  stairsdownicon); // So that only show E to go down stairs once have got up
              stairsdownicon.visible = true;
              var pos = OPENWORLD.Space.localToWorldObj(dad);
              OPENWORLD.Space.worldToLocalSurfaceObjHide(
                  dad, pos.x, pos.y, 0.00, 2,
                  level: 2); //centerx+(-17.27-centerx)*0.5, centery+(-45.26-centery)*0.5,0.0);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
           //   OPENWORLD.Space.faceObjectLerp(dad, threeJs.camera, 1);
              OPENWORLD.Space.faceObjectAlways(dad, threeJs.camera);
             // timer.cancel();
               OPENWORLD.Actor.playAction(dad, action: "squat", duration: 4);
             // OPENWORLD.Actor.playAction(dad, action: "squatup", duration: 4);
              //OPENWORLD.Actor.playActionThen(dad,  "squat","idle",duration:2);
              OPENWORLD.Mob.setSpeech(dad, [
                'Good morning my love',
                'Long day ahead',
                "Let's get everything ready"
              ], z: 50,
                  //   y:-10,
                  scale: 0.2,
                  minwait: 5,
                  randwait: 0,
                  width: 300,
                  clearwhendone: true,
                  delay: 1,
                  callbackonfinish: (actor) {
                    // now dad goes down stair from roof
                    OPENWORLD.Space.removeFaceObjectAlways(dad);
                    var v = 0.02;
                    var friendpos = OPENWORLD.Space.localToWorldObj(dad);

                    OPENWORLD.Mob.moveToLoop(
                        dad, [
                      {"p": [friendpos.x, friendpos.y, 0], "v": v, "l": 2},
                      // top stairs
                      {"p": [-16.52, -45.46 - 0.02, 0], "v": v, "l": 2},
                      // top stairs
                      {
                        "p": [-16.58, -45.46 - 0.02, 0],
                        "v": v / 4,
                        "t": 90,
                        "l": 1,
                        "action": "climb"
                      },
                      // second floor
                      {"p": [-16.63, -45.34, 0], "v": v, "t": 30, "l": 1},
                      //-16.60, -45.36+0.02
                      {"action": "idle", "time": 1, "callback": (actor) {
                        // now at first floor
                        //Timer.periodic(
                        //    const Duration(seconds: 1), (timer) async {
                        callwhentrue(() {
                          return   OPENWORLD.You.isfacing(dad, 45) && OPENWORLD.You.level ==1;
                        },delay:6,() {
                       //   if (/*ticks > 6 &&*/ OPENWORLD.You.isfacing(dad, 45) &&
                       //       OPENWORLD.You.level == 1) {
                        //    timer.cancel();  // remember to delete it

                            // var time=
                            OPENWORLD.Mob.setSpeech(dad, [
                              'Hi kids', //Good morning kids',
                              'Rise and shine'
                            ], z: 80,
                                scale: 0.4,
                                minwait: 5,
                                randwait: 0,
                                width: 300,
                                //   clearwhendone: true,
                                callbackonfinish: (actor) {
                                  OPENWORLD.Sound.play(path: 'sounds/cough.mp3', volume: 0.1);
                                  OPENWORLD.Sound.play(path: 'sounds/cough.mp3', volume: 0.1,delay:10);
                                  OPENWORLD.Mob.setSpeech(son, [
                                    'Hi Dad!',
                                    'Morning Mum!',

                                  ], z: 80,
                                      scale: 0.4,
                                      minwait: 5,
                                      randwait: 0,
                                      width: 300,
                                      clearwhendone: true,
                                      callbackonfinish: (actor) {
                                        OPENWORLD.Mob.setSpeech(dad, [
                                          'Its time to get up'
                                        ], z: 90,
                                          scale: 0.4,
                                          minwait: 5,
                                          randwait: 0,
                                          width: 300,
                                          clearwhendone: true,
                                          // delay: 6//time+6
                                        );
                                      }
                                  );
                                  OPENWORLD.Actor.playActionThen(
                                      son, "kneel", "squat", duration: 4,
                                      delay: 4);
                                  OPENWORLD.Space.faceObjectLerp(
                                      son, dad, 1, delay: 4);

                                  OPENWORLD.Mob.setSpeech(daughter, [
                                    'Oh Dad', //Good morning kids',
                                    'I want to sleep a bit longer',
                                    //'',
                                    'Good morning Mum'
                                  ], z: 80,
                                    scale: 0.4,
                                    minwait: 5,
                                    randwait: 0,
                                    width: 300,
                                    clearwhendone: true,
                                    //delay:time
                                  );
                                  OPENWORLD.Actor.playActionThen(
                                      daughter, "kneel", "squat",
                                      duration: 4);
                                  // OPENWORLD.Actor.playAction(daughter, action:"squat",duration:4);
                                  OPENWORLD.Space.faceObjectLerp(
                                      daughter, dad, 1); //,delay:time);


                                  List<Map> kitchenpositions = [
                                    {"p": [-16.49, -45.3, 0], "v": v, "l": 1},
                                    // first floor
                                    {
                                      "p": [-16.49, -45.3 - 0.02, 0],
                                      "v": v / 8,
                                      "l": 0,
                                      "t": 270,
                                      "action": "climb"
                                    },
                                    // to ground floor
                                    {"p": [-16.71, -45.28, 0], "v": v}
                                    // doorway
                                  ];
                                  Future.delayed(
                                      Duration(milliseconds: 11000), () async {
                                    var friendpos = OPENWORLD.Space
                                        .localToWorldObj(dad);

                                    OPENWORLD.Mob.moveToLoop(dad, [
                                      {
                                        "p": [friendpos.x, friendpos.y, 0],
                                        "v": v,
                                        "l": 1
                                      },
                                      ...kitchenpositions,
                                      {"p": [-16.80, -45.36, 0], "v": v},
                                      {
                                        "action": "squatwork",
                                        "time": 1,
                                        "callback": (actor) {
                                          OPENWORLD.Space.objTurnLerp(
                                              actor, 267 - 180, 1);
                                          OPENWORLD.Sound.play(path: 'sounds/cough.mp3', volume: 0.1);
                                          OPENWORLD.Mob.setSpeech(son, [
                                            'Hi Grandma'
                                          ], z: 90,
                                            scale: 0.4,
                                            minwait: 5,
                                            randwait: 0,
                                            width: 300,
                                            clearwhendone: true,
                                          );
                                          OPENWORLD.Space.faceObjectLerp(
                                              son, grandma, 1);
                                          OPENWORLD.Space.objTurnLerp(
                                              son, 110, 1, delay: 5);

                                          OPENWORLD.Mob.setSpeech(grandma, [
                                            'Good morning.','Your cold doesnt sound','too good'
                                          ], z: 80,
                                              scale: 0.4,
                                              minwait: 5,
                                              randwait: 0,
                                              width: 300,
                                              clearwhendone: true,
                                              delay: 2
                                          );
                                          OPENWORLD.Space.faceObjectLerp(
                                              grandma, son, 1, delay: 2);
                                        }
                                      }
                                    ], action: "walk",
                                      looptype: OPENWORLD.Mob
                                          .LoopTypeStop,
                                      //stopaction: "squatwork",
                                      //callbackonfinish:(actor) ,
                                      //  delay: 11
                                    );
                                  });
                                  Future.delayed(
                                      Duration(
                                          milliseconds: 7000), () async {
                                    var friendpos = OPENWORLD.Space
                                        .localToWorldObj(son);
                                    OPENWORLD.Mob.moveToLoop(
                                      son, [
                                      {
                                        "p": [friendpos.x, friendpos.y, 0],
                                        "v": v,
                                        "l": 1
                                      },
                                      ...kitchenpositions,
                                      {"p": [-16.81, -45.40, 0], "v": v},
                                      {
                                        "action": "squatwork",
                                        "time": 1,
                                        "callback": (actor) {
                                          OPENWORLD.Space.objTurnLerp(
                                              actor, 110, 1);
                                        }
                                      }
                                      //,110],//291],//-16.67, -45.09  -16.76, -45.33,pilgrimspeed,204]
                                    ], action: "walk",
                                      looptype: OPENWORLD.Mob
                                          .LoopTypeStop,
                                      //    stopaction: "squatwork",

                                      // delay: 7
                                    );
                                  });
                                  Future.delayed(
                                      Duration(
                                          milliseconds: 14000), () async {
                                    var friendpos = OPENWORLD.Space
                                        .localToWorldObj(daughter);
                                    OPENWORLD.Mob.moveToLoop(
                                      daughter, [
                                      {
                                        "p": [friendpos.x, friendpos.y, 0],
                                        "v": v,
                                        "l": 1
                                      },
                                      ...kitchenpositions,
                                      {"p": [ -16.78, -45.26, 0], "v": v},
                                      {
                                        "p": [
                                          -16.73 + 0.02,
                                          -45.47 + 0.06,
                                          0
                                        ],
                                        "v": v
                                      },
                                      {
                                        "action": "squatwork",
                                        "time": 1,
                                        "callback": (actor) {
                                          OPENWORLD.Space.objTurnLerp(
                                              actor, 110 - 180, 1);
                                        }
                                      }
                                      //,110],//291-180]  //-16.77, -45.08
                                    ], action: "walk",
                                      looptype: OPENWORLD.Mob
                                          .LoopTypeStop,
                                      // stopaction: "squatwork",
                                      // callbackonfinish: (actor) {
                                      //  },
                                      //  delay: 14
                                    );
                                  });
                                }
                            );


                          });  // end call when true
                      //  });
                      }}
                    ], action: "walk", //walkup",//straight",
                        looptype: OPENWORLD.Mob.LoopTypeStop);
                  }

              );
            });


            /// Code is in firemove - firstmove?
            var siticon = await OPENWORLD.Sprite.makeTextSprite(
                'Sit', Colors.white, width: 200,
                sizeattentuation: true,
                scale: 0.02,
                paddingLeft: 5,
                paddingRight: 5);
            hotloadAdd(firsthotload, false, siticon);
            //  siticon.scale.setValues(0.04*0.6,0.02*0.4,1.0);
            siticon.scale.setValues(
                0.04 * 0.3, 0.02 * 0.4, 1.0);
            OPENWORLD.Space.worldToLocalSurfaceObjHide(
                siticon, sitposx, sitposy, 0.02,
                1); //-17.78, -44.81


            var ticksall = 0;
            var ticksvalid = 0;
            print("set started false");
            var started=false;


            Timer.periodic(
                const Duration(seconds: 1), (timer2) async {
              var worldpos = OPENWORLD.You.getWorldPos();
              if (!started&&OPENWORLD.Space.getDistanceBetweenObjs(threeJs.camera, dad) < 0.2) {
                OPENWORLD.Space.readdObjFromHide(siticon);
                siticon.visible = true;

              } else {
                OPENWORLD.Space.removeObjFromHide(siticon);
                siticon.visible = false;

              }
              if (OPENWORLD.Space.getDistanceBetweenObjs(
                  threeJs.camera, dad) < 0.2 &&  // 0.3 is a bit too far
                  OPENWORLD.You.isfacing(dad, 45) &&
                  OPENWORLD.You.level == 0 &&
                  worldpos.x < -16.67) {
                // This is where you sit down
                print("lower sit down"+ticksvalid.toString());
                var disttoseat = OPENWORLD.Math.vectorDistance(
                    worldpos,
                    THREE.Vector3(sitposx, sitposy, 0.0));
                if (ticksvalid == 5) {
                  print("in tickvalid 5");
                  OPENWORLD.Mob.setSpeech(dad, [
                    'Mmm, this looks good',
                    disttoseat > 0.1
                        ? 'Sit down my love'
                        : 'Im so hungry'
                  ], z: 60,
                    scale: 0.4,
                    minwait: 5,
                    randwait: 0,
                    width: 300,
                    //  clearwhendone: true,
                    //  delay: 5
                  );
                  OPENWORLD.Space.faceObjectLerp(
                      dad, threeJs.camera, 1, delay: 5);
                  //   OPENWORLD.Actor.playAction(citizen2iii,action:"squat");//, duration:2);
                  OPENWORLD.Space.objTurnLerp(
                      dad, 267 - 180, 1, delay: 9);
                  OPENWORLD.Actor.playActionThen(
                      dad, "squat", "squatwork", duration: 4,
                      delay: 5);
                } else if (!started&&(ticksvalid > 10 || disttoseat < 0.1)) {
                  print("ticks valid");
                  started=true;

                  Future.delayed(Duration(
                      milliseconds: 2000), () async { //7000

                    print("in eat bread");

                    eatbread(platelowercity, 20, bitetime:10);

                    OPENWORLD.Space.removeObjFromHide(siticon);
                    siticon.visible = false;

                    var family = [dad, daughter, son];
                    for (var member in family) {
                      var breadunleaven2ii = breadunleaven.clone();
                      OPENWORLD.Space.setTurnPitchRoll(breadunleaven2ii.children[0], 0, 90, -45); //35);
                      OPENWORLD.Space.objTurnLerp(
                          dad, 267 - 180, 1);

                      // OPENWORLD.Space.objRoll(pitchfork.children[0], 90);
                      //  OPENWORLD.Space.objTurn(pitchfork.children[0], 20 + 180);
                      breadunleaven2ii.position.z = 0.0; //-4.0;
                      breadunleaven2ii.position.y = 0.0; //5.0;
                      breadunleaven2ii.position.x = member == dad ? 5.0 : 9.0; //7.0;//4.0;
                      var wielddelay=20 +
                          OPENWORLD.Math.random() * 3;
                      OPENWORLD.Actor.wield(
                          member, breadunleaven2ii,
                          "Bip01_L_Hand",
                          delay: wielddelay );
                      if (member==son)
                        OPENWORLD.BaseObject.setVisible(plateson,false,groupname:"breadunleaven", delay:wielddelay);
                      else if (member==daughter)
                        OPENWORLD.BaseObject.setVisible(platedaughter,false,groupname:"breadunleaven", delay:wielddelay);
                      else if (member==dad)
                        OPENWORLD.BaseObject.setVisible(platedad,false,groupname:"breadunleaven", delay:wielddelay);


                      OPENWORLD.Camera.setPitch(-13);
                      var start = 36.0;
                      for (var i = 0; i < 10; i++) {
                        var rnd = OPENWORLD.Math.random() * 6;
                        start += rnd;
                        OPENWORLD.Actor.playActionThen(
                            member, "squateat", "squatwork",
                            delay: start);
//                            OPENWORLD.Actor.playActionThen(member,"squateat",  "squatwork",looprepetitions:1,delay:start);
                        if (member == son) {
                          OPENWORLD.Space.objTurnLerp(
                              son, 110 - 35, 1,
                              delay: start + 5);
                          OPENWORLD.Space.objTurnLerp(
                              son, 110, 1, delay: start + 8 +
                              OPENWORLD.Math.random() * 3);
                          // OPENWORLD.Space.faceObjectLerp(
                          //      child1iii, threeJs.camera, 1,
                          //      delay: start + 10);
                        } else if (member == dad) {
                          OPENWORLD.Space.objTurnLerp(
                              dad, 267 - 180 + 35, 1,
                              delay: start + 5);
                          OPENWORLD.Space.faceObjectLerp(
                              dad, threeJs.camera, 1,
                              delay: start + 8 +
                                  OPENWORLD.Math.random() * 3);
                        }
                        start += 10.0;
                      }
                  }

                    var chat = [
                      {1: 'Let me say the blessing.'},
                      {
                        1: 'Blessed is the LORD, God of Israel,'
                      },
                      {
                        1: 'who brings forth bread from the earth'
                      },
                      {1: ' '},
                      {1: ' '},
                      {
                        0: "Yesterday when I was with the goats near"
                      },
                      {
                        0: "at the kidron near the Benei Hezir tomb"
                      },
                      {
                        0: "they all ran away like they'd seen a ghost."
                      },
                      {
                        0: "I don't want to tend them around there anymore"
                      },
                      {0: ' '},
                      {
                        1: "Heh, might be why there is so much for them"
                      },
                      {1: "to eat around there."},
                      {
                        1: "They all get spooked by the spirits"
                      },
                      {1: "so no one takes their goats there."},
                      {1: ' '},
                      {
                        1: "Something funny happened yesterday."
                      },
                      {
                        1: "A roman soldier dropped one of his letters"
                      },
                      {1: "as he was leaving our shop."},
                      {1: "I ran after him to return it."},
                      {1: "He was so grateful he gave us "},
                      {
                        1: "tokens to see a play at Herod's theatre."
                      },
//                          {1: "tesserah/tokens to see a play at Herod's theatre."},
                      {
                        1: "But it might not be good for business"
                      },
                      {1: "to be seen around Romans."},
                      {1: "I think we should give it a miss"},
                      {1: ' '},
                      {
                        0: "But Dad, I've never been to the theatre."
                      },
                      {0: ' '},
                      {0: ' '},
                      {1: "Mmm, this is delicious"},
                    ];
                    // have you look at your companion - would be nice

                    var citizenmeetchatterarr = createChat(
                        chat);
                    var citizenmeetchatter = citizenmeetchatterarr[0];
                    var citizenmeet2chatter = citizenmeetchatterarr[1];
                    // Son coughing
                    OPENWORLD.Sound.play(path: 'sounds/cough.mp3', volume: 0.1, delay:10);
                    OPENWORLD.Actor.playActionThen(son, "squateat", "squatwork", delay:10); // simulate putting hands to mouth when cough
                   // OPENWORLD.Sound.play(path: 'sounds/cough.mp3', volume: 0.1, delay:30);
                   // OPENWORLD.Actor.playActionThen(son, "squateat", "squatwork", delay:30); // simulate putting hands to mouth when cough

                    OPENWORLD.Mob.setSpeech(son,
                        citizenmeetchatter
                        , z: 50,
                       x:-40,
                       // y:-30,
                        scale: 0.3,
                        minwait: 6,
                        randwait: 0,
                        width: 300,
                        clearwhendone: true,
                        tails:{'bottomright'},
                        delay: 10
                    );
                    var time = OPENWORLD.Mob.setSpeech(dad,
                        citizenmeet2chatter
                        , z: 40,//55,
                        x:-35,
                         //y:-30,
                        scale: 0.2,
                        //3,
                        minwait: 6,
                        randwait: 0,
                        width: 300,
                        clearwhendone: true,
                        tails:{'bottomright'},
                        callbackonfinish: (actor){
                          // put camera back to normal pitch
                          OPENWORLD.Camera.setPitch(0);
                        },
                        delay: 10
                    );
                    Future.delayed(
                        Duration(seconds: time + 10), () async {
                      finishedmeal();
                    });

                    // You are sat down at your breakfast
                    OPENWORLD.Space
                        .worldToLocalSurfaceOnlyObjLerp(
                        threeJs.camera, sitposx, sitposy,
                        OPENWORLD.Camera.cameraoffset * 0.75,
                        //57.59, 13.35
                        1.0);
                    OPENWORLD.Space.faceObjectLerp(
                        dad, threeJs.camera, 1);

                    OPENWORLD.You.setImmobile(true, delay: 1);
                    OPENWORLD.Space.objTurnLerp(
                        threeJs.camera, 267, 1); //146, 1);
                    OPENWORLD.You.setImmobile(false, delay: 8);
                  }
                  );

                  timer2.cancel();
                }

                ticksvalid++;
                print("ticks valid added");
              }
              // After 200 seconds stop waiting for you to sit down
              // never stop waiting
              /*if (ticksall > 200) {
                print("timer2 lower city cancelled");
                timer2.cancel();
              }*/
              if (OPENWORLD.You.level == 0) //&&worldpos.x<-16.67&& isfacing(citizen2iii,45))
                ticksall++;
            });
          }  // end firstmovelowercity
          if (gamestart == GameStart.lowercity &&
              !gamestartpos[gamestart]['progress'].contains('finishedmeal'))
            hasmovedhandler =
                firstmovelowercity; // When player first moves then call this once

        }
      }
    }
    hotloadAdd(firsthotload, false, robes);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        robes, -16.44, -45.07, 0.01, 2, level: 1);
    robes.scale.setValues(1.0, 1.0, 1.0);
    OPENWORLD.Space.objTurn(robes, 0);
    OPENWORLD.Texture.setEmissive(robes, THREE.Color.fromHex32(0x444444));


    // _hotload.add(clotheshanging);
    hotloadAdd(firsthotload, false, clotheshanging);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clotheshanging, -16.54, -45.56, 0.08, 2, level: 1);
    OPENWORLD.Space.objTurn(clotheshanging, 0);

    var clotheshanging3 = await OPENWORLD.Model.copyModel(clotheshanging,
        texture: "assets/models/clotheshanging/clotheshanging2.png",
        groupname: 'clotheshangingpng');
    hotloadAdd(firsthotload, false, clotheshanging3);
    //  _hotload.add(clotheshanging3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clotheshanging3, -16.60, -45.55, 0.08, 2, level: 1);
    OPENWORLD.Space.objTurn(
        clotheshanging3, 180); // Why 180??? Should be zero!!

    var clotheshanging4 = clotheshanging.clone();
    //  _hotload.add(clotheshanging4);
    hotloadAdd(firsthotload, false, clotheshanging4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clotheshanging4, -16.51, -45.07, 0.08, 2, level: 1);
    OPENWORLD.Space.objTurn(clotheshanging4, 0);

    var table4 = table.clone();
    // _hotload.add(table4);
    hotloadAdd(firsthotload, false, table4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        table4, -16.55, -45.06, -0.013, 2,
        level: 1); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    table4.scale.setValues(0.007, 0.007, 0.007);
    //_hotload.add(lamp);
    hotloadAdd(firsthotload, false, lamp);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        lamp, -16.55, -45.04, 0.023, 2, level: 1);
    OPENWORLD.Space.objTurn(lamp, 180);
    var cup7 = cup.clone();
    //_hotload.add(cup7);
    hotloadAdd(firsthotload, false, cup7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup7, -16.55, -45.04 - 0.04, 0.023, 2, level: 1);
    //_hotload.add(matrolled);
    hotloadAdd(firsthotload, false, matrolled);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matrolled, -16.43, -45.07, 0, 2, level: 1);

    roomLowercity = OPENWORLD.Room.createRoom(-16.83, -45.29,
        soundpath: !OPENWORLD.Time.isNight(OPENWORLD.Time.time)?"sounds/indoors.mp3":null, volume: 0.05,
        randomsoundpaths: ["sounds/chickens.mp3","sounds/bah.mp3","sounds/goat.mp3","sounds/goat2.mp3"], randomsoundvolume:0.05, randomsoundgap: 80,  roomspeed: 1.0 / 20 ,
        exitroom: roomTerrain); //THREE.Object3D();

    roomLowercity.extra['guide'] = [
      "You are at your house in the lower city.",
    ];
    //OPENWORLD.Room.setIndoors(roombethphage,true);
    OPENWORLD.Room.setAutoIndoors(roomLowercity, true);
    _hotload.add(roomLowercity);

    OPENWORLD.Room.setDistanceTrigger(roomLowercity,
        maxy: -45.01, miny: -45.6, minx:-17.24, maxx: -16.46, event:(action) {
          if (action) {
            setState(() {
              if (gamestart==GameStart.lowercity&&OPENWORLD.You.level==2) {
                OPENWORLD.Camera.cameraoffset =
                    Glob.defaultcameraoffset * 0.25;
                print("offset 0.25 lowercity");
              } else {
                OPENWORLD.Camera.cameraoffset =
                    Glob.defaultcameraoffset * 0.75;
                print("offset 0.75 lowercity");
              }
              if (gamestart==GameStart.lowercity)
                OPENWORLD.Space.setZLerp(threeJs.camera,OPENWORLD.Camera.cameraoffset,1.0,level:OPENWORLD.You.level);//gamestartpos[gamestart]['l']??0);
              if (mounted)
                roomname = "Lower City Home";
            });
          } else {
            OPENWORLD.Camera.cameraoffset=Glob.defaultcameraoffset;

            setState(() {
              if (mounted)
                roomname = "";
            });
          }
        });

    var mativ = mati.clone();
    //  _hotload.add(mativ);
    hotloadAdd(firsthotload, false, mativ);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mativ, -16.56, -45.17, 0.00, 2);



    var littletablex=-16.72+0.03;
    var littletabley=-45.07;
    var table2 = table.clone();
    //  _hotload.add(table2);
    hotloadAdd(firsthotload, false, table2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        table2, littletablex,littletabley, -0.013,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    table2.scale.setValues(0.007, 0.007, 0.007);
    var cup5 = cup.clone();
    //_hotload.add(cup5);
    hotloadAdd(firsthotload, false, cup5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup5, littletablex-0.01, littletabley-0.03,0.025,2);//-16.73, -45.1, 0.025, 2);
    var plate5 = plate.clone();
    hotloadAdd(firsthotload, false, plate5);
//    _hotload.add(plate5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        plate5, littletablex+0.01, littletabley+0.02,0.025,2);// -16.71, -45.05, 0.025, 2);
    var breadunleaven3 = breadunleaven.clone();
    plate5.add(breadunleaven3);

    var basketwickerdeeppears2 = basketwickerdeeppears.clone();
    // hotloadAdd(firsthotload, false, clotheshanging3);
    _hotload.add(basketwickerdeeppears2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basketwickerdeeppears2, -16.78, -45.06,0, 2, lerpopacity: 1.0);
    OPENWORLD.Space.objTurn(
        basketwickerdeeppears2, 180);

    var basketwickerdeepapples7 = basketwickerdeepapples.clone();
    _hotload.add(basketwickerdeepapples7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basketwickerdeepapples7, -16.79, -45.12, 0.00, 2);
    OPENWORLD.Space.objTurn(
        basketwickerdeepapples7, 180);

    hotloadAdd(firsthotload, false, basketwickerfigs);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basketwickerfigs, -16.81, -45.04, 0.048, 2);

    var basketwickerfigs2= basketwickerfigs.clone();
    //_hotload.add(plate4);
    hotloadAdd(firsthotload, false, basketwickerfigs2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basketwickerfigs2, -16.81-0.02, -45.07-0.04, 0.048, 2);
  /*  var cup4 = cup.clone();
    //  _hotload.add(cup4);
    hotloadAdd(firsthotload, false, cup4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup4, -16.81, -45.04, 0.045, 2);
    var plate4 = plate.clone();
    //_hotload.add(plate4);
    hotloadAdd(firsthotload, false, plate4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        plate4, -16.81, -45.07, 0.047, 2);
    var breadunleaven2 = breadunleaven.clone();
    plate4.add(breadunleaven2);
*/
    var pot6 = pot.clone();
    // _hotload.add(pot6);
    hotloadAdd(firsthotload, false, pot6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(pot6, -16.64, -45.11, 0,
        2); //-16.71, -45.17,0.0,2);//-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);
    var amphora5 = amphora.clone();
    // _hotload.add(amphora5);
    hotloadAdd(firsthotload, false, amphora5);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora5, -16.63, -45.05, 0,
        2); //-16.69, -45.12,0.0,2);//-17.02+0.08, -45.5, 0.005, 2); // 3.2,2.5, 0.0);





    // _hotload.add(jug);
    hotloadAdd(firsthotload, false, jug);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        jug,-16.77, -45.03,0.01,// -16.92, -45.13, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);

    // _hotload.add(woodbundle);
    var woodbundle2 = woodbundle.clone();
    woodbundle2.scale.setValues(0.011, 0.011, 0.011);
    hotloadAdd(firsthotload, false, woodbundle2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        woodbundle2, -16.98, -45.02, 0.01,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(woodbundle, 95);

    var woodbundle3 = woodbundle2.clone();

    //_hotload.add(woodbundle2);
    hotloadAdd(firsthotload, false, woodbundle3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        woodbundle3, -17.00, -45.12, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    //   OPENWORLD.Space.objTurn(woodbundle2,100);
    OPENWORLD.Space.setTurnPitchRoll(woodbundle3, 100, 180, 0);
    var woodbundle3ii = woodbundle2.clone();
    //_hotload.add(woodbundle3);
    hotloadAdd(firsthotload, false, woodbundle3ii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        woodbundle3ii, -17.00, -45.09, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    var woodbundle4 = woodbundle2.clone();
    //   _hotload.add(woodbundle4);
    hotloadAdd(firsthotload, false, woodbundle4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        woodbundle4, -17.00, -45.06, 0.01,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.setTurnPitchRoll(woodbundle4, 100, 180, 0);

    var fence2ii = fence2.clone();
    // _hotload.add(fence2ii);
    hotloadAdd(firsthotload, false, fence2ii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence2ii, -17.01 - 0.035, -45.05, 0,
        2); //-16.69, -45.12,0.0,2);//-17.02+0.08, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence2ii, 10);
    var fence2iii = fence2.clone();
    //_hotload.add(fence2iii);
    hotloadAdd(firsthotload, false, fence2iii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence2iii, -17.01 - 0.035, -45.07, 0.01,
        2); //-16.69, -45.12,0.0,2);//-17.02+0.08, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence2iii, 10 + 180);

    OPENWORLD.Space.objTurn(chicken.children[0], 0);
    OPENWORLD.Space.objTurn(chicken, 270);
//    OPENWORLD.Space.worldToLocalSurfaceObjHide(
    //       chicken,    -17.00, -45.37, 0.0,2);
    //  _hotload.add(chicken);
    setcancollide(chicken,true);
    hotloadAdd(firsthotload, false, chicken);

    //OPENWORLD.Space.readdObjFromHide(chicken,dist:3);
    OPENWORLD.Mob.moveToLoop(chicken,
        [
          {'p': [-17.00, -45.37, 0], 'v': 0.02},
          {"action": "pecking", "time": 8, "duration": null, "z": 0},
          {'p': [-17.07, -45.37, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [-17.12, -45.37, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [-17.07, -45.41, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [-17.0, -45.43, 0], 'v': 0.02},
          {"action": "pecking", "time": 10, "duration": null, "z": 0.0}
        ],
        //  duration:1.0,
        facenow: true,
        hidedist:2,
        randomduration: 0.1,
        //  reverseloop:true,
        action: "walk" //straight"
    );
    var basket4 = basket.clone();
    //_hotload.add(basket4);
    hotloadAdd(firsthotload, false, basket4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket4, -16.48, -45.10, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    var table3 = table2.clone();
    //_hotload.add(table3);
    hotloadAdd(firsthotload, false, table3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        table3, -16.58, -45.08, -0.013,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    var cup6 = cup.clone();
    //  _hotload.add(cup6);
    hotloadAdd(firsthotload, false, cup6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup6, -16.58, -45.08, 0.02,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);

    var amphora7 = amphora.clone();
    // _hotload.add(amphora7);
    hotloadAdd(firsthotload, false, amphora7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora7, -16.48, -45.18, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);


    // house 2
    var citizenf22iv = await OPENWORLD.Actor.copyActor(
        citizenf22, action: null); //"squatwork");//right");
    //_hotload.add(citizenf2iv);
    hotloadAdd(firsthotload, false, citizenf22iv);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        citizenf22iv, -18.01, -44.96, 0, 2);
    OPENWORLD.Mob.moveToLoop(citizenf22iv,
        [
          {'p': [-18.01, -44.88, 0], 'v': pilgrimspeed},
          {'p': [-17.89, -44.92, 0], 'v': pilgrimspeed},
          {'p': [-17.87, -44.76, 0], 'v': pilgrimspeed},
          {'p': [-17.97, -44.71, 0], 'v': pilgrimspeed},
          {
            "action": "squatwork",
            "time": 32,
            "duration": null,
            "z": 0.0,
            "t": 270
          },
          {'p': [-17.87, -44.76, 0], 'v': pilgrimspeed},
          {'p': [-17.89, -44.92, 0], 'v': pilgrimspeed},
          {'p': [-18.01, -44.88, 0], 'v': pilgrimspeed},
          {'p': [-18.01, -45, 0], 'v': pilgrimspeed},
          {
            "action": "squatwork",
            "time": 32,
            "duration": null,
            "z": 0.0,
            "t": 180
          }
        ],

        surfaceonly: true,
        fadeout: 1.0,
        action: "walk"
    );
    //  _hotload.add(millstone);

    if (OPENWORLD.Math.random()<0.1) {
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          wilddog, -16.44, -45.74, 0, 3,
          lerpopacity: 1.0); //-8.14, -19.86  -18.01, -44.88
      OPENWORLD.Space.objTurn(wilddog.children[0], 0);
      _hotload.add(wilddog);
      //  OPENWORLD.Actor.playActionsLoop(citizenf2ii, ["pickupright","idle","point","pickupright","idlebum","idle","idle","pickupright","pickupright","idle","idlenose","idle"]);
      OPENWORLD.Mob.moveToLoop(wilddog,
          [
            { 'p': [-16.44, -45.74, 0], 'v': pilgrimspeed,},  //east south
            { 'p': [-17.42, -45.53, 0], 'v': pilgrimspeed,},  // west south
            {"action": "urinate"},
            { 'p': [-17.68, -44.97, 0], 'v': pilgrimspeed, "callback": (actor) {    // west mid
              OPENWORLD.Sound.play(path: 'sounds/bark.mp3', volume: 0.1);
            }
            },
            { 'p': [-17.1, -44.73, 0], 'v': pilgrimspeed,},  //  north west
//            { 'p': [-17.1, -44.08, 0], 'v': pilgrimspeed,},  //
            {"action": "urinate"},
            { 'p': [-16.32, -44.98, 0], 'v': pilgrimspeed,},  // north west
          ],

          duration: 1,
          // randomduration: 0.1,
          surfaceonly: true,
          fadeout: 1.0,
          action: "walk"
      );
    }


    if (OPENWORLD.Math.random()<0.1) {
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cat, -17.4, -45.9, 0, 0.5, lerpopacity: 1.0); //15.04, 6.73

      OPENWORLD.Space.objTurn(cat, 0);
      _hotload.add(cat);

      // Cat meows when you get near
      OPENWORLD.BaseObject.setDistanceTrigger(cat,
          dist: 0.5, event: (action) {
            if (action) {
              OPENWORLD.Sound.play(path: 'sounds/meow.mp3',
                  volume: 0.05,
                  delay: OPENWORLD.Math.random() * 5);
              OPENWORLD.Mob.randomwalk(
                cat, 0.1, 0.02, 0.1, // -17.4,-45.9, 0.1, //1, 0.15
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

    if (OPENWORLD.Math.random()<0.1&&!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var neighbour = await OPENWORLD.Actor.copyActor(
          manlist[5], action: "idle3",randomduration: 0.1); //"shovel");
      // _hotload.add(citizen2iii);
      hotloadAdd(firsthotload, false, neighbour);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          neighbour, -17.58 - 0.02, -44.48, 0, 2);
      OPENWORLD.Space.objTurn(neighbour, 290);

      var neighbour2 = await OPENWORLD.Actor.copyActor(
          manlist[6], action: "idle3", randomduration: 0.1); //"shovel");
      // _hotload.add(citizen2iii);
      hotloadAdd(firsthotload, false, neighbour2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          neighbour2, -17.71, -44.46, 0, 2);
      OPENWORLD.Space.objTurn(neighbour2, 102);

    //  var donechat = false;
      var inchat=false;
      var chatcnt=0;
      OPENWORLD.BaseObject.setDistanceTrigger(neighbour,
          dist: 0.4, event: (action) {
            if (action) {
              if (!inchat) {
                inchat = true;
                if (chatcnt == 0) {
                  OPENWORLD.Space.faceObjectLerp(neighbour, threeJs.camera, 1);
                  OPENWORLD.Space.faceObjectLerp(neighbour2, threeJs.camera, 1,
                      delay: OPENWORLD.Math.random());
                  OPENWORLD.Space.faceObjectLerp(neighbour,neighbour2, 1, delay:12);
                  OPENWORLD.Space.faceObjectLerp(neighbour2,neighbour, 1,delay:13);
                  OPENWORLD.Space.faceObjectLerp(neighbour, threeJs.camera, 1,delay:25);
                  OPENWORLD.Space.faceObjectLerp(neighbour2, threeJs.camera, 1, delay:26);
                  var chat = [{0: "Shalom"},
                    {1: "Shalom"},
                    {0: "You should come round for dinner come time."},
                    {0: "My wife's making salted fish stew"},
                    {1: "She makes the best fish stew."},
                    {1: "I've got a whole lot of figs. "},
                    {1: "I'll bring them. "},
                    {0: "Thanks. That'll be great"},
                  ];

                  var minwait = 4;
                  var delay = 0;
                  var citizenmeetchatterarr = createChat(chat);
                  var citizenmeetchatter = citizenmeetchatterarr[0];
                  var citizenmeet2chatter = citizenmeetchatterarr[1];

                  OPENWORLD.Mob.setSpeech(
                      neighbour,
                      citizenmeetchatter,
                      z: 120,
                      //0.5
                        scale: 0.3,
                      width: 300,
                      minwait: minwait,
                      clearwhendone: true,
                      randwait: 0,
                      delay: delay);
                  OPENWORLD.Mob.setSpeech(
                      neighbour2,
                      citizenmeet2chatter,
                      z: 90,
                      //80,
                      minwait: minwait,
                      clearwhendone: true,
                      //0.5
                       scale: 0.3,
                      width: 300,
                      randwait: 0,
                      delay: delay + 2,
                      callbackonfinish: (actor) {
                        inchat = false;
                      }

                  );
                  chatcnt++;
                } else {
                  var chat = OPENWORLD.Math.randPick(chatsgeneral?['men']);
                  OPENWORLD.Space.faceObjectLerp(neighbour,neighbour2, 1);
                  OPENWORLD.Space.faceObjectLerp(neighbour2,neighbour, 1);

                  var citizenmeetchatterarr = createChat(chat);
                  var citizenmeetchatter = citizenmeetchatterarr[0];
                  var citizenmeet2chatter = citizenmeetchatterarr[1];
                  //  print("found friend" + citizenmeetchatter.toString() + " " +
                  //     citizenmeet2chatter.toString());
                  var minwait = 4;
                  var delay = OPENWORLD.Math.random() * 10;
                  OPENWORLD.Mob.setSpeech(
                      neighbour,
                      citizenmeetchatter,
                      z: 120,
                      //0.5
                      scale: 0.3,
                      width: 300,
                      minwait: minwait,
                      clearwhendone: true,
                      randwait: 0,
                      delay: delay);
                  OPENWORLD.Mob.setSpeech(
                      neighbour2,
                      citizenmeet2chatter,
                      z: 90,
                      //80,
                      minwait: minwait,
                      clearwhendone: true,
                      //0.5
                      scale: 0.3,
                      width: 300,
                      randwait: 0,
                      delay: delay + 2,
                    callbackonfinish: (actor) {
                        inchat=false;
                    }
                  );
                  chatcnt++;
                }
              }
            } else {
              OPENWORLD.Space.faceObjectLerp(neighbour,neighbour2, 1);
              OPENWORLD.Space.faceObjectLerp(neighbour2,neighbour, 1);

            }
          });
    }

    var rakers=[
      [-17.61-0.1, -45.66+0.02,180],
      [-14.76,-46.6,180],
      [-13.55,-46.61,0]

    ];

   // for (var pos in rakers) {
   //   if (OPENWORLD.Math.random() < 0.2 &&
   //       !OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
    var pos=OPENWORLD.Math.randPick(rakers);   // pick one raker so always a neighbour
    var neighbour = await OPENWORLD.Actor.copyActor(
        citizen3, action: "shovel");
    var pitchfork2ii = pitchfork.clone();
    OPENWORLD.Space.setTurnPitchRoll(pitchfork2ii.children[0], 90, 0, 0);
    // OPENWORLD.Space.objRoll(pitchfork.children[0], 90);
    //  OPENWORLD.Space.objTurn(pitchfork.children[0], 20 + 180);
    OPENWORLD.Actor.wield(neighbour, pitchfork2ii, "Bip01_L_Hand");
    OPENWORLD.Space.objPitch(neighbour, -8);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        neighbour, pos[0],pos[1],0,2);// -17.61 - 0.1, -45.66, 0, 2);
    _hotload.add(neighbour);
    OPENWORLD.Space.objTurn(neighbour,pos[2]);// 270);
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
              'Shalom',
              'Its a nice day'
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
      //}
   // }


    if (OPENWORLD.Math.random()<0.3&&!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var cart2 = await OPENWORLD.Actor.copyActor(cart,
          action: "idle"); //await OPENWORLD.Model.createModel('assets/models/cart.glb');
      _hotload.add(cart2);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          cart2, -17.31, -44.59, -0.01, 2); // 3.2,2.5, 0.0);
      // cart.scale.setValues(0.01 * convscale, 0.01 * convscale,
      //     0.01 * convscale);
      OPENWORLD.Space.objTurn(cart2, 0);
      var figs2 = figs.clone();
      // figs.scale.setValues(5.0,5.0,5.0);
      cart2.add(figs2);
    }

    if (OPENWORLD.Math.random()<0.3&&!OPENWORLD.Time.isNight(OPENWORLD.Time.time)) {
      var childgirliv = await OPENWORLD.Actor.copyActor(
          childgirl, action: "walkup");//,duration:1.0);
      _hotload.add(childgirliv);
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          childgirliv, 58.03, 12.45, 0.00,
          2); //centerx+(-17.27-centerx)*0.5, centery+(-45.26-centery)*0.5,0.0);// -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
      OPENWORLD.Space.objTurn(childgirliv, 0);

     // var girlspeed = 0.07;
      OPENWORLD.Mob.moveToLoop(childgirliv,
          [
            {'p': [-17.95, -45.45, 0], 'v': girlspeed},
            {'p': [-17.92, -45.18, 0], 'v': girlspeed},
            {'p': [-17.6, -45.25, 0], 'v': girlspeed},
            {'p': [-17.64, -45.49, 0], 'v': girlspeed},
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

      var child12ii = await OPENWORLD.Actor.copyActor(child12, action: "idle3");
      OPENWORLD.Space.worldToLocalSurfaceObjHide(
          child12ii, -17.74, -45.21, 0, 2);
      _hotload.add(child12ii);
      OPENWORLD.Space.objTurn(child12ii, 0);
      OPENWORLD.Space.faceObjectAlways(child12ii, childgirliv);
    }

    hotloadAdd(firsthotload, false, millstone);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        millstone, -17.92, -45.06, 0,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);

    var oven2 = tannur.clone();
    //  _hotload.add(oven2);
    hotloadAdd(firsthotload, false, oven2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        oven2, -18.02, -44.69, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(oven2, 90);
    var housefire2 = new VolumetricFire(
    Glob.fireWidth, Glob.fireHeight, Glob.fireDepth, Glob.sliceSpacing, threeJs.camera);
    await housefire2.init();

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        housefire2.mesh, -18.02, -44.69, 0.02,
        3); // 3.35, 0.51, 0.3,3); //3.7);
    housefire2.mesh.scale.x = 0.01;
    housefire2.mesh.scale.y = 0.01;
    housefire2.mesh.scale.z = 0.01;
    hotloadAdd(firsthotload, false, housefire2.mesh);
    //  _hotload.add(housefire2.mesh);
    OPENWORLD.Updateables.add(housefire2);

    var smoke5 = Smoke();
    var smokeGroup5 = await smoke5.createSmoke(
        'assets/textures/smoke/clouds64.png');

    //var smokeGroup2=smokeGroup.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smokeGroup5, -18.02, -44.69, 0.05, 3);

    smokeGroup5.scale.setValues(0.00001, 0.00001, 0.00001);
    OPENWORLD.Updateables.add(smoke5);
    //  _hotload.add(smokeGroup5);
    hotloadAdd(firsthotload, false, smokeGroup5);

    instancedHays.place(0,  -18.04, -44.91, 0.00);///,  scale:THREE.Vector3(0.04,0.04,0.04));//,5);

   /* var hay9 = hay.clone();
    //_hotload.add(hay9);
    hotloadAdd(firsthotload, false, hay9);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay9, -18.14, -44.84, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    hay9.scale.setValues(0.04, 0.04, 0.04);*/
    instancedHays.place(0, -18.14, -44.84, 0,  scale:THREE.Vector3(0.04,0.04,0.04));//,5);


  /*  var hay10 = hay.clone();
    // _hotload.add(hay10);
    hotloadAdd(firsthotload, false, hay10);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay10, -18.15, -44.93, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    hay10.scale.setValues(0.04, 0.04, 0.04);*/
    instancedHays.place(0, -18.15, -44.93, 0,  scale:THREE.Vector3(0.04,0.04,0.04));//,5);

  /*  var hay11 = hay.clone();
    hotloadAdd(firsthotload, false, hay11);
    //_hotload.add(hay11);
    hay11.scale.setValues(0.011, 0.01, 0.007);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay11, -18.00, -44.86, 0.013,
        2); */
    instancedHays.place(0, -18.00, -44.86, 0.013,  scale:THREE.Vector3(0.011, 0.01, 0.007));//,5);
    /*var hay12 = hay.clone();
    hotloadAdd(firsthotload, false, hay12);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay12, -18.02, -44.94, 0.0,
        2);*/
    instancedHays.place(0, -18.02, -44.94, 0.0);//,5);


    var manger2 = manger.clone();
    // _hotload.add(manger2);
    hotloadAdd(firsthotload, false, manger2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        manger2, -17.99, -44.86, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(manger2, 100);
    manger2.scale.setValues(0.01, 0.01, 0.01);


    var sheep4 = await OPENWORLD.Actor.copyActor(
        sheeporig, duration: 6, randomduration: 1);
    //_hotload.add(sheep4);
    hotloadAdd(firsthotload, false, sheep4);
    OPENWORLD.Space.objTurn(sheep4.children[0], 0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheep4, -18.11, -44.85, 0.0,
        2); // -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
    OPENWORLD.Space.objTurn(sheep4, 90);


    var sheep5 = await OPENWORLD.Actor.copyActor(
        sheeporig, duration: 6, randomduration: 1);
    //_hotload.add(sheep5);
    hotloadAdd(firsthotload, false, sheep5);
    OPENWORLD.Space.objTurn(sheep5.children[0], 0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheep5, -18.13, -44.94, 0.0,
        2); // -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
    OPENWORLD.Space.objTurn(sheep5, 90);

    var pitchfork3 = pitchfork2.clone();
    OPENWORLD.Space.setTurnPitchRoll(pitchfork3.children[0], 90, 70, 55);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pitchfork3, -18.13, -44.84, 0,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    //  _hotload.add(pitchfork3);
    hotloadAdd(firsthotload, false, pitchfork3);
    var mat8 = mati.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mat8, -18.06, -45.06, 0, 2);
    // _hotload.add(mat8);
    hotloadAdd(firsthotload, false, mat8);
    OPENWORLD.Space.objTurn(mat8, 10);

    var board2 = board.clone();
    //  _hotload.add(board2);
    hotloadAdd(firsthotload, false, board2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board2, -18.12, -45.06, 0.1,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    board2.scale.setValues(0.003, 0.003, 0.0015);
    var cup9 = cup.clone();
    // _hotload.add(cup9);
    hotloadAdd(firsthotload, false, cup9);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup9, -18.12, -45.06, 0.1,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var cup10 = cup.clone();
    //_hotload.add(cup10);
    hotloadAdd(firsthotload, false, cup10);
    cup10.scale.setValues(0.0002, 0.0002, 0.0002);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup10, -18.12 + 0.005, -45.06, 0.1,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var matrolled2 = matrolled.clone();
    // _hotload.add(matrolled2);
    hotloadAdd(firsthotload, false, matrolled2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matrolled2, -18.17, -45.00, 0, 2);
    var amphora8 = amphora.clone();
    hotloadAdd(firsthotload, false, amphora8);
    //_hotload.add(amphora8);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora8, -17.95, -45.08, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var jug2 = jug.clone();
    // _hotload.add(jug2);
    hotloadAdd(firsthotload, false, jug2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        jug2, -17.95, -45, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var table5 = table.clone();
    // _hotload.add(table5);
    hotloadAdd(firsthotload, false, table5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        table5, -18.00, -45.07, -0.013,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    table5.scale.setValues(0.004, 0.004, 0.004);
    var lamp2 = lamp.clone();
    //  _hotload.add(lamp2);
    hotloadAdd(firsthotload, false, lamp2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        lamp2, -18.00, -45.07, 0.01,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    var pot7 = pot.clone();
    //  _hotload.add(pot7);
    hotloadAdd(firsthotload, false, pot7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot7, -18.19, -45.02, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
//    OPENWORLD.You.level=0;
    OPENWORLD.Portals.createPortal(
        -18.14,
        -44.79,
        0.04,
        0.1,
        -18.14,
        -44.79 - 0.2,
        0.0,
        level2: 1,
        lerp: 1);
    ; //,marker:_hotload);
    OPENWORLD.Portals.createPortal(
        -18.14,
        -44.79 - 0.07,
        level: 1,
        0.04,
        0.02,
        -18.05,
        -44.79,
        0.0,
        level2: 0,
      //  marker:_hotload,
        lerp: 1); //);
    var mat9 = mati.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mat9, -18.06, -44.98, 0, 2, level: 1);
    //  _hotload.add(mat9);
    hotloadAdd(firsthotload, false, mat9);
    OPENWORLD.Space.objTurn(mat9, 10);
    var pot8 = pot.clone();
    hotloadAdd(firsthotload, false, pot8);
    //  _hotload.add(pot8);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot8, -18.03, -45.04, 0, 2,
        level: 1); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);

    var chicken2 = await OPENWORLD.Actor.copyActor(
        chicken,
        //  action: null,
        randomduration: 0.1);
    setcancollide(chicken2,true);
    //_hotload.add(chicken2);
    hotloadAdd(firsthotload, false, chicken2);

    var chickenposx = -17.78;
    var chickenposy = -44.81;
    OPENWORLD.Mob.moveToLoop(chicken2,
        [
          {'p': [chickenposx, chickenposy, 0], 'v': 0.02},
          {"action": "pecking", "time": 8, "duration": null, "z": 0},
          {'p': [chickenposx - 0.07, chickenposy, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenposx - 0.12, chickenposy, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenposx - 0.07, chickenposy - 0.04, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenposx, chickenposy - 0.06, 0], 'v': 0.02},
          {"action": "pecking", "time": 10, "duration": null, "z": 0.0}
        ],
        hidedist: 2,
        //  duration:1.0,
        facenow: true,
        randomduration: 0.1,
        //  reverseloop:true,
        action: "walk" //straight"
    );

    instancedHays.place(0, -17.85, -44.76, 0.0, scale:THREE.Vector3(0.04,0.04,0.04));//,5);

    // house 3
    var sheep6 = await OPENWORLD.Actor.copyActor(
        sheeporig, duration: 6, randomduration: 1);
    // _hotload.add(sheep6);
    hotloadAdd(firsthotload, false, sheep6);
    OPENWORLD.Space.objTurn(sheep6.children[0], 0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheep6, -17.59, -45.86, 0.0,
        2); // -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
    OPENWORLD.Space.objTurn(sheep6, 0);

    var sheep7 = await OPENWORLD.Actor.copyActor(
        sheeporig, duration: 6, randomduration: 1);
    // _hotload.add(sheep7);
    hotloadAdd(firsthotload, false, sheep7);
    OPENWORLD.Space.objTurn(sheep7.children[0], 0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheep7, -17.66, -45.85, 0.0,
        2); // -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
    OPENWORLD.Space.objTurn(sheep7, 270);

   /* var hay15 = hay.clone();
    // _hotload.add(hay15);
    hotloadAdd(firsthotload, false, hay15);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay15, -17.56, -45.87, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    hay15.scale.setValues(0.04, 0.04, 0.04);*/
    instancedHays.place(0, -17.56, -45.87, 0.0, scale:THREE.Vector3(0.04,0.04,0.04));//,5);

  /*  var hay16 = hay
        .clone();
    // _hotload.add(hay16);
    hotloadAdd(firsthotload, false, hay16);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay16, -17.64, -45.79, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    hay16.scale.setValues(0.04, 0.04, 0.04);*/
    instancedHays.place(0, -17.64, -45.79, 0.0, scale:THREE.Vector3(0.04,0.04,0.04));//,5);
 /*
    var hay17 = hay
        .clone();
    // _hotload.add(hay17);
    hotloadAdd(firsthotload, false, hay17);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay17, -17.64, -45.89, 0,
        2);*/ //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    instancedHays.place(0, -17.64, -45.89, 0.0);// scale:THREE.Vector3(0.04,0.04,0.04));//,5);
    var amphora9 = amphora.clone();
    //  _hotload.add(amphora9);
    hotloadAdd(firsthotload, false, amphora9);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora9, -17.43, -45.62, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var millstone2 = millstone.clone();
    //  _hotload.add(millstone2);
    hotloadAdd(firsthotload, false, millstone2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        millstone2, -17.60, -45.62, 0, 2);
    var mat10 = mati.clone();
    hotloadAdd(firsthotload, false, mat10);
    // _hotload.add(mat10);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mat10, -17.75, -45.82, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var pot9 = pot.clone();

    /// _hotload.add(pot9);
    hotloadAdd(firsthotload, false, pot9);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot9, -17.73, -45.91, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var board3 = board2.clone();
    //  _hotload.add(board3);
    hotloadAdd(firsthotload, false, board3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board3, -17.68, -45.92, 0.1,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var jug3 = jug.clone();
    //  _hotload.add(jug3);
    hotloadAdd(firsthotload, false, jug3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        jug3, -17.68, -45.92, 0.1,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var chicken3 = await OPENWORLD.Actor.copyActor(
        chicken,
        action: null,
        randomduration: 0.1);
    setcancollide(chicken3,true);
    _hotload.add(chicken3);

    var chickenpos3x = -17.62; //9;
    var chickenpos3y = -45.60;
    OPENWORLD.Mob.moveToLoop(chicken3,
        [
          {'p': [chickenpos3x, chickenpos3y, 0], 'v': 0.02},
          {"action": "pecking", "time": 8, "duration": null, "z": 0},
          {'p': [chickenpos3x - 0.07, chickenpos3y, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenpos3x - 0.12, chickenpos3y, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenpos3x - 0.07, chickenpos3y - 0.04, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenpos3x, chickenpos3y - 0.06, 0], 'v': 0.02},
          {"action": "pecking", "time": 10, "duration": null, "z": 0.0}
        ],
        //  duration:1.0,
        facenow: true,
        randomduration: 0.1,
        hidedist:2,
        //  reverseloop:true,
        action: "walk" //straight"
    );

    // House 4
    var table6 = table.clone();
    //_hotload.add(table6);
    hotloadAdd(firsthotload, false, table6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        table6, -17.39, -44.26, 0.0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var chisel3 = chisel.clone();
    chisel3.scale.setValues(0.007, 0.007, 0.007);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        chisel3, -17.39, -44.26, 0.057,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    // _hotload.add(chisel3);
    hotloadAdd(firsthotload, false, chisel3);
    var hammer3 = hammer.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hammer3, -17.38, -44.27, 0.059,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    // _hotload.add(hammer3);
    hotloadAdd(firsthotload, false, hammer3);
    OPENWORLD.Space.objTurn(hammer3, 10);
    var saw2 = saw.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        saw2, -17.37, -44.22, 0.059,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    // _hotload.add(saw2);
    hotloadAdd(firsthotload, false, saw2);
    OPENWORLD.Space.objRoll(saw2, 90);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hoe, -17.43, -44.135, 0.002,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
//    _hotload.add(hoe);
    hotloadAdd(firsthotload, false, hoe);
    OPENWORLD.Space.setTurnPitchRoll(hoe, 90, 10, -5); //.objTurn(shovel2,90);
    // OPENWORLD.Space.objTurn(hoe,90);
    var shovel2 = shovel.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        shovel2, -17.32, -44.155, 0.0,
        2); //-17.14, -45.31,-0.005,2);//centerx+(-17.56-centerx)*0.5, centery+(-44.81-centery)*0.5, 0.0, 2); // 3.2,2.5, 0.0);
    // _hotload.add(shovel2);
    hotloadAdd(firsthotload, false, shovel2);
    OPENWORLD.Space.setTurnPitchRoll(
        shovel2, 90, 10, 0); //.objTurn(shovel2,90);
    var pot10 = pot.clone();
    // _hotload.add(pot10);
    hotloadAdd(firsthotload, false, pot10);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot10, -17.39, -44.29, 0.059,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var boardpos2x = -17.44;
    var boardpos2y = -44.18;
    var board8 = board.clone();
    //  _hotload.add(board8);
    hotloadAdd(firsthotload, false, board8);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board8, boardpos2x, boardpos2y, 0.1,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    //board8.scale.setValues(0.0003,0.0011,0.0011);
    var board6 = board.clone();
    //  _hotload.add(board6);
    hotloadAdd(firsthotload, false, board6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board6, boardpos2x, boardpos2y + 0.01, 0.1, 2);
    var hammer4 = hammer.clone();
//    _hotload.add(hammer4);
    hotloadAdd(firsthotload, false, hammer4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hammer4, boardpos2x, boardpos2y + 0.005, 0.1 - 0.026, 2);
    OPENWORLD.Space.objPitch(hammer4, 90);
    var board7 = board.clone();
    //_hotload.add(board7);
    hotloadAdd(firsthotload, false, board7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        board7, boardpos2x, boardpos2y + 0.016, 0.1, 2);
    var chisel4 = chisel.clone();
    //_hotload.add(chisel4);
    hotloadAdd(firsthotload, false, chisel4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        chisel4, boardpos2x, boardpos2y + 0.015, 0.1 - 0.008, 2);
    OPENWORLD.Space.objPitch(chisel4, 90);
    var cistern2 = cistern.clone();
    // _hotload.add(cistern2);
    hotloadAdd(firsthotload, false, cistern2);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cistern2, -17.38, -44.42, 0.005, 2);
    var jug4 = jug.clone();
    // _hotload.add(jug4);
    hotloadAdd(firsthotload, false, jug4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        jug4, -17.45, -44.39, 0.00, 2);
    var fence3iv = fence3.clone();
    //_hotload.add(fence3iv);
    hotloadAdd(firsthotload, false, fence3iv);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3iv, -17.12, -44.44, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence3iv, 100);
    var fence3v = fence3.clone();
    // _hotload.add(fence3v);
    hotloadAdd(firsthotload, false, fence3v);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3v, -17.12 + 0.02, -44.44 + 0.11, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence3v, 100);
    var fence3vi = fence3.clone();
    //   _hotload.add(fence3vi);
    hotloadAdd(firsthotload, false, fence3vi);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        fence3vi, -17.12 + 0.04, -44.44 + 0.22, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(fence3vi, 100);
    var hay18 = hay
        .clone();
    //  _hotload.add(hay18);
    hotloadAdd(firsthotload, false, hay18);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay18, -17.03, -44.42, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    hay18.scale.setValues(0.04, 0.04, 0.04);
    var hay19 = hay
        .clone();
    //_hotload.add(hay19);
    hotloadAdd(firsthotload, false, hay19);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay19, -17.09, -44.39, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var hay20 = hay
        .clone();
    //_hotload.add(hay20);
    hotloadAdd(firsthotload, false, hay20);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay20, -17.01, -44.27, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    hay20.scale.setValues(0.04, 0.04, 0.04);
    var hay21 = hay
        .clone();
//    _hotload.add(hay21);
    hotloadAdd(firsthotload, false, hay21);

    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay21, -16.98, -44.36, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var hay22 = hay
        .clone();
    // _hotload.add(hay22);
    hotloadAdd(firsthotload, false, hay22);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay22, -17.01, -44.18, 0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var sheep8 = await OPENWORLD.Actor.copyActor(
        sheeporig, duration: 6, randomduration: 1);
//    _hotload.add(sheep8);
    hotloadAdd(firsthotload, false, sheep8);

    OPENWORLD.Space.objTurn(sheep8.children[0], 0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheep8, -17.04, -44.40, 0.0,
        2); // -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
    OPENWORLD.Space.objTurn(sheep8, -90);

    var sheep9 = await OPENWORLD.Actor.copyActor(
        sheeporig, duration: 6, randomduration: 1);
    // _hotload.add(sheep9);
    hotloadAdd(firsthotload, false, sheep9);
    OPENWORLD.Space.objTurn(sheep9.children[0], 0);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        sheep9, -16.99, -44.22, 0.0,
        2); // -9.74, -51.38,0);//-9.26, -50.90,0.00);//-14.42, 64.41, 0.06); // 9.8,1.1, 0.14,3); //3.42);
    OPENWORLD.Space.objTurn(sheep9, 0);

    var pitchfork4 = pitchfork2.clone();
    OPENWORLD.Space.setTurnPitchRoll(pitchfork4.children[0], 90, 70, 55);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pitchfork4, -16.99, -44.14, 0, 2);
    // _hotload.add(pitchfork4);
    hotloadAdd(firsthotload, false, pitchfork4);
    var chicken4 = await OPENWORLD.Actor.copyActor(
        chicken,
        action: null,
        randomduration: 0.1);
    setcancollide(chicken4,true);    //  _hotload.add(chicken4);
    hotloadAdd(firsthotload, false, chicken4);

    var chickenpos4x = -17.17;
    var chickenpos4y = -44.25;
    OPENWORLD.Mob.moveToLoop(chicken4,
        [
          {'p': [chickenpos4x, chickenpos4y, 0], 'v': 0.02},
          {"action": "pecking", "time": 8, "duration": null, "z": 0},
          {'p': [chickenpos4x - 0.07, chickenpos4y, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenpos4x - 0.12, chickenpos4y, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenpos4x - 0.07, chickenpos4y - 0.04, 0], 'v': 0.02},
          {"action": "pecking", "time": 7, "duration": null, "z": 0.0},
          {'p': [chickenpos4x, chickenpos4y - 0.06, 0], 'v': 0.02},
          {"action": "pecking", "time": 10, "duration": null, "z": 0.0}
        ],
        //  duration:1.0,
        facenow: true,
        randomduration: 0.1,
        hidedist:2,
        //  reverseloop:true,
        action: "walk" //straight"
    );
    var basket6 = basket.clone();
    // _hotload.add(basket6);
    hotloadAdd(firsthotload, false, basket6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket6, -16.95, -43.97, 0.00, 2);
    var pot11 = pot.clone();
    //_hotload.add(pot11);
    hotloadAdd(firsthotload, false, pot11);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot11, -16.93, -44.07, 0.0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var jug5 = jug.clone();
    //  _hotload.add(jug5);
    hotloadAdd(firsthotload, false, jug5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        jug5, -16.94, -44.02, 0.0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var amphora11 = amphora.clone();
    hotloadAdd(firsthotload, false, amphora11);
    //_hotload.add(amphora11);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora11, -17.03, -43.94, 0.00, 2);
    var amphora12 = amphora.clone();
    // _hotload.add(amphora12);
    hotloadAdd(firsthotload, false, amphora12);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora12, -17.03, -44.07, 0.00, 2);
    var table7 = table.clone();
    // _hotload.add(table7);
    hotloadAdd(firsthotload, false, table7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        table7, -17.03, -44.01, -0.007,
        2); //-16.82, -45.36,0,2);//-17.05, -45.39+0.1, 0.0, 2); // 3.2,2.5, 0.0);
    table7.scale.setValues(0.004, 0.004, 0.004);
    var mortar2 = mortar.clone();
    // _hotload.add(mortar2);
    hotloadAdd(firsthotload, false, mortar2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mortar2, -17.03, -44.01, 0.011, 2);
    var boardpos3x = -17.37;
    var boardpos3y = -44.08;
    var amphora13 = amphora.clone();
    //_hotload.add(amphora13);
    hotloadAdd(firsthotload, false, amphora13);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora13, boardpos3x, boardpos3y, 0.005,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    amphora.scale.setValues(0.033, 0.033, 0.033);

    var boardiii = board.clone();
    //_hotload.add(boardiii);
    hotloadAdd(firsthotload, false, boardiii);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        boardiii, boardpos3x, boardpos3y, 0.005,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    boardiii.scale.setValues(0.011, 0.011, 0.011);
    var pot12 = pot.clone();
    hotloadAdd(firsthotload, false, pot12);
    //   _hotload.add(pot12);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot12, boardpos3x - 0.04, boardpos3y + 0.02, 0,
        2); //-16.79, -45.47,0.0,2);//-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);
    var cup11 = cup.clone();
    //  _hotload.add(cup11);
    hotloadAdd(firsthotload, false, cup11);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup11, boardpos3x, boardpos3y + 0.025, 0.005,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    cup.scale.setValues(0.0005, 0.0005, 0.0005);
    var cup12 = cup.clone();
    //_hotload.add(cup12);
    hotloadAdd(firsthotload, false, cup12);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup12, boardpos3x - 0.015, boardpos3y + 0.025, 0.005,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var plate6 = plate
        .clone();
    //   _hotload.add(plate6);
    hotloadAdd(firsthotload, false, plate6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        plate6, boardpos3x + 0.03, boardpos3y + 0.025, 0.011,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var breadunleaven4 = breadunleaven.clone();
    plate6.add(breadunleaven4);
    breadunleaven4.scale.setValues(100.0, 100.0, 100.0);

    var cup13 = cup.clone();
    //   _hotload.add(cup13);
    hotloadAdd(firsthotload, false, cup13);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        cup13, -17.37, -44.00, 0.047,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var plate7 = plate
        .clone();
    //  _hotload.add(plate7);
    hotloadAdd(firsthotload, false, plate7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        plate7, -17.32, -44.00, 0.047,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var jug6 = jug.clone();
    // _hotload.add(jug6);
    hotloadAdd(firsthotload, false, jug6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        jug6, -17.42, -44.03, 0.0,
        2); //-17.02+0.04, -45.5, 0.005, 2); // 3.2,2.5, 0.0);
    var firepit2 = firepit.clone();
    // _hotload.add(firepit2);
    hotloadAdd(firsthotload, false, firepit2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        firepit2, -17.37, -43.92, 0.0,
        2); //-16.93, -45.43, 0.0, 2); // 3.2,2.5, 0.0);
    var smoke6 = Smoke();
    var smokeGroup6 = await smoke6.createSmoke(
        'assets/textures/smoke/clouds64.png');
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        smokeGroup6, -17.37, -43.92, 0.01,
        3); //centerx+(-17.02-centerx)*0.5, centery+(-45.58-centery)*0.5, 0.51*0.5, 3);
    /// OPENWORLD.Space.worldToLocalSurfaceObjHide(
    //     smokeGroup2,  -16.85,-45.25, 0.51*0.5, 3);
    smokeGroup6.scale.setValues(0.000015, 0.000015, 0.000015);
    OPENWORLD.Updateables.add(smoke6);
    //_hotload.add(smokeGroup6);
    hotloadAdd(firsthotload, false, smokeGroup6);
    var woodbundle5 = woodbundle2.clone();
    // _hotload.add(woodbundle5);
    hotloadAdd(firsthotload, false, woodbundle5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        woodbundle5, -17.22 - 0.02, -43.94, 0, 2);
    var woodbundle6 = woodbundle2.clone();
    // _hotload.add(woodbundle6);
    hotloadAdd(firsthotload, false, woodbundle6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        woodbundle6, -17.22 - 0.02, -43.91, 0, 2);
    OPENWORLD.Space.objTurn(woodbundle6, 10);
    var mat4 = mati.clone();
    // _hotload.add(mat4);
    hotloadAdd(firsthotload, false, mat4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mat4, -17.26, -43.82, 0, 2);
    OPENWORLD.Space.objTurn(mat4, 0);
    var matrolled3 = matrolled.clone();
    //  _hotload.add(matrolled3);
    hotloadAdd(firsthotload, false, matrolled3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matrolled3, -17.36, -43.68, 0, 2);
    var clotheshanging5 = clotheshanging.clone();
    // _hotload.add(clotheshanging5);
    hotloadAdd(firsthotload, false, clotheshanging5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clotheshanging5, -17.36, -43.76, 0.08, 2);
    OPENWORLD.Space.objTurn(clotheshanging5, 90);
    var clotheshanging6 = clotheshanging3.clone();
    //   _hotload.add(clotheshanging6);
    hotloadAdd(firsthotload, false, clotheshanging6);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clotheshanging6, -17.38, -43.83, 0.08, 2);
    OPENWORLD.Space.objTurn(clotheshanging6, 90);
    var basket7 = basket.clone();
    //   _hotload.add(basket7);
    hotloadAdd(firsthotload, false, basket7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket7, -17.36, -43.84, 0.00, 2);
    var pillow3 = pillow.clone();
    //  _hotload.add(pillow3);
    hotloadAdd(firsthotload, false, pillow3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pillow3, -17.29, -43.81, 0.00, 2);
    OPENWORLD.Space.objTurn(pillow3, 0);
    var pot13 = pot.clone();
    hotloadAdd(firsthotload, false, pot13);
    //_hotload.add(pot13);
    //var pillow3 = pillow.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot13, -17.35, -43.76, 0,
        2); //-16.79, -45.47,0.0,2);//-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);
    var bedding2 = bedding.clone();
    //_hotload.add(bedding2);
    hotloadAdd(firsthotload, false, bedding2);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        bedding2, -17.26, -43.73, 0,
        2); //-16.79, -45.47,0.0,2);//-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);
    OPENWORLD.Space.objTurn(bedding2, 0);
    var pillow4 = pillow3.clone();
    // _hotload.add(pillow4);
    hotloadAdd(firsthotload, false, pillow4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pillow4, -17.3, -43.73, 0.00, 2);
    var basket8 = basket.clone();
    //  _hotload.add(basket8);
    hotloadAdd(firsthotload, false, basket8);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        basket8, -16.94, -43.78, 0.00, 2);
    var mat5 = mati.clone();
    //  _hotload.add(mat5);
    hotloadAdd(firsthotload, false, mat5);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        mat5, -16.99, -43.88, 0, 2);
    OPENWORLD.Space.objTurn(mat5, 0);
    var matrolled4 = matrolled.clone();
    // _hotload.add(matrolled4);
    hotloadAdd(firsthotload, false, matrolled4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        matrolled4, -16.91, -43.94, 0, 2);
    var amphora14 = amphora.clone();
    // _hotload.add(amphora14);
    hotloadAdd(firsthotload, false, amphora14);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora14, -16.91, -43.83, 0.00, 2);
    var clotheshanging7 = clotheshanging.clone();
    // _hotload.add(clotheshanging7);
    hotloadAdd(firsthotload, false, clotheshanging7);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        clotheshanging7, -17.01, -43.75, 0.08, 2);
    OPENWORLD.Space.objTurn(clotheshanging7, 0);
    var pot14 = pot.clone();
    //_hotload.add(pot14);
    hotloadAdd(firsthotload, false, pot14);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        pot14, -17.04, -43.76, 0,
        2); //-16.79, -45.47,0.0,2);//-16.86, -45.41,0,2);//-17.02, -45.44, 0.0, 2); // 3.2,2.5, 0.0);
    var amphora15 = amphora.clone();
    //_hotload.add(amphora15);
    hotloadAdd(firsthotload, false, amphora15);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        amphora15, -17.00, -43.74, 0.00, 2);
    var manger4 = manger.clone();
    //_hotload.add(manger4);
    hotloadAdd(firsthotload, false, manger4);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        manger4, -17.32, -44.49, 0.00, 2);
    OPENWORLD.Space.objTurn(manger4, 100);
    /*var hay14 = hay.clone();
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        hay14, -17.32, -44.49, 0.02, 2);
    // _hotload.add(hay14);
    hotloadAdd(firsthotload, false, hay14);*/
    instancedHays.place(0,-17.32, -44.49, 0.02);// scale:THREE.Vector3(0.04,0.04,0.04));//,5);

    var millstone3 = millstone.clone();
    // _hotload.add(millstone3);
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        millstone3, -17.09, -44.65, 0, 2);
    hotloadAdd(firsthotload, false, millstone3);
    // }

    instancedHays.finish();

  }
}
