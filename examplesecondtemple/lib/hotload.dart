// Brings all hotloads together to be loaded one after the other
// Allows journeys to be seperated into different hotloads
part of 'SecondTemplePage.dart';

extension HotloadExt on SecondTemplePageState {

  hotloadAdd(firsthotload, hotload, obj) {
    // if (firsthotload||!hotload) {
    //     threeJs.scene.add(obj);
    //  } else
    _hotload.add(obj);
  }

  hotload(firsthotload) async
  {
    print("hotload started");
    // Clear the hotload including things like portals, doorways, obstacles
    OPENWORLD.System.resetHotload(_hotload);
    OPENWORLD.Portals.portals.clear();

    doorways.clear();

    firsthotload = false;
    Glob.bathingstep=-1;
    //var pilgrimspeed = 0.025;

    waterlist.clear();

   // blocklist.clear();
    OPENWORLD.Obstacles.obstacles.clear();

    OPENWORLD.Config
        .config['positions']['poolpositions'][1]['positions'].clear();

    // load outer area of jerusalem
    hotloadOuter(firsthotload);

  //  hotloadSprites(firsthotload);

    // load lowercity
     await hotloadLowercity(firsthotload);
     addProgress(inc:10);

    // load pilgrims road
    await hotloadPilgrimsroad(firsthotload);
    addProgress(inc:10);

    instancedColumns.reset();

    // load second temple
    await hotloadSecondtemple(firsthotload);
    addProgress(inc:10);

    if (!Glob.roamsukkot) { // For some reason with sukkot, some people are at a 45 degreee angle - I think because of the upddate pool objects in hearth so just turn it off
      // load hearth but not if its sukkot journey roam
      await hotloadHearth(firsthotload);
      addProgress(inc: 10);
    }
    instancedColumns.finish();

    // Load siloam
    await hotloadSiloam(firsthotload);
    addProgress(inc:10);

    // load womens gate journey
    await hotloadWomensgate(firsthotload);
    addProgress(inc:10);

    // load bethpage journey
    await hotloadBethphage(firsthotload);
    addProgress(inc:10);

    // Every hotloadXXX() above has now finished re-adding its own pool
    // positions for this cycle. createPoolObjects() (called individually
    // inside several of them) only ever ADDS new entries - it has no way
    // to know a position map is gone after the poolpositions[1]
    // ['positions'].clear() at the top of this function, so a stale
    // Position from the PREVIOUS hotload cycle (e.g. the rabbi at his old
    // coordinates) would otherwise keep sitting alongside the new one
    // forever, accumulating further with every subsequent hot reload.
    // updatePoolObjects() reconciles that: it releases anything whose
    // underlying map is no longer present, then re-runs createPoolObjects()
    // to pick up whatever's new - safe to call here since everything that
    // should exist this cycle has already been added by this point.
   // print('lennnn'+OPENWORLD.Config.config['positions']['poolpositions'][1]['positions'].length.toString());
    await OPENWORLD.Config.updatePoolObjects();

    OPENWORLD.Config.forceShowPoolObjects();

  }
}
