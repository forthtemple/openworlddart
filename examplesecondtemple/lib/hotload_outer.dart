// Code for places outside jersualem
part of 'SecondTemplePage.dart';

extension HotloadOuterExt on SecondTemplePageState {
  hotloadOuter(firsthotload) async {

    //  psephinus tower


    var soldier24ii = await OPENWORLD.Actor.copyActor(
        soldier24, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier24ii,-66-0.1, 34.36, 0,
        3, lerpopacity: 1);
    _hotload.add(soldier24ii);
    OPENWORLD.Space.objTurn(soldier24ii,285);
    //OPENWORLD.Model.setTexture(soldier24, "assets/actors/soldier/head4.jpg",groupname:"soldier_3");

    var soldier2ii = await OPENWORLD.Actor.copyActor(
        soldier2, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier2ii, -66.15, 33.89,0,//-13.64, 62.71, 0,
        5,  lerpopacity: 1);
    _hotload.add(soldier2ii);
    OPENWORLD.Space.objTurn(soldier2ii,285);


    var maxx=-66.0, miny=14.4, minx= -89.0, maxy= 67.0;//11.3;
    var boundarywidth3=maxx-minx;
    var boundarylength3=maxy-miny;

    var grassposx2=(maxx+minx)/2;
    var grassposy2=(maxy+miny)/2;

    List<List<double>> excludeSquares = [];

    var diff=0.4;
    var points=OPENWORLD.Math.interpolateByIncrement([[-66.6,34.3],[-89.75,41.8]], diff);
    for (var point in points) {
      if (point[1]<maxy&&point[1]>miny) //44&&point[0] >= minx && point[0] <= maxx && point[1] >= miny &&
        //     point[1] <= maxy) {
        // if (i==0)
        //   print("point:"+point.toString());
        excludeSquares.add(
            [
              point[0],
              point[1],
              0.4,
              diff,
            ]);
      // } // bethphagepos),  diff, 0.4]);

    }

    var grassiii = Vegetation();
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
           PlantSpec(
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
          //   edgeFadeWidth: 2,
             edgeFadeWidth: 5,
            pitchVariation: 0.0, //17
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


    // Essene gate
   soldier24ii = await OPENWORLD.Actor.copyActor(
        soldier24, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier24ii,-45.56, -46.82, 0,
        3, lerpopacity: 1);
    _hotload.add(soldier24ii);
    OPENWORLD.Space.objTurn(soldier24ii,241);
    //OPENWORLD.Model.setTexture(soldier24, "assets/actors/soldier/head4.jpg",groupname:"soldier_3");

    soldier2ii = await OPENWORLD.Actor.copyActor(
        soldier2, randomduration: 0.1,
        action: "idlehold"); //, action:"idlehold");
    OPENWORLD.Space.worldToLocalSurfaceObjHide(
        soldier2ii, -45.39,-47.26,0,//-13.64, 62.71, 0,
        5,  lerpopacity: 1);
    _hotload.add(soldier2ii);
    OPENWORLD.Space.objTurn(soldier2ii,241);

    //blocklist.add(
    //    [-45.5, -46.8,0.5]); //-25.51, 116.5,0.2]);//,0.5]);

    OPENWORLD.Obstacles.createObstacle(-45.13, -46.8-0.08,0.5,0.5);//,marker:_hotload);
//    OPENWORLD.Obstacles.createObstacle(-45.5, -46.8,0.5,0.5);

    maxx=-38; miny=-60.7; minx= -60; maxy= -50.1;
    boundarywidth3=maxx-minx;
    boundarylength3=maxy-miny;

    grassposx2=(maxx+minx)/2;
    grassposy2=(maxy+miny)/2;

    excludeSquares = [];


    diff=0.5;
    points=OPENWORLD.Math.interpolateByIncrement([
      [-45.78,-47.15],
      [-46.6,-50],
      [-44.43,-52.28],
      [-38.06,-53.9]
    ], diff);
    for (var point in points) {
      if (point[1]<maxy&&point[1]>miny) //44&&point[0] >= minx && point[0] <= maxx && point[1] >= miny &&
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
      // } // bethphagepos),  diff, 0.4]);

    }

   grassiii = Vegetation();
   grassgroupii = await grassiii.createGrass(threeJs.camera,
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
          PlantSpec(
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


  }
}
