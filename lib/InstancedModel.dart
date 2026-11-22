// This code to create instanced models so less draw objects -
// eg rather than draw 1000 columns models individually put them into an instanced model as one draw object
import 'package:three_js/three_js.dart' as THREE;
import 'package:openworld/openworld.dart' as OPENWORLD;

class InstancedModel {
  final List<THREE.InstancedMesh> parts;
  final List<THREE.Matrix4> _partLocalMatrices;
  final THREE.Object3D _dummy = THREE.Object3D();
  final THREE.Matrix4 _combined = THREE.Matrix4.identity();
  final THREE.Vector3 _defaultScale;
  int _nextIndex = 0;
  THREE.Vector3? _centerWorldPos; // set once, after placements — used for distance checks
  double hideDistance = 0.0;     // tune per model; e.g. columns visible from further than a small jug
  String _name='';

  InstancedModel._(this.parts, this._partLocalMatrices, this._defaultScale, this._name);

  /// Whether [node] would actually render, taking into account that
  /// three.js hides descendants of an invisible ancestor even though their
  /// own .visible flag stays true - BaseObject.setVisible(obj, false,
  /// groupname: 'x') only ever sets .visible on the matching named node
  /// itself, relying on exactly this inherited behavior.
  static bool _isEffectivelyVisible(THREE.Object3D node) {
    THREE.Object3D? cur = node;
    while (cur != null) {
      if (cur.visible == false) return false;
      cur = cur.parent;
    }
    return true;
  }

  factory InstancedModel.fromTemplate(THREE.Object3D template, int maxCount, THREE.Scene scene, {name=''}) {
    final parts = <THREE.InstancedMesh>[];
    final localMatrices = <THREE.Matrix4>[];

    template.updateMatrix();                       // capture the group's own position/rotation/scale
    final rootMatrix = template.matrix.clone();

    template.traverse((child) {
      if (child is THREE.Mesh && _isEffectivelyVisible(child)) {
        child.updateMatrix();
        final p = THREE.InstancedMesh(child.geometry, child.material, maxCount);
        p.frustumCulled = false;
        parts.add(p);//THREE.InstancedMesh(child.geometry, child.material, maxCount));
        final local = THREE.Matrix4.identity();
        local.multiply2(rootMatrix, child.matrix);  // root transform × child's own offset
        localMatrices.add(local);
      }
    });
    for (final p in parts) {
      scene.add(p);
    }
   // print("vvvot"+OPENWORLD.Mob.getName(template));
    return InstancedModel._(parts, localMatrices, template.scale.clone(), name);
  }

  /// Call at the start of each hotload pass — rewinds the write position
  /// without touching the meshes already in the scene.
  void reset() => _nextIndex = 0;

  void place( turn,  x,  y,  z,  {scale, int level = 0}) {
    if (_nextIndex>= parts.first.count!) {
      print('InstancedModel: placed more instances than allocated (${parts.first
          .count})'+' '+_name);
      return;
    }
    _dummy.position.setValues(0, 0, 0);
    _dummy.rotation.x=0.0;
    _dummy.rotation.y=0.0;
    _dummy.rotation.z=0.0;
    if (scale!=null)
      _dummy.scale=scale.divide(_defaultScale);
    else {
     // if (OPENWORLD.BaseObject.getName(_dummy)=='donationchest')
      //print("default scale"+_defaultScale.toString());
      _dummy.scale = THREE.Vector3(1.0,1.0,1.0);//_defaultScale.clone();
    }
   // setValues(0, 0, 0);
    OPENWORLD.Space.objTurn(_dummy, turn);
    OPENWORLD.Space.worldToLocalSurfaceObj(_dummy, x, y, z, level: level);
  // OPENWORLD.Space.worldToLocalSurfaceObjHide(_dummy, x, y, z, level: level, cameradist);
    _dummy.updateMatrix();
    for (int i = 0; i < parts.length; i++) {
      _combined.multiply2(_dummy.matrix, _partLocalMatrices[i]);
      parts[i].setMatrixAt(_nextIndex, _combined);
    }
    _nextIndex++;
  }

  void finish() {
    THREE.Vector3? sum;
    for (int i = 0; i < _nextIndex; i++) {
      parts.first.getMatrixAt(i, _combined);
      final pos = THREE.Vector3().setFromMatrixPosition(_combined);
      sum = (sum == null) ? pos : sum.add(pos);
    }
    if (sum != null && _nextIndex > 0) {
         _centerWorldPos = sum..scale(1.0 / _nextIndex); // rough centroid of this batch
//      _centerWorldPos = sum..multiplyScalar(1.0 / _nextIndex); // rough centroid of this batch
    }
    for (final p in parts) {
      p.count = _nextIndex;
      p.instanceMatrix!.needsUpdate = true;
      //p.computeBoundingSphere();
    }
  }

  void updateVisibility(THREE.Vector3 cameraWorldPos) {
    if (_centerWorldPos == null) return;
    final visible =  hideDistance<=0||cameraWorldPos.distanceTo(_centerWorldPos!) <= hideDistance;
    //print("visible"+visible.toString()+" center "+_centerWorldPos.toString()+" "+cameraWorldPos.toString()+" "+hideDistance.toString()+" "+cameraWorldPos.distanceTo(_centerWorldPos!).toString());
    for (final p in parts) {
      p.visible = visible;
    }
  }
 /* void finish() {
    for (final p in parts) {
      p.count = _nextIndex;
      p.instanceMatrix!.needsUpdate = true;
      p.computeBoundingSphere();   // <-- add this: without it, frustum culling uses
      //     the template's local-origin bounds and
      //     silently culls the entire InstancedMesh
    }
  }

  void finish() {
    for (final p in parts) {
      p.count = _nextIndex;
      p.instanceMatrix!.needsUpdate = true;
    }
  }*/
}