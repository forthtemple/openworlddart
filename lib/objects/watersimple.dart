import 'package:openworld/updateable.dart';
import 'package:openworld/three_dart/three_dart.dart' as THREE;
import 'package:openworld/openworld.dart' as OPENWORLD;
import 'dart:math' as math;

class WaterSimple extends Updateable
{
  static List _waterVertData=[];  // all use this
  static late THREE.PlaneGeometry g;

  static initVertexData({widthsegments:5, heightsegments:5})
  {
    g = new THREE.PlaneGeometry(1, 1, widthsegments, heightsegments);
    g.rotateX(-math.pi * 0.5);
    _waterVertData = [];
    var v3 = new THREE.Vector3(); // for re-use
    for (var i = 0; i < g.attributes['position'].count; i++) {
      v3.fromBufferAttribute(g.attributes['position'], i);
      _waterVertData.add({
        'initH': v3.y,
        'amplitude': THREE.MathUtils.randFloatSpread(2)/100,
        'phase': THREE.MathUtils.randFloat(0, math.pi)
      });
    }

  }

  createWater()
  {
    var m = new THREE.MeshStandardMaterial({
      //'color': THREE.Color(0x0000ff),
      //  'color': 0x996633,
      // 'envMap': envMap, // optional environment map
      // 'specular': 0x050505,
      // 'shininess': 100


    });
    m.emissive = THREE.Color(
        0x2e3f50);//000000);//3d4848);//4f5b5b);//21170e);//406695);//64777d);//);//665600);
    m.metalness = 1.0;
    m.roughness = 0.5;

    m.opacity=0.9;
    m.transparent=true;
    return new THREE.Mesh(g, m);
  }

  @override
  // only need to do once as all share
  update(frameTime, elapsedTime)
  {
    for (var idx=0; idx<_waterVertData.length; idx++) {
      var vd=_waterVertData[idx];
      ///  _waterVertData.forEach((vd, idx) => {
      var y = vd['initH']+ math.sin( elapsedTime +
          vd['phase']) * vd['amplitude'];
      g.attributes['position'].setY(idx, y);
      //print("hrrr");

      // });
    }
    g.attributes['position'].needsUpdate = true;
    g.computeVertexNormals();
  }
}