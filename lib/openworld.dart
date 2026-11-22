import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:image/image.dart' as im;

//import 'package:audioplayers/audioplayers.dart';
import 'package:openworld/updateable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'asset_pack.dart';
//import 'package:openworld_gl/native-array/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:just_audio/just_audio.dart';
//import 'package:openworld/three_dart/three3d/objects/index.dart';
import 'package:three_js/three_js.dart' as THREE;

import 'dart:math' as math;

//import 'package:three_js/three_js_jsm.dart' as THREE_JSM;
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:three_js_helpers/utils/skeleton_utils.dart';

//import 'package:xml2json/xml2json.dart';
import 'package:path_provider/path_provider.dart';
import 'objects/fire.dart';
import 'ms3d/ms3d_openworld.dart';
export 'ms3d/ms3d_openworld.dart';
export 'ms3d/ms3d.dart';
export 'ms3d/smd.dart';
export 'ms3d/ms3d_terrain.dart';
import 'surface_grid.dart';

class Space {
  static late THREE.Scene _scene;
  static late THREE.Group mesh;
  static late THREE.Object3D _roof;
  static late Map<int, THREE.Object3D>
  _surfaces; // Is a list because in future might have levels
  static late THREE.Object3D _walls;
  static late Map<THREE.Object3D, THREE.BoundingSphere> _wallBoundingSpheres =
      {};

  // Wall meshes whose name contains "boundingbox" get an axis-aligned box
  // pre-filter here instead of a sphere - see _computeWallBounds(). A long
  // thin wall is a much tighter fit inside a box than a sphere (a sphere's
  // diameter has to match the wall's longest dimension, which makes it
  // hugely over-inclusive across the wall's thin axis), so this is opt-in
  // per mesh via naming rather than a blanket switch, in case some wall
  // geometry (a round column, say) actually fits a sphere better.
  static late Map<THREE.Object3D, THREE.BoundingBox> _wallBoundingBoxes = {};
  static late THREE.Raycaster _raycaster;
  static late List _lerpobjects;
  static late List _lerpobjectssurface;
  static late List _lerpturnobjects;
  static late Map _faceobjects;
  static late List<THREE.Object3D> _hideobjects;
  static late List _hidemeshobjects;

  static double wallintersectoffsetz = 0.017; //0.006;//6;  // 0.005
  // Spatial cache for terrain raycasts.
  // Quantises x,z to a 0.02-unit grid so nearby queries reuse the same result.
  // The terrain is static so cached values never go stale.
  // Key format: "level:rx:rz"  where rx/rz are integers (coord * 50).
  static late Map<String, THREE.Intersection> _raycastCache = {};
  static const double _raycastGridSize =
      0.02; // world units per cell -  originally 0.02
  static const int _raycastCacheMaxSize = 20000; // ~3 MB at ~150 bytes/entry

  // Fast downward terrain lookups (see surface_grid.dart). One grid per
  // level, built the first time that level is queried. Set to false to go
  // back to raycasting + _raycastCache.
  static bool useSurfaceGrid = true;
  static final Map<int, SurfaceGrid> _surfaceGrids = {};

  // Cache of terrain normals for getTerrainPitch (used by normalize2world).
  // Quantised to a _normalGridSize grid in x,z plus 1-unit height bands so
  // stacked surfaces (eg a bridge over a path) don't share an entry.
  static Map<String, THREE.Vector3> _normalCache = {};
  static const double _normalGridSize = 0.2;
  static const int _normalCacheMaxSize = 20000;

  static init(mesh, scene) {
    _scene = scene;
    Space.mesh = mesh;
    _lerpobjects = [];
    _lerpobjectssurface = [];
    _lerpturnobjects = [];
    _hideobjects = [];
    _hidemeshobjects = [];
    _faceobjects = {};
    _raycastCache = {};
    _surfaceGrids.clear();
    _normalCache = {};

    // Get all meshes with the word surface in them for surface intersection
    _surfaces = {};
    var maxlevel = -1;
    var minlevel = 0;
    for (var i = 0; i < mesh.children.length; i++) {
      var obj = mesh.children[i];
      int ind = obj.name.indexOf("surface");
      if (ind != -1) {
        var level = 0;

        if (ind + 7 < obj.name.length) {
          //print("vvv"+obj.name);
          if (obj.name[ind + 7] == '-') {
            //  print('xxxfound');
            if (ind + 8 < obj.name.length &&
                Math.isNumeric(obj.name[ind + 8])) {
              level = -int.parse(obj.name[ind + 8]);
            }
          } else if (Math.isNumeric(obj.name[ind + 7])) {
            level = int.parse(obj.name[ind + 7]);
          }
        }
        if (level > maxlevel)
          maxlevel = level;
        else if (level < minlevel)
          minlevel = level;
      }
    }

    // Basically going through each level, cloning the entire mesh then deleting whatever doesn't match that level
    for (var level = minlevel; level <= maxlevel; level++) {
      var _surface = mesh.clone();
      for (var i = _surface.children.length - 1; i >= 0; i--) {
        var obj = _surface.children[i];
        //print("mesh name"+obj.name);
        var ind = obj.name.indexOf("surface"); //== -1) {
        if (ind != -1) {
          var grouplevel = 0;
          if (ind + 7 < obj.name.length) {
            if (obj.name[ind + 7] == '-') {
              if (ind + 8 < obj.name.length &&
                  Math.isNumeric(obj.name[ind + 8])) {
                grouplevel = -int.parse(obj.name[ind + 8]);
              }
            } else if (Math.isNumeric(obj.name[ind + 7])) {
              grouplevel = int.parse(obj.name[ind + 7]);
            }
          }
          if (grouplevel != level) _surface.remove(obj);
        } else
          _surface.remove(obj);
      }
      _surfaces[level] = _surface;
      //      _surfaces.add(_surface);
    }



    // Get all meshes with the word wall in them for wall intersection
    _walls = mesh.clone();
    for (var i = _walls.children.length - 1; i >= 0; i--) {
      var obj = _walls.children[i];
      if (!obj.name.contains("wall")) {
        //==-1) {
        _walls.remove(obj);
      } else {
        // print("leave"+obj.name.toString());
      }
    }
    // Cache a world-space bounding sphere (or box, for meshes opted in by
    // name - see _computeWallBounds()) for each wall mesh once, up front.
    // wallIntersectDistance() runs a full triangle-level raycast against
    // every wall mesh every time it's called; walls are static (never move
    // or deform), so precomputing this here means the cheap ray/sphere or
    // ray/box pre-filter used there costs nothing beyond this one-time setup.
    _computeWallBounds();
    // Get the roof meshes
    _roof = mesh.clone(); // why must the roof be cloned????
    for (var i = _roof.children.length - 1; i >= 0; i--) {
      var obj = _roof.children[i];
      if (!obj.name.contains("roof")) {
        _roof.remove(obj);
      } else {
        // print("rooofs"+obj.name);
      }
    }

    for (var i = 0; i < mesh.children.length; i++) {
      var obj = mesh.children[i];
      // print("distt"+obj.name);
      if (obj.name.contains("hide")) {
        var split = obj.name.split("hide");
        if (split.length > 1 && split[1].length > 0) {
          var cameradiststr = "";
          var ok = true;
          //print('nnn'+split[1]);
          for (var j = 0; j < split[1].length; j++) {
            final RegExp digitOnly = RegExp(r'^\d+$');
            if (ok && digitOnly.hasMatch(split[1][j]) || split[1][j] == '.')
              cameradiststr += split[1][j];
            else
              ok = false;
          }
          THREE.BufferGeometry? geom = obj.geometry;
          //print("steps geom "+geom!.attributes['position'].toString());
          var positionAttribute = geom!.attributes['position'];
          var vertex = new THREE.Vector3();
          var xsum = 0.0, ysum = 0.0, zsum = 0.0;
          for (var j = 0; j < positionAttribute.count; j++) {
            // Get the x, y, z components of the current vertex

            vertex.fromBuffer(positionAttribute, j);

            // Now 'vertex' contains the position of the current vertex in local space
            // You can perform operations with 'vertex' here
            //print('vert'+i.toString()+' '+vertex.x.toString());
            xsum += vertex.x;
            ysum += vertex.y;
            zsum += vertex.z;
          }

          var xcenter = xsum / positionAttribute.length;
          var zcenter = zsum / positionAttribute.length;
          obj.extra['cameradist'] = double.parse(cameradiststr);
          obj.extra['xworldhide'] = xcenter;
          obj.extra['yworldhide'] = -zcenter;
          //print("vvvvv"+obj.extra['xworldhide'].toString()+" "+obj.extra['yworldhide'].toString());
          if (_hidemeshobjects.indexOf(obj) == -1) {
            _hidemeshobjects.add(obj);
          }
        }
      }
    }
    _raycaster = THREE.Raycaster();
  }

  static THREE.Raycaster getRaycaster() {
    return _raycaster;
  }

  static getSurfaces() {
    return _surfaces;
  }

  /// local coords to world coords
  static localToWorld(x, y, z) {
    return new THREE.Vector3(x.toDouble(), -z.toDouble(), y.toDouble());
  }

  /// get world coords of an object
  /// Note, z is not in world coords
  static THREE.Vector3 localToWorldObj(THREE.Object3D object) {
    return localToWorld(
      object.position.x,
      object.position.y,
      object.position.z,
    ); //new THREE.Vector3(y,z,-x);
  }

  /// convert world coords to local cords
  static worldToLocal(x, y, z) {
    return new THREE.Vector3(x, z, -y);
  }

  /// detect an intersection of a point with surface meshes looking down with local coordinates
  /// You are ignoring localy
  static localIntersectSurface(localx, localy, localz, {level = 0, nocache}) {
    if (_surfaces != null &&
        _surfaces.length > 0 &&
        _surfaces[0]?.children != null) {
      // THREE.Intersection
      var intersection = localIntersectSurfaceVector(
        localx,
        localy,
        localz,
        level: level,
        nocache: nocache,
      );
      // THREE.Face? face=intersection.face;

      if (intersection != null)
        return intersection.point?.y;
      else
        return 0;
      // start at camera level and go up if dont find an intersection
    }

    return 0;
  }

  // localy is being ignored!
  // nocache is a fudge for case where want exact intersection
  static localIntersectSurfaceVector(
    localx,
    localy,
    localz, {
    level = 0,
    nocache,
  }) {
    if (_surfaces == null ||
        _surfaces.length <= level ||
        _surfaces[level]?.children == null)
      return null;

    // Fast path: exact result from the 2D triangle grid, no cache needed.
    if (useSurfaceGrid) {
      final grid = _surfaceGrids[level] ??= SurfaceGrid.build(
        _surfaces[level]!.children,
        _raycaster.layers,
      );
      return grid.intersectDown(
        (localx as num).toDouble(),
        Camera._camera.position.y + 100,
        (localz as num).toDouble(),
      );
    }

    // Quantise to grid so nearby positions share a cache entry.
    // Multiplying by 1/_raycastGridSize and truncating gives the cell index.
    if (nocache == null || !nocache) {
      final double invGrid = 1.0 / _raycastGridSize;
      //print("uuuu"+localx.toString()+" "+invGrid.toString());
      final int rx = (localx * invGrid).truncate();
      final int rz = (localz * invGrid).truncate();
      final String key = '$level:$rx:$rz';

      final cached = _raycastCache[key];
      if (cached != null) return cached;

      // Cache miss — do the actual raycast (up to 3 attempts at increasing height)
      _raycaster.set(
        THREE.Vector3(localx, Camera._camera.position.y + 100, localz),
        //THREE.Vector3(localx, Camera._camera.position.y + i * 10 + 0.3, localz),
        THREE.Vector3(0, -1, 0),
      );
      List<THREE.Intersection> intersects = _raycaster.intersectObjects(
        _surfaces[level]!.children,
        false,
      );
      if (intersects.length > 0) {
        // Evict oldest entries if the cache is getting too large.
        // Simple strategy: clear half the cache when the limit is hit.
        // This is rare — the terrain is large and walks are localised.

        if (_raycastCache.length >= _raycastCacheMaxSize) {
          final keys = _raycastCache.keys.toList();
          for (var k = 0; k < keys.length ~/ 2; k++) {
            _raycastCache.remove(keys[k]);
          }
        }
        _raycastCache[key] = intersects[0];

        return intersects[0];
      }
    } else {
      _raycaster.set(
        THREE.Vector3(localx, Camera._camera.position.y + 100, localz),
        //THREE.Vector3(localx, Camera._camera.position.y + i * 10 + 0.3, localz),
        THREE.Vector3(0, -1, 0),
      );
      List<THREE.Intersection> intersects = _raycaster.intersectObjects(
        _surfaces[level]!.children,
        false,
      );
      if (intersects.length > 0) {
        return intersects[0];
      }
    }
    //  }
    return null;
  }

  /// Rebuild the terrain grids, e.g. if a surface mesh was moved or changed
  /// after startup. They are rebuilt lazily on the next query.
  static void rebuildSurfaceGrids() {
    _surfaceGrids.clear();
    _normalCache = {};
  }

  /// Debug check: compares the grid against the real raycaster at [samples]
  /// random points on [level] and prints any mismatches plus timings.
  /// Call once after the scene has loaded, e.g. Space.verifySurfaceGrid();
  static void verifySurfaceGrid({
    int level = 0,
    int samples = 2000,
    double tolerance = 0.001,
  }) {
    if (_surfaces[level] == null) {
      print('verifySurfaceGrid: no surfaces for level $level');
      return;
    }
    final children = _surfaces[level]!.children;
    final grid = _surfaceGrids[level] ??= SurfaceGrid.build(
      children,
      _raycaster.layers,
    );

    if (grid.isEmpty) {
      print('verifySurfaceGrid: level $level has no hittable triangles');
      return;
    }
    final rnd = math.Random(1);
    final originY = Camera._camera.position.y + 100;
    int mismatches = 0, hitsBoth = 0, missBoth = 0;
    final swGrid = Stopwatch(), swRay = Stopwatch();
    for (int i = 0; i < samples; i++) {
      final x = grid.minX + rnd.nextDouble() * (grid.maxX - grid.minX);
      final z = grid.minZ + rnd.nextDouble() * (grid.maxZ - grid.minZ);

      swGrid.start();
      final g = grid.intersectDown(x, originY, z);
      swGrid.stop();

      swRay.start();
      _raycaster.set(THREE.Vector3(x, originY, z), THREE.Vector3(0, -1, 0));
      final r = _raycaster.intersectObjects(children, false);
      swRay.stop();

      final rHit = r.isNotEmpty ? r[0] : null;
      if (g == null && rHit == null) {
        missBoth++;
      } else if (g != null &&
          rHit != null &&
          (g.point!.y - rHit.point!.y).abs() <= tolerance) {
        hitsBoth++;
      } else {
        mismatches++;
        if (mismatches <= 10) {
          print(
            'verifySurfaceGrid mismatch at x=$x z=$z '
            'grid=${g?.point?.y} ray=${rHit?.point?.y} '
            'gridObj=${g?.object?.name} rayObj=${rHit?.object?.name}',
          );
        }
      }
    }
    print(
      'verifySurfaceGrid level $level: $hitsBoth match, $missBoth both miss, '
      '$mismatches mismatches. grid ${(swGrid.elapsedMicroseconds / samples).toStringAsFixed(1)}us/query, '
      'raycast ${(swRay.elapsedMicroseconds / samples).toStringAsFixed(1)}us/query',
    );
  }

  // Guess the level of an object by finding the level closest to this object
  // This will not work if you do something like worldToLocalObj(actor,x,y, 50.0,0.1,level:0, delay:1.0) which could give it the wrong level
  static getObjLevel(object) {
    //var pos=localToWorldObj(object);
    var closestlevel = -1;
    var closestdist = 999999.0;
    for (var level = 0; level < _surfaces.length; level++) {
      var intersect = localIntersectSurfaceVector(
        object.position.x,
        999.9,
        object.position.z,
        level: level,
      );

      if (intersect != null) {
        var dist = (intersect.point?.y - object.position.y).abs();
        if (dist < closestdist) {
          closestlevel = level;
          closestdist = dist;
        }
      }
    }
    return closestlevel;
  }


  /// world coords & camera z that intersects with surface with world coords [x] and [y] and [level]
  /// [nocache] is a fudge to force getting intersect point without using the cache - eg if need more accurate height
  static worldIntersectSurface(x, y, {level = 0, nocache}) {
    var localx = x;
    var localz = -y;
    return localIntersectSurface(
      localx,
      Camera._camera.position.y,
      localz,
      level: level,
      nocache: nocache,
    );
  }

  /// local coords of world coords intersection with surface looking down
  static worldToLocalSurface(x, y, z, {level = 0, nocache}) {
    var localx = x;
    var localy = worldIntersectSurface(x, y, level: level, nocache: nocache);
    var localz = -y;
    return new THREE.Vector3(localx, localy + z.toDouble(), localz);
  }

  /// set an [object] [turn] so it is normal to the terrain at point [worldx] [worldy], [worldz]. For example a car at a certain angle on a steep hill
  static objNormalize2World(
    THREE.Object3D object, {
    turn,
    worldx,
    worldy,
    worldz,
  }) {
    // getTurn returns the raw rotation.y yaw (-A-180); convert to the world angle A that the code below expects
    if (turn == null) turn = Math.standardAngle(-Space.getTurn(object) - 180);
    //  This make object completely flat on the terrain including roll

    // if (!(object is THREE.Camera))
    //   turn=;
    var pitch = getTerrainPitch(
      object,
      turn: !(object is THREE.Camera) ? -turn - 180 : turn,
      worldx: worldx,
      worldy: worldy,
      worldz: worldz,
    );

    object.rotation.x = THREE.MathUtils.degToRad(-pitch);
    // object.rotation.y = THREE.MathUtils.degToRad(Math.standardAngleSigned(-turn));
    object.rotation.y = THREE.MathUtils.degToRad(
      Math.standardAngleSigned(object is THREE.Camera ? -turn : -turn - 180),
    );
    object.rotation.z = THREE.MathUtils.degToRad(0.0);
    object.rotation.order = THREE.RotationOrders.yxz;
    object.updateMatrix();

  }

  /// Set position of object to have world coords [x],[y],[z] [level] where [z] is relative to the surface intersection
  /// [delay] position in delay seconds
  static worldToLocalSurfaceObj(object, x, y, z, {normalize2world, level = 0, delay}) {
    if (delay != null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        //print("play "+path.toString());
        worldToLocalSurfaceObj(
          object,
          x,
          y,
          z,
          level: level,
          normalize2world: normalize2world,
        );
      });
    } else {
      // if being lerped somewhere else then remove it from the lerp
      var ind = _lerpobjects.indexOf(object);
      if (ind >= 0) _lerpobjects.removeAt(ind); //, 1);
      //        _lerpobjects.splice(ind, 1);
      var position = worldToLocalSurface(
        x.toDouble(),
        y.toDouble(),
        z.toDouble(),
        level: level,
        nocache: object.extra.containsKey('nocache'),
      );
      object.position.setValues(position.x, position.y, position.z);
      if (normalize2world != null && normalize2world) {
        //if (BaseObject.getName(object)=='donkeygroup3i')
        //  print("worldToLocalSurfaceObj donkey");

        objNormalize2World(object); //,worldx:x,worldy:y,worldz:z);
        //  var pitchyaw=worldSurfacePitchYaw(x,y,z);
        // setTurnPitchRoll(object, Space.getObjTurn(object),pitchyaw[0],pitchyaw[1]);
        //   setTurnPitchRoll(object,0,pitchyaw[0],pitchyaw[1]);
      }
    }
  }

  // Set an [object] [z] value intersecting with the terrain
  static setZ(object, z, {level = 0, delay}) {
    if (delay != null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        setZ(object, z, level: level);
      });
    } else {
      var pos = localToWorldObj(object);
      worldToLocalSurfaceObj(object, pos.x, pos.y, z.toDouble(), level: level);
    }
  }

  // Lerp an [object] [z] value intersecting with the terrain lerping in [time] seconds and [delay] seconds
  static setZLerp(object, z, time, {level = 0, delay}) {
    var pos = localToWorldObj(object);
    // var currentz=getZ(object);
    worldToLocalSurfaceOnlyObjLerp(
      object,
      pos.x,
      pos.y,
      z,
      time,
      level: level,
      delay: delay,
    );
  }


  /// Hide an [object] if its over [cameradist] away from [x],[y] and [z] [level] otherwise show it
  /// [lerpopacity] is time to lerp opacity from 1 to 0 so doesnt suddenly hide
  /// [lerplight] time to lerp any  light in [object] to on or off so isn't sudden when you move away or closer to a light source
  static worldToLocalSurfaceObjHide(
    object,
    num x,
    num y,
    num z,
    num cameradist, {
    num? lerpopacity,
    num? lerplight,
    int level = 0,
    bool? normalize2world,
  }) {
    //    lerplight=null;
    object.extra['cameradist'] = cameradist;
    if (lerpopacity != null) object.extra['lerpopacity'] = lerpopacity;
    if (lerplight != null) object.extra['lerplight'] = lerplight;
    if (_hideobjects.indexOf(object) == -1) {
      _hideobjects.add(object);
    }
    worldToLocalSurfaceObj(
      object,
      x.toDouble(),
      y.toDouble(),
      z.toDouble(),
      normalize2world: normalize2world,
      level: level,
    );
  }

  /// Stop hiding the [object] if its away from the camera
  static removeObjFromHide(object) {
    if (_hideobjects.contains(object)) _hideobjects.remove(object);
  }

  /// Is this [object] in hide
  static objIsHide(object) {
    return _hideobjects.contains(object);
  }

  /// Set the [object] hide [dist]
  static setObjHideDist(object, num dist) {
    object.extra['cameradist'] = dist.toDouble();
  }

  /// Add a previously hidden [object] back to be being hidden. Use [dist] to change it to something different to what it was before
  static readdObjFromHide(object, {dist}) {
    if (dist != null) setObjHideDist(object, dist);
    if (!_hideobjects.contains(
      object,
    )) //&&object.extra.containsKey('cameradist')
      _hideobjects.add(object);
  }

  /// Set [object] to lerp its opacity in hide within [lerpopacity] seconds
  static setObjLerpOpacity(object, lerpopacity) {
    object.extra['lerpopacity'] = lerpopacity;
  }

  /// Set [object] to lerp its light intensity in hide within [lerplight] seconds
  static setObjLerpLight(object, lerplight) {
    object.extra['lerplight'] = lerplight;
  }

  /// move [object] to [x],[y],[z], [levle] taking [time] seconds - lerp to the position
  /// [delay] lerp for [delay] seconds
  static worldToLocalSurfaceObjLerp(object, x, y, z, time, {level = 0, delay}) {
    if (delay != null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        worldToLocalSurfaceObjLerp(
          object,
          x,
          y,
          z,
          time,
          level: level,
        ); //,normalize2world:normalize2world);
      });
    } else {
      THREE.Vector3 position = worldToLocalSurface(x, y, z, level: level);
      //object.position.set(position.x, position.y, position.z);
      object.extra['lerpfromtime'] = System.currentMilliseconds();
      object.extra['lerpcurrenttime'] = System.currentMilliseconds();
      object.extra['lerptotime'] = time;
      //  object.extra['lerpnormalize2world'] = normalize2world;
      //  object.extra['lerptolevel'] = level;   because its not surface doesn't care about the level
      object.extra['lerpinitialpos'] = object.position.clone();
      object.extra['lerpfinalpos'] = position;
      // object.extra['lerpz']=(position.y-object.position.y).abs()>0.4;

      //if (_lerpobjects.indexOf(object) < 0)
      if (!_lerpobjects.contains(object)) _lerpobjects.add(object);
    }
  }

  /// lerp [object] to [x],[y],[z],[level] taking [time] seconds only along the terrain surface - useful if moving object across hilly terrain
  ///                        note, z is not lerped -
  /// [delay] lerp for [delay] seconds
  static worldToLocalSurfaceOnlyObjLerp(
    THREE.Object3D object,
    x,
    y,
    z,
    time, {
    /*normalize2world,*/ level = 0,
    normalize2world = false,
    delay,
  }) {
    if (delay != null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        //print("play "+path.toString());
        worldToLocalSurfaceOnlyObjLerp(
          object,
          x,
          y,
          z,
          time,
          level: level,
          normalize2world: normalize2world,
        );
      });
    } else {
      // THREE.Vector3 position = worldToLocalSurface(x, y, z);
      //object.position.set(position.x, position.y, position.z);
      object.extra['lerpsurfacefromtime'] = System.currentMilliseconds();
      object.extra['lerpsurfacecurrenttime'] = System.currentMilliseconds();
      object.extra['lerpsurfacetotime'] = time;
      object.extra['lerpsurfacetolevel'] = level;
      object.extra['lerpsurfacenormalize2world'] = normalize2world;
      object.extra['lerpsurfaceinitialpos'] = localToWorldObj(
        object,
      ); //object.position.clone();
      //localy-localintersecty is world z value - so you are lerping from current world z to new world z value
      var localy = object.position.y;
      var localintersecty = worldIntersectSurface(
        object.extra['lerpsurfaceinitialpos'].x,
        object.extra['lerpsurfaceinitialpos'].y,
        level: level,
      );
      object.extra['lerpsurfaceinitialpos'].z =
          localy - localintersecty; //z.toDouble();
      object.extra['lerpsurfacefinalpos'] = THREE.Vector3(
        x.toDouble(),
        y.toDouble(),
        z.toDouble(),
      );
      // object.extra['lerpz']=(position.y-object.position.y).abs()>0.4;

      //if (_lerpobjects.indexOf(object) < 0)
      if (_lerpobjects.contains(object)) _lerpobjects.remove(object);
      if (!_lerpobjectssurface.contains(object))
        _lerpobjectssurface.add(object);
    }
  }

  /// Remove the [object] from movement lerping
  static removeObjectFromLerp(object) {
    if (_lerpobjects.contains(object)) _lerpobjects.remove(object);
  }

  /// Remove the [object] from movement surface lerping
  static removeObjectFromSurfaceLerp(object) {
    if (_lerpobjectssurface.contains(object))
      _lerpobjectssurface.remove(object);
  }

  /// Is the [object] being surface lerped?
  static isInSurfaceLerp(object) {
    return _lerpobjectssurface.contains(object);
  }

  ///  set [object] to have world coords [x],[y],[z] but not relative to the surface
  static worldToLocalObj(object, x, y, z) {
    var position = worldToLocal(x.toDouble(), y.toDouble(), z.toDouble());
    object.position.setValues(position.x, position.y, position.z);
  }

  /// Turn an [object] where [angle] 0 is facing north, 90 east in the world
  /// [normalize2world] means turn the object and have its pitch set to the terrain it sits on -eg a car on a steep hill should have a pitch matching the terrain
  static objTurn(THREE.Object3D object, angle, {normalize2world}) {
    // if lerping turn somewhere else then remove it
    var ind = _lerpturnobjects.indexOf(object);
    if (ind >= 0) {
      _lerpturnobjects.removeAt(ind);
    }
    //      _lerpturnobjects.splice(ind, 1);

    angle = Math.standardAngle(angle.toDouble());
    if (object is THREE.Camera)
      Camera.setTurn(angle);
    //object.rotation.y = (-angle ) * math.pi / 180;
    else {
      if (normalize2world != null && normalize2world)
        objNormalize2World(object, turn: angle);
      else
        object.rotation.y = (-angle - 180) * math.pi / 180;
    }
  }

  /// Roll an [object] by [angle] degrees
  static objRoll(THREE.Object3D object, double angle) {
    object.rotation.z = (-angle) * math.pi / 180;
  }

  /// Get an [object] roll in degrees
  static getRoll(object) {
    return THREE.MathUtils.radToDeg(object.rotation.z);
  }

  /// Get an [object] turn in degrees
  static getTurn(object) {
    if (object is THREE.Camera) {
      return Camera.turn; //-(180 * object.rotation.y / math.pi);
    } else {
      // Get the object's forward vector (-Z axis) in world space
      final forward = THREE.Vector3(0, 0, -1);
      forward.applyQuaternion(object.quaternion);

      // Project onto the XZ plane and compute yaw
      // atan2(-x, -z) maps Three.js's -Z-forward convention back to a clean angle
      final yawRadians = math.atan2(-forward.x, -forward.z);

      return THREE.MathUtils.radToDeg(yawRadians);
    }
    // return THREE.MathUtils.radToDeg(object.rotation.y);
    /*  var q = object.quaternion;

// 2. Calculate Yaw (Turn) in radians
    double turnRadians = math.atan2(2 * (q.w * q.y + q.x * q.z), 1 - 2 * (q.y * q.y + q.z * q.z));

// 3. Convert to Degrees
    return THREE.MathUtils.radToDeg(turnRadians);*/
  }

  /// Set pitch of an [object] by [angle] degrees
  static objPitch(THREE.Object3D object, double angle) {
    object.rotation.x = (-angle) * math.pi / 180;
  }

  /// Get pitch of [object] in degrees
  static getPitch(object) {
    return THREE.MathUtils.radToDeg(object.rotation.x);
  }

  /// Turn the [object] [angle] degrees lerping in [time] seconds
  /// [normalize2world] means it is pitched and rolled in line with the surface
  /// [delay] lerp for [delay] seconds
  static objTurnLerp(
    THREE.Object3D object,
    angle,
    time, {
    normalize2world,
    delay,
  }) {
    if (delay != null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        objTurnLerp(object, angle, time, normalize2world: normalize2world);
      });
    } else {
      object.extra['lerpfromtimeturn'] = System.currentMilliseconds();
      object.extra['lerptotimeturn'] = time.toDouble();
      object.extra['lerpnormalize2worldturn'] = normalize2world;
      //  print("normalize2worlduu"+normalize2world.toString());
      // So that say if initially 10 and finally 350 then will not lerp 340 degrees, instead 10 to -10 and vice versa
      //  var turna = getObjTurn(object); // 10         350
      var turna;
      //  if (normalize2world==null||!normalize2world)
      turna = getObjTurn(object); //  10         350
      // else {
      //  turna=Math.standardAngle(180-(180*object.rotation.y/math.pi+180));
      //  turna=Math.standardAngle(THREE.MathUtils.radToDeg(object.rotation.y)+180);
      //  turna = Math.standardAngle(
      //     getTurn(object));                // 10         350   getObjTurn(object);
      //if (!(object is THREE.Camera))
      // turna -= 180.0;
      // }
      var turnb = Math.standardAngle(angle.toDouble()); // 350       10
      if ((turna - turnb).abs() > (turna - (turnb - 360)).abs())
        turnb -= 360; //  350 become -10
      else if (((turna - 360) - turnb).abs() < (turna - turnb).abs())
        turna -= 360; //  350 become -10

      object.extra['lerpinitialturn'] = turna; //getObjTurn(object);// %360 ;
      // if init=10 and angle is 350 then make angle -10 so lerp doesn't go almost 360 deg
      // if init=360 and angle is 112
      //angle=angle%360;
      // if ((object.extra['lerpinitialturn']-angle).abs()>(object.extra['lerpinitialturn']-(angle-360)).abs())
      //   angle-=360;

      //   var prevlerpfinalturn=-9999.0;
      //  if (BaseObject.getName(object)=='donkeygroup3i'&&object.extra.containsKey('lerpfinalturn'))
      //   prevlerpfinalturn=object.extra['lerpfinalturn'];

      object.extra['lerpfinalturn'] = turnb; //Math.standardAngle(angle);
      // print("mmmm"+object.extra['lerpinitialturn'].toString()+" "+angle.toString());
      //  if (BaseObject.getName(object)=='donkeygroup3i')
      //    print("have set turn!!!"+angle.toString()+" "+Math.standardAngle(turna).toString()+" "+Math.standardAngle(getObjTurn(object)).toString()+" "+
      //             Math.standardAngle(turnb).toString()+" "+Math.standardAngle(prevlerpfinalturn).toString());

      if (_lerpturnobjects.indexOf(object) < 0) _lerpturnobjects.add(object);
    }
  }

  /// Is the [obj] currently being turned?
  static objIsTurnLerp(obj) {
    return _lerpturnobjects.contains(obj);
  }

  /// [Turn] [pitch] and [roll] [object] using euler so that is as expect eg if roll and then turn seperately then get different result than if turn then roll
  /// pitch x, turn is y, z is roll
  ///  yxz mean turn, then roll, then pitch
  static setTurnPitchRoll(THREE.Object3D object, turn, pitch, roll) {
    object.setRotationFromEuler(
      THREE.Euler(
        THREE.MathUtils.degToRad(-roll.toDouble()).toDouble(),
        THREE.MathUtils.degToRad(180.0 - turn).toDouble(),
        THREE.MathUtils.degToRad(-pitch.toDouble()).toDouble(),
        THREE.RotationOrders.yxz,
      ),
    ); //;'YXZ' ));
  }

  /*static setTurnPitchRoll2(THREE.Object3D object,turn,pitch,roll)
  {

      object.rotation.x=THREE.MathUtils.degToRad(pitch.toDouble());
      object.rotation.y= THREE.MathUtils.degToRad(180.0-turn).toDouble();
      object.rotation.z=THREE.MathUtils.degToRad(-roll.toDouble());

  }*/

  /// [object] faces [object2]
  /// [normalize2world] means [object] is turned relative to the terrain eg a car parked on a hill will turn with the correct pitch
  static faceObject(object, object2, {normalize2world}) {
    var angle = getAngleBetweensObjs(object, object2);
    objTurn(object, angle, normalize2world: normalize2world);
  }

  /// [object] faces [object2] taking [time] seconds to do it
  /// [normalize2world] means [object] is turned relative to the terrain eg a car parked on a hill will turn with the correct pitch
  static faceObjectLerp(object, object2, time, {normalize2world, delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        faceObjectLerp(object, object2, time, normalize2world: normalize2world);
      });
      BaseObject.addTimer(object, t);
    } else {
      var angle = getAngleBetweensObjs(object, object2);
      objTurnLerp(
        object,
        angle,
        time.toDouble(),
        normalize2world: normalize2world,
      );
    }
  }

  /// [object] faces point [x],[y]
  /// [normalize2world] means [object] is turned relative to the terrain eg a car parked on a hill will turn with the correct pitch
  static facePoint(object, x, y, {normalize2world, delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        facePoint(object, x, y, normalize2world: normalize2world);
      });
      BaseObject.addTimer(object, t);
    } else {
      var pos1 = localToWorldObj(object);
      pos1.z = 0.0;
      var pos2 = THREE.Vector3(x, y, 0.0); //localToWorld(x, y, 0);
      var angle = Math.getAngleBetweenPoints(pos1, pos2);
      // print("uuufacepointlerp"+angle.toString());
      objTurn(object, angle, normalize2world: normalize2world);
    }
  }

  /// [object] faces point [x],[y] taking [time] seconds to do it
  /// [normalize2world] means [object] is turned relative to the terrain eg a car parked on a hill will turn with the correct pitch
  static facePointLerp(object, x, y, time, {normalize2world = false, delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        facePointLerp(object, x, y, time, normalize2world: normalize2world);
      });
      BaseObject.addTimer(object, t);
    } else {
      var pos1 = localToWorldObj(object);
      pos1.z = 0.0;
      var pos2 = THREE.Vector3(x, y, 0.0); //localToWorld(x, y, 0);
      var angle = Math.getAngleBetweenPoints(pos1, pos2);
      //print("opfacepointlerp"+angle.toString()+" noramalize"+normalize2world.toString());
      objTurnLerp(
        object,
        angle,
        time.toDouble(),
        normalize2world: normalize2world,
      );
    }
  }

  /// [object] always faces [object2]
  /// [normalize2world] means [object] is turned relative to the terrain eg a car parked on a hill will turn with the correct pitch
  /// [delay] for [delay] seconds
  static faceObjectAlways(object, object2, {normalize2world, delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        faceObjectAlways(object, object2, normalize2world: normalize2world);
      });
      BaseObject.addTimer(object, t);
    } else if (object != object2) {
      // If the origturn not set then set it here

      /*  if (!(object is THREE.Camera) && !object.extra.containsKey('origturn')) {
        print('faceobjectalways turn'+getTurn(object).toString());
        object.extra['origturn'] = getTurn(object);
      }*/

      faceObjectLerp(
        object,
        object2,
        1,
        normalize2world: normalize2world,
      ); // so doenst just jump
      _faceobjects[object] = object2;
    }
  }

  /// Remove [object] from always facing the other object
  static removeFaceObjectAlways(object,{delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        removeFaceObjectAlways(object);
      });
      BaseObject.addTimer(object, t);
    } else if (_faceobjects.containsKey(object))
        _faceobjects.remove(object); //]=null;
  }

  /// The angle the [object] is facing - 0 is north
  static getObjTurn(object) {
    if (object is THREE.Camera) {
      return Camera.turn; //-(180 * object.rotation.y / math.pi);
    } else
      return Math.standardAngle(-(180 * object.rotation.y / math.pi + 180));
  }

  /// Angle between [object1] to [object2]
  static getAngleBetweensObjs(object1, object2) {
    var pos1 = localToWorldObj(object1);
    var pos2 = localToWorldObj(object2);
    return Math.getAngleBetweenPoints(pos1, pos2);
  }

  /// How far between [object1] and [object2]
  static getDistanceBetweenObjs(object1, object2) {
    var pos1 = localToWorldObj(object1);
    var pos2 = localToWorldObj(object2);
    return math.sqrt(
      (pos1.x - pos2.x) * (pos1.x - pos2.x) +
          (pos1.y - pos2.y) * (pos1.y - pos2.y) +
          (pos1.z - pos2.z) * (pos1.z - pos2.z),
    );
  }

  /// How far between [object1] and [object2] ignoring z axis
  static getDistanceBetweenObjs2D(object1, object2) {
    var pos1 = localToWorldObj(object1);
    var pos2 = localToWorldObj(object2);
    return math.sqrt(
      (pos1.x - pos2.x) * (pos1.x - pos2.x) +
          (pos1.y - pos2.y) * (pos1.y - pos2.y),
    );
  }

  /// Move [object] forward [moveamt]
  /// [delay] for [delay] seconds
  static objForward(object, moveamt, {delay}) {
    if (delay != null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        //print("play "+path.toString());
        objForward(object, moveamt);
      });
    } else {
      object.translateZ(moveamt);
    }
  }

  // This gets z given the intersect point and the position of the [object] relative to the intersect point
  // Why did  you comment this out?
  static getZ(object) {
    var terrainZ = localIntersectSurface(
      object.position.x,
      object.position.y,
      object.position.z,
    );
    return object.position.z - terrainZ;
    //var localintersecty=worldIntersectSurface(object.extra['lerpsurfaceinitialpos'].x,object.extra['lerpsurfaceinitialpos'].y);
    // return
    ////object.extra['lerpsurfaceinitialpos'].z=localy-localintersecty;
  }

  /* static objForwardSurface(object, moveamt, {delay,z:0.0}) {
    if (delay != null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        //print("play "+path.toString());
        objForward(object, moveamt);
      });
    } else {
      var pos = localToWorldObj(object);
      var newpos = Math.vectorMoveForward(pos.x, pos.y, getObjTurn(object), moveamt);

      worldToLocalSurfaceObj(object, newpos.x, newpos.y, z);
     // object.translateZ(moveamt);
    }
  }*/

  /// Move [object] forward [moveamt]   lerping in [time] seconds
  /// [z] is height above surface
  /// [offset] is how far left or right the [object] is move eg 2 meters forward and 1 meter left offset
  /// [level] is which this terrain level this is for
  /// [delay] for [delay] seconds
  static objForwardLerp(object, moveamt, time, {delay, offset, z, level = 0}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        objForwardLerp(
          object,
          moveamt,
          time,
          offset: offset,
          z: z,
          level: level,
        );
      });
      BaseObject.addTimer(object, t);
    } else {
      var pos = localToWorldObj(object);
      var newpos = Math.vectorMoveForward(
        pos.x,
        pos.y,
        getObjTurn(object),
        moveamt,
      );
      if (offset != null) {
        newpos = Math.vectorMoveForward(
          newpos.x,
          newpos.y,
          getObjTurn(object) + 90,
          offset,
        );
      }
      if (z == null) z = 0.0;
      worldToLocalSurfaceObjLerp(
        object,
        newpos.x,
        newpos.y,
        z,
        level: level,
        time,
      );
    }
  }

  /// Move [object] at [angle] a distance of [moveamt]
  /// [z] is height above surface
  static objMoveAngleSurface(object, angle, moveamt, z) {
    var pos = localToWorldObj(object);
    var newpos = Math.vectorMoveForward(pos.x, pos.y, angle, moveamt);
    worldToLocalSurfaceObj(object, newpos.x, newpos.y, z.toDouble());
  }

  /// Move [object] at [angle] a distance of [moveamt]  lerping for [time] seconds
  /// [z] is height above surface
  /// [level] is which this terrain level this is for
  /// [delay] for [delay] seconds
  static objMoveAngleSurfaceLerp(
    object,
    angle,
    moveamt,
    z,
    time, {
    level = 0,
    delay,
  }) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        objMoveAngleSurfaceLerp(object, angle, moveamt, z, time, level: level);
      });
      BaseObject.addTimer(object, t);
    } else {
      var pos = localToWorldObj(object);
      var newpos = Math.vectorMoveForward(pos.x, pos.y, angle, moveamt);
      worldToLocalSurfaceObjLerp(
        object,
        newpos.x,
        newpos.y,
        z.toDouble(),
        time,
        level: level,
      );
    }
  }

  /// Move [object] forward by [moveamt] along the surface of the terrain. [z] is distance above surface
  /// [level] is which this terrain level this is for
  static objForwardSurface(object, moveamt, z, {normalize2world, level = 0}) {
    object.translateZ(moveamt);
    var localy = localIntersectSurface(
      object.position.x,
      Camera._camera.position.y,
      object.position.z,
      level: level,
    );
    object.position.y = localy + z;
    if (normalize2world != null && normalize2world) {
      // if (BaseObject.getName(object)=='donkeygroup3i')
      //    print("objforwardsurface");
      objNormalize2World(object);
    }
  }

  /// Move an [object] left or right relative to direction facing by [moveamt] distance
  static objLeftRight(object, moveamt) {
    object.translateX(moveamt);
  }

  /// Move an [object] left or right relative to direction facing by [moveamt] distance along the surface of the terrain.
  /// [level] is which this terrain level this is for
  /// [z] is distance above surface
  static objLeftRightSurface(object, moveamt, z, {level = 0}) {
    object.translateX(moveamt);
    var localy = localIntersectSurface(
      object.position.x,
      999,
      object.position.z,
      level: level,
    );
    object.position.y = localy + z;
  }

  /// Distance local coordinates are from the wall in the direction from the camera to the position localx,localy,localz
  static distanceWall(localx, localy, localz, {offsetz}) {
    if (_surfaces != null &&
        _surfaces[0]?.children != null &&
        _walls != null &&
        _walls.children != null) {
      if (offsetz == null)
        offsetz =
            wallintersectoffsetz; //(offsetz==null?wallintersectoffsetz:offsetz)
      return wallIntersectDistance(
        Camera._camera.position.x,
        Camera._camera.position.y - offsetz,
        //0.005, //so that wall doesn't have to be so high
        Camera._camera.position.z,
        localx,
        localy - offsetz,
        localz,
      );
    } else
      return -2;
  }

  /// Precompute a world-space bounding sphere (or axis-aligned box, for
  /// meshes whose name contains "boundingbox") for every wall mesh in
  /// [_walls]. Walls are static, so this only needs to run once (called from
  /// init() right after _walls is (re)built) rather than every frame.
  ///
  /// A wall mesh named e.g. "housewallboundingbox5lowercity" (contains both
  /// "wall", so it's picked up as a wall at all, and "boundingbox") gets a
  /// box instead of a sphere. Everything else keeps the sphere as before.
  static void _computeWallBounds() {
    _wallBoundingSpheres = {};
    _wallBoundingBoxes = {};
    for (var child in _walls.children) {
      var geometry = child.geometry;
      if (geometry == null) continue;
      child.updateWorldMatrix(true, false);

      if (child.name.contains("boundingbox")) {
        geometry.computeBoundingBox();
        var localBox = geometry.boundingBox;
        if (localBox == null) continue;
        // BoundingBox has no applyMatrix4 of its own (unlike BoundingSphere),
        // so the world-space box is built by transforming all 8 corners of
        // the local box and taking their min/max - the standard way to get
        // a world-space AABB out of a possibly-rotated local box. It's a
        // one-time cost here, not per-frame.
        var worldBox = THREE.BoundingBox();
        for (var corner in [
          THREE.Vector3(localBox.min.x, localBox.min.y, localBox.min.z),
          THREE.Vector3(localBox.min.x, localBox.min.y, localBox.max.z),
          THREE.Vector3(localBox.min.x, localBox.max.y, localBox.min.z),
          THREE.Vector3(localBox.min.x, localBox.max.y, localBox.max.z),
          THREE.Vector3(localBox.max.x, localBox.min.y, localBox.min.z),
          THREE.Vector3(localBox.max.x, localBox.min.y, localBox.max.z),
          THREE.Vector3(localBox.max.x, localBox.max.y, localBox.min.z),
          THREE.Vector3(localBox.max.x, localBox.max.y, localBox.max.z),
        ]) {
          worldBox.expandByPoint(corner.applyMatrix4(child.matrixWorld));
        }
        _wallBoundingBoxes[child] = worldBox;
        print("wallbox " + child.name + " " + worldBox.toString());
      } else {
        geometry.computeBoundingSphere();
        var localSphere = geometry.boundingSphere;
        if (localSphere == null) continue;
        // applyMatrix4 correctly accounts for the mesh's world position,
        // rotation AND scale in one step.
        var worldSphere = localSphere.clone().applyMatrix4(child.matrixWorld);
        _wallBoundingSpheres[child] = worldSphere;
      }
    }
  }

  /// Intersection with closest wall from local coordinates.
  /// prevlocal  coordinates specifies the previous location so know what direction the object is heading even if the camera isn't facing in that direction
  /// Player could be moving sideway or backwards so camera angle can't always be used
  static wallIntersectDistance(
    localx,
    localy,
    localz,
    prevlocalx,
    prevlocaly,
    prevlocalz,
  ) {
    if (_surfaces != null &&
        _surfaces[0]?.children != null &&
        _walls != null &&
        _walls.children != null) {
      var posVector = new THREE.Vector3(localx, localy, localz);
      var dirVector = new THREE.Vector3(
        localx - prevlocalx,
        localy - prevlocaly,
        localz - prevlocalz,
      );
      _raycaster.set(posVector, dirVector);
      // Cheap pre-filter: only run the expensive per-triangle raycast
      // (intersectObjects below) against walls whose cached world bounding
      // sphere or box the ray could plausibly hit. _walls.children can
      // contain many wall meshes spread across the whole level; on any
      // given call only the one or two walls actually near the player can
      // matter, so this normally skips full triangle-level testing for
      // most of them. A mesh gets a box instead of a sphere if its name
      // contains "boundingbox" (see _computeWallBounds()) - boxes fit a
      // long thin wall far more tightly than a sphere does.
      var candidates = _walls.children.where((child) {
        var box = _wallBoundingBoxes[child];
        if (box != null) return _raycaster.ray.intersectsBox(box);
        var sphere = _wallBoundingSpheres[child];
        return sphere == null || _raycaster.ray.intersectsSphere(sphere);
      }).toList();
     /*  Use this to work out which walls are taking the longest to compute intersections
     for (var c in candidates) {
        var sw = Stopwatch()..start();
        _raycaster.intersectObject(c, false);
        sw.stop();
        var verts = c.geometry?.attributes['position']?.length ?? 0;
        var indices = c.geometry?.index?.length ?? 0;
        print(
          "wall candidate '${c.name}': verts=$verts indices=$indices time=${sw.elapsedMicroseconds}us",
        );
      }*/

      var intersects = _raycaster.intersectObjects(
        candidates,
        false,
      ); // ??? does it need to be true?
      if (intersects.length > 0) {
        return intersects[0].distance;
      }
    }
    return -1;
  }

  /// Get the intersect distance from local coordinates with a roof in the terrain
  /// Will initially try interection going up from camera, then try intersection from height above camera looking down
  /// Useful if want to know if player is indoors
  static roofInteresectDistance(localx, localy, localz) {
    // Try interesect up from camera
    _raycaster.set(
      new THREE.Vector3(localx, localy, localz),
      new THREE.Vector3(0, 1, 0),
    ); // Raycast upwards
    // calculate objects intersecting the picking ray
    var intersects = _raycaster.intersectObjects(
      _roof.children,
      false,
    ); //!!! does it need to be true
    if (intersects.length > 0) {
      // print("inter roof");
      return intersects[0].point?.y;
    } else {
      // Try intersect down from a height above camera
      _raycaster.set(
        new THREE.Vector3(localx, localy + 1.5, localz),
        new THREE.Vector3(0, -1, 0),
      ); // Raycast downwards
      // calculate objects intersecting the picking ray
      var intersects = _raycaster.intersectObjects(
        _roof.children,
        false,
      ); //!!! does it need to be true
      if (intersects.length > 0) {
        // print("interii"+intersects[0].point!.y.toString());
        return intersects[0].point?.y;
      }
    }
    return -1;
  }

  /// Given  an [object] on the terrain and [turn] and position at [worldx], [worldy], [worldz],[level] what is the pitch at that point in the terrain
  static getTerrainPitch(object, {worldx, worldy, worldz, turn, level = 0}) {
    if (turn == null) turn = getTurn(object);
    double localx;
    double localz;
    double localy;
    if (worldx != null) {
      localx = (worldx as num).toDouble();
      localz = -(worldy as num).toDouble();
      localy = Camera._camera.position.y + 1;
    } else {
      localx = object.position.x;
      localy = object.position.y;
      localz = object.position.z;
    }
    final worldNormal = _terrainNormal(localx, localy, localz, level,
        useheight: worldx == null);
    if (worldNormal == null) return 0.0;

    var turnRad = THREE.MathUtils.degToRad(turn);
    var lookDir = THREE.Vector3(math.sin(turnRad), 0, math.cos(turnRad));
    lookDir.normalize();

    // dot product of normal and lookDir gives the sine of the slope angle
    double dot = worldNormal.dot(lookDir).clamp(-1.0, 1.0).toDouble();
    // Negative because a 'forward' normal tilt means looking down
    var pitchRadians = -math.asin(dot);
    return THREE.MathUtils.radToDeg(pitchRadians);
  }

  /// World-space terrain normal below local [x],[y],[z], cached on a
  /// [_normalGridSize] grid. Uses the SurfaceGrid when enabled, otherwise a
  /// raycast. [useheight] adds a 1-unit height band to the cache key so an
  /// object under a bridge doesn't get the bridge's normal.
  static THREE.Vector3? _terrainNormal(double x, double y, double z, level,
      {bool useheight = true}) {
    final double inv = 1.0 / _normalGridSize;
    final int rx = (x * inv).floor();
    final int rz = (z * inv).floor();
    final int ry = useheight ? y.floor() : 0;
    final String key = '$level:$rx:$rz:$ry';
    final cached = _normalCache[key];
    if (cached != null) return cached;

    var surfaces = Space.getSurfaces()[level].children;
    THREE.Intersection? hit;
    if (useSurfaceGrid) {
      final grid = _surfaceGrids[level] ??= SurfaceGrid.build(
        _surfaces[level]!.children,
        _raycaster.layers,
      );
      hit = grid.intersectDown(x, y + 0.3, z);
    } else {
      Space.getRaycaster().set(
        THREE.Vector3(x, y + 0.3, z),
        THREE.Vector3(0, -1, 0),
      );
      var intersects = Space.getRaycaster().intersectObjects(surfaces, false);
      if (intersects.length > 0) hit = intersects[0];
    }
    if (hit == null || hit.face == null) return null;

    final THREE.Vector3 normal = hit.face!.normal.clone();
    normal.transformDirection(surfaces[0].matrixWorld);

    if (_normalCache.length >= _normalCacheMaxSize) {
      final keys = _normalCache.keys.toList();
      for (var k = 0; k < keys.length ~/ 2; k++) {
        _normalCache.remove(keys[k]);
      }
    }
    _normalCache[key] = normal;
    return normal;
  }

  /// Get the [object] position when place before camera [dist] away with {offset} left or right from the center
  static getPlaceBeforeCameraPos(object, dist, {offset}) {
    var angle = getObjTurn(Camera._camera);
    var worldpos = localToWorldObj(Camera._camera);
    var pos = Math.vectorMoveForward(worldpos.x, worldpos.y, angle, dist);

    if (offset != null) {
      pos = Math.vectorMoveForward(pos.x, pos.y, angle + 90, offset);
    }
    return pos;
  }

  /// position distance [dist] in front of the camera
  /// [offset] is how far left or right from the center in frant of camera. Eg if place three items in front of camera might want one to the left, one middle one on right
  /// [level] is which this terrain level this is for
  /// [time] specifies lerp time to move the object to the camera
  static placeBeforeCamera(object, dist, {time, offset, z, level}) //,delay})
  {
    /*  if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        placeBeforeCamera(object, dist,time:time,offset:offset,z:z);
      });
      BaseObject.addTimer(object, t);
    } else {*/
    if (z == null) z = 0.0;
    var pos = getPlaceBeforeCameraPos(object, dist, offset: offset);
    if (time != null) {
      Space.worldToLocalSurfaceObjLerp(
        object,
        pos.x,
        pos.y,
        z,
        time,
        level: level,
      );
    } else
      Space.worldToLocalSurfaceObj(object, pos.x, pos.y, z, level: level);
    //  }
  }

  /// Reset an [object] position and rotation
  static resetPosRot(object) {
    /*  obj.rotation.x=0.0;//-0.04;
      obj.rotation.y=0.00;
      obj.rotation.z=0.0;//-0.04;*/
    resetRot(object);
    object.position.x = 0.0; //-0.04;
    object.position.y = 0.00;
    object.position.z = 0.0;
    ;
  }

  /// Reset an [object] rotation
  static resetRot(object) {
    object.rotation.x = 0.0; //-0.04;
    object.rotation.y = 0.00;
    object.rotation.z = 0.0; //-0.04;
  }

  static THREE.Vector3? lasthideworldpos; //=null;
  static var lasthidetick = 0;
  static int updatetick = 0;

  static bool forcecheckhide = false;

  /// Set to true to print how long each section of [update] takes every frame
  static bool showtime = false;
  static Stopwatch? _timeSw;
  static int _timeLast = 0;

  static void _timeStart() {
    if (!showtime) return;
    (_timeSw ??= Stopwatch())
      ..reset()
      ..start();
    _timeLast = 0;
  }

  /// Prints the time since the previous lap. [count] is how many objects the section handled.
  static void _timeLap(String label, [int? count]) {
    if (!showtime) return;
    final now = _timeSw!.elapsedMicroseconds;
    print('Space.update: ${label.padRight(20)} ${((now - _timeLast) / 1000.0).toStringAsFixed(2)}ms'
        '${count != null ? '  ($count objs)' : ''}');
    _timeLast = now;
  }

  /// Update all the lerping objects for position and rotation and hiding and detect triggers
  static update(frameTime) {
    _timeStart();
    final int nlerp = _lerpobjects.length;
    final int nlerpsurface = _lerpobjectssurface.length;
    final int nlerpturn = _lerpturnobjects.length;
    for (var i = _lerpobjects.length - 1; i >= 0; i--) {
      var obj = Space._lerpobjects[i];
      if (obj == null /*||!obj.visible*/ ) {
        //you shouldn't be lerping objects if they're not visible
        Space._lerpobjects.remove(obj); //splice(i, 1);
      } else {
        obj.extra['lerpcurrenttime'] += frameTime * 1000;
        var lerp =
            (obj.extra['lerpcurrenttime'] - obj.extra['lerpfromtime']) /
            (obj.extra['lerptotime'] * 1000);
        //var lerp = (System.currentMilliseconds() - obj.extra['lerpfromtime']) /
        //    (obj.extra['lerptotime'] * 1000);
        if (lerp >= 1) {
          obj.position.setValues(
            obj.extra['lerpfinalpos'].x,
            obj.extra['lerpfinalpos'].y,
            obj.extra['lerpfinalpos'].z,
          );
          var inddelete = Space._lerpobjects.indexOf(obj);
          if (inddelete >= -1) {
            Space._lerpobjects.remove(obj);
          }
        } else {
          obj.position.setValues(
            obj.extra['lerpinitialpos'].x +
                lerp *
                    (obj.extra['lerpfinalpos'].x -
                        obj.extra['lerpinitialpos'].x),
            obj.extra['lerpinitialpos'].y +
                lerp *
                    (obj.extra['lerpfinalpos'].y -
                        obj.extra['lerpinitialpos'].y),
            obj.extra['lerpinitialpos'].z +
                lerp *
                    (obj.extra['lerpfinalpos'].z -
                        obj.extra['lerpinitialpos'].z),
          );
        }
      }
    }

    _timeLap('lerpobjects', nlerp);



    for (var i = Space._lerpobjectssurface.length - 1; i >= 0; i--) {
      var obj = Space._lerpobjectssurface[i];
      if (obj == null /*||!obj.visible*/ ) {
        // you shouldn't be lerping objects if they're not visible
        Space._lerpobjectssurface.remove(obj); //splice(i, 1);
      } else {
        obj.extra['lerpsurfacecurrenttime'] += frameTime * 1000;
        var lerp =
            (obj.extra['lerpsurfacecurrenttime'] -
                obj.extra['lerpsurfacefromtime']) /
            (obj.extra['lerpsurfacetotime'] * 1000);
        // var lerp = (System.currentMilliseconds() - obj.extra['lerpsurfacefromtime']) /
        //     (obj.extra['lerpsurfacetotime'] * 1000);
        if (lerp > 1) {
          //  obj.extra.remove('lerpsurfaceprevz');

          worldToLocalSurfaceObj(
            obj,
            obj.extra['lerpsurfacefinalpos'].x,
            obj.extra['lerpsurfacefinalpos'].y,
            obj.extra['lerpsurfacefinalpos'].z,
            level: obj.extra['lerpsurfacetolevel'],
            normalize2world: obj.extra['lerpsurfacenormalize2world'],
          );
          if (Space._lerpobjectssurface.contains(obj)) {
            //inddelete>=-1) {
            //print("removed");
            Space._lerpobjectssurface.remove(obj);
            // print("xxx"+_space._lerpobjects.length.toString());
          }
        } else {
          var localy = obj.position.y;
          // print("namelerp"+BaseObject.getName(obj));
          worldToLocalSurfaceObj(
            obj,
            obj.extra['lerpsurfaceinitialpos'].x +
                lerp *
                    (obj.extra['lerpsurfacefinalpos'].x -
                        obj.extra['lerpsurfaceinitialpos'].x),
            obj.extra['lerpsurfaceinitialpos'].y +
                lerp *
                    (obj.extra['lerpsurfacefinalpos'].y -
                        obj.extra['lerpsurfaceinitialpos'].y),
            obj.extra['lerpsurfaceinitialpos'].z +
                lerp *
                    (obj.extra['lerpsurfacefinalpos'].z -
                        obj.extra['lerpsurfaceinitialpos'].z),
            level: obj.extra['lerpsurfacetolevel'],
            normalize2world: obj.extra['lerpsurfacenormalize2world'],
          );

          // Cheat so that if going down steps don't jolt into position
          //  obj.position.y=obj.position.y*0.1+localy*0.9;
          //          obj.position.y=obj.position.y*0.2+localy*0.8;
          /* var localynew=obj.position.y;
          if (obj.extra.containsKey('lerpsurfaceprevz')) {
            obj.position.y=obj.position.y*0.3+obj.extra['lerpsurfaceprevz']*0.3+localy*0.4;
          } else*/
          /* var fct=(obj.position.y-localy).abs()/0.01;
          if (fct>0.5)
            fct=0.5;

          if (obj.extra.containsKey('stableboy'))//obj.extra['mobname']=='yourfriend')
            print("fctttt"+(obj.position.y-localy).abs().toString()+" "+fct.toString());
          obj.position.y=obj.position.y*fct+localy*(1-fct);*/
          obj.position.y = obj.position.y * 0.3 + localy * 0.7;
          //  obj.extra['lerpsurfaceprevz']=localynew;
        }
      }
    }

    _timeLap('lerpobjectssurface', nlerpsurface);

    // print("checking turn lerp");
    for (var i = Space._lerpturnobjects.length - 1; i >= 0; i--) {
      var obj = Space._lerpturnobjects[i];

      if (obj == null /*||!obj.visible*/ ) {
        // you shouldn't be lerping objects if they're not visible
        Space._lerpturnobjects.remove(obj);
      } else {
        var lerp =
            (System.currentMilliseconds() - obj.extra['lerpfromtimeturn']) /
            (obj.extra['lerptotimeturn'] * 1000);
        //if (BaseObject.getName(obj)=='donkeygroup3i')
        //  print('donkey in lerp'+" "+lerp.toString());

        if (lerp >= 1) {
          Space._lerpturnobjects.remove(obj);
          Space.objTurn(
            obj,
            obj.extra['lerpfinalturn'],
            normalize2world: obj.extra['lerpnormalize2worldturn'],
          );
        } else {
          var newangle =
              obj.extra['lerpinitialturn'] +
              lerp *
                  (obj.extra['lerpfinalturn'] - obj.extra['lerpinitialturn']);
          if (obj is THREE.Camera)
            Camera.setTurn(newangle);
          else {
            // this will not work because objturn removes from lerp - Space.objTurn(obj, newangle,normalize2world: obj.extra['lerpnormalize2worldturn']);
            if (obj.extra.containsKey('lerpnormalize2worldturn') &&
                obj.extra['lerpnormalize2worldturn'] != null &&
                obj.extra['lerpnormalize2worldturn']) {
              // if (BaseObject.getName(obj)=='donkeygroup3i')
              //    print("lerp new angle "+Math.standardAngle(newangle).toString()+" "+lerp.toString()+" initt:"+Math.standardAngle(obj.extra['lerpinitialturn']).toString()+" finalt:"+Math.standardAngle(obj.extra['lerpfinalturn']).toString()+" "+ obj.extra['lerpfromtimeturn'].toString()+" "+ obj.extra['lerptotimeturn'].toString());
              objNormalize2World(obj, turn: newangle);
              // Space.objTurn(obj, newangle);
            } else
              //    Space.objTurn(obj, newangle,normalize2world: obj.extra['lerpnormalize2worldturn']);
              obj.rotation.y = (-newangle - 180) * math.pi / 180;
          }
        }
      }
    }

    _timeLap('lerpturnobjects', nlerpturn);

    var worldpos = Space.localToWorldObj(Camera._camera);
    var dohidelist =
        lasthideworldpos == null ||
        (worldpos.x - lasthideworldpos!.x).abs() > 0 ||
        (worldpos.y - lasthideworldpos!.y).abs() > 0 ||
        updatetick % 40 == 0 ||
        forcecheckhide;
    //if (lasthideworldpos!=null)
    /*  var visible=0;
    for (var obj in Space._hideobjects)
      if (obj.visible)
        visible++;
    print('xvvvcvcv'+Space._hideobjects.length.toString()+"vis"+visible.toString());*/

    //     print('xvvvcvcv'+(worldpos.x-lasthideworldpos.x).abs().toString()+" "+Space._hideobjects.length.toString());
    if (dohidelist) {
      int amt;
      int mod;
      if (updatetick % 40 == 0 || forcecheckhide) {
        forcecheckhide = false;
        amt = 1;
        mod = 0;
      } else {
        amt = 20;
        mod = lasthidetick % amt;
      }
      // updatetick % 20;
      //print("hidelist count"+Space._hideobjects.length.toString()+" "+mod.toString());
      for (var i = Space._hideobjects.length - 1 - mod; i >= 0; i -= amt) {
        //   print("iii"+i.toString()+" "+mod.toString());
        //for (var i = Space._hideobjects.length - 1; i >= 0; i--) {
        var obj = Space._hideobjects[i];
        if (obj == null) {
          Space._hideobjects.removeAt(i);
          // Space._hideobjects.splice(i, 1);
        } else {
          // if (BaseObject.getName(obj).contains("chicken"))
          //    print("found chicken!!!");
          var objectpos = Space.localToWorldObj(obj);

          num cameradist = obj.extra['cameradist'];
          var inside =
              (worldpos.x - objectpos.x).abs() <= cameradist &&
              (worldpos.y - objectpos.y).abs() <= cameradist;

          if (obj.extra.containsKey('lerplight')) {
            // Group stays visible=true for the whole fade so its light
            // children keep rendering while their intensity ramps down/up -
            // so we can't use obj.visible to detect direction here like the
            // branches below do. Track it ourselves instead.
            var wasinside = obj.extra['lerplightinside'] ?? true;
            if (wasinside && !inside) {
              obj.extra['lerplightinside'] = false;
              //if (obj.extra.containsKey('grouplamp'))
              //    print("in group lamp off");

              Light.intensityLerpObj(obj, 0.0, obj.extra['lerplight']);
            } else if (!wasinside && inside) {
              obj.extra['lerplightinside'] = true;
              obj.visible = true;
              //if (obj.extra.containsKey('grouplamp'))
              //  print("in group lamp on");
              Light.intensityLerpObj(obj, 1.0, obj.extra['lerplight']);
            }
          } else if ((obj as THREE.Object3D).visible && !inside) {
            if (obj.extra.containsKey('lerpopacity') &&
                obj.extra['lerpopacity'] > 0.0) {
              // Clone materials so the fade-out opacity change doesn't bleed
              // onto other objects sharing the same material.
              // restoreSharedMaterials() is called automatically by
              // Texture.update() once the lerp reaches 0 and visible=false.
              Texture.cloneMaterialsForFade(obj);
              Texture.opacityLerp(obj, 0.0, obj.extra['lerpopacity']);
            } else {
              obj.visible = false;
            }
          } else if (!(obj as THREE.Object3D).visible && inside) {
            if (obj.extra.containsKey('lerpopacity') &&
                obj.extra['lerpopacity'] > 0.0) {
              var initopacity = Texture.getInitialOpacity(obj);
              Texture.cloneMaterialsForFade(obj);
              Texture.opacityLerp(obj, initopacity, obj.extra['lerpopacity']);
              if (obj.extra.containsKey('configname') &&
                  obj.extra['configname'] == 'table')
                ;
              //print("mmmlerp up" + initopacity.toString() + " " +
              //   obj.extra['lerpopacity'].toString());
            } else
              obj.visible = true;
          }
        }
      }
      lasthideworldpos = worldpos;
      lasthidetick++;
    }
    _timeLap(dohidelist ? 'hideobjects' : 'hideobjects (skip)', Space._hideobjects.length);

    // Should do this only once a second
    if (updatetick % 10 == 0) {
      for (var i = Space._hidemeshobjects.length - 1; i >= 0; i--) {
        var obj = Space._hidemeshobjects[i];
        //var worldpos = Space.localToWorldObj(Camera._camera);
        // var objectpos =Space.localToWorldObj(obj);
        THREE.Vector3 objectpos = THREE.Vector3(
          obj.extra['xworldhide'],
          obj.extra['yworldhide'],
          0.0,
        );
        var cameradist = obj.extra['cameradist'];
        var inside =
            (worldpos.x - objectpos.x).abs() <= cameradist &&
            (worldpos.y - objectpos.y).abs() <= cameradist;

        if (obj.extra.containsKey('lerplight')) {
          var wasinside = obj.extra['lerplightinside'] ?? true;
          if (wasinside && !inside) {
            obj.extra['lerplightinside'] = false;
            Light.intensityLerpObj(obj, 0.0, obj.extra['lerplight']);
          } else if (!wasinside && inside) {
            obj.extra['lerplightinside'] = true;
            obj.visible = true;
            Light.intensityLerpObj(obj, 1.0, obj.extra['lerplight']);
          }
        } else if ((obj as THREE.Object3D).visible && !inside) {
          if (obj.extra.containsKey('lerpopacity') &&
              obj.extra['lerpopacity'] > 0.0) {
            Texture.cloneMaterialsForFade(obj);
            Texture.opacityLerp(obj, 0.0, obj.extra['lerpopacity']);
          } else {
            obj.visible = false;
          }
        } else if (!(obj as THREE.Object3D).visible && inside) {
          if (obj.extra.containsKey('lerpopacity') &&
              obj.extra['lerpopacity'] > 0.0) {
            var initopacity = Texture.getInitialOpacity(obj);
            Texture.cloneMaterialsForFade(obj);
            Texture.opacityLerp(obj, initopacity, obj.extra['lerpopacity']);
            if (obj.extra.containsKey('configname') &&
                obj.extra['configname'] == 'table')
              ;
            print(
              "mmm down" +
                  initopacity.toString() +
                  " " +
                  obj.extra['lerpopacity'].toString(),
            );
          } else
            obj.visible = true;
        }
      }
    }
    _timeLap(updatetick % 10 == 0 ? 'hidemeshobjects' : 'hidemeshobjects (skip)', Space._hidemeshobjects.length);

    // turning every 10 frames is too jerky
    if (updatetick % 3 == 0) {
      for (var key in Space._faceobjects.keys) {
        // have lerpturnobjects so that dont just jump to facing the camera - lerps first and when finished then looks at camera
        if (key != null &&
            key.visible &&
            !Space._lerpturnobjects.contains(key)) {
          Space.faceObject(key, Space._faceobjects[key]);
        }
      }
    }
    _timeLap(updatetick % 3 == 0 ? 'faceobjects' : 'faceobjects (skip)', Space._faceobjects.length);

    // Occasionally change ambience of sprites - about every 10 seconds
    if (updatetick % 100 == 0) {
      if (Time.ambience != null) {
        Space._scene.traverse((object) {
          if (object.extra.containsKey('ambient')) {
            object.children[0].material?.color =
                Time.ambience!.color!; // as THREE.Color;
            //  print("update ambience"+Time._ambience!.color!.red.toString()+" "+Time._ambience!.color!.green.toString()+" "+Time._ambience!.color!.blue.toString()+" ");
            //  object.material = material;
          }
        });
      }
    }
    if (showtime) {
      _timeLap(updatetick % 100 == 0 ? 'ambience' : 'ambience (skip)');
      print('Space.update: ${'TOTAL'.padRight(20)} ${(_timeSw!.elapsedMicroseconds / 1000.0).toStringAsFixed(2)}ms');
    }
    updatetick++;
  }
}

/// All camera turning should be done here
class Camera {
  static double turn = 0; // 0 is north in degrees
  static double pitch = 0; // degrees up
  static double pitchset = 0; //double.nan;
  static double roll = 0;

  static double width = 0;
  static double height = 0;

  static late THREE.Camera _camera;
  static late double cameraoffset; // How far up from the surface in the z direction is the camera //=0.15;

  ///  Set the [camera] and [cameraoffset] from the surface intersection
  static init(camera, cameraoffset, width, height) {
    _camera = camera;
    Camera.cameraoffset = cameraoffset;
    Camera.width = width;
    Camera.height = height;
  }

  /// Set the turn of the camera where 0 is north
  static setTurn(turn) {
    Camera.turn = Math.standardAngle(turn.toDouble());
    updateCamera();
  }

  static setPitch(pitch) {
    // Should be between -180 and 180
    Camera.pitch = Math.standardAngleSigned(pitch.toDouble());
    updateCamera();
  }

  static setRoll(roll) {
    Camera.roll = Math.standardAngleSigned(roll.toDouble());
    updateCamera();
  }

  /// Update rotation of camera based upopn its pitch, turn and roll
  static updateCamera() {
    //                                                                         pitch                                     //turn                               // roll
    Camera._camera.setRotationFromEuler(
      THREE.Euler(
        THREE.MathUtils.degToRad(pitch).toDouble(),
        THREE.MathUtils.degToRad(-turn).toDouble(),
        THREE.MathUtils.degToRad(roll).toDouble(),
        THREE.RotationOrders.yxz,
      ),
    ); //'YXZ' ));
  }
}

/// Status and procedures related to overall system
class System {
  // Allow turn off openworld if move out of the game
  static bool active = true;

  static AppLifecycleState appstate = AppLifecycleState.resumed;

  static bool loaded=false;

  /// epoch milliseconds elapsed
  static currentMilliseconds() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static isDesktop() {
    return kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  static isSmartphone() {
    return !kIsWeb &&( Platform.isAndroid || Platform.isIOS);
  }

  /// Remove all objects from [hotload] including all timers, hidden lists, turn lists etc so doesn't get bigger and bigger every time you hotload
  static resetHotload(hotload) {
    for (var obj in hotload.children) {
      Space._hideobjects.remove(obj);
      Space._faceobjects.remove(obj);
      Space._lerpobjects.remove(obj);
      Space._lerpobjectssurface.remove(obj);
      Mob.movetohiddenlist.remove(obj);
      Mob.movetoloopbnextlist.remove(obj);
      Mob.removeObjectFromMoveTo(obj);
      BaseObject.clearTimers(obj);
      Mob.chatterlist.remove(obj);
      Mob.speechlist.remove(obj);
    }
    /* var cachevalues=Config._objects3dCache.values;
    for (var i=hotload.children.length-1; i>=0; i--)
      if (!cachevalues.contains(hotload.children[i]))//Config._objects3dCache.contains(hotload[i]))
        hotload.remove(hotload.children[i]);
      else
        print('found in cache');*/

    hotload.clear();
  }

  /// Returns the apps version and buildnumber
  static getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

   // String version = packageInfo.version;      // e.g., "1.0.0"
   // String buildNumber = packageInfo.buildNumber; // e.g., "1"
    return packageInfo;
   // print('Version: $version+$buildNumber');
  }

  /*  static getFullScreenSize()
  {
    final screens = PlatformDispatcher.instance.displays;
    return screens.first.size;
   // print("size"+fSize.toString());
  }*/
}

/// Procedures related to storing persistent data
class Persistence {
  static String gamename = ""; // So that if two games in web wont mix up cookies in browser

  /// Save the variable with [name] with [val] in persistent storage
  /// Doesnt work on web - would need to save on server if use web
  static set(name, val) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (val is double)
      await prefs.setDouble(gamename + name, val);
    else if (val is bool)
      await prefs.setBool(gamename + name, val);
    else if (val is List<String>)
      await prefs.setStringList(gamename + name, val);
    else
      await prefs.setString(gamename + name, val.toString());
  }

  /// This is to get the sharepreferences safely - sometimes they can be corrupted and stop the app from working so  start again
  static Future<SharedPreferences> getPrefsSafely() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      // File is corrupted — reset it and try again.
      // hardReset() clears the underlying storage/cache and forces
      // a fresh, valid file to be written on next access.
      SharedPreferences.resetStatic();
      try {
        return await SharedPreferences.getInstance();
      } catch (e2) {
        // Still failing — as a last resort, delete the file directly (desktop only)
        if (Platform.isWindows || Platform.isLinux) {
          final appSupportDir = await getApplicationSupportDirectory();
          final prefsFile = File(
            '${appSupportDir.path}/shared_preferences.json',
          );
          if (await prefsFile.exists()) {
            await prefsFile.delete();
          }
        }
        return await SharedPreferences.getInstance();
      }
    }
  }

  /// Get the persistent value of variable [name] and if its not found use the default value [def] instead
  static get(name, {def}) async {
    //print('aaaa');
    // try {
    final SharedPreferences prefs =
        await getPrefsSafely(); //await SharedPreferences.getInstance();
    //print('bbbb');
    if (await prefs.containsKey(gamename + name)) {
      print("found" + name);
//      return await prefs.get(gamename + name);
      final value = prefs.get(gamename + name);
      // Return a growable copy: on macOS lists come back fixed-length
      if (value is List) return value.map((e) => e.toString()).toList();
      return value;
    } else {
      print("not found" + name);

      return def;
    }
    // } catch (e) {
    //   // This executes if any exception or error is thrown
    //   print('Persistence error occurred: $e');
    //  }
  }

  /// Remove variable [name] from persistent storage
  static remove(name) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(gamename + name);
  }

  /// Clear persistent storage in its entirety
  static reset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}

/// functions for sound such as fading in and out
class Sound {
  static bool mute = false;

  static List<Map> soundlist = []; // Audioplayers to be faded
  static List soundpool =
      []; // Audioplayer list - with list can mute all sounds

  static Map durations = {};

  /// Play a sound using [sound] audioplayer.
  /// Can set [path] of asset or leave null to play whatever the audioplayer is loaded with
  /// Can set [volume] of sound
  /// Can [delay] playing the sound in seconds
  /// Set play the sound from position [seek] seconds instead of from the start
  /// [obj] is object3d that sounds belong to so can clear the timer if need too
  /// [loop] bool to loop the sound instead of playing once
  static play({
    sound,
    path,
    volume = 1.0,
    delay,
    seek,
    loop,
    fadein,
    obj,
  }) async {
    var duration = -1.0;
    if (mute) return;
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        play(
          sound: sound,
          path: path,
          volume: volume,
          seek: seek,
          loop: loop,
          fadein: fadein,
        );
      });
      if (obj != null) BaseObject.addTimer(obj, t);
    } else {
      if (sound == null) {
        sound = getAudioPlayer();
      }
      if (loop != null && loop)
        sound.setReleaseMode(audioplayers.ReleaseMode.loop);
      else
        sound.setReleaseMode(audioplayers.ReleaseMode.release);

      if (sound.state == audioplayers.PlayerState.playing) await sound.stop();
      if (path != null) {
        await sound.setSource(audioplayers.AssetSource(path));
        if (durations.containsKey(path))
          duration = durations[path];
        else {
          //print('getduration'+player.toString()+" path"+path.toString());
          var dur = await sound.getDuration(); //.setUrl(path);
          if (dur != null) {
            duration = dur!.inMilliseconds / 1000.0;
          } else
            duration = -1;
          durations[path] = duration;
        }
      }
      if (volume != null) sound.setVolume(volume.toDouble());
      if (seek != null)
        sound.seek(Duration(milliseconds: (seek * 1000).round()));

      if (fadein != null) {
        print("sound" + path + " fadein");
        await sound.resume(); //play();
        fadeIn(sound, fadein);
      } else {
        print("sound" + path + " resume");
        await sound.resume();
      }
    }
    return duration;
  }

  /// either get an audioplayer thats not being used or make one
  /// Use a pool allows the list of all the audioplayers to be muted
  static getAudioPlayer() {
    //  print("stacktrace"+StackTrace.current.toString());
    for (var sound in soundpool)
      if (sound.state != audioplayers.PlayerState.playing)
        return sound;

    var sound = audioplayers.AudioPlayer();
    soundpool.add(sound);
    return sound;
  }

  /// [Mute] all audioplayers in the sound pool
  static setMute(mute) {
    if (mute) {
      for (var sound in soundpool)
        if (sound.state == audioplayers.PlayerState.playing) sound.stop();
    }
    Sound.mute = mute;
  }

  // fade [soundfrom] to zero in [fadetime] seconds and then play [soundto]
  // fade from [soundfrom] to [soundto] in [fadetime]
  static playFade(
    audioplayers.AudioPlayer soundfrom,
    audioplayers.AudioPlayer soundto,
    fadetime,
  ) {
    soundlist.add({
      'soundfrom': soundfrom,
      'soundto': soundto,
      'fadetime': fadetime,
      'fadestarttick': System.currentMilliseconds(),
      'fromvolume': soundfrom.volume,
      'tovolume': soundto.volume,
    });
  }

  /// Remove [sound] audioplayer from list of sounds to fade
  static removeSoundList(audioplayers.AudioPlayer sound) {
    for (var i = soundlist.length - 1; i >= 0; i--)
      if ((soundlist[i].containsKey('soundto') &&
              soundlist[i]['soundto'] == sound) ||
          (soundlist[i].containsKey('soundfrom') &&
              soundlist[i]['soundfrom'] == sound))
        soundlist.removeAt(i);
  }

  /// Fade into [sound] gradually in [fadetime] seconds
  static fadeIn(audioplayers.AudioPlayer sound, fadetime) {
    // Remove any existing in soundlist
    removeSoundList(sound);
    soundlist.add({
      'soundto': sound,
      'fadetime': fadetime,
      'fadestarttick': System.currentMilliseconds(),
      'tovolume': sound.volume,
    });
  }

  /// Fade out [sound] gradually in [fadetime] seconds
  static fadeOut(audioplayers.AudioPlayer sound, fadetime) {
    // Remove any existing in soundlist
    removeSoundList(sound);
    soundlist.add({
      'soundfrom': sound,
      'fadetime': fadetime,
      'fadestarttick': System.currentMilliseconds(),
      'fromvolume': sound.volume,
    });
  }

  /// Is the [sound] playing
  /// Glitch in ios where if looping then player state is not playing therefore use this procedure instead
  static isPlaying(audioplayers.AudioPlayer sound) {
    return (sound.state == audioplayers.PlayerState.playing) ||
        (sound.releaseMode == audioplayers.ReleaseMode.loop &&
            sound.state == audioplayers.PlayerState.completed);
  }

  /// Update the fading sounds volume
  static update() {
    for (var i = soundlist.length - 1; i >= 0; i--) {
      var item = soundlist[i];
      var lerp =
          (System.currentMilliseconds() - item['fadestarttick']) /
          (item['fadetime'] * 1000);
      if (lerp >= 1) {
        if (item.containsKey('soundfrom') &&
            isPlaying(
              item['soundfrom'],
            )) //item['soundfrom'].state == audioplayers.PlayerState.playing) //playing)
          item['soundfrom'].stop();
        soundlist.removeAt(i);

        //  soundlist.splice(i);
      } else {
        if (item.containsKey('soundfrom'))
          item['soundfrom'].setVolume(item['fromvolume'] * (1 - lerp));
        // print("uuuu"+(item['tovolume'] * lerp).toString());
        if (item.containsKey('soundto'))
          item['soundto'].setVolume(item['tovolume'] * lerp);
      }
    }
  }
}

/// Math functions that are useful for openworld
class Math {
  /// Difference between [angle1] and [angle2]
  static angleDifference(angle1, angle2) {
    var diff = angle1 - angle2;
    while (diff > 180 || diff < -180) {
      if (diff > 180) //Math.PI)
        diff = diff - 360; //(float)(2*Math.PI); // 340-360 is -20
      if (diff < -180) //Math.PI)
        diff = diff + 360; //(float)(2*Math.PI); // -340+360 is 20
    }
    return diff;
  }

  /// angle between two 2D vectors [v] and [v2]
  static getAngleBetweenPoints(v, v2) {
    var DeltaX, DeltaY;
    var ret;

    DeltaX = v2.x - v.x;
    DeltaY = -(v2.y - v.y);
    //print("mm"+v.x.toString()+" "+v.y.toString()+" "+v2.x.toString()+" "+v2.y.toString());//+" "+StackTrace.current.toString());
    if (DeltaX < 0)
      ret = math.atan(DeltaY / DeltaX) + math.pi;
    else if (DeltaX > 0)
      ret = math.atan(DeltaY / DeltaX);
    else {
      if (DeltaY < 0)
        ret = -math.pi / 2;
      else if (DeltaY > 0)
        ret = math.pi / 2;
      else
        ret = 0.0;
    }
    if (ret < -1000 || ret > 1000)
      ret = 0.0;
    else {
      ret = ret + math.pi / 2;
      while (ret < 0) ret += 2 * math.pi;
      while (ret >= 2 * math.pi) ret -= 2 * math.pi;

      ret *= 180 / math.pi;
      // ret=Math.toDegrees((double)ret);
    }
    return ret;
  }

  static vector2tovector3(THREE.Vector2 a) {
    return THREE.Vector3(a.x, a.y, 0.0);
  }

  /// distance between vector [v] and [v2] in 2D
  /// This ignores z!
  static vectorDistance(THREE.Vector3 v, THREE.Vector3 v2) {
    var deltaX = v.x - v2.x;
    var deltaY = v.y - v2.y;
    return math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
  }

  /// distance between vector [v] and [v2] in 3D
  /// This doest not ignore z
  static vectorDistance3(THREE.Vector3 v, THREE.Vector3 v2) {
    var deltaX = v.x - v2.x;
    var deltaY = v.y - v2.y;
    var deltaZ = v.z - v2.z;
    return math.sqrt((deltaX * deltaX) + (deltaY * deltaY) + (deltaZ * deltaZ));
  }

  /// Give the vector [angle] degrees forward of point [x],[y] with [dist] distance from x,y
  static THREE.Vector2 vectorMoveForward(x, y, angle, dist) {
    double rad = THREE.MathUtils.degToRad(angle.toDouble()).toDouble();
    //System.out.println("angle"+angle);
    return THREE.Vector2(x + math.sin(rad) * dist, y + math.cos(rad) * dist);
  }

  /// Give the vector [angle] degrees forward of point [x],[y] with [dist] distance from x,y returning a 3D vector instead of 2D
  static THREE.Vector3 vectorMoveForward3(x, y, angle, dist) {
    double rad = THREE.MathUtils.degToRad(angle.toDouble()).toDouble();
    //System.out.println("angle"+angle);
    return THREE.Vector3(
      x + math.sin(rad) * dist,
      y + math.cos(rad) * dist,
      0.0,
    );
  }

  /// Generate a random number between 0 and 1
  static random({seed = null}) {
    var rng = math.Random(seed);
    return rng.nextDouble();
  }

  /*static randInt(max) {
    var rng = math.Random();
    return rng.nextInt(max);
  }*/

  /// Generate a random number between 0 and [max]
  static randInt(max, {exclude}) {
    if (exclude == null) {
      var rng = math.Random();
      return rng.nextInt(max);
    } else {
      var rng = math.Random();
      var val = rng.nextInt(max);
      var cnt = 0;
      while (exclude.contains(val) && cnt < 100) {
        val = rng.nextInt(max);
        cnt++;
      }
      return val;
    }
  }

  /// Get a random float between [low] and [high]
  static num randFloat(num low, num high) {
    return low + Math.random() * (high - low);
  }

  /// Get a random float between <-[range]/2, [range]/2> interval
  static double randFloatSpread(num range) {
    return range * (0.5 - Math.random());
  }

  /// Pick a random item from a [list] eg if a list [1,2,3,4] will pick a random item from this list
  /// [exclude] any that are in the exclude list
  static randPick(list, {exclude}) {
    if (exclude == null)
      return list[randInt(list.length)];
    else {
      var list2 = list.toList();
      for (var item in exclude) list2.remove(item);
      return randPick(list2);
    }
  }

  /// Standardize [angle] between 0 and 360
  static standardAngle(angle) {
    return ((angle % 360) + 360) % 360;
  }

  /// Standardize [angle] between -180 and 180
  static standardAngleSigned(angle) {
    return ((angle + 180) % 360 + 360) % 360 - 180;
  }

  /*static degToRad(degrees) {
    return degrees * (math.pi / 180);
  }
*/
  // Deleted by knightpro for some reason have added it hear
  /*static THREE.Vector3 multiplyScalar(THREE.Vector3 vec, num scalar) {
    vec.x *= scalar;
    vec.y *= scalar;
    vec.z *= scalar;

    return vec;
  }*/

  static isNumeric(char) {
    return int.tryParse(char) != null || double.tryParse(char) != null;
    /*  if (char.length != 1) {
        return false;
      }
      // Matches any digit from 0-9
      RegExp numeric = RegExp(r'^[0-9]$');
      return numeric.hasMatch(char);*/
  }

  /// Given a [y] value and non convex path in [pointorig] (eg  e.g. [[1,1],[2,1],[3.5,1],[10,2]]), get an x value using interpolation
  static double interpolateX(double y, List<List<double>> pointsorig) {
    // 1. Sort points by Y-coordinate (index 1)
    var points = [...pointsorig]; //pointorig.
    points.sort((a, b) => a[1].compareTo(b[1]));

    // 2. Handle out-of-bounds
    if (y <= points.first[1]) return points.first[0];
    if (y >= points.last[1]) return points.last[0];

    // 3. Find the segment
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      if (y >= p0[1] && y <= p1[1]) {
        // 4. Linear Interpolation Formula
        final fraction = (y - p0[1]) / (p1[1] - p0[1]);
        return p0[0] + fraction * (p1[0] - p0[0]);
      }
    }
    return points.last[0];
  }

  /// Given a [x] value and non convex path in [pointorig] (eg  e.g. [[1,1],[2,1],[3.5,1],[10,2]]), get a y value using interpolation
  static double interpolateY(double x, List<List<double>> pointsorig) {
    // 1. Sort points by Y-coordinate (index 1)
    var points = [...pointsorig]; //pointorig.
    points.sort((a, b) => a[0].compareTo(b[0]));

    // 2. Handle out-of-bounds
    if (x <= points.first[0]) return points.first[1];
    if (x >= points.last[0]) return points.last[1];

    // 3. Find the segment
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      if (x >= p0[0] &&x <= p1[0]) {
        // 4. Linear Interpolation Formula
        final fraction = (x - p0[0]) / (p1[0] - p0[0]);
        return p0[1] + fraction * (p1[1] - p0[1]);
      }
    }
    return points.last[1];
  }

  /// Interpolates along a polyline of 2D points at a fixed distance increment.
  ///
  /// [points]    – the input polyline, e.g. [[1,1],[2,1],[3.5,1],[10,2]]
  /// [increment] – the step distance between output points
  /// Returns a new list of [x, y] points sampled along the path.
  static List<List<double>> interpolateByIncrement(
    List<List> pointsorig,
    double increment,
  ) {
    List<List<double>> points = pointsorig.map((innerList) {
      return innerList.map((item) => (item as num).toDouble()).toList();
    }).toList();

    if (points.length < 2) return List.from(points);

    final result = <List<double>>[];

    // Always include the first point
    result.add(List.from(points.first));

    int segmentIndex = 0; // current segment start index
    double distanceIntoSegment = 0.0; // how far we are into the current segment
    double accumulated = 0.0; // distance accumulated toward the next sample

    while (segmentIndex < points.length - 1) {
      final p1 = points[segmentIndex];
      final p2 = points[segmentIndex + 1];

      final dx = p2[0] - p1[0];
      final dy = p2[1] - p1[1];
      final segmentLength = math.sqrt(dx * dx + dy * dy);
      final remaining = segmentLength - distanceIntoSegment;

      if (accumulated + remaining < increment) {
        // Not enough room in this segment — consume it and move on
        accumulated += remaining;
        segmentIndex++;
        distanceIntoSegment = 0.0;
      } else {
        // Place one or more sample points within this segment
        double needed = increment - accumulated;

        while (distanceIntoSegment + needed <= segmentLength) {
          distanceIntoSegment += needed;
          final t = distanceIntoSegment / segmentLength;
          result.add([p1[0] + t * dx, p1[1] + t * dy]);
          needed = increment; // subsequent points are a full increment apart
        }

        accumulated = segmentLength - distanceIntoSegment;
        segmentIndex++;
        distanceIntoSegment = 0.0;
      }
    }

    // Optionally include the final point if it isn't already there
    final last = points.last;
    final prev = result.last;
    const epsilon = 1e-9;
    if ((last[0] - prev[0]).abs() > epsilon ||
        (last[1] - prev[1]).abs() > epsilon) {
      result.add(List.from(last));
    }

    return result;
  }

  /// Given point [a] and point [b] find the point between them by distance [fraction]
  static List<double> interpolateTwoPoints(List a, List b, fraction) {
    return [
      a[0].toDouble() +
          (b[0].toDouble() - a[0].toDouble()) * fraction.toDouble(),
      a[1].toDouble() +
          (b[1].toDouble() - a[1].toDouble()) * fraction.toDouble(),
    ];
  }

  // Finds the next point in a [path] from a position [x], [y] in the [path] - is it not the closest to x,y but the next
  // Eg if path is = [ [-15.2,40.66-0.1], [-19.67,38.0], [-28.63,34.99], ];
  // and have point -19.5, 38.0 it'll pick -16.67,38.0 but if -19.9,38.0 it'll pick -28.63,34.99
  static int findClosestNextIndex(List<List> path, x, y) {
    if (path.length < 2) return 0;

    double bestDistSq = double.infinity;
    int bestIndex = 0;

    for (int i = 0; i < path.length - 1; i++) {
      final ax = path[i][0].toDouble(), ay = path[i][1].toDouble();
      final bx = path[i + 1][0].toDouble(), by = path[i + 1][1].toDouble();

      final abx = bx - ax, aby = by - ay;
      final apx = x.toDouble() - ax, apy = y.toDouble() - ay;

      final abLenSq = abx * abx + aby * aby;
      final t = abLenSq > 0 ? (apx * abx + apy * aby) / abLenSq : 0.0;
      final tClamped = t.clamp(0.0, 1.0);

      final closestX = ax + tClamped * abx;
      final closestY = ay + tClamped * aby;

      final dx = x.toDouble() - closestX, dy = y.toDouble() - closestY;
      final distSq = dx * dx + dy * dy;

      if (distSq < bestDistSq) {
        bestDistSq = distSq;
        // t <= 0 means we haven't reached point i yet -> target i.
        // t > 0 means we're on/past this segment -> target the next point ahead.
        bestIndex = (t <= 0.0) ? i : i + 1;
      }
    }

    return bestIndex;
  }
}

/// Keyboardcallbacks allow callback for keyboard presses with conditions including distance and angle facing an object
/// For example if a certain distance from a donkey to ride and facing direction the callback will be called if the key is pressed

enum KeyboardCallbackType  {
  conditional,  // only active if a condition is true eg is a certain distance away from an object
  unconditional, // always active so say can press 'E' and it will always call the callback
  disabled  // turn off the callback
}

class KeyboardCallback {
  late String key;
  late double? x=null;
  late double? y=null;
  late int level;
  late double dist;  // distance from object or x,y for callback to be active
  late double? facingdiff=null;  // the difference angle at which you must be facing the x,y or object
  late THREE.Object3D? object=null;
  late double? keyreactivatetime=null;// time before the key is active again - so stop issue of double clicking quickly
  late Function callback;
  KeyboardCallbackType type=KeyboardCallbackType.conditional;   // What type of callback
  //bool alwaystrue=false;  // If you press this key then the callback is called conditionally

 KeyboardCallback(key,level, dist, callback, {x,y,object, facingdiff,keyreactivatetime}) {
    this.key=key; this.level=level; this.dist=dist; this.callback=callback; this.object=object;
    if (x!=null)
      this.x=x.toDouble();
    if (y!=null)
      this.y=y.toDouble();
    if (facingdiff!=null)
      this.facingdiff=facingdiff.toDouble();
    if (keyreactivatetime!=null)
       this.keyreactivatetime=keyreactivatetime.toDouble();
  }
}

class KeyboardCallbacks {
  static var keyboardcallbacks=[];
  static Map<String,int> keyreactivatetimes= {};
  static init() {
    keyboardcallbacks=[];
  }

  /// Create a keyboard callback
  /// [key] is the keyboard key that the callback is for eg 'E'
  /// [dist] is how close the camera has to be to the [object] or [x],[y] before the callback is active if its type is conditional
  /// [callback] is the callback function to be called if they key is pressed and the conditions are met
  /// [facingdiff] is the angle the threshold at which you must be facing the [object] or [x],[y] before the conditional keyboardcallback is active
  /// [keyreactivatetime] is how long before a keypress can be pressed again for the callback to be called - stopped too many callbacks being pressed at once
  static createKeyboardCallback(key, dist, callback, {x,y,level=0,object, facingdiff,keyreactivatetime}) {
    var keyboardcallback=KeyboardCallback(key, level, dist, callback,x:x,y:y,object:object,facingdiff:facingdiff,keyreactivatetime:keyreactivatetime);
    keyboardcallbacks.add(keyboardcallback);
    return keyboardcallback;
  }

  /// Find a callback associated with [object]
  static findByObject(object) {
    for (var keyboardcallback in keyboardcallbacks)
      if (keyboardcallback.object==object)
        return keyboardcallback;
    return null;
  }

  /// Handle they keyboard [key] being pressed and decide which callbacks should be called
  static keydown(key) {
    var found = false;
    if (key is String) {
      var keyok;
      if (keyreactivatetimes[key] != null) {
         if ( System.currentMilliseconds() - keyreactivatetimes[key] < 0)
            keyok = false;
         else {
           keyok=true;
           keyreactivatetimes.remove(key);
         }
      } else
        keyok = true;
      if (keyok) {
        var worldpos = Space.localToWorldObj(Camera._camera);
        for (var keyboardcallback in keyboardcallbacks) {
          if (keyboardcallback.type!=KeyboardCallbackType.disabled&&
              (keyboardcallback.object == null || keyboardcallback.type==KeyboardCallbackType.unconditional||//alwaystrue||
              keyboardcallback.object.visible)) {
            var x, y;
            if (keyboardcallback.object != null) {
              var pos = Space.localToWorldObj(keyboardcallback.object);
              x = pos.x;
              y = pos.y;
            } else {
              x = keyboardcallback.x;
              y = keyboardcallback.y;
            }
            print("keyboardcallback" + key + " " + x.toString() +
                " " + y.toString() + " " + keyboardcallback.level.toString() +
                " " + keyboardcallback.dist.toString() + " " +
                keyboardcallback.key.toString() + " " +
                keyboardcallback.object.toString() + " " +
                keyboardcallback.facingdiff.toString()+" "+worldpos.x.toString()+" "+worldpos.y.toString()+" "+keyboardcallback.type.toString());//alwaystrue.toString());
            if (keyboardcallback.key == key &&
                ( keyboardcallback.type==KeyboardCallbackType.unconditional||(  keyboardcallback.level == You.level &&  //keyboardcallback.alwaystrue
                worldpos.x > x - keyboardcallback.dist &&
                worldpos.x < x + keyboardcallback.dist &&
                worldpos.y > y - keyboardcallback.dist &&
                worldpos.y < y + keyboardcallback.dist))) {

              print("found keybaord callback");
              var facingok;
              // If right on top of the object the dont worry about facing
              if ( keyboardcallback.type!=KeyboardCallbackType.unconditional&&keyboardcallback.facingdiff != null &&  //!keyboardcallback.alwaystrue
                  keyboardcallback.object != null) {//&&(x -worldpos.x).abs()>0.15&&(y -worldpos.y).abs()>0.15) {
                facingok = You.isfacing(
                    keyboardcallback.object, keyboardcallback.facingdiff);

              } else
                facingok = true;
              if (facingok) {
                print("done keyboardcallback");
                if (keyboardcallback.keyreactivatetime != null)
                  keyreactivatetimes[keyboardcallback.key] =
                      System.currentMilliseconds() +
                          (keyboardcallback.keyreactivatetime * 1000).round();
                keyboardcallback.callback(keyboardcallback);
                found = true;
              }
            }
          }
        }
      }
    }
    return found;
  }
}


/// Functions for game control with keyboard
class Keyboard {
  Map keyCodes = {};
  Map modifiers = {};
  static int lastmovetick = -1;
  static int lastturntick = -1;

  Map ALIAS = {
    'left': LogicalKeyboardKey.arrowLeft.keyId, //37,
    'up': LogicalKeyboardKey.arrowUp.keyId, //38,
    'right': LogicalKeyboardKey.arrowRight.keyId, //39,
    'down': LogicalKeyboardKey.arrowDown.keyId, //40,
    'space': 32,
    'pageup': 33,
    'pagedown': 34,
    'tab': 9,
    'escape': 27,
  };

  List MODIFIERS = ['shift', 'ctrl', 'alt', 'meta'];

  //onKeyChange(KeyEvent event, eventtype) {
  onKeyChange(LogicalKeyboardKey event, eventtype) {
    // update this.keyCodes
    //print("keyid"+event.keyId.toString());
    var keyCode;
    if (event.keyId < 255)
      //    if (event.logicalKey.keyId<255)
      keyCode = String.fromCharCode(event.keyId).toUpperCase();
    //      keyCode = String.fromCharCode(event.logicalKey.keyId).toUpperCase();
    else
      keyCode = event.keyId;
    //      keyCode=event.logicalKey.keyId;

    var pressed = eventtype == 'keydown' ? true : false;

    //    print("keychange"+keyCode.toString()+" "+pressed.toString()+" "+event.logicalKey.keyId.toString());
    this.keyCodes[keyCode] = pressed;

    // update this.modifiers
    this.modifiers['shift'] =
        event.keyId == LogicalKeyboardKey.shift.keyId; //shiftKey;
    //        event.logicalKey.keyId == LogicalKeyboardKey.shift.keyId; //shiftKey;
    this.modifiers['ctrl'] =
        event.keyId == LogicalKeyboardKey.control.keyId; //event.ctrlKey;
    //        event.logicalKey.keyId == LogicalKeyboardKey.control.keyId; //event.ctrlKey;
    this.modifiers['alt'] =
        event.keyId == LogicalKeyboardKey.alt.keyId; //event.altKey;
    //        event.logicalKey.keyId == LogicalKeyboardKey.alt.keyId; //event.altKey;
    this.modifiers['meta'] =
        event.keyId == LogicalKeyboardKey.meta.keyId; //event.metaKey;
    //        event.logicalKey.keyId == LogicalKeyboardKey.meta.keyId; //event.metaKey;
    if (this.pressed("W") ||
        this.pressed("S") ||
        this.pressed("up") ||
        this.pressed("down") ||
        (!VirtualJoystick.getJoyStickTurn() &&
            (this.pressed("D") ||
                this.pressed("right") ||
                this.pressed("A") ||
                this.pressed("left"))))
      lastmovetick = System.currentMilliseconds();
    if ((VirtualJoystick.getJoyStickTurn() &&
        (this.pressed("D") ||
            this.pressed("right") ||
            this.pressed("A") ||
            this.pressed("left"))))
      lastturntick = System.currentMilliseconds();
  }

  // eg right
  pressed(keyDesc) {
    var keys = keyDesc.split("+");
    for (var i = 0; i < keys.length; i++) {
      String key = keys[i];
      var pressed = false;
      if (MODIFIERS.indexOf(key) != -1) {
        //print("nnn");
        pressed = this.modifiers[key];
      } else if (ALIAS.containsKey(key)) {
        //print("yyy");
        if (this.keyCodes.containsKey(ALIAS[key])) {
          pressed = this.keyCodes[ALIAS[key]];
        }
      } else if (this.keyCodes.containsKey(key.toUpperCase()[0])) {
        // print("lll");

        pressed = this.keyCodes[key.toUpperCase()[0]];
      } //else
      //  print("ppp");
      //print('ooo'+key.toString()+" "+pressed.toString()+" "+keyCodes.toString());
      if (!pressed) return false;
    }

    return true;
  }
}

/// Functions for game control with virtual joystick for smartphones
class VirtualJoystick {
  bool _active = false;

  late Keyboard keyboard;

  double targetRotationX = 0;
  double targetRotationY = 0;

  double _baseX = 0;
  double _baseY = 0;

  double _stickX = 0;
  double _stickY = 0;

  double _lastClientX = 0.0;
  double _lastClientY = 0.0;

  bool _stickpressed = false;
  bool _screenpressed = false;
  double swipeturnamt=30000;  // when drag horizontally on screen how fast do you turn

  int joysticksize =
      320; // How big is the joystick so know to ignore touches in that area
  double minpitch = -25; // Mininum camera pitch allowed - make zero if no lower limit
  double maxpitch = 25; // Maximum camera pitch allowed - make zero if no upper limit

  THREE.Object3D testintersect = THREE.Object3D();

  /// Initialise joystick with the pixel size of the joystick [joysticksize] so doesn't get confused with screenswipe
  /// [minpitch] and [maxpitch] is the maximum and minimum pitch of the camera so that dont end up with the camera up in the air or pointing down at the ground
  VirtualJoystick({joysticksize, minpitch, maxpitch}) {
    // this._space = space;
    this._active = true;
    keyboard = Keyboard();
    if (System.isDesktop())
       swipeturnamt=30000;
    else
       swipeturnamt=0.5*30000;

    if (joysticksize != null) this.joysticksize = joysticksize;
    if (minpitch != null) this.minpitch = minpitch.toDouble();
    if (maxpitch != null) this.maxpitch = maxpitch.toDouble();
    Space._scene.add(testintersect);
  }

  static getJoyStickTurn() {
    return !System.isDesktop();
  }

  deltaX() {
    return this._stickX - this._baseX;
  }

  deltaY() {
    return this._stickY - this._baseY;
  }

  /// For joystick how many pixels up
  up() {
    if (this._stickpressed == false) return 0; //false;
    var deltaX = this.deltaX();
    var deltaY = this.deltaY();
    if (deltaY >= 0) return 0; // false;
    if (deltaX.abs() > 2 * deltaY.abs()) return 0; //false;
    return deltaY.abs(); //true;
  }

  /// For joystick how many pixels down
  down() {
    if (this._stickpressed == false) return 0; //false;
    var deltaX = this.deltaX();
    var deltaY = this.deltaY();
    if (deltaY <= 0) return 0; //false;
    if (deltaX.abs() > 2 * deltaY.abs()) return 0; //false;
    return deltaY.abs(); //true;
  }

  /// For joystick how many pixels right
  right() {
    if (this._stickpressed == false) return 0;
    var deltaX = this.deltaX();
    var deltaY = this.deltaY();
    if (deltaX <= 0) return 0;
    if (deltaY.abs() > 2 * deltaX.abs()) return 0;
    return deltaX.abs(); //true;
  }

  /// For joystick how many pixels left
  left() {
    if (this._stickpressed == false) return 0; //false;
    var deltaX = this.deltaX();
    var deltaY = this.deltaY();
    if (deltaX >= 0) return 0; //false;
    if (deltaY.abs() > 2 * deltaX.abs()) return 0; //false;
    return deltaX.abs(); //true;
  }

  /// Stick has been moved
  onStickChange(stickX, stickY) {
    // print("stick change");
    this._stickX = stickX;
    this._stickY = stickY;
    this._stickpressed = true;
    this._screenpressed = false;
  }

  /// Stick stop move
  onStickUp() {
    this._stickpressed = false;
    // print("stickup");
  }

  /// Is stick being pressed
  getStickPressed() {
    return this._stickpressed;
    // print("stick pressed")
  }

  /// screen pressed
  onTouchDown(clientX, clientY) {
    if (!this._stickpressed) {
      this._screenpressed = true;
      _lastClientX = clientX;
      _lastClientY = clientY; //throwBall();

      // print("ooo");
    } //else
    // print("xxx");
  }

  /// screen swiped so move camera - if swipe left or right turn camera left or right, if swipe up down then pitch camera up and down
  onTouch(clientX, clientY, screenWidth, screenHeight, delta) {
    if (You.immobileturn) return;
    // If close to joystick then ignore so stop big jumps
    if (!System.isDesktop() &&
        (clientX < joysticksize || _lastClientX < joysticksize) &&
        (_lastClientY < joysticksize || clientY < joysticksize)) {
      print(
        'miss ' +
            _lastClientX.toString() +
            " " +
            clientX.toString() +
            " " +
            _lastClientY.toString() +
            " " +
            clientY.toString(),
      );
      _lastClientX = clientX;
      _lastClientY = clientY;
      return;
    }
    // divide by 6 size that dont accidently change pitch
    if ((_lastClientX - clientX).abs() > (_lastClientY - clientY).abs() / 6) {
      // Mean horizontal swipe so turn

      Keyboard.lastturntick = System.currentMilliseconds();
      Camera.setTurn(
        Camera.turn -
            (swipeturnamt * delta * ((_lastClientX - clientX) / screenWidth)),
      ); //THREE.MathUtils.radToDeg(roty));
    } else {
      // Vertical swipe so pitch
      //print("rotupdown"+_lastClientX.toString()+" "+ clientX.toString()+" "+_lastClientY.toString() +" "+clientY.toString());
      var newpitch =
          Camera.pitch +
          (30000 * delta * ((_lastClientY - clientY) / screenHeight));
      // print('pitch'+newpitch.toString());
      if ((minpitch == 0 || newpitch > minpitch || (Camera.pitch<minpitch&&newpitch>Camera.pitch)) &&
          (maxpitch == 0 || newpitch < maxpitch || (Camera.pitch>maxpitch&&newpitch<Camera.pitch))) {
        print("pitchset" + newpitch.toString());
        Camera.pitchset = newpitch;
        Camera.setPitch(newpitch);
        Keyboard.lastturntick = System.currentMilliseconds();
      } //else
      //    print("new pitch failed:"+newpitch.toString());
    }
    _lastClientX = clientX;
    _lastClientY = clientY;
  }

  /// No longer touching screen
  onTouchUp() {
    print("tocuhup");
    this._screenpressed = false;
  }

  /// if keyboard pressed then move camera
  /// Called in animate()
  update(frameTime) {
    // if low framerate then cap the frame so dont jump too far
    if (frameTime > 0.05) {
      frameTime = 0.05;
      //print("capped frametime");
    }

    if (!this._screenpressed) {
      /// This part seems redundant as this is always active
      if (!this._active &&
          !this.keyboard.pressed("W") &&
          !this.keyboard.pressed("S") &&
          !this.keyboard.pressed("up") &&
          !this.keyboard.pressed("down") &&
          !You.immobileturn) {
        // This is if you turn with the keyboard  left or right
        var rotamt;
        if (!System.isDesktop()) //kIsWeb)
          rotamt =
              0.15; // this is redundant because you woudln't use a keyboard on a smartphone
        else
          rotamt = 1.2;

        Camera.setTurn(Camera.turn - targetRotationY * frameTime * rotamt);
        Camera._camera.up = new THREE.Vector3(0, 1, 0);
      } else {}
    }

    // Make sure camera up is pointing up
    Camera._camera.up = new THREE.Vector3(0, 1, 0);

    targetRotationX = 0;
    targetRotationY = 0;

    var rotamt;
    if (!System.isDesktop()) //kIsWeb) //this._ismobile)
      rotamt = 150;
    else
      rotamt = 300;

    // For smartphones joystick left and right turns you left and right while on web will slide you left and right
    var joystickturn =
        VirtualJoystick.getJoyStickTurn(); //!System.isDesktop();//kIsWeb;//true;

    // This is for the keyboard
    if (this._active) {
      var moveamt = You.speed * You.drag * frameTime;
      if (this.keyboard.pressed("D") || this.keyboard.pressed("right")) {
        if (joystickturn && !You.immobileturn) {
          Camera.setTurn(
            Camera.turn + frameTime * rotamt,
          ); // * math.pi / 180);//_camera.rotateY(frameTime * rotamt * math.pi / 180);
        } else if (!You.immobile) {
          var ok;
          if (You.level > 0) {
            // Test that the position moving to has a surface. If not dont move
            testintersect.position = Camera._camera.position.clone();
            testintersect.quaternion = Camera._camera.quaternion.clone();
            // Makes no sense that this is negative
            testintersect.translateX(moveamt + 0.04);
            var intersect = Space.localIntersectSurfaceVector(
              testintersect.position.x,
              Camera._camera.position.y,
              testintersect.position.z,
              level: You.level,
            );
            ok = intersect != null;
          } else
            ok = true;
          if (ok)
            Space.objLeftRightSurface(
              Camera._camera,
              moveamt,
              Camera.cameraoffset,
              level: You.level,
            );
        }
      }
      if (this.keyboard.pressed("A") || this.keyboard.pressed("left")) {
        if (joystickturn && !You.immobileturn)
          Camera.setTurn(Camera.turn - frameTime * rotamt);
        //Camera._camera.rotateY(-frameTime * rotamt * math.pi / 180);
        else if (!You.immobile) {
          var ok;
          if (You.level > 0) {
            // Test that the position moving to has a surface. If not dont move
            testintersect.position = Camera._camera.position.clone();
            testintersect.quaternion = Camera._camera.quaternion.clone();
            // Makes no sense that this is negative
            testintersect.translateX(-moveamt - 0.04);
            var intersect = Space.localIntersectSurfaceVector(
              testintersect.position.x,
              Camera._camera.position.y,
              testintersect.position.z,
              level: You.level,
            );
            ok = intersect != null;
          } else
            ok = true;

          if (ok)
            Space.objLeftRightSurface(
              Camera._camera,
              -You.speed * You.drag * frameTime,
              Camera.cameraoffset,
              level: You.level,
            );
        }
      }
      if (((this.keyboard.pressed("W") || this.keyboard.pressed("up"))) &&
          !You.immobile) {
        //print("move forward"+(-You.speed* You.drag * frameTime).toString()+' '+You.speed.toString()+' ' +You.drag.toString());
        var ok;
        // print("you"+You.level.toString());
        if (You.level > 0) {
          // Test that the position moving to has a surface. If not dont move
          // THREE.Vector3 dog;
          // dog.co
          /*   testintersect.children.clear();
          var geometry = THREE.BoxGeometry( 0.01, 0.01, 0.01 );
          var material = THREE.MeshBasicMaterial.fromMap( { 'color': THREE.Color.fromHex32(0x00ff00) } );
          var cube = THREE.Mesh( geometry, material );
          testintersect.add(cube);*/

          //   Space.worldToLocalSurfaceObj(cube, position['p'][0].toDouble(), position['p'][1].toDouble(),0.0);
          //  Space._scene.add( cube );
          testintersect.position = Camera._camera.position.clone();
          //testintersect.rotation=Camera._camera.rotation.clone();
          //testintersect.up=Camera._camera.up.clone();
          testintersect.quaternion = Camera._camera.quaternion.clone();
          // Makes no sense that this is negative
          testintersect.translateZ(-moveamt - 0.04);
          var intersect = Space.localIntersectSurfaceVector(
            testintersect.position.x,
            Camera._camera.position.y,
            testintersect.position.z,
            level: You.level,
          );
          ok = intersect != null;
          //  print("intersect!!"+ok.toString());
          //var localy = Space.localIntersectSurface(
          //    testintersect.position.x, Camera._camera.position.y, testintersect.position.z,level:You.level);
        } else
          ok = true;

        if (ok) {
          var y = Camera._camera.position.y;
          Space.objForwardSurface(
            Camera._camera,
            -moveamt,
            // why negative ?? -You.speed * You.drag * frameTime,
            Camera.cameraoffset,
            level: You.level,
          );
          //  if (You.level == 0)
          // Fudge so that if dont jolt going up stairs

          Camera._camera.position.y = Camera._camera.position.y * 0.2 + y * 0.8;
        }
      }
      if (((this.keyboard.pressed("S") || this.keyboard.pressed("down")) &&
          !You.immobile)) {
        var ok;
        if (You.level > 0) {
          // Test that the position moving to has a surface. If not dont move
          testintersect.position = Camera._camera.position.clone();
          testintersect.quaternion = Camera._camera.quaternion.clone();
          // Makes no sense that this is negative
          testintersect.translateZ(moveamt + 0.04);
          var intersect = Space.localIntersectSurfaceVector(
            testintersect.position.x,
            Camera._camera.position.y,
            testintersect.position.z,
            level: You.level,
          );
          ok = intersect != null;
        } else
          ok = true;

        if (ok)
          //You.speed* You.drag * frameTime
          Space.objForwardSurface(
            Camera._camera,
            moveamt,
            Camera.cameraoffset,
            level: You.level,
          );
      }
    }

    // This is for the joystick
    // If smartphone then the joystick left and right turns you left and right while if web then will slide you left and right
    if (this._active) {
      const fct = 2.0;   // move amount factor with joystick

      if (this.right() > 0) {
        if (joystickturn && !You.immobileturn)
          Camera.setTurn(
            Camera.turn + frameTime * this.right() * this.right() * rotamt,
          );
        else if (!You.immobile) {
          Space.objLeftRightSurface(
            Camera._camera,
            You.speed * You.drag * this.right() * frameTime,
            Camera.cameraoffset,
            level: You.level,
          );
        }
      }
      if (this.left() > 0) {
        if (joystickturn && !You.immobileturn)
          Camera.setTurn(
            Camera.turn - frameTime * this.left() * this.left() * rotamt,
          );
        else if (!You.immobile)
          Space.objLeftRightSurface(
            Camera._camera,
            -You.speed * You.drag * this.left() * frameTime,
            Camera.cameraoffset,
          );
      }
      if (this.up() > 0 && !You.immobile) {
        //camera.position.z = camera.position.z -  amt * frameTime;
        var ok;
        // print("you"+You.level.toString());
        if (You.level > 0) {
          // Test that the position moving to has a surface. If not dont move
          // THREE.Vector3 dog;
          // dog.co
          /*   testintersect.children.clear();
          var geometry = THREE.BoxGeometry( 0.01, 0.01, 0.01 );
          var material = THREE.MeshBasicMaterial.fromMap( { 'color': THREE.Color.fromHex32(0x00ff00) } );
          var cube = THREE.Mesh( geometry, material );
          testintersect.add(cube);*/

          //   Space.worldToLocalSurfaceObj(cube, position['p'][0].toDouble(), position['p'][1].toDouble(),0.0);
          //  Space._scene.add( cube );
          testintersect.position = Camera._camera.position.clone();
          //testintersect.rotation=Camera._camera.rotation.clone();
          //testintersect.up=Camera._camera.up.clone();
          testintersect.quaternion = Camera._camera.quaternion.clone();
          // Makes no sense that this is negative
          testintersect.translateZ(-You.speed * You.drag * this.down() * frameTime* fct-0.04);//-moveamt - 0.04);
          var intersect = Space.localIntersectSurfaceVector(
            testintersect.position.x,
            Camera._camera.position.y,
            testintersect.position.z,
            level: You.level,
          );
          ok = intersect != null;
          //  print("intersect!!"+ok.toString());
          //var localy = Space.localIntersectSurface(
          //    testintersect.position.x, Camera._camera.position.y, testintersect.position.z,level:You.level);
        } else
          ok = true;
        if (ok)
         Space.objForwardSurface(Camera._camera,
          -You.speed * You.drag * this.up() * You.drag * frameTime*fct,
          Camera.cameraoffset,
          level: You.level,
        );
      }
      if (this.down() > 0 && !You.immobile) {
        var ok;
        if (You.level > 0) {
          // Test that the position moving to has a surface. If not dont move
          testintersect.position = Camera._camera.position.clone();
          testintersect.quaternion = Camera._camera.quaternion.clone();
          // Makes no sense that this is negative
          testintersect.translateZ(You.speed * You.drag * this.down() * frameTime*fct+ 0.04);
          var intersect = Space.localIntersectSurfaceVector(
            testintersect.position.x,
            Camera._camera.position.y,
            testintersect.position.z,
            level: You.level,
          );
          ok = intersect != null;
        } else
          ok = true;

        if (ok)
          Space.objForwardSurface(
          Camera._camera,
          You.speed * You.drag * this.down() * frameTime*fct,
          Camera.cameraoffset,
            level: You.level
        );
      }
    }
  }
}

/// Functions for textures such as creating a text texture and lerping opacity of texture
class Texture {
  static List _lerpopacityobjects = [];
  static String defaultfontfamily =
      ""; // Set this so that you can use a default font family without needing to specify it every time

  /// This is a general purpose text painter used by sprites, planes
  /// Returns a metadata map, not just a TextPainter
  /// [message] the text to write
  static makeTextPainter(
    message, {
    Color textcolor = Colors.white,
    fontSize = 20,
    backgroundcolor = Colors.black,
    backgroundopacity = 0.5,
    width = 200,
    fontfamily,
    bold,
    paddingLeft = 0.0,
    paddingRight = 0.0,
    paddingTop = 0.0,
    paddingBottom = 0.0,
  }) {
    var usefontfamily = "";
    if (defaultfontfamily != "")
      usefontfamily = defaultfontfamily;
    else if (fontfamily != null)
      usefontfamily = fontfamily;

    var fontWeight = (bold != null && bold)
        ? FontWeight.bold
        : FontWeight.normal;

    TextStyle textStyle;
    if (usefontfamily == "")
      textStyle = TextStyle(
        color: textcolor,
        fontSize: fontSize.toDouble(),
        fontWeight: fontWeight,
      );
    else
      textStyle = TextStyle(
        fontFamily: usefontfamily,
        color: textcolor,
        fontSize: fontSize.toDouble(),
        fontWeight: fontWeight,
      );

    final textPainter = TextPainter(
      text: TextSpan(text: message, style: textStyle),
      textDirection: TextDirection.ltr,
    );

    double availableWidth =
        width.toDouble() - paddingLeft.toDouble() - paddingRight.toDouble();
    textPainter.layout(
      minWidth: 0,
      maxWidth: availableWidth > 0 ? availableWidth : width.toDouble(),
    );

    if (textPainter.width <= 0) return null;

    double totalWidth =
        textPainter.width + paddingLeft.toDouble() + paddingRight.toDouble();
    double totalHeight =
        textPainter.height + paddingTop.toDouble() + paddingBottom.toDouble();

    return {
      'textPainter': textPainter,
      'totalWidth': totalWidth,
      'totalHeight': totalHeight,
      'paddingLeft': paddingLeft.toDouble(),
      'paddingTop': paddingTop.toDouble(),
      'bgPaint': Paint()
        ..color = backgroundcolor.withOpacity(backgroundopacity.toDouble()),
    };
  }

  // Merges a list of makeTextPainter maps into a single texture, laid out horizontally
  /// [tails] - which speech-bubble pointer(s) to draw at the bottom of the
  /// combined bubble: any of 'bottomleft', 'bottomcenter', 'bottomright'.
  /// Leave null/empty for a plain rectangle (the original behaviour). All
  /// segments share ONE background shape/color when tails are used (the
  /// first segment's background paint) - tails don't support per-segment
  /// background colors, since a tail is a property of the whole bubble.
  /// [tailSize] how far the tail's point extends below the bubble, in
  /// pixels.
  static makeTextPainters(
    List<Map> painters, {
    Set<String>? tails,
    double tailSize = 15,
  }) async {
    // Filter out any nulls
    final valid = painters.where((p) => p != null).toList();
    if (valid.isEmpty) return null;

    // Total width is sum of all segments; height is the tallest segment
    double totalWidth = valid.fold(
      0.0,
      (sum, p) => sum + (p['totalWidth'] as double),
    );
    double totalHeight = valid.fold(
      0.0,
      (max, p) =>
          (p['totalHeight'] as double) > max ? p['totalHeight'] as double : max,
    );

    var usetails = tails ?? <String>{};
    // The tail pokes out below the bubble, so the canvas/texture need to be
    // taller than the text content itself when any tail is requested. Text
    // positioning below stays relative to totalHeight (the un-extended
    // content area) - only the background shape and final image extend
    // further down.
    double canvasHeight = totalHeight + (usetails.isNotEmpty ? tailSize : 0);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    if (usetails.isNotEmpty) {
      // One shared outline for the whole bubble, using the first segment's
      // background paint - traces top/right/bottom edges, dipping into a
      // pointed notch at the bottom wherever a tail was requested, then
      // closes back up the left edge.
      final Paint bgPaint = valid.first['bgPaint'] as Paint;
      final double notchHalfWidth = tailSize * 0.5; //0.6;

      final notchPositions = <double>[];
      if (usetails.contains('bottomright'))
        notchPositions.add(totalWidth); // * 0.94);//0.82);
      if (usetails.contains('bottomcenter'))
        notchPositions.add(totalWidth * 0.5);
      if (usetails.contains('bottomleft'))
        notchPositions.add(0); //totalWidth * 0.06);//0.18);
      // Walking the bottom edge right-to-left, so visit notches in that order.
      notchPositions.sort((a, b) => b.compareTo(a));

      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(totalWidth, 0)
        ..lineTo(totalWidth, totalHeight);

      for (final notchX in notchPositions) {
        if (notchX == totalWidth * 0.5)
          path.lineTo(notchX + notchHalfWidth / 2, totalHeight);
        else if (notchX < totalWidth * 0.75)
          path.lineTo(notchX + notchHalfWidth, totalHeight);
        else
          path.lineTo(notchX, totalHeight);
        path.lineTo(notchX, canvasHeight);
        if (notchX == totalWidth * 0.5)
          path.lineTo(notchX - notchHalfWidth / 2, totalHeight);
        else if (notchX > totalWidth * 0.25)
          path.lineTo(notchX - notchHalfWidth, totalHeight);
        else
          path.lineTo(notchX, totalHeight);
      }

      path.lineTo(0, totalHeight);
      path.close();

      // Fill fully opaque inside an offscreen layer, then apply bgPaint's
      // actual opacity once to the whole flattened result on restore().
      // Filling this path directly with a translucent paint leaves a
      // visible hairline seam along the flat parts of the bottom edge next
      // to each tail notch - Skia anti-aliases each adjacent path segment
      // independently, and stacking their partial-alpha edges at a shared
      // near-collinear boundary doesn't blend cleanly. Compositing as one
      // opaque shape first and applying the opacity in a single pass avoids
      // that seam entirely.
      final layerBounds = Rect.fromLTWH(0, 0, totalWidth, canvasHeight);
      canvas.saveLayer(layerBounds, Paint()..color = bgPaint.color);
      canvas.drawPath(
        path,
        Paint()
          ..color = bgPaint.color.withOpacity(1.0)
          ..style = bgPaint.style,
      );
      canvas.restore();
    }

    double xOffset = 0.0;
    for (final p in valid) {
      final double segWidth = p['totalWidth'] as double;
      final double segHeight = p['totalHeight'] as double;
      final double padLeft = p['paddingLeft'] as double;
      final double padTop = p['paddingTop'] as double;
      final TextPainter tp = p['textPainter'] as TextPainter;
      final Paint bgPaint = p['bgPaint'] as Paint;

      if (usetails.isEmpty) {
        // No tails requested - original per-segment rectangle behaviour,
        // unchanged, so existing calls render exactly as before.
        canvas.drawRect(
          Rect.fromLTWH(xOffset, 0, segWidth, totalHeight),
          bgPaint,
        );
      }

      // Draw this segment's text, offset by its own padding + current x position
      tp.paint(canvas, Offset(xOffset + padLeft, padTop));

      xOffset += segWidth;
    }

    final im = await recorder.endRecording().toImage(
      totalWidth.toInt(),
      canvasHeight.toInt(),
    );
    final pngBytes = await im.toByteData(format: ImageByteFormat.rawRgba);

    // Flip vertically by reversing pixel rows directly, rather than via
    // RepeatWrapping + repeat.y=-1. RepeatWrapping makes the GPU's texture
    // filter sample across the top/bottom seam as if the image tiles - with
    // a plain rectangle that's invisible (opaque background right to the
    // edges), but with tails there's transparent space beside each notch,
    // and that wrap-sampling bleeds a thin strip of opaque background across
    // it, which is exactly the seam artifact under the tails. Flipping the
    // actual pixel data avoids depending on texture wrapping for this at all.
    final width = totalWidth.toInt();
    final height = canvasHeight.toInt();
    final rawBytes = pngBytes!.buffer.asUint8List();
    final rowBytes = width * 4; // RGBA, 4 bytes per pixel
    final flippedBytes = Uint8List(rawBytes.length);
    for (int y = 0; y < height; y++) {
      final srcStart = y * rowBytes;
      final dstStart = (height - 1 - y) * rowBytes;
      flippedBytes.setRange(dstStart, dstStart + rowBytes, rawBytes, srcStart);
    }

    THREE.Uint8Array data = THREE.Uint8Array.fromList(flippedBytes);
    THREE.ImageElement imageelement = THREE.ImageElement(
      data: data,
      width: totalWidth.toInt(),
      height: canvasHeight.toInt(),
    );
    var texturei = THREE.DataTexture(
      imageelement.data,
      totalWidth.toInt(),
      canvasHeight.toInt(),
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
    );
    texturei.needsUpdate = true;
    texturei.wrapT = THREE.ClampToEdgeWrapping;

    return {"texture": texturei, "width": totalWidth, "height": canvasHeight};
  }

  /// This allows creates painters for  multi text of different fonts, boldness, text
  /// [texts] is an array of Maps that include the text to be drawn, font, size, padding etc
  /// [tails] draws the little speech bubble tail on the text so looks like its being spoken and include 'bottomleft', 'bottomcenter', 'bottomright'
  /// [tailSize] how far the pointer extends below the bubble.
  static makeMultiText(
    List<Map> texts, {
    Set<String>? tails,
    double tailSize = 15,
  }) async {
    List<Map> textPainters = [];
    for (var text in texts) {
      var textPainter = makeTextPainter(
        text['message'],
        textcolor: text['textcolor'],
        fontSize: text['fontSize'] ?? 20,
        backgroundcolor: text['backgroundcolor'] ?? Colors.black,
        backgroundopacity: text['backgroundopacity'] ?? 0.5,
        width: text['width'] ?? 200,
        fontfamily: text['fontfamily'],
        bold: text['bold'],
        paddingLeft: text['paddingLeft'] ?? 0.0,
        paddingRight: text['paddingRight'] ?? 0.0,
        paddingTop: text['paddingTop'] ?? 0.0,
        paddingBottom: text['paddingBottom'] ?? 0.0,
      );
      textPainters.add(textPainter);
    }
    return await makeTextPainters(
      textPainters,
      tails: tails,
      tailSize: tailSize,
    );
  }

  /// Create a text sprite with text [message] with color [textcolor] and size [fontSize] and background of color [backgroundcolor] with opacity [backgroundopoacity]
  /// [z] is how high make the sprite
  /// [width] how wide to make the sprite
  /// [fontfamily] is the font family of text
  /// [bold] is whether the text is bold or not
  /// [tails] speech-bubble pointer(s) to draw at the bottom: any of
  /// 'bottomleft', 'bottomcenter', 'bottomright'. Omit for a plain
  /// rectangle.
  /// [tailSize] how far the pointer extends below the bubble.
  static makeText(
    message,
    Color textcolor, {
    fontSize = 20,
    z = 0,
    backgroundcolor = Colors.black,
    backgroundopacity = 0.5,
    width = 200,
    fontfamily,
    bold,
    paddingLeft = 0.0,
    paddingRight = 0.0,
    paddingTop = 0.0,
    paddingBottom = 0.0,
    Set<String>? tails,
    double tailSize = 15,
  }) async {
    var textPainter = makeTextPainter(
      message,
      textcolor: textcolor,
      fontSize: fontSize,
      backgroundcolor: backgroundcolor,
      backgroundopacity: backgroundopacity,
      width: width,
      fontfamily: fontfamily,
      paddingLeft: paddingLeft,
      paddingRight: paddingRight,
      paddingTop: paddingTop,
      paddingBottom: paddingBottom,
    );
    // print("maketext"+message.toString()+" "+textPainter.toString());
    if (textPainter != null)
      return await makeTextPainters(
        [textPainter],
        tails: tails,
        tailSize: tailSize,
      );
    else
      return null;
  }

  /// Get the opacity of an [object] - just returns the opacity of the last material it finds while traversing
  static getOpacity(object) {
    var ret = 1.0;
    object.traverse((child) {
      if (child.material is THREE.Material) {
        if (child.material.opacity != null) {
          // print("found material"+child.material.opacity.toString());
          ret = child.material.opacity.toDouble();
        }
      }
      // Lights don't have a material/opacity, so treat "opacity" as a
      // fraction of the light's original design-time intensity instead.
      // This lets the existing hide/fade pipeline (worldToLocalSurfaceObjHide,
      // Space.update, Texture.opacityLerp) work on lights with no other changes.
      if (child is THREE.Light) {
        if (!child.extra.containsKey('lerporiginalintensity')) {
          // Capture the original intensity once, the first time this light
          // is touched by the fade system, so later fades always reference
          // the correct "full brightness" value regardless of where the
          // intensity currently sits mid-fade.
          child.extra['lerporiginalintensity'] = child.intensity;
        }
        var original = child.extra['lerporiginalintensity'];
        if (original > 0) {
          ret = (child.intensity / original).toDouble();
        }
      }
    });
    return ret; // 1.0;
  }

  /// Set the [opacity] of every material in an [object] with 0.0 being transparent and 1.0 being opaque
  /// Use [groupname] to set the opacity of a specific group
  static setOpacity(object, opacity, {groupname}) {
    object.traverse((child) {
      if (child.material is THREE.Material &&
          (groupname == null ||
              (groupname != null && child.name == groupname))) {
        // if (child.material is THREE.Material) {
        child.material.opacity = opacity.toDouble();
        child.material.transparent = true;
      }
      if (child is THREE.Light &&
          (groupname == null ||
              (groupname != null && child.name == groupname))) {
        if (!child.extra.containsKey('lerporiginalintensity')) {
          child.extra['lerporiginalintensity'] = child.intensity;
        }
        child.intensity =
            child.extra['lerporiginalintensity'] * opacity.toDouble();
      }
    });
  }

  /// set the [shininess] of every material in [object]
  static setShininess(object, shininess) {
    object.traverse((child) {
      if (child.material is THREE.Material) {
        (child.material as THREE.Material).shininess = shininess.toDouble();
      }
    });
  }

  /// set the [roughness] of every material in [object]
  static setRoughness(object, roughness) {
    object.traverse((child) {
      if (child.material is THREE.Material) {
        (child.material as THREE.Material).roughness = roughness.toDouble();
      }
    });
  }

  /// Set the [metalness] of every material in [object]
  static setMetalness(object, metalness) {
    object.traverse((child) {
      if (child.material is THREE.Material) {
        (child.material as THREE.Material).metalness = metalness.toDouble();
      }
    });
  }

  /// Set the [emissive] color of every material in an [object]
  /// Use [groupname] to set it for a specific group
  static setEmissive(object, THREE.Color emissive, {groupname}) {
    object.traverse((child) {
      if (child.material is THREE.Material &&
          (groupname == null ||
              (groupname != null && child.name == groupname))) {
        child.material.emissive = emissive;
      }
    });
  }

  /// Set the [specular] value of every material in [object]
  static setSpecular(object, THREE.Color specular) {
    object.traverse((child) {
      if (child.material is THREE.Material) {
        child.material.specular = specular;
      }
    });
  }

  /// Set the [mat] material of every material in [object]
  /// Use [groupname] to set it for a specific group
  static setMaterial(object, THREE.Material mat, {groupname}) {
    object.traverse((child) {
      if (child.material is THREE.Material &&
          (groupname == null ||
              (groupname != null && child.name == groupname))) {
        child.material = mat;
      }
    });
  }

  /// Find a material of [object] with [groupname]
  static getMaterialByGroupname(object, groupname) {
    var ret = null;
    object.traverse((child) {
      // print("groupname"+child.name);
      if (child.material is THREE.Material && child.name == groupname) {
        // print("gfoundgroupn");
        ret = child.material;
      }
    });
    return ret;
  }

  /// Set the [color]  of every material in an [object]
  /// Use [groupname] to set it for a specific group
  static setColor(object, THREE.Color color, {groupname}) {
    object.traverse((child) {
      if (child.material is THREE.Material &&
          (groupname == null ||
              (groupname != null && child.name == groupname))) {
        child.material.color = color;
      }
    });
  }

  /// Set the [normalMap]  of every material in an [object]
  /// Use [groupname] to set it for a specific group and set its [normalScale] scale
  static setNormalMap(
    object,
    THREE.Texture? normalMap, {
    groupname,
    normalScale,
  }) {
    object.traverse((child) {
      if (child.material is THREE.Material &&
          (groupname == null ||
              (groupname != null && child.name == groupname))) {
        child.material.normalMap = normalMap;
        if (normalScale != null)
          child.material?.normalScale = THREE.Vector2(
            normalScale.toDouble(),
            normalScale.toDouble(),
          );
        child.material?.normalMap?.wrapS = THREE.RepeatWrapping;
        child.material?.normalMap?.wrapT = THREE.RepeatWrapping;
      }
    });
  }

  /// Set whether to use [mipmap] for every  material in an [object]
  static setMipMap(object, mipmap) {
    object.traverse((child) {
      if (child.material is THREE.Material) {
        child.material.map?.generateMipmaps = mipmap;
      }
    });
  }

  /// Set the [side] eg doublesided texture for every  material in an [object]
  /// Use [groupname] to set it for a specific group
  static setSide(object, side, {groupname}) {
    object.traverse((child) {
      if (child.material is THREE.Material &&
          (groupname == null ||
              (groupname != null && child.name == groupname))) {
        child.material.side = side;
        child.material.needsUpdate = true;
      }
    });
  }

  /// Set the [emissive] color of every material in an [object]
  /*static setAmbience(object, THREE.Color emissive) {
    object.traverse((child) {
      if (child.material is THREE.Material) {
        child.material.ambience = emissive;
      }
    });
  }*/

  /// Why is this returning 1?
  static getInitialOpacity(object) {
    if (!object.extra.containsKey('lerpinitialopacityfirst')) {
      if (object.extra.containsKey('configname') &&
          object.extra['configname'] == 'table')
        print("get init");
      object.extra['lerpinitialopacityfirst'] = getOpacity(object);
    }
    return 1; //object.extra['lerpinitialopacityfirst'];
  }

  /// [Flip] child material of [obj] in horizonal direction
  /// works for planes and sprites - should really  traverse
  static flipx(obj, flip) {
    if (flip) {
      (obj.children[0].material as THREE.Material).map?.wrapS =
          THREE.RepeatWrapping;
      (obj.children[0].material as THREE.Material).map?.repeat.x = -1.0;
    } else
      (obj.children[0].material as THREE.Material).map?.repeat.x = 1;
  }

  /// [flip] child material of [obj] in vertical direction
  /// works for planes and sprites - should really traverse
  static flipy(obj, flip) {
    if (flip) {
      // (obj.children[0].material as THREE.Material).map?.wrapS =
      //    THREE.RepeatWrapping;
      (obj.children[0].material as THREE.Material).map?.flipY = false;
    } else
      (obj.children[0].material as THREE.Material).map?.flipY = true;
  }

  /// Clone every material on [object] so that opacity changes during a fade
  /// do not affect other objects sharing the same material. The original
  /// shared materials are saved in [object.extra['_originalMaterials']] so
  /// they can be restored once the fade is complete.
  static cloneMaterialsForFade(THREE.Object3D object) {
    if (object.extra.containsKey('_originalMaterials'))
      return; // already cloned
    final originals = <THREE.Object3D, dynamic>{};
    object.traverse((child) {
      if (child is THREE.Mesh && child.material != null) {
        originals[child] = child.material;
        /* if (child.material is List) {
          child.material = (child.material as List)
              .map((m) => (m as THREE.Material).clone()..transparent = true)
              .toList();
        } else {*/
        final cloned = (child.material as THREE.Material).clone();
        cloned.transparent = true;
        child.material = cloned;
        //  }
      }
    });
    object.extra['_originalMaterials'] = originals;
  }

  /// Restore the original shared materials saved by [cloneMaterialsForFade].
  /// Call this after a fade completes so the object stops holding private
  /// material copies and goes back to sharing the common material.
  static restoreSharedMaterials(THREE.Object3D object) {
    if (!object.extra.containsKey('_originalMaterials')) return;
    final originals =
        object.extra['_originalMaterials'] as Map<THREE.Object3D, dynamic>;
    for (final entry in originals.entries) {
      entry.key.material = entry.value;
    }
    object.extra.remove('_originalMaterials');
  }

  /// Lerp the opacity of the material in [object] to [opacity] in [time] seconds
  /// [delay] seconds before start the lerp
  static opacityLerp(object, opacity, time, {delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        opacityLerp(object, opacity, time);
      });
      if (object != null) BaseObject.addTimer(object, t);
    } else {
      object.extra['lerpfromtimeopacity'] = System.currentMilliseconds();
      object.extra['lerptotimeopacity'] = time;

      var currentopacity = getOpacity(
        object,
      ); //getInitialOpacity(object);//getOpacity(object);;
      if (!object.visible)
        object.extra['lerpinitialopacity'] = 0;
      else
        object.extra['lerpinitialopacity'] = currentopacity;

      object.extra['lerpfinalopacity'] = opacity;

      if (_lerpopacityobjects.indexOf(object) < 0)
        _lerpopacityobjects.add(object);
    }
  }

  /// Sets a [secondarymaterial] to an [object]
  /// This fixes the threejs bug where cannot set secondary materials
  static setGroupMaterial(object, secondarymaterial) {
    object.geometry?.addGroup(0, object.geometry!.attributes['position'].length, 0);
    object.geometry?.addGroup(0, object.geometry!.attributes['position'].length, 1);
    //  object.geometry=geom;
    //   object.geometry?.groupsNeedUpdate=true;
    //    object.geometry?.elementsNeedUpdate=true;
    object.material = THREE.GroupMaterial([object.material, secondarymaterial]);
  }

  /// Change an [object] so its materials are changed to a MeshBasicMaterial
  /// Use [groupname] to set it for a specific group
  /// Useful for example if want burning embers not effected by shadow or light
  static setBasicMaterial(obj, {groupname}) {
    //print("in basic");
    obj.traverse((child) {
      //  print("basic "+child.name);
      if (child.material is THREE.Material &&
          (groupname == null ||
              (groupname != null && child.name == groupname))) {
        child.material = THREE.MeshBasicMaterial.fromMap({
          'map': child.material?.map,
        //  'transparent':true,//child.material?.transparent
        });
        //child.material.emissive=THREE.Color.fromHex32(0x000000);

        //   print("found basicmat");
      }
    });
  }

  /// Update opacity lerps
  static update(frameTime) {
    for (var i = _lerpopacityobjects.length - 1; i >= 0; i--) {
      var obj = _lerpopacityobjects[i];
      if (obj == null) {
        _lerpopacityobjects.remove(obj);
      } else {
        var lerp =
            (System.currentMilliseconds() - obj.extra['lerpfromtimeopacity']) /
            (obj.extra['lerptotimeopacity'] * 1000);
        if (lerp >= 1) {
          _lerpopacityobjects.remove(obj);
          setOpacity(obj, obj.extra['lerpfinalopacity']);
          obj.visible = obj.extra['lerpfinalopacity'] > 0;
          // Restore the original shared material now the fade is done.
          // The cloned material is discarded; no permanent copies remain.
          restoreSharedMaterials(obj);
        } else {
          var newopacity =
              obj.extra['lerpinitialopacity'] +
              lerp *
                  (obj.extra['lerpfinalopacity'] -
                      obj.extra['lerpinitialopacity']);
          obj.visible = newopacity > 0;
          setOpacity(obj, newopacity);
        }
      }
    }
  }
}

/// Class for a trigger when an object such as a model, plane, sprite or actor is touched
class TouchTrigger {//} with THREE.EventDispatcher {
  late var event;

  /// Set the callback for a touch trigger when an object is touched
  TouchTrigger(event)
  {
    this.event=event;
  }

  trigger(val) {
    print('trigger touch');
    event(val);
   // this.dispatchEvent(THREE.Event(type: 'trigger', action: val));
  }

 // triggermenu(val) {
 //   print('triggermenu openworld');
//    this.dispatchEvent(THREE.Event(type: 'triggermenu', action: val));
 // }
}

/// Class to allow creation of distance trigger for rooms, npcs, plants etc
class DistanceTrigger {
  //}with THREE.EventDispatcher {
  late double ndist, edist, sdist, wdist; //dist;
  bool inside = false;
  late bool ignoreifhidden;
  late var level;
  late var event;
  late String? name;

  /// Initialize distance trigger that is attached ot an object that has a rectangle around it [ndist] north, [sdist] south, [edist] east and [wdist] west of
  /// the objects position and will be triggered if the camera goes within this rectangle
  /// If [ignoreifhidden] is true then the trigger occurs even if the object the trigger is attached is hidden
  DistanceTrigger(
    ndist,
    edist,
    sdist,
    wdist,
    event, {
    ignoreifhidden = true,
    level,
        name
  }) {
    this.ndist = ndist.toDouble();
    this.edist = edist.toDouble();
    this.sdist = sdist.toDouble();
    this.wdist = wdist.toDouble(); //dist=dist;
    this.ignoreifhidden = ignoreifhidden;
    this.event = event;
    this.level = level;
    this.name = name;
  }

  trigger(val) {
    print('trigger'+name.toString());
    event(val);
    //this.dispatchEvent(THREE.Event(  type: 'trigger',action:val ) );
  }
}

/// Class to allow creation of customer trigger for any object eg models, sprites, actors - eg a trigger when actor is attacked
class CustomTrigger with THREE.EventDispatcher {
  CustomTrigger() {}

  trigger(name, val) {
    print('custom trigger' + name);
    this.dispatchEvent(THREE.Event(type: name, action: val));
  }
}

/// This is the base class for all objects and includes sprites, models, actors, planes
class BaseObject {
  static List _triggers = [];
  static List _touchtriggers = [];
  static double touchtriggerwait = 0.3;
  static List _highlightobjects = []; // so can hide them all

  static THREE.Raycaster ray = THREE.Raycaster();

  static init() {
    _triggers = [];
    _touchtriggers = [];
    _highlightobjects = [];
  }

  /// Return the name of the [obj] - if the name hasn't been set then return path from where object was loaded from if exists or the  texturepath if it exists
  static getName(obj) {
    var name = '';
    if (obj.extra.containsKey('mobname'))
      name = obj.extra['mobname'];
    else if (obj.extra.containsKey('path'))
      name = obj.extra['path'];
    else if (obj.extra.containsKey('texturepath'))
      name = obj.extra['texturepath'];
    return name;
  }

  /// Add a [timer] to [object] - record so can remove all timers if necessary
  static addTimer(object, timer) {
    if (!object.extra.containsKey('timers'))
      object.extra['timers'] = [];
    if (!object.extra['timers'].contains(timer))
      object.extra['timers'].add(timer);
  }

  /*  this causes an issue when mark static in some cases
  static markStatic(THREE.Object3D obj) {
    if (obj.extra.containsKey('mixer')) return; // is THREE.SkinnedMesh) return;
    obj.matrixAutoUpdate = false;
    obj.updateMatrix(); // compute it correctly once
    obj.matrixWorldNeedsUpdate = false; // and don't let it re-dirty itself
    for (var child in obj.children) markStatic(child);
  }*/

  /// Get all of [obj] timers
  static getTimers(obj) {
    if (obj.extra.containsKey('timers'))
      return obj.extra['timers'];
    else
      return [];
  }

  /// Stop all of [obj] timers and clear them all
  static clearTimers(obj) {
    if (obj.extra.containsKey('timers')) {
      for (var i = obj.extra['timers'].length - 1; i >= 0; i--) {
        obj.extra['timers'][i].cancel();
        obj.extra['timers'].remove(obj.extra['timers'][i]);
      }
    }
  }

  /// Go through entire scene and cancel any timers
  static clearAllTimers() {
    Space._scene.traverse((child) {
      clearTimers(child);
    });
  }

  /// Clear everything for [obj] including timers, randomwalk, moving, text, chatter, speech, lerping
  static clearAll(obj, {delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        clearAll(obj);
      });
      if (obj != null) BaseObject.addTimer(obj, t);
    } else {
      Space.removeFaceObjectAlways(obj);
      // Kill any random walk
      if (obj.extra.containsKey('movetoidrand'))
        obj.extra.remove('movetoidrand');
      // Kill any moveto walk
      if (obj.extra.containsKey('movetoid')) obj.extra.remove('movetoid');
      clearTimers(obj);
      Mob.clearText(obj);
      Mob.pauseChatter(obj);
      Mob.pauseSpeech(obj);
      Space.removeObjectFromLerp(obj);
      Space.removeObjectFromSurfaceLerp(obj);
      Mob.removeObjectFromMoveTo(
        obj,
      ); // this is removing from the movetoloopbnextlist list (not the timer)
    }
  }

  /// Set the [scale] of an [obj] highlight
  /// Override [scale] with [scalex] , [scaley] and [scalez] if want to scale highlight in different axis
  static setHighLightScale(
    THREE.Object3D obj, {
    scale = 1.05,
    scalex,
    scaley,
    scalez,
  }) {
    if (!obj.extra.containsKey('selectx')) {
      obj.extra['selectx'] = obj.scale.x;
      obj.extra['selecty'] = obj.scale.y;
      obj.extra['selectz'] = obj.scale.z;
    }
    var sx = scale;
    var sy = scale;
    var sz = scale;
    if (scalex != null) sx = scalex;
    if (scaley != null) sy = scaley;
    if (scalez != null) sz = scalez;

    obj.extra['select'].scale.z =
        obj.extra['selectz'] * sz; //1.4;//multiplyScalar(scale);
    obj.extra['select'].scale.x =
        obj.extra['selectx'] * sx; //1.4;//multiplyScalar(scale);
    obj.extra['select'].scale.y =
        obj.extra['selecty'] * sy; //1.4;//multiplyScalar(scale);
  }

  /// Set the [opacity] of [obj] highlight
  static setHighLightOpacity(obj, opacity) {
    obj.extra['select'].traverse((object) {
      if (object is THREE.Mesh) {
        object.material?.opacity = opacity; //.blending= THREE.AdditiveBlending;
      }
    });
  }

  /// Given an [obj] a select highlight and add to the scene [parent] with [color], [opacity]
  /// Can set the [scale] of hightlight and override in different axis with [scalex], [scaley] and [scalez]
  /// Can change the opacity when deselected with [deselectopacity]
  /// Can change the scale when deselected with [deselectscale]
  static setHighlight(
    obj,
    parent,
    color,
    opacity, {
    scale = 1.05,
    scalex,
    scaley,
    scalez,
    deselectopacity,
    deselectscale,
  }) {
    var outlineMaterial2 = new THREE.MeshBasicMaterial.fromMap({
      "color": color,
      "side": THREE.BackSide,
    });
    outlineMaterial2.opacity = opacity;
    outlineMaterial2.transparent = true;
    obj.extra['deselectopacity'] = deselectopacity;
    obj.extra['deselectscale'] = deselectscale;
    var clone;
    if (obj.extra.containsKey('animations'))
      clone = SkeletonUtils.clone(obj);
    else
      clone = obj.clone();
    obj.extra['select'] = clone;
    // If hiding then obj then do the same for the selection
    if (Space._hideobjects.contains(obj) && obj.parent == parent) {
      //parent.contains(obj)) {
      clone.extra['cameradist'] = obj.extra['cameradist'];
      Space._hideobjects.add(clone);
    }

    if (obj.extra.containsKey('isplane') && obj.extra['isplane']) {
      // This is to give a blue border
      outlineMaterial2.side = THREE.FrontSide;
      var width = obj.extra['select'].children[0].scale.x;
      var height = obj.extra['select'].children[0].scale.y;
      // Space.objForward(obj.extra['select'].children[0], -0.05);
      var linescale = scale - 1;
      var clone = obj.extra['select'].children[0].clone();
      var clone2 = obj.extra['select'].children[0].clone();
      var clone3 = obj.extra['select'].children[0].clone();
      obj.extra['select'].add(clone);
      obj.extra['select'].add(clone2);
      obj.extra['select'].add(clone3);
      obj.extra['select'].children[1].scale.y = height * linescale / 2;
      obj.extra['select'].children[1].position.y =
          -(height / 2) +
          obj.extra['select'].children[1].scale.y / 2; //linescale/2;
      obj.extra['select'].children[2].scale.x = width * linescale / 2;
      obj.extra['select'].children[2].position.z =
          -(width / 2) +
          obj.extra['select'].children[2].scale.x / 2; //linescale/2;
      obj.extra['select'].children[3].scale.x = width * linescale / 2;
      obj.extra['select'].children[3].position.z =
          (width / 2) -
          obj.extra['select'].children[3].scale.x / 2; //linescale/2;
      obj.extra['select'].children[0].scale.y = height * linescale / 2;
      obj.extra['select'].children[0].position.y =
          (height / 2) -
          obj.extra['select'].children[0].scale.y / 2; //linescale/2 ;
    }
    setHighLightScale(
      obj,
      scale: scale,
      scalex: scalex,
      scaley: scaley,
      scalez: scalez,
    );
    obj.extra['select'].visible = false;
    obj.extra['select'].traverse((object) {
      if (object is THREE.Mesh) {
        object.material = outlineMaterial2; //.blending= THREE.AdditiveBlending;
      }
    });
    parent.add(obj.extra['select']);

    if (!_highlightobjects.contains(obj)) _highlightobjects.add(obj);
  }

  /// Turn the highlight of [obj] on or off.
  /// Can increase the size of the highlight with [scale]
  /// Can change the [opacity] of the highlight
  static highlight(obj, on, {scale, opacity}) {
    if (obj.extra.containsKey('select')) {
      obj.extra['select'].position =
          obj.position; // so always have same position even if moved
      obj.extra['select'].visible = on;
      if (on) {
        if (scale != null) setHighLightScale(obj, scale: scale);
        if (opacity != null) setHighLightOpacity(obj, opacity.toDouble());
      }
    }
  }

  /// set [obj] to be unselected and has smaller select outline
  static deselectHighLight(obj) {
    if (obj.extra['deselectscale'] != null)
      setHighLightScale(obj, scale: obj.extra['deselectscale']);
    if (obj.extra['deselectopacity'] != null) //opacity!=null)
      setHighLightOpacity(obj, obj.extra['deselectopacity']);
  }

  /// deselect all high lighted objects
  static deselectHighLights() {
    for (var obj in _highlightobjects) {
      deselectHighLight(obj);
      /*if (obj.extra['deselectscale']!=null)
        setHighLightScale(obj, scale:obj.extra['deselectscale']);
      if (obj.extra['deselectopacity']!=null)//opacity!=null)
        setHighLightOpacity(obj, obj.extra['deselectopacity']);*/
    }
  }

  /// Set a distance trigger of [object].
  /// If camera goes within the square specified by [dist] or the rectangle specified by [ndist], [sdist], [edist] and [wdist]
  /// then sets off trigger. If camera was also in the trigger distance and moves out also triggers
  /// [ignoreifhidden] means even if the [object] is invisible the trigger still operates
  static setDistanceTrigger(
    object, {
    required event,
        dist, ndist, edist, wdist, sdist,
        name,
    ignoreifhidden = true,
    level,
  }) {
    if (_triggers.contains(object)) {
      // If already have distance trigger than just change it
      if (dist != null) {
        object.extra['trigger'].ndist = dist.toDouble();
        object.extra['trigger'].sdist = dist.toDouble();
        object.extra['trigger'].edist = dist.toDouble();
        object.extra['trigger'].wdist = dist.toDouble();
      } else {
        object.extra['trigger'].ndist = ndist.toDouble();
        object.extra['trigger'].sdist = sdist.toDouble();
        object.extra['trigger'].edist = edist.toDouble();
        object.extra['trigger'].wdist = wdist.toDouble();
      }
      object.extra['trigger'].ignoreifhidden = ignoreifhidden;
      object.extra['trigger'].level = level;
      object.extra['trigger'].name=name;
    } else {
      // disableDistanceTrigger(object);
      if (dist != null)
        object.extra['trigger'] = DistanceTrigger(
          dist.toDouble(),
          dist.toDouble(),
          dist.toDouble(),
          dist.toDouble(),
          event,
          name:name,
          ignoreifhidden: ignoreifhidden,
          level: level,
        );
      else {
        /* print(
            "ndist" + ndist.toString() + " edist" + edist.toString() +
                " sdist" +
                sdist.toString() + " wdist" + wdist.toString());*/
        object.extra['trigger'] = DistanceTrigger(
          ndist,
          edist,
          sdist,
          wdist,
          event,
          name:name,
          ignoreifhidden: ignoreifhidden,
          level: level,
        );
      }
      _triggers.add(object);
    }
  }

  /// Delete the distance trigger for the [object]
  static removeDistanceTrigger(object) {
    if (_triggers.contains(object)) _triggers.remove(object);
  }

  // reenable the distance trigger for [object]
  static reenableDistanceTrigger(object) {
    if (!_triggers.contains(object) && object.extra.containsKey('trigger'))
      _triggers.add(object);
  }

  /// Set an [object] to have a trigger when the object is touched
  static setTouchTrigger(object, {required event}) //,{time:0.5})
  {
    disableTouchTrigger(object);
    var trigger = TouchTrigger(event); //time:time);
    object.traverse((child) {
      child.extra['touchtrigger'] = trigger;
    });
    object.extra['touchtrigger'] = trigger;
    _touchtriggers.add(object);
  }

  /// Delete the touch trigger for the [object]
  static disableTouchTrigger(object) {
    if (_touchtriggers.contains(object)) _touchtriggers.remove(object);
  }

  /// For the objects touched any then trigger the touchtrigger if they have one
  /// [pointerdowntick] is when the mouse was clicked so that dont trigger  all the time
  /// [event] is the mouse position
  /// [parent] is the scene that check for intersections of
  /// [width] and [height] is the width and height of screen
  /// [numpoints] is how many spots will check for interections - this is useful if low frame rate and isn't finding touched objects - try more often if low framerate
  /// How close (in screen pixels) a tap must be to a touch trigger's centre
  /// to count when the tap doesn't hit it exactly. Fingers are much less
  /// precise than a mouse, so this makes small icons easy to tap on phones.
  /// Negative = automatic: 30 on smartphones, 0 (exact hits only) elsewhere.
  static double touchSlopPixels = -1;
  static final THREE.Vector3 _touchTmp = THREE.Vector3();

  /// True if [o] and all its parents are visible
  static bool _isShown(THREE.Object3D? o) {
    while (o != null) {
      if (!o.visible) return false;
      o = o.parent;
    }
    return true;
  }

  /// Handles the screen being touched
  /// [pointerdowntick] is time in milliseconds the screen was touched so dont have to many clicks
  /// [event] is the mouseevent, touchevent of the screen being touched
  /// [width],[height] is the threejs width and height
  /// [numpoints] is how many points around the touch it'll test in case is a near miss
  static touchup(pointerdowntick, event, /*parent,*/ width, height, numpoints) {
    if (System.currentMilliseconds() - pointerdowntick <=
        touchtriggerwait * 1000) return false;

    // Only test objects that actually have a touch trigger - raycasting the
    // whole scene (terrain, buildings, crowds) was what made taps slow.
    final candidates = <THREE.Object3D>[];
    for (final o in _touchtriggers) {
      if (o is THREE.Object3D && o.parent != null && _isShown(o)) {
        candidates.add(o);
      }
    }
    if (candidates.isEmpty) return false;

    var found = false;
    final fired = <dynamic>{};
    void fire(THREE.Object3D o) {
      final trigger = o.extra['touchtrigger'];
      if (trigger != null && !fired.contains(trigger)) {
        fired.add(trigger);
        print("touched trigger in here");
        trigger.trigger(event);
        found = true;
      }
    }

    // 1. Exact hit: ray test against the trigger objects only
    for (var i = -numpoints / 2; i < numpoints / 2 && !found; i++) {
      final ndc = THREE.Vector2(
        ((event.clientX + i) / width) * 2 - 1,
        -((event.clientY + i) / height) * 2 + 1,
      );
      ray.setFromCamera(ndc, Camera._camera);
      final intersects = ray.intersectObjects(candidates, true);
      for (final intersect in intersects) {
        // The hit may be a child mesh; walk up to the object with the trigger
        THREE.Object3D? o = intersect.object;
        if (!_isShown(o)) continue;
        while (o != null && !o.extra.containsKey('touchtrigger')) {
          o = o.parent;
        }
        if (o != null) fire(o);
      }
    }
    if (found) return true;

    // 2. Near miss (finger-friendly): the trigger whose centre is closest to
    //    the tap on screen, if within touchSlopPixels
    final slop = touchSlopPixels >= 0
        ? touchSlopPixels
        : (System.isSmartphone() ? 30.0 : 0.0);
    if (slop <= 0) return false;

    final cam = Camera._camera;
    THREE.Object3D? nearest;
    double nearestDist = slop;
    for (final o in candidates) {
      o.getWorldPosition(_touchTmp);
      _touchTmp.applyMatrix4(cam.matrixWorldInverse);
      if (_touchTmp.z >= 0) continue; // behind the camera
      _touchTmp.applyMatrix4(cam.projectionMatrix); // to -1..1 screen coords
      final sx = (_touchTmp.x + 1) / 2 * width;
      final sy = (1 - _touchTmp.y) / 2 * height;
      final dx = sx - event.clientX;
      final dy = sy - event.clientY;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d <= nearestDist) {
        nearestDist = d;
        nearest = o;
      }
    }
    if (nearest != null) fire(nearest);
    return found;
  }

  /// Create your own trigger for [object] eg npc attacked
  static setCustomTrigger(object) //,{time:0.5})
  {
    object.extra['customtrigger'] = CustomTrigger(); //trigger;
  }

  /// Remove the [object] custom trigger of [name]
  static removeCustomTrigger(object, name) {
    if (object.extra.containsKey('customtrigger'))
      object.extra['customtrigger'].removeEventListener(name);
  }

  /// Does the [object] have a custom trigger of [name]
  static hasCustomTrigger(object, name) {
    if (object.extra.containsKey('customtrigger')) {
      // var dog=CustomTrigger();
      // dog.hasEventListener(type, listener)
      return object.extra['customtrigger'].hasEventListener(name, null);
    }
    return false;
  }

  /// Get an [object] group by [groupname]
  static getGroupByName(object, groupname) {
    var found=null;
    object.traverse((child) {
    //  print("vooot"+child.name.toString());
      if (child.name == groupname) {
       // print("matched groupname"+groupname);
        found= child;
      }
    });
    return found;
  }

  /// Check if should trigger distance triggers
  static update(frameTime) {
    for (var i = _triggers.length - 1; i >= 0; i--) {
      var obj = _triggers[i];
      DistanceTrigger trigger = obj.extra['trigger'];
      if (obj == null) {
        _triggers.removeAt(i);
        // _triggers.splice(i, 1);
      } else if (((obj.visible && trigger.ignoreifhidden) ||
              !trigger.ignoreifhidden) &&
          (trigger.level == null ||
              (trigger.level != null && You.level == trigger.level))) {
        var worldpos = Space.localToWorldObj(Camera._camera);
        var objectpos = Space.localToWorldObj(obj);

        var inside =
            worldpos.x >= objectpos.x - trigger.wdist &&
            worldpos.x < objectpos.x + trigger.edist &&
            worldpos.y >= objectpos.y - trigger.sdist &&
            worldpos.y <= objectpos.y + trigger.ndist;

        if (trigger.inside && !inside) {
          //dist > cameradist) {
          obj.extra['trigger'].inside = false;
          obj.extra['trigger'].trigger(false);
        } else if (!trigger.inside && inside) {
          //]dist <= cameradist) {
          obj.extra['trigger'].inside = true;
          obj.extra['trigger'].trigger(true);
        }
      }
    }
  }

  /// Make [object] [visible] in [delay] seconds
  /// Use [groupname] to set it for a specific group
  static setVisible(object, visible, {groupname, delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        setVisible(object, visible, groupname: groupname);
      });
      BaseObject.addTimer(object, t);
    } else {
      object.traverse((child) {
        // if (object.extra.containsKey('donkeyname'))
        //    print("groupname vis"+child.name.toString()+" "+groupname.toString());
        if ((groupname == null ||
            (groupname != null && child.name == groupname))) {
          // if (child.material is THREE.Material) {
          child.visible = visible;
        }
      });

      // object.visible=visible;
    }
  }

  /// Set whether an [object] can cast a shadow or not
  static setCastShadow(model, castshadow) {
    if (castshadow != null) {
      model?.traverse((child) {
        if (child is THREE.Mesh) {
          child.castShadow = castshadow;
        }
      });
      model?.castShadow = castshadow;
    }
  }
}

/// Procedures related to mesh models
class Model {
  /// Load a model of [path] and can replace its [texture]
  /// [castshadow] set with the object can cast a shadow
  /// [basic] set whether the object should use a basic material eg embers with no shadow or light effects
  /// Use [groupname] to set the [texture] for a specific group
  static createModel(
    path, {
    texture,
    castshadow,
    basic,
    //keeptexture,
    groupname,
    texturereplace,
    merge,
  }) async {
    // MilkShape / SMD models
    if (Ms3dLoader.isMs3dPath(path)) {
      var ms3dmodel = await Ms3dLoader.createModel(
        path,
        texturereplace: texturereplace == null ? null : Map<String, String>.from(texturereplace),
        basic: basic != null && basic,
        castshadow: castshadow != null && castshadow,
        merge: merge != null && merge,
      );
      if (texture != null) {
        await setTexture(ms3dmodel, texture, groupname: groupname);
      }
      return ms3dmodel;
    }
    //var loaderu = THREE.GLTFLoader(); //null);
    // print("model path"+path.toString());
    final stopwatch = Stopwatch()..start();
    var gltf = await AssetPack.loadGLTF(path);//await loaderu.fromAsset(path); //loadAsync(path); //ii.gltf');
    //print("ooo"+gltf.toString());
    var model = gltf?.scene;
    model?.extra['path'] = path;
    if (texture != null) {
      await setTexture(model, texture, groupname: groupname);
    }
    stopwatch.stop();
    Duration elapsedDuration = stopwatch.elapsed;
    print(
      "model path" +
          path.toString() +
          ' Time elapsed: ${elapsedDuration.inMilliseconds} milliseconds',
    );
    //    await fixTexture(model);
    // For some reason gltfloader doesn't turn on transparency when transparent material is used so set it here
   // if (keeptexture == null || !keeptexture)
    model?.traverse((child) {
        if (child is THREE.Mesh &&
            child.material is THREE.MeshStandardMaterial) {
          // print("oo"+(child.material as THREE.MeshStandardMaterial).name.toString());
          if (basic != null && basic)
            child.material = THREE.MeshBasicMaterial.fromMap({
              'map': child.material?.map,
            });
          else {
            // !!!why must this be done
            var transparent = ((child.material as THREE.MeshStandardMaterial)
                .name
                .contains(".png"));
            child.material = THREE.MeshStandardMaterial.fromMap({
              'map': child.material?.map,
            });
            // if ((child.material as THREE.MeshStandardMaterial).name.contains(".png"))
            child.material?.transparent = transparent; //true;
          }
          child.castShadow = (castshadow != null && castshadow);
        }
      });
    model?.castShadow = (castshadow != null && castshadow);
//    BaseObject.markStatic(model!);
    return model;
  }

  /// Copy a [model] setting a new [texture] Useful only if want to set the texture of the model with a new texture
  /// Use [groupname] to set the [texture] for a specific group
  /// [castshadow] set with the object can cast a shadow
  static copyModel(model, {texture, groupname, castshadow}) async {
    THREE.Object3D model2 = model.clone();
    if (texture != null) {
      model.extra['texturepath'] = texture;
      await Model.setTexture(model2, texture, groupname: groupname);
      // model2.traverse((object) {
      //   print("mesh name"+object.name);
      //});
    }
    if (castshadow != null) {
      model2?.traverse((child) {
        if (child is THREE.Mesh) {
          // print("oo"+(child.material as THREE.MeshStandardMaterial).name.toString());
          //child.material =
          //    THREE.MeshLambertMaterial.fromMap({'map': child.material?.map});
          child.castShadow = castshadow;
        }
      });
      model2?.castShadow = castshadow;
    }
    return model2;
  }

  /// Apply texture of path [texturepath] to [model] to all meshes or to the mesh specified by [groupname]
  static setTexture(model, texturepath, {groupname}) async {
    var texture = await AssetPack.loadTexture(texturepath);//await THREE.TextureLoader().fromAsset(texturepath);

    var material = THREE.MeshStandardMaterial.fromMap({'map': texture});
    texture?.colorSpace = "srgb";
    material.needsUpdate = true;

    material.map?.wrapS = THREE.RepeatWrapping;
    material.map?.wrapT = THREE.RepeatWrapping;

    if (kIsWeb) {
      // must flip for web for some reason
      material.map?.wrapT = THREE.RepeatWrapping;
      material.map?.repeat.y = -1.0;
    }
    material.transparent = texturepath.contains(".png");
    model.traverse((object) {
      if (object is THREE.Mesh &&
          (groupname == null || object.name == groupname)) {
        (object as THREE.Mesh).material = material;
        //   (object as THREE.Mesh).material?.needsUpdate = true;
      }
    });
  }

  /* static fixTexture(model)
  {
    model.traverse((object) {
      if (object is THREE.Mesh) {
        (object as THREE.Mesh).material?.map?.colorSpace="srgb";
        (object as THREE.Mesh).material?.map?.wrapT=1000;
        (object as THREE.Mesh).material?.map?.flipY=false;
        (object as THREE.Mesh).material?.opacity=1.0;
        (object as THREE.Mesh).material?.transparent=false;
        (object as THREE.Mesh).material?.needsUpdate = true;
      }
    });
  }*/

  /// Clone not only the [obj] meshes but also the material
  /// Useful for opacitylerp
  static copyModelAndMat(obj) {
    var clone = obj.clone();
    clone.traverse((object) {
      if (object.material != null) {
        object.material = object.material.clone();
        object.material.needsUpdate = true;
      }
    });
    return clone;
  }
}

/// Per-actor distance-throttle state. Kept as one typed object per actor
/// (rather than several dynamic entries in actor.extra) so the per-frame
/// lookup in Actor.update is a single Map hit on an Object3D key (cheap
/// identity hash) instead of up to four String-keyed hits into a
/// Map<String, dynamic>, and so the fields come back already typed with
/// no `as double`/`as int` casts needed.
class _ThrottleState {
  double distance;
  int skipFrames;
  int phase;
  double accum = 0.0;

  _ThrottleState(this.distance, this.skipFrames, this.phase);
}

/// Procedures related to animated actors
class Actor {
  static List<THREE.Object3D> actorlist = [];
  static int _updateFrameCounter = 0;
  static final Map<THREE.Object3D, _ThrottleState> _throttled = {};

  static init() {
    actorlist = [];
    _updateFrameCounter = 0;
    _throttled.clear();
  }

  /// Opt an actor into distance-based animation throttling. OFF by default -
  /// call this explicitly per actor, since it's only safe for actors doing
  /// something like idle standing/sitting far from any path the player
  /// walks near. A WALKING actor would visibly "glide" (body position
  /// keeps moving via its own update, legs only refresh every few frames)
  /// if throttled, however far away it is, so don't enable this for those.
  ///
  /// Once enabled, whenever the actor is further than [minDistance] from
  /// the camera its AnimationMixer only advances every [skipFrames]
  /// frames instead of every frame. The elapsed time between updates is
  /// still accumulated and passed in full, so playback speed stays
  /// correct - it just becomes chunkier rather than smooth, which is the
  /// trade you're opting into. Inside [minDistance] it always updates
  /// every frame, same as an actor that was never throttled.
  static void enableDistanceThrottle(
    THREE.Object3D actor, {
    double minDistance = 8.0,
    int skipFrames = 3,
  }) {
    // Stagger actors so they don't all skip/update on the same frame -
    // that would just turn a smooth cost into a periodic spike instead.
    _throttled[actor] = _ThrottleState(
      minDistance,
      skipFrames,
      actorlist.length % skipFrames,
    );
  }

  /// Undo enableDistanceThrottle - the actor goes back to updating at full
  /// rate every frame regardless of distance.
  static void disableDistanceThrottle(THREE.Object3D actor) {
    _throttled.remove(actor);
  }

  /// Create an actor from asset [path]
  ///  If [texture] specified use that texture instead of its own - can specify which [groupname] the texture applies to
  /// [action] specifies default animation once created with [duration]
  /// So that animations aren't always the same making actors move in unison use [randomduration] to add small variations. 0.1 will change the duration by a random value within 10%
  /// [z] offset so if center of actor is z=0, can specify [z] so that makes the feet the origin to make it easier to put on surface
  /// Specify the actor [shareanimations] that you want this actor alway have
  /// [castshadow] set with the object can cast a shadow
  /// [basic] set whether the object should use a basic material eg embers with no shadow or light effects
  /// [startat] Start the actors animation within a fraction of the animations total length (between 0-1) - eg if 0.5 and animation is 3 seconds link then will start at 1.5 seconds
  static createActor(
    path, {
    texture,
    groupname,
    action = "idle",
    randomduration,
    z,
    shareanimations,
    castshadow,
    basic,
    startat,
    duration,
    animations,
    texturereplace,
  }) async {
    final stopwatch = Stopwatch()..start();

    final isms3d = Ms3dLoader.isMs3dPath(path);
    THREE.Object3D? actor;
    if (isms3d) {
      // MilkShape / SMD actor: [animations] names an animation set from
      // config.json "actoranimations" (or Ms3dLoader.animationSets)
      actor = await Ms3dLoader.createActor(
        path,
        animations: animations,
        texturereplace: texturereplace == null ? null : Map<String, String>.from(texturereplace),
        basic: basic != null && basic,
        castshadow: castshadow != null && castshadow,
      );
    } else {
      // var loaderu = THREE.GLTFLoader(); //null);
      // var gltf = await loaderu.fromAsset(path);//await loaderu.fromAsset(path); //ii.gltf');
      var gltf = await AssetPack.loadGLTF(path);//await loaderu.fromAsset(path); //loadAsync(path); //ii.gltf');
      actor = gltf?.scene; //["scene"];
      List<dynamic>? gltfanimations = gltf?.animations; //["animations"];
      actor?.extra['animations'] = gltfanimations;
    }
    if (texture != null) {
      await Model.setTexture(actor, texture, groupname: groupname);
    }
    stopwatch.stop();
    Duration elapsedDuration = stopwatch.elapsed;
    print(
      "actor path" +
          path.toString() +
          ' Time elapsed: ${elapsedDuration.inMilliseconds} milliseconds',
    );

    actor?.extra['path'] = path;
    //  await Model.fixTexture(actor);
    // !!! why must this be done?????
    if (!isms3d) actor?.traverse((child) {
      if (child is THREE.Mesh && child.material is THREE.MeshStandardMaterial) {
        // print("oo"+(child.material as THREE.MeshStandardMaterial).name.toString());
        if (basic != null && basic)
          child.material = THREE.MeshBasicMaterial.fromMap({
            'map': child.material?.map,
          });
        else {
          child.material = THREE.MeshStandardMaterial.fromMap({
            'map': child.material?.map,
          });
          //              THREE.MeshLambertMaterial.fromMap({'map': child.material?.map});
          child.castShadow = (castshadow != null && castshadow);
        }
      }
    });
    actor?.castShadow = (castshadow != null && castshadow);

    if (shareanimations != null) {
      Actor.shareAnimations(actor, shareanimations);
    }
    //actor?.extra['origquaternion']=actor.quaternion;
    actor?.extra['origrotation'] = actor.rotation;
    actorlist.add(actor!);
    var mixer = new THREE.AnimationMixer(actor!);
    actor.extra['mixer'] = mixer;
    var anim = getAnimationByName(actor, action);
    // so dont need 0.14 everywhere for actors
    if (z != null) actor.children[0].position.y += z;
    if (anim != null) {
      var idle = await mixer.clipAction(
        anim,
      ); //, null,THREE.AdditiveAnimationBlendMode);
      if (randomduration != null) {
        var durationi;
        if (duration == null)
          durationi = anim.duration;
        else
          durationi = duration;
        durationi *=
            (1 + (Math.random() * randomduration - randomduration / 2));
        idle?.setDuration(durationi);
      } else if (duration != null) {
        idle?.setDuration(duration);
        //  print("anim duration"+path+" "+duration.toString());
      }
      if (startat != null) {
        if (duration == null)
          idle?.startAt(startat.toDouble() * idle?.getClip().duration);
        else
          idle?.startAt(startat.toDouble() * duration.toDouble());
      }

      idle?.play();
    }
    return actor;
  }

  /// Share [actor2] animations with [actor1] - must have same skeleton
  /// Does not overwrite if animation already exists
  static shareAnimations(actor1, actor2) {
    List animations = actor2.extra['animations']; // AnimationClip
    for (var animation in animations) {
      var found = false;
      for (var animationa in actor1.extra['animations']) {
        if (animation.name == animationa.name) found = true;
      }
      if (!found) actor1.extra['animations'].add(animation);
    }
  }

  /// Get the animation clip from [actor] specified by [name]
  static getAnimationByName(actor, name) {
    for (THREE.AnimationClip animation in actor.extra['animations'])
      if (animation.name == name) return animation;
    return null;
  }

  /// Get the first animation currently played by the [actor] - just returnss the first one
  static getActiveAction(actor) {
    var animations = actor.extra['animations']; // AnimationClip
    THREE.AnimationMixer mixer = getActorMixer(actor);
    for (THREE.AnimationClip animation in animations) {
      THREE.AnimationAction? action = mixer.clipAction(animation);
      if (mixer.isActiveAction(action!)) return action;
    }
  }

  /// Get every active action for the [actor]
  static List<THREE.AnimationAction> getActiveActions(actor) {
    List<THREE.AnimationAction> ret = [];
    var animations = actor.extra['animations']; // AnimationClip
    THREE.AnimationMixer mixer = getActorMixer(actor);
    for (THREE.AnimationClip animation in animations) {
      THREE.AnimationAction? action = mixer.clipAction(animation);
      if (mixer.isActiveAction(action!)) ret.add(action);
    }
    return ret;
  }

  /// Have every active action of the [actor] in fade in [fadein] seconds
  static fadeInAll(actor, fadein) {
    var actions = Actor.getActiveActions(actor);
    for (var actioni in actions)
      actioni.fadeIn(fadein);
    return actions;
  }

  /// Have every active action of the [actor] in fade out [fadeout] seconds
  /// Can exclude an action [excludeaction] - useful if want to fadein a new action and fadeout the rest
  static List<THREE.AnimationAction> fadeOutAll(
    actor,
    fadeout, {
    excludeaction,
  }) {
    List<THREE.AnimationAction> actions = Actor.getActiveActions(actor);
    for (var actioni in actions) {
      if (excludeaction == null || actioni != excludeaction)
        actioni.fadeOut(fadeout);
    }
    return actions;
  }

  /// Get the [actor] animationmixer
  static THREE.AnimationMixer getActorMixer(actor) {
    return actor.extra['mixer'];
  }

  /// Update all the actors animation
  static update(frameTime) {
    _updateFrameCounter++;
    THREE.Vector3?
    cameraPos; // only computed the first time it's actually needed this frame
    //var throttledupdate=0;
    // var throttled=0;
    // var notthrottled=0;
    //var hasdonetest=false;
    for (var actor in actorlist) {
      //
      if (!actor.visible || actor.parent == null || !actor.parent!.visible)
        continue;
      if (actor.parent!.parent != null && !actor.parent!.parent!.visible)
        continue;
      var mixer = actor.extra['mixer'];

      var t = _throttled[actor];
      if (t == null) {
        // var pos=Space.localToWorldObj(actor);
        //+actor.parent!.parent!.visible.toString()+" "
        //    print("not throttled"+actor.extra['path'].toString()+" "+Space.localToWorldObj(actor).toString()+" "+Mob.getName(actor)+" "+actor.parent!.visible.toString()+" "+Space.objIsHide(actor).toString());
        // Default, unchanged behaviour: every actor updates every frame
        // unless it has explicitly opted into throttling below.
        mixer.update(frameTime);
        /*if ( _updateFrameCounter % 30 == 0) {
          print("new frame");
          actor.traverse((c) {
            if (c is THREE.SkinnedMesh && c.skeleton != null) {
              print("uunew frame");
              c.skeleton!.computeBoneTexture();   // new texture, same bone data
            }
          });
        }*/
        /*actor.traverse((c) {
          if (c is THREE.SkinnedMesh && c.skeleton != null) {
            c.skeleton!.boneTexture?.dispose();
            c.skeleton!.computeBoneTexture();
          }
        });*/
        /*if (!hasdonetest) {
          hasdonetest=true;
          actor.traverse((c) {
            if (c is THREE.SkinnedMesh && c.skeleton != null) {
              final b = c.skeleton!.bones[1].quaternion;
              print('bone ${b.x.toStringAsFixed(3)} ${b.y.toStringAsFixed(3)} '
                  'mixer t=${(mixer.time as num).toStringAsFixed(2)}');
            }
          });
        }*/
        //  notthrottled++;
        continue;
      }

      cameraPos ??= Space.localToWorldObj(Camera._camera);
      var actorPos = Space.localToWorldObj(actor);
      var dx = actorPos.x - cameraPos.x;
      var dy = actorPos.y - cameraPos.y;
      var farAway = (dx * dx + dy * dy) > (t.distance * t.distance);

      if (!farAway) {
        // Close enough that it needs full quality - update every frame,
        // same as if it had never been throttled, including any time
        // banked from a moment ago when it was still far away.
        mixer.update(frameTime + t.accum);
        // throttledupdate++;
        t.accum = 0.0;
        continue;
      } // else
      //  throttled++;

      t.accum += frameTime;
      if ((_updateFrameCounter + t.phase) % t.skipFrames == 0) {
        // Pass the full accumulated time so the animation still plays at
        // the correct speed overall - it just advances in bigger, less
        // frequent steps instead of a smooth one every frame.
        mixer.update(t.accum);
        // throttledupdate++;
        t.accum = 0.0;
      } // else
      //  throttled++;
    }
    //72 72 81 295
    //136 0 133 290
    // print("animation throttle"+throttled.toString()+" "+throttledupdate.toString()+" "+notthrottled.toString()+" "+actorlist.length.toString());
  }

  /// Copy an existing [actor] rather than load it again
  /// Set the [actor] to a different [texture] from assets and either apply it to the entire actor or just the group [groupname]
  /// Once copied set its initial animation [action] with [duration]. Start the actors animation within a fraction of the animations total length (between 0-1) with [startat]
  /// set a [randomduration] where if say 0.1 will add a random number between -0.05 to 0.05 to the [duration] to stop multiple actors all moving in sync unnaturally
  /// Set whether or not this actor can cast a shadow with [castshadow]
  /// [castshadow] set with the object can cast a shadow
  /// [resetposition] so when clone, don't remember its old position
  static copyActor(
    actor, {
    action = "idle",
    randomduration,
    duration,
    texture,
    groupname,
    castshadow,
    resetposition,
    startat,
//    logtext,
  }) async {
    THREE.Object3D model = SkeletonUtils.clone(actor);
    if (resetposition != null && resetposition) {
      model.position.setValues(0.0, 0.0, 0.0);
    }

    if (actor.extra.containsKey('movetoloopindex'))
      actor.extra.remove('movetoloopindex');
    // stop issue where if rotate the original actor that rotation is remembered - should be the original rotation
    /*  if (actor.extra.containsKey('origquaternion')) {
      THREE.Quaternion quat=actor.extra['origquaternion'].clone();
      //model.useQuaternion = true;
      model.quaternion=quat;
      //model.applyQuaternion(quat);
    //  model.quaternion.normalize();
      if (logtext!=null)
        print("copy actor quat set"+quat.x.toString()+" "+quat.y.toString()+" "+quat.z.toString()+" "+quat.w.toString());
     // model.rotation.x = actor.extra['origrotation'].x;
     // model.rotation.y = actor.extra['origrotation'].y;
     // model.rotation.z = actor.extra['origrotation'].z;
      model.extra['origquaternion']=quat;//model.quaternion;
    }*/
  /*  if (actor.extra.containsKey('origrotation')) {
      model.rotation.x = actor.extra['origrotation'].x;
      model.rotation.y = actor.extra['origrotation'].y;
      model.rotation.z = actor.extra['origrotation'].z;
      if (logtext != null)
        print(
          "copy actor rot set" +
              actor.extra['origrotation'].x.toString() +
              " " +
              actor.extra['origrotation'].y.toString() +
              " " +
              actor.extra['origrotation'].z.toString(),
        );
      // if do a copy of a copy keep this original copy
      model.extra['origrotation'] = actor.extra['origrotation'];
    }*/

    // use z value of orignal actor
    model.children[0].position.y = actor.children[0].position.y;
    model.extra['animations'] = actor.extra['animations'];
    var mixer = new THREE.AnimationMixer(model);
    model.extra['mixer'] = mixer;
    model.extra['path'] = actor.extra['path'];

    if (texture != null) {
      actor?.extra['texturepath'] = texture;
      await Model.setTexture(model, texture, groupname: groupname);
    }
    if (castshadow != null) {
      model?.traverse((child) {
        if (child is THREE.Mesh) {
          // print("oo"+(child.material as THREE.MeshStandardMaterial).name.toString());
          //child.material =
          //    THREE.MeshLambertMaterial.fromMap({'map': child.material?.map});
          child.castShadow = castshadow;
        }
      });
      model?.castShadow = castshadow;
    }
    actorlist.add(model);
    if (action != null) {
      var anim = getAnimationByName(model, action);
      if (anim != null) {
        var idle = await mixer.clipAction(anim);
        if (randomduration != null) {
          var durationi;
          if (duration != null)
            durationi = duration;
          else
            durationi = anim.duration;
          durationi *=
              (1 + (Math.random() * randomduration - randomduration / 2));
          idle?.setDuration(durationi);
        } else if (duration != null) {
          idle?.setDuration(duration);
        }
        if (startat != null) {
          if (duration == null)
            idle?.startAt(startat.toDouble() * idle?.getClip().duration);
          else
            idle?.startAt(startat.toDouble() * duration.toDouble());
        }
        //cowidle?.setDuration(10);
        idle?.play();
      } else {
        print("anim action" + action + " not found");
      }
    }
    return model;
  }

  /// Allows creation of a new animation by combining two animations - for example a squat animation and a look left animation - combine to create squatting looking left animation
  /// Creates a new animation clip on [actor] called [newAnimName], built by taking
  /// the animation [baseAnimName] and overwriting the rotation of [boneName] in
  /// every frame with the rotation of [boneName] taken from the FIRST frame of
  /// [poseAnimName].
  ///
  /// Example:
  ///   OPENWORLD.Actor.createAnimation(seller, "sittableleft", "sittableidle", "lookleft", "Bip01Head")
  ///
  /// This lets you compose many pose variants (sittableleft, squatleft, squatright,
  /// standleft etc.) from a small set of base animations and a small set of single-bone
  /// "pose" animations, instead of hand-authoring every combination in Blender.
  /// [actor] is usually the shared actor that has all the shared animations
  /// [newAninmName] is the name of the new animation you want to create eg squatleft
  /// [baseAnimName] is the name of the animation you are modifying
  /// [poseAnimName] is the name of the second animation you are copying
  /// [boneNames] is a list of the bones you wish to copy the animation from [poseAnimName] to the new animation eg "Bip01_Head" bone for looking left
  static bool createAnimation(
    actor,
    String newAnimName,
    String baseAnimName,
    String poseAnimName,
    List<String> boneNames,
  ) {
    var baseClip = getAnimationByName(actor, baseAnimName);
    var poseClip = getAnimationByName(actor, poseAnimName);

    if (baseClip == null) {
      print(
        "createAnimation: base animation '$baseAnimName' not found on actor",
      );
      return false;
    }
    if (poseClip == null) {
      print(
        "createAnimation: pose animation '$poseAnimName' not found on actor",
      );
      return false;
    }

    var newClip = baseClip.clone();
    newClip.name = newAnimName;

    // Cast to a concrete, statically-typed list. Without this, poseClip.tracks

    // resolves as a dynamic call (since poseClip itself comes from a dynamic
    // Map lookup), and any closure passed to .where() gets inferred as
    // "(dynamic) => dynamic" instead of matching the real
    // "bool Function(KeyframeTrack)" signature .where() expects at runtime —
    // which throws exactly the type mismatch you're seeing.
    List<THREE.KeyframeTrack> poseClipTracks = List<THREE.KeyframeTrack>.from(
      poseClip.tracks,
    );
    List<THREE.KeyframeTrack> newClipTracks = List<THREE.KeyframeTrack>.from(
      newClip.tracks,
    );

    for (var boneName in boneNames) {
      var poseTracks = poseClipTracks
          .where((THREE.KeyframeTrack t) => t.name.startsWith('$boneName.'))
          .toList();

      if (poseTracks.isEmpty) {
        print(
          "createAnimation: bone '$boneName' has no tracks in '$poseAnimName'",
        );
        continue;
      }

      for (var poseTrack in poseTracks) {
        final itemSize = poseTrack.values.length ~/ poseTrack.times.length;
        final firstFrameValue = poseTrack.values.sublist(0, itemSize);

        THREE.KeyframeTrack? targetTrack;
        for (var t in newClipTracks) {
          if (t.name == poseTrack.name) {
            targetTrack = t;
            break;
          }
        }

        if (targetTrack != null) {
          final frameCount = targetTrack.times.length;
          final newValues = <num>[];
          for (var f = 0; f < frameCount; f++) {
            newValues.addAll(firstFrameValue);
          }
          targetTrack.values = newValues;
        } else {
          final times = newClipTracks.isNotEmpty
              ? newClipTracks[0].times
              : [0.0, newClip.duration];
          final newValues = <num>[];
          for (var f = 0; f < times.length; f++) {
            newValues.addAll(firstFrameValue);
          }

          THREE.KeyframeTrack newTrack;
          if (poseTrack is THREE.QuaternionKeyframeTrack) {
            newTrack = THREE.QuaternionKeyframeTrack(
              poseTrack.name,
              List<num>.from(times),
              newValues,
            );
          } else if (poseTrack is THREE.VectorKeyframeTrack) {
            newTrack = THREE.VectorKeyframeTrack(
              poseTrack.name,
              List<num>.from(times),
              newValues,
            );
          } else if (poseTrack is THREE.NumberKeyframeTrack) {
            newTrack = THREE.NumberKeyframeTrack(
              poseTrack.name,
              List<num>.from(times),
              newValues,
            );
          } else {
            newTrack = THREE.KeyframeTrack(
              poseTrack.name,
              List<num>.from(times),
              newValues,
            );
          }
          newClip.tracks.add(newTrack);
          newClipTracks.add(newTrack);
        }
      }
    }

    actor.extra['animations'].add(newClip);
    return true;
  }

  /// Get the [actor]s animations
  static getAnimations(THREE.Object3D actor) {
    return actor.extra['animations'];
  }

  /// Does the [actor] have an action called [name]
  static hasAnimation(actor, name) {
    var animations = Actor.getAnimations(actor);
    for (var animation in animations) {
      if (animation.name == name) {
        return true;
      }
    }
    return false;
  }

  /// Get the action for the [actor] of [name] or [index]
  /// Call THREE.AnimationAction  [clampWhenFinished] if specified
  /// [stopallactions] in the animation mixer if specified
  /// set the [duration] of the animation
  /// set a [randomduration] where if say 0.1 will add a random number between -0.05 to 0.05 to the [duration] to stop multiple actors all moving in sync unnaturally
  ///    if [randomduration] is 0.1 and duration is 10 seconds will be randomly between 9.5 and 10.5 seconds
  /// [startat] Start the actors animation within a fraction of the animations total length (between 0-1) - eg if 0.5 and animation is 3 seconds link then will start at 1.5 seconds
  static getAction(
    actor, {
    index,
    name,
    clampWhenFinished = false,
    stopallactions = false,
    duration,
    randomduration,
    startat,
  }) {
    var animations = Actor.getAnimations(actor);

    if (stopallactions) getActorMixer(actor).stopAllAction();
    THREE.AnimationClip? clip;
    if (index != null) {
      clip = animations[index];
    } else {
      for (var animation in animations)
        if (animation.name == name) {
          clip = animation;
        }
    }

    if (clip != null) {
      THREE.AnimationAction action = actor.extra['mixer'].clipAction(clip);

      if (clampWhenFinished) action.clampWhenFinished = true;
      if (duration != null) {
        if (randomduration != null)
          duration *=
              (1 + (Math.random() * randomduration - randomduration / 2));
        action.setDuration(duration);
      } else if (randomduration != null) {
        duration = clip.duration;
        duration *= (1 + (Math.random() * randomduration - randomduration / 2));
        action.setDuration(duration);
      }
      if (startat != null) {
        if (duration != null)
          action.startAt(startat.toDouble() * duration.toDouble());
        else
          action.startAt(startat.toDouble() * action.getClip().duration);
      }
      return action;
    } else
      print(
        "getaction could not find " +
            name.toString() +
            " for " +
            BaseObject.getName(actor),
      );
  }

  /// Returns the [startat] time for in [action] in seconds rather than as a fraction
  static getActionStartat(action, startat, duration) {
    if (startat != null) {
      if (duration == null) {
        // print("startat"+(startat.toDouble() * actionu
        //    .getClip()
        //    .duration).toString());
        return startat.toDouble() * action.getClip().duration;
      } else
        return startat.toDouble() * duration.toDouble();
    }
  }

  /// Play an animation for [actor] of [action] name.
  /// Call THREE.AnimationAction  [clampWhenFinished] if specified
  /// [stopallactions] in the animation mixer if specified
  /// set the [duration] of the animation
  /// set a [randomduration] where if say 0.1 will add a random number between -0.05 to 0.05 to the [duration] to stop multiple actors all moving in sync unnaturally
  /// [delay] before play the action
  /// [loopmode] specify if animation loops ie THREE.LoopOnce, THREE.LoopRepeat
  /// [looprepetitions] how many times loop  - 0 if indefinate
  /// play animation [backwards] if true
  /// [startat] Start the actors animation within a fraction of the animations total length (between 0-1) - eg if 0.5 and animation is 3 seconds link then will start at 1.5 seconds
  static playAction(
    actor, {
    action,
    clampWhenFinished = false,
    stopallactions = false,
    duration,
    randomduration,
    delay,
    loopmode,
    looprepetitions = 0,
    backwards,
    startat,
    fadein = 0.5,
    fadeout = 1.0,
  }) async {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () async {
        (await playAction(
          actor,
          action: action,
          clampWhenFinished: clampWhenFinished,
          stopallactions: stopallactions,
          duration: duration,
          randomduration: randomduration,
          loopmode: loopmode,
          looprepetitions: looprepetitions,
          startat: startat,
          fadein: fadein,
          fadeout: fadeout,
        ));
      });

      BaseObject.addTimer(actor, t);
      return null;
    } else {
      // If looping with playactionloop then stop the loop
      if (actor.extra.containsKey("actionlooptimer")) {
        actor.extra["actionlooptimer"].cancel();
      }
      // THREE.AnimationAction? currentaction = Actor.getActiveAction(actor);
      /*   if (currentaction!=null) {
      //  print("playaction fadeout"+action+" "+BaseObject.getName(actor));
        await currentaction.fadeOut(1.0);
      }*/
      print("playaction " + action + " " + BaseObject.getName(actor));
      THREE.AnimationAction actionu = await getAction(
        actor,
        name: action,
        clampWhenFinished: clampWhenFinished,
        stopallactions: stopallactions,
        duration: duration,
        randomduration: randomduration,
      );
      THREE.AnimationMixer mixer = getActorMixer(actor);
      if (mixer.isActiveAction(actionu!) && actionu!.isRunning()) {
        print(
          "playaction already playing " +
              action +
              " " +
              BaseObject.getName(actor),
        );
        return actionu;
      }
      // List<THREE.AnimationAction> actions = Actor.getActiveActions(actor);

      // actionu.reset();
      if (loopmode != null && looprepetitions != null)
        actionu.setLoop(loopmode, looprepetitions);
      if (duration != null) actionu.setDuration(duration);
      if (backwards != null && backwards) {
        // Standard three.js reversed-playback technique: negative timeScale
        // makes the mixer step time backwards each frame. Since reset() just
        // set time=0, we also need to seed time at the END of the clip,
        // otherwise the very first evaluation clamps to frame 0 and the
        // animation appears to not move (or snaps instantly to the start).
        var cliplength = actionu.getClip().duration.toDouble();
        var timescale;
        if (duration == null)
          timescale = 1;
        else
          timescale = cliplength / duration;
        actionu.timeScale = -timescale; //1;
        actionu.time = actionu.getClip().duration.toDouble();
      } else {
        //  actionu.timeScale = timescale;//1;
      }
      // !!! Must add backwards somehow
      /* if (backwards!=null&&backwards) {
        action.backwards=true;
      } else
        action.backwards=false;*/
      //  actionu.timeScale = -1;
      if (startat != null) {
        var actionstartat = getActionStartat(actionu, startat, duration);
        actionu.startAt(actionstartat);

        /* if (duration==null) {
         // print("startat"+(startat.toDouble() * actionu
          //    .getClip()
          //    .duration).toString());
          actionu.startAt(startat.toDouble() * actionu
              .getClip()
              .duration);
        } else
           actionu.startAt(startat.toDouble()*duration.toDouble());*/
      }
      //  THREE.AnimationMixer mixer=getActorMixer(actor);
      //if (!mixer.isActiveAction(actionu!))
      actionu.reset().play();
      if (fadeout != null && fadeout > 0) {
        Actor.fadeOutAll(actor, fadeout, excludeaction: actionu);
      } //.0);
      //        actionu.reset().play();
      //if (actions.length>0)
      if (fadein != null && fadein > 0) await actionu.fadeIn(fadein); //0.5);
      // Actor.fadeInAll(actor, 0.5);

      return actionu;
    }
  }

  /// Have [actor] play animation [action] and when complete then do the looped action [actionthen]
  /// Can specify [duration] of the [action] and the duration of actionthen with [durationthen]
  /// So that animations aren't always the same making actors move in unison use [randomdurationthen] to add small variations. 0.1 will change the duration by a random value within 10%
  /// Can play the animation [backwards]
  /// Can start animation in [delay] seconds
  static playActionThen(
    actor,
    action,
    actionthen, {
    duration,
    /*looprepetitions,*/ durationthen,
    randomdurationthen,
    backwards,
    /*loop,*/ delay,
  }) async {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        playActionThen(
          actor,
          action,
          actionthen,
          duration: duration,
          /*looprepetitions:looprepetitions,*/
          backwards: backwards,
          durationthen: durationthen,
          randomdurationthen: randomdurationthen /*,loop:loop*/,
        );
      });
      BaseObject.addTimer(actor, t);
    } else {
      /* THREE.AnimationAction activeanimation=getActiveAction(actor);
      if (activeanimation!=null) {
       // print("fadeeeee");//+activeanimation.name.toString());
        await activeanimation.fadeOut(0.5);

      }*/
      // Actor.fadeOutAll(actor,0.2);
      /* List<THREE.AnimationAction> actions= Actor.fadeOutAll(actor,1.0);
      if (actions.length==0)
        print("playactionthen fadeouti none"+BaseObject.getName(actor));
      else {
        for (var actionitem in actions)
          print("playactionthen fadeouti" + BaseObject.getName(actor) + " " +
              action + " " + actionitem
              .getClip()
              .name
              .toString()); // Actor.gactionitem.name.toString());
      }*/
      // Actor.playAction already fades it out
      var loopmode;
      // if (looprepetitions!=null&&looprepetitions>1) {
      //    loopmode=THREE.LoopRepeat;
      //} else
      loopmode = THREE.LoopOnce;
      THREE.AnimationAction animationaction = await Actor.playAction(
        actor,
        action: action,
        clampWhenFinished: true,
        //  stopallactions: true,
        loopmode: loopmode,
        //THREE.LoopOnce,
        //   looprepetitions: looprepetitions,
        backwards: backwards,
        duration: duration,
      );
      THREE.AnimationMixer mixer = Actor.getActorMixer(actor);
      // playaction already fades it in
      //   animationaction.fadeIn(0.5);

      mixer.addEventListener('finished', (e) async {
        mixer.clearListeners();
        //animationaction.fadeOut(0.5);//1.0);
        //play action already fades it out
        List<THREE.AnimationAction> actions = Actor.getActiveActions(actor);
        for (var actionitem in actions)
          if (actionitem != animationaction) actionitem.stop();
        print(
          "play action then" +
              actionthen +
              " " +
              actor.toString() +
              " " +
              Mob.getName(actor),
        );
        /* var actions= Actor.fadeOutAll(actor,1.0);
                if (actions.length==0)
                  print("playactionthen fadeoutii none"+BaseObject.getName(actor));
                else {
                  for (var actionitem in actions)
                    print("playactionthen fadeoutii" + BaseObject.getName(actor) + " " +
                        action + " " + actionitem
                        .getClip()
                        .name
                        .toString()); // Actor.gactionitem.name.toString());
                }*/

        //  if (loop==null||!loop) {
        var actionanimation = await Actor.playAction(
          actor,
          action: actionthen,
          clampWhenFinished: true,
          randomduration: randomdurationthen,
          // fadeout:0.0,
          duration: durationthen,
        );
        /*  } else {
                  var actionanimation = await Actor.playAction(
                      actor, action: actionthen,
                      loopmode: THREE.LoopOnce,
                      clampWhenFinished: true,
                      // fadeout:0.0,
                      duration: durationthen);
                  mixer.addEventListener('finished',
                          (e) async {
                        mixer.clearListeners();
                        playActionThen(
                            actor, action, actionthen, duration: duration,
                            durationthen: durationthen,
                            backwards: backwards,
                            loop: loop);
                      }
                  );
                }*/

        // play action already fades it in
        //  actionanimation.fadeIn(1.0);
      });
    }
  }


  /// Given an [actor] a list of [actions] to play over and over in a loop eg sit down, then standup then startjump etc
  /// [durationss] list of durations for each action
  /// [randomdurations] list of randomdurations for each action
  /// [randomaction] start at a random action instead of the first
  /// [usetimers] specify whether use timers to switch actions or wait till animation finished event occurs
  /// [stoponcomplete] rather than loop over and over stop when reach the end of the list of actions
  static playActionsLoop(
    actor,
    actions, {
    durations,
    randomdurations,
    looprepetitionss,
    index,
    fadein,
    fadeout = 1.0,
    randomaction,
    usetimers = true,
    stoponcomplete,
    islooped = false,   // is an internval playactionloop variable
    /*callbackonfinish,*/ delay,
  }) async {
    if (!islooped && actor.extra.containsKey('prevloopaction'))
      actor.extra.remove('prevloopaction');

    // assert(actions.length>1,'jj');
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        playActionsLoop(
          actor,
          actions,
          durations: durations,
          randomdurations: randomdurations,
          looprepetitionss: looprepetitionss,
          fadein: fadein,
          fadeout: fadeout,
          randomaction: randomaction,
          stoponcomplete: stoponcomplete /*,callbackonfinish:callbackonfinish*/,
        );
      });
      BaseObject.addTimer(actor, t);
    } else {
      if (randomaction != null && randomaction)
        index = Math.randInt(actions.length);
      else if (index == null || index >= actions.length) {
        index = 0;
      }
      var duration;
      if (durations != null && index < durations.length)
        duration = durations[index];
      else
        duration = null;
      var randomduration;
      if (randomdurations != null && index < randomdurations.length)
        randomduration = randomdurations[index];
      else
        randomduration = null;
      if (actions.length == 1) {
        // If just one action then just loop it
        THREE.AnimationAction animationaction = await Actor.playAction(
          actor,
          action: actions[0],

          // clampWhenFinished: true,
          //  stopallactions: true,
          // loopmode: THREE.LoopOnce,
          // backwards:backwards,
          randomduration: randomduration,
          duration: duration,
          fadein: fadein,
          fadeout: fadeout,
        );
      } else {
        var action = actions[index];
        // print("playactionsloop"+index.toString()+' '+action);
        // Actor.fadeOutAll(actor, 0.5);

        var clipduration;
        //    THREE.AnimationAction actionitemu=Actor.getAction(actor,name:action);
        /* List<THREE.AnimationAction> actionsu= Actor.getActiveActions(actor);
        var found=false;
        for (var actionitem in actionsu)
          if (actionitemu==actionitem)
            found=true;*/
        /*if (actor.extra.containsKey('prevloopaction')&&actor.extra['prevloopaction']==actionitemu) {//actor.extra['']found) {
          // case where previous loop was this action therefore just play this action again rather than load it again
        //  print("found play action loop"+BaseObject.getName(actor)+" "+index.toString()+" "+actionitemu.isRunning().toString());

          actionitemu.play();
          if (duration != null)
            clipduration = duration;
          else
            clipduration = actionitemu.clip.duration;

        } else {*/
        //   print("not found play action loop"+BaseObject.getName(actor)+" "+index.toString());
        var looprepetitions;
        var loopmode;
        if (looprepetitionss != null &&
            index < looprepetitionss.length &&
            looprepetitionss[index] != 1) {
          looprepetitions = looprepetitionss[index];
          loopmode = THREE.LoopRepeat;
        } else {
          looprepetitions = null;
          loopmode = THREE.LoopOnce;
        }

        /*  if (actor.extra.containsKey('prevloopaction')&&actor.extra['prevloopaction']!=actionii) {
          //print("movetoloop fadeout"+fadeout.toString());
          actor.extra['prevloopaction'].fadeOut(fadeout);//0.5);
        }*/

        THREE.AnimationAction animationaction = await Actor.playAction(
          actor,
          action: action,
          clampWhenFinished: true,
          //  stopallactions:true,//fadeout==null,
          loopmode: loopmode,
          //THREE.LoopRepeat,
          looprepetitions: looprepetitions,
          //2,
          //            loopmode: THREE.LoopOnce,
          randomduration: randomduration,
          //startat:0.03,
          // backwards:backwards,
          duration: duration,
          fadein: fadein,
          //  fadeout:fadeout
        );
        Actor.fadeOutAll(actor, fadeout, excludeaction: animationaction);
        actor.extra['prevloopaction'] = animationaction;
        /*  var animations=Actor.getAnimations(actor);

        for (THREE.AnimationClip? clip in animations)
          if (clip!=animationaction) {
            THREE.AnimationAction animation=actor.extra['mixer'].clipAction(clip);
            animation.reset();
          }*/

        if (duration != null)
          clipduration = duration;
        else
          clipduration = animationaction.clip.duration;
        //  }
        if (looprepetitions != null) clipduration *= looprepetitions;

        /* if (actor.extra.containsKey("actionlooptimer")) {
          // BaseObject.clearTimers(obj)

          actor.extra["actionlooptimer"].cancel();
          actor.extra['timers'].remove(actor.extra["actionlooptimer"]);
        }*/
        // removes actionlooptimer - possibly stop adding many?
        removeObjectFromPlayActionsLoop(actor);

        // Use a timer instead of finished eventlistener so that the loop can be cleared with clearTimers()
        if (usetimers != null && usetimers) {
          if (actor.visible &&
              (index < actions.length - 1 ||
                  stoponcomplete == null ||
                  !stoponcomplete)) {
            print(
              "play action loop" +
                  BaseObject.getName(actor) +
                  " " +
                  clipduration.toString(),
            );
            Timer t = await Timer(
              Duration(milliseconds: (clipduration * 1000).round()),
              () {
                /* var usefadeout;
            if (fadeout != null)
              usefadeout = fadeout;
            else
              usefadeout = 0.5;
            animationaction.fadeOut(usefadeout); //1.0);//0.5); */
                print(
                  "play action loop" +
                      BaseObject.getName(actor) +
                      " " +
                      index.toString(),
                );

                playActionsLoop(
                  actor,
                  actions,
                  index: index + 1,
                  durations: durations,
                  randomdurations: randomdurations,
                  fadein: fadein,
                  fadeout: fadeout,
                  stoponcomplete: stoponcomplete,
                  islooped: true,
                );
              },
            );
            BaseObject.addTimer(actor, t);
            actor.extra["actionlooptimer"] = t;
          } else {
            print(
              "play action loop stop " +
                  BaseObject.getName(actor) +
                  " " +
                  actor.visible.toString(),
            );
            // if (callbackonfinish!=null)
            //   callbackonfinish(actor);
          }
        } else {
          // An issue here is how do you turn it off
          THREE.AnimationMixer mixer = Actor.getActorMixer(actor);

          mixer.addEventListener('finished', (e) async {
            mixer.clearListeners();
            //  if (mixer.removeEventListener('finished', listener)
            // dude(e) async
            //{
            //  if (index<actions.length-1||stoponcomplete==null||!stoponcomplete)
            /* List<THREE.AnimationAction> actionsu= Actor.getActiveActions(actor);
                for (var actionitem in actionsu)
                  if (actionitem!=animationaction)
                    actionitem.stop();*/
            if (index < actions.length - 1 ||
                stoponcomplete == null ||
                !stoponcomplete) {
              //   print("play action loop");
              playActionsLoop(
                actor,
                actions,
                index: index + 1,
                durations: durations,
                randomdurations: randomdurations,
                fadein: fadein,
                fadeout: fadeout,
                stoponcomplete: stoponcomplete,
                islooped: true,
              );
            }
          });
        }
      }
    }
  }

  /// Remove the [actor] from the play actions loop
  static removeObjectFromPlayActionsLoop(actor) {
    if (actor.extra.containsKey("actionlooptimer")) {
      // BaseObject.clearTimers(obj)

      actor.extra["actionlooptimer"].cancel();
      actor.extra['timers'].remove(actor.extra["actionlooptimer"]);
      actor.extra.remove("actionlooptimer");
    }
  }

  ///. Stop all animations on character [group]
  static stopAnimations(THREE.Object3D group) //THREE.AnimationMixer mixer)
  async {
    //print("xxx"+mixer.getRoot().toString());
    //THREE.Object3D group=mixer.getRoot();
    List<dynamic> animations = group.extra['animations'];
    // print("stop name"+group.extra['name']);
    //THREE.Object3D model=group.children[0] as THREE.Object3D;
    // print("xxx"+group.animations.toString()+" "+group.name.toString());//amodel.toString());
    //model.

    for (var j = 0; j < animations.length; j++) {
      await group.extra['mixer'].clipAction(animations[j])?.stop();
      await group.extra['mixer'].clipAction(animations[j])?.reset();
    }
  }

  /// Have an [actor] wield a [model] on the bone [bonename]
  static wield(actor, wieldobject, bonename, {delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        wield(actor, wieldobject, bonename);
      });
      BaseObject.addTimer(actor, t);
    } else {
      unwield(actor, bonename);
      THREE.Bone? bone = null;
      actor.traverse((object) {
        if (object.skeleton != null) {
          bone = object.skeleton?.getBoneByName(bonename);
        }
      });

      //THREE.Bone bone= actor.children[0].children[0].skeleton?.getBoneByName(bonename);//"Bip01_R_Hand");
      if (bone != null) {
        bone?.add(wieldobject); //.children[0]);
      }
      actor.extra['wielding'] = wieldobject;
      return bone;
    }
  }

  /// Have [actor] unwield any models it is wielding
  static unwieldAll(actor, {delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        unwieldAll(actor);
      });
      BaseObject.addTimer(actor, t);
    } else {
      THREE.Bone? bone = null;
      actor.traverse((object) {
        if (object.skeleton != null) {
          for (var bone in object.skeleton?.bones) {
            if (bone != null) bone.clear();
          }
        }
      });

      /*  for (var bone in actor.children[0].children[0].skeleton?.bones) {
        if (bone != null)
          bone.clear();
      }*/
      clearWielding(actor);
    }
  }

  /// Have [actor] unwield any model attached to [bonename] in [delay] seconds
  static unwield(actor, bonename, {delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        unwield(actor, bonename);
      });
      BaseObject.addTimer(actor, t);
    } else {
      THREE.Bone? bone = null;
      actor.traverse((object) {
        if (object.skeleton != null) {
          bone = object.skeleton?.getBoneByName(bonename);
        }
      });

      // var bone = actor.children[0].children[0].skeleton?.getBoneByName(
      //    bonename); //"Bip01_R_Hand");
      if (bone != null) {
        bone?.clear();
        clearWielding(actor);
      }
    }
  }

  /// Return the object3d that [obj] is wielding
  /// This isn't much good if you're wielding multiple objects on different bones
  static getWielding(obj) {
    if (obj.extra.containsKey('wielding')) return obj.extra['wielding'];
  }

  /// Clear the item specified that the [actor] is wielding - will not actually remove what was wielded
  static clearWielding(actor) {
    if (actor.extra.containsKey('wielding'))
      actor.extra.remove('wielding');
  }
}

/// Procedures for creating planes including planes with text
class Plane {
  /// Create a plane with texture at [path] of size [width] and [height].
  /// [ambient] specifies if ambience changes with time of day
  /// [flipx] flips the plane texture in the horizontal direction
  /// is the material [doublesided] ?
  /// Position plane in [z] axis
  static loadPlane(
    path,
    width,
    height, {
    ambient = true,
    flipx = false,
    doublesided,
    z,
  }) async {
    var texturei = await AssetPack.loadTexture(path);//await THREE.TextureLoader().fromAsset(path);
    THREE.MeshStandardMaterial planeMaterial = THREE
        .MeshStandardMaterial.fromMap({'map': texturei, 'transparent': true});

    if (doublesided != null && doublesided)
      planeMaterial.side = THREE.DoubleSide;
    if (ambient && Time.ambience != null)
      planeMaterial.color = Time.ambience?.color as THREE.Color;

    var geometry = THREE.PlaneGeometry(1, 1);
    var plane = THREE.Mesh(geometry, planeMaterial);
    if (!kIsWeb) {
      // must flip for android and ios for some reason
      (plane.material as THREE.MeshStandardMaterial).map?.wrapT =
          THREE.RepeatWrapping;
      (plane.material as THREE.MeshStandardMaterial).map?.repeat.y = -1.0;
    }

    if (flipx) {
      (plane.material as THREE.MeshStandardMaterial).map?.wrapS =
          THREE.RepeatWrapping;
      (plane.material as THREE.MeshStandardMaterial).map?.repeat.x = -1.0;
    }
    plane.scale.setValues(width.toDouble(), height.toDouble(), 1);
    if (z != null) plane.position.y = z.toDouble(); //height/2;
    Space.objTurn(plane, -90); // front face is pointing north
    THREE.Group group = THREE.Group();
    group.add(plane);

    group.extra['texturepath'] = path;
    group.extra['isplane'] = true;
    if (ambient) group.extra['ambient'] = true;
    return group;
  }

  /// Create a text plane with text [message] with color [textcolor] and size [fontSize] and background of color [backgroundcolor] with opacity [backgroundopacity]
  /// [z] is how high make the plane above zero
  /// [width] how wide to make the text in pixels
  /// Set whether text is [bold]
  /// Set the text [fontfamily]
  static makeTextPlane(
    message,
    Color textcolor, {
    fontSize = 20,
    z = 0,
    backgroundcolor = Colors.black,
    backgroundopacity = 0.5,
    width = 200,
    bold,
    fontfamily,
  }) async {
    var ret = await Texture.makeText(
      message,
      textcolor,
      fontSize: fontSize,
      z: z,
      backgroundcolor: backgroundcolor,
      backgroundopacity: backgroundopacity,
      width: width,
      bold: bold,
      fontfamily: fontfamily,
    );
    var texturei = ret['texture'];
    width = ret['width'];
    var height = ret['height'];
    THREE.MeshStandardMaterial material = THREE.MeshStandardMaterial.fromMap({
      'map': texturei,
      'transparent': true,
      'sizeAttenuation':
          true /* 'useScreenCoordinates': false,*/ /*, 'alignment': THREE.Vector2( 1, -1 )spriteAlignment*/,
    });
    var group = THREE.Group();
    var geometry = THREE.PlaneGeometry(1, 1);
    var plane = THREE.Mesh(geometry, material);
    group.add(plane);
    plane.scale.setValues(1.0, height.toDouble() / width.toDouble(), 1.0);

    Space.objTurn(plane, -90); // front face is pointing north
    plane.position.y = z.toDouble(); //50;
    return group;
  }
}

/// Procedures related to sprites such as text sprites
class Sprite {
  /// Create a sprite with texture at [path] of size [width] and [height].
  /// [ambient] specifies if ambience changes with time of day
  /// [flipx] flips the sprite in the horizontal direction
  /// [transparent] is the sprite transparent
  /// [sizeattenuation] whether or not the sprite changes size depending on how far it is from the camera
  static loadSprite(
    path,
    width,
    height, {
    ambient = true,
    flipx = false,
    transparent = false,
    sizeattenuation = true,
  }) async {
    var texturei =await AssetPack.loadTexture(path);// await THREE.TextureLoader().fromAsset(path);
    texturei?.colorSpace = THREE.SRGBColorSpace;
    THREE.SpriteMaterial spriteMaterial = THREE.SpriteMaterial.fromMap({
      'map': texturei,

      'transparent': transparent,
      //false,//true  !!! for water shader for some reason this needs to be false,
      'sizeAttenuation': sizeattenuation,
      //true,
      'alphaTest': 0.1,
    });

    if (ambient && Time.ambience != null) {
      //spriteMaterial.color = THREE.Color.fromHex32(0x000000);//Time._ambience!.color as THREE.Color;
      spriteMaterial.color = Time.ambience!.color as THREE.Color;
      //  print("mmcol"+spriteMaterial.color.red.toString()+" "+spriteMaterial.color.green.toString()+" "+spriteMaterial.color.blue.toString());
    }

    var sprite = new THREE.Sprite(spriteMaterial);
    if (!kIsWeb) {
      // must flip for android and ios for some reason
      (sprite.material as THREE.SpriteMaterial).map?.wrapT =
          THREE.RepeatWrapping;
      (sprite.material as THREE.SpriteMaterial).map?.repeat.y = -1.0;
    }

    if (flipx) {
      (sprite.material as THREE.SpriteMaterial).map?.wrapS =
          THREE.RepeatWrapping;
      (sprite.material as THREE.SpriteMaterial).map?.repeat.x = -1.0;
    }
    sprite.scale.setValues(width.toDouble(), height.toDouble(), 1);
    sprite.position.y = height / 2;
    THREE.Group group = THREE.Group();
    group.add(sprite);

    group.extra['texturepath'] = path;
    if (ambient) group.extra['ambient'] = true;
    return group;
  }

  /// clones a sprite [spriteorig] but only by reusing the original sprites material - creates a new sprite from scratch
  // Why cant I just use spriteorig.copy(true) - doesn't work!!
  static cloneSprite(spriteorig) {
    var sprite = new THREE.Sprite(); //spriteorig.children[0].material);

    sprite.scale.setValues(
      spriteorig.children[0].scale.x,
      spriteorig.children[0].scale.y,
      1,
    ); // 0.4,1.4,1);

    sprite.material = spriteorig.children[0].material;
    if (!kIsWeb) {
      // must flip for android and ios for some reason
      (sprite.material as THREE.SpriteMaterial).map?.wrapT =
          THREE.RepeatWrapping;
      (sprite.material as THREE.SpriteMaterial).map?.repeat.y = -1.0;
    }

    sprite.position.y = spriteorig.children[0].position.y;

    THREE.Group group = THREE.Group();
    if (spriteorig.extra.containsKey('ambient') && spriteorig.extra['ambient'])
      group.extra['ambient'] = true;
    group.add(sprite);
    return group;
  }

  /// Create multi text sprites of different fonts, boldness, text color
  /// [texts] is an array of Maps that include the text to be drawn, font, size, padding etc

  static makeMultiTextSprite(List<Map> texts, {scale, x = 0, y = 0, z = 0}) async {
    var ret = await Texture.makeMultiText(texts);
    if (ret != null) {
      var texturei = ret['texture'];
      var width = ret['width'];
      var height = ret['height'];
      THREE.SpriteMaterial spriteMaterial = THREE.SpriteMaterial.fromMap({
        'map': texturei,
        'transparent': true,
        'sizeAttenuation':
            true /* 'useScreenCoordinates': false,*/ /*, 'alignment': THREE.Vector2( 1, -1 )spriteAlignment*/,
      });

      var sprite = new THREE.Sprite(spriteMaterial);
      sprite.scale.setValues(width, height, 1.0);
      sprite.position.x = x.toDouble(); //50;
      sprite.position.y = z.toDouble(); //50;
      sprite.position.z = y.toDouble(); //50;
      if (scale != null) {
        sprite.scale.x = sprite.scale.x * scale;
        sprite.scale.y = sprite.scale.y * scale;
      }
      return sprite;
    } else
      return null;
  }

  /// Create a text sprite with text [message] with color [textcolor] and size [fontSize] and background of color [backgroundcolor] with opacity [backgroundopacity]
  /// [z] is how high make the sprite
  /// [width] how wide to make the sprite texture in pixels
  /// Is the text [bold]
  /// Set text [fontfamily] eg Roboto
  static makeTextSprite(
    message,
    Color textcolor, {
    fontSize = 20,
    x = 0.0,
    y = 0.0,
    z = 0,
    backgroundcolor = Colors.black,
    backgroundopacity = 0.5,
    width = 200,
    bold,
    fontfamily,
    paddingLeft = 0.0,
    paddingRight = 0.0,
    paddingTop = 0.0,
    paddingBottom = 0.0,
    sizeattentuation = true,
    scale,
    tails,
  }) async {
    //  var ret = await Texture.makeText('E Mount', Colors.white,  z:1.8, backgroundcolor:Colors.black, backgroundopacity:1.0, paddingLeft:20);
    // Why do you pass z to makeText? Its not even used
    var ret = await Texture.makeText(
      message,
      textcolor,
      fontSize: fontSize,
      z: z,
      backgroundcolor: backgroundcolor,
      backgroundopacity: backgroundopacity,
      width: width,
      bold: bold,
      fontfamily: fontfamily,
      paddingLeft: paddingLeft,
      paddingRight: paddingRight,
      paddingTop: paddingTop,
      paddingBottom: paddingBottom,
      tails: tails,
    );
    if (ret != null) {
      var texturei = ret['texture'];
      width = ret['width'];
      var height = ret['height'];
      THREE.SpriteMaterial spriteMaterial = THREE.SpriteMaterial.fromMap({
        'map': texturei,
        'transparent': true,
        'sizeAttenuation': sizeattentuation,
        //true /* 'useScreenCoordinates': false,*/ /*, 'alignment': THREE.Vector2( 1, -1 )spriteAlignment*/
      });

      var sprite = new THREE.Sprite(spriteMaterial);
      if (scale == null)
        sprite.scale.setValues(width, height, 1.0);
      else
        sprite.scale.setValues(scale, scale, 1.0);
      sprite.position.y = z.toDouble(); //50;
      sprite.position.z = -y.toDouble();
      sprite.position.x = x.toDouble();
      return sprite;
    } else
      return null;
  }
}

/// Procedures related to light sources such as flickering and fading to different intensities
class Light {
  static THREE.Clock? clock = null;

  static List<THREE.Light> lightflickers = [];
  static List<THREE.Light> nightonlys = [];
  static List<THREE.Light> intensitylerps = [];

  static init() {
    lightflickers = [];
    nightonlys = [];
    intensitylerps = [];
  }

  /// Make [light] flicker
  static addFlicker(THREE.Light light) {
    if (!lightflickers.contains(light)) lightflickers.add(light);
    light.extra['initintensity'] = light.intensity;
    light.extra['currentintensity'] = light.intensity;
  }

  /// Set the [light] to only shine at night
  static addNightOnly(THREE.Light light) {
    light.extra['initintensity'] = light.intensity;
    light.extra['currentintensity'] = light.intensity;
    //   light.extra['initcolor']=light.color;
    if (!nightonlys.contains(light)) nightonlys.add(light);
  }

  /// Lerp intensity of the [light] to [intensity] in [time] seconds
  static intensityLerp(THREE.Light light, intensity, time) {
    if (lightflickers.contains(light)) lightflickers.remove(light);

    // Must be visible for the duration of the lerp or nothing will render -
    // update() sets light.visible=false once intensity actually reaches 0.
    light.visible = true;

    light.extra['lerpfromtimelight'] = System.currentMilliseconds();
    light.extra['lerptotimelight'] = time;

    light.extra['lerpinitiallight'] = light.intensity;
    light.extra['lerpfinallight'] = intensity;
    //if (light.extra.containsKey('grouplamplight'))
    //  print("found group lamp light in lerp"+" "+intensitylerps.indexOf(light).toString());
    if (intensitylerps.indexOf(light) < 0) {
      intensitylerps.add(light);
    }
  }

  /// Lerp intensity of every [THREE.Light] found within [object] (including
  /// object itself, so this also works if [object] is the light itself) to
  /// [fraction] of that light's original design-time intensity, over [time]
  /// seconds. Used by Space.worldToLocalSurfaceObjHide's [lerplight] option
  /// so lights fade in/out smoothly instead of popping on/off.
  static intensityLerpObj(THREE.Object3D object, fraction, time) {
    //var isgrouplamp=object.extra.containsKey("grouplamp");
    object.traverse((child) {
      if (child is THREE.Light) {
        if (!child.extra.containsKey('lerporiginalintensity')) {
          child.extra['lerporiginalintensity'] = child.intensity;
        }
        var original = child.extra['lerporiginalintensity'];
        /*if (isgrouplamp) {
          print('found group lamp' + original.toString() + " " +
              fraction.toString() + " " +
              time.toString()); //child.extra.containsKey('grouplamp'))
          child.extra['grouplamplight']=true;
        }*/
        //    print();
        intensityLerp(child, original * fraction, time);
      }
    });
  }

  /// Remove [light] from shining only at night
  static removeNightOnly(light) {
    if (nightonlys.contains(light)) nightonlys.remove(light);
    light.intensity = light.extra['initintensity'];
  }

  /// Update lights so can flicker and transition to different intensities
  static update(frametime) {
    if (clock == null) {
      print("no clock");
      return;
    }
    // Only check once a minute
    if (nightonlys.length > 0) {
      //&& System.currentMilliseconds()-lastnightchecktick>1000) {

      var perc = 1 - Time.getSunBrightness(Time.time);
      //print("perc"+perc.toString());
      // perc=0;
      for (var light in nightonlys) {
        if (Space._hideobjects.contains(light) && !light.visible) {
          // if light hidden because far away then dont switch it on
        } else {
          light.visible = perc > 0;
          if (light.visible && !lightflickers.contains(light)) {
            light.intensity =
                light.extra['initintensity'] *
                perc; //intensity;//color=lightcolor;
          }
          light.extra['currentintensity'] = light.extra['initintensity'] * perc;
        }
      }
    }

    // Flicker each light in the list

    for (var i = 0; i < lightflickers.length; i++) {
      var light = lightflickers[i];
      // if (light.visible)
      //   print("light on"+i.toString());
      if (light.visible &&
          light != null &&
          light.extra['currentintensity'] != 0) {
        var maxintensity =
            light.extra['currentintensity'] +
            light.extra['currentintensity'] * 0.25;
        var minintensity =
            light.extra['currentintensity'] -
            light.extra['currentintensity'] * 0.25;
        light.intensity +=
            (0.005) * //frametime* //clock!.getDelta() *
            // 20 *
            (5.0 * Math.random() - 2.5); //= 2+Math.random()*0.1-0.05;
        //print("xxxx"+light.intensity.toString()+" "+maxintensity.toString()+" "+minintensity.toString()+" "+frametime.toString());
        if (light.intensity > maxintensity) //2.3)
          light.intensity = maxintensity; //2.3;
        else if (light.intensity < minintensity) //1.7)
          light.intensity = minintensity; // 1.7;
      }
    }

    // Lerp light intensity
    for (var i = intensitylerps.length - 1; i >= 0; i--) {
      var obj = intensitylerps[i];
      //  if (obj.extra.containsKey('grouplamplight'))
      //    print("found group lamp here");
      if (obj == null) {
        intensitylerps.remove(obj);
      } else {
        var lerp =
            (System.currentMilliseconds() - obj.extra['lerpfromtimelight']) /
            (obj.extra['lerptotimelight'] * 1000);
        if (lerp >= 1) {
          intensitylerps.remove(obj);
          obj.intensity = obj.extra['lerpfinallight'].toDouble();
        } else {
          var newlight =
              obj.extra['lerpinitiallight'] +
              lerp *
                  (obj.extra['lerpfinallight'] - obj.extra['lerpinitiallight']);
          obj.intensity = newlight;
        }
        // A light contributes nothing at 0 intensity anyway, so switching
        // it off outright is a cheap win - most renderers skip fully
        // invisible lights during the lighting pass rather than just
        // rendering them at zero brightness.
        //if (obj.extra.containsKey('grouplamplight'))
        //   print("grouplamplight"+obj.intensity.toString()+" "+ (obj.intensity > 0).toString());
        obj.visible = obj.intensity > 0;
      }
    }
  }
}

/// Procedures related to game time such as night, day, length of day
class Time {
  static double time = 0; // 0 is midnight, 12 is noon
  static double daylength = 2.0; //2.0;// in hours , -1 never change

  static double nightstart = 21.5; // Time when night starts
  static double nightend = 5; // Time when night ends
  static double daystart = 10.5; // When day start
  static double dayend = 18.5; // When day ends
  static double sunrise = 7;
  static double sunset = 20;

  static double baseambience =
      0.4; // no matter what time it is this is how much ambience there is

  //static THREE.Mesh? _sunSphere;
  static THREE.Light? _sunLight;

  static double _azimuth = THREE.MathUtils.degToRad(90); // sun sets in the west // 0.1;

  static THREE.ShaderMaterial? _skyMat;

  static THREE.AmbientLight? ambience;

  // State for setTimeLerp() - smoothly transitioning Time.time to a target
  // value over a number of real seconds, rather than snapping instantly.
  static double? _lerpfromtime;
  static double? _lerptotime;
  static double? _lerpduration;
  static double _lerpelapsed = 0.0;

  /// initialise with a sun object [sunSphere] that moves with the position of a [skyMat] skymaterial shader
  /// [ambience] is ambient light that changes depending on the time of day
  static init(sunLight, skyMat, THREE.AmbientLight ambience) {
    Time._skyMat = skyMat;
    Time._sunLight = sunLight;
    Time.ambience = ambience;
  }

  /// get the brightness of the sun given the [time] of day - 0 dark 1 brightest
  static getSunBrightness(time) {
    var perc;
    if (isNight(time))
      perc = 0;
    else if (isDay(time))
      perc = 1;
    else if (time >= dayend && time <= nightstart) //isDaySunset(time))
      perc = (nightstart - time) / (nightstart - dayend);
    else if (time >= nightend && time < daystart) //isNightSunrise(time)) {
      perc = (time - nightend) / (daystart - nightend);
    return perc.toDouble();
  }

  /// Update the time based on daylength
  /// frametime is second elapsed since last time updated
  static update(frameTime) {
    if (_lerpduration != null) {
      _lerpelapsed += frameTime;
      var t = (_lerpelapsed / _lerpduration!).clamp(0.0, 1.0);
      setTime(_lerpfromtime! + (_lerptotime! - _lerpfromtime!) * t);
      if (t >= 1.0) {
        // Lerp finished - clear state so normal daylength progression
        // (if any) resumes from here on subsequent update() calls.
        _lerpduration = null;
      }
      return;
    }
    if (daylength > 0) {
      var fakesecondselapsed = (24.0 / daylength) * frameTime;
      // convert from second to minutes then hours
      setTime(Time.time + (fakesecondselapsed / 60.0) / 60.0);
    }
  }

  /// Smoothly lerp Time.time from its current value to [newtime] (hours,
  /// 0-24) over [time] seconds (real seconds, not game time). While a lerp
  /// is in progress the normal daylength-based time progression is paused;
  /// it resumes automatically once the lerp completes.
  ///
  /// The shorter direction around the 24-hour clock is always taken, e.g.
  /// lerping from 23 to 1 goes forward through midnight (+2 hours) rather
  /// than backward through the whole day (-22 hours).
  ///
  /// Example: if Time.time is currently 6 (6am), setTimeLerp(8, 120) will
  /// smoothly advance the time to 8am over the next 120 seconds.
  static setTimeLerp(newtime, time, {onlyifover}) {
    if (onlyifover != null && onlyifover && newtime < Time.time) return;
    var from = Time.time;
    var to = newtime.toDouble() % 24;
    var diff = to - from;
    if (diff > 12)
      diff -= 24;
    else if (diff < -12)
      diff += 24;

    _lerpfromtime = from;
    _lerptotime = from + diff;
    _lerpelapsed = 0.0;
    _lerpduration = time.toDouble();
  }

  /// set the [newtime] time and adjust skymesh and sun and ambience based  on time of day
  static setTime(newtime) {
    //sunSphere.position.y = - 700000;
    //sunSphere.visible = true;
    Time.time = newtime.toDouble() % 24;

    if (_sunLight != null) {
      // const distance = 400000;
      const distance = 400; //00;

      var perc = Time.getSunBrightness(time);

      // Set the background ambience based upon time
      var light = perc * (1 - baseambience) + baseambience;
      // print("light"+light.toString());

      THREE.Color ambience = THREE.Color();
      const fct = 1.0; //0.5;  // in three_js if dont use 0.5 will be too bright
      //print("ambience fct"+fct.toString());
      ambience.red = fct * light;
      ambience.green = fct * light;
      ambience.blue = fct * light;
      _sunLight!.intensity = perc;
      Time.ambience?.color = ambience; //THREE.Color(ambience);//0xffffff);
      // Set the inclination of the sun - sun should dip below horizon at sunset
      // -0.5 sunrise
      // 0=noon
      // 0.5=sunset
      // 1=midnight
      var inclination = 0.0;
      var found = false;
      var times = [0, sunrise, 12, sunset, 24];
      // var inclinations= [-1,         -0.5,     0 ,    0.5 ,      1];
      // if you make 12pm  90 degrees instead of 80 the walls dont get any light
      var inclinations = [-90, 0, 80, 180, -90];
      for (var i = 0; i < times.length; i++) {
        if (!found && time < times[i + 1]) {
          var x1 = times[i];
          var x2 = times[i + 1];
          var y1 = inclinations[i];
          var y2 = inclinations[i + 1];
          var m = (y2 - y1) / (x2 - x1);
          inclination = m * (time - x1) + y1;
          // print("found time"+time.toString()+" "+i.toString()+" "+inclination.toString());
          found = true;
        }
      }

      // 0 is noon, 1 is midnight
      // var theta = math.pi * (inclination - 0.5);
      //var phi = 2 * math.pi * (_azimuth - 0.5);

      var x = math.cos(THREE.MathUtils.degToRad(inclination)) * math.sin(_azimuth);
      var y = math.cos(THREE.MathUtils.degToRad(inclination)) * math.cos(_azimuth);
      var z = math.sin(THREE.MathUtils.degToRad(inclination));
      _sunLight?.position.x = distance * x;
      _sunLight?.position.y = distance * z;
      _sunLight?.position.z = distance * y;

      // _sunLight?.visible = true; //effectController.sun;
      _skyMat?.uniforms['sunPosition']['value'] = _sunLight?.position;
    }
  }

  /// Convert real seconds to game seconds
  /// For exmaple if daylength=2 hours and [amt] = 1 second then returns 12 seconds
  static double realSecondsToGameSeconds(amt) {
    return amt * 24 / daylength;
  }

  /// Is the [time] in the period from night to sunrise?
  static bool isNightSunrise(time) {
    return (time > nightend && time <= sunrise);
  }

  /// Is the [time] betwene sunrise and the start of the day
  static bool isSunriseDay(time) {
    return (time > sunrise && time <= daystart);
  }

  /// Is it day [time]?
  static bool isDay(time) {
    return (time >= daystart && time < dayend);
  }

  /// Is the [time] from the end of the day to sunset
  static bool isDaySunset(time) {
    return (time >= dayend && time < sunset);
  }

  /// Is the [time] after sunset and before the start of night
  static bool isSunsetNight(time) {
    return (time >= sunset && time < nightstart);
  }

  /// Is the [time] night?
  static bool isNight(time) {
    return (time >= nightstart || time < nightend);
  }

  /// Is the [time] between sunrise and sunset?
  static bool isSunRiseSet(time) {
    return (time >= sunrise && time < sunset);
  }
}

/// Procedures related to weather such as wind, cloud, rain and fog
class Weather {
  static double cloud = -1;
  static double newcloud = 0;
  static double oldcloud = 0;
  static int newcloudtick = -1;

  static double wind = -1;
  static double newwind = 0;
  static double oldwind = 0;
  static int newwindtick = -1;

  static double rain = -1;
  static double newrain = 0;
  static double oldrain = 0;
  static int newraintick = -1;
  static List rainlines = [];

  static double fog = -1;
  static double newfog = 0;
  static double oldfog = 0;
  static int newfogtick = -1;
  static bool fogindoors = true;
  static double defaultfognear = 0.01;

  static int weatherchangetime = 30; //000; // 30seconds to change from say 0 wind to 1 wind

  static THREE.Mesh? _clouds;
  static audioplayers.AudioPlayer? _windsound;
  static audioplayers.AudioPlayer? _windsound2;
  static audioplayers.AudioPlayer? _rainsound;
  static audioplayers.AudioPlayer? _rainsound2;

  static double probraintoday = 0.1; // in a given day probability starts
  static double probstopraintoday =
      2; // in a given day if its raining, probability it stops
  static double probfogtoday = 0.1;
  static double probstopfogtoday = 2;
  static double probwindtoday = 0.1;
  static double probstopwindtoday = 2; // in a given day if theres wind, probability it stops
  static double probcloudtoday = 0.1;
  static double probstopcloudtoday = 2;

  static bool lastindoors = false;

  /// Initialise the weather
  /// [clouds] is a plane with clouds texture that can be moved if windy and made more transparent if less cloud
  /// [windsoundpath] is the sound in the assets used for wind
  /// [rainsoundpath] is the sound in the assets used for rain
  static init(clouds, windsoundpath, rainsoundpath) async {
    Weather._clouds = clouds;
    if (clouds != null) {
      _clouds?.visible = false;
    }

    windwasplaying1 = false;
    windwasplaying2 = false;
    rainwasplaying1 = false;
    rainwasplaying2 = false;
    if (windsoundpath != null) {
      _windsound =
          audioplayers.AudioPlayer(); //handleInterruptions: false);//mode: PlayerMode.LOW_LATENCY);
      await _windsound?.setSource(audioplayers.AssetSource(windsoundpath));
      _windsound?.setReleaseMode(audioplayers.ReleaseMode.loop);
      _windsound2 = audioplayers.AudioPlayer();
      await _windsound2?.setSource(audioplayers.AssetSource(windsoundpath));
      _windsound2?.setReleaseMode(audioplayers.ReleaseMode.loop);
      _windsound2?.seek(Duration(seconds: 10));
    }

    if (rainsoundpath != null) {
      _rainsound =
          audioplayers.AudioPlayer(); //handleInterruptions: false);//mode: PlayerMode.LOW_LATENCY);
      await _rainsound?.setSource(audioplayers.AssetSource(rainsoundpath));
      _rainsound?.setReleaseMode(audioplayers.ReleaseMode.loop);

      _rainsound2 =
          audioplayers.AudioPlayer(); //handleInterruptions: false);//mode: PlayerMode.LOW_LATENCY);
      await _rainsound2?.setSource(audioplayers.AssetSource(rainsoundpath));
      _rainsound2?.setReleaseMode(audioplayers.ReleaseMode.loop);
      _rainsound2?.seek(Duration(seconds: 5));
    }

    // Create rain lines
    rainlines = [];
    var points = [];
    points.add(new THREE.Vector3(0, -1, 0));
    points.add(new THREE.Vector3(0, 1, 0));
    var geometryii = new THREE.BufferGeometry().setFromPoints(points);

    for (var i = 0; i < 40; i++) {
      var materiali = new THREE.LineBasicMaterial.fromMap({
        'color': 0x333333,
      }); //888888});
      var line = new THREE.Line(geometryii, materiali);
      materiali.transparent = true;
      materiali.opacity = 0.13;

      line.visible = false;
      //line.scale.setValues(0.1,0.1,0.1);
      line.position = Camera._camera.position.clone();
      line.position.y -= Camera.cameraoffset;
      line.rotation.y = Camera._camera.rotation.y;
      line.translateZ(-0.5);
      line.translateX(1.3 * ((Math.random() - 0.5)));

      Space._scene.add(line);
      rainlines.add(line);
    }

    if (Space?._scene.fog == null) {
      Space?._scene.fog = new THREE.Fog(0xcccccc, defaultfognear, 0);
    }
  }

  /// Set so randomly get weather with varying degrees of probability
  static setRandomWeather() {
    probraintoday = 0.1; // in a given day probability starts
    probstopraintoday =
        1.0; // in a given day if its raining, probability it stops
    probfogtoday = 0.1;
    probstopfogtoday = 6.0; // make it so fog doesn't last too long
    probwindtoday = 0.1;
    probstopwindtoday =
        1.0; // in a given day if theres wind, probability it stops
    probcloudtoday = 0.1;
    probstopcloudtoday = 1.0;
  }

  /// Set so that weather is always clear
  static setClearWeather() {
    probraintoday = 0; //0.1;  // in a given day probability starts
    probstopraintoday =
        0; //2;  // in a given day if its raining, probability it stops
    probfogtoday = 0; //0.1;
    probstopfogtoday = 0; //2;
    probwindtoday = 0; //0.1;
    probstopwindtoday =
        0; //2;  // in a given day if theres wind, probability it stops
    probcloudtoday = 0; //0.1;
    probstopcloudtoday = 0; //2;
  }

  static bool windwasplaying1 = false;
  static bool windwasplaying2 = false;
  static bool rainwasplaying1 = false;
  static bool rainwasplaying2 = false;

  /// Mute the weather sounds
  /// can stop weather sounds when app goes into background and start again when resume
  static mute(mute) {
    if (mute) {
      print("weather mute");
      if (_windsound != null) {
        if (Sound.isPlaying(Weather._windsound!)) {
          //==audioplayers.PlayerState.playing) {
          Weather._windsound!.pause();
          windwasplaying1 = true;
        }
        if (Sound.isPlaying(Weather._windsound2!)) {
          //.state==audioplayers.PlayerState.playing) {
          Weather._windsound2!.pause();
          windwasplaying2 = true;
        }
      }

      if (_rainsound != null) {
        if (Sound.isPlaying(Weather._rainsound!)) {
          //.state==audioplayers.PlayerState.playing) {
          print("pause rain sound");
          Weather._rainsound!.pause();
          rainwasplaying1 = true;
        }
        if (Sound.isPlaying(Weather._rainsound2!)) {
          //.state==audioplayers.PlayerState.playing) {
          print("pause rain2 sound");
          Weather._rainsound2!.pause();
          rainwasplaying2 = true;
        }
      }
    } else {
      print("weather unmute");
      if (windwasplaying1) {
        Weather._windsound!.resume();
        windwasplaying1 = false;
      }
      if (windwasplaying2) {
        Weather._windsound2!.resume();
        windwasplaying2 = false;
      }
      if (rainwasplaying1) {
        print("rain resume");
        Weather._rainsound!.resume();
        rainwasplaying1 = false;
      }
      if (rainwasplaying2) {
        print("rain2 resume");
        Weather._rainsound2!.resume();
        rainwasplaying2 = false;
      }
    }
  }

  /// Set [opacity] of sky - used for fog
  static setSkyOpacity(opacity) {
    Time._skyMat?.transparent = (opacity < 1);
    //if (Time._skyMat?.uniforms!=null)
    Time._skyMat?.uniforms['opacity']['value'] = opacity;
    //    Time._skyMat?.opacity=opacity;//uniforms['opacity']['value'] = opacity;
  }

  /// Change the [cloud] level by changing the cloud materials opacity
  /// Cloud is between 0 and 1
  static cloudChange(cloud) {
    Weather.cloud = cloud.toDouble();
    if (_clouds != null) {
      if (cloud == 0) {
        _clouds?.visible = false;
        print("off cloud");
      } else {
        _clouds?.visible = true;

        var lerp = cloud;

        ///0.5;

        _clouds?.material?.opacity = lerp; //cloud;
      }
    }
  }

  /// Change the new cloud [newcloud] level
  /// Will lerp if cloud has been set before so that cloud level isn't sudden
  static setCloud(newcloud) {
    // print("setcloud"+newcloud.toString()+" "+cloud.toString());
    if (cloud == -1) {
      cloud = newcloud.toDouble();
      Weather.newcloud = newcloud.toDouble();
      cloudChange(cloud);
    } else {
      Weather.newcloud = newcloud.toDouble();
      Weather.oldcloud = Weather.cloud;
      Weather.newcloudtick = System.currentMilliseconds();
    }
  }

  /// Change the volume of the [wind] sound
  /// Have two wind sounds since there is often an issue of a gap in looping audio
  static windSound(wind) {
    if (Weather._windsound != null) {
      Weather._windsound?.setVolume(wind.toDouble());
      if (wind > 0 &&
          Sound.isPlaying(
            Weather._windsound!,
          )) //=audioplayers.PlayerState.playing)
        Weather._windsound?.resume();
      else if (wind == 0 &&
          Sound.isPlaying(
            Weather._windsound!,
          )) //==audioplayers.PlayerState.playing)
        Weather._windsound?.stop();

      Weather._windsound2?.setVolume(wind.toDouble());
      if (wind > 0 &&
          Sound.isPlaying(
            Weather._windsound2!,
          )) //.state!=audioplayers.PlayerState.playing)
        Weather._windsound2?.resume();
      else if (wind == 0 &&
          Sound.isPlaying(
            Weather._windsound2!,
          )) //.state==audioplayers.PlayerState.playing)
        Weather._windsound2?.stop();
    }
  }

  /// Set the wind level [newwind] between 0 and 1
  static setWind(newwind) {
    if (wind == -1) {
      Weather.oldwind = 0;
      Weather.wind = newwind.toDouble();
      Weather.newwind = newwind.toDouble();
      windSound(wind);
    } else {
      Weather.oldwind = wind;
      Weather.newwind = newwind.toDouble();
      Weather.newwindtick = System.currentMilliseconds();
    }
  }

  /// Randomly change the number of rain lines based upon the level of rain
  static rainVisible(rain) {
    for (var line in rainlines) {
      line.visible = Math.random() < rain;
    }
  }

  /// Set the volume of the [rain]
  /// Use two sounds so that don't hear gap between looping sounds
  static rainSound(rain) {
    if (Weather._rainsound != null) {
      Weather._rainsound?.setVolume(rain.toDouble());
      Weather._rainsound2?.setVolume(rain.toDouble());

      if (rain > 0 &&
          Weather._rainsound != null &&
          Weather._rainsound!.state != audioplayers.PlayerState.playing) {
        //   if (wind>0&&!Weather._windsound!.playing)
        Weather._rainsound?.resume();
        print("rain sound resume" + Weather._rainsound!.state.toString());
      } else if (rain == 0 && Sound.isPlaying(Weather._rainsound!)) {
        //.state==audioplayers.PlayerState.playing) {

        Weather._rainsound?.stop();
        print("rain sound stop");
      }

      if (rain > 0 &&
          Weather._rainsound2 != null &&
          Sound.isPlaying(Weather._rainsound2!)) {
        //.state!=audioplayers.PlayerState.playing) {
        Weather._rainsound2?.resume();
        print("rain sound2 resume" + Weather._rainsound2!.state.toString());
      } else if (rain == 0 && Sound.isPlaying(Weather._rainsound2!)) {
        //.state==audioplayers.PlayerState.playing) {

        Weather._rainsound2?.stop();
        print("rain sound2 stop");
      }
    }
  }

  /// Set the level of rain [newrain] between 0 and 1
  static setRain(newrain) {
    if (rain == -1) {
      Weather.rain = newrain.toDouble();
      Weather.newrain = newrain.toDouble();
      rainSound(rain);
      rainVisible(rain);
    } else {
      Weather.newrain = newrain.toDouble();
      Weather.newraintick = System.currentMilliseconds();
      Weather.oldrain = rain;
    }
  }

  /// Display fog with [fog] level and change color depending on time of day
  static changeFog(fog) {
    if (fog == 0) {
      (Space?._scene.fog as THREE.Fog)?.near = defaultfognear;
      (Space?._scene.fog as THREE.Fog)?.far = 0;
      setSkyOpacity(1.0);
    } else {
      // if there is fog there can be no cloud!!
      // transparency of skymat messes up clouds
      if (cloud > 0) {
        cloudChange(0);
        newcloud = 0;
      }
      var far;
      var near;
      if (fog < 0.05) {
        var lerp = fog / 0.05;
        near = (1 - lerp) * 8 + lerp * 4;
        far = (1 - lerp) * 240 + lerp * 120;
      } else if (fog < 0.1) {
        var lerp = (fog - 0.05) / 0.05;
        near = (1 - lerp) * 4 + lerp * 2;
        far = (1 - lerp) * 120 + lerp * 60;
      } else if (fog < 0.5) {
        var lerp = (fog - 0.1) / 0.4;
        near = (1 - lerp) * 2 + lerp * 0.1;
        far = (1 - lerp) * 60 + lerp * 4;
      } else {
        // if (fog<=1) {
        var lerp = (fog - 0.5) / 0.5;
        near = 0.1; //(1-lerp)*2+lerp*0.1;
        far = (1 - lerp) * 4 + lerp * 0.8;
      }
      (Space._scene.fog as THREE.Fog)?.near = near;
      (Space._scene.fog as THREE.Fog)?.far = far;

      if (fog > 0.1) {
        setSkyOpacity(0.0);
        Space._scene.background = (Space._scene.fog as THREE.Fog).color;
      } else {
        // at 0.1 is should be 0.1
        // at 0 should be 1
        Space._scene.background = (Space._scene.fog as THREE.Fog).color;
        var lerp = fog / 0.1;
        setSkyOpacity(1 - lerp);
      }
      var perc = Time.getSunBrightness(Time.time) * 0.8; // cccccc = about 0.8
      Space._scene.fog?.color.red = perc;
      Space._scene.fog?.color.green = perc;
      Space._scene.fog?.color.blue = perc;
    }
    // scene.fog = new THREE.Fog( 0xcccccc, 0.1, 0.8 );//1
    //  scene.fog = new THREE.Fog( 0xcccccc, 0.1, 4 );// 0.5
    //  scene.fog = new THREE.Fog( 0xcccccc, 2, 60 );// 0.1
    //scene.fog = new THREE.Fog( 0xcccccc, 4, 120);//60 );// 0.05
    //scene.fog = new THREE.Fog( 0xcccccc, 8, 240);//60 );// 0.0
  }

  /// Set [newfog] level - will lerp to that new fog
  static setFog(newfog) {
    if (fog == -1) {
      Weather.fog = newfog.toDouble();
      Weather.newfog = newfog.toDouble();
      changeFog(fog);
    } else {
      Weather.newfog = newfog.toDouble();
      Weather.newfogtick = System.currentMilliseconds();
      Weather.oldfog = fog;
    }
  }

  /// Lerp the weather sounds, levels of rain, fog, cloud
  /// Generate random weather based upon probabilities
  /// frametime is the number of seconds since the last frame
  static update(num frameTime) {
    var indoors = You.indoors();
    if (probraintoday > 0 && rain <= 0) {
      if (Math.random() < probraintoday * Time.realSecondsToGameSeconds(frameTime) /
              (24 * 60 * 60)) {
        newrain = Math.random();
        newcloud = Math.random(); // If raining should be cloudy
        setRain(newrain);
        setCloud(newcloud);
        print('rain set' + newrain.toString());
      }
      // frame time is 12 hours then probability is 50%
      // frame time is 6 25
      // frame time is 3 12.5%
    }
    if (probstopraintoday > 0 && rain > 0) {
      if (Math.random() < probstopraintoday * Time.realSecondsToGameSeconds(frameTime) /
              (24 * 60 * 60)) {
        setRain(0);
        print('rain off');
      }
    }

    if (probwindtoday > 0 && wind <= 0) {
      if (Math.random() <
          probwindtoday *
              Time.realSecondsToGameSeconds(frameTime) /
              (24 * 60 * 60)) {
        newwind = Math.random();
        setWind(newwind);
        // If wind then 50% chance there is cloud
        if (Math.random() < 0.5) {
          newcloud = Math.random();
          setCloud(newcloud);
        }
        print('wind set' + newwind.toString());
      }
      // frame time is 12 hours then probability is 50%
      // frame time is 6 25
      // frame time is 3 12.5%
    }
    if (probstopwindtoday > 0 && wind > 0) {
      if (Math.random() <
          probstopwindtoday *
              Time.realSecondsToGameSeconds(frameTime) /
              (24 * 60 * 60)) {
        setWind(0); //newwind=0;
        print('wind off');
      }
    }

    if (probcloudtoday > 0 && cloud <= 0) {
      if (Math.random() <
          probcloudtoday *
              Time.realSecondsToGameSeconds(frameTime) /
              (24 * 60 * 60)) {
        newcloud = Math.random();
        setCloud(newcloud);
        print('cloud set' + newcloud.toString());
      }
      // frame time is 12 hours then probability is 50%
      // frame time is 6 25
      // frame time is 3 12.5%
    }
    if (probstopcloudtoday > 0 && cloud > 0) {
      if (Math.random() <
          probstopcloudtoday *
              Time.realSecondsToGameSeconds(frameTime) /
              (24 * 60 * 60)) {
        setCloud(0);
        print('cloud off');
      }
    }

    if (probfogtoday > 0 && fog <= 0 && cloud <= 0) {
      if (Math.random() <
          probfogtoday *
              Time.realSecondsToGameSeconds(frameTime) /
              (24 * 60 * 60)) {
        newfog = Math.random();
        setFog(newfog);
        print('fog set' + newfog.toString());
      }
      // frame time is 12 hours then probability is 50%
      // frame time is 6 25
      // frame time is 3 12.5%
    }
    if (probstopfogtoday > 0 && fog > 0) {
      if (Math.random() <
          probstopfogtoday *
              Time.realSecondsToGameSeconds(frameTime) /
              (24 * 60 * 60)) {
        setFog(0); //newfog=0;
        print('fog off');
      }
    }

    if (_clouds != null) {
      if (newcloud != cloud) {
        // Take 30 seconds to change to new cloud
        double lerp =
            (System.currentMilliseconds() - Weather.newcloudtick) /
            (weatherchangetime * 1000);
        if (lerp >= 1) {
          Weather.cloudChange(newcloud);
        } else {
          Weather.cloudChange(newcloud * lerp + oldcloud * (1 - lerp));
        }
      }
      if (indoors) {
        if (!lastindoors) {
          // Have gone from outdoors to indoors
          Sound.fadeOut(_windsound!, 1);
          Sound.fadeOut(_windsound2!, 1);
        }
      } else {
        if (indoors != lastindoors && wind > 0) {
          // Have gone from indoors to outdoors
          _windsound?.resume();
          _windsound2?.resume();
          _windsound?.setVolume(wind);
          _windsound2?.setVolume(wind);
          Sound.fadeIn(_windsound!, 1);
          Sound.fadeIn(_windsound2!, 1);
        }
        if (newwind != wind) {
          // Take 30 seconds to change to new cloud
          double lerp =
              (System.currentMilliseconds() - Weather.newwindtick) /
              (weatherchangetime * 1000);
          //  print("lerp"+lerp.toString());
          if (lerp >= 1) {
            wind = newwind;
          } else {
            wind = newwind * lerp + oldwind * (1 - lerp);
          }
          windSound(wind);
        }
      }
      if (wind > 0) {
        _clouds?..material?.map?.offset.y -= wind * frameTime * 0.1; // 0.001;
      }
      if (indoors) {
        if (!lastindoors) {
          // Have gone from outdoors to indoors
          Sound.fadeOut(_rainsound!, 1);
          Sound.fadeOut(_rainsound2!, 1);
          rainVisible(0);
        }
      } else {
        if (indoors != lastindoors && rain > 0) {
          print("from indoors to outdoors" + rain.toString());
          // Have gone from indoors to outdoors
          _rainsound?.resume();
          _rainsound2?.resume();
          _rainsound?.setVolume(rain);
          _rainsound2?.setVolume(rain);
          Sound.fadeIn(_rainsound!, 1);
          Sound.fadeIn(_rainsound2!, 1);

          rainVisible(rain);
        }
        if (newrain != rain) {
          // Take 30 seconds to change to new cloud
          double lerp =
              (System.currentMilliseconds() - Weather.newraintick) /
              (weatherchangetime * 1000);
          if (lerp >= 1) {
            rain = newrain;
          } else {
            rain = newrain * lerp + oldrain * (1 - lerp);
          }
          rainSound(rain);
          rainVisible(rain);
        }
        if (rain > 0) {
          // Set rain lines in front of camera
          for (var line in rainlines) {
            THREE.Vector dog;

            //    line.position
            line.position = Camera._camera.position.clone();
            //line.position.clone(Camera._camera.position);
            line.position.y -= Camera.cameraoffset;
            line.rotation.y = Camera._camera.rotation.y;
            line.translateZ(-0.5);
            line.translateX(1.3 * ((Math.random() - 0.5)));
          }
        }
      }

      if (!fogindoors && You.indoors()) {
      } else if (newfog != fog) {
        // Take 30 seconds to change to new cloud
        double lerp =
            (System.currentMilliseconds() - Weather.newfogtick) /
            (weatherchangetime * 1000);
        if (lerp >= 1) {
          fog = newfog;
        } else {
          fog = newfog * lerp + oldfog * (1 - lerp);
        }
        changeFog(fog);
      }
    }
    lastindoors = indoors;
  }
}

/// Position as specified in config.json
class Position {
  late THREE.Vector3 position;
  late THREE.Object3D? object;
  late Map positionjson;

  Position(x, y) {
    position = THREE.Vector3(x.toDouble(), y.toDouble());
    object = null;
  }
}

/// Load a pool object specified in config.json
/// [poolsize] is how many objects in the pool
/// [maxdistance] is distance where ignore the object if too far away - make zero if no [maxdistance]
/// [name] is the name of the object3d in the pool
/// [positions] is a list of every position of the object - really should be more positions than poolsize otherwise no point
///
class PoolObject {
  late int poolsize;
  late double maxdistance;
  late String name;

  // late List<THREE.Vector3> positions;
  late List<Position> positions;

  // late List<THREE.Vector3> scales;
  late List<THREE.Object3D> objects; // be list of poolsize objects

  double lastfullx = -999;
  double lastfully = -999;

  /// Initialize pool object [Maxdistance] is how far before will display eg if in town dont bother drawing grass
  /// [poolsize] is how many objects in the pool
  /// [name] is the name of the object3d in the pool
  PoolObject(poolsize, name, {maxdistance = 0}) {
    this.poolsize = poolsize;
    this.maxdistance = maxdistance.toDouble();
    this.name = name;
    positions = [];
    // scales=[];
    objects = [];
  }
}

/// Loading and creating objects specified in config file or runtime
/// Allow scene objects to be placed an oriented and is defined in a config file rather than hard coded
/// Also includes poolobjects which allows things like vegetation where rather than define 1000 trees in a forest, define say 20  and have only the closest 20 appear near the camera
/// Poolobjects can also be defined runtime rather than config file and is useful for defining crowds of actors
class Config {
  static Map config = {};

  static List<PoolObject> poolObjects = [];
  static Map<String, List> _objects3dCache = {};

  // You have to move movediff distance before the pool view is updated
  static var movediffx = 1.0;
  static var movediffy = 1.0;

  // You have to move full sort diff before the positions are fully sorted
  static var fullsortdiffx = 5.0;
  static var fullsortdiffy = 5.0;

  static THREE.Group configGroup = THREE.Group();

  /// Load the config file -doesn't load any object3d, just the file
  static loadconfig() async {
    poolObjects = [];
    _objects3dCache = {};
    configGroup.clear();
    final String response = await rootBundle.loadString('assets/config.json');
    config = await json.decode(response);
    // MilkShape animation sets used by .ms3d actors
    Ms3dLoader.loadAnimationSets(config['actoranimations']);
    Space._scene.add(configGroup);
  }

  /// Go through list of positions and get those specified by [name]
  static getStaticPositionByName(name) {
    var items = {};
    items['positions'] = [];
    for (var item in config['positions']['staticpositions'])
      if (item['name'] == name &&
          !(item.containsKey('ignore') && item['ignore']))
        items['positions'].add(item);
    return items;
  }

  /// Get the object specified in config.son specified by [name]
  static getObjectByName(name) {
    for (var item in config['objects'])
      if (item['name'] == name &&
          !(item.containsKey('ignore') && item['ignore']))
        return item;
    return null;
  }

  /// Add a custom [object3d] of [name] to config that are not specified in config.json
  /// Useful if need to create a complicated object that is hard to define in config.json
  static addObject(name, object3d) {
    var mainobject = {};
    mainobject['name'] = name;
    mainobject['object'] = [];
    var object = {'object3d': object3d};
    mainobject['object'].add(object);
    config['objects'].add(mainobject);
  }

  /// Register an already-loaded [object3d] as the template for [name],
  /// skipping the normal type-based loading that getObjects3d() would
  /// otherwise do. Useful when you need custom setup at load time that's
  /// awkward to express purely through config.json - e.g. calling
  /// Actor.createActor() directly with a specific groupname/texture/z
  /// offset, or swapping textures on individual mesh groups after loading.
  ///
  /// [name] must still have a matching entry in config.json's 'objects'
  /// list (e.g. {"type":"actor"}) - its 'type' is what tells createClone()
  /// how to correctly clone this object later (SkeletonUtils.clone for an
  /// actor vs plain .clone() for a model, etc.), even though anything like
  /// filename/texture in that entry goes unused since the normal loading
  /// step is skipped entirely here. This is why addObject() above isn't a
  /// substitute for this - it creates a type-less entry, which would make
  /// createClone() fall back to plain .clone() and silently break skinned/
  /// animated actors.
  static setObject(name, object3d) {
    var mainobjects = Config.getObjectByName(name);
    object3d.extra['object'] = mainobjects['object'][0];
    object3d.extra['configname'] = name;
    _objects3dCache[name] = [object3d];
  }

  /// Look for a preloaded [object3d] from setObject and return its name
  static getObjectName(object3d) {
    for (var name in _objects3dCache.keys) {
      if (_objects3dCache[name]?[0] == object3d) return name;
    }
  }

  /// Look through a set of pool [positions] such as
  /// OPENWORLD.Config.config['positions']['poolpositions'][1]['positions'] looking for a position has a label matching [label]
  static getPositionsByLabel(positions, label) {
    var ret = [];
    for (var position in positions) {
      if (position.containsKey('label') && position['label'] == label)
        ret.add(position);
    }
    return ret;
  }

  /// Go through every object and add them to the scene [parent] based upon their position in the config file
  static createAllObjects(parent) async {
    for (var item in config['objects']) {
      if (!(item.containsKey('ignore') && item['ignore'])) {
        await createStaticObjectsByName(item['name'], parent);
      }
    }
  }

  /// Set the scale of the [clone] as specified by [object3d] and its [position] specified in config.json
  static setScale(object3d, position, clone) {
    var s = object3d.extra['object']['s'] ?? 1.0;
    var sx, sy, sz;
    if (object3d.extra['object'].containsKey('sx'))
      sx = object3d.extra['object']['sx'];
    else
      sx = s;
    if (object3d.extra['object'].containsKey('sy'))
      sy = object3d.extra['object']['sy'];
    else
      sy = s;
    if (object3d.extra['object'].containsKey('sz'))
      sz = object3d.extra['object']['sz'];
    else
      sz = s;

    if (position.containsKey('sx'))
      sx *= position['sx'];
    else if (position.containsKey('s')) {
      sx *= position['s'];
    }
    if (position.containsKey('sy'))
      sy *= position['sy'];
    else if (position.containsKey('s')) {
      sy *= position['s'];
    }
    if (position.containsKey('sz'))
      sz *= position['sz'];
    else if (position.containsKey('s')) {
      sz *= position['s'];
    }
    if (position.containsKey('rs')) {
      var rnd = (1 + Math.random() * position['rs'] - position['rs'] / 2);
      sx *= rnd;
      sy *= rnd;
      sz *= rnd;
    }
    // ?? why must sz and sy be swapped??
    clone.scale.setValues(sx, sz, sy); //sy,sz);
  }

  /// Given the [object3d] and [position] of the object return its overall turn
  static getTurn(object3d, position) //, clone)
  {
    var turn = (object3d.extra['object']['t'] ?? 0.0).toDouble();
    // if (object3d.extra.containsKey['randomturn'])
    //  turn+=Math.random()*object3d.extra['randomturn']-object3d.extra['randomturn']/2;
    if (position.containsKey('rt'))
      turn += Math.random() * position['rt'] - position['rt'] / 2;

    if (position.containsKey('t')) {
      turn += position['t'].toDouble();
    }
    return turn;
    // Space.objTurn(clone, turn);
  }

  /// Given the [object3d] and [position] of the object return its overall pitch
  static getPitch(object3d, position) //, clone)//, {flip:false})
  {
    var turn = 0.0;
    if (object3d.extra['object'].containsKey('pitch'))
      turn = object3d.extra['object']['pitch'].toDouble();

    if (position.containsKey('pitch')) {
      turn += position['pitch'].toDouble();
    }
    return turn;
  }

  /// Given the [object3d] and [position] of the object return its overall roll
  static getRoll(object3d, position) {
    var turn = 0.0;
    if (object3d.extra['object'].containsKey('roll'))
      turn = object3d.extra['object']['roll'].toDouble();

    if (position.containsKey('roll')) {
      turn += position['roll'].toDouble();
    }
    return turn;
  }

  /// Set an [object3d] texture using a config [object]
  static setTexture(object3d, object) {
    if (object.containsKey('emissive')) {
      Texture.setEmissive(
        object3d,
        ColorLib.colorFromHexString(object['emissive']),
      );
    }
    if (object.containsKey('opacity')) {
      Texture.setOpacity(object3d, object['opacity']);
    }
    if (object.containsKey('shininess')) {
      Texture.setShininess(object3d, object['shininess']);
    }
    if (object.containsKey('roughness')) {
      Texture.setRoughness(object3d, object['roughness']);
    }
  }

  /// Given the [name] of the object specified in config.json create that object.
  /// Cached by name - every caller only ever reads from the returned
  /// template to clone from, never mutates it, so it's safe (and much
  /// cheaper) to load each named object once and reuse it for every
  /// static position, pool, and shareanimations lookup that needs it.
  static getObjects3d(name) async {
    if (_objects3dCache.containsKey(name)) return _objects3dCache[name];

    var mainobjects = Config.getObjectByName(name);
    var object3ds = [];

    for (var object in mainobjects['object']) {
      if (!object.containsKey('ignore') || !object['ignore']) {
        var object3d;
        if (object['type'] == 'sprite') {
          var ambient;
          if (object.containsKey('ambient') && !object['ambient'])
            ambient = false;
          else
            ambient = true;

          // Create two sprites if mirror and randomly choose if flip
          var randommirror = false;
          var spriteflip = null;
          if (object.containsKey("randommirroru") && object["randommirroru"]) {
            randommirror = true;
            spriteflip = await Sprite.loadSprite(
              object['texture'],
              object['width'],
              object['height'],
              ambient: ambient,
              flipx: true,
            );
            if (object.containsKey('z'))
              spriteflip.children[0].position.y += object['z'];
          }
          if (!object.containsKey('s')) object['s'] = 1.0;
          object3d = await Sprite.loadSprite(
            object['texture'],
            object['width'],
            object['height'],
            ambient: ambient,
          );
          if (object.containsKey('z'))
            object3d.children[0].position.y += object['z'];
          /*  THREE.SpriteMaterial  mat=object3d.children[0].material;
          mat.color=THREE.Color.fromHex32(0xffffff);
          mat.color=THREE.Color.fromHex32(0xffffff);
          mat.needsUpdate=true;
         // THREE.Texture? map= mat.map;
         // map.op
         object3d.children[0].material.opacity=Math.random();//color.set(0xffffff);//THREE.Color.fromHex32(0xffffff);
          object3d.children[0].material.needsUpdate=true;*/

          object3d.extra['randommirror'] = randommirror;
          object3d.extra['spriteflip'] = spriteflip;
        } else if (object['type'] == 'plane') {
          if (object.containsKey('text')) {
            // Plane with text

            if (!object.containsKey('s')) object['s'] = 1.0;
            Color color;
            if (object.containsKey('color'))
              color = ColorLib.dartColorFromHexString(object['color']);
            else
              color = Colors.white;
            var backgroundcolor;
            if (object.containsKey('backgroundcolor'))
              backgroundcolor = ColorLib.dartColorFromHexString(
                object['backgroundcolor'],
              );
            else
              backgroundcolor = Colors.black;
            setTexture(object3d, object);

            object3d = await Plane.makeTextPlane(
              object['text'],
              color,
              fontSize: object['fontsize'] ?? 20,
              width: object['w'] ?? 200,
              backgroundcolor: backgroundcolor,
              backgroundopacity: object['backgroundopacity'] ?? 1,
            ); //Colors.white);
            if (object.containsKey('z'))
              object3d.children[0].position.y += object['z'];
            if (!object.containsKey("t")) object['t'] = 0;
          } else {
            // Plane without text
            var ambient;
            if (object.containsKey('ambient') && !object['ambient'])
              ambient = false;
            else
              ambient = true;
            if (!object.containsKey('s')) object['s'] = 1.0;
            object3d = await Plane.loadPlane(
              object['texture'],
              object['width'],
              object['height'],
              ambient: ambient,
            );
            if (object.containsKey('z'))
              object3d.children[0].position.y += object['z'];
            if (!object.containsKey("t")) object['t'] = 0;
          }
        } else if (object['type'] == 'model') {
          object3d = await Model.createModel(
            object['filename'],
            texture: object['texture'],
            texturereplace: object['texturereplace'],
            merge: object['merge'],
          ); //, ambient:ambient);
          setTexture(object3d, object);

          if (!object.containsKey('s')) {
            object['s'] = 1.0;
          }

          //   object3d.scale.set(object['s'], object['s'], object['s']);
          if (object.containsKey('z')) object3d.position.y += object['z'];

          if (!object.containsKey("t")) object['t'] = 0;
        } else if (object['type'] == 'actor') {
          var shareanimations;
          if (object.containsKey('shareanimations')) {
            var shareobjects3d = await getObjects3d(object['shareanimations']);
            shareanimations = shareobjects3d[0];
          }

          object3d = await Actor.createActor(
            object['filename'],
            texture: object['texture'],
            action: object['action'] ?? 'idle',
            randomduration: object['randomduration'],
            startat: object['startat'],
            castshadow: object['castshadow'] ?? false,
            shareanimations: shareanimations,
            animations: object['animations'],
            texturereplace: object['texturereplace'],
          );
          setTexture(object3d, object);

          if (!object.containsKey('s')) object['s'] = 1.0;

          if (object.containsKey('z'))
            object3d.children[0].position.y += object['z'];

          if (!object.containsKey("t")) object['t'] = 0;
        } else if (object['type'] == 'pointlight') {
          object3d = THREE.Object3D();
          if (!object.containsKey('color')) object['color'] = "#FFFFFF";
        } else if (object['type'] == 'fire') {
          object3d = THREE.Object3D();
        } else if (object.containsKey('object3d')) {
          // Means is custom object
          object3d = object['object3d'];
        }
        object3d.extra['object'] = object;
        object3d.extra['configname'] = name;
        object3ds.add(object3d);
      }
    }
    _objects3dCache[name] = object3ds;
    return object3ds;
  }

  /// Create a clone of the [object3d] so can create many copies as necessary
  static createClone(THREE.Object3D object3d) async {
    var clone;
    if (object3d.extra['object']['type'] == 'sprite') {
      var useobject;
      var randommirror = object3d.extra['randommirror'];
      var spriteflip = object3d.extra['spriteflip'];

      if (randommirror) {
        if (Math.random() > 0.5)
          useobject = spriteflip;
        else
          useobject = object3d;
      } else
        useobject = object3d;

      clone = await Sprite.cloneSprite(useobject);
    } else if (object3d.extra['object']['type'] == 'plane') {
      clone = object3d.clone();
    } else if (object3d.extra['object']['type'] == 'model') {
      clone = object3d.clone();
    } else if (object3d.extra['object']['type'] == 'actor') {
      // object3d.clone() does not correctly clone a skinned/animated actor -
      // Actor.copyActor() uses SkeletonUtils.clone() and sets up a fresh,
      // independent AnimationMixer per instance (registering it in
      // Actor.actorlist), which is exactly what pooled/static instances need.
      // action:null so it doesn't auto-play anything here - the placement
      // code (createStaticObjectsByName / showPoolsObjects) plays whatever
      // action that specific position calls for right after positioning it.
      clone = await Actor.copyActor(object3d, action: null);
    } else if (object3d.extra['object']['type'] == 'pointlight') {
      THREE.Color color = ColorLib.colorFromHexString(
        object3d.extra['object']['color'],
      ); // int.parse(

      clone = new THREE.PointLight(
        color.getHex(),
      ); //0xFFA500); //PointLight(0xffffff)

      if (object3d.extra['object'].containsKey('intensity'))
        clone.intensity = object3d.extra['object']['intensity'].toDouble();
      if (object3d.extra['object'].containsKey('distance'))
        clone.distance = object3d.extra['object']['distance'].toDouble();
      if (object3d.extra['object'].containsKey('flicker') &&
          object3d.extra['object']['flicker'])
        Light.addFlicker(clone);
      if (object3d.extra['object'].containsKey('nightonly') &&
          object3d.extra['object']['nightonly']) {
        Light.addNightOnly(clone);
      }
    } else if (object3d.extra['object']['type'] == 'fire') {
      var fireWidth = 2;
      var fireHeight = 4;
      var fireDepth = 2;
      var sliceSpacing = 0.5;

      var fire = new VolumetricFire(
        fireWidth,
        fireHeight,
        fireDepth,
        sliceSpacing,
        Camera._camera,
      );
      await fire.init();

      if (object3d.extra['object'].containsKey('s'))
        fire.mesh.scale.setValues(
          object3d.extra['object']['s'],
          object3d.extra['object']['s'],
          object3d.extra['object']['s'],
        );
      if (object3d.extra['object'].containsKey('z')) {
        fire.mesh.position.y = object3d.extra['object']['z'].toDouble();
      }

      Updateables.add(fire);
      var firemesh = fire.mesh;
      var firegroup = THREE.Group();
      firegroup.add(firemesh);
      return firegroup;
    } else {
      // Must be a custom object
      clone = object3d.clone();
    }
    clone.extra['object3d'] = object3d;
    return clone;
  }

  /// Given the [object3d] at [position] as specified in config.json scale and turn the [clone]
  static setScaleTurn(object3d, position, clone) {
    if (object3d.extra['object']['type'] == 'sprite') {
      setScale(object3d, position, clone);
      // What is this for?
      if (position.containsKey('t')) {
        Space.objTurn(clone, position['t'].toDouble());
      }
    } else if (object3d.extra['object']['type'] == 'plane') {
      setScale(object3d, position, clone);

      Space.setTurnPitchRoll(
        clone,
        getTurn(object3d, position),
        getPitch(object3d, position),
        getRoll(object3d, position),
      );
    } else if (object3d.extra['object']['type'] == 'model') {
      setScale(object3d, position, clone);

      Space.setTurnPitchRoll(
        clone,
        getTurn(object3d, position),
        getPitch(object3d, position),
        getRoll(object3d, position),
      );
    } else if (object3d.extra['object']['type'] == 'pointlight') {
    } else if (object3d.extra['object']['type'] == 'fire') {
    } else {
      // Must be a custom object
      //clone = object3d.clone();
      setScale(object3d, position, clone);

      Space.setTurnPitchRoll(
        clone,
        getTurn(object3d, position),
        getPitch(object3d, position),
        getRoll(object3d, position),
      );
    }
  }

  /// Create all the objects in the config file specified by [name] and add them to the scene [parent]
  static createStaticObjectsByName(name, parent) async {
    var starttick = System.currentMilliseconds();
    var items = Config.getStaticPositionByName(name);
    print("get static obj" + name);
    if (items != null && items['positions'].length > 0) {
      print("found pos static obj" + name);

      var objects3d = await getObjects3d(name);

      if (objects3d != null && objects3d.length > 0) {
        print("found obj static obj" + name);
        for (var object3d in objects3d) {
          for (var position in items['positions']) {
            if ((!position.containsKey('ignore') || !position['ignore']) &&
                !(position.containsKey('_placed') && position['_placed'])) {
              position['_placed'] = true;

              var number;
              if (position.containsKey('n'))
                number = position['n'];
              else
                number = 1;
              for (var cnt = 0; cnt < number; cnt++) {
                var clone = await createClone(object3d);
                clone.extra['configname'] = name;
                setScaleTurn(object3d, position, clone);

                if (position.containsKey('rt')) {
                  var rt = position['rt'].toDouble();
                  Space.objTurn(
                    object3d,
                    Space.getObjTurn(object3d) + Math.random() * rt - rt * 0.5,
                  );
                }

                var p = position['p'].toList();
                if (p.length == 2) p.add(0.0);
                if (object3d.extra['object'].containsKey('x'))
                  p[0] += object3d.extra['object']['x'];
                if (object3d.extra['object'].containsKey('y'))
                  p[1] += object3d.extra['object']['y'];

                if (position.containsKey('rx'))
                  p[0] +=
                      (Math.random() * position['rx'] -
                      position['rx'].toDouble() / 2.0);
                if (position.containsKey('ry'))
                  p[1] +=
                      (Math.random() * position['ry'] -
                      position['ry'].toDouble() / 2.0);
                if (position.containsKey('rz'))
                  p[2] +=
                      (Math.random() * position['rz'] -
                      position['rz'].toDouble() / 2.0);

                var normalize2world;
                if (position.containsKey('normalize2world'))
                  normalize2world = position['normalize2world'];
                else
                  normalize2world = false;
                var level = position.containsKey('l')
                    ? (position['l'] as num).toInt()
                    : 0;
                if (position.containsKey("d")) {
                  Space.worldToLocalSurfaceObjHide(
                    clone,
                    p[0].toDouble(),
                    p[1].toDouble(),
                    p[2].toDouble(),
                    position['d'].toDouble(),
                    normalize2world: normalize2world,
                    level: level,
                  );
                } else {
                  Space.worldToLocalSurfaceObj(
                    clone,
                    p[0].toDouble(),
                    p[1].toDouble(),
                    p[2].toDouble(),
                    normalize2world: normalize2world,
                    level: level,
                  );
                }

                parent.add(clone);

                if (object3d.extra['object']['type'] == 'actor') {
                  var actionname =
                      position['action'] ??
                      object3d.extra['object']['action'] ??
                      'idle';
                  var randomduration =
                      position['randomduration'] ??
                      object3d.extra['object']['randomduration'];
                  var startat =
                      position['startat'] ??
                      object3d.extra['object']['startat'];
                  if (Actor.hasAnimation(clone, actionname))
                    await Actor.playAction(
                      clone,
                      action: actionname,
                      randomduration: randomduration,
                      startat: startat,
                      fadein: 0.0,
                    );
                }
              }
            }
          }
        }
      }
    }
    print(
      "config time to load " +
          name +
          " " +
          ((System.currentMilliseconds() - starttick) / 1000.0).toString(),
    );
  }

  /// Given the pool objects specified in config.json create all the positions and the objects in the scene [parent]
  static THREE.Object3D? _lastPoolParent;

  static createPoolObjects() async //parent) async
  {
    var parent = configGroup;
    _lastPoolParent = parent;
    if (config['positions'].containsKey("poolpositions")) {
      for (var item in config['objects']) {
        if (!(item.containsKey('ignore') && item['ignore'])) {
          var name = item['name'];
          print("pool position" + name);
          var poolpositions = config['positions']['poolpositions'];
          for (var poolposition in poolpositions) {
            var poolsize = poolposition['poolsize'];
            var maxdistance = poolposition['maxdistance'];

            for (var position in poolposition['positions']) {
              // position is like  { "name": "grass","p": [ 35.13, 0.13,0.0],  "rx": 30, "ry":30, "rs":0.4, "n": 512 },
              if (position['name'] == name &&
                  !(position.containsKey('ignore') && position['ignore']) &&
                  !(position.containsKey('_pooled') && position['_pooled'])) {
                position['_pooled'] = true;
                // See if exists
                var usePoolObject = null;
                for (var poolObject in poolObjects) {
                  if (poolObject.name == name &&
                      poolObject.poolsize == poolsize) {
                    usePoolObject = poolObject;
                  }
                }
                if (usePoolObject == null) {
                  // Must create one
                  usePoolObject = PoolObject(
                    poolsize,
                    name,
                    maxdistance: maxdistance,
                  );
                  poolObjects.add(usePoolObject);
                }
                if (position.containsKey("marker") &&
                    position['marker'] &&
                    position.containsKey('rx') &&
                    position.containsKey('ry')) {
                  var geometry = THREE.BoxGeometry(0.5, 0.5, 0.5);
                  var material = THREE.MeshBasicMaterial.fromMap({
                    'color': THREE.Color.fromHex32(0x00ff00),
                  });

                  var cube = THREE.Mesh(geometry, material);

                  Space.worldToLocalSurfaceObj(
                    cube,
                    position['p'][0].toDouble(),
                    position['p'][1].toDouble(),
                    0.0,
                  );
                  Space._scene.add(cube);

                  material = THREE.MeshBasicMaterial.fromMap({
                    'color': THREE.Color.fromHex32(0xff0000),
                  });
                  var cubetopleft = THREE.Mesh(geometry, material);
                  Space.worldToLocalSurfaceObj(
                    cubetopleft,
                    position['p'][0].toDouble() - position['rx'] / 2.0,
                    position['p'][1].toDouble() + position['ry'] / 2.0,
                    0.0,
                  );
                  Space._scene.add(cubetopleft);
                  material = THREE.MeshBasicMaterial.fromMap({
                    'color': THREE.Color.fromHex32(0x0000ff),
                  });
                  var cubetopright = THREE.Mesh(geometry, material);
                  Space.worldToLocalSurfaceObj(
                    cubetopright,
                    position['p'][0].toDouble() + position['rx'] / 2.0,
                    position['p'][1].toDouble() + position['ry'] / 2.0,
                    0.0,
                  );
                  Space._scene.add(cubetopright);
                  material = THREE.MeshBasicMaterial.fromMap({
                    'color': THREE.Color.fromHex32(0xffff00),
                  });
                  var cubebottomleft = THREE.Mesh(geometry, material);
                  Space.worldToLocalSurfaceObj(
                    cubebottomleft,
                    position['p'][0].toDouble() - position['rx'] / 2.0,
                    position['p'][1].toDouble() - position['ry'] / 2.0,
                    0.0,
                  );
                  Space._scene.add(cubebottomleft);
                  material = THREE.MeshBasicMaterial.fromMap({
                    'color': THREE.Color.fromHex32(0x00ffff),
                  });
                  var cubebottomright = THREE.Mesh(geometry, material);
                  Space.worldToLocalSurfaceObj(
                    cubebottomright,
                    position['p'][0].toDouble() + position['rx'] / 2.0,
                    position['p'][1].toDouble() - position['ry'] / 2.0,
                    0.0,
                  );
                  Space._scene.add(cubebottomright);
                  material = THREE.MeshBasicMaterial.fromMap({
                    'color': THREE.Color.fromHex32(0xff00ff),
                  });
                  var cubetop = THREE.Mesh(geometry, material);
                  Space.worldToLocalSurfaceObj(
                    cubetop,
                    position['p'][0].toDouble(),
                    position['p'][1].toDouble() + position['ry'] / 2.0,
                    0.0,
                  );
                  Space._scene.add(cubetop);
                  material = THREE.MeshBasicMaterial.fromMap({
                    'color': THREE.Color.fromHex32(0x000000),
                  });
                  var cubeleft = THREE.Mesh(geometry, material);
                  Space.worldToLocalSurfaceObj(
                    cubeleft,
                    position['p'][0].toDouble() - position['rx'] / 2.0,
                    position['p'][1].toDouble(),
                    0.0,
                  );
                  Space._scene.add(cubeleft);
                  material = THREE.MeshBasicMaterial.fromMap({
                    'color': THREE.Color.fromHex32(0xffffff),
                  });
                  var cuberight = THREE.Mesh(geometry, material);
                  Space.worldToLocalSurfaceObj(
                    cuberight,
                    position['p'][0].toDouble() + position['rx'] / 2.0,
                    position['p'][1].toDouble(),
                    0.0,
                  );
                  Space._scene.add(cuberight);
                  material = THREE.MeshBasicMaterial.fromMap({
                    'color': THREE.Color.fromHex32(0x888888),
                  });
                  var cubebottom = THREE.Mesh(geometry, material);
                  Space.worldToLocalSurfaceObj(
                    cubebottom,
                    position['p'][0].toDouble(),
                    position['p'][1].toDouble() - position['ry'] / 2.0,
                    0.0,
                  );
                  Space._scene.add(cubebottom);
                }
                // Generate all the position points
                var n = position['n'] ?? 1;
                for (var i = 0; i < n; i++) {
                  var pos = Position(
                    position['p'][0].toDouble(),
                    position['p'][1].toDouble(),
                  );

                  // var p = position['p'].toList();
                  if (position['p'].length == 2)
                    pos.position.z = 0.0;
                  else
                    pos.position.z = position['p'][2].toDouble();

                  if (position.containsKey('rx'))
                    pos.position.x +=
                        (Math.random() * position['rx'] -
                        position['rx'].toDouble() / 2.0);
                  if (position.containsKey('ry'))
                    pos.position.y +=
                        (Math.random() * position['ry'] -
                        position['ry'].toDouble() / 2.0);
                  if (position.containsKey('rz'))
                    pos.position.z +=
                        (Math.random() * position['rz'] -
                        position['rz'].toDouble() / 2.0);
                  pos.positionjson = position;
                  usePoolObject.positions.add(pos);
                }
              }
            }
          }
        }
      }
      // Get distant names in poolobjects and then create all the pools
      var names = [];
      for (var poolObject in poolObjects) {
        if (!names.contains(poolObject.name)) names.add(poolObject.name);
      }
      for (var name in names) {
        var objects3d = await getObjects3d(name);
        // Need to create clones of poolsize without adding them to the scene
        for (var poolObject in poolObjects) {
          if (poolObject.name == name) {
            var init = poolObject.objects.length;
            for (var i = init; i < poolObject.poolsize; i++) {
              var clone = await createClone(objects3d[0]);
              clone.visible = false;
              poolObject.objects.add(clone);
              parent.add(clone);
            }
          }
        }
      }
      // Force the next showPoolsObjects() call to do a full pass regardless
      // of whether the camera has moved, so anything just added here (or in
      // a prior call) shows up immediately rather than waiting for movement.
      lastx = null;
      lasty = null;
    }
  }

  static double? lastx;
  static double? lasty;

  /// Call this after directly modifying config['positions']['poolpositions']
  /// entries that were already processed by a prior createPoolObjects() call
  /// - whether that's replacing an existing position map wholesale:
  ///   config['positions']['poolpositions'][1]['positions'][0] = {...new map...};
  /// or editing a field on the existing map in place:
  ///   config['positions']['poolpositions'][1]['positions'][0]['action']='idle';
  /// Either way, showPoolsObjects() alone won't pick this up for a position
  /// that's already occupied - it only re-applies a position's data at the
  /// moment an object newly takes that position over, not every frame.
  ///
  /// For a wholesale replacement, whichever object was showing there is
  /// released back to the pool and the replacement map is picked up as a
  /// fresh entry (re-calling createPoolObjects() is safe and cheap here -
  /// its incremental _pooled skip means it only actually does work for
  /// genuinely new/replaced entries). For an in-place edit on a still-
  /// occupied position, its turn/pitch/roll/scale and (if it's an actor)
  /// current action are re-applied directly to whatever's occupying it.
  /// Given a raw position map from config['positions']['poolpositions'][g]
  /// ['positions'][i], find the runtime Position tracking it (matched by
  /// reference, same as updatePoolObjects() uses). Returns null if
  /// createPoolObjects() hasn't processed it yet, or it isn't in any
  /// poolpositions list at all.
  static Position? getPoolPosition(Map positionjson) {
    for (var poolObject in poolObjects) {
      for (var pos in poolObject.positions) {
        if (identical(pos.positionjson, positionjson)) return pos;
      }
    }
    return null;
  }

  /// Whether the given position map currently has an object assigned/shown
  /// - i.e. it's one of the closest poolsize positions right now.
  static bool isPoolPositionVisible(Map positionjson) {
    var pos = getPoolPosition(positionjson);
    return pos != null && pos.object != null;
  }

  /// The object3d clone currently occupying the given position map, or null
  /// if nothing currently occupies it (out of maxdistance range right now,
  /// or createPoolObjects() hasn't processed it yet).
  static THREE.Object3D? getPoolPositionObject(Map positionjson) {
    var pos = getPoolPosition(positionjson);
    return pos?.object;
  }

  /// The reverse of getPoolPositionObject() - given an [object3d] (e.g. the
  /// actor passed into a callbackonvisible/callbackonhide callback), returns
  /// the raw position map it currently occupies, or null if it isn't
  /// currently assigned to any pool position. O(1) - the object is tagged
  /// with its current position at assignment time rather than searched for.
  /// Inside callbackonhide specifically, this still returns the position
  /// the object is in the process of leaving (the tag is cleared right
  /// after that callback runs, not before).
  static Map? getPositionForObject(THREE.Object3D object3d) {
    return object3d.extra['currentpositionjson'];
  }

  static updatePoolObjects() async {
    if (!config['positions'].containsKey("poolpositions")) return;
    if (_lastPoolParent == null) return; // createPoolObjects() hasn't run yet

    // Combine every position map currently present across ALL poolposition
    // groups into one set. Checking against this (rather than one group's
    // list at a time) matters because a Position belonging to group A would
    // otherwise be wrongly treated as "removed" the moment group B's list
    // is the one being checked, even though it never belonged to B at all.
    var allCurrentPositions = <dynamic>{};
    for (var poolposition in config['positions']['poolpositions']) {
      allCurrentPositions.addAll(poolposition['positions']);
    }

    for (var poolObject in poolObjects) {
      for (var i = poolObject.positions.length - 1; i >= 0; i--) {
        var pos = poolObject.positions[i];
        if (!allCurrentPositions.contains(pos.positionjson)) {
          // Removed/replaced entirely - release whatever was occupying it.
          if (pos.object != null) {
            var released = pos.object!;
            pos.object!.extra.remove('hasposition');
            if (pos.positionjson.containsKey('callbackonhide'))
              pos.positionjson['callbackonhide'](released);
            released.extra.remove('currentpositionjson');
          }
          poolObject.positions.removeAt(i);
        } else if (pos.object != null) {
          // Still a valid entry AND still occupied - showPoolsObjects()
          // only re-applies a position's data at the moment an object
          // newly takes it over, so a plain in-place edit here (e.g.
          // changing 'action', 't', or 'p') would otherwise sit unread
          // until this slot happens to cycle out and back in. Re-apply now.

          // Re-derive the world position from 'p' - but only for entries
          // without rx/ry/rz jitter. Those bake a randomized offset into
          // pos.position once at creation time (see the generation loop
          // above); re-deriving here would collapse every jittered
          // instance in that cluster back onto the same unjittered center.
          if (!pos.positionjson.containsKey('rx') &&
              !pos.positionjson.containsKey('ry') &&
              !pos.positionjson.containsKey('rz')) {
            pos.position.x = pos.positionjson['p'][0].toDouble();
            pos.position.y = pos.positionjson['p'][1].toDouble();
            pos.position.z = pos.positionjson['p'].length > 2
                ? pos.positionjson['p'][2].toDouble()
                : 0.0;
          }
          Space.worldToLocalSurfaceObj(
            pos.object!,
            pos.position.x,
            pos.position.y,
            pos.position.z,
            level: pos.positionjson.containsKey('l')
                ? (pos.positionjson['l'] as num).toInt()
                : 0,
          );

          setScaleTurn(
            pos.object!.extra['object3d'],
            pos.positionjson,
            pos.object!,
          );

          if (pos.object!.extra['object3d'].extra['object']['type'] ==
              'actor') {
            var actionname =
                pos.positionjson['action'] ??
                pos.object!.extra['object3d'].extra['object']['action'] ??
                'idle';
            if (Actor.hasAnimation(pos.object!, actionname)) {
              var randomduration =
                  pos.positionjson['randomduration'] ??
                  pos
                      .object!
                      .extra['object3d']
                      .extra['object']['randomduration'];
              var startat =
                  pos.positionjson['startat'] ??
                  pos.object!.extra['object3d'].extra['object']['startat'];
              Actor.playAction(
                pos.object!,
                action: actionname,
                randomduration: randomduration,
                startat: startat,
                stopallactions: true,
                fadein: 0,
                fadeout: 0,
              );
            }
          }
        }
      }
    }

    await createPoolObjects(); //_lastPoolParent);
  }

  static forceShowPoolObjects() {
    lastx = null;
    var worldpos = You.getWorldPos();
    Config.showPoolsObjects(worldpos.x, worldpos.y);
  }

  /// The the players world position [x] [y] display the pool objects around the player
  static showPoolsObjects(x, y) async {
    // print("pool objects"+movediffx.toString()+" "+movediffy.toString()+" "+x.toString()+" "+lastx.toString()+" "+" "+y.toString()+" "+lasty.toString()+" ");
    if (lastx == null ||
        lasty == null ||
        (x - lastx!).abs() > movediffx ||
        (y - lasty!).abs() > movediffy) {
      // print("---------show pool objects");
      for (var poolObject in poolObjects) {
        if (poolObject.positions.length > 0) {
          // if positions is quite small vs the poolsize then always sort it
          if ((x - poolObject.lastfullx).abs() > fullsortdiffx ||
              (y - poolObject.lastfully).abs() > fullsortdiffy ||
              poolObject.positions.length < poolObject.poolsize * 3) {
            poolObject.positions.sort(
              (a, b) => ((a.position.x - x).abs() + (a.position.y - y).abs())
                  .compareTo(
                    (b.position.x - x).abs() + (b.position.y - y).abs(),
                  ),
            );
            poolObject.lastfullx = x;
            poolObject.lastfully = y;
          } else {
            // Dont sort the whole thing if havent moved much
            var positions1 = poolObject.positions.sublist(
              0,
              poolObject.poolsize * 2,
            );
            var positions2 = poolObject.positions.sublist(
              poolObject.poolsize * 2,
            );
            positions1.sort(
              (a, b) => ((a.position.x - x).abs() + (a.position.y - y).abs())
                  .compareTo(
                    (b.position.x - x).abs() + (b.position.y - y).abs(),
                  ),
            );
            poolObject.positions = positions1 + positions2;
          }
          // if have maxdistance and positions too far away dont bother
          if (poolObject.maxdistance == 0 ||
              Math.vectorDistance(
                    THREE.Vector3(
                      poolObject.positions[0].position.x,
                      poolObject.positions[0].position.y,
                    ),
                    THREE.Vector3(x, y),
                  ) <
                  poolObject.maxdistance) {
            // Go through all the distances greater than pool size and remove
            for (
              var i = poolObject.poolsize;
              i < poolObject.positions.length;
              i++
            ) {
              if (poolObject.positions[i].object != null) {
                var released = poolObject.positions[i].object!;
                poolObject.positions[i].object!.extra.remove('hasposition');
                poolObject.positions[i].object = null;
                var releasedjson = poolObject.positions[i].positionjson;
                if (releasedjson.containsKey('callbackonhide'))
                  releasedjson['callbackonhide'](released);
                released.extra.remove('currentpositionjson');
              }
            }

            // Find those in the poolsize that haven't been added
            var inc = 0;
            for (var i = 0; i < poolObject.poolsize; i++) {
              //final object = poolObject.positions[i].object;
              if (i < poolObject.positions.length &&
                  poolObject.positions[i].object == null) {
                innerloop:
                for (var j = inc; j < poolObject.objects.length; j++) {
                  if (!poolObject.objects[j].extra.containsKey('hasposition')) {
                    // Use this one
                    //  print("have added position");
                    poolObject.objects[j].extra['hasposition'] = true;
                    poolObject.positions[i].object = poolObject.objects[j];
                    var positionjson = poolObject.positions[i].positionjson;
                    poolObject.objects[j].extra['currentpositionjson'] =
                        positionjson;
                    setScaleTurn(
                      poolObject.objects[j].extra['object3d'],
                      positionjson,
                      poolObject.objects[j],
                    );

                    Space.worldToLocalSurfaceObj(
                      poolObject.objects[j],
                      poolObject.positions[i].position.x,
                      poolObject.positions[i].position.y,
                      poolObject.positions[i].position.z,
                      level: positionjson.containsKey('l')
                          ? (positionjson['l'] as num).toInt()
                          : 0,
                    );

                    // Actors: get the correct animation actually applied to
                    // the skeleton BEFORE this object is made visible. If we
                    // set visible=true first and let playAction resolve
                    // later (it's async, and its pose only actually applies
                    // on the mixer's NEXT update tick), the object renders
                    // one or more frames in its previous pose / bind pose
                    // first and then visibly pops into the right one -
                    // this is exactly the bug we're fixing here.
                    if (poolObject
                            .objects[j]
                            .extra['object3d']
                            .extra['object']['type'] ==
                        'actor') {
                      var actionname =
                          positionjson['action'] ??
                          poolObject
                              .objects[j]
                              .extra['object3d']
                              .extra['object']['action'] ??
                          'idle';
                      if (Actor.hasAnimation(
                        poolObject.objects[j],
                        actionname,
                      )) {
                        var randomduration =
                            positionjson['randomduration'] ??
                            poolObject
                                .objects[j]
                                .extra['object3d']
                                .extra['object']['randomduration'];
                        var startat =
                            positionjson['startat'] ??
                            poolObject
                                .objects[j]
                                .extra['object3d']
                                .extra['object']['startat'];
                        var action = await Actor.playAction(
                          poolObject.objects[j],
                          action: actionname,
                          randomduration: randomduration,
                          startat: startat,
                          stopallactions: true,
                          fadein: 0,
                          fadeout: 0,
                        );
                        // Force the mixer to apply this pose right now
                        // rather than waiting for the next Updateables
                        // .update() tick, which might not happen until
                        // after this frame has already rendered.
                        var updatepos;
                        if (startat != null)
                          updatepos = Actor.getActionStartat(
                            action,
                            startat,
                            null,
                          );
                        else
                          updatepos = 0.0;
                        //  print("mmmm"+updatepos.toString());
                        // action.startAt(actionstartat);
                        poolObject.objects[j].extra['mixer'].update(
                          updatepos,
                        ); //0.0);
                      }
                    }

                    if (positionjson.containsKey('lerpopacity') &&
                        (positionjson['lerpopacity'] as num) > 0) {
                      // Force opacity to 0 first regardless of whether this
                      // object was already visible elsewhere a moment ago
                      // (a reused pool clone never actually goes invisible
                      // between positions, so without this the "fade" would
                      // start from whatever opacity it already had - i.e.
                      // no visible fade at all on reuse).
                      Texture.cloneMaterialsForFade(poolObject.objects[j]);
                      Texture.setOpacity(poolObject.objects[j], 0.0);
                      poolObject.objects[j].visible = true;
                      Texture.opacityLerp(
                        poolObject.objects[j],
                        1.0,
                        (positionjson['lerpopacity'] as num).toDouble(),
                      );
                    } else {
                      poolObject.objects[j].visible = true;
                    }

                    if (positionjson.containsKey('callbackonvisible'))
                      positionjson['callbackonvisible'](poolObject.objects[j]);

                    inc = j + 1;
                    break innerloop;
                  }
                }
              }
            }
          }
        }
      }
      lastx = x;
      lasty = y;
    }
  }
}

/// Mob procedures specifically for NPC's such as walking around, showing speech text for NPC
class Mob {
  static List chatterlist = [];
  static List speechlist = [];
  static var movetohiddenlist = {};
  static var movetoloopbnextlist = {};
  static bool colorfromname = false;

  static int LoopTypeRestart =
      0; // Means when reach the end of movetoloop positions go back to the start but walking there
  static int LoopTypeReverseLoop =
      1; // Means when reach the end of movetoloop positions just repeat in reverse
  static int LoopTypeStop =
      2; // Means when reach the end of movetoloop positions stop

  /// Give the npc [object] a name [mobname]
  static setName(object, mobname) {
    object.extra['mobname'] = mobname;
  }

  /// So know original facing direction of [object] if set to facing the player eg faceobjectalways
  static setInitTurn(object, turn) {
    object.extra['origturn'] = turn.toDouble();
    Space.objTurn(object, turn.toDouble());
  }

  /// Get the original [object] facing direction with {def} angle if not found
  static getInitTurn(object, {def}) {
    if (object.extra.containsKey('origturn'))
      return object.extra['origturn'];
    else
      return def;
  }

  /// Get the name of the NPC [object]
  static getName(object) {
    if (object.extra.containsKey('mobname'))
      return object.extra['mobname'];
    else
      return "";
  }

  /// Place multiple text sprite on a NPC [object] eg  'E' keypress in bold and then the action text in a different font
  /// [texts] is an array of Maps that include the text to be drawn, font, size, padding etc
  /// [z] is how high the text should be
  /// [y] how far forward or back. Negative means forward (eg -100)
  /// [x] how left or right. Negative means left
  /// [scale] is scale of the text generated
  static setMultiText(
    THREE.Object3D object,
    List<Map> texts, {
    scale,
    x = 0,
    y = 0,
    z = 50,
  }) async {
    var spritey = await Sprite.makeMultiTextSprite(texts, scale:scale, x: x, y: y, z: z);

    if (spritey != null) {
      /*if (scale != null) {
        spritey.scale.x = spritey.scale.x * scale;
        spritey.scale.y = spritey.scale.y * scale;
      }*/
      // Remove any other text
      if (object.extra.containsKey('namesprite')) {
        object.remove(object.extra['namesprite']);
      }
      object.extra['namesprite'] = spritey;
      object.add(spritey);
    }
  }

  /// Place text on an NPC
  /// [msg] what NPC should say
  /// [textcolor] for color of text and if not specified will use npcs name as a seed to get a random color
  /// [z] is how high the text should be
  /// [y] how far forward or back. Negative means forward (eg -100)
  /// [x] how left or right. Negative means left
  /// [width] is how wide the chat is for the npc
  /// [scale] is scale of the text generated
  /// [width] is how wide the text should be
  /// Set the [scale] of the text
  /// Set the [backgroundcolor] of the text
  /// Set the  opacity [backgroundopacity] of the backgroundcolor
  /// How much padding for the text on [paddingLeft], [paddingRight], [paddingTop] , [paddingBottom] side
  /// [tails] draws the little speech bubble tail on the text so looks like its being spoken and include 'bottomleft', 'bottomcenter', 'bottomright'
  /// [fontfamily] of the text
  static setText(
    THREE.Object3D object,
    msg, {
    textcolor = null,
    fontSize = 20,
    z = 50,
    y = 0.0,
    x = 0.0,
    width = 200,
    scale,
    backgroundcolor,
    backgroundopacity,
    fontfamily,
    paddingLeft = 0.0,
    paddingRight = 0.0,
    paddingTop = 0.0,
    paddingBottom = 0.0,
    tails,
    delay,
  }) async {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        setText(
          object,
          msg,
          textcolor: textcolor,
          fontSize: fontSize,
          z: z,
          y: y,
          x: x,
          width: width,
          scale: scale,
          backgroundcolor: backgroundcolor,
          backgroundopacity: backgroundopacity,
          fontfamily: fontfamily,
          paddingLeft: paddingLeft,
          paddingRight: paddingRight,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
          tails: tails,
        );
      });
      BaseObject.addTimer(object, t);
    } else {
      if (textcolor == null) {
        if (colorfromname && Mob.getName(object) != "")
          textcolor = ColorLib.colorFromText(Mob.getName(object));
        else
          textcolor = Colors.white;
      }

      if (backgroundcolor == null) backgroundcolor = Colors.black;
      if (backgroundopacity == null) backgroundopacity = 0.5;
      var spritey = await Sprite.makeTextSprite(
        msg,
        textcolor,
        fontSize: fontSize,
        z: z,
        y: y,
        x: x,
        width: width,
        backgroundcolor: backgroundcolor,
        backgroundopacity: backgroundopacity,
        fontfamily: fontfamily,
        paddingLeft: paddingLeft,
        paddingRight: paddingRight,
        paddingTop: paddingTop,
        paddingBottom: paddingBottom,
        tails: tails,
      );

      if (spritey != null) {
        if (scale != null) {
          spritey.scale.x = spritey.scale.x * scale;
          spritey.scale.y = spritey.scale.y * scale;
        }
        // Remove any other text
        if (object.extra.containsKey('namesprite')) {
          object.remove(object.extra['namesprite']);
        }
        object.extra['namesprite'] = spritey;
        object.add(spritey);
      }
    }
  }

  /// Remove text from NPC [object]
  static clearText(object, {delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        clearText(object);
      });
      BaseObject.addTimer(object, t);
    } else {
      if (object.extra.containsKey('namesprite')) {
        object.remove(object.extra['namesprite']);
        object.extra.remove('namesprite');
      }
    }
  }

  /// Get the sprite text of an [object]
  static getTextSprite(object) {
    if (object.extra.containsKey('namesprite'))
      return object.extra['namesprite'];
  }

  /// Set the random chatter for an npc picking random line from chatter at random intervals [randwait]
  /// The [chatter] is a list of text strings that will randomly pick from
  /// [randwait] is the number of seconds wait for next chatter between 0 and randwait. [minwait] is minimum wait
  /// [start] specifies if begin chatter straight away
  /// [z] is how high the chat should be on npc
  /// [width] is how wide the chat is for the npc
  /// Set the [scale] of the text
  /// [delay] seconds before start the chatter
  static setChatter(
    object,
    chatter, {
    randwait = 20,
    minwait = 5,
    start = true,
    z = 50,
    width = 200,
    scale,
    delay,
  }) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        setChatter(
          object,
          chatter,
          randwait: randwait,
          minwait: minwait,
          start: start,
          z: z,
          width: width,
          scale: scale,
        );
      });
      BaseObject.addTimer(object, t);
    } else {
      object.extra['chatter'] = chatter;
      object.extra['chatterrandwait'] = randwait;
      object.extra['chatterminwait'] = minwait;
      if (start)
        object.extra['nextchatter'] = randomNextChat(object);
      else
        object.extra['nextchatter'] = -1;
      object.extra['chatterz'] = z;
      object.extra['chatterwidth'] = width;
      object.extra['chatterscale'] = scale;
      if (!chatterlist.contains(object)) chatterlist.add(object);
    }
  }

  /// Based upon the chat randwait and minwait randomly gets a time for the next chat in the future for the NPC
  static randomNextChat(object) {
    return System.currentMilliseconds() +
        Math.random() * object.extra['chatterrandwait'] * 1000 +
        object.extra['chatterminwait'] * 1000;
  }

  /// Stop the chatter for the [object] NPC
  static pauseChatter(object) {
    object.extra['nextchatter'] = -1;
  }

  static startChatter(object) {
    object.extra['nextchatter'] = randomNextChat(object);
  }

  static nextChatter() {
    for (var i = chatterlist.length - 1; i >= 0; i--) {
      var obj = chatterlist[i];
      if (obj == null) {
        chatterlist.remove(obj);
      } else if (obj.visible && obj.extra['nextchatter'] != -1) {
        if (System.currentMilliseconds() >= obj.extra['nextchatter']) {
          obj.extra['nextchatter'] = randomNextChat(obj);
          return {
            "object": obj,
            "chatter":
                obj.extra['chatter'][(Math.random() *
                        obj.extra['chatter'].length)
                    .floor()],
            'z': obj.extra['chatterz'],
            'width': obj.extra['chatterwidth'],
            'scale': obj.extra['chatterscale'],
          };
        }
      }
    }
    return null;
  }


  // Convert text [input] into NPC speech/chatter chunks so that fits well into setSpeech
  static List<String> chopText(
    String input, {
    int minWords = 3,
    int maxWords = 7,
  }) {
    // Split into punctuation fragments, keeping punctuation.
    // The * keeps things like "..." together.
    final fragmentRegex = RegExp(r'[^,?.!;:]+[,?.!;:]*');

    final fragments = fragmentRegex
        .allMatches(input)
        .map((m) => m.group(0)!.trim())
        .where((s) => s.isNotEmpty);

    final List<String> finalLines = [];

    int wordCount(String s) {
      if (s.trim().isEmpty) return 0;
      return s.trim().split(RegExp(r'\s+')).length;
    }

    String joinFragments(String a, String b) {
      if (a.isEmpty) return b;
      return '$a $b';
    }

    List<String> splitBalanced(String text) {
      final words = text.trim().split(RegExp(r'\s+'));

      if (words.length <= maxWords) {
        return [text.trim()];
      }

      final chunkCount = (words.length / maxWords).ceil();
      final baseSize = words.length ~/ chunkCount;
      final remainder = words.length % chunkCount;

      final List<String> chunks = [];
      var index = 0;

      for (var i = 0; i < chunkCount; i++) {
        final size = baseSize + (i < remainder ? 1 : 0);
        chunks.add(words.sublist(index, index + size).join(' '));
        index += size;
      }

      return chunks;
    }

    String current = '';
    int currentWords = 0;

    void flush() {
      if (current.trim().isNotEmpty) {
        finalLines.add(current.trim());
        current = '';
        currentWords = 0;
      }
    }

    for (final fragment in fragments) {
      final fragmentWords = wordCount(fragment);

      if (current.isEmpty) {
        if (fragmentWords > maxWords) {
          finalLines.addAll(splitBalanced(fragment));
        } else {
          current = fragment;
          currentWords = fragmentWords;
        }
        continue;
      }

      final combined = joinFragments(current, fragment);
      final combinedWords = currentWords + fragmentWords;

      // If the current line is still very short, prefer combining.
      if (currentWords < minWords) {
        if (combinedWords > maxWords) {
          finalLines.addAll(splitBalanced(combined));
          current = '';
          currentWords = 0;
        } else {
          current = combined;
          currentWords = combinedWords;
        }

        continue;
      }

      // If adding the fragment would make the line too long,
      // split before this fragment.
      if (combinedWords > maxWords) {
        flush();

        if (fragmentWords > maxWords) {
          finalLines.addAll(splitBalanced(fragment));
        } else {
          current = fragment;
          currentWords = fragmentWords;
        }
      } else {
        current = combined;
        currentWords = combinedWords;
      }

      if (currentWords == maxWords) {
        flush();
      }
    }

    flush();

    return finalLines;
  }

  /// Say a speech specified by the text array [chatter] doing line by line in [chatter] with [wait] interval
  /// [wait] is the number of seconds wait for next speech line
  /// [z] is how high the chat should be on npc
  /// [y] how far forward or back. Negative means forward (eg -100)
  /// [x] how left or right. Negative means left
  /// [width] is how wide the chat is for the npc
  /// [scale] is scale of the text generated
  /// How much padding for the text on [paddingLeft], [paddingRight], [paddingTop] , [paddingBottom] side
  /// [tails] draws the little speech bubble tail on the text so looks like its being spoken and include 'bottomleft', 'bottomcenter', 'bottomright'
  /// [delay] is how many seconds before start the speech
  static setSpeech(
    object,
    chatter, {
    randwait = 10,
    minwait = 5,
    x = 0.0,
    y = 0.0,
     z = 50,
     width = 200, scale, clearwhendone = false,
    paddingLeft = 10,
    paddingRight = 10,
    paddingTop = 0.0,
    paddingBottom = 0.0,
    callbackonfinish,
    tails,
    delay,
  }) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        setSpeech(
          object,
          chatter,
          minwait: minwait,
          randwait: randwait,
          x:x,
          y: y,
          z: z,
          width: width,
          scale: scale,
          clearwhendone: clearwhendone,
          paddingLeft: paddingLeft,
          paddingRight: paddingRight,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
          callbackonfinish: callbackonfinish,
          tails: tails,
        );
      });
      BaseObject.addTimer(object, t);
    } else if (object!=null) {
      pauseChatter(object);
      object.extra['speech'] = chatter;
      object.extra['speechrandwait'] = randwait;
      object.extra['speechminwait'] = minwait;
      object.extra['speechpos'] = 0;
      object.extra['nextspeech'] =
          System.currentMilliseconds(); //nextSpeech(object);
      object.extra['speechx'] = x;
      object.extra['speechy'] = y;
      object.extra['speechz'] = z;
      object.extra['speechwidth'] = width;
      object.extra['speechscale'] = scale;
      object.extra['speechpaddingleft'] = paddingLeft;
      object.extra['speechpaddingright'] = paddingRight;
      object.extra['speechpaddingtop'] = paddingTop;
      object.extra['speechpaddingbottom'] = paddingBottom;
      object.extra['speechtails'] = tails;
      //  object.extra['speechscale'] = scale;
      object.extra['speechclearwhendone'] = clearwhendone;
      object.extra['speechcallbackonfinish'] = callbackonfinish;
      speechlist.add(object);
    } else
      print("setspeech obj null"+chatter.toString());
    if (randwait == 0) {
      if (delay == null) delay = 0;
      return delay + chatter.length * minwait;
    } else
      return -1;
  }

  /// Pause the speech of the npc [object]
  static pauseSpeech(object) {
    object.extra['nextspeech'] = -1;
    // In case still a callback that might get called - remove it
    if (object.extra.containsKey('speechcallbackonfinish'))
      object.extra.remove('speechcallbackonfinish');
  }

  static nextSpeechTime(object) {
    return System.currentMilliseconds() +
        Math.random() * object.extra['speechrandwait'] * 1000 +
        object.extra['speechminwait'] * 1000;
  }

  /// Get the next line in the speech if the correct amount of time has passed
  static nextSpeech() {
    for (var i = speechlist.length - 1; i >= 0; i--) {
      var obj = speechlist[i];
      if (obj == null) {
        chatterlist.remove(obj);
      } else if (obj.visible && obj.extra['nextspeech'] != -1) {
        if (System.currentMilliseconds() >= obj.extra['nextspeech']) {
          var ret = {
            "object": obj,
            "chatter": obj.extra['speech'][obj.extra['speechpos']],
            'z': obj.extra['speechz'],
            'y': obj.extra['speechy'],
            'x': obj.extra['speechx'],
            'width': obj.extra['speechwidth'],
            'scale': obj.extra['speechscale'],
            'clearwhendone': obj.extra['speechclearwhendone'],
            'paddingleft': obj.extra['speechpaddingleft'],
            'paddingright': obj.extra['speechpaddingright'],
            'paddingtop': obj.extra['speechpaddingtop'],
            'paddingbottom': obj.extra['speechpaddingbottom'],
            'tails': obj.extra['speechtails'],
          };
          obj.extra['speechpos']++;
          if (obj.extra['speechpos'] < obj.extra['speech'].length)
            obj.extra['nextspeech'] = nextSpeechTime(obj);
          else {
            obj.extra['nextspeech'] = -1;
            // nextSpeechTime(object)
          }
          return ret;
        }
      }
    }
    return null;
  }

  /// Have [actor] loop between points in [positions] looping through all the positions.
  /// Eg if want to have an npc walk up and down a street
  /// Also includes actions so can walk do an action, then walk again
  /// moveToLoop stops if actor stops being visible so if lots of npcs dont have huge number walking when not visible
  /// It will restart once the actor becomes visible again
  ///
  /// [positions] is       {'p':[x,y,z],'v':0.2,'action':'washhip','time':5, 'l':0,'duration':null, 'z':0.1,'t':90,'callback':func}
  /// [action] is what animation action such as walking should be done while moving
  /// [facedir] makes actor face in the direction they're walking
  /// [facenow] when start the loop have the actor face in the direction travelling straight away
  /// [randomposition] means actor will start at a random point in the positions array otherwise they start from the beginning every time
  /// [reverseloop] instead of going through positions one by one to the end and then back to the first, instead goes in reverse when get to the end of the positions
  /// [surfaceonly] means will always check the terrain when moving - useful if walking over hilly terrain - stop walking through a hill
  /// [hidedist] if hide distance not set then set it to this
  /// [fadeOut] time in seconds for any actions in the move to loop
  /// [normalize2world] if you want the actor to be normal to the terrain eg like a car correctly pitched on a terrain slope
  /// So that animations aren't always the same making actors move in unison use [randomduration] to add small variations. 0.1 will change the duration by a random value within 10%
  /// [looptype] is   LoopTypeRestart Means when reach the end of movetoloop positions go back to the start but walking there
  ///                 LoopTypeReverseLoop Means when reach the end of movetoloop positions just repeat in reverse
  ///                 LoopTypeStop   Means when reach the end of movetoloop positions stop
  /// [level] of surface the actor moves on - can be overridden in [positions]
  /// [lerpopacity] is time to fade when actor is away from the camera
  static moveToLoop(
    actor, List<Map> positions, {action, facedir = true, facenow, index = 0, id = -1, randomposition = false,
    surfaceonly, fadeout = 0.5, normalize2world, randomduration, looptype, duration,
    hidedist = 5,
    level = 0,
    lerpopacity = 1.0,
  }) {
    if (positions.length <= 1) {
      print(
        "movetoloop positions is length" +
            positions.length.toString() +
            " so halting",
      );
      return;
    }

    if ((id != -1 && actor.extra['movetoid'] != id) ||
        !System.active /*||!actor.visible*/ ) {
      // have overriden with another moveto
      print("done movetoloop");
      return;
    }
    var totaltime = 0.0;

    // var isnew=id==-1;
    var originalloc;
    if (id == -1) {
      positions = positions
          .toList(); // moveToLoop shouldn't be modifying the original list so use a copy
      movetoloopbnextlist.remove(actor);
      print(
        "init movetoloop" +
            index.toString() +
            " " +
            positions.length.toString() +
            " " +
            BaseObject.getName(actor),
      );

      // If actor isn't in hide, then add it if default hidedist is set
      if (hidedist != null && hidedist > 0 && !Space.objIsHide(actor)) {
        Space.readdObjFromHide(actor, dist: hidedist);
        print(
          "actor movetoloop readd from hide " +
              BaseObject.getName(actor) +
              " " +
              hidedist.toString(),
        );
      } else if (Space.objIsHide(actor))
        print("actor movetoloop is hide" + BaseObject.getName(actor));

      if (lerpopacity != null) actor.extra['lerpopacity'] = lerpopacity;

      // Stop any existing animation if it is running and are setting a new animation
      if (action != null) {
        THREE.AnimationAction? currentaction = Actor.getActiveAction(actor);
        if (currentaction != null) currentaction.fadeOut(fadeout);
      }
      // If an action entry doesn't contain time then work it out
      for (var i = 0; i < positions.length; i++) {
        if (!positions[i].containsKey("p") &&
            !positions[i].containsKey("time")) {
          if (positions[i].containsKey('duration'))
            positions[i]['time'] = positions[i]['duration'];
          else if (positions[i].containsKey('action')) {
            THREE.AnimationAction actionii = Actor.getAction(
              actor,
              name: positions[i]['action'],
            );
            positions[i]['time'] = actionii.getClip().duration;
          }
        }
      }
      if (looptype != null && looptype == LoopTypeReverseLoop) {
        for (var i = positions.length - 2; i >= 0; i--) {
          positions.add(positions[i]);
        }
      }

      // Type with position
      //               [newposx,newposy,0.0, speed,action, duration, turn];
      // Type without position   - z used so you can lerp the bather up and down
      //                  action time duration z    turn
      // eg           [ "washhip",5,   null,   0.1,  90],
      // {'p':[x,y,z],'v':0.2,'action':'washhip','time':5, 'duration':null, 'z':0.1,'t':90,'callback':func}
      //var fakedist=0.001;
      var useind = 0;
      var nextind = -1;
      //  var fakedist=0.001;
      //      var fakedist=0.01;
      // var hasanim=false;
      // if (positions[0][0] is String ) {
      if (!positions[0].containsKey("p")) {
        // if (positions[0].containsKey("action")  ) {
        var actioni = positions[0]['action']; //[0]
        var t = positions[0]['time']; //[1]
        // var speed=fakedist/t;
        // If you start off with just actions then you use the current position of the actor - in fact, if just an action then will always use its current position
        var actorpos = Space.localToWorldObj(actor);

        var newposx = actorpos.x; //pos[0];
        var newposy = actorpos.y; //pos[1];
        var newposz;
        if (positions[0].containsKey('z')) {
          //        if (positions[0].length>3) {
          newposz = positions[0]['z']; // z
          //          newposz= positions[0][3]; // z
        } else
          newposz = 0.0;

        var newl;
        if (positions[0].containsKey('l')) {
          newl = positions[0]['l']; // ;
        } else
          newl = level;
        var newpos = {
          "p": [newposx, newposy, newposz],
          "v": -1,
          "l": newl,
          "time": t,
          "action": actioni,
        };
        //        var newpos= {"p":[newposx,newposy,newposz], "v":speed,"action":action};
        var useduration = duration;
        if (positions[0].containsKey('duration') &&
            positions[0]['duration'] != null) {
          //        if (positions[0].length>2) {
          useduration = positions[0]['duration']; //[2];
          newpos['duration'] = useduration;
          // newpos.add(duration);
        }
        if (positions[0].containsKey('startat') &&
            positions[0]['startat'] != null) {
          // if (positions[0].length>4) {
          var startat = positions[0]['startat']; //[4];
          newpos['startat'] = startat;
          //  newpos.add(turn);
        }
        if (positions[0].containsKey('t') && positions[0]['t'] != null) {
          // if (positions[0].length>4) {
          var turn = positions[0]['t']; //[4];
          newpos['t'] = turn;
          //  newpos.add(turn);
        }
        if (positions[0].containsKey('callback')) {
          newpos['callback'] = positions[0]['callback'];
        }
        // var newpos= [-16.76+fakedist, -45.33,0.0, speed,action];
        positions[0] = newpos;
      }
      for (var i = 1; i < positions.length; i++) {
        if (!positions[i].containsKey("p")) {
          //        if (positions[i].containsKey("action")  ) {
          // if (positions[i][0] is String ) {
          //  hasanim=true;
          if (nextind == -1) {
            for (var j = i + 1; j < positions.length; j++) {
              if (nextind == -1 && !(positions[j].containsKey('action')))
                //  if (nextind==-1&&!(positions[j][0] is String))
                nextind = j;
            }
          }
          if (nextind == -1) nextind = 0;
          // var action=positions[i]['p'];//0];
          var actioni = positions[i]['action']; //0];
          var t = positions[i]['time']; //[1];
          /* if (positions[i].length>2)
             duration=positions[i][2];
           else
             duration=null;*/
          //  var speed=fakedist/t;
          var l;
          if (positions[i - 1].containsKey('l'))
            l = positions[i - 1]['l'];
          else
            l = level;
          var newpos = {
            "p": [
              positions[i - 1]['p'][0].toDouble(),
              positions[i - 1]['p'][1].toDouble(),
              positions[i - 1]['p'][2].toDouble(),
            ],
            "l": l,
            "v": -1,
            "time": t,
            "action": actioni,
          }; //,duration];
          //var newpos={"p":[positions[i-1]['p'][0].toDouble(),positions[i-1]['p'][1].toDouble(),positions[i-1]['p'][2].toDouble()], "v":speed,"action":action};//,duration];
          //          var newpos=[positions[i-1][0].toDouble(),positions[i-1][1].toDouble(),positions[i-1][2].toDouble(), speed,action];//,duration];
          /* if (nextind==-1) {
             newpos[0] += fakedist;
             print("no nextind");
           } else {*/
          /*  var angle =Math.getAngleBetweenPoints(THREE.Vector3(positions[useind]['p'][0].toDouble(),positions[useind]['p'][1].toDouble(),0.0),THREE.Vector3(positions[nextind]['p'][0].toDouble(),positions[nextind]['p'][1].toDouble(),0.0));
        //  var angle =Math.getAngleBetweenPoints(THREE.Vector3(positions[useind][0].toDouble(),positions[useind][1].toDouble(),0.0),THREE.Vector3(positions[nextind][0].toDouble(),positions[nextind][1].toDouble(),0.0));
             //print("angggle"+angle.toString());
          THREE.Vector2 pos=Math.vectorMoveForward(positions[i-1]['p'][0].toDouble(),positions[i-1]['p'][1].toDouble(),  angle,  fakedist);
         // THREE.Vector2 pos=Math.vectorMoveForward(positions[i-1][0].toDouble(),positions[i-1][1].toDouble(),  angle,  fakedist);
          newpos['p'][0]=pos[0];
          newpos['p'][1]=pos[1]; */
          //newpos[0]=pos[0];
          // newpos[1]=pos[1];
          //   }

          if (positions[i].containsKey("duration") &&
              positions[i]['duration'] != null) {
            //  if (positions[i].length>2) {
            var useduration = positions[i]['duration']; //[2];
            newpos['duration'] = useduration;
            //             newpos.add(duration);
          }
          if (positions[i].containsKey('startat')) {
            var startat = positions[i]['startat']; //[4];
            newpos['startat'] = startat;
            // newpos.add(turn);
          }
          if (positions[i].containsKey('z')) {
            //          if (positions[i].length>3) {
            //  newpos[2]= positions[i][3]; // z
            newpos['p'][2] = positions[i]['z']; // z
          } else
            newpos['p'][2] = positions[useind]['p'][2];
          //             newpos[2]= positions[useind][2];
          // if (positions[i].length>4) {
          if (positions[i].containsKey('t')) {
            var turn = positions[i]['t']; //[4];
            newpos['t'] = turn;
            // newpos.add(turn);
          }
          if (positions[i].containsKey('callback')) {
            newpos['callback'] = positions[i]['callback'];
          }

          positions[i] = newpos;
          //  print("neewwwwpos"+newpos.toString());
          // fakedist+=0.001;
        } else {
          useind = i;
          nextind = -1;
        }
      }

      //  print("movetoloop"+positions.toString()+" "+BaseObject.getName(actor));
      // if loop go back to original position
      id = (Math.random() * 10000).floor();
      actor.extra['movetoid'] = id;
      /* with movetohidden this should not be necessary should it?
     if (actor.extra.containsKey('movetoloopindex')) {
         print("set to has loop index"+BaseObject.getName(actor));

        // If restarting moveloop then put the index back to what it was so can continue loop
        index=actor.extra['movetoloopindex'];
      } else*/
      if (randomposition) {
        print("random index" + BaseObject.getName(actor));

        // Pick a random position index
        var initindex = Math.randInt(positions.length - 1);
        var posa = positions[initindex];
        if (initindex == positions.length - 1) {
          index = 0;
        } else {
          index = initindex + 1;
        }
        // Get the one after it
        var posb = positions[index];

        var l;
        if (positions[index].containsKey('l'))
          l = positions[index]['l'];
        else
          l = level;
        double lerp = Math.random();
        //  print("random index lerp"+lerp.toString()+" "+posa.toString()+" "+posb.toString());
        var randx = (1 - lerp) * posa['p'][0] + lerp * posb['p'][0];
        var randy = (1 - lerp) * posa['p'][1] + lerp * posb['p'][1];
        var randz = (1 - lerp) * posa['p'][2] + lerp * posb['p'][2];
        //  actor.extra['movetolooprandpos']=THREE.Vector3(randx,randy,randz);
        Space.worldToLocalSurfaceObj(
          actor,
          randx,
          randy,
          randz,
          level: l,
          normalize2world: normalize2world,
        );
        /*          Space.worldToLocalSurfaceObj(
              actor, (1 - lerp) * posa[0] + lerp * posb[0],
              (1 - lerp) * posa[1] + lerp * posb[1],
              (1 - lerp) * posa[2] + lerp * posb[2], level:level);*/
        // In case first positions item contains a callback
        if (positions[index].containsKey('callback')) {
          positions[index]['callback'](actor);
          //  print("movedtoloop callback");
        }
      } else {
        //  print("set to first loc"+index.toString());
        // Means set the actor to the first position and set the index to the next position
        var l;
        if (positions[index].containsKey('l'))
          l = positions[index]['l'];
        else
          l = level;
        Space.worldToLocalSurfaceObj(
          actor,
          positions[index]['p'][0].toDouble(),
          positions[index]['p'][1].toDouble(),
          positions[index]['p'][2].toDouble(),
          level: l,
          normalize2world: normalize2world,
        );
        //        Space.worldToLocalSurfaceObj(actor, positions[index][0].toDouble(),positions[index][1].toDouble(),positions[index][2].toDouble(), level:level);
        // In case first positions item contains a callback
        if (positions[index].containsKey('callback')) {
          positions[index]['callback'](actor);
        }
        index++;
      }
      originalloc = Space.localToWorld(
        actor.position.x,
        actor.position.y,
        actor.position.z,
      );
      ;
    } else // not id==-1
      originalloc = Space.localToWorld(
        actor.position.x,
        actor.position.y,
        actor.position.z,
      );

    //if (actor.extra.containsKey('walker'))
    //   print("xxxxyyy"+positions.length.toString());
    // Get the total time for a loop
    totaltime = 0.0;
    for (var i = 0; i < positions.length; i++) {
      var time;
      var speed;
      if (!positions[i].containsKey('time') || positions[i]['time'] == null) {
        if (positions[i].containsKey('v'))
          speed = positions[i]['v'].toDouble(); // m/s
        else
          speed = 0.2;
        var dist;
        if (i == 0)
          dist = Math.vectorDistance(
            THREE.Vector3(originalloc.x, originalloc.y, 0),
            THREE.Vector3(
              positions[i]['p'][0].toDouble(),
              positions[i]['p'][1].toDouble(),
              0,
            ),
          );
        else if (i < positions.length - 1)
          dist = Math.vectorDistance(
            THREE.Vector3(
              positions[i]['p'][0].toDouble(),
              positions[i]['p'][1].toDouble(),
              0,
            ),
            THREE.Vector3(
              positions[i + 1]['p'][0].toDouble(),
              positions[i + 1]['p'][1].toDouble(),
              0,
            ),
          );
        else if (looptype == null || looptype == Mob.LoopTypeRestart)
          dist = Math.vectorDistance(
            THREE.Vector3(
              positions[i]['p'][0].toDouble(),
              positions[i]['p'][1].toDouble(),
              0,
            ),
            THREE.Vector3(
              positions[0]['p'][0].toDouble(),
              positions[0]['p'][1].toDouble(),
              0,
            ),
          );
        else
          dist = 0;
        time = dist / speed;
      } else
        time = positions[i]['time'];
      if (time != null) totaltime += time;
    }
    actor.extra['movetoloopindex'] = index;

    var speed;
    if (positions.length == 0)
      print("eRRR moveToLoop has no positions!!");
    else if (index >= positions.length)
      print(
        "eRRR moveToLoop" +
            index.toString() +
            " " +
            positions.length.toString() +
            " " +
            BaseObject.getName(actor),
      );
    var time;
    if (!positions[index].containsKey('time') ||
        positions[index]['time'] == null) {
      if (positions[index].containsKey('v'))
        //    if (positions[index].length>=3)
        speed = positions[index]['v'].toDouble(); // m/s
      //   speed=positions[index][3].toDouble(); // m/s
      else
        speed = 0.2;
      var dist = Math.vectorDistance(
        THREE.Vector3(originalloc.x, originalloc.y, 0),
        THREE.Vector3(
          positions[index]['p'][0].toDouble(),
          positions[index]['p'][1].toDouble(),
          0,
        ),
      );
      //        THREE.Vector3(positions[index ][0].toDouble(), positions[index ][1].toDouble(), 0));

      // print("speed"+speed.toString()+" dit"+dist.toString()+" "+index.toString()+" "+originalloc.x.toString()+" "+originalloc.y.toString());

      time = dist / speed;
    } else
      time = positions[index]['time']; // get rid of the need for fakedist
    var l;
    if (positions[index].containsKey('l'))
      l = positions[index]['l'];
    else
      l = level;
    if (!positions[index].containsKey('time') ||
        positions[index]['time'] == null) {
      // Dont move if just waiting
      //   print("movetolerp occured"+BaseObject.getName(actor));
      if (surfaceonly != null && surfaceonly)
        Space.worldToLocalSurfaceOnlyObjLerp(
          actor,
          positions[index]['p'][0].toDouble(),
          positions[index]['p'][1].toDouble(),
          positions[index]['p'][2].toDouble(),
          time.toDouble(),
          normalize2world: normalize2world,
          /*normalize2world:normalize2world,*/ level: l,
        );
      // Space.worldToLocalSurfaceOnlyObjLerp(actor,positions[index][0].toDouble(),positions[index][1].toDouble(),positions[index][2].toDouble(),time.toDouble()/*,normalize2world:normalize2world*/, level:level);
      else
        Space.worldToLocalSurfaceObjLerp(
          actor,
          positions[index]['p'][0].toDouble(),
          positions[index]['p'][1].toDouble(),
          positions[index]['p'][2].toDouble(),
          time.toDouble(),
          level: l,
        );
    } else {
      print(
        "no movetolerp" +
            positions[index].toString() +
            " " +
            BaseObject.getName(actor),
      );
    }
    //      Space.worldToLocalSurfaceObjLerp(actor,positions[index][0].toDouble(),positions[index][1].toDouble(),positions[index][2].toDouble(),time.toDouble(),level:level);
    if (positions[index].containsKey('t')) {
      print("movetoploop positionst turn");
      Space.objTurnLerp(
        actor,
        positions[index]['t'].toDouble(),
        1,
        normalize2world: normalize2world,
      );
    } else if (facenow != null && facenow) {
      print(
        "movetoploop facepoint" + BaseObject.getName(actor),
      ); //+" "+ Space.localToWorldObj(actor).toString()+" "+positions[index]['p'].toString()+" "+positions.toString());

      Space.facePoint(
        actor,
        positions[index]['p'][0].toDouble(),
        positions[index]['p'][1].toDouble(),
        normalize2world: normalize2world,
      );
      //      Space.facePoint(actor,positions[index][0].toDouble(),positions[index][1].toDouble());
    } else if (facedir) {
      //   print("movetoploop facedir"+BaseObject.getName(actor)+" "+ Space.localToWorldObj(actor).toString()+" "+positions[index]['p'].toString());
      //if (isnew)
      //   Space.facePoint(actor, positions[index]['p'][0].toDouble(),
      //      positions[index]['p'][1].toDouble());
      // else
      // stop case where actor is at the next position exactly therefore cannot get facing direction from it because right on top of it
      var actorpos = Space.localToWorldObj(actor);
      if (Math.vectorDistance(
            THREE.Vector3(actorpos.x, actorpos.y, 0.0),
            THREE.Vector3(
              positions[index]['p'][0].toDouble(),
              positions[index]['p'][1].toDouble(),
              0.0,
            ),
          ) >
          0.05) {
        // if (BaseObject.getName(actor)=='donkeygroup3i')
        //   print("donkey facedir in moveto");
        Space.facePointLerp(
          actor,
          positions[index]['p'][0].toDouble(),
          positions[index]['p'][1].toDouble(),
          1,
          normalize2world: normalize2world,
        );
      }
    }
    //      Space.facePointLerp(actor,positions[index][0].toDouble(),positions[index][1].toDouble(),1);
    var useaction;
    if (positions[index].containsKey('action'))
      //    if (positions[index].length>=5)
      useaction = positions[index]['action'];
    //      useaction=positions[index][4];
    else
      useaction = action;
    var useduration;
    if (positions[index].containsKey('duration') &&
        positions[index]['duration'] != null)
      useduration = positions[index]['duration'];
    //if (positions[index].length>=6)
    //  useduration=positions[index][5];
    else
      useduration = duration;
    var usestartat;
    if (positions[index].containsKey('startat') &&
        positions[index]['startat'] != null)
      usestartat = positions[index]['startat'];
    else
      usestartat = null;
    if (useaction != null) {
      //await Actor.getAction(actor, name: action).reset().play();
      THREE.AnimationAction actionii = Actor.getAction(
        actor,
        name: useaction,
        duration: useduration,
        randomduration: randomduration,
        clampWhenFinished: true,
        startat: usestartat,
      );
      if (actor.extra.containsKey('movetoloopaction') &&
          actor.extra['movetoloopaction'] != actionii) {
        //print("movetoloop fadeout"+fadeout.toString());
        actor.extra['movetoloopaction'].fadeOut(fadeout); //0.5);
      }

      if (actionii == null)
        print("move to loop action error" + useaction.toString());
      //  print("setting actor movetoloop "+useaction);
      actionii.reset().play();
      Actor.fadeOutAll(actor, fadeout, excludeaction: actionii);
      actor.extra['movetoloopaction'] = actionii;
    }
    movetoloopbnextlist[actor] = {
      "positions": positions,
      "action": action,
      "facedir": facedir,
      "facenow": facenow,
      "looptype": looptype,
      "hidedist": hidedist,
      "id": id,
      "surfaceonly": surfaceonly,
      "duration": duration,
      "fadeout": fadeout,
      "randomduration": randomduration,
      "index": index,
      "level": level,
      "normalize2world": normalize2world,
      "starttime": System.currentMilliseconds(),
      "currenttime": System.currentMilliseconds(),
      "time": time,
    }; //""nexttime":System.currentMilliseconds()+time*1000};
    //if (BaseObject.getName(actor)=='yourfriend')
    //   print("vooat"+movetoloopbnextlist[actor].toString());
    /*var t= Timer(new Duration(milliseconds: (time * 1000).floor()), () async {
      // cancel started an new one
      if (actor.visible && id == actor.extra['movetoid']) {
        if (positions[index].containsKey('callback')) {
          positions[index]['callback'](actor);
        //  print("movedtoloop callback");
        }

       // print("movetoloop timer"+time.toString()+" "+BaseObject.getName(actor)+" "+Space.objIsHide(actor).toString());
        if (index + 1 < positions.length) {
          moveToLoop(actor, positions, action: action,
              facedir: facedir,
              id: id,
              surfaceonly: surfaceonly, /*normalize2world:normalize2world,*/ duration:duration,fadeout:fadeout,randomduration: randomduration, looptype:looptype,
              index: index + 1, level:level);
        } else  {
          if (looptype==null||(looptype!=LoopTypeStop)) {
            moveToLoop(actor, positions, action: action,
            facedir: facedir,
            id: id,
            surfaceonly: surfaceonly,/* normalize2world:normalize2world,*/ duration:duration,fadeout:fadeout,randomduration: randomduration,
            index: 0, level:level);
          }  else {

          }

        }
      } else {
        // now that no longer visible keep a copy so can reactivate once visible
        var idx;
        if (index + 1 < positions.length)
          idx=index+1;
        else
          idx=0;
        var movetohidden = {"positions":positions,"action":action,"facedir":facedir,"id":id, "surfaceonly":surfaceonly,"duration":duration,"fadeout":fadeout,
          "randomduration":randomduration, "index":idx, "level":level};
        movetohiddenlist[actor]=movetohidden;

      }
    });
    BaseObject.addTimer(actor, t);
*/
    return totaltime;
  }


  // Used by moveToLoop to do the next position or action
  static moveToLoopNext(
    actor,
    List<Map> positions, {
    action,
    facedir,
    facenow,
    index,
    id,
    /*randomposition,*/ surfaceonly,
    fadeout,
    randomduration,
    looptype,
    duration,
    hidedist,
    level,
    normalize2world,
  }) {
    if (actor.visible && id == actor.extra['movetoid']) {
      if (positions[index].containsKey('callback')) {
        positions[index]['callback'](actor);
        //  print("movedtoloop callback");
      }

      print(
        "movetoloop next timer" +
            BaseObject.getName(actor) +
            " " +
            Space.objIsHide(actor).toString() +
            " index" +
            index.toString() +
            " " +
            positions.length.toString() +
            " looptype" +
            looptype.toString(),
      );
      if (index + 1 < positions.length) {
        moveToLoop(
          actor,
          positions,
          action: action,
          facedir: facedir,
          id: id,
          surfaceonly: surfaceonly,
          duration: duration,
          fadeout: fadeout,
          randomduration: randomduration,
          looptype: looptype,
          index: index + 1,
          level: level,
          normalize2world: normalize2world,
        );
      } else {
        // finished
        if (looptype == null || (looptype != LoopTypeStop)) {
          moveToLoop(
            actor,
            positions,
            action: action,
            facedir: facedir,
            id: id,
            surfaceonly: surfaceonly,
            duration: duration,
            fadeout: fadeout,
            randomduration: randomduration,
            index: 0,
            level: level,
            normalize2world: normalize2world,
          );
        } else {}
      }
    } else {
      // now that no longer visible keep a copy so can reactivate once visible
      print(
        "moveto hidden in next" +
            BaseObject.getName(actor) +
            " " +
            actor.visible.toString() +
            " " +
            id.toString() +
            " " +
            actor.extra['movetoid'].toString() +
            " looptype" +
            looptype.toString(),
      );
      var idx;
      if (index + 1 < positions.length)
        idx = index + 1;
      else
        idx = 0;
      var movetohidden = {
        "positions": positions,
        "action": action,
        "facedir": facedir,
        "id": id,
        "surfaceonly": surfaceonly,
        "duration": duration,
        "fadeout": fadeout,
        "randomduration": randomduration,
        "index": idx,
        "level": level,
        "normalize2world": normalize2world,
        "looptype": looptype,
      };
      movetohiddenlist[actor] = movetohidden;
    }
  }

  /// Remove the [actor] from the moveToLoop
  static removeObjectFromMoveTo(actor) {
    movetoloopbnextlist.remove(actor);
  }

  /// Is the [actor] in moveToLoop?
  static isInMoveTo(actor) {
    return movetoloopbnextlist.containsKey(actor);
  }

  /// By default randomwalk rememembers where the [actor] last was so when reappears is in last spot that moved
  /// This resets the randomwalk for the [actor]
  static resetrandomwalk(actor) {
    if (actor.extra.containsKey('randomwalkinitpos'))
      actor.extra.remove('randomwalkinitpos');

    if (actor.extra.containsKey('randomwalkx')) {
      actor.extra.remove('randomwalkx');
      actor.extra.remove('randomwalky');
    }
    if (actor.extra.containsKey('randomwalkhasreset'))
      actor.extra.remove('randomwalkhasreset');
  }

  /// Have [actor] walk randomly from where they currently are to a distance within [distfrominit] with [speed] m/s.
  /// This RELIES on a distance trigger since if the actor is not visible it will stop working - unlike moveToLoop!
  /// For example a sheep just randomly walking around a field
  /// Randomwalk stops if actor stops being visible so if lots of npcs dont have huge number walking when not visible
  /// [walkingchance] the percent of time walking rather than standing idling
  /// [action] is the action the [actor] does while moving eg walking and [actionduration] is how long to do the action in seconds
  /// [stopaction] is the action the [actor] does when stops eg idle
  /// [reset] means dont lerp from initial position instead just instantly set a new position
  /// [z] is how high from surface that move
  /// [surfaceonly] means will always check the terrain when moving - useful if walking over hilly terrain - stop walking through a hill

  static randomwalk(
    actor,
    distfrominit,
    speed,
    walkingchance, {
    action,
    actionduration,
    stopaction,
    id = -1,
    reset = false,
    z,
    surfaceonly,
  }) async {
    if (id != -1 && !actor.extra.containsKey('movetoidrand')) {
      // means completely cleared random walk
      print("cleared randomwalk");
      return;
    }
    if ((id != -1 && actor.extra['movetoidrand'] != id) || !System.active) {
      print(
        "done random moveto" +
            actor.extra['movetoidrand'].toString() +
            " id" +
            id.toString() +
            " " +
            System.active.toString(),
      );

      // Issue where if restarts randomwalk then you get gliding
      if (stopaction != null) {
        print("stop walk action randomwalk" + stopaction);
        (await Actor.getAction(
          actor,
          name: stopaction,
          stopallactions: true,
        )).reset().play();
      }
      return;
    }
    var originalloc;
    if (z == null) z = 0;
    if (id == -1) {
      Space.removeObjectFromLerp(actor);
      id = (Math.random() * 10000).floor();
      actor.extra['movetoidrand'] = id;
      if (actor.extra.containsKey('randomwalkinitpos'))
        originalloc = actor.extra['randomwalkinitpos'];
      else {
        originalloc = Space.localToWorld(
          actor.position.x,
          actor.position.y,
          actor.position.z,
        );
        actor.extra['randomwalkinitpos'] = originalloc;
      }

      if (stopaction != null) {
        // stop actor walking on the spot if become unhidden
        print("randomwalk stop action");
        (await Actor.getAction(
          actor,
          name: stopaction,
          stopallactions: true,
        )).reset().play();
      }
      if (actor.extra.containsKey('randomwalkx')) {
        // If hidden and now reappears then put back where it was last
        Space.worldToLocalSurfaceObj(
          actor,
          actor.extra['randomwalkx'].toDouble(),
          actor.extra['randomwalky'].toDouble(),
          z.toDouble(),
        );
      } else if (reset) {
        // Only reset once so doenst jump around when go near it again
        if (!actor.extra.containsKey('randomwalkhasreset')) {
          var randx = originalloc.x + 2 * (Math.random() - 0.5) * distfrominit;
          var randy = originalloc.y + 2 * (Math.random() - 0.5) * distfrominit;
          Space.worldToLocalSurfaceObj(actor, randx, randy, z.toDouble());
          actor.extra['randomwalkhasreset'] = true;
        }
      }
      if (walkingchance < 1) {
        var t = new Timer(
          new Duration(milliseconds: (Math.random() * 10 * 1000).floor()),
          () async {
            randomwalk(
              actor,
              distfrominit,
              speed,
              walkingchance,
              action: action,
              actionduration: actionduration,
              stopaction: stopaction,
              surfaceonly: surfaceonly,
              id: id,
              z: z,
            );
          },
        );
        BaseObject.addTimer(actor, t);
        return;
      }
    } else {
      originalloc = actor.extra['randomwalkinitpos'];
    }
    var randx = originalloc.x + 2 * (Math.random() - 0.5) * distfrominit;
    var randy = originalloc.y + 2 * (Math.random() - 0.5) * distfrominit;
    moveTo(
      actor,
      [
        [randx, randy, z, speed],
      ],
      action: action,
      actionduration: actionduration,
      stopaction: stopaction,
      surfaceonly: surfaceonly,
    );

    var dist = Math.vectorDistance(
      THREE.Vector3(originalloc.x, originalloc.y, 0),
      THREE.Vector3(randx, randy, 0),
    );
    var time = dist / speed;
    var t = new Timer(
      new Duration(milliseconds: (time * 1000).floor()),
      () async {
        // cancel started an new one
        if (actor.visible && id == actor.extra['movetoidrand']) {
          if (walkingchance < 1) {
            // if walk took 5 second then if 10% chance walk then should wait for 50 seconds
            var waittime = time / walkingchance;
            new Timer(
              new Duration(milliseconds: (waittime * 1000).floor()),
              () async {
                randomwalk(
                  actor,
                  distfrominit,
                  speed,
                  walkingchance,
                  action: action,
                  actionduration: actionduration,
                  stopaction: stopaction,
                  id: id,
                  z: z,
                  surfaceonly: surfaceonly,
                );
              },
            );
          } else
            randomwalk(
              actor,
              distfrominit,
              speed,
              walkingchance,
              action: action,
              actionduration: actionduration,
              stopaction: stopaction,
              id: id,
              z: z,
              surfaceonly: surfaceonly,
            );
        } else if (actor.extra.containsKey('movetoidrand')) {
          //if 'movetoidrand' removed then means completely kill random walk
          if (stopaction != null) {
            print(
              "stop walk actioniirandomwalk " +
                  stopaction +
                  "id" +
                  id.toString() +
                  ' ' +
                  actor.extra['movetoidrand'].toString(),
            );
            var worldpos = Space.localToWorldObj(actor);
            actor.extra['randomwalkx'] = worldpos.x;
            actor.extra['randomwalky'] = worldpos.y;
            Space.removeObjectFromLerp(actor);
            (await Actor.getAction(
              actor,
              name: stopaction,
              stopallactions: true,
            )).reset().play();
          }
        }
      },
    );
    BaseObject.addTimer(actor, t);
  }

  /// Move an [actor] through list of [positions]  world coordinates, if a forth coordinate is specified it is the speed the move otherwise use 0.2 m/s
  /// Each position is made up of [x,y,z,v,turn, level]  - it is different to moveToLoop which uses a Map of values rather than a list of arrays
  /// [action] is the action the [actor] does while moving eg walking with duration [actionduration]
  /// [facedir] is whether the [actor] faces in the direction moving through the [positions]
  /// When gone through the [positions] what is the [stopaction] when stops eg idle taking [stopactionduration] seconds if set
  /// [surfaceonly] means that the [actor] will not simply lerp from one point in [positions] to another but also check the surface terrain - useful if walking over bumpy terrain
  /// [reset] means dont lerp from initial position instead just instantly set to the first position in positions
  /// [callbackonfinish] is called when the [actor] reaches its final point as callbackonfinish(actor)
  /// [delay] is how many seconds before start moving
  /// Returns how long it takes in seconds to reach the final position
  static moveTo(
    actor,
    List<List> positions, {
    action,
    actionduration,
    actionrandomduration,
    facedir = true,
    stopaction,
    stopactionduration,
    index = 0,
    id = -1,
    surfaceonly,
    reset,
    callbackonfinish,
    normalize2world = false,
    level = 0,
    delay,
  }) async {
    var totaltime = -1.0;
    if (id == -1) {
      totaltime = 0;
      if (delay != null) {
        double del = delay.toDouble();
        totaltime += del; // as double;
      }
      var speed;
      var originalloc;
      if (reset == null || !reset)
        originalloc = Space.localToWorld(
          actor.position.x,
          actor.position.y,
          actor.position.z,
        );
      else {
        originalloc = THREE.Vector3(positions[0][0], positions[0][1], 0);
        Space.worldToLocalSurfaceObj(
          actor,
          positions[0][0],
          positions[0][1],
          0.0,
          normalize2world: normalize2world,
          level: level,
        );
      }
      for (var i = 0; i < positions.length; i++) {
        if (positions[index].length <= 3)
          speed = 0.2;
        else
          speed = positions[index][3].toDouble(); // m/s
        var dist;
        if (i == 0)
          dist = Math.vectorDistance(
            THREE.Vector3(originalloc.x, originalloc.y, 0),
            THREE.Vector3(
              positions[i][0].toDouble(),
              positions[i][1].toDouble(),
              0,
            ),
          );
        else
          dist = Math.vectorDistance(
            THREE.Vector3(
              positions[i][0].toDouble(),
              positions[i][1].toDouble(),
              0,
            ),
            THREE.Vector3(
              positions[i - 1][0].toDouble(),
              positions[i - 1][1].toDouble(),
              0,
            ),
          );
        var time = dist / speed;
        totaltime += time;
      }
    }
    if (delay != null) {
      // The reason this is here is because you need to return total time so that know how long it takes to get to the position
      Timer t = Timer(Duration(milliseconds: (delay * 1000).floor()), () {
        moveTo(
          actor,
          positions,
          action: action,
          actionduration: actionduration,
          actionrandomduration: actionrandomduration,
          facedir: facedir,
          stopaction: stopaction,
          stopactionduration: stopactionduration,
          surfaceonly: surfaceonly,
          callbackonfinish: callbackonfinish,
          normalize2world: normalize2world,
          level: level,
        );
      });
      BaseObject.addTimer(actor, t);
      // return totaltime+delay;
    } else {
      if (id != -1 && actor.extra['movetoid'] != id) {
        // have overriden with another moveto
        print("done moveto");
        return;
      }

      if (id == -1) {
        print("init moveto.." + BaseObject.getName(actor));
        // if loop go back to original position

        //  positions.insert(0, [originalloc.x,originalloc.y,positions[positions.length-1][2],positions[positions.length-1][3]]);
        //  index++;
        id = (Math.random() * 10000).floor();
        actor.extra['movetoid'] = id;
      }
      // print("uuu"+positions.length.toString()+" "+index.toString());
      if (positions[index].length <= 2) positions[index].add(0.0);
      var speed;
      if (positions[index].length <= 3)
        speed = 0.2;
      else
        speed = positions[index][3].toDouble(); // m/s
      var originalloc = Space.localToWorld(
        actor.position.x,
        actor.position.y,
        actor.position.z,
      );
      var dist = Math.vectorDistance(
        THREE.Vector3(originalloc.x, originalloc.y, 0),
        THREE.Vector3(
          positions[index][0].toDouble(),
          positions[index][1].toDouble(),
          0,
        ),
      );

      var time = dist / speed;
      /*print("moveto" + time.toString() + " d" + dist.toString() + " s" +
          speed.toString() + " o" + originalloc.x.toString() + " " +
          originalloc.y.toString() + " p" + positions[index][0].toString() +
          " " + positions[index][1].toString() + " " +
          positions[index][2].toString()+" surface"+surfaceonly.toString());*/
      var uselevel;
      //  print("level "+level.toString()+" "+positions.toString()+" "+index.toString()+" "+positions[index].length.toString());
      if (positions[index].length >= 6)
        uselevel = positions[index][5].toInt(); //Double();
      else
        uselevel = level;
      if (surfaceonly != null && surfaceonly)
        Space.worldToLocalSurfaceOnlyObjLerp(
          actor,
          positions[index][0].toDouble(),
          positions[index][1].toDouble(),
          positions[index][2].toDouble(),
          time,
          normalize2world: normalize2world,
          level: uselevel,
        );
      else
        Space.worldToLocalSurfaceObjLerp(
          actor,
          positions[index][0].toDouble(),
          positions[index][1].toDouble(),
          positions[index][2].toDouble(),
          time,
          level: uselevel,
        );

      if (positions[index].length >= 5 && positions[index][4] != null) {
        print("moveto positions turn 5");
        Space.objTurnLerp(
          actor,
          positions[index][4].toDouble(),
          1,
          normalize2world: normalize2world,
        );
      } else if (facedir) {
        print("moveto facepoint lerp" + normalize2world.toString());
        Space.facePointLerp(
          actor,
          positions[index][0].toDouble(),
          positions[index][1].toDouble(),
          1,
          normalize2world: normalize2world,
        );
      }

      if (action != null) {
        print("movetoaction " + BaseObject.getName(actor));
        //Actor.fadeOutAll(actor, 0.5);
        var actionitem = (await Actor.getAction(
          actor,
          name: action,
          duration: actionduration,
          randomduration: actionrandomduration,
          //    stopallactions: true
        )).reset().play();
        Actor.fadeOutAll(actor, 0.5, excludeaction: actionitem);
      }

      var t = new Timer(
        new Duration(milliseconds: (time * 1000).floor()),
        () async {
          // cancel started an new one
          if (actor.visible &&
              actor.extra.containsKey('movetoid') &&
              id == actor.extra['movetoid']) {
            if (index + 1 < positions.length) {
              print("moveto surface " + surfaceonly.toString());
              moveTo(
                actor,
                positions,
                action: action,
                actionduration: actionduration,
                facedir: facedir,
                stopaction: stopaction,
                stopactionduration: stopactionduration,
                id: id,
                index: index + 1,
                surfaceonly: surfaceonly,
                callbackonfinish: callbackonfinish,
                normalize2world: normalize2world,
                level: level,
              );
            } else {
              if (stopaction != null) {
                print(
                  "stop walk moveto action" +
                      stopaction +
                      " " +
                      BaseObject.getName(actor),
                );
                THREE.AnimationAction actionitem = (await Actor.getAction(
                  actor,
                  name: stopaction,
                  duration: stopactionduration,
                  //  stopallactions: true
                )).reset().play();
                Actor.fadeOutAll(actor, 0.5, excludeaction: actionitem);
                /* THREE.AnimationAction animationaction = await Actor.playAction(
                  actor, action: stopaction,
                  clampWhenFinished: true,
                  //   stopallactions: true,
                //  loopmode: loopmode,//THREE.LoopRepeat,
                 // looprepetitions: looprepetitions,//2,
//            loopmode: THREE.LoopOnce,
                //  randomduration: randomduration,
                  // backwards:backwards,
                //  duration: duration,
                 // fadein: fadein,
                //  fadeout:fadeout
              );*/
              }
              if (callbackonfinish != null) callbackonfinish(actor);
            }
          } else if (!actor.visible) {
            // go where when not visible or movetoid gone
            print("done movetoii moveto");
            // So that when come back isn't standing in one spot
            if (stopaction != null) {
              print(
                "stop walk action" +
                    stopaction +
                    " " +
                    BaseObject.getName(actor),
              );
              Actor.fadeOutAll(actor, 0.5);
              (await Actor.getAction(
                actor,
                name: stopaction, //stopallactions: true
              )).reset().play();
            }
            if (callbackonfinish != null) callbackonfinish(actor);
          }
        },
      );
      BaseObject.addTimer(actor, t);
      //}
    }
    return totaltime;
  }

  /// Place an [actor]  [dist] distance in front of the camera taking [time] seconds to get there with animation [action] and using [stopaction] when reached the position
  /// level is not needed because you use the level of the camera always
  /// [offset] is how far left or right from the center in frant of camera. Eg if place three items in front of camera might want one to the left, one middle one on right
  /// [delay] how long delay before placing before camera in seconds
  /// [speed] instead of using time to get their, instead use speed in m/s to get there
  /// placement in [z] axis
  /// [callbackonfinish] is called when the [actor] reaches it destination with callbackonfinish(actor)
  static placeBeforeCamera(
    actor,
    dist, {
    time,
    action,
    stopaction,
    offset,
    delay,
    speed,
    z,
    callbackonfinish,
  }) async {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        placeBeforeCamera(
          actor,
          dist,
          time: time,
          action: action,
          stopaction: stopaction,
          offset: offset,
          speed: speed,
          z: z,
          callbackonfinish: callbackonfinish,
        );
      });
      BaseObject.addTimer(actor, t);
    } else {
      if (action != null) {
        /* var actions= Actor.getActiveActions(actor);
        for (var actioni in actions)
          await actioni.fadeOut(0.5);*/
        Actor.fadeOutAll(actor, 0.5);

        /*THREE.AnimationAction activeanimation=Actor.getActiveAction(actor);
        if (activeanimation!=null) {
        //  print("fadeeeee");//+activeanimation.name.toString());
          await activeanimation.fadeOut(0.5);

        }*/
        var animationaction = (await Actor.getAction(
          actor,
          name: action,
        )).reset().play();
        // activeanimation=Actor.getActiveAction(actor);
        await animationaction.fadeIn(0.5);
      }
      print(
        "start action before camera" +
            action.toString() +
            " " +
            Mob.getName(actor),
      );
      if (speed != null) {
        // If speed then calculate time to get to position
        THREE.Vector2 pos = Space.getPlaceBeforeCameraPos(
          actor,
          dist,
          offset: offset,
        );
        var pos3 = THREE.Vector3(pos.x, pos.y, 0);
        var worldpos = You.getWorldPos();
        worldpos.z = 0;
        var dist2 = Math.vectorDistance(pos3, worldpos);
        time = dist2 / speed;
        print(
          "new time camera" +
              time.toString() +
              " d" +
              dist2.toString() +
              " v" +
              speed.toString(),
        );
      }
      Space.placeBeforeCamera(
        actor,
        dist,
        time: time,
        offset: offset,
        z: z,
        level: You.level,
      );
      var t = new Timer(
        new Duration(milliseconds: (time * 1000).floor()),
        () async {
          Space.faceObjectLerp(actor, Camera._camera, 0.5);

          if (stopaction != null) {
            print("stopaction place before camera" + stopaction);
            var actions = Actor.getActiveActions(actor);
            for (var actioni in actions) await actioni.fadeOut(0.5);

            /*  THREE.AnimationAction activeanimation=Actor.getActiveAction(actor);
          if (activeanimation!=null) {
            //  print("fadeeeee");//+activeanimation.name.toString());
            await activeanimation.fadeOut(0.5);

          }*/
            var activeanimation = (await Actor.getAction(
              actor,
              name: stopaction,
            )).reset().play();
            // activeanimation=Actor.getActiveAction(actor);
            await activeanimation.fadeIn(0.5);
          }
        },
      );
      BaseObject.addTimer(actor, t);
      var angle = Space.getAngleBetweensObjs(
        Camera._camera,
        actor,
      ); //, object2)

      Space.objTurnLerp(actor, angle - 180, 1);
      if (callbackonfinish != null) callbackonfinish(actor);
    }
  }

  /// Update an NPC - randomly get a chatter from an NPC and continue any speeches
  /// Also update movetoloops and check actors that are now visible and need to restart their animations
  static update(frameTime) {
    if (Math.random() < 0.1) {
      var chatter = Mob.nextChatter();
      if (chatter != null) {
        var obj = chatter["object"];
        Mob.setText(
          obj,
          chatter['chatter'],
          z: chatter['z'],
          width: chatter['width'],
          scale: chatter['scale'],
        );
      }

      var speech = Mob.nextSpeech();
      if (speech != null && speech["object"].visible) {
        var obj = speech["object"];
        Mob.setText(
          obj,
          speech['chatter'],
          z: speech['z'],
          y: speech['y'],
          x: speech['x'],
          width: speech['width'],
          scale: speech['scale'],
          paddingLeft: speech['paddingleft'],
          paddingRight: speech['paddingright'],
          paddingTop: speech['paddingtop'],
          paddingBottom: speech['paddingbottom'],
          tails: speech['tails'],
        );
        if (obj.extra['nextspeech'] == -1) {
          // Means have finished
          if (speech['clearwhendone'])
            Mob.clearText(obj, delay: obj.extra['speechminwait']);

          if (obj.extra['speechcallbackonfinish'] != null) {
            // You should wait until the last line of text is shown minwait length before calling the callback
            if (obj.visible) {
              Future.delayed(
                Duration(
                  milliseconds: (obj.extra['speechminwait'] * 1000).toInt(),
                ),
                () {
                  if (obj != null &&
                      obj.extra.containsKey('speechcallbackonfinish')) {
                    // print("chttt"+speech['chatter'].toString());
                    obj.extra['speechcallbackonfinish'](obj);
                  }
                },
              );
            }
          }
        }
      }

      // This is what determines if should restart a movetoloop because actor is now visible
      // Loops through all the hidden actors that have stopped in the movetoloop and check if they are visible.
      // If visible then restart and remove from the hidden list
      var actors = {...movetohiddenlist.keys};
      for (var actor in actors) {
        if (actor.visible) {
          print("redo movetoloop!" + BaseObject.getName(actor));
          var movetohidden = movetohiddenlist[actor];
          /*{
          "positions": positions,
          "action": action,
          "facedir": facedir,
          "id": id,
          "surfaceonly": surfaceonly,
          "duration": duration,
          "fadeout": fadeout,
          "randomduration": randomduration,
          "index": idx,
          "level": level
        };*/

          moveToLoop(
            actor,
            movetohidden['positions'],
            action: movetohidden['action'],
            facedir: movetohidden['facedir'],
            id: movetohidden['id'],
            surfaceonly: movetohidden['surfaceonly'],
            duration: movetohidden['duration'],
            looptype: movetohidden['looptype'],
            fadeout: movetohidden['fadeout'],
            randomduration: movetohidden['randomduration'],
            index: movetohidden['index'],
            level: movetohidden['level'],
            normalize2world: movetohidden['normalize2world'],
          );
          movetohiddenlist.remove(actor);
        }
      }
    }

    // This is what determines if the next part of the movetoloop should be started
    // This is all so movetoloop can be accelerated

    var actors = {...movetoloopbnextlist.keys};
    // print("movetoloopnextlistkeys length"+actors.length.toString());
    for (var actor in actors) {
      movetoloopbnextlist[actor]['currenttime'] += frameTime * 1000;
      var movetoloopnext = movetoloopbnextlist[actor];

      if (movetoloopnext['currenttime'] >
          movetoloopnext['starttime'] + movetoloopnext['time'] * 1000) {
        //  if (System.currentMilliseconds() > movetoloopnext['nexttime']) {
        print(
          "movetoloopnext called" +
              (frameTime * 1000).toString() +
              " " +
              movetoloopnext['currenttime'].toString() +
              " " +
              BaseObject.getName(actor),
        );
        movetoloopbnextlist.remove(actor);
        moveToLoopNext(
          actor,
          movetoloopnext['positions'],
          action: movetoloopnext['action'],
          facedir: movetoloopnext['facedir'],
          facenow: movetoloopnext['facenow'],
          id: movetoloopnext['id'],
          surfaceonly: movetoloopnext['surfaceonly'],
          duration: movetoloopnext['duration'],
          fadeout: movetoloopnext['fadeout'],
          randomduration: movetoloopnext['randomduration'],
          looptype: movetoloopnext['looptype'],
          index: movetoloopnext['index'],
          hidedist: movetoloopnext['hidedist'],
          level: movetoloopnext['level'],
          normalize2world: movetoloopnext['normalize2world'],
        );
      }
    }

  }
}

/// Procedures related to rooms
/// As a player moves around can enter a room which has a position with width and height
/// Can set that indoors so it doesn't rain inside and also set the background sound of the room
/// Can also set trigger so when enter a room certain things can happen
class Room {
  // You flick between sound1 and sound2 when move to different rooms
  static late audioplayers.AudioPlayer backgroundsound11;
  static late audioplayers.AudioPlayer backgroundsound12;
  static String backgroundsoundpath1 = "";
  static late audioplayers.AudioPlayer backgroundsound21;
  static late audioplayers.AudioPlayer backgroundsound22;
  static String backgroundsoundpath2 = "";
  static late audioplayers.AudioPlayer backgroundrandomsound;
  static bool hasinitialised = false;
  static double fadeInOutTime=3.0;

  /// Initialise sound for rooms
  static init() {
    // two audioplayers for two rooms so that dont hear gaps when loop such as fire
    if (!hasinitialised) {
      backgroundsound11 = audioplayers.AudioPlayer();
      backgroundsound12 = audioplayers.AudioPlayer();
      backgroundsound21 = audioplayers.AudioPlayer();
      backgroundsound22 = audioplayers.AudioPlayer();
      backgroundrandomsound = audioplayers.AudioPlayer();
      hasinitialised = true;
    }
  }

  /// Create a room at position [x],[y] with background sound file [soundpath] with [volume]. Use [soundpathfunc] if want to dynamically set the sound path - eg one sound at night and another during the day
  /// and also play a sound [randomsoundpaths] every 0 to [randomsoundgap] seconds - eg occasional hammerming at a smithys -picks at random each time
  /// Can specify a room that exit [exitroom] to when leave the room eg a default town room when leave a shop
  /// [roomspeed] how fast you move in the room
  /// [level] of the room - if not set then level is ignored
  static createRoom(
    x, y, {soundpath, soundpathfunc, volume = 1, randomsoundpaths, randomsoundgap=30, randomsoundvolume = 1, exitroom, roomspeed, level, name
  }) {
    var room = THREE.Object3D();
    room.extra['x'] = x;
    room.extra['y'] = y;
    Space.worldToLocalSurfaceObj(room, x.toDouble(), y.toDouble(), 0.0);
    if (exitroom != null) {
      room.extra['exitroom'] = exitroom;
    }
    if (name!=null)
      room.extra['name']=name;
    if (level != null) room.extra['level'] = level;
    if (soundpath != null || soundpathfunc != null) {
      room.extra['backgroundsound'] = soundpath;
      if (soundpathfunc != null)
        room.extra['backgroundsoundfunc'] = soundpathfunc;
      room.extra['backgroundvolume'] = volume;
      if (randomsoundpaths != null) {
        room.extra['backgroundrandomsounds'] = randomsoundpaths;
        if (randomsoundgap == null) randomsoundgap = 30;
        room.extra['backgroundrandomsoundgap'] = randomsoundgap;
        room.extra['backgroundrandomsoundvolume'] = randomsoundvolume;
      }
    }
    if (roomspeed != null) room.extra['roomspeed'] = roomspeed;

    return room;
  }

  /// When the randomsound will next be played
  static getNextRandomsSound(room) {
    if (room.extra.containsKey('backgroundrandomsoundgap'))
      room.extra['backgroundsoundgapnext'] =
          System.currentMilliseconds() +
          Math.random() * room.extra['backgroundrandomsoundgap'] * 1000;
  }

  /// Remove [room] sound
  static clearRandomSound(room) {
    if (room.extra.containsKey('backgroundrandomsoundgap'))
      room.extra.remove('backgroundrandomsoundgap');
    if (room.extra.containsKey('backgroundsoundgapnext'))
      room.extra.remove('backgroundsoundgapnext');
  }

  /// Get x coordinate of [room]
  static getX(room) {
    return room.extra['x'];
  }

  /// Get y coordinate of [room]
  static getY(room) {
    return room.extra['y'];
  }

  /// Get room name of [room]
  static getRoomName(room) {
    if (room.extra.containsKey('name'))
      return room.extra['name'];
    else
      return "";
  }

  /// Get the [room] speed that a play can move through it
  static getRoomSpeed(room) {
    if (room != null && room.extra.containsKey('roomspeed'))
      return room.extra['roomspeed'];
  }

  static bool wasplaying1 = false;
  static bool wasplaying2 = false;

  /// [mute] the room or start the sound again
  static mute(mute) async {
    if (!hasinitialised) return;
    print("mute room" + mute.toString() + " " + roomSoundStates());
    if (mute) {
      if (backgroundsound11.state == audioplayers.PlayerState.playing) {
        print("mute room11 " + mute.toString() + " " + roomSoundStates());
        wasplaying1 = true;
        backgroundsound11.stop();
        backgroundsound12.stop();
      }
      if (backgroundsound21.state == audioplayers.PlayerState.playing) {
        print("mute room21 " + mute.toString() + " " + roomSoundStates());
        wasplaying2 = true;
        backgroundsound21.stop();
        backgroundsound22.stop();
      }
    } else {
      if (wasplaying1) {
        backgroundsound11.resume();
        Duration? duration = (await backgroundsound12.getDuration());
        if (duration != null) {
          backgroundsound12.seek(
            Duration(milliseconds: (duration!.inMilliseconds / 2).round()),
          ); //5));
          backgroundsound12.resume();
        }
        wasplaying1 = false;
      }
      if (wasplaying2) {
        backgroundsound21.resume();
        var duration = await backgroundsound22.getDuration();
        backgroundsound22.seek(
          Duration(milliseconds: (duration!.inMilliseconds / 2).round()),
        ); //5));
        // backgroundsound22.seek(Duration(seconds: 5));
        backgroundsound22.resume();
        wasplaying2 = false;
      }
    }
  }

  /// If [room] is [indoors] then rain will not appear anywhere in the room
  static setIndoors(room, indoors) {
    room.extra['indoors'] = indoors;
  }

  /// Will check if a roof mesh is above your head automatically in the [room] if [indoors] and if so rain will not appear
  /// Means some parts of room can have rain and others doesn't depending on whether there is a roof above your head
  static setAutoIndoors(room, indoors) {
    room.extra['autoindoors'] = indoors;
  }

  /// Provide a [room] with a function [func] that determines if the user is inside or not - allows custom code to determine if indoors
  static setIndoorsFunc(room, func) {
    room.extra['indoorsfunc'] = func;
  }

  /// Is the point [x],[y] inside the room?
  static pointInRoom(room, x, y) {
    return room.extra.containsKey('roomminx') &&
        x >= room.extra['roomminx'] &&
        x <= room.extra['roommaxx'] &&
        y >= room.extra['roomminy'] &&
        y <= room.extra['roommaxy'];
  }

  /// return the minimum x value of a [room]
  static getMinX(room) {
    return room.extra['roomminx'];
  }

  /// return the minimum y value of a [room]
  static getMinY(room) {
    return room.extra['roomminy'];
  }

  /// return the maximum x value of a [room]
  static getMaxX(room) {
    return room.extra['roommaxx'];
  }

  /// return the maximum y value of a [room]
  static getMaxY(room) {
    return room.extra['roommaxy'];
  }

  // Return the closest point to [x],[y] the [room] boundary
  // For example if maxy: 0.7, miny: 0, minx: 48.1, maxx: 49 and point inside that rectangle eg x=48.5,y= 0.5 then will return  48.5, 0.7.
  // [offset] is how far out or in your place it from the edge
  static List getClosestEdgePoint(room, x, y, {offset = 0}) {
    if (pointInRoom(room, x, y)) {
      // Distance to each edge
      double dLeft = x - room.extra['roomminx'];
      double dRight = room.extra['roommaxx'] - x;
      double dBottom = y - room.extra['roomminy'];
      double dTop = room.extra['roommaxy'] - y;

      // Find the smallest distance
      double minDist = [dLeft, dRight, dBottom, dTop].reduce(math.min);

      if (minDist == dLeft) return [room.extra['roomminx'] - offset, y];
      if (minDist == dRight) return [room.extra['roommaxx'] + offset, y];
      if (minDist == dBottom) return [x, room.extra['roomminy'] - offset];
      return [x, room.extra['roommaxy'] + offset]; // Top edge
    } else
      return [];
  }

  /// Is the [object] inside the [room]
  static isInRoom(room, object) {
    var pos = Space.localToWorldObj(object);
    return pointInRoom(room, pos.x, pos.y);
  }

  /// Add an [object] to a [room] - these will only be visible if inside room
  static addRoomObject(room, object) {
    if (!room.extra.containsKey('roomobjects')) room.extra['roomobjects'] = [];
    if (!room.extra['roomobjects'].contains(object)) {
      object.visible = false; // only show it if inside room
      room.extra['roomobjects'].add(object);
    }
  }

  /// Get the [room] background sound
  static getBackgroundSoundPath(room) {
    if (room.extra.containsKey("backgroundsoundfunc")) {
      return (room.extra["backgroundsoundfunc"](room));
    }
    if (room.extra.containsKey("backgroundsound"))
      return room.extra["backgroundsound"];
  }

  /// Set the [room] background sound with asset [path]
  static setBackgroundSoundPath(room, path) {
    room.extra["backgroundsound"] = path;
  }

  /// Get the [room] volume
  static getBackgroundVolume(room) {
    if (room.extra.containsKey("backgroundvolume"))
      return room.extra["backgroundvolume"];
  }

  /// Set the [room] [volume]
  static setBackgroundVolume(room, volume) {
    room.extra["backgroundvolume"] = volume;
  }

  /// Create a trigger on a room with its boundaries. Will play background sound when you enter the room
  /// If [dist] specified then the room will be a square of dist from the rooms center
  /// Otherwise can use [minx], [miny], [maxx] and [maxy] world coordinates to specify the boundaries of the room
  /// [event] is the callback if triggered
  static setDistanceTrigger(room, {minx, maxx, miny, maxy, dist, event}) {
    if (dist != null) {
      minx = room.extra['x'] - dist;
      maxx = room.extra['x'] + dist;
      miny = room.extra['y'] - dist;
      maxy = room.extra['y'] + dist;
    }
    room.extra['roomminx'] = minx;
    room.extra['roommaxx'] = maxx;
    room.extra['roomminy'] = miny;
    room.extra['roommaxy'] = maxy;
    BaseObject.setDistanceTrigger(
      room,
      ndist: maxy - room.extra['y'],
      sdist: room.extra['y'] - miny,
      wdist: room.extra['x'] - minx,
      edist: maxx - room.extra['x'],
      level: room.extra['level'],
      event: (action) async {
        // Only trigger the room entry use is at correct room level - ignore level if it is not set
        //   if (!room.extra.containsKey('level')||(room.extra.containsKey('level')&&You.level==room.extra['level'])) {
        //    room.extra['trigger'].addEventListener( 'trigger',  ( THREE.Event event ) async {
        if (event != null) event(action);
        if (action) {
          print("entered room" + (room.extra.containsKey('name')
                    ? room.extra['name'].toString()
                    : ""),
          );
          // show objects if enter room
          if (room.extra.containsKey('roomobjects')) {
            print("contains room objects");
            for (var object in room.extra['roomobjects']) object.visible = true;
          }
          You.room = room;

          getNextRandomsSound(room);
          if (getBackgroundSoundPath(room) != null) {
            //room.extra.containsKey("backgroundsound")) {
            // Has two sounds so that when loop don't get gap
            backgroundsound11.setReleaseMode(audioplayers.ReleaseMode.loop);
            backgroundsound12.setReleaseMode(audioplayers.ReleaseMode.loop);
            backgroundsound21.setReleaseMode(audioplayers.ReleaseMode.loop);
            backgroundsound22.setReleaseMode(audioplayers.ReleaseMode.loop);

            if ((backgroundsound11.state == audioplayers.PlayerState.playing &&
                    getBackgroundSoundPath(room) == backgroundsoundpath1) ||
                (backgroundsound21.state == audioplayers.PlayerState.playing &&
                    getBackgroundSoundPath(room) == backgroundsoundpath2)) {
              // do nothing as is already playing
            } else {
              var val = getPlaying();
              var usesoundto = val[0];
              var usesoundfrom = val[1];
              Sound.fadeOut(usesoundfrom[0],fadeInOutTime);// 1.0);
              Sound.fadeOut(usesoundfrom[1], fadeInOutTime);//1.0);
              //usesoundfrom[0].stop();
              //usesoundfrom[1].stop();

              print(
                "roomsoundplay " +
                    getRoomName(room) +
                    getBackgroundSoundPath(room).toString(),
              );

              // You have the same sound playing twice here with one  starting half way though the middle
              var duration = await Sound.play(
                sound: usesoundto[0],
                path: getBackgroundSoundPath(room),
                loop: true,
                volume: getBackgroundVolume(room),
              ); //room.extra['backgroundvolume']);
              if (duration != null) {
                if (duration <= 0) duration = 5;

                print("duration" + duration.toString());
                await Sound.play(
                  sound: usesoundto[1],
                  path: getBackgroundSoundPath(room),
                  loop: true,
                  volume: getBackgroundVolume(room),
                  seek: duration / 2.0,
                );
                ; //5);

                Sound.fadeIn(usesoundto[0], fadeInOutTime);//2);
                Sound.fadeIn(usesoundto[1],fadeInOutTime);// 2);
              }
            }
            //print("play "+room.extra['backgroundsound']);
          } else {
            // Entered a room with no sound therefore fade the old room
            print("entered a room with no sound");
            var val = getPlaying();
            var usesoundto = val[0];
            var usesoundfrom = val[1];
            if (Sound.isPlaying(
              usesoundfrom[0],
            )) //==audioplayers.PlayerState.playing)
              Sound.fadeOut(usesoundfrom[0],fadeInOutTime);// 2);
            else {
              // bug ios
              print("with no sound stop 0");
              usesoundfrom[0].stop();
            }
            if (Sound.isPlaying(
              usesoundfrom[1],
            )) //.state==audioplayers.PlayerState.playing)
              Sound.fadeOut(usesoundfrom[1],fadeInOutTime);// 2);
            else {
              // bug ios
              print("with no sound stop 1");
              usesoundfrom[1].stop();
            }
          }
        } else {
          // exit the room
          print(
            "exit room:" +
                (room.extra.containsKey('name')
                    ? room.extra['name'].toString()
                    : ""),
          );
          room.extra['backgroundsoundgapnext'] = -1;
          if (You.room != null &&
              You.room != room &&
              getBackgroundSoundPath(You.room) != null &&
              getBackgroundSoundPath(room) != null &&
              getBackgroundSoundPath(You.room) ==
                  getBackgroundSoundPath(room)) {
            // do nothing as same sound in new room

            print("do nothing");
          } else {
            // Exit but not into another room
            print(
              "roomsoundfadeout " +
                  getRoomName(room) +
                  getBackgroundSoundPath(room).toString(),
            );

            var val = getPlaying();
            var usesoundto = val[0];
            var usesoundfrom = val[1];
            if (Sound.isPlaying(
              usesoundfrom[0],
            )) //.state==audioplayers.PlayerState.playing)
              Sound.fadeOut(usesoundfrom[0], fadeInOutTime);//2);
            else {
              // bug in ios
              print("roomsoundfadeout stop 0");
              usesoundfrom[0].stop();
              //  usesoundto[0].stop();
            }
            if (Sound.isPlaying(
              usesoundfrom[1],
            )) //.state==audioplayers.PlayerState.playing)
              Sound.fadeOut(usesoundfrom[1], fadeInOutTime);//2);
            else {
              // bug in ios
              print("roomsoundfadeout stop 1");
              usesoundfrom[1].stop();
              // usesoundto[1].stop();
            }

            if (room.extra.containsKey('exitroom')) {
              var exitroom = room.extra['exitroom'];
              exitroom.extra['trigger'].inside = true;
              // In case was disabled
              BaseObject.reenableDistanceTrigger(exitroom);
              exitroom.extra['trigger'].trigger(true);
            }
          }
          // hide objects if exit room
          if (room.extra.containsKey('roomobjects')) {
            for (var object in room.extra['roomobjects'])
              object.visible = false;
          }
        }
        //   }
      },
    );
  }

  /// Which background audioplayer is playing
  static getPlaying() {
    var usesound11;
    var usesound12;
    var usesound21;
    var usesound22;
    if (Sound.isPlaying(backgroundsound11)) {
      //.state==audioplayers.PlayerState.playing) {
      usesound11 = backgroundsound21;
      usesound12 = backgroundsound22;
      usesound21 = backgroundsound11;
      usesound22 = backgroundsound12;
    } else {
      usesound11 = backgroundsound11;
      usesound12 = backgroundsound12;
      usesound21 = backgroundsound21;
      usesound22 = backgroundsound22;
    }
    // usesound1 is the one to use and the usesound2 is what was used before
    return [
      [usesound11, usesound12],
      [usesound21, usesound22],
    ];
  }

  /// Get state of background sounds for debugging
  static roomSoundStates() {
    // return  Sound.isPlaying(backgroundsound11).toString()+" "+Sound.isPlaying(backgroundsound12).toString()+" "
    //    +Sound.isPlaying(backgroundsound21).toString()+" "+Sound.isPlaying(backgroundsound22).toString();
    //   backgroundsound11.
    if (hasinitialised)
      return (backgroundsound11.state).toString() +
          " " +
          backgroundsound11.releaseMode.toString() +
          " " +
          (backgroundsound12.state).toString() +
          " " +
          backgroundsound12.releaseMode.toString() +
          " " +
          (backgroundsound21.state).toString() +
          " " +
          backgroundsound21.releaseMode.toString() +
          " " +
          (backgroundsound22.state).toString() +
          " " +
          backgroundsound22.releaseMode.toString();
    else
      return "not initialised";
  }

  /// If random sounds in room then determine if should play or not
  static update(frameTime) {
    if (You.room != null &&
        You.room!.extra.containsKey('backgroundsoundgapnext') &&
        You.room?.extra['backgroundsoundgapnext'] != -1 &&
        System.currentMilliseconds() >
            You.room?.extra['backgroundsoundgapnext']) {
      print("play groan");
      Sound.play(
        path: Math.randPick(You.room?.extra['backgroundrandomsounds']),
        volume: You.room?.extra['backgroundrandomsoundvolume'],
      ); //1.0);//You.room?.extra['backgroundvolume']);
      getNextRandomsSound(You.room);
    }
  }
}

/// Class allows run time obstacles to be placed in a game. Also includes a callback when an obstacle is hit by a player
/// Allows a player to be stopped without relying on walls defined in terrain model
class Obstacle {
  late double x;
  late double y;
  late int level;
  late double width;
  late double height;
  late THREE.Object3D? marker;
  bool enabled = true;
  late Function? callback;
  double callbacknextwait=-1;
  int callbacknexttick=-1;

  /// Set the position of the obstacle at [x],[y] and [level] with a [width] and [height].
  /// If obstacle hit call [callback]
  /// [callbacknextwait] is a how long must wait in seconds before a callback is called again - stops flood of callbacks if player keeps hitting an obstacle
  /// [marker] is the scene (or hotload) so can place a marker on the scene showing the position of the marker
  Obstacle(x, y, width, height, {level = 0, marker,callback,callbacknextwait}) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.level = level;
    this.marker = marker;
    this.callback = callback;
    if (callbacknextwait!=null)
      this.callbacknextwait=callbacknextwait.toDouble();
  }

  /// Returns the closest point on or inside the obstacle to (posx, posy).
  /*closestHit(posx,  posy) {
    // 1. Calculate the boundaries of the rectangle
    double minX = x-width/2;
    double maxX = x + width/2;
    double minY = y-height/2;
    double maxY = y + height/2;

    // 2. Clamp the pos coordinates to the rectangle boundaries
    double closestX = posx.toDouble().clamp(minX, maxX);
    double closestY = posy.toDouble().clamp(minY, maxY);

    return [closestX, closestY];
  }*/

  /// Calculates which side the point [posx],[posy] hits and returns standard headings:
  /// North (0), East (90), South (180), West (270)
  int hitDirection(posx, posy) {
    // 1. Calculate boundaries
    double minX = x - width / 2;
    double maxX = x + width / 2;
    double minY = y - height / 2;
    double maxY = y + height / 2;

    // 2. Find absolute distance from the point to each of the 4 bounds
    double distToWest = (posx.toDouble() - minX).abs();
    double distToEast = (posx.toDouble() - maxX).abs();
    double distToNorth = (posy.toDouble() - minY).abs();
    double distToSouth = (posy.toDouble() - maxY).abs();

    // 3. Determine which distance is the shortest
    double minDist = distToNorth;
    int direction = 0; // Default North

    if (distToEast < minDist) {
      minDist = distToEast;
      direction = 90;
    }
    if (distToSouth < minDist) {
      minDist = distToSouth;
      direction = 180;
    }
    if (distToWest < minDist) {
      minDist = distToWest;
      direction = 270;
    }

    return direction;
  }

  /// Execute the callback but only if sufficent time has past from the previous callback
  executeCallback()
  {
    if (callback!=null&&
        (callbacknextwait<=0||(callbacknextwait>0&&System.currentMilliseconds()>=callbacknexttick))) {
      callback!(this);
      if (callbacknextwait>0) {
        callbacknexttick=System.currentMilliseconds()+(callbacknextwait*1000).round();
      }
    }
  }
}


class Obstacles {
  static List obstacles = [];

  static init() {
    obstacles = [];
  }

  /// Set the position of the obstacle at [x],[y] and [level] with a [width] and [height].
  /// If obstacle hit call [callback]
  /// [callbacknextwait] is a how long must wait in seconds before a callback is called again - stops flood of callbacks if player keeps hitting an obstacle
  /// [marker] is the scene (or hotload) so can place a marker on the scene showing the position of the marker
  static createObstacle(x, y, width, height, {level = 0, marker = null, callback=null,callbacknextwait=-1}) {
    var obstacle = Obstacle(x, y, width, height, level: level, marker: marker, callback:callback,callbacknextwait:callbacknextwait);

    obstacles.add(obstacle);
    if (marker != null) {
      var geometry = THREE.BoxGeometry(1.0, 1.0, 1.0); //0.02, 0.02, 0.02 );
      var material = THREE.MeshBasicMaterial.fromMap({
        'color': THREE.Color.fromHex32(0x00ff00),
      });
      var cube = THREE.Mesh(geometry, material);
      cube.scale.setValues(width.toDouble(), 0.02, height.toDouble());

      Space.worldToLocalSurfaceObj(
        cube,
        x.toDouble(),
        y.toDouble(),
        0.0,
        level: level,
      );
      marker.add(cube);
    }
    return obstacle;
  }

  /// Return any obstacles hit at world position [x],[y] but only if the obstacle is enabled
  static getHits(x, y) {
    var hits = [];
    //  var worldpos = Space.localToWorldObj(Camera._camera);

    for (var obstacle in obstacles) {
      // if (portal.name!=null)
      //   print("portal!!"+worldpos.x.toString()+" "+worldpos.y.toString()+" "+portal.x.toString()+" "+portal.y.toString()+" "+portal.width.toString()+" "+portal.height.toString());
      if (obstacle.enabled &&
          obstacle.level == You.level &&
          x > obstacle.x - obstacle.width / 2 &&
          x < obstacle.x + obstacle.width / 2 &&
          y > obstacle.y - obstacle.height / 2 &&
          y < obstacle.y + obstacle.height / 2) {
        hits.add(obstacle);
      }
    }
    return hits;
  }
}

// This is a general purpose doorway that allows for multiple doors in the doorway eg two grand doors that both open and close outwards and inwards
// The multiple doors can be opened and closed. Also includes an obstacle that is turned on or off depending if open or closed
class Doorway {
  List doors = [];
  var obstacle = null;

  /// Add a [door] object3d and set its turn angle when open [angleopen] and turn angle when closed [angleclosed] - so two grand doors might be open at 180 and 0 degrees then when closed 90 and 270
  /// [hideifopen] just removes and hides the doors in they are open rather than turn them
  addDoor(door, angleopen, angleclosed, {hideifopen}) {
    doors.add({
      'door': door,
      'angleopen': angleopen,
      'angleclosed': angleclosed,
      'hideifopen': hideifopen,
    });
  }

  /// Moves the doors open or closed based upon the angleclosed and angleopen values - or just hide them if open -hideifopen
  setOpenClose(open) {
    if (obstacle != null) obstacle.enabled = !open; //false;
    for (var door in doors) {
      if (open && door['hideifopen'] != null && door['hideifopen']) {
        door['door'].visible = false;
        Space.removeObjFromHide(door['door']);
      } else {
        door['door'].visible = true;
        Space.readdObjFromHide(door['door']);
        if (!System.loaded)
          Space.objTurn(door['door'], door[open ? 'angleopen' : 'angleclosed']);
        else
          Space.objTurnLerp(
            door['door'],
            door[open ? 'angleopen' : 'angleclosed'],
            2,
          );
      }
    }
  }

}

/// Class allows players to jump between areas
/// It made up of a rectangle where if hit by player, takes them to a second define point
/// It is useful for allowing players transition to different level eg a portal at the bottom of some stairs that takes them to the top of the stairs at a different level
class Portal {
  late double x;
  late double y;
  late int level;
  late double width;
  late double height;
  late double x2;
  late double y2;
  late double z2;
  late int level2;
  late double? lerp;
  late THREE.Object3D? marker;

  //var initturn;
  var finalturn;
  var callback;
  late bool adjacent;
  late var angleentry;
  late var angleentrythresh;
  late var name;

  Portal(
    x, y, width, height, x2, y2,
    z2, {
    lerp,
    level = 0,
    level2 = 0,
    marker = null,
    /*initturn,*/ finalturn,
    callback,
    adjacent,
    angleentry,
    angleentrythresh,
    name,
  }) {
    assert(
      x2 > x + width / 2 ||
          x2 < x - width / 2 ||
          y2 > y + height / 2 ||
          y2 < y - height / 2,
    );

    this.x = x.toDouble();
    this.y = y.toDouble();
    this.level = level;
    this.width = width.toDouble();
    this.height = height.toDouble();
    this.x2 = x2.toDouble();
    this.y2 = y2.toDouble();
    this.z2 = z2;
    this.level2 = level2;
    this.marker = marker; /*this.initturn=initturn;*/
    this.finalturn = finalturn;
    this.callback = callback;
    this.adjacent = adjacent ?? false;
    this.angleentry = angleentry;
    this.angleentrythresh = angleentrythresh;
    this.name = name;
    if (lerp != null)
      this.lerp = lerp.toDouble();
    else
      this.lerp = null;
  }

  // Handle a player entering this portal
  enter({worldpos})
  {
    if (worldpos==null)
      worldpos= Space.localToWorldObj(Camera._camera);
    if (name != null)
      print("hit portal!!" + name); //inc.toString()+" "+);
    //    print("portal!!"+worldpos.x.toString()+" "+worldpos.y.toString()+" "+portal.x.toString()+" "+portal.y.toString()+" "+portal.width.toString()+" "+portal.height.toString());
    You.level = level2;

    // Default destination is the portal's own fixed x2,y2. When
    // 'adjacent' is set, the coordinate ALONG the player's travel
    // direction still uses the fixed x2/y2 (that's "how far out the
    // other side" the portal pushes them), but the coordinate
    // PERPENDICULAR to travel instead carries over the player's own
    // offset from the portal's center on that axis - so walking
    // through near one edge of the portal comes out near the
    // corresponding edge on the other side, rather than always
    // landing at one exact point regardless of where you entered.
    var destx =x2;
    var desty = y2;
    if (adjacent && Portals.lastworldpos != null) {
      var dx = worldpos.x - Portals.lastworldpos!.x;
      var dy = worldpos.y - Portals.lastworldpos!.y;
      if (dx.abs() >= dy.abs()) {
        // Travelling primarily east/west - x2 is the fixed "through
        // the portal" distance, y carries the vertical offset.
        var offset = (worldpos.y - y).clamp(
          -height / 2,
          height / 2,
        );
        desty = y2 + offset;
      } else {
        // Travelling primarily north/south - y2 is fixed, x carries
        // the horizontal offset.
        var offset = (worldpos.x - x).clamp(
          -width / 2,
          width / 2,
        );
        destx = x2 + offset;
      }
    }

    if (lerp == null) {
      //  print("lerp null");
      Space.worldToLocalSurfaceObj(Camera._camera, destx, desty, z2 + Camera.cameraoffset, level: level2,);
      // Makes no sense if both set if dont have lerp
      //if (initturn!=null)
      //  Camera.turn=initturn.toDouble();
      if (finalturn != null)
        Camera.turn = finalturn.toDouble();
      if (callback != null) callback();
      Portals.nextchecktick = -1;
    } else {
      You.immobile = true;
      Portals.inimmobile = true;
      Space.worldToLocalSurfaceObjLerp(
        Camera._camera,
        destx,
        desty,
        z2 + Camera.cameraoffset,
        lerp,
        level: level2,
      );

      if (finalturn != null)
        Space.objTurnLerp(
          Camera._camera, finalturn.toDouble(), lerp,
        );
      if (callback != null) {
        //   callback();
        Future.delayed(
          Duration(milliseconds: (lerp! * 1000).toInt()),
              () async {
            //print("play "+path.toString());
            callback();
          },
        );
      }

      Portals.nextchecktick =
          System.currentMilliseconds() +
              (lerp! * 1000 + 500).round();
      if (name != null)
        print("nexttickcheck" + Portals.nextchecktick.toString() +
              " " +
              System.currentMilliseconds().toString() +
              " " +
              (lerp! * 1000 + 500).toString() +
              " " +
              name,
        );
    }
  }

  /// Return the closest point to the portal rectangle at [posx],[posy]
  closestHit(posx,  posy) {
    // 1. Calculate the boundaries of the rectangle
    double minX = x-width/2;
    double maxX = x + width/2;
    double minY = y-height/2;
    double maxY = y + height/2;

    // 2. Clamp the pos coordinates to the rectangle boundaries
    double closestX = posx.toDouble().clamp(minX, maxX);
    double closestY = posy.toDouble().clamp(minY, maxY);

    return [closestX, closestY];
  }
}

class Portals {
  static List portals = [];
  static int nextchecktick = -1;
  static var inimmobile = false;
  static THREE.Vector3? lastworldpos;

  static init() {
    portals = [];
  }

  /// Create a portal at [x],[y],[level] with [width],[height] where if the player hits the rectangle the player moves to [x2],[y2],[level2] in [lerp] seconds
  /// Set the [marker] as the scene or hotload which will then show the position of the portal and its exit
  /// [finalturn] is the direction a player faces when a player reaches the end of the portal
  /// [callback] is called when a player reaches the end of a portal
  /// [adjacent] means when exit the portal you move to the exit adjacent to the way you moved in -eg bottom of a wide stair case rather than reach x2,y2 in the middle of the stair case you reach it with the camera travelling at the same angle it came in
  /// [angleentry] is the angle that must enter portal for you to get through it - for example if travelling north up stairs, cannot trigger the portal if travelling south
  /// [anglethresh] is the threshold at with [angleentry] is valid eg if set [angleentry] to 90 and [angleentrythresh] to 45 than valid to enter the portal 45 to 135 degrees
  static createPortal(x, y, width, height, x2, y2, z2, {
    level = 0,
    level2 = 0,
    lerp,
    marker = null,
    finalturn,
    callback,
    adjacent,
    angleentry,
    angleentrythresh,
    name,
  }) //, reverse})
  {
    var portal = Portal(x, y, width, height, x2, y2, z2,
      level: level,
      level2: level2,
      lerp: lerp,
      marker: marker,
      finalturn: finalturn,
      callback: callback,
      adjacent: adjacent,
      angleentry: angleentry,
      angleentrythresh: angleentrythresh,
      name: name,
    );
    //  var portal=Portal(x,y,width,height,x2,y2, z2,level:level, level2:level2, lerp:lerp, marker:marker,initturn:initturn,finalturn:finalturn);
    portals.add(portal);
    if (marker != null) {
      var geometry = THREE.BoxGeometry(1.0, 1.0, 1.0); //0.02, 0.02, 0.02 );
      var material = THREE.MeshBasicMaterial.fromMap({
        'color': THREE.Color.fromHex32(0x00ff00),
      });
      var cube = THREE.Mesh(geometry, material);
      cube.scale.setValues(width.toDouble(), 0.02, height.toDouble());

      Space.worldToLocalSurfaceObj(
        cube,
        x.toDouble(),
        y.toDouble(),
        0.0,
        level: level,
      );
      marker.add(cube);

      material = THREE.MeshBasicMaterial.fromMap({
        'color': THREE.Color.fromHex32(0xff0000),
      });
      var cubeto = THREE.Mesh(geometry, material);
      Space.worldToLocalSurfaceObj(
        cubeto,
        x2.toDouble(),
        y2.toDouble(),
        z2.toDouble(),
        level: level2,
      );
      cubeto.scale.setValues(0.05, 0.05, 0.05);
      marker.add(cubeto);
    }
    /* if (reverse!=null&&reverse) {
      var reverseportal = Portal(
          x2,
          y2,
          width,
          height,
          x,
          y,
          z2,
          level: level2,
          level2: level,
          lerp: lerp,
          marker: marker);
      portals.add(reverseportal);
    }*/
    return portal;
  }


  /// Check if player moved into portal
  static update() {
    if (nextchecktick == -1 || System.currentMilliseconds() > nextchecktick) {
      // print("portals update"+inimmobile.toString()+" "+You.immobile.toString());
      if (inimmobile) {
        inimmobile = false;
        You.immobile = false;
      }
      var worldpos = Space.localToWorldObj(Camera._camera);
      // print("update portal!!"+portals.length.toString());
      var found = false;
      //  var inc=0;
      for (Portal portal in portals) {
        if (portal.name != null)
          print(
            "portal!!" + worldpos.x.toString() +
                " " + worldpos.y.toString() +
                " " + portal.x.toString() +
                " " + portal.y.toString() +
                " " + portal.width.toString() +
                " " + portal.height.toString(),
          );
        if (!found &&
            portal.level == You.level &&
            worldpos.x > portal.x - portal.width / 2 &&
            worldpos.x < portal.x + portal.width / 2 &&
            worldpos.y > portal.y - portal.height / 2 &&
            worldpos.y < portal.y + portal.height / 2 &&
            //   (portal.angleentry==null||(portal.angleentry!=null&&Math.angleDifference(Camera.turn, portal.angleentry)<portal.angleentrythresh))
            (portal.angleentry == null ||
                (portal.angleentry != null &&
                    Math.angleDifference(You.getMoveDir(), portal.angleentry) <
                        portal.angleentrythresh))) {
          portal.enter(worldpos:worldpos);

          found = true;
        }
        // inc++;
      }

      lastworldpos = worldpos;

      // Space.worldToLocalSurfaceObjLerp(
      //     Camera._camera, 10.49, 3.60, 0, 1);
    }
  }
}

/// Procedures related to color
class ColorLib {
  /// from the seed of the username [text] get a repeatable random color
  /// Is dart Color so that can be used in widgets rather than THREE.Color
  static Color colorFromText(String text) {
    var seed = 0;
    for (var k = 0; k < text.length; k++) {
      var char = text.codeUnits[k] as int;
      seed += (k + 1) * char;
    }
    const colorlist = [
      Colors.yellow,
      Colors.red,
      Colors.white,
      Colors.lightBlueAccent,
      Colors.lightGreen,
      Colors.orange,
      Colors.white38,
      Colors.amberAccent,
      Colors.purpleAccent,
    ];
    var color = colorlist[seed % colorlist.length];
    return color;
  }

  /// Covert colors string [colorstr] eg #ffffff to a THREE color
  static THREE.Color colorFromHexString(colorstr) {
    //return THREE.Colo
    return THREE.Color.fromHex32(
      int.parse(colorstr.replaceAll("#", ""), radix: 16),
    );
  }

  /// Covert colors string [code] eg #ffffff to a dart color
  static Color dartColorFromHexString(String code) {
    return Color(int.parse(code.replaceAll("#", ""), radix: 16) + 0xFF000000);
  }

  /// Brighten a hex color and return a hex color
  static int brighten(int hexColor, double amount) {
    // Extract channels (assuming AARRGGBB)
    int a = (hexColor >> 24) & 0xFF;
    int r = (hexColor >> 16) & 0xFF;
    int g = (hexColor >> 8) & 0xFF;
    int b = hexColor & 0xFF;

    // Add brightness and clamp to 255
    r = (r * amount).round().clamp(0, 255);
    g = (g * amount).round().clamp(0, 255);
    b = (b * amount).round().clamp(0, 255);

    // Re-assemble
    return (a << 24) | (r << 16) | (g << 8) | b;
  }
}

/// Executes all updateables such a fire, water, smoke
class Updateables {
  static List<Updateable> updateables = [];

  static init() {
    updateables = [];
  }

  /// Add an updateable like fire
  static add(Updateable updateable) {
    updateables.add(updateable);
  }

  /// Delete the [updateable]
  static remove(updateable) {
    if (updateables.contains(updateable)) updateable.sremove(updateable);
  }

  /// Execute the updateables - do it every frame
  static update(frameTime, elapsedTime) {
    for (var updateable in updateables)
      updateable.update(frameTime, elapsedTime);
  }
}

///  Functions and info related to the player
class You {
  static THREE.Object3D? room; // Current room the player is in

  static double speed = 1; //2; // your speed 2m/s
  static double drag = 1; // can modify the speed by a percentage
  static bool immobile = false; // Stop player movement
  static bool immobileturn = false; // Stop player turning
  static int level = 0;  // Your level on the terrain surface - eg below ground - on a roof

  static String wield = ""; // Name of object wielding

  /// Where you are in world coordinates - returns vector3f
  static THREE.Vector3 getWorldPos() {
    return Space.localToWorldObj(Camera._camera);
  }

  /// Is the player indoors. Used to stop rain while inside
  /// Can set a room is always indoors with indoors flag
  /// Can set a room to be indoors only if a roof is above the player (autoindoors)
  /// Can set a room to be indoors based upon a custom function. For example if camera z is less than a certain amount is in the sea
  static indoors() {
    var indoors = false;
    if (room != null) {
      if (Room.isInRoom(room, Camera._camera)) {
        indoors = room!.extra.containsKey("indoors") && room!.extra['indoors'];
        //print("indoors"+indoors.toString()+" "+room!.extra['guide'].toString());
        if (!indoors) {
          if (room!.extra.containsKey("autoindoors") &&
              room!.extra['autoindoors']) {
            // print("test intersect roof"+Space.roofInteresectDistance(Camera._camera.position.x,Camera._camera.position.y,Camera._camera.position.z).toString());
            indoors =
                Space.roofInteresectDistance(
                  Camera._camera.position.x,
                  Camera._camera.position.y,
                  Camera._camera.position.z,
                ) >
                0;
            // print("inndors"+indoors.toString());
          }
          if (!indoors && room!.extra.containsKey('indoorsfunc')) {
            //  print("voot");
            indoors = room!.extra['indoorsfunc']();
          }
        }
      } else {
        //  print("not in room");
      }
    } else {
      //  print("no room");
    }
    //    print("mmmm"+indoors.toString());
    return indoors;
  }

  /// What direction are you moving
  static getMoveDir() {
    if (lastworldpos != null && lastworldpos2 != null) {
      //print("movedir"+Math.getAngleBetweenPoints( lastworldpos2,getWorldPos()).toString());//lastworldpos"+lastworldpos.toString()+ " "+getWorldPos().toString());
      return Math.getAngleBetweenPoints(lastworldpos2, getWorldPos());
    } else
      return Camera.turn; //0;
  }

  /// Set the player to be immobile in [delay] seconds
  static setImmobile(isimmobile, {delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).floor()), () {
        setImmobile(isimmobile);
      });
    } else
      immobile = isimmobile;
  }

  /// Set the player to not be able to turn camera (or reenable) in [delay] seconds
  static setImmobileTurn(isimmobile, {delay}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).floor()), () {
        setImmobileTurn(isimmobile);
      });
    } else
      immobileturn = isimmobile;
  }

  /// Are you facing this [object] within [diff] degrees threshold
  static isfacing(object,diff)
  {
    var angle = Space.getAngleBetweensObjs(Camera._camera, object);
    var anglediff = Math.angleDifference(Camera.turn, angle);
    return anglediff.abs()<diff;
  }

  /// How far away is this [object] from you
  static getObjDistance(object)
  {
    return Space.getDistanceBetweenObjs(Camera._camera, object);
  }

  static var lastworldpos = null;
  static var lastworldpos2 = null;

  static update() {
    var worldpos = getWorldPos();
    if (lastworldpos == null ||
        worldpos.x != lastworldpos.x ||
        worldpos.y != lastworldpos.y) {
      lastworldpos2 = lastworldpos;
      lastworldpos = worldpos;
    }
  }
}

/// A map item that holds a map image, two world positions and corresponding pixel positions on the image
class MapItem {
  late String filename; // Asset image path
  late double worldx, worldy; //  world coordinates for a given image coordinate
  late int imagex, imagey;
  late double worldx2,
      worldy2; //  world coordinates for a given image coordinate
  late int imagex2, imagey2;
  late int width, height;

  /// Initialise a map item with the map images [filename] alongside two points. One points being world positions and a corresponding image position
  MapItem(
    filename, {
    required worldx,
    required worldy,
    required imagex,
    required imagey,
    required worldx2,
    required worldy2,
    required imagex2,
    required imagey2,
  }) {
    this.filename = filename;
    this.worldx = worldx.toDouble();
    this.worldy = worldy.toDouble();
    this.imagex = imagex;
    this.imagey = imagey;
    this.worldx2 = worldx2.toDouble();
    this.worldy2 = worldy2.toDouble();
    this.imagex2 = imagex2;
    this.imagey2 = imagey2;
  }

  /// Given the world coords [inworldx] and [inworldy] return image pixel coordinates of the map
  getImageCoordsFromWorldCoords(inworldx, inworldy) {
    var mx = (imagex2 - imagex) / (worldx2 - worldx);
    var cx = imagex2 - mx * worldx2;
    var mapx = (mx * inworldx + cx);
    var my = (imagey2 - imagey) / (worldy2 - worldy);
    var cy = imagey2 - my * worldy2;
    var mapy = (my * inworldy + cy);
    return [mapx, mapy];
  }
}

/// Functions related to maps
/// Allows placing of markers and showing the correct map
class Maps {
  static List<MapItem> _maplist = [];

  /// Add a [maplist] of maps with asset image filename and two coordinates. One is the pixel position in the image and the other coordinate is its world coordinates
  static init(maplist) async {
    _maplist = maplist;
    for (var mapitem in maplist) {
      // Get the width and height of the image so that can calculate image position from world position
      ByteData imageData = await rootBundle.load(mapitem.filename);
      var bytes = Uint8List.view(imageData.buffer);
      var image = im.decodeImage(bytes);
      mapitem.width = image?.width;
      mapitem.height = image?.height;
    }
  }

  // Return the right map given the world coords [worldx] and [worldy] and return the image coordinates for that map
  // First images should be big one for whole terrain and smaller ones after
  // Will first try to find the first smaller map
  static getMapFromWorldcoords(worldx, worldy) {
    for (var i = _maplist.length - 1; i >= 0; i--) {
      var mapitem = _maplist[i];
      var pos = mapitem.getImageCoordsFromWorldCoords(worldx, worldy);
       print("map posss"+pos.toString());
      if (!(pos[0] < 0 ||
          pos[0] >= mapitem.width ||
          pos[1] < 0 ||
          pos[1] >= mapitem.height))
        return {"imagepos": pos, "map": mapitem};
    }
    return null;
  }
}

/// Class for a single music item including the songs [filename] and [chance] of it being played
class MusicItem {
  late String filename; // Songs asset path
  late double chance; // Chance it is played over other songs
  int nexttick = -1;

  MusicItem(filename, {chance}) {
    this.filename = filename;
    if (chance != null)
      this.chance = chance;
    else
      this.chance = -1;
  }
}

/// Functions related to playing music
class Musics {
  static audioplayers.AudioPlayer music = audioplayers.AudioPlayer();

  static List<MusicItem> _musiclist = [];

  // How long before play a song
  static double timebetweensongs = 5 * 60;

  // Randomness on how long before play a song
  static double randomtimebetweensongs = 50;

  static bool mute = false;

  /// A list of music as a list of asset sound paths and the chance it is played
  static init(musiclist) {
    mute = false;
    _musiclist = musiclist;
    for (var musicitem in _musiclist) {
      if (musicitem.chance == -1) musicitem.chance = 1.0 / _musiclist.length;
    }
    getNext();
  }

  /// [mute] the music
  static setMute(mute) {
    if (mute) {
      if (music.state == audioplayers.PlayerState.playing) music.stop();
    }
    Musics.mute = mute;
  }

  /// Get next based upon probability
  static getNext() {
    var nexttick =
        System.currentMilliseconds() +
        timebetweensongs * 1000 +
        1000 * Math.random() * randomtimebetweensongs;

    double sumprob = 0;
    for (int i = 0; i < _musiclist.length; i++) sumprob += _musiclist[i].chance;
    var chance = (sumprob * Math.random());
    sumprob = 0;

    for (int i = 0; i < _musiclist.length; i++) {
      sumprob += _musiclist[i].chance;
      if (chance < sumprob) {
        _musiclist[i].nexttick = nexttick.toInt();
        return _musiclist[i];
      }
    }
    var pick = Math.randInt(_musiclist.length) - 1;
    _musiclist[pick].nexttick = nexttick;
    return _musiclist[pick];
  }

  /// Check if time to play another song
  static update() async {
    if (Sound.mute || mute) return;
    for (int i = 0; i < _musiclist.length; i++) {
      if (_musiclist[i].nexttick != -1 &&
          System.currentMilliseconds() >= _musiclist[i].nexttick) {
        print("play" + _musiclist[i].filename);
        _musiclist[i].nexttick = -1;

        await music.setSource(audioplayers.AssetSource(_musiclist[i].filename));
        await music.resume();
        getNext();
      }
    }
  }
}
