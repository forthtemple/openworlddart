
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:image/image.dart' as im;

import 'package:audioplayers/audioplayers.dart';
import 'package:openworld/updateable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openworld_gl/native-array/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:just_audio/just_audio.dart';
import 'package:openworld/three_dart/three3d/objects/index.dart';
import 'package:openworld/three_dart/three_dart.dart' as THREE;
import 'dart:math' as math;
import 'package:openworld/three_dart_jsm/three_dart_jsm.dart' as THREE_JSM;
import 'package:audioplayers/audioplayers.dart' as audioplayers;
//import 'package:xml2json/xml2json.dart';

import 'objects/fire.dart';

class Space {


  static late THREE.Scene _scene;
  static late Group _mesh;
  static late THREE.Object3D _roof;
  static late List<THREE.Object3D> _surfaces;
  static late THREE.Object3D _walls;
  static late THREE.Raycaster _raycaster;
  static late List _lerpobjects;
  static late List _lerpobjectssurface;
  static late List _lerpturnobjects;
  static late Map _faceobjects;
  static late List _hideobjects;

  static double wallintersectoffsetz=0.005;


  static init(  mesh, scene) {
    _scene=scene;
    _mesh = mesh;
    _lerpobjects = [];
    _lerpobjectssurface = [];
    _lerpturnobjects=[];
    _hideobjects=[];
    _faceobjects= {};

    // Get all meshes with the word surface in them for surface intersection
    _surfaces=[];
    var _surface = mesh.clone();

    var obj, i;
    for (i = _surface.children.length - 1; i >= 0; i--) {
      obj = _surface.children[i];
      //print("mesh name"+obj.name);
      if (obj.name.indexOf("surface") == -1) {
        _surface.remove(obj);
      }

    }
    _surfaces.add(_surface);

    // Get all meshes with the word wall in them for wall intersection
    _walls = mesh.clone();
    for (i = _walls.children.length - 1; i >= 0; i--) {
      obj = _walls.children[i];
      if (!obj.name.contains("wall")) {
        //==-1) {
        _walls.remove(obj);
      } else {
        // print("leave"+obj.name.toString());
      }
    }
    // Get the roof meshes
    _roof=mesh.clone();  // why must the roof be cloned????
    for (i = _roof.children.length - 1; i >= 0; i--) {
      obj = _roof.children[i];
      if (!obj.name.contains("roof")) {
        _roof.remove(obj);
      } else {
      }
    }
    _raycaster = THREE.Raycaster();
  }

  /// local coords to world coords
  static localToWorld(x, y, z) {
    return new THREE.Vector3(x, -z, y);
  }

  /// get world coords of an object
  static THREE.Vector3 localToWorldObj(object) {
    return localToWorld(object.position.x, object.position.y,
        object.position.z); //new THREE.Vector3(y,z,-x);
  }

  /// convert world coords to local cords
  static worldToLocal(x, y, z) {
    return new THREE.Vector3(x, z, -y);
  }

  /// detect an intersection of a point with surface meshes looking down with local coordinates
  static localIntersectSurface(localx, localy, localz) {
    if (_surfaces!=null&&_surfaces.length>0 &&
        _surfaces[0].children != null &&
        _walls != null &&
        _walls.children != null) {
      //print('hrrr');
      for (var i=0; i<3; i++) {
        //print("inter "+i.toString());
        _raycaster.set(
            new THREE.Vector3(localx, Camera._camera.position.y+i*10+0.3, localz),
            new THREE.Vector3(0, -1, 0));
        // calculate objects intersecting the picking ray
        var intersects = _raycaster.intersectObjects(
            _surfaces[0].children, false); //!!! does it need to be true
        // if (this.testintersect)
        //  print('xxx'+i.toString()+" "+intersects.toString());
        if (intersects.length > 0) {
          //print("vvv"+intersects[0].point.y.toString());
          return intersects[0].point.y;
        }
      }
    }

    return 0;
  }

  /// world coords & camera z that intersects with surface with world coords [x] and [y]
  static worldIntersectSurface(x, y) {
    var localx = x;
    var localz = -y;
    return localIntersectSurface(localx, Camera._camera.position.y, localz);
  }

  /// local coords of world coords intersection with surface looking down
  static worldToLocalSurface(x, y, z) {
    var localx = x;
    var localy = worldIntersectSurface(x, y);
    var localz = -y;
    return new THREE.Vector3(localx, localy + z.toDouble(), localz);
  }

  /// Set position of object to have world coords [x],[y],[z] where [z] is relative to the surface intersection
  /// [delay] position in delay seconds
  static worldToLocalSurfaceObj(object, double x, double y, double z, {delay}) {
    if (delay!=null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        //print("play "+path.toString());
        worldToLocalSurfaceObj(object, x, y, z);
      });
    } else {
      // if being lerped somewhere else then remove it from the lerp
      var ind = _lerpobjects.indexOf(object);
      if (ind >= 0)
        _lerpobjects.splice(ind, 1);
      var position = worldToLocalSurface(x, y, z);
      object.position.set(position.x, position.y, position.z);
    }
  }

  /// Hide an [object] if its over [cameradist] away from [x],[y] and [z] otherwise show it
  /// [lerpopacity] is time to lerp opacity from 1 to 0 so doesnt suddenly hide
  static worldToLocalSurfaceObjHide(object, x, y, z, cameradist, {lerpopacity}) {
    object.extra['cameradist']=cameradist;
    if (lerpopacity!=null)
      object.extra['lerpopacity']=lerpopacity;
    if (_hideobjects.indexOf(object)==-1) {
      _hideobjects.add(object);
    }
    worldToLocalSurfaceObj(object,x.toDouble(),y.toDouble(),z.toDouble());
  }

  /// Stop hiding the object if its away from the camera
  static removeObjFromHide(object)
  {
    if (_hideobjects.contains(object))
      _hideobjects.remove(object);
  }

  static readdObjFromHide(object)
  {
    if (!_hideobjects.contains(object))//&&object.extra.containsKey('cameradist')
      _hideobjects.add(object);
  }

  /// move [object] to [x],[y],[z] taking [time] seconds - lerp to the position
  /// [delay] lerp for [delay] seconds
  static worldToLocalSurfaceObjLerp(THREE.Object3D object, x, y, z, time, {delay}) {
    if (delay!=null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        worldToLocalSurfaceObjLerp( object, x, y, z, time);
      });
    } else {
      THREE.Vector3 position = worldToLocalSurface(x, y, z);
      //object.position.set(position.x, position.y, position.z);
      object.extra['lerpfromtime'] = System.currentMilliseconds();
      object.extra['lerptotime'] = time;
      object.extra['lerpinitialpos'] = object.position.clone();
      object.extra['lerpfinalpos'] = position;
      // object.extra['lerpz']=(position.y-object.position.y).abs()>0.4;

      //if (_lerpobjects.indexOf(object) < 0)
        if (!_lerpobjects.contains(object))
          _lerpobjects.add(object);
    }
  }

  /// lerp [object] to [x],[y],[z] taking [time] seconds only along the terrain surface - useful if moving object across hilly terrain
  /// [delay] lerp for [delay] seconds
  static worldToLocalSurfaceOnlyObjLerp(THREE.Object3D object, x, y, z, time, {delay}) {
    if (delay!=null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        //print("play "+path.toString());
        worldToLocalSurfaceOnlyObjLerp( object, x, y, z, time);
      });
    } else {
     // THREE.Vector3 position = worldToLocalSurface(x, y, z);
      //object.position.set(position.x, position.y, position.z);
      object.extra['lerpsurfacefromtime'] = System.currentMilliseconds();
      object.extra['lerpsurfacetotime'] = time;
      object.extra['lerpsurfaceinitialpos'] = localToWorldObj(object);//object.position.clone();
      object.extra['lerpsurfaceinitialpos'].z=z.toDouble();
      object.extra['lerpsurfacefinalpos'] = THREE.Vector3(x.toDouble(),y.toDouble(),z.toDouble());
      // object.extra['lerpz']=(position.y-object.position.y).abs()>0.4;

      //if (_lerpobjects.indexOf(object) < 0)
      if (_lerpobjects.contains(object))
        _lerpobjects.remove(object);
      if (!_lerpobjectssurface.contains(object))
        _lerpobjectssurface.add(object);
    }
  }

  /// From the [object] from movement lerping
  static removeObjectFromLerp(object)
  {
    if (_lerpobjects.contains(object))
      _lerpobjects.remove(object);
  }

  ///  set [object] to have world coords [x],[y],[z] but not relative to the surface
  static worldToLocalObj(object, x, y, z) {
    var position = worldToLocal(x, y, z);
    object.position.set(position.x, position.y, position.z);
  }

  /// Turn an [object] where [angle] 0 is facing north, 90 east in the world
  static objTurn(THREE.Object3D object, double angle) {
    // if lerping turn somewhere else then remove it
    var ind = _lerpturnobjects.indexOf(object);
    if (ind >= 0)
      _lerpturnobjects.splice(ind, 1);

    angle=Math.standardAngle(angle);
    if (object is THREE.Camera)
      Camera.setTurn(angle);
    //object.rotation.y = (-angle ) * math.pi / 180;
    else
      object.rotation.y = (-angle - 180) * math.pi / 180;
  }

  // Roll an [object] by [angle] degrees
  static objRoll(THREE.Object3D object, double angle) {
    object.rotation.z = (-angle ) * math.pi / 180;
  }

  // Pitch an [object] by [angle] degrees
  static objPitch(THREE.Object3D object, double angle) {
    object.rotation.x = (-angle ) * math.pi / 180;
  }

  /// Turn the [object] [angle] degrees lerping in [time] seconds
  /// [delay] lerp for [delay] seconds
  static objTurnLerp(THREE.Object3D object, double angle, double time, {delay})
  {
    if (delay!=null) {
      Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () async {
        objTurnLerp(object, angle, time);
      });
    } else {
      object.extra['lerpfromtimeturn'] = System.currentMilliseconds();
      object.extra['lerptotimeturn'] = time;

      // So that say if initially 10 and finally 350 then will not lerp 340 degrees, instead 10 to -10 and vice versa
      var turna = getObjTurn(object); // 10              350
      var turnb = Math.standardAngle(angle); // 350       10
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

      object.extra['lerpfinalturn'] = turnb; //Math.standardAngle(angle);
      // print("mmmm"+object.extra['lerpinitialturn'].toString()+" "+angle.toString());

      if (_lerpturnobjects.indexOf(object) < 0)
        _lerpturnobjects.add(object);
    }
  }

  /// [Turn] [pitch] and [roll] [object] using euler so that is as expect eg if roll and then turn seperately then get different result than if turn then roll
  /// pitch x, turn is y, z is roll
  static setTurnPitchRoll(object,turn,pitch,roll)
  {
    object.setRotationFromEuler( THREE.Euler(THREE.MathUtils.degToRad(-roll).toDouble(), THREE.MathUtils.degToRad(180-turn).toDouble(),THREE.MathUtils.degToRad(-pitch).toDouble(), 'YXZ' ));
  }

  /// [object] faces [object2]
  static faceObject(object, object2)
  {
    var angle=getAngleBetweensObjs(object,object2);
    objTurn(object, angle);
  }

  /// [object] faces [object2] taking [time] seconds to do it
  static faceObjectLerp(object, object2, time, {delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: delay * 1000), () {
        faceObjectLerp(object, object2, time);
      });
      BaseObject.addTimer(object, t);
    } else {
      var angle = getAngleBetweensObjs(object, object2);
      objTurnLerp(object, angle, time.toDouble());
    }
  }

  /// [object] faces point [x],[y] taking [time] seconds to do it
  static facePointLerp(object, x,y,time, {delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: delay * 1000), () {
        facePointLerp(object, x,y,time);
      });
      BaseObject.addTimer(object, t);
    } else {
      var pos1 = localToWorldObj(object);
      pos1.z = 0.0;
      var pos2 = THREE.Vector3(x, y, 0.0); //localToWorld(x, y, 0);
      var angle = Math.getAngleBetweenPoints(pos1, pos2);
      // print("uuufacepointlerp"+angle.toString());
      objTurnLerp(object, angle, time.toDouble());
    }

  }

  /// [object] always faces [object2]
  /// [delay] for [delay] seconds
  static faceObjectAlways(object, object2, {delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        faceObjectAlways(object, object2);
      });
      BaseObject.addTimer(object, t);
    } else {
      faceObjectLerp(object,object2,1);  // so doenst just jump
      _faceobjects[object]=object2;
    }
  }

  /// Remove [object] from always facing the other object
  static faceObjectAlwaysRemove(object)
  {
    if (_faceobjects.containsKey(object))
      _faceobjects.remove(object);//]=null;
  }

  /// The angle the object is facing - 0 is north
  static getObjTurn(object) {
    if (object is THREE.Camera) {
      return Camera.turn;//-(180 * object.rotation.y / math.pi);
    }  else
      return -(180*object.rotation.y/math.pi+180);
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
    return math.sqrt((pos1.x - pos2.x) * (pos1.x - pos2.x) +
        (pos1.y - pos2.y) * (pos1.y - pos2.y) +
        (pos1.z - pos2.z) * (pos1.z - pos2.z));
  }

  /// How far between [object1] and [object2] ignoring z axis
  static getDistanceBetweenObjs2D(object1, object2) {
    var pos1 = localToWorldObj(object1);
    var pos2 = localToWorldObj(object2);
    return math.sqrt((pos1.x - pos2.x) * (pos1.x - pos2.x) +
        (pos1.y - pos2.y) * (pos1.y - pos2.y) );
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

  /// Move [object] forward [moveamt]   lerping in [time] seconds
  /// [z] is height above surface
  /// [offset] is how far left or right the [object] is move eg 2 meters forward and 1 meter left offset
  /// [delay] for [delay] seconds
  static objForwardLerp(object, moveamt, time, {delay, offset,z}) {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        objForwardLerp(object, moveamt, time, offset:offset, z:z);
      });
      BaseObject.addTimer(object, t);
    } else {
      var pos = localToWorldObj(object);
      var newpos = Math.vectorMoveFoward(pos.x, pos.y, getObjTurn(object), moveamt);
      if (offset!=null) {
        newpos=Math.vectorMoveFoward(newpos.x, newpos.y,getObjTurn(object)+90, offset);
      }
      if (z==null)
        z=0.0;
      worldToLocalSurfaceObjLerp(object, newpos.x, newpos.y, z, time);
    }
  }


  /// Move [object] at [angle] a distance of [moveamt]
  /// [z] is height above surface
  static objMoveAngleSurface(object, angle, moveamt, z)
  {
      var pos = localToWorldObj(object);
      var newpos = Math.vectorMoveFoward(pos.x, pos.y, angle, moveamt);
      worldToLocalSurfaceObj(object, newpos.x, newpos.y, z.toDouble());

  }

  /// Move [object] at [angle] a distance of [moveamt]  lerping for [time] seconds
  /// [z] is height above surface
  /// [delay] for [delay] seconds
  static objMoveAngleSurfaceLerp(object, angle, moveamt, z,time, {delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        objMoveAngleSurfaceLerp(object, angle, moveamt, z, time);
      });
      BaseObject.addTimer(object, t);
    } else {
      var pos = localToWorldObj(object);
      var newpos = Math.vectorMoveFoward(pos.x, pos.y, angle, moveamt);
      worldToLocalSurfaceObjLerp(object, newpos.x, newpos.y, z.toDouble(), time);
    }
  }

  /// Move [object] forward by [moveamt] along the surface of the terrain. [z] is distance above surface
  static objForwardSurface(object, moveamt, z) {
    object.translateZ(moveamt);
    var localy = localIntersectSurface(
        object.position.x, Camera._camera.position.y, object.position.z);
    object.position.y = localy + z;
  }

  /// Move an [object] left or right relative to direction facing by [moveamt] distance
  static objLeftRight(object, moveamt) {
    object.translateX(moveamt);
  }

  /// Move an [object] left or right relative to direction facing by [moveamt] distance along the surface of the terrain.
  /// [z] is distance above surface
  static objLeftRightSurface(object, moveamt, z) {
    object.translateX(moveamt);
    var localy =
    localIntersectSurface(object.position.x, 999, object.position.z);
    object.position.y = localy + z;
  }

  /// Move [object] [z] distance above the terrain surface
  static objUpSurface(object, z) {
    var localy =
    localIntersectSurface(object.position.x, 999, object.position.z);

    object.position.y = localy + z;
  }

  /// Distance local coordinates are from the wall facing in the direction of the camera
  static distanceWall(localx, localy, localz) {
    if (_surfaces != null &&
        _surfaces[0].children != null &&
        _walls != null &&
        _walls.children != null) {
      return wallIntersectDistance(Camera._camera.position.x, Camera._camera.position.y -wallintersectoffsetz, //0.005, //so that wall doesn't have to be so high
          Camera._camera.position.z, localx, localy, localz);
    } else
      return -2;
  }

  /// Intersection with closest wall from local coordinates.
  /// prevlocal  coordinates specifies the previous location so know what direction the object is heading even if the camera isn't facing in that direction
  /// Player could be moving sideway or backwards so camera angle can't always be used
  static wallIntersectDistance(
      localx, localy, localz, prevlocalx, prevlocaly, prevlocalz) {
    if (_surfaces != null &&
        _surfaces[0].children != null &&
        _walls != null &&
        _walls.children != null) {
      var posVector = new THREE.Vector3(localx, localy, localz);
      var dirVector = new THREE.Vector3(
          localx - prevlocalx, localy - prevlocaly, localz - prevlocalz);
      _raycaster.set(posVector, dirVector);
      // print("xxx"+this._walls.children.length.toString());
      var intersects = _raycaster.intersectObjects(
          _walls.children, false); // ??? does it need to be true?
      if (intersects.length > 0) {
        return intersects[0].distance;
      }
    }
    return -1;
  }

  /// Get the intersect distance from local coordinates with a roof in the terrain
  /// Will initially try interection going up from camera, then try intersection from height above camera looking down
  /// Useful if want to know if player is indoors
  static roofInteresectDistance(localx,localy,localz){

    // Try interesect up from camera
    _raycaster.set(
        new THREE.Vector3(localx, localy, localz),
        new THREE.Vector3(0, 1, 0));  // Raycast upwards
    // calculate objects intersecting the picking ray
    var intersects = _raycaster.intersectObjects(
        _roof.children, false); //!!! does it need to be true
    if (intersects.length > 0) {
      return intersects[0].point.y;
    } else {
      // Try intersect down from a height above camera
      _raycaster.set(
          new THREE.Vector3(localx, localy+1.5, localz),
          new THREE.Vector3(0, -1, 0));  // Raycast downwards
      // calculate objects intersecting the picking ray
      var intersects = _raycaster.intersectObjects(
          _roof.children, false); //!!! does it need to be true
      if (intersects.length > 0) {
        return intersects[0].point.y;
      }
    }
    return -1;

  }

  /// Get the position when place before camera [dist] away with {offset} left or right from the center
  static getPlaceBeforeCameraPos(object,dist, {offset})
  {
    var angle=getObjTurn(Camera._camera);
    var worldpos = localToWorldObj(Camera._camera);
    var pos=Math.vectorMoveFoward(worldpos.x, worldpos.y, angle, dist);

    if (offset!=null) {
      pos=Math.vectorMoveFoward(pos.x, pos.y, angle+90, offset);
    }
   return pos;
  }

  /// position distance [dist] in front of the camera
  /// [offset] is how far left or right from the center in frant of camera. Eg if place three items in front of camera might want one to the left, one middle one on right
  /// [time] specifies lerp time to move the object to the camera
  static placeBeforeCamera(object,dist, {time,offset, z})
  {
    if (z==null)
      z=0.0;
    var pos=getPlaceBeforeCameraPos(object,dist, offset:offset);
    if (time!=null) {
      Space.worldToLocalSurfaceObjLerp(object, pos.x, pos.y, z, time);
    } else
      Space.worldToLocalSurfaceObj(object, pos.x, pos.y,z);
  }


  static int updatetick=0;

  /// Update all the lerping objects for position and rotation and hiding and detect triggers
  static update(frameTime)
  {
    for (var i =_lerpobjects.length - 1; i >= 0; i--) {
      var obj = Space._lerpobjects[i];
      if (obj==null) {
        Space._lerpobjects.remove(obj);//splice(i, 1);
      } else {
        var lerp = (System.currentMilliseconds() - obj.extra['lerpfromtime']) /
            (obj.extra['lerptotime'] * 1000);
        if (lerp >= 1) {
          obj.position.set(obj.extra['lerpfinalpos'].x, obj.extra['lerpfinalpos'].y, obj.extra['lerpfinalpos'].z);
          var inddelete = Space._lerpobjects.indexOf(obj);
          if (inddelete>=-1) {
            Space._lerpobjects.remove(obj);
          }
        } else {

          obj.position.set(
              obj.extra['lerpinitialpos'].x +
                  lerp * (obj.extra['lerpfinalpos'].x - obj.extra['lerpinitialpos'].x),
              obj.extra['lerpinitialpos'].y +
                  lerp * (obj.extra['lerpfinalpos'].y - obj.extra['lerpinitialpos'].y),
              obj.extra['lerpinitialpos'].z +
                  lerp * (obj.extra['lerpfinalpos'].z - obj.extra['lerpinitialpos'].z));
        }
      }
    }

    for (var i = Space._lerpobjectssurface.length - 1; i >= 0; i--) {
      var obj = Space._lerpobjectssurface[i];
      if (obj==null) {
        Space._lerpobjectssurface.remove(obj);//splice(i, 1);
      } else {
        var lerp = (System.currentMilliseconds() - obj.extra['lerpsurfacefromtime']) /
            (obj.extra['lerpsurfacetotime'] * 1000);

        if (lerp >= 1) {
          worldToLocalSurfaceObj(obj,obj.extra['lerpsurfacefinalpos'].x, obj.extra['lerpsurfacefinalpos'].y, obj.extra['lerpsurfacefinalpos'].z);
          if (Space._lerpobjectssurface.contains(obj)) {//inddelete>=-1) {
            //print("removed");
            Space._lerpobjectssurface.remove(obj);
            // print("xxx"+_space._lerpobjects.length.toString());
          }

        } else {
          worldToLocalSurfaceObj(obj,obj.extra['lerpsurfaceinitialpos'].x +
              lerp * (obj.extra['lerpsurfacefinalpos'].x - obj.extra['lerpsurfaceinitialpos'].x),
              obj.extra['lerpsurfaceinitialpos'].y +
                  lerp * (obj.extra['lerpsurfacefinalpos'].y - obj.extra['lerpsurfaceinitialpos'].y),
              obj.extra['lerpsurfaceinitialpos'].z +
                  lerp * (obj.extra['lerpsurfacefinalpos'].z - obj.extra['lerpsurfaceinitialpos'].z));


        }
      }
    }


    for (var i = Space._lerpturnobjects.length - 1; i >= 0; i--) {
      var obj = Space._lerpturnobjects[i];
      if (obj==null) {
        Space._lerpturnobjects.remove(obj);
      } else {
        var lerp = (System.currentMilliseconds() - obj.extra['lerpfromtimeturn']) /
            (obj.extra['lerptotimeturn'] * 1000);

        if (lerp >= 1) {
          Space._lerpturnobjects.remove(obj);
          Space.objTurn(obj, obj.extra['lerpfinalturn']);
        } else {
          var newangle=obj.extra['lerpinitialturn'] +
              lerp * (obj.extra['lerpfinalturn']- obj.extra['lerpinitialturn']);
          if (obj is THREE.Camera)
            Camera.setTurn(newangle);
          else
            obj.rotation.y = (-newangle - 180) * math.pi / 180;

        }
      }
    }

    // Should do this only once a second
    if (updatetick%10==0) {
      for (var i = Space._hideobjects.length - 1; i >= 0; i--) {
        var obj = Space._hideobjects[i];
        if (obj == null) {

          Space._hideobjects.splice(i, 1);
        } else {
          var worldpos = Space.localToWorldObj(Camera._camera);
          var objectpos =Space.localToWorldObj(obj);

          var cameradist = obj.extra['cameradist'];
          var inside=(worldpos.x-objectpos.x).abs()<=cameradist&&(worldpos.y-objectpos.y).abs()<=cameradist;

          if ((obj as THREE.Object3D).visible && !inside) {
            obj.visible = false;

          }
          else if (!(obj as THREE.Object3D).visible && inside) {
          //
            if (obj.extra.containsKey('lerpopacity')&&obj.extra['lerpopacity']>0.0) {
              var initopacity = Texture.getInitialOpacity(obj);
              Texture.opacityLerp(obj, initopacity, obj.extra['lerpopacity']);
              if (obj.extra.containsKey('configname') &&
                  obj.extra['configname'] == 'table')
                print("mmm" + initopacity.toString());
            } else
              obj.visible = true;
          }
        }
      }


      for (var key in Space._faceobjects.keys) {
        // have lerpturnobjects so that dont just jump to facing the camera - lerps first and when finished then looks at camera
        if (key!=null&&key.visible&&!Space._lerpturnobjects.contains(key)) {
          Space.faceObject(key, Space._faceobjects[key]);
        }
      }
    }
    // Occasionally change ambience of sprites - about every 10 seconds
    if (updatetick%100==0) {
      if (Time._ambience!=null) {
        Space._scene.traverse((object) {
          if (object.extra.containsKey('ambient')) {
            object.children[0].material.color =
            Time._ambience?.color as THREE.Color;
            //  object.material = material;
          }
        });
      }
    }
    updatetick++;
  }

}

/// All camera turning should be done here
class Camera
{
  static double turn=0;  // 0 is north in degrees
  static double pitch=0; // degrees up
  static double roll=0;

  static  double width=0;
  static  double height=0;

  static late THREE.Camera _camera;
  static late double cameraoffset; // How far up from the surface in the z direction is the camera //=0.15;

  ///  Set the [camera] and [cameraoffset] from the surface intersection
  static init(camera, cameraoffset, width, height)
  {
    _camera=camera;
    Camera.cameraoffset = cameraoffset;
    Camera.width=width;
    Camera.height=height;

  }


  /// Set the turn of the camera where 0 is north
  static setTurn(turn) {
    Camera.turn = turn.toDouble();
    updateCamera();
  }

  static setPitch(pitch) {
    Camera.pitch = pitch.toDouble();
    updateCamera();
  }

  static setRoll(roll) {
    Camera.roll=roll.toDouble();
    updateCamera();
  }

  /// Update rotation of camera based upopn its pitch, turn and roll
  static updateCamera()
  {
    //                                                                         pitch                                     //turn                               // roll
    Camera._camera.setRotationFromEuler(THREE.Euler( THREE.MathUtils.degToRad(pitch).toDouble(), THREE.MathUtils.degToRad(-turn).toDouble(),THREE.MathUtils.degToRad(roll).toDouble(), 'YXZ' ));

  }

}

/// Status and procedures related to overall system
class System {
  // Allow turn off openworld if move out of the game
  static bool active=true;

  static AppLifecycleState appstate=AppLifecycleState.resumed;

  /// epoch milliseconds elapsed
  static currentMilliseconds() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  static isDesktop()
  {
    return kIsWeb||Platform.isLinux||Platform.isWindows||Platform.isMacOS;
  }

/*  static getFullScreenSize()
  {
    final screens = PlatformDispatcher.instance.displays;
    return screens.first.size;
   // print("size"+fSize.toString());
  }*/

}

/// Procedures related to storing persistent data
class Persistence
{
  static String gamename="";  // So that if two games in web wont mix up cookies in browser
  
  /// Save the variable with [name] with [val] in persistent storage
  /// Doesnt work on web - would need to save on server if use web
  static set(name,val) async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (val is double)
      await prefs.setDouble(gamename+name,val);
    else if (val is bool)
      await prefs.setBool(gamename+name,val);
    else if (val is List<String>)
      await prefs.setStringList(gamename+name,val);
    else
      await prefs.setString(gamename+name,val.toString());
  }

  /// Get the persistent value of variable [name] and if its not found use the default value [def] instead
  static get(name,{def}) async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await prefs.containsKey(gamename+name)) {
      print("found"+name);
      return await prefs.get(gamename+name);
    } else {
      print("not found"+name);

      return def;
    }
  }

  /// Remove variable [name] from persistent storage
  static remove(name) async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(gamename+name);
  }

  /// Clear persistent storage in its entirety
  static reset() async
  {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

  }
}


/// functions for sound such as fading in and out
class Sound {
  static bool mute=false;

  static List<Map> soundlist=[];  // Audioplayers to be faded
  static List soundpool=[];   // Audioplayer list - with list can mute all sounds

 static Map durations={};

  /// Play a sound using [sound] audioplayer.
  /// Can set [path] of asset or leave null to play whatever the audioplayer is loaded with
  /// Can set [volume] of sound
  /// Can [delay] playing the sound in seconds
  /// Set play the sound from position [seek] seconds instead of from the start
  /// [obj] is object3d that sounds belong to so can clear the timer if need too
  static play( { sound, path, volume, delay, seek, loop, fadein, obj}) async
  {
    var duration=-1.0;
    if (mute)
      return;
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        play(sound:sound, path:path, volume:volume, seek:seek, loop:loop, fadein:fadein );
      });
      if (obj!=null)
        BaseObject.addTimer(obj, t);
    } else {
      if (sound == null) {
        sound = getAudioPlayer();
      }
      if (loop!=null&&loop)
        sound.setReleaseMode(audioplayers.ReleaseMode.loop);
      else
        sound.setReleaseMode(audioplayers.ReleaseMode.release);

      if (sound.state == audioplayers.PlayerState.playing)
        await sound.stop();
      if (path != null) {
        await sound.setSource(audioplayers.AssetSource(path));
        if (durations.containsKey(path))
          duration =durations[path];
        else {
          //print('getduration'+player.toString()+" path"+path.toString());
          var dur= await sound.getDuration();//.setUrl(path);
          if (dur!=null) {
            duration = dur!.inMilliseconds / 1000.0;
          } else
            duration=-1;
          durations[path] = duration;

        }

      }
      if (volume != null)
        sound.setVolume(volume.toDouble());
      if (seek!=null)
        sound.seek(Duration(milliseconds: (seek*1000).round()));
      if (fadein!=null) {
        await sound.resume(); //play();
        fadeIn(sound, fadein);
      } else
        await sound.resume(); //play();
    }
    return duration;

  }


  /// either get an audioplayer thats not being used or make one
  /// Use a pool allows the list of all the audioplayers to be muted
  static getAudioPlayer()
  {
  //  print("stacktrace"+StackTrace.current.toString());
    for (var sound in soundpool)
      if (sound.state != audioplayers.PlayerState.playing)
        return sound;

    var sound = audioplayers.AudioPlayer();
    soundpool.add(sound);
    return sound;

  }

  /// [Mute] all audioplayers in the sound pool
  static setMute(mute)
  {
    if (mute) {
      for (var sound in soundpool)
        if (sound.state == audioplayers.PlayerState.playing)
          sound.stop();
    }
    Sound.mute=mute;
  }

  // fade [soundfrom] to zero in [fadetime] seconds and then play [soundto]
  // fade from [soundfrom] to [soundto] in [fadetime]
  static playFade(audioplayers.AudioPlayer soundfrom, audioplayers.AudioPlayer soundto, fadetime) {
    soundlist.add({'soundfrom':soundfrom, 'soundto':soundto, 'fadetime':fadetime,'fadestarttick': System.currentMilliseconds(), 'fromvolume':soundfrom.volume, 'tovolume':soundto.volume});
  }

  /// Remove [sound] audioplayer from list of sounds to fade
  static removeSoundList(audioplayers.AudioPlayer sound)
  {
     for (var i=soundlist.length-1; i>=0; i--)
       if ((soundlist[i].containsKey('soundto')&&soundlist[i]['soundto']==sound)||(soundlist[i].containsKey('soundfrom')&&soundlist[i]['soundfrom']==sound))
         soundlist.removeAt(i);
  }

  /// Fade into [sound] gradually in [fadetime] seconds
  static fadeIn( audioplayers.AudioPlayer sound, fadetime)
  {
    // Remove any existing in soundlist
    removeSoundList(sound);
    soundlist.add({'soundto':sound, 'fadetime':fadetime,'fadestarttick': System.currentMilliseconds(), 'tovolume':sound.volume});
  }

  /// Fade out [sound] gradually in [fadetime] seconds
  static fadeOut( audioplayers.AudioPlayer sound, fadetime)
  {
    // Remove any existing in soundlist
    removeSoundList(sound);
    soundlist.add({'soundfrom':sound,  'fadetime':fadetime,'fadestarttick': System.currentMilliseconds(), 'fromvolume':sound.volume});
  }

  /// Is the [sound] playing
  /// Glitch in ios where if looping then player state is not playing therefore use this procedure instead
  static isPlaying( audioplayers.AudioPlayer sound)
  {
    return (sound.state == audioplayers.PlayerState.playing)||(sound.releaseMode==audioplayers.ReleaseMode.loop&&sound.state==audioplayers.PlayerState.completed);
  }

  /// Update the fading sounds volume
  static update() {
    for (var i=soundlist.length-1; i>=0; i--) {
      var item=soundlist[i];
      var lerp= (System.currentMilliseconds() - item['fadestarttick']) / (item['fadetime'] * 1000);
      if (lerp>=1) {
        if (item.containsKey('soundfrom')&&isPlaying(item['soundfrom']))//item['soundfrom'].state == audioplayers.PlayerState.playing) //playing)
          item['soundfrom'].stop();

        soundlist.splice(i);
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

  /// angle between two vectors [v] and [v2]
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

  /// distance between vector [v] and [v2] in 2D
  static vectorDistance(THREE.Vector3 v, THREE.Vector3  v2) {
    var deltaX = v.x - v2.x;
    var deltaY = v.y - v2.y;
    return math.sqrt((deltaX * deltaX) + (deltaY * deltaY));
  }

  /// Give the vector [angle] degrees forward of point [x],[y] with [dist] distance from x,y
  static vectorMoveFoward(x,  y,  angle,  dist)
  {
    double rad=THREE.MathUtils.degToRad(angle).toDouble();
    //System.out.println("angle"+angle);
    return THREE.Vector2(x+math.sin(rad)*dist, y+math.cos(rad)*dist);
  }

  /// Generate a random number between 0 and 1
  static random({seed:null})
  {
    var rng = math.Random(seed);
    return  rng.nextDouble();
  }

  /// Generate a random number between 0 and [max]
  static randInt(max) {
    var rng = math.Random();
    return rng.nextInt(max);
  }

  /// Standardize [angle] between 0 and 360
  static standardAngle(angle)
  {
    return ((angle % 360) + 360) % 360;
  }
}


/// Functions for game control with keyboard
class Keyboard {
  Map keyCodes = {};
  Map modifiers = {};

  Map ALIAS = {
    'left': LogicalKeyboardKey.arrowLeft.keyId, //37,
    'up': LogicalKeyboardKey.arrowUp.keyId, //38,
    'right': LogicalKeyboardKey.arrowRight.keyId, //39,
    'down': LogicalKeyboardKey.arrowDown.keyId, //40,
    'space': 32,
    'pageup': 33,
    'pagedown': 34,
    'tab': 9,
    'escape': 27
  };

  List MODIFIERS = ['shift', 'ctrl', 'alt', 'meta'];

  onKeyChange(LogicalKeyboardKey event, eventtype) {
    // update this.keyCodes
    var keyCode = event.keyId;

    var pressed = eventtype == 'keydown' ? true : false;

    this.keyCodes[keyCode] = pressed;

    // update this.modifiers
    this.modifiers['shift'] =
        event.keyId == LogicalKeyboardKey.shift.keyId; //shiftKey;
    this.modifiers['ctrl'] =
        event.keyId == LogicalKeyboardKey.control.keyId; //event.ctrlKey;
    this.modifiers['alt'] =
        event.keyId == LogicalKeyboardKey.alt.keyId; //event.altKey;
    this.modifiers['meta'] =
        event.keyId == LogicalKeyboardKey.meta.keyId; //event.metaKey;
  }

  // eg right
  pressed(keyDesc) {
    var keys = keyDesc.split("+");
    for (var i = 0; i < keys.length; i++) {
      String key = keys[i];
      var pressed = false;
      if (MODIFIERS.indexOf(key) != -1) {
        pressed = this.modifiers[key];
      } else if (ALIAS.containsKey(key)) {
        if (this.keyCodes.containsKey(ALIAS[key])) {
          pressed = this.keyCodes[ALIAS[key]];

        }
      } else if (this.keyCodes.containsKey(key.toUpperCase()[0])) {
        pressed = this.keyCodes[key.toUpperCase()[0]];
      }
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

  int joysticksize=320;  // How big is the joystick so know to ignore touches in that area
  double minpitch=-25;   // Mininum camera pitch allowed - make zero if no lower limit
  double maxpitch=25;    // Maximum camera pitch allowed - make zero if no upper limit

  /// Initialise joystick with the pixel size of the joystick [joysticksize] so doesn't get confused with screenswipe
  /// [minpitch] and [maxpitch] is the maximum and minimum pitch of the camera so that dont end up with the camera up in the air or pointing down at the ground
  VirtualJoystick({joysticksize,minpitch, maxpitch}) {
    // this._space = space;
    this._active = true;
    keyboard = Keyboard();
    if (joysticksize!=null)
      this.joysticksize=joysticksize;
    if (minpitch!=null)
      this.minpitch=minpitch;
    if (maxpitch!=null)
      this.maxpitch=maxpitch;
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
    if (You.immobileturn)
      return;
    // If close to joystick then ignore so stop big jumps
    if (!System.isDesktop()&&(clientX<joysticksize||_lastClientX<joysticksize)&&(_lastClientY<joysticksize||clientY<joysticksize)) {
      print('miss '+_lastClientX.toString()+" "+ clientX.toString()+" "+_lastClientY.toString() +" "+clientY.toString());
      _lastClientX = clientX;
      _lastClientY = clientY;
      return;
    }
    // divide by 6 size that dont accidently change pitch
    if ((_lastClientX - clientX).abs() > (_lastClientY - clientY).abs()/6) {
      // Mean horizontal swipe so turn
      Camera.setTurn(Camera.turn-(30000*delta * ((_lastClientX - clientX) / screenWidth)));//THREE.MathUtils.radToDeg(roty));
    } else {

      // Vertical swipe so pitch
      //print("rotupdown"+_lastClientX.toString()+" "+ clientX.toString()+" "+_lastClientY.toString() +" "+clientY.toString());
      var newpitch=Camera.pitch+(30000*delta * ((_lastClientY - clientY) / screenHeight));
      if ((minpitch==0||newpitch>minpitch)&&(maxpitch==0||newpitch<maxpitch))
        Camera.setPitch(newpitch);
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
  update(frameTime)
  {
    // if low framerate then cap the frame so dont jump too far
    if (frameTime>0.05) {
      frameTime = 0.05;
      print("capped frametime");
    }

    if (!this._screenpressed) {
      /// This part seems redundant as this is always active
      if (!this._active &&
          !this.keyboard.pressed("W") &&
          !this.keyboard.pressed("S") &&
          !this.keyboard.pressed("up") &&
          !this.keyboard.pressed("down")&&
          !You.immobileturn) {
        // This is if you turn with the keyboard  left or right
        var rotamt;
        if (!System.isDesktop())//kIsWeb)
          rotamt = 0.15; // this is redundant because you woudln't use a keyboard on a smartphone
        else
          rotamt = 1.2;

        Camera.setTurn(Camera.turn-targetRotationY * frameTime * rotamt);
        Camera._camera.up = new THREE.Vector3(0, 1, 0);
      } else {

      }
    }

    // Make sure camera up is pointing up
    Camera._camera.up = new THREE.Vector3(0, 1, 0);

    targetRotationX = 0;
    targetRotationY = 0;

    var rotamt;
    if (!System.isDesktop())//kIsWeb) //this._ismobile)
      rotamt = 150;
    else
      rotamt = 300;

    // For smartphones joystick left and right turns you left and right while on web will slide you left and right
    var joystickturn = !System.isDesktop();//kIsWeb;//true;

    // This is for the keyboard
    if (this._active) {

      if (this.keyboard.pressed("D") || this.keyboard.pressed("right")) {
        if (joystickturn&&!You.immobileturn) {
          Camera.setTurn(Camera.turn+frameTime * rotamt);// * math.pi / 180);//_camera.rotateY(frameTime * rotamt * math.pi / 180);
        } else if (!You.immobile) {
          Space.objLeftRightSurface(
              Camera._camera, You.speed * You.drag * frameTime,
              Camera.cameraoffset);
        }

      }
      if (this.keyboard.pressed("A") || this.keyboard.pressed("left")) {
        if (joystickturn&&!You.immobileturn)
          Camera.setTurn(Camera.turn-frameTime * rotamt);
          //Camera._camera.rotateY(-frameTime * rotamt * math.pi / 180);
        else if (!You.immobile) {
          Space.objLeftRightSurface(
              Camera._camera, -You.speed * You.drag * frameTime,
              Camera.cameraoffset);
        }
      }
      if ((this.keyboard.pressed("W") || this.keyboard.pressed("up"))&&!You.immobile) {

        Space.objForwardSurface(
            Camera._camera, -You.speed* You.drag * frameTime, Camera.cameraoffset);
      }
      if ((this.keyboard.pressed("S") || this.keyboard.pressed("down")&&!You.immobile)) {
        Space.objForwardSurface(
            Camera._camera, You.speed* You.drag * frameTime, Camera.cameraoffset);
      }

    }

    // This is for the joystick
    // If smartphone then the joystick left and right turns you left and right while if web then will slide you left and right
    if (this._active) {
     // const fct = 3;
      if (this.right() > 0) {
        if (joystickturn&&!You.immobileturn)
          Camera.setTurn(Camera.turn+frameTime *  this.right() *this.right() * rotamt);
        else if (!You.immobile)
          Space.objLeftRightSurface(Camera._camera,
              You.speed* You.drag * this.right() * frameTime, Camera.cameraoffset);
      }
      if (this.left() > 0) {
        if (joystickturn&&!You.immobileturn)
          Camera.setTurn(Camera.turn-frameTime *  this.left() *this.left() * rotamt);
        else if (!You.immobile)
          Space.objLeftRightSurface(Camera._camera,
              -You.speed* You.drag * this.left() * frameTime, Camera.cameraoffset);
      }
      if (this.up() > 0&&!You.immobile) {
        //camera.position.z = camera.position.z -  amt * frameTime;
        Space.objForwardSurface(Camera._camera,
            -You.speed* You.drag * this.up()*You.drag * frameTime, Camera.cameraoffset);
      }
      if (this.down() > 0&&!You.immobile) {
        Space.objForwardSurface(Camera._camera,
            You.speed* You.drag* this.down() * frameTime, Camera.cameraoffset);
      }
    }

  }
}

/// Functions for textures such as creating a text texture and lerping opacity of texture
class Texture {
  static List _lerpopacityobjects = [];
  static String defaultfontfamily="";   // Set this so that you can use a default font family without needing to specify it every time

  /// Create a text sprite with text [message] with color [textcolor] and size [fontSize] and background of color [backgroundcolor] with opacity [backgroundopoacity]
  /// [z] is how high make the sprite
  /// [width] how wide to make the sprite
  /// [fontfamily] is the font family of text
  /// [bold] is whether the text is bold or not
  static makeText(message, Color textcolor,
      {fontSize: 20, z: 0, backgroundcolor: Colors
          .black, backgroundopacity: 0.5, width: 200, fontfamily, bold}) async {
    final recorder = PictureRecorder();
    var canvas = Canvas(recorder);

    var textStyle;
    var usefontfamily="";
    if (defaultfontfamily!="")
      usefontfamily=defaultfontfamily;
    else if (fontfamily!=null)
      usefontfamily=fontfamily;
    var fontWeight;
    if (bold!=null&&bold)
      fontWeight=FontWeight.bold;
    else
      fontWeight=FontWeight.normal;
    if (usefontfamily=="")
      textStyle=TextStyle(
      color: textcolor, //Colors.white,
      fontSize: fontSize.toDouble(),
      fontWeight: fontWeight,
      backgroundColor: backgroundcolor.withOpacity(
          backgroundopacity.toDouble()),
    );
    else
      textStyle=TextStyle(
          fontFamily: usefontfamily,
        color: textcolor, //Colors.white,
        fontSize: fontSize.toDouble(),
        fontWeight:fontWeight,
        backgroundColor: backgroundcolor.withOpacity(
            backgroundopacity.toDouble()),
      );

    var textSpan = TextSpan(
      text: message,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    //double width = 200;
    double height = 20;
    textPainter.layout(
      minWidth: 0,
      maxWidth: width.toDouble(),
    );
    width = textPainter.width;
    height = textPainter.height; //
    final xCenter = 0.0; // (width - textPainter.width) / 2;
    final yCenter = 0.0;
    ; // (height - textPainter.height)/2;//*0.7;
    final offset = Offset(xCenter, yCenter);
    textPainter.paint(canvas, offset);
    //YourPainter.paint(Canvas, Size(width,height)); // paint stuff somehow on canvas
    var im = (await recorder.endRecording().toImage(width.toInt(),
        height.toInt())); //width * sizeRatio, height * sizeRatio);
    // print("ooo"+im.width.toString()+"xxx"+im.height.toString());
    var pngBytes = await im.toByteData(format: ImageByteFormat.rawRgba);
    Uint8Array data = Uint8Array.from(pngBytes!.buffer.asUint8List());
    THREE.ImageElement imageelement = THREE.ImageElement(
        data: data, width: width.toInt(), height: height.toInt());

    var texturei = THREE.DataTexture(
        imageelement.data,
        width.toInt(),
        height.toInt(),
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null);

    texturei.needsUpdate = true;

    // Must flip in y direction
    texturei.wrapT = THREE.RepeatWrapping;
    texturei.repeat.y = -1;
    return {"texture": texturei, "width": width, "height": height};
  }

  /// Get the opacity of an [object] - just returns the opacity of the last material it finds while traversing
  static getOpacity(object)
  {
    var ret = 1.0;
    object.traverse((child) {
      if (child.material is THREE.Material) {
        if (child.material.opacity != null) {
          // print("found material"+child.material.opacity.toString());
          ret = child.material.opacity.toDouble();
        }
      }
    });
    return ret; // 1.0;

  }

  /// Set the [opacity] of every material in an [object]
  static setOpacity(object, opacity) {
    object.traverse((child) {
      if (child.material is THREE.Material) {
        child.material.opacity = opacity;
        child.material.transparent = true;
      }
    });
  }

  /// Set the [emissive] color of every material in an [object]
  static setEmissive(object, THREE.Color emissive) {
    object.traverse((child) {
      if (child.material is THREE.Material) {
        child.material.emissive = emissive;
      }
    });
  }

  /// Why is this returning 1?
  static getInitialOpacity(object)
  {
    if (!object.extra.containsKey('lerpinitialopacityfirst')) {
      if (object.extra.containsKey('configname')&&object.extra['configname']=='table')
        print("get init");
      object.extra['lerpinitialopacityfirst'] = getOpacity(object);
    }
    return 1;//object.extra['lerpinitialopacityfirst'];


  }

  /// [Flip] child material of [obj] in horizonal direction
  /// works for planes and sprites - should really  traverse
  static flipx(obj,flip)
  {
    if (flip) {
      (obj.children[0].material as THREE.Material).map?.wrapS =
          THREE.RepeatWrapping;
      (obj.children[0].material as THREE.Material).map?.repeat.x = -1.0;
    } else
      (obj.children[0].material as THREE.Material).map?.repeat.x = 1;
  }

  /// [flip] child material of [obj] in vertical direction
  /// works for planes and sprites - should really traverse
  static flipy(obj,flip)
  {
    if (flip) {
     // (obj.children[0].material as THREE.Material).map?.wrapS =
      //    THREE.RepeatWrapping;
      (obj.children[0].material as THREE.Material).map?.flipY=false;
    } else
      (obj.children[0].material as THREE.Material).map?.flipY=true;
  }

  /// Lerp the opacity of the material in [object] to [opacity] in [time] seconds
  static opacityLerp(object, opacity, time)
  {
    object.extra['lerpfromtimeopacity'] = System.currentMilliseconds();
    object.extra['lerptotimeopacity'] = time;

    var currentopacity=getOpacity(object);//getInitialOpacity(object);//getOpacity(object);;
    if (!object.visible)
      object.extra['lerpinitialopacity']=0;
    else
      object.extra['lerpinitialopacity'] =  currentopacity;

    object.extra['lerpfinalopacity'] =opacity;

    if (_lerpopacityobjects.indexOf(object) < 0)
      _lerpopacityobjects.add(object);
  }

  /// Update opacity lerps
  static update(frameTime)
  {
    for (var i = _lerpopacityobjects.length - 1; i >= 0; i--) {
      var obj = _lerpopacityobjects[i];
      if (obj==null) {
        _lerpopacityobjects.remove(obj);
      } else {
        var lerp = (System.currentMilliseconds() - obj.extra['lerpfromtimeopacity']) /
            (obj.extra['lerptotimeopacity'] * 1000);
        if (lerp >= 1) {
          _lerpopacityobjects.remove(obj);
          setOpacity(obj, obj.extra['lerpfinalopacity']);
          obj.visible=obj.extra['lerpfinalopacity']>0;
        } else {
          var newopacity=obj.extra['lerpinitialopacity'] +
              lerp * (obj.extra['lerpfinalopacity']- obj.extra['lerpinitialopacity']);
          obj.visible= newopacity>0;
          setOpacity(obj, newopacity);

        }
      }
    }
  }
}


/// Class for a trigger when an object such as a model, plane, sprite or actor is touched
class TouchTrigger with THREE.EventDispatcher {

  TouchTrigger()//{time:0.5})
  {
  }

  trigger(val)
  {
    print('trigger');
    this.dispatchEvent(THREE.Event( { 'type': 'trigger','action':val }) );
  }

  triggermenu(val)
  {
    print('triggermenu openworld');
    this.dispatchEvent(THREE.Event( { 'type': 'triggermenu','action':val }) );

  }
}

/// Class to allow creation of distance trigger for rooms, npcs, plants etc
class DistanceTrigger with THREE.EventDispatcher {
  late double ndist,edist,sdist, wdist;//dist;
  bool inside=false;
  late bool ignoreifhidden;

  /// Initialize distance trigger that is attached ot an object that has a rectangle around it [ndist] north, [sdist] south, [edist] east and [wdist] west of
  /// the objects position and will be triggered if the camera goes within this rectangle
  /// If [ignoreifhidden] is true then the trigger occurs even if the object the trigger is attached is hidden
  DistanceTrigger(ndist,edist,sdist, wdist, {ignoreifhidden:true})
  {
    this.ndist=ndist.toDouble();
    this.edist=edist.toDouble();
    this.sdist=sdist.toDouble();
    this.wdist=wdist.toDouble();//dist=dist;
    this.ignoreifhidden=ignoreifhidden;
  }

  trigger(val)
  {
    print('trigger');
    this.dispatchEvent(THREE.Event( { 'type': 'trigger','action':val }) );
  }


}

/// Class to allow creation of customer trigger for any object eg models, sprites, actors - eg a trigger when actor is attacked
class CustomTrigger with THREE.EventDispatcher {

  CustomTrigger()
  {
  }

  trigger(name, val)
  {
    print('custom trigger'+name);
    this.dispatchEvent(THREE.Event( { 'type': name,'action':val }) );
  }
}


/// This is the base class for all objects and includes sprites, models, actors, planes
class BaseObject {
  static List _triggers = [];
  static List _touchtriggers = [];
  static double touchtriggerwait = 0.3;
  static List _highlightobjects = []; // so can hide them all

  static THREE.Raycaster ray = THREE.Raycaster();

  /// Add a [timer] to [object] - record so can remove all timers if necessary
  static addTimer(obj, timer) {
    if (!obj.extra.containsKey('timers'))
      obj.extra['timers'] = [];
    if (!obj.extra['timers'].contains(timer))
      obj.extra['timers'].add(timer);
  }

  /// Get all of [obj] timers
  static getTimers(obj)
  {
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

  /// Clear everything for [obj] including timers, randomwalk, moving, text, chatter, speech, lerping
  static clearAll(obj)
  {
    Space.faceObjectAlwaysRemove(obj);
    // Kill any random walk
    if (obj.extra.containsKey('movetoidrand'))
      obj.extra.remove('movetoidrand');
    // Kill any moveto walk
    if (obj.extra.containsKey('movetoid'))
      obj.extra.remove('movetoid');
    clearTimers(obj);
    Mob.clearText(obj);
    Mob.pauseChatter(obj);
    Mob.pauseSpeech(obj);
    Space.removeObjectFromLerp(obj);
  }

  /// Set the [scale] of an [obj] highlight
  /// Override [scale] with [scalex] , [scaley] and [scalez] if want to scale highlight in different axis
  static setHighLightScale(THREE.Object3D obj,
      {scale: 1.05, scalex, scaley, scalez}) {
    if (!obj.extra.containsKey('selectx')) {
      obj.extra['selectx'] = obj.scale.x;
      obj.extra['selecty'] = obj.scale.y;
      obj.extra['selectz'] = obj.scale.z;
    }
    var sx = scale;
    var sy = scale;
    var sz = scale;
    if (scalex != null)
      sx = scalex;
    if (scaley != null)
      sy = scaley;
    if (scalez != null)
      sz = scalez;

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
      if (object is Mesh) {
        object.material.opacity = opacity; //.blending= THREE.AdditiveBlending;
      }
    });
  }

  /// Given an [obj] a select highlight and add to the scene [parent] with [color], [opacity]
  /// Can set the [scale] of hightlight and override in different axis with [scalex], [scaley] and [scalez]
  /// Can change the opacity when deselected with [deselectopacity]
  /// Can change the scale when deselected with [deselectscale]
  static setHighlight(obj, parent, color, opacity,
      {scale: 1.05, scalex, scaley, scalez, deselectopacity, deselectscale}) {
    var outlineMaterial2 = new THREE.MeshBasicMaterial(
        { "color": color, "side": THREE.BackSide});
    outlineMaterial2.opacity = opacity;
    outlineMaterial2.transparent = true;
    obj.extra['deselectopacity'] = deselectopacity;
    obj.extra['deselectscale'] = deselectscale;
    var clone;
    if (obj.extra.containsKey('animations'))
      clone = THREE_JSM.SkeletonUtils.clone(obj);
    else
      clone = obj.clone();
    obj.extra['select']=clone;
    // If hiding then obj then do the same for the selection
    if (Space._hideobjects.contains(obj)&&obj.parent==parent) {//parent.contains(obj)) {
      clone.extra['cameradist']=obj.extra['cameradist'];
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
      obj.extra['select'].children[1].position.y = -(height / 2) +
          obj.extra['select'].children[1].scale.y / 2; //linescale/2;
      obj.extra['select'].children[2].scale.x = width * linescale / 2;
      obj.extra['select'].children[2].position.z = -(width / 2) +
          obj.extra['select'].children[2].scale.x / 2; //linescale/2;
      obj.extra['select'].children[3].scale.x = width * linescale / 2;
      obj.extra['select'].children[3].position.z = (width / 2) -
          obj.extra['select'].children[3].scale.x / 2; //linescale/2;
      obj.extra['select'].children[0].scale.y = height * linescale / 2;
      obj.extra['select'].children[0].position.y = (height / 2) -
          obj.extra['select'].children[0].scale.y / 2; //linescale/2 ;

    }
    setHighLightScale(
        obj, scale: scale, scalex: scalex, scaley: scaley, scalez: scalez);
    obj.extra['select'].visible = false;
    obj.extra['select'].traverse((object) {
      if (object is Mesh) {
        object.material =
            outlineMaterial2; //.blending= THREE.AdditiveBlending;
      }
    });
    parent.add(obj.extra['select']);

    if (!_highlightobjects.contains(obj))
      _highlightobjects.add(obj);
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
        if (scale != null)
          setHighLightScale(obj, scale: scale);
        if (opacity != null)
          setHighLightOpacity(obj, opacity);
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
  static setDistanceTrigger(object,
      {dist, ndist, edist, wdist, sdist, ignoreifhidden: true}) {
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
      object.extra['trigger'].ignoreifhidden=ignoreifhidden;
    } else {
     // disableDistanceTrigger(object);
      if (dist != null)
        object.extra['trigger'] = DistanceTrigger(
            dist.toDouble(), dist.toDouble(), dist.toDouble(), dist.toDouble(),
            ignoreifhidden: ignoreifhidden);
      else {
        print(
            "ndist" + ndist.toString() + " edist" + edist.toString() +
                " sdist" +
                sdist.toString() + " wdist" + wdist.toString());
        object.extra['trigger'] = DistanceTrigger(
            ndist, edist, sdist, wdist, ignoreifhidden: ignoreifhidden);
      }
      _triggers.add(object);
    }
  }

  /// Delete the distance trigger for the [object]
  static disableDistanceTrigger(object) {
    if (_triggers.contains(object))
      _triggers.remove(object);
  }

  // reenable the distance trigger for [object]
  static reenableDistanceTrigger(object) {
    if (!_triggers.contains(object) && object.extra.containsKey('trigger'))
      _triggers.add(object);
  }

  /// Set an [object] to have a trigger when the object is touched
  static setTouchTrigger(object) //,{time:0.5})
  {
    disableTouchTrigger(object);
    var trigger = TouchTrigger(); //time:time);
    object.traverse((child) {
      child.extra['touchtrigger'] = trigger;
    });
    object.extra['touchtrigger'] = trigger;
    _touchtriggers.add(object);
  }

  /// Delete the touch trigger for the [object]
  static disableTouchTrigger(object) {
    if (_touchtriggers.contains(object))
      _touchtriggers.remove(object);
  }

  /// For the objects touched any then trigger the touchtrigger if they have one
  /// [pointerdowntick] is when the mouse was clicked so that dont trigger  all the time
  /// [event] is the mouse position
  /// [parent] is the scene that check for intersections of
  /// [width] and [height] is the width and height of screen
  /// [numpoints] is how many spots will check for interections - this is useful if low frame rate and isn't finding touched objects - try more often if low framerate
  static touchup(pointerdowntick, event, parent, width, height, numpoints) {
    var found = false;
    if (System.currentMilliseconds() - pointerdowntick >
        touchtriggerwait * 1000) {
      for (var i=-numpoints/2; i<numpoints/2; i++) {
        if (!found) {
          var mouse = THREE.Vector2(event.clientX, event.clientY);
          var offsetdx = 0;
          var offsetdy = 0;
          THREE.Vector2 convertPosition(THREE.Vector2 location) {
            double _x = ((location.x+i) / (width - offsetdx)) * 2 - 1;
            double _y = -((location.y+i) / (height - offsetdy)) * 2 + 1;
            return THREE.Vector2(_x, _y);
          }
          ray.setFromCamera(convertPosition(mouse), Camera._camera);
          List<THREE.Intersection> intersects = ray.intersectObjects(
              parent.children, true);
          if (intersects.isNotEmpty) {
           // print("clicked soemthign" + intersects.length.toString());
            var hasdone = [];
            for (var intersect in intersects) {
              if (intersect.object.visible &&
                  intersect.object.extra.containsKey('touchtrigger') &&
                  !hasdone.contains(intersect.object.extra['touchtrigger'])) {
                print("touched trigger in here");
                // boat.extra['select'].visible =!boat.extra['select'].visible;
                hasdone.add(intersect.object.extra['touchtrigger']);
                intersect.object.extra['touchtrigger'].trigger(event);
                found = true;

              }
            }
          }
        }

      }
    }
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
      return object.extra['customtrigger'].hasEventListener(name,null);
    }
    return false;
  }

  /// Check if should trigger distance triggers
  static update(frameTime) {
    for (var i = _triggers.length - 1; i >= 0; i--) {
      var obj = _triggers[i];
      DistanceTrigger trigger = obj.extra['trigger'];
      if (obj == null) {
        _triggers.splice(i, 1);
      } else
      if ((obj.visible && trigger.ignoreifhidden) || !trigger.ignoreifhidden) {
        var worldpos = Space.localToWorldObj(Camera._camera);
        var objectpos = Space.localToWorldObj(obj);

        var inside = worldpos.x >= objectpos.x - trigger.wdist &&
            worldpos.x < objectpos.x + trigger.edist &&
            worldpos.y >= objectpos.y - trigger.sdist &&
            worldpos.y <= objectpos.y + trigger.ndist;

        if (trigger.inside && !inside) { //dist > cameradist) {
          obj.extra['trigger'].inside = false;
          obj.extra['trigger'].trigger(false);
        } else if (!trigger.inside && inside) { //]dist <= cameradist) {
          obj.extra['trigger'].inside = true;
          obj.extra['trigger'].trigger(true);
        }
      }
    }
  }

  /// Make [object] [visible] in [delay] seconds
  static setVisible(object, visible, {delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        setVisible(object,visible);
      });
      BaseObject.addTimer(object, t);

    } else {
      object.visible=visible;
    }
  }

}

/// Procedures related to mesh models
class Model
{
  /// Load a model of [path] and can replace its [texture]
  static createModel(path,{texture}) async
  {
    var loaderu = THREE_JSM.GLTFLoader(null);
    print("model path"+path.toString());
    var gltf = await loaderu.loadAsync(path); //ii.gltf');
    //print("ooo"+gltf.toString());
    var model = gltf["scene"];
    if (texture!=null) {
      await setTexture(model,texture);
    }

    // For some reason gltfloader doesn't turn on transparency when transparent material is used so set it here
    model.traverse( (child) {
      if(child is THREE.Mesh && child.material is THREE.MeshStandardMaterial){
        // print("oo"+(child.material as THREE.MeshStandardMaterial).name.toString());
        if ((child.material as THREE.MeshStandardMaterial).name.contains(".png"))
          child.material.transparent = true;
      }
    });
    return model;
  }

  /// Apply texture to [model] to all meshes or to the mesh specified by [meshname]
  static setTexture(model, texturepath, {meshname}) async {
    var texture = await THREE.TextureLoader().loadAsync(texturepath);

    var material = THREE.MeshStandardMaterial({'map': texture});
    material.needsUpdate = true;
    if (kIsWeb) {
      // must flip for web for some reason
      material.map?.wrapT =
          THREE.RepeatWrapping;
      material.map?.repeat.y = -1.0;
    }
    model.traverse((object) {
      if (object is Mesh&& (meshname==null||object.name==meshname)) {
        (object as Mesh).material=material;
      }
    });
  }

  /// Clone not only the [obj] meshes but also the material
  /// Useful for opacitylerp
  static copyModelAndMat(obj)
  {
    var clone=obj.clone();
    clone.traverse((object) {
      if (object.material!=null) {
        object.material=object.material.clone();
      }
    });
    return clone;
  }
}


/// Procedures related to animated actors
class Actor {
  static List actorlist=[];

  /// Create an actor from asset path
  ///  If [texture] specified use that texture instead of its own
  /// [action] specifies default animation once created with [duration]
  /// So that animations aren't always the same making actors move in unison use [randomduration] to add small variations. 0.1 will change the duration by a random value within 10%
  /// [z] offset so if center of actor is z=0, can specify [z] so that makes the feet the origin to make it easier to put on surface
  /// Specify the actor [shareanimations] that you want this actor alway have
  static createActor(path,{texture, action:"idle",randomduration, z, shareanimations, duration}) async
  {
    var loaderu = THREE_JSM.GLTFLoader(null);
    var gltf =
    await loaderu.loadAsync(path); //ii.gltf');
    var actor = gltf["scene"];
    List animations=gltf["animations"];
    actor.extra['animations']=animations;
    if (texture!=null) {
      await Model.setTexture(actor,texture);
    }
    if (shareanimations!=null) {
       Actor.shareAnimations(actor,shareanimations);
    }
    actor.extra['origrotation']=actor.rotation;
    actorlist.add(actor);
    var mixer = new THREE.AnimationMixer(actor);
    actor.extra['mixer']=mixer;
    var anim=getAnimationByName(actor, action);
    // so dont need 0.14 everywhere for actors
    if (z!=null)
      actor.children[0].position.y+=z;
    if (anim!=null) {
      var idle = await mixer.clipAction(anim);
      if (randomduration!=null) {
        var durationi;
        if (duration==null)
          durationi=anim.duration;
        else
          durationi=duration;
        durationi*=(1+(Math.random()*randomduration-randomduration/2));
        idle?.setDuration(durationi);
      } else if (duration!=null) {
        idle?.setDuration(duration);
      }

      idle?.play();
    }
    return actor;
  }

  /// Share [actor2] animations with [actor1] - must have same skeleton
  /// Does not overwrite if animation already exists
  static shareAnimations(actor1, actor2)
  {
    List animations=actor2.extra['animations'];  // AnimationClip
    for (var animation in animations) {
       var found=false;
       for (var animationa in actor1.extra['animations']) {
         if (animation.name == animationa.name)
           found = true;
       }
       if (!found)
         actor1.extra['animations'].add(animation);
    }
  }

  /// Get the animation clip from [actor] specified by [name]
  static getAnimationByName(actor,name)
  {
    for (THREE.AnimationClip animation in actor.extra['animations'])
      if (animation.name==name)
        return animation;
    return null;
  }

  /// Get the [actor] animationmixer
  static getActorMixer(actor)
  {
    return actor.extra['mixer'];
  }

  /// Update all the actors animation
  static update(frameTime)  {
    for (var actor in actorlist) {
      if (actor.visible)
        actor.extra['mixer'].update(frameTime);
    }

  }

  /// Copy an existing [actor] rather than load it again
  /// Set the [actor] to a different [texture] from assets
  /// Once copied set its initial animation [action] with [duration]
  /// set a [randomduration] where if say 0.1 will add a random number between -0.05 to 0.05 to the [duration] to stop multiple actors all moving in sync unnaturally
  static copyActor( actor, {action:"idle", randomduration, duration, texture}) async
  {

    THREE.Object3D model = THREE_JSM.SkeletonUtils.clone(actor);
    // stop issue where if rotate the original actor that rotation is remembered - should be the original rotation
    if (actor.extra.containsKey('origrotation')) {
      model.rotation.x = actor.extra['origrotation'].x;
      model.rotation.y = actor.extra['origrotation'].y;
      model.rotation.z = actor.extra['origrotation'].z;
    }
    // use z value of orignal actor
    model.children[0].position.y=actor.children[0].position.y;
    model.extra['animations']=actor.extra['animations'];
    var mixer = new THREE.AnimationMixer(model);
    model.extra['mixer']=mixer;

    if (texture!=null) {
      await Model.setTexture(
          model, texture);
    }

    actorlist.add(model);
    var anim=getAnimationByName(model, action);
    if (anim!=null) {
      var idle = await mixer.clipAction(anim);
      if (randomduration!=null) {
        var durationi;
        if (duration!=null)
          durationi =duration;
        else
          durationi=anim.duration;
        durationi*=(1+(Math.random()*randomduration-randomduration/2));
        idle?.setDuration(durationi);
      };
      //cowidle?.setDuration(10);
      idle?.play();
    } else {
      print("anim action"+action+" not found");
    }
    return model;
  }

  /// Get the [actor]s animations
  static getAnimations(THREE.Object3D actor)
  {
    return actor.extra['animations'];
  }

  /// Does the [actor] have an action called [name]
  static hasAnimation(actor, name)
  {
    var animations=Actor.getAnimations(actor);
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
  static getAction(actor,{index, name, clampWhenFinished = false, stopallactions =false, duration, randomduration}) async
  {
    var animations=Actor.getAnimations(actor);

    if (stopallactions)
      getActorMixer(actor).stopAllAction();
    THREE.AnimationClip? clip;
    if (index!=null) {
      clip=animations[index];
    } else {
      for (var animation in animations)
        if (animation.name==name) {
          clip=animation;
        }
    }
    if (clip!=null) {
      THREE.AnimationAction action = await  actor.extra['mixer'].clipAction(clip);
      if (clampWhenFinished)
        action.clampWhenFinished = true;
      if (duration != null) {

        if (randomduration!=null)
          duration*=(1+(Math.random()*randomduration-randomduration/2));
        action.setDuration(duration);
      } else if (randomduration!=null) {
        var duration=clip.duration;
        duration*=(1+(Math.random()*randomduration-randomduration/2));
        action.setDuration(duration);
      }
      return action;
    }
  }

  /// Play an animation for [actor] of [name].
  /// Call THREE.AnimationAction  [clampWhenFinished] if specified
  /// [stopallactions] in the animation mixer if specified
  /// set the [duration] of the animation
  /// set a [randomduration] where if say 0.1 will add a random number between -0.05 to 0.05 to the [duration] to stop multiple actors all moving in sync unnaturally
  /// [delay] before play the action
  /// [loopmode] specify if animation loops ie THREE.LoopOnce, THREE.LoopRepeat
  /// [looprepetitions] how many times loop  - 0 if indefinate
  /// play animation [backwards] if true
  static playAction(actor,{ name, clampWhenFinished = false, stopallactions =false, duration, randomduration,  delay, loopmode, looprepetitions:0, backwards}) async
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () async {
        (await playAction(actor,
        name: name, clampWhenFinished: clampWhenFinished, stopallactions: stopallactions, duration:duration, randomduration:randomduration, loopmode:loopmode, looprepetitions:looprepetitions));
      });

      BaseObject.addTimer(actor,t);
    } else {
      THREE.AnimationAction action = await getAction(actor,
          name: name,
          clampWhenFinished: clampWhenFinished,
          stopallactions: stopallactions,
          duration: duration,
          randomduration: randomduration);

      action.reset();
      if (loopmode!=null)
        action.setLoop(loopmode, looprepetitions);
      if (duration!=null)
        action.setDuration(duration);
      if (backwards!=null&&backwards) {
       action.backwards=true;
      } else
        action.backwards=false;
      action.play();
    }
  }

  /// Have [actor] play animation [action] and when complete then do action [actionthen]
  /// Can specify [duration] of the [action] and the duration of actionthen with [durationthen]
  /// Can play the animation [backwards]
  /// Can start animation in [delay] seconds
  static playActionThen(actor, action, actionthen, {duration, durationthen, backwards, delay}) async
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        playActionThen(actor, action, actionthen, duration:duration, backwards:backwards, durationthen:durationthen);
      });
      BaseObject.addTimer(actor,t);
    } else {
      await Actor.playAction(actor, name: action,
          clampWhenFinished: true,
          stopallactions: true,
          loopmode: THREE.LoopOnce,
          backwards:backwards,
          duration: duration);
      THREE.AnimationMixer mixer=Actor.getActorMixer(actor);

      mixer.clearListeners();
      mixer.addEventListener('finished',
              (e) async {

              //print("uuuo"+actionthen+" "+actor.toString()+" "+Mob.getName(actor));
            await Actor.playAction(
                actor, name: actionthen, duration: durationthen);

      });


    }
  }

  ///. Stop all animations on character [group]
  static stopAnimations(THREE.Object3D group)//THREE.AnimationMixer mixer)
  async {
    //print("xxx"+mixer.getRoot().toString());
    //THREE.Object3D group=mixer.getRoot();
    List<dynamic> animations=group.extra['animations'];
    // print("stop name"+group.extra['name']);
    //THREE.Object3D model=group.children[0] as THREE.Object3D;
    // print("xxx"+group.animations.toString()+" "+group.name.toString());//amodel.toString());
    //model.

    for (var j=0; j<animations.length; j++) {
      await group.extra['mixer'].clipAction( animations[j] )?.stop();
      await group.extra['mixer'].clipAction( animations[j] )?.reset();
    }
  }

  /// Have an [actor] wield a [model] on the bone [bonename]
  static wield(actor, wieldobject, bonename)
  {
    unwield(actor,bonename);
    THREE.Bone bone= actor.children[0].children[0].skeleton?.getBoneByName(bonename);//"Bip01_R_Hand");
    if (bone!=null) {
      bone.add(wieldobject);//.children[0]);
    }
    actor.extra['wielding']=wieldobject;

  }

  /// Have [actor] unwield any models it is wielding
  static unwieldAll(actor, {delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        unwieldAll(actor);
      });
      BaseObject.addTimer(actor, t);
    } else {
      for (var bone in actor.children[0].children[0].skeleton?.bones) {
        if (bone != null)
          bone.clear();
      }
      clearWielding(actor);
    }
  }

  /// Have [actor] unwield any model attached to [bonename] in [delay] seconds
  static unwield(actor, bonename, {delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        unwield(actor, bonename);
      });
      BaseObject.addTimer(actor,t);

    } else {
      var bone = actor.children[0].children[0].skeleton?.getBoneByName(
          bonename); //"Bip01_R_Hand");
      if (bone != null) {
        bone.clear();
        clearWielding(actor);
      }
    }
  }

  /// Return the object3d that [obj] is wielding
  /// This isn't much good if you're wielding multiple objects on different bones
  static getWielding(obj)
  {
    if (obj.extra.containsKey('wielding'))
      return obj.extra['wielding'];
  }

  /// Clear the item specified that the [actor] is wielding - will not actually remove what was wielded
  static clearWielding(actor)
  {
    if (actor.extra.containsKey('wielding'))
      actor.extra.remove('wielding');
  }

}

/// Procedures for creating planes including planes with text
class Plane
{
  /// Create a plane with texture at [path] of size [width] and [height].
  /// [ambient] specifies if ambience changes with time of day
  /// [flipx] flips the plane texture in the horizontal direction
  /// is the material [doublesided] ?
  /// Position plane in [z] axis
  static loadPlane(path, width,height, {ambient:true, flipx=false, doublesided,z}) async
  {
    var texturei = await THREE.TextureLoader(null)
        .loadAsync(path);
    THREE.MeshStandardMaterial planeMaterial = new THREE.MeshStandardMaterial({
      'map': texturei,
      'transparent': true,
    });
    if (doublesided!=null&&doublesided)
      planeMaterial.side = THREE.DoubleSide;
    if (ambient&&Time._ambience!=null)
      planeMaterial.color=Time._ambience?.color as THREE.Color;

    var geometry = THREE.PlaneGeometry(1, 1);
    var plane = THREE.Mesh(geometry, planeMaterial);
    if (!kIsWeb) {
      // must flip for android and ios for some reason
      (plane.material as THREE.MeshStandardMaterial ).map?.wrapT =
          THREE.RepeatWrapping;
      (plane.material as THREE.MeshStandardMaterial ).map?.repeat.y = -1.0;
    }

    if (flipx) {
      (plane.material as THREE.MeshStandardMaterial ).map?.wrapS =
          THREE.RepeatWrapping;
      (plane.material as THREE.MeshStandardMaterial ).map?.repeat.x = -1.0;
    }
    plane.scale.set(width.toDouble(), height.toDouble(),1);
    if (z!=null)
      plane.position.y=z;//height/2;
    Space.objTurn(plane,-90);  // front face is pointing north
    Group group=Group();
    group.add(plane);

    group.extra['texturepath']=path;
    group.extra['isplane']=true;
    if (ambient)
      group.extra['ambient']=true;
    return group;


  }

  /// Create a text plane with text [message] with color [textcolor] and size [fontSize] and background of color [backgroundcolor] with opacity [backgroundopacity]
  /// [z] is how high make the plane above zero
  /// [width] how wide to make the text in pixels
  /// Set whether text is [bold]
  /// Set the text [fontfamily]
  static makeTextPlane(message, Color textcolor, {fontSize:20, z:0, backgroundcolor:Colors.black, backgroundopacity:0.5, width:200, bold, fontfamily}) async {
    var ret = await Texture.makeText(message, textcolor, fontSize:fontSize, z:z, backgroundcolor:backgroundcolor, backgroundopacity:backgroundopacity, width:width, bold:bold, fontfamily: fontfamily);
    var texturei=ret['texture'];
    width=ret['width'];
    var height=ret['height'];
    THREE.MeshStandardMaterial material = new THREE.MeshStandardMaterial({
      'map': texturei,
      'transparent': true,  'sizeAttenuation':true /* 'useScreenCoordinates': false,*/ /*, 'alignment': THREE.Vector2( 1, -1 )spriteAlignment*/
    });
    var group=Group();
    var geometry = THREE.PlaneGeometry(1, 1);
    var plane = THREE.Mesh(geometry, material);
    group.add(plane);
    plane.scale.set(1.0, height.toDouble()/width.toDouble(), 1.0);

    Space.objTurn(plane,-90);  // front face is pointing north
    plane.position.y = z.toDouble();//50;
    return group;

  }
}

/// Procedures related to sprites such as text sprites
class Sprite
{
  /// Create a sprite with texture at [path] of size [width] and [height].
  /// [ambient] specifies if ambience changes with time of day
  /// [flipx] flips the sprite in the horizontal direction
  static loadSprite(path, width,height, {ambient:true, flipx=false}) async
  {
    var texturei = await THREE.TextureLoader(null)
        .loadAsync(path);
    THREE.SpriteMaterial spriteMaterial = new THREE.SpriteMaterial({
      'map': texturei,

      'transparent':
      true, 'sizeAttenuation':true
    });
    if (ambient&&Time._ambience!=null)
      spriteMaterial.color=Time._ambience?.color as THREE.Color;


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
    sprite.scale.set(width.toDouble(), height.toDouble(),1);
    sprite.position.y=height/2;
    Group group=Group();
    group.add(sprite);

    group.extra['texturepath']=path;
    if (ambient)
      group.extra['ambient']=true;
    return group;

  }

  /// clones a sprite [spriteorig] but only by reusing the original sprites material - creates a new sprite from scratch
  // Why cant I just use spriteorig.copy(true) - doesn't work!!
  static cloneSprite(spriteorig)  {

    var sprite = new THREE.Sprite();//spriteorig.children[0].material);

    sprite.scale.set(spriteorig.children[0].scale.x,spriteorig.children[0].scale.y,1);// 0.4,1.4,1);

    sprite.material=spriteorig.children[0].material;
    if (!kIsWeb) {
      // must flip for android and ios for some reason
      (sprite.material as THREE.SpriteMaterial).map?.wrapT =
          THREE.RepeatWrapping;
      (sprite.material as THREE.SpriteMaterial).map?.repeat.y = -1.0;
    }

    sprite.position.y = spriteorig.children[0].position.y;

    Group group=Group();
    if (spriteorig.extra.containsKey('ambient')&&spriteorig.extra['ambient'])
      group.extra['ambient']=true;
    group.add(sprite);
    return group;
  }


  /// Create a text sprite with text [message] with color [textcolor] and size [fontSize] and background of color [backgroundcolor] with opacity [backgroundopacity]
  /// [z] is how high make the sprite
  /// [width] how wide to make the sprite texture in pixels
  /// Is the text [bold]
  /// Set text [fontfamily] eg Roboto
  static makeTextSprite(message, Color textcolor, {fontSize:20, z:0, backgroundcolor:Colors.black, backgroundopacity:0.5, width:200, bold, fontfamily}) async {

    var ret = await Texture.makeText(message, textcolor, fontSize:fontSize, z:z, backgroundcolor:backgroundcolor, backgroundopacity:backgroundopacity, width:width, bold:bold,fontfamily:fontfamily);
    var texturei=ret['texture'];
    width=ret['width'];
    var height=ret['height'];
    THREE.SpriteMaterial spriteMaterial = new THREE.SpriteMaterial({
      'map': texturei,
      'transparent': true,  'sizeAttenuation':true /* 'useScreenCoordinates': false,*/ /*, 'alignment': THREE.Vector2( 1, -1 )spriteAlignment*/
    });

    var sprite = new THREE.Sprite(spriteMaterial);
    sprite.scale.set(width, height, 1.0);
    sprite.position.y = z.toDouble();//50;
    return sprite;

  }
}

/// Procedures related to light sources such as flickering and fading to different intensities
class Light
{
  static THREE.Clock? clock=null;

  static List<THREE.Light> lightflickers=[];
  static List<THREE.Light> nightonlys=[];
  static List<THREE.Light> intensitylerps=[];

  /// Make [light] flicker
  static addFlicker(THREE.Light light)
  {
    if (!lightflickers.contains(light))
      lightflickers.add(light);
    light.extra['initintensity']=light.intensity;
    light.extra['currentintensity']=light.intensity;
  }

  /// Set the [light] to only shine at night
  static addNightOnly(THREE.Light light)
  {
    light.extra['initintensity']=light.intensity;
    light.extra['currentintensity']=light.intensity;
    //   light.extra['initcolor']=light.color;
    if (!nightonlys.contains(light))
      nightonlys.add(light);
  }

  /// Lerp intensity of the [light] to [intensity] in [time] seconds
  static intensityLerp(THREE.Light light, intensity, time)
  {
    if (lightflickers.contains(light))
      lightflickers.remove(light);

    light.extra['lerpfromtimelight'] = System.currentMilliseconds();
    light.extra['lerptotimelight'] = time;

    light.extra['lerpinitiallight'] = light.intensity;
    light.extra['lerpfinallight'] = intensity;
    if (intensitylerps.indexOf(light) < 0)
      intensitylerps.add(light);

  }

  /// Remove [light] from shining only at night
  static removeNightOnly(light)
  {
    if (nightonlys.contains(light))
      nightonlys.remove(light);
    light.intensity=light.extra['initintensity'];
  }

  /// Update lights so can flicker and transition to different intensities
  static update() {
    if (clock == null) {
    //  print("no clock");
      return;
    }
    // Only check once a minute
    if (nightonlys.length > 0) {//&& System.currentMilliseconds()-lastnightchecktick>1000) {

        var perc = 1 - Time.getSunBrightness(Time.time);
        //print("perc"+perc.toString());
        // perc=0;
        for (var light in nightonlys) {
          if (Space._hideobjects.contains(light)&&!light.visible) {
            // if light hidden because far away then dont switch it on

          } else {
            light.visible = perc > 0;
            if (light.visible && !lightflickers.contains(light)) {

              light.intensity = light.extra['initintensity'] *
                  perc; //intensity;//color=lightcolor;
            }
            light.extra['currentintensity'] =
                light.extra['initintensity'] * perc;
          }
        }
    }

    // Flicker each light in the list
    for (var light in lightflickers) {
      if (light.visible&&light != null && light.extra['currentintensity']!=0) {

        var maxintensity = light.extra['currentintensity'] +
            light.extra['currentintensity'] * 0.25;
        var minintensity = light.extra['currentintensity'] -
            light.extra['currentintensity'] * 0.25;
        light.intensity += clock!.getDelta() *
            20 *
            (5.0 * Math.random() -
                2.5); //= 2+Math.random()*0.1-0.05;
        if (light.intensity > maxintensity) //2.3)
          light.intensity = maxintensity; //2.3;
        else if (light.intensity < minintensity) //1.7)
          light.intensity = minintensity; // 1.7;

      }
    }

    // Lerp light intensity
    for (var i = intensitylerps.length - 1; i >= 0; i--) {
      var obj = intensitylerps[i];
      if (obj == null) {
        intensitylerps.remove(obj);

      } else {
        var lerp = (System.currentMilliseconds() -
            obj.extra['lerpfromtimelight']) /
            (obj.extra['lerptotimelight'] * 1000);
        if (lerp >= 1) {
          intensitylerps.remove(obj);
          obj.intensity = obj.extra['lerpfinallight'].toDouble();
        } else {
          var newlight = obj.extra['lerpinitiallight'] +
              lerp * (obj.extra['lerpfinallight'] -
                  obj.extra['lerpinitiallight']);
          obj.intensity = newlight;
        }
      }
    }
  }
}

/// Procedures related to game time such as night, day, length of day
class Time {
  static double time = 0; // 0 is midnight, 12 is noon
  static double daylength=2.0;//2.0;// in hours , -1 never change

  static double nightstart = 21.5;   // Time when night starts
  static double nightend = 5;   // Time when night ends
  static double daystart = 10.5;  // When day start
  static double dayend = 18.5;    // When day ends
  static double sunrise = 7;
  static double sunset = 20;

  static double baseambience = 0.4; // no matter what time it is this is how much ambience there is

  static THREE.Mesh? _sunSphere;

  static double _azimuth = 0.1;

  static THREE.ShaderMaterial? _skyMat;

  static THREE.AmbientLight? _ambience;

  /// initialise with a sun object [sunSphere] that moves with the position of a [skyMat] skymaterial shader
  /// [ambience] is ambient light that changes depending on the time of day
  static init(sunSphere, skyMat, THREE.AmbientLight ambience) {
    Time._skyMat = skyMat;
    Time._sunSphere = sunSphere;
    Time._ambience = ambience;
  }

  /// get the brightness of the sun given the [time] of day - 0 dark 1 brightest
  static getSunBrightness(time)
  {
    var perc;
    if (isNight(time))
      perc=0;
    else if (isDay(time))
      perc=1;
    else if (time>=dayend && time<=nightstart)//isDaySunset(time))
      perc=(nightstart-time)/(nightstart-dayend);
    else if (time>=nightend && time<daystart)//isNightSunrise(time)) {
      perc=(time-nightend)/(daystart-nightend);
    return perc;

  }

  /// Update the time based on daylength
  /// frametime is second elapsed since last time updated
  static update(frameTime)
  {
    if (daylength>0) {
      var fakesecondselapsed=(24.0/daylength)*frameTime;
      // convert from second to minutes then hours
      setTime(Time.time + (fakesecondselapsed/60.0)/60.0);
    }
  }

  /// set the [newtime] time and adjust skymesh and sun and ambience based  on time of day
  static setTime(newtime) {
    //sunSphere.position.y = - 700000;
    //sunSphere.visible = true;
    Time.time=newtime.toDouble() %24;

    if (_sunSphere!=null) {
      const distance = 400000;

      var perc=Time.getSunBrightness(time);

      // Set the background ambience based upon time
      var light=perc *(1-baseambience)+baseambience;

      THREE.Color ambience=THREE.Color();
      ambience.r=light; ambience.g=light; ambience.b=light;
      Time._ambience?.color=THREE.Color(ambience);//0xffffff);
      // Set the inclination of the sun - sun should dip below horizon at sunset
      // -0.5 sunrise
      // 0=noon
      // 0.5=sunset
      // 1=midnight
      var inclination=0.0;
      var found=false;
      var times=[0 ,                sunrise,     12 ,   sunset ,  24];
      var inclinations= [-1,         -0.5,     0 ,    0.5 ,      1];
      for (var i=0; i<times.length; i++) {
        if (!found&&time<times[i+1]) {
           var x1=times[i];
           var x2=times[i+1];
           var y1=inclinations[i];
           var y2=inclinations[i+1];
           var m=(y2-y1)/(x2-x1);
           inclination=m*(time-x1)+y1;
          // print("found time"+time.toString()+" "+i.toString()+" "+inclination.toString());
           found=true;
        }

      }

      // 0 is noon, 1 is midnight
      var theta = math.pi * (inclination - 0.5);
      var phi = 2 * math.pi * (_azimuth - 0.5);

      _sunSphere?.position.x = distance * math.cos(phi);
      _sunSphere?.position.y = distance * math.sin(phi) * math.sin(theta);
      _sunSphere?.position.z = distance * math.sin(phi) * math.cos(theta);

      _sunSphere?.visible = true; //effectController.sun;
      _skyMat?.uniforms['sunPosition']['value'] = _sunSphere?.position;


    }

  }

  /// Convert real seconds to game seconds
  /// For exmaple if daylength=2 hours and [amt] = 1 second then returns 12 seconds
  static double realSecondsToGameSeconds(amt)
  {
    return amt*24/daylength;
  }

  /// Is the [time] in the period from night to sunrise?
  static bool isNightSunrise( time)
  {
    return (time>nightend&&time<=sunrise) ;
  }

  /// Is the [time] betwene sunrise and the start of the day
  static  bool isSunriseDay(time)
  {
    return (time>sunrise&&time<=daystart);
  }

  /// Is it day [time]?
  static  bool isDay( time)
  {
    return (time>=daystart&&time<dayend);
  }

  /// Is the [time] from the end of the day to sunset
  static  bool isDaySunset(time)
  {
    return (time>=dayend&&time<sunset);
  }

  /// Is the [time] after sunset and before the start of night
  static  bool isSunsetNight( time)
  {
    return (time>=sunset&&time<nightstart);
  }

  /// Is the [time] night?
  static bool isNight(time)
  {
    return (time>=nightstart||time<nightend);
  }
}

/// Procedures related to weather such as wind, cloud, rain and fog
class Weather
{
  static double cloud=-1;
  static double newcloud=0;
  static double oldcloud=0;
  static int newcloudtick=-1;

  static double wind=-1;
  static double newwind=0;
  static double oldwind=0;
  static int newwindtick=-1;

  static double rain=-1;
  static double newrain=0;
  static double oldrain=0;
  static int newraintick=-1;
  static List rainlines=[];

  static double fog=-1;
  static double newfog=0;
  static double oldfog=0;
  static int newfogtick=-1;
  static bool fogindoors=true;

  static int weatherchangetime=30;//000; // 30seconds to change from say 0 wind to 1 wind

  static THREE.Mesh? _clouds;
  static audioplayers.AudioPlayer? _windsound;
  static audioplayers.AudioPlayer? _windsound2;
  static audioplayers.AudioPlayer? _rainsound;
  static audioplayers.AudioPlayer? _rainsound2;

  static double probraintoday=0;//0.1;  // in a given day probability starts
  static double probstopraintoday=0;//2;  // in a given day if its raining, probability it stops
  static double probfogtoday=0;//0.1;
  static double probstopfogtoday=0;//2;
  static double probwindtoday=0;//0.1;
  static double probstopwindtoday=0;//2;  // in a given day if theres wind, probability it stops
  static double probcloudtoday=0;//0.1;
  static double probstopcloudtoday=0;//2;

  static bool lastindoors=false;


  /// Initialise the weather
  /// [clouds] is a plane with clouds texture that can be moved if windy and made more transparent if less cloud
  /// [windsoundpath] is the sound in the assets used for wind
  /// [rainsoundpath] is the sound in the assets used for rain
  static init(clouds, windsoundpath, rainsoundpath) async {
    Weather._clouds = clouds;
    if (clouds!=null) {
      _clouds?.visible = false;
    }

    windwasplaying1=false;
    windwasplaying2=false;
    rainwasplaying1=false;
    rainwasplaying2=false;
    if (windsoundpath!=null) {
      _windsound = audioplayers
          .AudioPlayer(); //handleInterruptions: false);//mode: PlayerMode.LOW_LATENCY);
      await _windsound?.setSource(audioplayers.AssetSource(windsoundpath));
      _windsound?.setReleaseMode(audioplayers.ReleaseMode.loop);
      _windsound2 = audioplayers
          .AudioPlayer();
      await _windsound2?.setSource(audioplayers.AssetSource(windsoundpath));
      _windsound2?.setReleaseMode(audioplayers.ReleaseMode.loop);
      _windsound2?.seek(Duration(seconds: 10));
    }

    if (rainsoundpath!=null) {
      _rainsound = audioplayers.AudioPlayer();//handleInterruptions: false);//mode: PlayerMode.LOW_LATENCY);
      await _rainsound?.setSource(audioplayers.AssetSource(rainsoundpath));
      _rainsound?.setReleaseMode(audioplayers.ReleaseMode.loop);

      _rainsound2 = audioplayers
          .AudioPlayer(); //handleInterruptions: false);//mode: PlayerMode.LOW_LATENCY);
      await _rainsound2?.setSource(audioplayers.AssetSource(rainsoundpath));
      _rainsound2?.setReleaseMode(audioplayers.ReleaseMode.loop);
      _rainsound2?.seek(Duration(seconds: 5));
    }

    // Create rain lines
    var points = [];
    points.add( new THREE.Vector3( 0, -1, 0 ) );
    points.add( new THREE.Vector3( 0, 1, 0 ) );
    var geometryii = new THREE.BufferGeometry().setFromPoints( points );

    for (var i=0; i<40; i++) {
      var materiali = new THREE.LineBasicMaterial({ 'color': 0x333333});//888888});
      var line = new THREE.Line(geometryii, materiali);
      materiali.transparent=true;
      materiali.opacity=0.13;

      line.visible=false;
      //line.scale.set(0.1,0.1,0.1);
      line.position.copy(Camera._camera.position);
      line.position.y -= Camera.cameraoffset;
      line.rotation.y = Camera._camera.rotation.y;
      line.translateZ(-0.5);
      line.translateX(1.3*((Math.random()-0.5)));

      Space._scene.add(line);
      rainlines.add(line);
    }

    if (Space?._scene.fog==null) {
      Space?._scene.fog = new THREE.Fog( 0xcccccc, 0.1, 0 );

    }
  }

  /// Set so randomly get weather with varying degrees of probability
  static setRandomWeather()
  {
    probraintoday=0.1;  // in a given day probability starts
    probstopraintoday=1.0;  // in a given day if its raining, probability it stops
    probfogtoday=0.1;
    probstopfogtoday=6.0; // make it so fog doesn't last too long
    probwindtoday=0.1;
    probstopwindtoday=1.0;  // in a given day if theres wind, probability it stops
    probcloudtoday=0.1;
    probstopcloudtoday=1.0;
  }

  /// Set so that weather is always clear
  static setClearWeather()
  {
    probraintoday=0;//0.1;  // in a given day probability starts
    probstopraintoday=0;//2;  // in a given day if its raining, probability it stops
    probfogtoday=0;//0.1;
    probstopfogtoday=0;//2;
    probwindtoday=0;//0.1;
    probstopwindtoday=0;//2;  // in a given day if theres wind, probability it stops
    probcloudtoday=0;//0.1;
    probstopcloudtoday=0;//2;
  }

  static bool windwasplaying1=false;
  static bool windwasplaying2=false;
  static bool rainwasplaying1=false;
  static bool rainwasplaying2=false;

  /// Mute the weather sounds
  /// can stop weather sounds when app goes into background and start again when resume
  static mute(mute)
  {
    if (mute) {
      print("weather mute");
      if (_windsound!=null) {
        if (Sound.isPlaying(Weather._windsound!)) {//==audioplayers.PlayerState.playing) {
          Weather._windsound!.pause();
          windwasplaying1=true;
        }
        if (Sound.isPlaying(Weather._windsound2!)) {//.state==audioplayers.PlayerState.playing) {
          Weather._windsound2!.pause();
          windwasplaying2=true;
        }
      }

      if (_rainsound!=null) {
        if (Sound.isPlaying(Weather._rainsound!)) {//.state==audioplayers.PlayerState.playing) {
          print("pause rain sound");
          Weather._rainsound!.pause();
          rainwasplaying1=true;
        }
        if (Sound.isPlaying(Weather._rainsound2!)) {//.state==audioplayers.PlayerState.playing) {
          print("pause rain2 sound");
          Weather._rainsound2!.pause();
          rainwasplaying2=true;
        }
      }

    } else {
      print("weather unmute");
      if (windwasplaying1) {
        Weather._windsound!.resume();
        windwasplaying1=false;
      }
      if (windwasplaying2) {
        Weather._windsound2!.resume();
        windwasplaying2=false;
      }
      if (rainwasplaying1) {
        print("rain resume");
        Weather._rainsound!.resume();
        rainwasplaying1=false;
      }
      if (rainwasplaying2) {
        print("rain2 resume");
        Weather._rainsound2!.resume();
        rainwasplaying2=false;
      }

    }
  }

  /// Set [opacity] of sky - used for fog
  static setSkyOpacity(opacity)
  {
    Time._skyMat?.transparent=(opacity<1);

    Time._skyMat?.uniforms['opacity']['value'] = opacity;
  }

  /// Change the [cloud] level by changing the cloud materials opacity
  /// Cloud is between 0 and 1
  static cloudChange(cloud)
  {
    Weather.cloud=cloud.toDouble();
    if (_clouds!=null) {
      if (cloud==0) {
        _clouds?.visible = false;
        print("off cloud");
      } else {

        _clouds?.visible=true;

        var lerp=cloud;///0.5;

        _clouds?.material.opacity=lerp;//cloud;
      }
    }
  }

  /// Change the new cloud [newcloud] level
  /// Will lerp if cloud has been set before so that cloud level isn't sudden
  static setCloud(newcloud)
  {
    // print("setcloud"+newcloud.toString()+" "+cloud.toString());
    if (cloud==-1) {
      cloud = newcloud.toDouble();
      Weather.newcloud=newcloud.toDouble();
      cloudChange(cloud);
    } else {
      Weather.newcloud = newcloud.toDouble();
      Weather.oldcloud=Weather.cloud;
      Weather.newcloudtick=System.currentMilliseconds();
    }
  }

  /// Change the volume of the [wind] sound
  /// Have two wind sounds since there is often an issue of a gap in looping audio
  static windSound(wind)
  {
    if (Weather._windsound!=null) {
      Weather._windsound?.setVolume(wind.toDouble());
      if (wind>0&&Sound.isPlaying(Weather._windsound!))//=audioplayers.PlayerState.playing)
        Weather._windsound?.resume();
      else if (wind==0&&Sound.isPlaying(Weather._windsound!))//==audioplayers.PlayerState.playing)

        Weather._windsound?.stop();

      Weather._windsound2?.setVolume(wind.toDouble());
      if (wind>0&&Sound.isPlaying(Weather._windsound2!)) //.state!=audioplayers.PlayerState.playing)
        Weather._windsound2?.resume();
      else if (wind==0&&Sound.isPlaying(Weather._windsound2!))//.state==audioplayers.PlayerState.playing)
        Weather._windsound2?.stop();
    }
  }

  /// Set the wind level [newwind] between 0 and 1
  static setWind(newwind)
  {
    if (wind==-1) {
      Weather.oldwind=0;
      Weather.wind = newwind.toDouble();
      Weather.newwind=newwind.toDouble();
      windSound(wind);
    } else {
      Weather.oldwind=wind;
      Weather.newwind = newwind.toDouble();
      Weather.newwindtick=System.currentMilliseconds();

    }
  }

  /// Randomly change the number of rain lines based upon the level of rain
  static rainVisible(rain)
  {
    for (var line in rainlines) {
      line.visible=Math.random()<rain;
    }
  }

  /// Set the volume of the [rain]
  /// Use two sounds so that don't hear gap between looping sounds
  static rainSound(rain)
  {
    if (Weather._rainsound!=null) {
      Weather._rainsound?.setVolume(rain.toDouble());
      Weather._rainsound2?.setVolume(rain.toDouble());

      if (rain>0&&Weather._rainsound!=null&&Weather._rainsound!.state!=audioplayers.PlayerState.playing) {
        //   if (wind>0&&!Weather._windsound!.playing)
        Weather._rainsound?.resume();
        print("rain sound resume"+Weather._rainsound!.state.toString());
      } else if (rain==0&&Sound.isPlaying(Weather._rainsound!)) {//.state==audioplayers.PlayerState.playing) {

        Weather._rainsound?.stop();
        print("rain sound stop");
      }

      if (rain>0&&Weather._rainsound2!=null&&Sound.isPlaying(Weather._rainsound2!)) {//.state!=audioplayers.PlayerState.playing) {
        Weather._rainsound2?.resume();
        print("rain sound2 resume"+Weather._rainsound2!.state.toString());
      } else if (rain==0&&Sound.isPlaying(Weather._rainsound2!)) {//.state==audioplayers.PlayerState.playing) {

        Weather._rainsound2?.stop();
        print("rain sound2 stop");
      }

    }
  }

  /// Set the level of rain [newrain] between 0 and 1
  static setRain(newrain)
  {
    if (rain==-1) {
      Weather.rain = newrain.toDouble();
      Weather.newrain=newrain.toDouble();
      rainSound(rain);
      rainVisible(rain);
    } else {
      Weather.newrain = newrain.toDouble();
      Weather.newraintick=System.currentMilliseconds();
      Weather.oldrain=rain;
    }
  }

  /// Display fog with [fog] level and change color depending on time of day
  static changeFog(fog)
  {
    if (fog==0) {
      (Space?._scene.fog as THREE.Fog)?.near=0.1;
      (Space?._scene.fog as THREE.Fog)?.far=0;
      setSkyOpacity(1.0);
    }else {
      // if there is fog there can be no cloud!!
      // transparency of skymat messes up clouds
      if (cloud>0) {
        cloudChange(0);
        newcloud=0;
      }
      var far;
      var near;
      if (fog<0.05) {
        var lerp=fog/0.05;
        near=(1-lerp)*8+lerp*4;
        far=(1-lerp)*240+lerp*120;
      } else if (fog<0.1) {
        var lerp=(fog-0.05)/0.05;
        near=(1-lerp)*4+lerp*2;
        far=(1-lerp)*120+lerp*60;
      } else if (fog<0.5) {
        var lerp=(fog-0.1)/0.4;
        near=(1-lerp)*2+lerp*0.1;
        far=(1-lerp)*60+lerp*4;
      } else {// if (fog<=1) {
        var lerp=(fog-0.5)/0.5;
        near=0.1;//(1-lerp)*2+lerp*0.1;
        far=(1-lerp)*4+lerp*0.8;
      }
      (Space._scene.fog as THREE.Fog)?.near=near;
      (Space._scene.fog as THREE.Fog)?.far=far;

      if (fog>0.1) {
        setSkyOpacity(0.0);
        Space._scene.background=(Space._scene.fog as THREE.Fog).color;
      } else {
        // at 0.1 is should be 0.1
        // at 0 should be 1
        Space._scene.background=(Space._scene.fog as THREE.Fog).color;
        var lerp=fog/0.1;
        setSkyOpacity(1-lerp);
      }
      var perc=Time.getSunBrightness(Time.time)*0.8;  // cccccc = about 0.8
      Space._scene.fog?.color.r=perc;
      Space._scene.fog?.color.g=perc;
      Space._scene.fog?.color.b=perc;


    }
    // scene.fog = new THREE.Fog( 0xcccccc, 0.1, 0.8 );//1
    //  scene.fog = new THREE.Fog( 0xcccccc, 0.1, 4 );// 0.5
    //  scene.fog = new THREE.Fog( 0xcccccc, 2, 60 );// 0.1
    //scene.fog = new THREE.Fog( 0xcccccc, 4, 120);//60 );// 0.05
    //scene.fog = new THREE.Fog( 0xcccccc, 8, 240);//60 );// 0.0
  }

  /// Set [newfog] level - will lerp to that new fog
  static setFog(newfog)
  {
    if (fog==-1) {
      Weather.fog = newfog.toDouble();
      Weather.newfog=newfog.toDouble();
      changeFog(fog);
    } else {
      Weather.newfog = newfog.toDouble();
      Weather.newfogtick=System.currentMilliseconds();
      Weather.oldfog=fog;

    }
  }

  /// Lerp the weather sounds, levels of rain, fog, cloud
  /// Generate random weather based upon probabilities
  /// frametime is the number of seconds since the last frame
  static update(num frameTime)
  {

    var indoors=You.indoors();
    if (probraintoday>0&&rain<=0) {
      if (Math.random()<probraintoday*Time.realSecondsToGameSeconds(frameTime)/(24*60*60)) {
        newrain=Math.random();
        newcloud=Math.random();  // If raining should be cloudy
        setRain(newrain);
        setCloud(newcloud);
        print('rain set'+newrain.toString());
      }
      // frame time is 12 hours then probability is 50%
      // frame time is 6 25
      // frame time is 3 12.5%
    }
    if (probstopraintoday>0&&rain>0) {
      if (Math.random()<probstopraintoday*Time.realSecondsToGameSeconds(frameTime)/(24*60*60)) {
        setRain(0);
        print('rain off');
      }
    }

    if (probwindtoday>0&&wind<=0) {
      if (Math.random()<probwindtoday*Time.realSecondsToGameSeconds(frameTime)/(24*60*60)) {
        newwind=Math.random();
        setWind(newwind);
        // If wind then 50% chance there is cloud
        if (Math.random()<0.5) {
          newcloud = Math.random();
          setCloud(newcloud);
        }
        print('wind set'+newwind.toString());
      }
      // frame time is 12 hours then probability is 50%
      // frame time is 6 25
      // frame time is 3 12.5%
    }
    if (probstopwindtoday>0&&wind>0) {
      if (Math.random()<probstopwindtoday*Time.realSecondsToGameSeconds(frameTime)/(24*60*60)) {
        setWind(0);//newwind=0;
        print('wind off');
      }
    }

    if (probcloudtoday>0&&cloud<=0) {
      if (Math.random()<probcloudtoday*Time.realSecondsToGameSeconds(frameTime)/(24*60*60)) {
        newcloud=Math.random();
        setCloud(newcloud);
        print('cloud set'+newcloud.toString());
      }
      // frame time is 12 hours then probability is 50%
      // frame time is 6 25
      // frame time is 3 12.5%
    }
    if (probstopcloudtoday>0&&cloud>0) {

      if (Math.random()<probstopcloudtoday*Time.realSecondsToGameSeconds(frameTime)/(24*60*60)) {
        setCloud(0);
        print('cloud off');
      }
    }

    if (probfogtoday>0&&fog<=0&&cloud<=0) {
      if (Math.random()<probfogtoday*Time.realSecondsToGameSeconds(frameTime)/(24*60*60)) {
        newfog=Math.random();
        setFog(newfog);
        print('fog set'+newfog.toString());
      }
      // frame time is 12 hours then probability is 50%
      // frame time is 6 25
      // frame time is 3 12.5%
    }
    if (probstopfogtoday>0&&fog>0) {
      if (Math.random()<probstopfogtoday*Time.realSecondsToGameSeconds(frameTime)/(24*60*60)) {
        setFog(0);//newfog=0;
        print('fog off');
      }
    }

    if (_clouds!=null) {
      if (newcloud!=cloud) {
        // Take 30 seconds to change to new cloud
        double lerp=(System.currentMilliseconds()-Weather.newcloudtick)/(weatherchangetime*1000);
        if (lerp>=1) {
          Weather.cloudChange(newcloud);
        } else {
          Weather.cloudChange(newcloud*lerp+oldcloud*(1-lerp));

        }
      }
      if (indoors) {
        if (!lastindoors) {
          // Have gone from outdoors to indoors
          Sound.fadeOut(_windsound!, 1);
          Sound.fadeOut(_windsound2!, 1);
        }
      } else {
        if (indoors!=lastindoors&&wind>0) {
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
          double lerp = (System.currentMilliseconds() - Weather.newwindtick) / (weatherchangetime * 1000);
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
        _clouds?..material.map.offset.y -= wind * frameTime * 0.1; // 0.001;
      }
      if (indoors) {
        if (!lastindoors) {
          // Have gone from outdoors to indoors
          Sound.fadeOut(_rainsound!, 1);
          Sound.fadeOut(_rainsound2!, 1);
          rainVisible(0);
        }
      } else {
        if (indoors!=lastindoors&&rain>0) {
          print("from indoors to outdoors"+rain.toString());
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
          double lerp = (System.currentMilliseconds() - Weather.newraintick) / (weatherchangetime * 1000);
          if (lerp >= 1) {
            rain = newrain;
          } else {
            rain = newrain * lerp + oldrain * (1 - lerp);
          }
          rainSound(rain);
          rainVisible(rain);
        }
        if (rain>0) {
          // Set rain lines in front of camera
          for (var line in rainlines) {
            line.position.copy(Camera._camera.position);
            line.position.y -= Camera.cameraoffset;
            line.rotation.y = Camera._camera.rotation.y;
            line.translateZ(-0.5);
            line.translateX(1.3 * ((Math.random() - 0.5)));

          }
        }
      }


      if (!fogindoors&&You.indoors()) {
      } else if (newfog != fog) {
        // Take 30 seconds to change to new cloud
        double lerp = (System.currentMilliseconds() - Weather.newfogtick) / (weatherchangetime * 1000);
        if (lerp >= 1) {
          fog = newfog;
        } else {
          fog = newfog * lerp + oldfog * (1 - lerp);
        }
        changeFog(fog);
      }
    }
    lastindoors=indoors;
  }

}

/// Position as specified in config.json
class Position
{
   late THREE.Vector3 position;
   late THREE.Object3D? object;
   late Map positionjson;

   Position(x,y) {
      position=THREE.Vector3(x.toDouble(),y.toDouble());
      object=null;
   }
}

/// Load a pool object specified in config.json
/// [poolsize] is how many objects in the pool
/// [maxdistance] is distance where ignore the object if too far away - make zero if no [maxdistance]
/// [name] is the name of the object3d in the pool
/// [positions] is a list of every position of the object - really should be more positions than poolsize otherwise no point
///
class PoolObject
{
   late int poolsize;
   late double maxdistance;
   late String name;
  // late List<THREE.Vector3> positions;
   late List<Position> positions;
  // late List<THREE.Vector3> scales;
   late List<THREE.Object3D> objects;  // be list of poolsize objects

   double lastfullx=-999;
   double lastfully=-999;

   /// Initialize pool object [Maxdistance] is how far before will display eg if in town dont bother drawing grass
   /// [poolsize] is how many objects in the pool
   /// [name] is the name of the object3d in the pool
   PoolObject(poolsize, name, {maxdistance:0})
   {
     this.poolsize=poolsize;
     this.maxdistance=maxdistance.toDouble();
     this.name=name;
     positions=[];
    // scales=[];
     objects=[];
   }
}

/// Loading and creating objects specified in config file
class Config
{
  static Map config={};

  static List<PoolObject> poolObjects=[];

  /// Load the config file
  static loadconfig() async{
    final String response = await rootBundle.loadString('assets/config.json');
    config = await json.decode(response);
  }

  /// Go through list of positions and get those specified by [name]
  static getStaticPositionByName(name)
  {
    var items={};
    items['positions']=[];
    for (var item in config['positions']['staticpositions'])
      if (item['name']==name&&!(item.containsKey('ignore')&&item['ignore']))
        items['positions'].add(item);
    return items;
  }

  /// Get the object specified in config.son specified by [name]
  static getObjectByName(name)
  {
    for (var item in config['objects'])
      if (item['name']==name&&!(item.containsKey('ignore')&&item['ignore']))
        return item;
    return null;
  }

  /// Add a custom [object3d] of [name] to config that are not specified in config.json
  /// Useful if need to create a complicated object that is hard to define in config.json
  static addObject(name, object3d)
  {
    var mainobject={};
    mainobject['name']=name;
    mainobject['object']=[];
    var object={'object3d':object3d};
    mainobject['object'].add(object);
    config['objects'].add(mainobject);
  }

  /// Go through every object and add them to the scene [parent] based upon their position in the config file
  static createAllObjects(parent) async
  {
    for (var item in config['objects']) {
      if (!(item.containsKey('ignore')&&item['ignore'])) {
        await createStaticObjectsByName(item['name'], parent);
      }
    }
  }

  /// Set the scale of the [clone] as specified by [object3d] and its [position] specified in config.json
  static setScale(object3d, position, clone)
  {
    var s=object3d.extra['object']['s'] ?? 1.0;
    var sx, sy, sz;
    if (object3d.extra['object'].containsKey('sx'))
      sx=object3d.extra['object']['sx'];
    else
      sx=s;
    if (object3d.extra['object'].containsKey('sy'))
      sy=object3d.extra['object']['sy'];
    else
      sy=s;
    if (object3d.extra['object'].containsKey('sz'))
      sz=object3d.extra['object']['sz'];
    else
      sz=s;

    if (position.containsKey('sx'))
      sx*=position['sx'];
    else if (position.containsKey('s')) {
      sx*=position['s'];
    }
    if (position.containsKey('sy'))
      sy*=position['sy'];
    else if (position.containsKey('s')) {
      sy*=position['s'];
    }
    if (position.containsKey('sz'))
      sz*=position['sz'];
    else if (position.containsKey('s')) {
      sz*=position['s'];
    }
    if (position.containsKey('rs')) {
      var rnd=(1 + Math.random() * position['rs'] - position['rs'] / 2);
      sx *=rnd;
      sy*=rnd;
      sz*=rnd;
    }
    // ?? why must sz and sy be swapped??
    clone.scale.set(sx,sz,sy);//sy,sz);
  }

  /// Given the [object3d] and [position] of the object return its overall turn
  static getTurn(object3d, position)//, clone)
  {
    var turn = (object3d.extra['object']['t'] ?? 0.0).toDouble();
    // if (object3d.extra.containsKey['randomturn'])
    //  turn+=Math.random()*object3d.extra['randomturn']-object3d.extra['randomturn']/2;
    if (position.containsKey('rt'))
      turn+=Math.random()*position['rt']-position['rt']/2;

    if (position.containsKey('t')) {
      turn += position['t'].toDouble();

    }
    return turn;
   // Space.objTurn(clone, turn);
  }

  /// Given the [object3d] and [position] of the object return its overall pitch
  static getPitch(object3d, position)//, clone)//, {flip:false})
  {
    var turn = 0.0;
    if (object3d.extra['object'].containsKey('pitch'))
       turn=object3d.extra['object']['pitch'].toDouble();

    if (position.containsKey('pitch')) {
      turn += position['pitch'].toDouble();

    }
    return turn;
  }

  /// Given the [object3d] and [position] of the object return its overall roll
  static getRoll(object3d, position)
  {
    var turn = 0.0;
    if (object3d.extra['object'].containsKey('roll'))
      turn=object3d.extra['object']['roll'].toDouble();

    if (position.containsKey('roll')) {
      turn += position['roll'].toDouble();

    }
    return turn;
  }


  /// Given the [name] of the object specified in config.json create that object
  static getObjects3d(name) async
  {
    var mainobjects=Config.getObjectByName(name);
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
          var randommirror=false;
          var spriteflip=null;
          if (object.containsKey("randommirroru") &&
              object["randommirroru"]) {
            randommirror = true;
            spriteflip = await Sprite.loadSprite(
                object['texture'], object['width'], object['height'],
                ambient: ambient, flipx: true);
            if (object.containsKey('z'))
              spriteflip.children[0].position.y += object['z'];

          }
          if (!object.containsKey('s'))
            object['s'] = 1.0;
          object3d = await Sprite.loadSprite(
              object['texture'], object['width'], object['height'],
              ambient: ambient);
          if (object.containsKey('z'))
            object3d.children[0].position.y += object['z'];
          object3d.extra['randommirror']=randommirror;
          object3d.extra['spriteflip']=spriteflip;
        } else if (object['type'] == 'plane') {
          if (object.containsKey('text')) {
            // Plane with text

            if (!object.containsKey('s'))
              object['s'] = 1.0;
            Color color;
            if (object.containsKey('color'))
              color = ColorLib.dartColorFromHexString(object['color']);
            else
              color = Colors.white;
            var backgroundcolor;
            if (object.containsKey('backgroundcolor'))
              backgroundcolor =
                  ColorLib.dartColorFromHexString(object['backgroundcolor']);
            else
              backgroundcolor = Colors.black;

            object3d = await Plane.makeTextPlane(
                object['text'], color, fontSize: object['fontsize'] ?? 20,
                width: object['w'] ?? 200,
                backgroundcolor: backgroundcolor,
                backgroundopacity: object['backgroundopacity'] ??
                    1); //Colors.white);
            if (object.containsKey('z'))
              object3d.children[0].position.y += object['z'];
            if (!object.containsKey("t"))
              object['t'] = 0;
          } else {
            // Plane without text
            var ambient;
            if (object.containsKey('ambient') && !object['ambient'])
              ambient = false;
            else
              ambient = true;
            if (!object.containsKey('s'))
              object['s'] = 1.0;
            object3d = await Plane.loadPlane(
                object['texture'], object['width'], object['height'],
                ambient: ambient);
            if (object.containsKey('z'))
              object3d.children[0].position.y += object['z'];
            if (!object.containsKey("t"))
              object['t'] = 0;
          }
        } else if (object['type'] == 'model') {

          object3d = await Model.createModel(object['filename'],
              texture: object['texture']); //, ambient:ambient);
          if (object.containsKey('emissive')) {
            Texture.setEmissive(object3d,ColorLib.colorFromHexString(
                object['emissive']));
          }
          if (!object.containsKey('s'))
            object['s'] = 1.0;

          //   object3d.scale.set(object['s'], object['s'], object['s']);
          if (object.containsKey('z'))
            object3d.position.y += object['z'];

          if (!object.containsKey("t"))
            object['t'] = 0;

        } else if (object['type'] == 'pointlight') {
          object3d = THREE.Object3D();
          if (!object.containsKey('color'))
            object['color'] = "#FFFFFF";

        } else if (object['type'] == 'fire') {
          object3d = THREE.Object3D();
        } else if (object.containsKey('object3d')) {
          // Means is custom object
          object3d = object['object3d'];
        }
        object3d.extra['object'] = object;
        object3d.extra['configname']=name;
        object3ds.add(object3d);

      }
    }
    return object3ds;
  }

  /// Create a clone of the [object3d] so can create many copies as necessary
  static createClone(THREE.Object3D object3d) async
  {
    var clone;
    if (object3d.extra['object']['type'] == 'sprite') {
      var useobject;
      var randommirror=object3d.extra['randommirror'];
      var spriteflip=object3d.extra['spriteflip'];

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

    } else if (object3d.extra['object']['type'] == 'pointlight') {
      var color = ColorLib.colorFromHexString(
          object3d.extra['object']['color']); // int.parse(

      clone = new THREE.PointLight(color); //0xFFA500); //PointLight(0xffffff)

      if (object3d.extra['object'].containsKey('intensity'))
        clone.intensity =
            object3d.extra['object']['intensity'].toDouble();
      if (object3d.extra['object'].containsKey('distance'))
        clone.distance =
            object3d.extra['object']['distance'].toDouble();
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
          fireWidth, fireHeight, fireDepth, sliceSpacing,
          Camera._camera);
      await fire.init();

      if (object3d.extra['object'].containsKey('s'))
        fire.mesh.scale.set(
            object3d.extra['object']['s'],
            object3d.extra['object']['s'],
            object3d.extra['object']['s']);
      if (object3d.extra['object'].containsKey('z')) {
        fire.mesh.position.y =
            object3d.extra['object']['z'].toDouble();
      }

      Updateables.add(fire);
      var firemesh = fire.mesh;
      var firegroup=THREE.Group();
      firegroup.add(firemesh);
      return firegroup;
    } else {
      // Must be a custom object
      clone = object3d.clone();

    }
    clone.extra['object3d']=object3d;
    return clone;
  }

  /// Given the [object3d] at [position] as specified in config.json scale and turn the [clone]
  static setScaleTurn(object3d, position,clone)
  {
    if (object3d.extra['object']['type'] == 'sprite') {
      setScale(object3d, position, clone);
      // What is this for?
      if (position.containsKey('t')) {
        Space.objTurn(
            clone,
            position['t'].toDouble());

      }
    } else if (object3d.extra['object']['type'] == 'plane') {

      setScale(object3d, position, clone);

      Space.setTurnPitchRoll(clone, getTurn(object3d, position),
          getPitch(object3d, position),
          getRoll(object3d, position));

    } else if (object3d.extra['object']['type'] == 'model') {


      setScale(object3d, position, clone);

      Space.setTurnPitchRoll(clone, getTurn(object3d, position),
          getPitch(object3d, position),
          getRoll(object3d, position));

    } else if (object3d.extra['object']['type'] == 'pointlight') {

    } else if (object3d.extra['object']['type'] == 'fire') {

    } else {
      // Must be a custom object
      //clone = object3d.clone();
      setScale(object3d, position, clone);


      Space.setTurnPitchRoll(clone, getTurn(object3d, position),
          getPitch(object3d, position),
          getRoll(object3d, position));
    }

  }

  /// Create all the objects in the config file specified by [name] and add them to the scene [parent]
  static createStaticObjectsByName(name, parent) async
  {
    var starttick=System.currentMilliseconds();
    var items = Config.getStaticPositionByName(name);
    if (items!=null&&items['positions'].length>0) {

       var objects3d=await getObjects3d(name);

      if (objects3d!=null&&objects3d.length>0) {
        for (var object3d in objects3d) {
          for (var position in items['positions']) {

            if (!position.containsKey('ignore') || !position['ignore']) {

              var number;
              if (position.containsKey('n'))
                number = position['n'];
              else
                number = 1;
              for (var cnt = 0; cnt < number; cnt++) {

                var clone=await createClone(object3d);
                clone.extra['configname']=name;
                setScaleTurn(object3d, position,clone);

                var p = position['p'].toList();
                if (p.length == 2)
                  p.add(0.0);
                if (object3d.extra['object'].containsKey('x'))
                  p[0] += object3d.extra['object']['x'];
                if (object3d.extra['object'].containsKey('y'))
                  p[1] += object3d.extra['object']['y'];

                if (position.containsKey('rx'))
                  p[0] += (Math.random() * position['rx'] -
                      position['rx'].toDouble() / 2.0);
                if (position.containsKey('ry'))
                  p[1] += (Math.random() * position['ry'] -
                      position['ry'].toDouble() / 2.0);
                if (position.containsKey('rz'))
                  p[2] += (Math.random() * position['rz'] -
                      position['rz'].toDouble() / 2.0);

                  if (position.containsKey("d")) {
                    Space.worldToLocalSurfaceObjHide(
                        clone, p[0].toDouble(), p[1].toDouble(),
                        p[2].toDouble(), position['d'].toDouble());
                  } else {

                    Space.worldToLocalSurfaceObj(
                        clone, p[0].toDouble(), p[1].toDouble(),
                        p[2].toDouble());
                  }

                parent.add(clone);

              }
            }
          }
        }
      }
    }
    print("config time to load "+name+" "+((System.currentMilliseconds()-starttick)/1000.0).toString());
  }


  /// Given the pool objects specified in config.json create all the positions and the objects in the scene [parent]
  static createPoolObjects(parent) async
  {
    if (config['positions'].containsKey("poolpositions")) {
      for (var item in config['objects']) {
        if (!(item.containsKey('ignore') && item['ignore'])) {
          var name = item['name'];
          print("pool position"+name);
          var poolpositions = config['positions']['poolpositions'];
          for (var poolposition in poolpositions) {
            var poolsize = poolposition['poolsize'];
            var maxdistance = poolposition['maxdistance'];

            for (var position in poolposition['positions']) {
              if (position['name'] == name &&
                  !(position.containsKey('ignore') && position['ignore'])) {
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
                  usePoolObject =
                      PoolObject(poolsize, name, maxdistance: maxdistance);
                  poolObjects.add(usePoolObject);
                }
                // Generate all the position points
                var n = position['n'] ?? 1;
                for (var i = 0; i < n; i++) {
                  var pos = Position(position['p'][0], position['p'][1]);

                  // var p = position['p'].toList();
                  if (position['p'].length == 2)
                    pos.position.z = 0.0;
                  else
                    pos.position.z = position['p'][2];

                  if (position.containsKey('rx'))
                    pos.position.x += (Math.random() * position['rx'] -
                        position['rx'].toDouble() / 2.0);
                  if (position.containsKey('ry'))
                    pos.position.y += (Math.random() * position['ry'] -
                        position['ry'].toDouble() / 2.0);
                  if (position.containsKey('rz'))
                    pos.position.z += (Math.random() * position['rz'] -
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
      var names=[];
      for (var poolObject in poolObjects) {
        if (!names.contains(poolObject.name))
          names.add(poolObject.name);
      }
      for (var name in names) {
        var objects3d=await getObjects3d(name);
        // Need to create clones of poolsize without adding them to the scene
        for (var poolObject in poolObjects) {
          if (poolObject.name==name) {
            var init=poolObject.objects.length;
            for (var i=init; i<poolObject.poolsize; i++) {
              var clone = await createClone(objects3d[0]);
              clone.visible=false;
              poolObject.objects.add(clone);
              parent.add(clone);
            }
          }
        }
      }
    }
  }

  static double lastx=-999;
  static double lasty=-999;

  /// The the players world position [x] [y] display the pool objects around the player
  static showPoolsObjects(x,y)
  {
    if ((x-lastx).abs()>1||(y-lasty).abs()>1) {
      for (var poolObject in poolObjects) {
        if (poolObject.positions.length > 0) {
          // if positions is quite small vs the poolsize then always sort it
          if ((x-poolObject.lastfullx).abs()>5||(y-poolObject.lastfully).abs()>5||poolObject.positions.length<poolObject.poolsize*3) {

            poolObject.positions.sort((a, b) =>
                ((a.position.x - x).abs() + (a.position.y - y).abs()).compareTo(
                    (b.position.x - x).abs() + (b.position.y - y).abs()));
            poolObject.lastfullx=x;
            poolObject.lastfully=y;
          } else {
            // Dont sort the whole thing if havent moved much
            var positions1=poolObject.positions.sublist(0, poolObject.poolsize*2);
            var positions2=poolObject.positions.sublist( poolObject.poolsize*2);
            positions1.sort((a, b) =>
                ((a.position.x - x).abs() + (a.position.y - y).abs()).compareTo(
                    (b.position.x - x).abs() + (b.position.y - y).abs()));
            poolObject.positions=positions1+positions2;
          }
          // if have maxdistance and positions too far away dont bother
          if (poolObject.maxdistance == 0 || Math.vectorDistance(THREE.Vector3(
              poolObject.positions[0].position.x,
              poolObject.positions[0].position.y), THREE.Vector3(x, y)) <
              poolObject.maxdistance) {
            // Go through all the distances greater than pool size and remove
            for (var i = poolObject.poolsize; i <
                poolObject.positions.length; i++) {
              if (poolObject.positions[i].object != null) {
                poolObject.positions[i].object!.extra.remove('hasposition');
                poolObject.positions[i].object = null;
              }
            }

            // Find those in the poolsize that haven't been added
            var inc = 0;
            for (var i = 0; i < poolObject.poolsize; i++) {
              //final object = poolObject.positions[i].object;
              if (i<poolObject.positions.length&&poolObject.positions[i].object == null) {
                innerloop:
                for (var j = inc; j < poolObject.objects.length; j++) {
                  if (!poolObject.objects[j].extra.containsKey('hasposition')) {
                    // Use this one
                  //  print("have added position");
                    poolObject.objects[j].extra['hasposition'] = true;
                    poolObject.positions[i].object = poolObject.objects[j];
                    var positionjson = poolObject.positions[i].positionjson;
                    setScaleTurn(
                        poolObject.objects[j].extra['object3d'], positionjson,
                        poolObject.objects[j]);

                    Space.worldToLocalSurfaceObj(
                        poolObject.objects[j],
                        poolObject.positions[i].position.x,
                        poolObject.positions[i].position.y,
                        poolObject.positions[i].position.z);

                    poolObject.objects[j].visible=true;
                    inc = j + 1;
                    break innerloop;
                  }
                }
              }
            }

          }
        }
      }
      lastx=x;
      lasty=y;
    }
  }
}


/// Mob procedures specifically for NPC's such as walking around, showing speech text for NPC
class Mob
{
  static List chatterlist=[];
  static List speechlist=[];
  static bool colorfromname=false;

  /// Give the npc [object] a name [mobname]
  static setName(object,mobname)
  {
    object.extra['mobname']=mobname;
  }

  /// So know original facing direction if set facing the player
  static setInitTurn(object,turn)
  {
    object.extra['origturn']=turn.toDouble();
    Space.objTurn(object, turn.toDouble());
  }

  static getOrigTurn(object) {
    if (object.extra.containsKey('origturn'))
      return object.extra['origturn'];
    else
      return null;
  }

  /// Get the name of the NPC [object]
  static getName(object)
  {
    if (object.extra.containsKey('mobname'))
      return object.extra['mobname'];
    else
      return "";
  }

  /// Place text on an NPC
  /// [msg] what NPC should say
  /// [textcolor] for color of text and if not specified will use npcs name as a seed to get a random color
  /// [z] is how high the text should be
  /// [width] is how wide the text should be
  /// Set the [scale] of the text
  /// Set the [backgroundcolor] of the text
  /// Set the  opacity [backgroundopacity] of the backgroundcolor
  /// [fontfamily] of the text
  static setText(THREE.Object3D object,msg,{textcolor:null, fontSize:20, z:50, width:200, scale, backgroundcolor, backgroundopacity, fontfamily}) async
  {
    if (textcolor==null) {
      if (colorfromname&&Mob.getName(object)!="")
        textcolor = ColorLib.colorFromText(Mob.getName(object));
      else
        textcolor=  Colors.white;
    }

    if (backgroundcolor==null)
      backgroundcolor=Colors.black;
    if (backgroundopacity==null)
      backgroundopacity=0.5;
    var spritey = await Sprite.makeTextSprite(msg, textcolor, fontSize:fontSize, z:z, width:width, backgroundcolor: backgroundcolor, backgroundopacity: backgroundopacity, fontfamily:fontfamily);

    if (scale!=null) {
      spritey.scale.x = spritey.scale.x * scale;
      spritey.scale.y = spritey.scale.y * scale;
    }
    // Remove any other text
    if (object.extra.containsKey('namesprite')) {
      object.remove(object.extra['namesprite']);
    }
    object.extra['namesprite']=spritey;
    object.add(spritey);
  }

  /// Update an NPC - randomly get a chatter from an NPC and continue any speeches
  static update()
  {
    var chatter = Mob.nextChatter();
    if (chatter != null) {
      var obj = chatter["object"];
      Mob.setText(obj, chatter['chatter'], z:chatter['z'], width:chatter['width'], scale:chatter['scale']);
    }

    var speech = Mob.nextSpeech();
    if (speech != null) {
      var obj = speech["object"];
      Mob.setText(obj, speech['chatter'], z:speech['z'], width:speech['width'], scale:speech['scale']);
    }
  }

  /// Remove text from NPC [object]
  static clearText(object)
  {
    if (object.extra.containsKey('namesprite')) {
      object.remove(object.extra['namesprite']);
      object.extra.remove('namesprite');
    }
  }

  /// Set the random chatter for an npc picking random line from chatter at random intervals [randwait]
  /// The [chatter] is a list of text strings that will randomly pick from
  /// [randwait] is the number of seconds wait for next chatter between 0 and randwait. [minwait] is minimum wait
  /// [start] specifies if begin chatter straight away
  /// [z] is how high the chat should be on npc
  /// [width] is how wide the chat is for the npc
  /// Set the [scale] of the text
  /// [delay] seconds before start the chatter
  static setChatter(object, chatter,{randwait:20, minwait:5, start:true, z:50, width:200, scale, delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        setChatter(object, chatter,randwait:randwait, minwait:minwait, start:start, z:z, width:width, scale:scale);
      });
      BaseObject.addTimer(object,t);

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
      if (!chatterlist.contains(object))
        chatterlist.add(object);
    }
  }

  /// Based upon the chat randwait and minwait randomly gets a time for the next chat in the future for the NPC
  static randomNextChat(object)
  {
    return System.currentMilliseconds()+Math.random()*object.extra['chatterrandwait']*1000+object.extra['chatterminwait']*1000;
  }

  /// Stop the chatter for the [object] NPC
  static pauseChatter(object)
  {
    object.extra['nextchatter']=-1;
  }


  static startChatter(object)
  {
    object.extra['nextchatter']=randomNextChat(object);
  }

  static nextChatter()
  {
    for (var i=chatterlist.length-1; i>=0; i--) {
      var obj=chatterlist[i];
      if (obj==null) {
        chatterlist.remove(obj);
      } else if (obj.visible&&obj.extra['nextchatter']!=-1) {
        if (System.currentMilliseconds()>=obj.extra['nextchatter']) {
          obj.extra['nextchatter']=randomNextChat(obj);
          return {"object":obj,"chatter":obj.extra['chatter'][(Math.random()*obj.extra['chatter'].length).floor()],'z':obj.extra['chatterz'],'width':obj.extra['chatterwidth'],'scale':obj.extra['chatterscale']};
        }
      }

    }
    return null;
  }

  /// Say a speech specified by the text array [chatter] doing line by line in [chatter] with [wait] interval
  /// [wait] is the number of seconds wait for next speech line
  /// [z] is how high the chat should be on npc
  /// [width] is how wide the chat is for the npc
  /// [scale] is scale of the text generated
  /// [delay] is how many seconds before start the speech
  static setSpeech(object, chatter,{randwait:10, minwait:5, z:50, width:200, scale, delay})
  {

    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        setSpeech(object, chatter,minwait:minwait, randwait:randwait,z:z, width:width, scale:scale);
      });
      BaseObject.addTimer(object,t);

    } else {
      pauseChatter(object);
      object.extra['speech'] = chatter;
      object.extra['speechrandwait'] = randwait;
      object.extra['speechminwait'] = minwait;
      object.extra['speechpos'] = 0;
      object.extra['nextspeech'] =
          System.currentMilliseconds(); //nextSpeech(object);
      object.extra['speechz'] = z;
      object.extra['speechwidth'] = width;
      object.extra['speechscale'] = scale;
      speechlist.add(object);
    }
    if (randwait==0) {
      if (delay==null)
        delay=0;
      return delay+chatter.length*minwait;
    } else
      return -1;

  }

  /// Pause the speech of the npc [object]
  static pauseSpeech(object)
  {
    object.extra['nextspeech']=-1;
  }

  static nextSpeechTime(object)
  {
    return System.currentMilliseconds()+Math.random()*object.extra['speechrandwait']*1000+ object.extra['speechminwait']*1000;
  }


  /// Get the next line in the speech if the correct amount of time has passed
  static nextSpeech()
  {
    for (var i=speechlist.length-1; i>=0; i--) {
      var obj=speechlist[i];
      if (obj==null) {
        chatterlist.remove(obj);
      } else if (obj.visible&&obj.extra['nextspeech']!=-1) {
        if (System.currentMilliseconds()>=obj.extra['nextspeech']) {
          var ret={"object":obj,"chatter":obj.extra['speech'][obj.extra['speechpos']],'z':obj.extra['speechz'],'width':obj.extra['speechwidth'],'scale':obj.extra['speechscale']};
          obj.extra['speechpos']++;
          if ( obj.extra['speechpos']<obj.extra['speech'].length)
            obj.extra['nextspeech']=nextSpeechTime(obj);
          else
            obj.extra['nextspeech']=-1;
          return ret;
        }
      }
    }
    return null;
  }

  /// Have [actor] loop between points in [positions] looping through all the positions.
  /// Eg if want to have an npc walk up and down a street
  /// moveToLoop stops if actor stops being visible so if lots of npcs dont have huge number walking when not visible
  ///
  /// [positions] is a list of 4 elements, the first 3 is the x,y,z position and the 4 is the velocity in m/s
  /// [action] is what animation action such as walking should be done while moving
  /// [facedir] makes actor face in the direction they're walking
  /// [randomposition] means actor will start at a random point in the positions array otherwise they start from the beginning every time
  /// [surfaceonly] means will always check the terrain when moving - useful if walking over hilly terrain - stop walking through a hill
  static moveToLoop(actor, List<List> positions,  {action, facedir:true,   index:0,id:-1, randomposition:false, surfaceonly}) async
  {
    if ((id!=-1&&actor.extra['movetoid']!=id)||!System.active/*||!actor.visible*/) {
      // have overriden with another moveto
      print("done moveto");
      return;
    }

    var originalloc=Space.localToWorld(actor.position.x, actor.position.y, actor.position.z);
    if (id==-1) {
      print("init moveto");
      // if loop go back to original position

      id=(Math.random()*10000).floor();
      actor.extra['movetoid']=id;
      if (actor.extra.containsKey('movetoloopindex')) {
        // If restarting moveloop then put the index back to what it was so can continue loop
        index=actor.extra['movetoloopindex'];
      } else if (randomposition) {
          var initindex = Math.randInt(positions.length - 1);
          var posa = positions[initindex];
          if (initindex == positions.length - 1) {
            index = 0;
          } else {
            index = initindex + 1;
          }
          var posb = positions[index];

          double lerp = Math.random();
          Space.worldToLocalSurfaceObj(
              actor, (1 - lerp) * posa[0] + lerp * posb[0],
              (1 - lerp) * posa[1] + lerp * posb[1],
              (1 - lerp) * posa[2] + lerp * posb[2]);

      } else {
        Space.worldToLocalSurfaceObj(actor, positions[0][0],positions[0][1],positions[0][2]);
        index++;
      }
    }
    actor.extra['movetoloopindex']=index;

    var speed=positions[index][3].toDouble(); // m/s
    var   dist = Math.vectorDistance(
        THREE.Vector3(originalloc.x,originalloc.y, 0),
        THREE.Vector3(positions[index ][0], positions[index ][1], 0));


    var time=dist/speed;

    if (surfaceonly!=null&&surfaceonly)
      Space.worldToLocalSurfaceOnlyObjLerp(actor,positions[index][0].toDouble(),positions[index][1].toDouble(),positions[index][2].toDouble(),time.toDouble());
    else
      Space.worldToLocalSurfaceObjLerp(actor,positions[index][0].toDouble(),positions[index][1].toDouble(),positions[index][2].toDouble(),time.toDouble());
    if (facedir)
      Space.facePointLerp(actor,positions[index][0].toDouble(),positions[index][1].toDouble(),1);
    if (action!=null) {
      (await Actor.getAction(actor, name: action)).reset().play();
    }

    new Timer(new Duration(milliseconds: (time * 1000).floor()), () async {
      // cancel started an new one
      if (actor.visible && id == actor.extra['movetoid']) {
        if (index + 1 < positions.length) {
          moveToLoop(actor, positions, action: action,
              facedir: facedir,
              id: id,
              surfaceonly: surfaceonly,
              index: index + 1);
        } else {
          moveToLoop(actor, positions, action: action,
              facedir: facedir,
              id: id,
              surfaceonly: surfaceonly,
              index: 0);

        }
      } else {
        print("done movetoii"+actor.visible.toString());
      }
    });

  }

  /// By default randomwalk rememembers where the [actor] last was so when reappears is in last spot that moved
  /// This resets the randomwalk for the [actor]
  static resetrandomwalk(actor)
  {
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
  /// For example a sheep just randomly walking around a field
  /// Randomwalk stops if actor stops being visible so if lots of npcs dont have huge number walking when not visible
  /// [walkingchance] the percent of time walking rather than standing idling
  /// [action] is the action the [actor] does while moving eg walking and [actionduration] is how long to do the action in seconds
  /// [stopaction] is the action the [actor] does when stops eg idle
  /// [reset] means dont lerp from initial position instead just instantly set a new position
  /// [z] is how high from surface that move
  /// [surfaceonly] means will always check the terrain when moving - useful if walking over hilly terrain - stop walking through a hill

  static randomwalk(actor, distfrominit, speed, walkingchance, {action, actionduration, stopaction, id=-1, reset:false, z, surfaceonly}) async
  {
    if (id!=-1&&!actor.extra.containsKey('movetoidrand')) { // means completely cleared random walk
      print("cleared randomwalk");
      return;
    }
    if ((id!=-1&&actor.extra['movetoidrand']!=id)||!System.active) {
      print("done random moveto"+actor.extra['movetoidrand'].toString()+" id"+id.toString()+" "+System.active.toString());

     // Issue where if restarts randomwalk then you get gliding
      if (stopaction != null) {
        print("stop walk action randomwalk" + stopaction);
        (await Actor.getAction(
            actor, name: stopaction, stopallactions: true))
            .reset()
            .play();
      }
      return;
    }
    var originalloc;
    if (z==null)
      z=0;
    if (id==-1) {
      Space.removeObjectFromLerp(actor);
      id = (Math.random() * 10000).floor();
      actor.extra['movetoidrand'] = id;
      if (actor.extra.containsKey('randomwalkinitpos'))
        originalloc=actor.extra['randomwalkinitpos'];
      else {
        originalloc = Space.localToWorld(
            actor.position.x, actor.position.y, actor.position.z);
        actor.extra['randomwalkinitpos'] = originalloc;
      }

      if (stopaction!=null) {
        // stop actor walking on the spot if become unhidden
        print("randomwalk stop action");
        (await Actor.getAction(
            actor, name: stopaction, stopallactions: true))
            .reset()
            .play();
      }
      if (actor.extra.containsKey('randomwalkx')) {
        // If hidden and now reappears then put back where it was last
        Space.worldToLocalSurfaceObj(actor,actor.extra['randomwalkx'],actor.extra['randomwalky'],z);
      } else if (reset) {
        // Only reset once so doenst jump around when go near it again
        if (!actor.extra.containsKey('randomwalkhasreset')) {
          var randx = originalloc.x + 2 * (Math.random() - 0.5) * distfrominit;
          var randy = originalloc.y + 2 * (Math.random() - 0.5) * distfrominit;
          Space.worldToLocalSurfaceObj(actor, randx, randy, z.toDouble());
          actor.extra['randomwalkhasreset']=true;
        }
      }
      if (walkingchance<1) {
        var t=new Timer(new Duration(
            milliseconds: (Math.random() * 10 * 1000).floor()), () async {
          randomwalk(actor, distfrominit, speed, walkingchance, action: action, actionduration:actionduration,
              stopaction: stopaction,
              surfaceonly: surfaceonly,
              id: id, z:z);
        });
        BaseObject.addTimer(actor, t);
        return;
      }

    } else {
      originalloc=actor.extra['randomwalkinitpos'];
    }
    var randx=originalloc.x+2*(Math.random()-0.5)*distfrominit;
    var randy=originalloc.y+2*(Math.random()-0.5)*distfrominit;
    moveTo(actor, [[randx,randy,z,speed]],action:action, actionduration:actionduration, stopaction:stopaction, surfaceonly:surfaceonly);

    var   dist = Math.vectorDistance(THREE.Vector3(originalloc.x,originalloc.y, 0), THREE.Vector3(randx, randy, 0));
    var time=dist/speed;
    var t=new Timer(new Duration(milliseconds: (time * 1000).floor()), () async {
      // cancel started an new one
      if (actor.visible && id == actor.extra['movetoidrand']) {
        if (walkingchance<1) {
          // if walk took 5 second then if 10% chance walk then should wait for 50 seconds
          var waittime=time/walkingchance;
          new Timer(new Duration(milliseconds: (waittime * 1000).floor()), () async {
            randomwalk(actor,distfrominit, speed, walkingchance, action:action, actionduration:actionduration, stopaction:stopaction, id:id, z:z, surfaceonly:surfaceonly);

          });
        } else
          randomwalk(actor,distfrominit, speed, walkingchance, action:action, actionduration:actionduration, stopaction:stopaction, id:id, z:z, surfaceonly:surfaceonly);
      } else if (actor.extra.containsKey('movetoidrand')){
        //if 'movetoidrand' removed then means completely kill random walk
        if (stopaction != null) {
          print("stop walk actioniirandomwalk " + stopaction+ "id"+id.toString()+' '+actor.extra['movetoidrand'].toString());
          var worldpos = Space.localToWorldObj(actor);
          actor.extra['randomwalkx']=worldpos.x;
          actor.extra['randomwalky']=worldpos.y;
          Space.removeObjectFromLerp(actor);
          (await Actor.getAction(
              actor, name: stopaction, stopallactions: true))
              .reset()
              .play();
        }
      }
    });
    BaseObject.addTimer(actor, t);
  }

  /// Move an [actor] through list of [positions]  world coordinates, if a forth coordinate is specified it is the speed the move otherwise use 0.2 m/s
  /// [action] is the action the [actor] does while moving eg walking with duration [actionduration]
  /// [facedir] is whether the [actor] faces in the direction moving through the [positions]
  /// When gone through the [positions] what is the [stopaction] when stops eg idle
  /// [surfaceonly] means that the [actor] will not simply lerp from one point in [positions] to another but also check the surface terrain - useful if walking over bumpy terrain
  /// [delay] is how many seconds before start moving
  /// Returns how long it takes in seconds to reach the final position
  static moveTo(actor, List<List> positions,  {action, actionduration, facedir:true, stopaction,  index:0,id:-1, surfaceonly, delay}) async
  {
    var totaltime=-1.0;
    if (id==-1) {
      totaltime=0;
      if (delay!=null) {
        double del=delay.toDouble();
        totaltime += del;// as double;
      }
      var speed;
      var originalloc = Space.localToWorld(
          actor.position.x, actor.position.y, actor.position.z);
      for (var i=0; i<positions.length; i++) {
        if (positions[index].length <= 3)
          speed = 0.2;
        else
          speed = positions[index][3].toDouble(); // m/s
        var dist;
        if (i==0)
          dist= Math.vectorDistance(
              THREE.Vector3(originalloc.x, originalloc.y, 0),
              THREE.Vector3(positions[i][0], positions[i][1], 0));
        else
          dist= Math.vectorDistance(
              THREE.Vector3(positions[i][0], positions[i][1], 0),
              THREE.Vector3(positions[i-1][0], positions[i-1][1], 0));
        var time = dist / speed;
        totaltime+=time;
      }
    }
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).floor()), () {
        moveTo(actor, positions,  action:action, actionduration:actionduration, facedir:facedir, stopaction:stopaction, surfaceonly:surfaceonly);
      });
      BaseObject.addTimer(actor, t);
    } else {
      if (id != -1 && actor.extra['movetoid'] != id) {
        // have overriden with another moveto
        print("done moveto");
        return;
      }

      if (id == -1) {
        print("init moveto");
        // if loop go back to original position

        //  positions.insert(0, [originalloc.x,originalloc.y,positions[positions.length-1][2],positions[positions.length-1][3]]);
        //  index++;
        id = (Math.random() * 10000).floor();
        actor.extra['movetoid'] = id;

      }
      // print("uuu"+positions.length.toString()+" "+index.toString());
      if (positions[index].length <= 2)
        positions[index].add(0.0);
      var speed;
      if (positions[index].length <= 3)
        speed = 0.2;
      else
        speed = positions[index][3].toDouble(); // m/s
      var originalloc = Space.localToWorld(
          actor.position.x, actor.position.y, actor.position.z);
      var dist = Math.vectorDistance(
          THREE.Vector3(originalloc.x, originalloc.y, 0),
          THREE.Vector3(positions[index][0], positions[index][1], 0));

      var time = dist / speed;
      print("moveto" + time.toString() + " d" + dist.toString() + " s" +
          speed.toString() + " o" + originalloc.x.toString() + " " +
          originalloc.y.toString() + " p" + positions[index][0].toString() +
          " " + positions[index][1].toString() + " " +
          positions[index][2].toString()+" surface"+surfaceonly.toString());
      if (surfaceonly!=null&&surfaceonly)
         Space.worldToLocalSurfaceOnlyObjLerp(
          actor, positions[index][0].toDouble(), positions[index][1].toDouble(), positions[index][2].toDouble(),
          time);
      else
        Space.worldToLocalSurfaceObjLerp(
          actor, positions[index][0].toDouble(), positions[index][1].toDouble(), positions[index][2].toDouble(),
          time);

      if (facedir)
        Space.facePointLerp(actor, positions[index][0].toDouble(), positions[index][1].toDouble(), 1);

      if (action != null) {
        (await Actor.getAction(actor, name: action,
            duration: actionduration,
            stopallactions: true)).reset().play();
      }

      new Timer(new Duration(milliseconds: (time * 1000).floor()), () async {
        // cancel started an new one
        if (actor.visible && actor.extra.containsKey('movetoid')&&id == actor.extra['movetoid']) {
          if (index + 1 < positions.length) {
            print("moveto "+surfaceonly.toString());
            moveTo(actor, positions, action: action,
                facedir: facedir,
                stopaction: stopaction,
                id: id,
                index: index + 1, surfaceonly: surfaceonly);
          } else {
            if (stopaction != null) {
              print("stop walk moveto action" + stopaction);
              (await Actor.getAction(
                  actor, name: stopaction, stopallactions: true))
                  .reset()
                  .play();
            }
          }
        } else if (!actor.visible) {
          // go where when not visible or movetoid gone
          print("done movetoii moveto");
          // So that when come back isn't standing in one spot
          if (stopaction != null) {
            print("stop walk action" + stopaction);
            (await Actor.getAction(
                actor, name: stopaction, stopallactions: true))
                .reset()
                .play();
          }
        }
      });
      //}
    }
    return totaltime;
  }

  /// Place an [actor]  [dist] distance in front of the camera taking [time] seconds to get there with animation [action] and using [stopaction] when reached the position
  /// [offset] is how far left or right from the center in frant of camera. Eg if place three items in front of camera might want one to the left, one middle one on right
  /// [delay] how long delay before placing before camera in seconds
  /// [speed] instead of using time to get their, instead use speed in m/s to get there
  /// placement in [z] axis
  static placeBeforeCamera(actor,dist,  {time, action, stopaction, offset, delay, speed, z}) async
  {
    if (delay != null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).round()), () {
        placeBeforeCamera(actor,dist, time:time, action:action, stopaction:stopaction, offset:offset, speed:speed, z:z);
      });
      BaseObject.addTimer(actor,t);

    } else {
      if (action != null) {
        (await Actor.getAction(actor, name: action, stopallactions: true)).reset().play();
      }
      print("start action before camera"+action.toString()+" "+Mob.getName(actor));
      if (speed!=null) {
        // If speed then calculate time to get to position
        THREE.Vector2 pos=Space.getPlaceBeforeCameraPos(actor,dist, offset:offset);
        var pos3=THREE.Vector3(pos.x, pos.y,0);
        var worldpos = You.getWorldPos();
        worldpos.z=0;
        var dist2 = Math.vectorDistance(pos3, worldpos);
        time=dist2/speed;
        print("new time camera"+time.toString()+" d"+dist2.toString()+" v"+speed.toString());
      }
      Space.placeBeforeCamera(actor, dist, time: time, offset: offset, z:z);
      var t=new Timer(new Duration(milliseconds: (time * 1000).floor()), () async {

        Space.faceObjectLerp(actor, Camera._camera,0.5);

        if (stopaction != null) {
          print("stopaction place before camera" + stopaction);
          (await Actor.getAction(actor, name: stopaction, stopallactions: true))
              .reset()
              .play();
        }
      });
      BaseObject.addTimer(actor,t);
      var angle=Space.getAngleBetweensObjs(Camera._camera, actor);//, object2)

      Space.objTurnLerp(actor, angle - 180, 1);


    }

  }

}

/// Procedures related to rooms
/// As a player moves around can enter a room which has a position with width and height
/// Can set that indoors so it doesn't rain inside and also set the background sound of the room
/// Can also set trigger so when enter a room certain things can happen
class Room
{
  // You flick between sound1 and sound2 when move to different rooms
  static late audioplayers.AudioPlayer backgroundsound11;
  static late audioplayers.AudioPlayer backgroundsound12;
  static  String backgroundsoundpath1="";
  static late audioplayers.AudioPlayer backgroundsound21;
  static late audioplayers.AudioPlayer backgroundsound22;
  static String backgroundsoundpath2="";
  static late audioplayers.AudioPlayer backgroundrandomsound;
  static bool hasinitialised=false;


  /// Initialise sound for rooms
  static init()
  {
    // two audioplayers for two rooms so that dont hear gaps when loop such as fire
    if (!hasinitialised) {
      backgroundsound11 = audioplayers.AudioPlayer();
      backgroundsound12 = audioplayers.AudioPlayer();
      backgroundsound21 = audioplayers.AudioPlayer();
      backgroundsound22 = audioplayers.AudioPlayer();
      backgroundrandomsound=audioplayers.AudioPlayer();
      hasinitialised=true;
    }
  }

  /// Create a room at position [x],[y] with background sound file [path] with [volume]
  /// and also play a sound [randomsoundpath] every 0 to [randomsoundgap] seconds - eg occasional hammerming at a smithys
  /// Can specify a room that exit [exitroom] to when leave the room eg a default town room when leave a shop
  static createRoom(x,y, {soundpath, volume=1, randomsoundpath, randomsoundgap, exitroom})
  {
    var room=THREE.Object3D();
    room.extra['x']=x;
    room.extra['y']=y;
    Space.worldToLocalSurfaceObj(room, x.toDouble(),y.toDouble(), 0.0);
    if (exitroom!=null) {
      room.extra['exitroom']=exitroom;
    }
    if (soundpath!=null) {
      room.extra['backgroundsound']=soundpath;
      room.extra['backgroundvolume']=volume;
      if (randomsoundpath!=null) {
        room.extra['backgroundrandomsound'] = randomsoundpath;
        if (randomsoundgap==null)
          randomsoundgap=30;
        room.extra['backgroundrandomsoundgap'] = randomsoundgap;
      }
    }

    return room;
  }

  /// When the randomsound will next be played
  static getNextRandomsSound(room)
  {
    if (room.extra.containsKey('backgroundrandomsoundgap'))
       room.extra['backgroundsoundgapnext']=System.currentMilliseconds()+Math.random()*room.extra['backgroundrandomsoundgap']*1000;
  }

  /// Remove [room] sound
  static clearRandomSound(room)
  {
    if (room.extra.containsKey('backgroundrandomsoundgap'))
      room.extra.remove('backgroundrandomsoundgap');
    if (room.extra.containsKey('backgroundsoundgapnext'))
      room.extra.remove('backgroundsoundgapnext');

  }

  /// Get x coordinate of [room]
  static getX(room)
  {
    return room.extra['x'];
  }

  /// Get y coordinate of [room]
  static getY(room)
  {
    return room.extra['y'];
  }

  /// Get room name of [room]
  static getRoomName(room)
  {
    if (room.extra.containsKey('name'))
      return room.extra['name'];
    else
      return "";
  }

  static bool wasplaying1=false;
  static bool wasplaying2=false;

  /// [mute] the room or start the sound again
  static mute(mute) async
  {
    if (!hasinitialised)
      return;
    print("mute room"+mute.toString()+" "+roomSoundStates());
    if (mute ) {
      if (backgroundsound11.state == audioplayers.PlayerState.playing) {
        print("mute room11 "+mute.toString()+" "+roomSoundStates());
        wasplaying1=true;
        backgroundsound11.stop();
        backgroundsound12.stop();
      }
      if (backgroundsound21.state == audioplayers.PlayerState.playing) {
        print("mute room21 "+mute.toString()+" "+roomSoundStates());
        wasplaying2=true;
        backgroundsound21.stop();
        backgroundsound22.stop();
      }
    } else {
      if (wasplaying1) {
        backgroundsound11.resume();
        Duration? duration=(await backgroundsound12.getDuration());
        if (duration!=null) {
          backgroundsound12.seek(Duration(
              milliseconds: (duration!.inMilliseconds / 2).round())); //5));
          backgroundsound12.resume();
        }
        wasplaying1=false;
      }
      if (wasplaying2) {
        backgroundsound21.resume();
        var duration=await backgroundsound22.getDuration();
        backgroundsound22.seek(Duration(milliseconds:(duration!.inMilliseconds/2).round()));//5));
       // backgroundsound22.seek(Duration(seconds: 5));
        backgroundsound22.resume();
        wasplaying2=false;
      }
    }
  }


  /// If [room] is [indoors] then rain will not appear anywhere in the room
  static setIndoors(room,indoors)
  {
    room.extra['indoors']=indoors;
  }

  /// Will check if a roof mesh is above your head automatically in the [room] if [indoors] and if so rain will not appear
  /// Means some parts of room can have rain and others doesn't depending on whether there is a roof above your head
  static setAutoIndoors(room,indoors)
  {
    room.extra['autoindoors']=indoors;

  }

  /// Provide a [room] with a function [func] that determines if the user is inside or not - allows custom code to determine if indoors
  static setIndoorsFunc(room,func)
  {
    room.extra['indoorsfunc']=func;
  }

  /// Is the point [x],[y] inside the room?
  static pointInRoom(room,x,y)
  {
    return room.extra.containsKey('roomminx')&&x>=room.extra['roomminx']&&x<=room.extra['roommaxx']&&y>=room.extra['roomminy']&&y<=room.extra['roommaxy'];
  }

  /// Add an [object] to a [room] - these will only be visible if inside room
  static addRoomObject(room, object)
  {
    if (!room.extra.containsKey('roomobjects'))
      room.extra['roomobjects']=[];
    if (!room.extra['roomobjects'].contains(object)) {
      object.visible=false; // only show it if inside room
      room.extra['roomobjects'].add(object);

    }
  }

  /// Get the [room] background sound
  static getBackgroundSoundPath(room)
  {
    if (room.extra.containsKey("backgroundsound"))
      return room.extra["backgroundsound"];
  }

  /// Set the [room] background sound with asset [path]
  static setBackgroundSoundPath(room, path)
  {
      room.extra["backgroundsound"]=path;
  }

  /// Get the [room] volume
  static getBackgroundVolume(room)
  {
    if (room.extra.containsKey("backgroundvolume"))
      return room.extra["backgroundvolume"];
  }

  /// Set the [room] [volume]
  static setBackgroundVolume(room, volume)
  {
       room.extra["backgroundvolume"]=volume;
  }

  /// Create a trigger on a room with its boundaries. Will play background sound when you enter the room
  /// If [dist] specified then the room will be a square of dist from the rooms center
  /// Otherwise can use [minx], [miny], [maxx] and [maxy] world coordinates to specify the boundaries of the room
  static setDistanceTrigger(room, {minx,maxx, miny,maxy, dist }) {
    if (dist!=null) {
      minx=room.extra['x']-dist;
      maxx=room.extra['x']+dist;
      miny=room.extra['y']-dist;
      maxy=room.extra['y']+dist;
    }
    room.extra['roomminx']=minx;
    room.extra['roommaxx']=maxx;
    room.extra['roomminy']=miny;
    room.extra['roommaxy']=maxy;
    BaseObject.setDistanceTrigger(room, ndist:maxy-room.extra['y'],sdist:room.extra['y']-miny,wdist:room.extra['x']-minx,edist:maxx-room.extra['x']);
    room.extra['trigger'].addEventListener( 'trigger',  ( THREE.Event event ) async {
      if (event.action) {
        print("entered room");
        // show objects if enter room
        if (room.extra.containsKey('roomobjects')) {
          print("contains room objects");
          for (var object in room.extra['roomobjects'])
            object.visible = true;
        }
        You.room = room;

        getNextRandomsSound(room);
        if ( getBackgroundSoundPath(room)!=null) {  //room.extra.containsKey("backgroundsound")) {
          // Has two sounds so that when loop don't get gap
          backgroundsound11.setReleaseMode(audioplayers.ReleaseMode.loop);
          backgroundsound12.setReleaseMode(audioplayers.ReleaseMode.loop);
          backgroundsound21.setReleaseMode(audioplayers.ReleaseMode.loop);
          backgroundsound22.setReleaseMode(audioplayers.ReleaseMode.loop);


          if ((backgroundsound11.state == audioplayers.PlayerState.playing &&
              getBackgroundSoundPath(room)== backgroundsoundpath1) ||
              (backgroundsound21.state == audioplayers.PlayerState.playing &&
                  getBackgroundSoundPath(room) == backgroundsoundpath2)) {
            // do nothing as is already playing
          } else {
            var val = getPlaying();
            var usesoundto = val[0];
            var usesoundfrom = val[1];


            print("roomsoundplay "+getRoomName(room)+getBackgroundSoundPath(room).toString());

            var duration=await Sound.play(sound:usesoundto[0], path: getBackgroundSoundPath(room), loop:true,
                volume: getBackgroundVolume(room));//room.extra['backgroundvolume']);
            if (duration<=0)
              duration=5;

            print("duration"+duration.toString());
            await Sound.play(sound:usesoundto[1], path: getBackgroundSoundPath(room),
                loop:true,
                volume: getBackgroundVolume(room), seek:duration/2.0);;//5);

            Sound.fadeIn(usesoundto[0], 2);
            Sound.fadeIn(usesoundto[1], 2);

          }
          //print("play "+room.extra['backgroundsound']);
        } else {
          // Entered a room with no sound therefore fade the old room
          print("entered a room with no sound");
          var val = getPlaying();
          var usesoundto = val[0];
          var usesoundfrom = val[1];
          if (Sound.isPlaying(usesoundfrom[0]))//==audioplayers.PlayerState.playing)
            Sound.fadeOut(usesoundfrom[0], 2);
          else { // bug ios
            print("with no sound stop 0");
            usesoundfrom[0].stop();
          }
          if (Sound.isPlaying(usesoundfrom[1])) //.state==audioplayers.PlayerState.playing)
            Sound.fadeOut(usesoundfrom[1], 2);
          else { // bug ios
            print("with no sound stop 1");
            usesoundfrom[1].stop();
          }


        }
      } else {
        // exit the room
        room.extra['backgroundsoundgapnext']=-1;
        if (You.room!=null&&You.room!=room&&getBackgroundSoundPath(You.room)!=null&&getBackgroundSoundPath(room)!=null&&
            getBackgroundSoundPath(You.room)==getBackgroundSoundPath(room)) {
          // do nothing as same sound in new room

          print("do nothing");
        } else {
          // Exit but not into another room
          print("roomsoundfadeout "+getRoomName(room)+getBackgroundSoundPath(room).toString());

          var val = getPlaying();
          var usesoundto = val[0];
          var usesoundfrom = val[1];
          if (Sound.isPlaying(usesoundfrom[0]))//.state==audioplayers.PlayerState.playing)
            Sound.fadeOut(usesoundfrom[0], 2);
          else { // bug in ios
            print("roomsoundfadeout stop 0");
            usesoundfrom[0].stop();
          }
          if (Sound.isPlaying(usesoundfrom[1]))//.state==audioplayers.PlayerState.playing)
            Sound.fadeOut(usesoundfrom[1], 2);
          else { // bug in ios
            print("roomsoundfadeout stop 1");
            usesoundfrom[1].stop();
          }

          if (room.extra.containsKey('exitroom')) {
            var exitroom=room.extra['exitroom'];
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

    });

  }


  /// Which background audioplayer is playing
  static getPlaying()
  {
    var usesound11;
    var usesound12;
    var usesound21;
    var usesound22;
    if (Sound.isPlaying(backgroundsound11)) {//.state==audioplayers.PlayerState.playing) {
      usesound11=backgroundsound21;
      usesound12=backgroundsound22;
      usesound21=backgroundsound11;
      usesound22=backgroundsound12;
    } else {
      usesound11=backgroundsound11;
      usesound12=backgroundsound12;
      usesound21=backgroundsound21;
      usesound22=backgroundsound22;
    }
    // usesound1 is the one to use and the usesound2 is what was used before
    return [[usesound11,usesound12],[usesound21,usesound22]];
  }

  /// Get state of background sounds for debugging
  static roomSoundStates()
  {
   // return  Sound.isPlaying(backgroundsound11).toString()+" "+Sound.isPlaying(backgroundsound12).toString()+" "
    //    +Sound.isPlaying(backgroundsound21).toString()+" "+Sound.isPlaying(backgroundsound22).toString();
 //   backgroundsound11.
    if (hasinitialised)
      return  (backgroundsound11.state).toString()+" "+backgroundsound11.releaseMode.toString()+" "+(backgroundsound12.state).toString()+" "+backgroundsound12.releaseMode.toString()+" "
            +(backgroundsound21.state).toString()+" "+backgroundsound21.releaseMode.toString()+" "+(backgroundsound22.state).toString()+" "+backgroundsound22.releaseMode.toString();
    else
      return "not initialised";
  }

  /// If random sounds in room then determine if should play or not
  static update(frameTime)
  {
    if (You.room!=null&&You.room!.extra.containsKey('backgroundsoundgapnext')&&You.room?.extra['backgroundsoundgapnext']!=-1&&
        System.currentMilliseconds()>You.room?.extra['backgroundsoundgapnext']) {
      print("play groan");
      Sound.play( path: You.room?.extra['backgroundrandomsound'], volume: 1.0);//You.room?.extra['backgroundvolume']);
      getNextRandomsSound(You.room);
    }
  }
}

/// Procedures related to color
class ColorLib
{
  /// from the seed of the username [text] get a repeatable random color
  /// Is dart Color so that can be used in widgets rather than THREE.Color
  static Color colorFromText(String text) {
    var seed = 0;
    for (var k = 0; k < text.length; k++) {
      var char = text.codeUnits[k] as int;
      seed += (k + 1) * char;
    }
    const colorlist=[Colors.yellow,Colors.red, Colors.white, Colors.lightBlueAccent,Colors.lightGreen, Colors.orange,
      Colors.white38, Colors.amberAccent, Colors.purpleAccent];
    var color= colorlist[seed % colorlist.length];
    return color;

  }

  /// Covert colors string [colorstr] eg #ffffff to a THREE color
  static colorFromHexString(colorstr) {
    return  THREE.Color(int.parse(colorstr.replaceAll("#", ""),
        radix: 16));
  }

  /// Covert colors string [code] eg #ffffff to a dart color
  static Color dartColorFromHexString(String code) {
    return  Color(int.parse(code.replaceAll("#", ""), radix:16) + 0xFF000000);
  }
}

/// Executes all updateables such a fire, water, smoke
class Updateables
{
  static List updateables=[];

  /// Add an updateable like fire
  static add(Updateable updateable) {
    updateables.add(updateable);
  }

  /// Delete the [updateable]
  static remove(updateable) {
    if (updateables.contains(updateable))
      updateable.sremove(updateable);
  }

  /// Execute the updateables - do it every frame
  static update(frameTime, elapsedTime)
  {
    for (var updateable in updateables)
      updateable.update(frameTime, elapsedTime);
  }
}

///  Functions and info related to the player
class You
{
  static THREE.Object3D? room;  // Current room the player is in

  static double speed=2; // your speed 2m/s
  static double drag=1;  // can modify the speed by a percentage
  static bool immobile=false;  // Stop player movement
  static bool immobileturn=false;  // Stop player turning

  static String wield="";  // Name of object wielding

  /// Where you are in world coordinates - returns vector3f
  static THREE.Vector3 getWorldPos()
  {
    return Space.localToWorldObj(Camera._camera);
  }

  /// Is the player indoors. Used to stop rain while inside
  /// Can set a room is always indoors with indoors flag
  /// Can set a room to be indoors only if a roof is above the player (autoindoors)
  /// Can set a room to be indoors based upon a custom function. For example if camera z is less than a certain amount is in the sea
  static indoors()
  {
    var indoors=false;
    if (room!=null) {
      indoors=room!.extra.containsKey("indoors")&&room!.extra['indoors'];
      if (!indoors) {
        if (room!.extra.containsKey("autoindoors")&&room!.extra['autoindoors']) {
          indoors= Space.roofInteresectDistance(Camera._camera.position.x,Camera._camera.position.y,Camera._camera.position.z)>0;
        }
        if (!indoors&&room!.extra.containsKey('indoorsfunc')) {
          indoors = room!.extra['indoorsfunc']();
        }
      }
    }
    return indoors;
  }

  /// What direction are you moving
  static getMoveDir()
  {
    if (lastworldpos!=null&&lastworldpos2!=null) {
      return Math.getAngleBetweenPoints( lastworldpos2,getWorldPos());
    } else
      return 0;
  }

  /// Set the player to be immobile in [delay] seconds
  static setImmobile(isimmobile,{delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).floor()), () {
        setImmobile(isimmobile);
      });
    } else
      immobile=isimmobile;
  }

  /// Set the player to not be able to turn camera (or reenable) in [delay] seconds
  static setImmobileTurn(isimmobile,{delay})
  {
    if (delay!=null) {
      Timer t = Timer(Duration(milliseconds: (delay * 1000).floor()), () {
        setImmobileTurn(isimmobile);
      });
    } else
      immobileturn=isimmobile;
  }

  static var lastworldpos=null;
  static var lastworldpos2=null;

  static update()
  {
    var worldpos=getWorldPos();
    if (lastworldpos==null||worldpos.x!=lastworldpos.x||worldpos.y!=lastworldpos.y) {
      lastworldpos2=lastworldpos;
      lastworldpos = worldpos;
    }

  }

}

/// A map item that holds a map image, two world positions and corresponding pixel positions on the image
class MapItem
{
  late String filename;  // Asset image path
  late double worldx, worldy;  //  world coordinates for a given image coordinate
  late int    imagex, imagey;
  late double worldx2, worldy2; //  world coordinates for a given image coordinate
  late int    imagex2, imagey2;
  late int  width, height;

  /// Initialise a map item with the map images [filename] alongside two points. One points being world positions and a corresponding image position
  MapItem(filename, {required worldx, required worldy, required imagex, required imagey, required worldx2, required worldy2, required imagex2, required imagey2})
  {
    this.filename=filename;
    this.worldx=worldx.toDouble();
    this.worldy=worldy.toDouble();
    this.imagex=imagex;
    this.imagey=imagey;
    this.worldx2=worldx2.toDouble();
    this.worldy2=worldy2.toDouble();
    this.imagex2=imagex2;
    this.imagey2=imagey2;
  }

  // Given the world coords [inworldx] and [inworldy] return image pixel coordinates of the map
  getImageCoordsFromWorldCoords(inworldx,inworldy)
  {
    var mx=(imagex2-imagex)/(worldx2-worldx);
    var cx=imagex2-mx*worldx2;
    var mapx=(mx*inworldx+cx);
    var my=(imagey2-imagey)/(worldy2-worldy);
    var cy=imagey2-my*worldy2;
    var mapy=(my*inworldy+cy);
    return [mapx,mapy];
  }
}

/// Functions related to maps
/// Allows placing of markers and showing the correct map
class Maps
{
  static List<MapItem> _maplist=[];


  /// Add a [maplist] of maps with asset image filename and two coordinates. One is the pixel position in the image and the other coordinate is its world coordinates
  static init(maplist) async
  {
    _maplist=maplist;
    for (var mapitem in maplist) {

      // Get the width and height of the image so that can calculate image position from world position
      ByteData imageData = await rootBundle.load(mapitem.filename);
      var bytes = Uint8List.view(imageData.buffer);
      var image = im.decodeImage(bytes);
      mapitem.width=image?.width;
      mapitem.height=image?.height;

    }
  }


  // Return the right map given the world coords [worldx] and [worldy] and return the image coordinates for that map
  // First images should be big one for whole terrain and smaller ones after
  // Will first try to find the first smaller map
  static getMapFromWorldcoords(worldx,worldy)
  {
    for (var i=_maplist.length-1; i>=0; i--) {
      var mapitem=_maplist[i];
      var pos=mapitem.getImageCoordsFromWorldCoords(worldx, worldy);
      //  print("posss"+pos.toString());
      if (!(pos[0]<0||pos[0]>=mapitem.width||pos[1]<0||pos[1]>=mapitem.height) )
        return {"imagepos":pos, "map":mapitem};

    }
    return null;
  }
}

/// Class for a single music item including the songs [filename] and [chance] of it being played
class MusicItem
{
  late String filename; // Songs asset path
  late double chance;   // Chance it is played over other songs
  int nexttick=-1;

  MusicItem(filename, {chance})
  {
    this.filename=filename;
    if (chance!=null)
      this.chance=chance;
    else
      this.chance=-1;
  }
}

/// Functions related to playing music
class Musics
{
  static audioplayers.AudioPlayer music = audioplayers.AudioPlayer();

  static List<MusicItem> _musiclist=[];

  // How long before play a song
  static double timebetweensongs=5*60;

  // Randomness on how long before play a song
  static double randomtimebetweensongs=50;

  static bool mute=false;

  /// A list of music as a list of asset sound paths and the chance it is played
  static init(musiclist)
  {
    mute=false;
    _musiclist=musiclist;
    for (var musicitem in _musiclist) {
      if (musicitem.chance==-1)
        musicitem.chance=1.0/_musiclist.length;
    }
    getNext();

  }

  /// [mute] the music
  static setMute(mute)
  {
    if (mute) {
      if (music.state == audioplayers.PlayerState.playing)
        music.stop();
    }
    Musics.mute=mute;
  }

  /// Get next based upon probability
  static getNext()
  {
    var nexttick=System.currentMilliseconds()+timebetweensongs*1000+1000*Math.random()*randomtimebetweensongs;

    double sumprob=0;
    for (int i=0; i<_musiclist.length; i++)
      sumprob+=_musiclist[i].chance;
    var chance=(sumprob*Math.random());
    sumprob=0;

    for (int i=0; i<_musiclist.length; i++) {
      sumprob+=_musiclist[i].chance;
      if (chance<sumprob) {
        _musiclist[i].nexttick=nexttick.toInt();
        return _musiclist[i];
      }
    }
    var pick=Math.randInt(_musiclist.length)-1;
    _musiclist[pick].nexttick=nexttick;
    return _musiclist[pick];

  }

  /// Check if time to play another song
  static update() async
  {
    if (Sound.mute||mute)
      return;
    for (int i=0; i<_musiclist.length; i++) {
      if (_musiclist[i].nexttick!=-1&&System.currentMilliseconds()>=_musiclist[i].nexttick) {
        print("play"+_musiclist[i].filename);
        _musiclist[i].nexttick=-1;

        await music.setSource( audioplayers.AssetSource(_musiclist[i].filename));
        await music.resume();
        getNext();
      }
    }
  }
}

      