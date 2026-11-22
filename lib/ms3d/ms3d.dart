// MilkShape 3D (.ms3d) binary format: parser, skeleton evaluation and
// CPU skinning.
//
// This file has no Flutter or three_js dependencies, so it can be reused by
// any of your games (and unit-tested with plain `dart test`).
//
// Behaviour deliberately mirrors the MudClient3D Java engine
// (MS3DModel.java):
//   * keyframe times are converted from seconds to frames (time * fps);
//   * an *animation* .ms3d supplies the skeleton (bind pose + keys) and the
//     *mesh* .ms3d supplies vertices whose `boneId` indexes that skeleton;
//   * skinning uses the single primary bone per vertex (the engine ignored
//     the optional extra weights), see [Ms3dSkinner.useVertexWeights];
//   * Euler angles are applied with the Quake/Half-Life convention used by
//     MathLib.AngleMatrix / AngleQuaternion.
//
// Two engine quirks are intentionally *not* reproduced:
//   * Java looked up rotation keys using the position key times. Every
//     animation in the fish tank has identical rotation/position times, so
//     using the rotation times gives the same result.
//   * Java's Hermite basis had a typo (h3 = t³+3t²+t instead of t³-2t²+t).
//     The correct curve is used here, which removes a slight jitter from
//     translation keys.

import 'dart:math' as math;
import 'dart:typed_data';

class Ms3dFormatException implements Exception {
  final String message;
  Ms3dFormatException(this.message);
  @override
  String toString() => 'Ms3dFormatException: $message';
}

class Ms3dMaterial {
  String name = '';
  final Float32List ambient = Float32List(4);
  final Float32List diffuse = Float32List(4);
  final Float32List specular = Float32List(4);
  final Float32List emissive = Float32List(4);
  double shininess = 0;
  double transparency = 1;
  int mode = 0;
  String texture = '';
  String alphamap = '';
}

class Ms3dGroup {
  int flags = 0;
  String name = '';
  late Uint16List triangleIndices;

  /// -1 when the group has no material.
  int materialIndex = -1;
}

class Ms3dKeys {
  /// Key times in *frames* (seconds * animationFPS), as the engine stored them.
  final Float32List times;

  /// xyz triples, one per key.
  final Float32List values;
  Ms3dKeys(this.times, this.values);
  int get length => times.length;
}

class Ms3dJoint {
  int flags = 0;
  String name = '';
  String parentName = '';
  int parentIndex = -1;

  /// Bind pose relative to the parent: Euler radians and translation.
  final Float32List rotation = Float32List(3);
  final Float32List position = Float32List(3);
  late Ms3dKeys rotationKeys;
  late Ms3dKeys positionKeys;

  // Hermite tangents for position keys (computed by [Ms3dSkeleton]).
  Float32List? tangentIn;
  Float32List? tangentOut;
}

class Ms3dModel {
  int version = 4;

  // Vertices.
  late Uint8List vertexFlags;
  late Float32List positions; // xyz * numVertices
  late Int8List boneIds; // primary bone, -1 = none
  // Optional extra influences (vertex "extra" chunk). Null if absent.
  Int8List? extraBoneIds; // 3 per vertex
  Uint8List? extraWeights; // 3 per vertex, 0..100

  // Triangles.
  late Uint16List triangleVertexIndices; // 3 per triangle
  late Float32List triangleNormals; // 9 per triangle: corner0 xyz, corner1 xyz, corner2 xyz
  late Float32List triangleS; // 3 per triangle
  late Float32List triangleT; // 3 per triangle
  late Uint8List triangleSmoothingGroup;
  late Uint8List triangleGroupIndex;

  List<Ms3dGroup> groups = [];
  List<Ms3dMaterial> materials = [];

  double animationFPS = 24;
  double currentTime = 0;
  int totalFrames = 0;
  List<Ms3dJoint> joints = [];

  String modelComment = '';
  double jointSize = 0;
  int transparencyMode = 0;
  double alphaRef = 0;

  int get numVertices => boneIds.length;
  int get numTriangles => triangleGroupIndex.length;

  int groupIndexByName(String name) =>
      groups.indexWhere((g) => g.name == name);

  /// Parses an .ms3d file. Throws [Ms3dFormatException] on bad data.
  static Ms3dModel parse(Uint8List bytes) => _Ms3dParser(bytes).parse();
}

class _Ms3dParser {
  final ByteData _d;
  final Uint8List _bytes;
  int _o = 0;
  _Ms3dParser(Uint8List bytes)
      : _bytes = bytes,
        _d = ByteData.sublistView(bytes);

  int get _remaining => _bytes.length - _o;

  void _need(int n, String what) {
    if (_remaining < n) {
      throw Ms3dFormatException('Unexpected end of file reading $what');
    }
  }

  int _u8() => _d.getUint8(_o++);
  int _s8() => _d.getInt8(_o++);
  int _u16() {
    final v = _d.getUint16(_o, Endian.little);
    _o += 2;
    return v;
  }

  int _s32() {
    final v = _d.getInt32(_o, Endian.little);
    _o += 4;
    return v;
  }

  double _f32() {
    final v = _d.getFloat32(_o, Endian.little);
    _o += 4;
    return v;
  }

  String _str(int len) {
    final b = _bytes.sublist(_o, _o + len);
    _o += len;
    final end = b.indexOf(0);
    // Latin-1 is what MilkShape writes; also normalise Windows separators.
    return String.fromCharCodes(end < 0 ? b : b.sublist(0, end))
        .replaceAll('\\', '/');
  }

  Ms3dModel parse() {
    final m = Ms3dModel();
    _need(14, 'header');
    final id = String.fromCharCodes(_bytes.sublist(0, 10));
    if (id != 'MS3D000000') {
      throw Ms3dFormatException('Not an MS3D file (header "$id")');
    }
    _o = 10;
    m.version = _s32();

    // Vertices: flags u8, xyz f32, boneId s8, refCount u8 = 15 bytes.
    _need(2, 'vertex count');
    final nv = _u16();
    _need(nv * 15, 'vertices');
    m.vertexFlags = Uint8List(nv);
    m.positions = Float32List(nv * 3);
    m.boneIds = Int8List(nv);
    for (var i = 0; i < nv; i++) {
      m.vertexFlags[i] = _u8();
      m.positions[i * 3] = _f32();
      m.positions[i * 3 + 1] = _f32();
      m.positions[i * 3 + 2] = _f32();
      m.boneIds[i] = _s8();
      _u8(); // reference count
    }

    // Triangles: 70 bytes each.
    _need(2, 'triangle count');
    final nt = _u16();
    _need(nt * 70, 'triangles');
    m.triangleVertexIndices = Uint16List(nt * 3);
    m.triangleNormals = Float32List(nt * 9);
    m.triangleS = Float32List(nt * 3);
    m.triangleT = Float32List(nt * 3);
    m.triangleSmoothingGroup = Uint8List(nt);
    m.triangleGroupIndex = Uint8List(nt);
    for (var t = 0; t < nt; t++) {
      _u16(); // flags
      for (var k = 0; k < 3; k++) {
        m.triangleVertexIndices[t * 3 + k] = _u16();
      }
      for (var k = 0; k < 9; k++) {
        m.triangleNormals[t * 9 + k] = _f32();
      }
      for (var k = 0; k < 3; k++) {
        m.triangleS[t * 3 + k] = _f32();
      }
      for (var k = 0; k < 3; k++) {
        m.triangleT[t * 3 + k] = _f32();
      }
      m.triangleSmoothingGroup[t] = _u8();
      m.triangleGroupIndex[t] = _u8();
    }

    // Groups.
    _need(2, 'group count');
    final ng = _u16();
    for (var g = 0; g < ng; g++) {
      _need(35, 'group');
      final grp = Ms3dGroup()
        ..flags = _u8()
        ..name = _str(32);
      final n = _u16();
      _need(n * 2 + 1, 'group triangles');
      grp.triangleIndices = Uint16List(n);
      for (var i = 0; i < n; i++) {
        grp.triangleIndices[i] = _u16();
      }
      grp.materialIndex = _s8();
      m.groups.add(grp);
    }

    // Materials: 361 bytes each.
    _need(2, 'material count');
    final nm = _u16();
    _need(nm * 361, 'materials');
    for (var i = 0; i < nm; i++) {
      final mat = Ms3dMaterial()..name = _str(32);
      for (final arr in [mat.ambient, mat.diffuse, mat.specular, mat.emissive]) {
        for (var k = 0; k < 4; k++) {
          arr[k] = _f32();
        }
      }
      mat.shininess = _f32();
      mat.transparency = _f32();
      mat.mode = _u8();
      mat.texture = _str(128);
      mat.alphamap = _str(128);
      m.materials.add(mat);
    }
    for (final g in m.groups) {
      if (g.materialIndex >= nm) g.materialIndex = -1;
    }

    // Animation globals.
    _need(12, 'animation globals');
    m.animationFPS = _f32();
    m.currentTime = _f32();
    m.totalFrames = _s32();
    final fps = m.animationFPS;

    // Joints.
    _need(2, 'joint count');
    final nj = _u16();
    for (var j = 0; j < nj; j++) {
      _need(93, 'joint');
      final joint = Ms3dJoint()
        ..flags = _u8()
        ..name = _str(32)
        ..parentName = _str(32);
      for (var k = 0; k < 3; k++) {
        joint.rotation[k] = _f32();
      }
      for (var k = 0; k < 3; k++) {
        joint.position[k] = _f32();
      }
      final nRot = _u16();
      final nPos = _u16();
      _need((nRot + nPos) * 16, 'joint keyframes');
      joint.rotationKeys = _readKeys(nRot, fps);
      joint.positionKeys = _readKeys(nPos, fps);
      m.joints.add(joint);
    }
    for (final joint in m.joints) {
      joint.parentIndex = joint.parentName.isEmpty
          ? -1
          : m.joints.indexWhere((p) => p.name == joint.parentName);
    }

    // Optional trailing chunks. The engine ignored these; they are read on a
    // best-effort basis and never cause the load to fail.
    try {
      _readExtras(m);
    } catch (_) {}
    return m;
  }

  Ms3dKeys _readKeys(int n, double fps) {
    final times = Float32List(n);
    final values = Float32List(n * 3);
    for (var i = 0; i < n; i++) {
      times[i] = _f32() * fps;
      values[i * 3] = _f32();
      values[i * 3 + 1] = _f32();
      values[i * 3 + 2] = _f32();
    }
    return Ms3dKeys(times, values);
  }

  void _readExtras(Ms3dModel m) {
    // Comments.
    if (_remaining < 4) return;
    final commentVersion = _s32();
    if (commentVersion == 1) {
      for (var block = 0; block < 3; block++) {
        final n = _s32();
        for (var i = 0; i < n; i++) {
          _s32(); // index
          final len = _s32();
          _o += len;
        }
      }
      final hasModelComment = _s32();
      if (hasModelComment > 0) {
        final len = _s32();
        m.modelComment = _str(len);
      }
    } else {
      return;
    }

    // Vertex extras.
    if (_remaining < 4) return;
    final vSub = _s32();
    final nv = m.numVertices;
    if (vSub >= 1 && vSub <= 3) {
      // v1: ids+weights; v2: + uint32 extra; v3 (MilkShape 1.8.5): + 2 extras.
      final per = vSub == 1 ? 6 : (vSub == 2 ? 10 : 14);
      if (_remaining < nv * per) return;
      final ids = Int8List(nv * 3);
      final w = Uint8List(nv * 3);
      for (var i = 0; i < nv; i++) {
        for (var k = 0; k < 3; k++) {
          ids[i * 3 + k] = _s8();
        }
        for (var k = 0; k < 3; k++) {
          w[i * 3 + k] = _u8();
        }
        if (vSub >= 2) _s32(); // extra
        if (vSub >= 3) _s32(); // extra2
      }
      m.extraBoneIds = ids;
      m.extraWeights = w;
    } else {
      return;
    }

    // Joint extras (colours).
    if (_remaining < 4) return;
    final jSub = _s32();
    if (jSub == 1) {
      _o += m.joints.length * 12;
    } else {
      return;
    }

    // Model extras.
    if (_remaining < 16) return;
    final mSub = _s32();
    if (mSub == 1 || mSub == 2) {
      m.jointSize = _f32();
      m.transparencyMode = _s32();
      m.alphaRef = _f32();
    }
  }
}

// ---------------------------------------------------------------------------
// 3x4 row-major matrix helpers (same layout as the Java engine: m[row*4+col]).
// ---------------------------------------------------------------------------

/// MathLib.AngleMatrix: Euler (x=roll, y=pitch, z=yaw) radians -> rotation.
void ms3dAngleMatrix(Float32List a, Float32List m) {
  final sy = math.sin(a[2]), cy = math.cos(a[2]);
  final sp = math.sin(a[1]), cp = math.cos(a[1]);
  final sr = math.sin(a[0]), cr = math.cos(a[0]);
  m[0] = cp * cy;
  m[4] = cp * sy;
  m[8] = -sp;
  m[1] = sr * sp * cy + cr * -sy;
  m[5] = sr * sp * sy + cr * cy;
  m[9] = sr * cp;
  m[2] = cr * sp * cy + -sr * -sy;
  m[6] = cr * sp * sy + -sr * cy;
  m[10] = cr * cp;
  m[3] = 0;
  m[7] = 0;
  m[11] = 0;
}

/// MathLib.AngleQuaternion. Output order x, y, z, w.
void ms3dAngleQuaternion(double ax, double ay, double az, Float64List q) {
  final sy = math.sin(az * 0.5), cy = math.cos(az * 0.5);
  final sp = math.sin(ay * 0.5), cp = math.cos(ay * 0.5);
  final sr = math.sin(ax * 0.5), cr = math.cos(ax * 0.5);
  q[0] = sr * cp * cy - cr * sp * sy;
  q[1] = cr * sp * cy + sr * cp * sy;
  q[2] = cr * cp * sy - sr * sp * cy;
  q[3] = cr * cp * cy + sr * sp * sy;
}

/// MathLib.QuaternionSlerp (note: may negate [q] in place, like the Java).
void ms3dQuaternionSlerp(Float64List p, Float64List q, double t, Float64List qt) {
  var a = 0.0, b = 0.0;
  for (var i = 0; i < 4; i++) {
    a += (p[i] - q[i]) * (p[i] - q[i]);
    b += (p[i] + q[i]) * (p[i] + q[i]);
  }
  if (a > b) {
    for (var i = 0; i < 4; i++) {
      q[i] = -q[i];
    }
  }
  final cosom = p[0] * q[0] + p[1] * q[1] + p[2] * q[2] + p[3] * q[3];
  double sclp, sclq;
  if ((1.0 + cosom) > 0.00000001) {
    if ((1.0 - cosom) > 0.00000001) {
      final omega = math.acos(cosom);
      final sinom = math.sin(omega);
      sclp = math.sin((1.0 - t) * omega) / sinom;
      sclq = math.sin(t * omega) / sinom;
    } else {
      sclp = 1.0 - t;
      sclq = t;
    }
    for (var i = 0; i < 4; i++) {
      qt[i] = sclp * p[i] + sclq * q[i];
    }
  } else {
    qt[0] = -p[1];
    qt[1] = p[0];
    qt[2] = -p[3];
    qt[3] = p[2];
    sclp = math.sin((1.0 - t) * 0.5 * math.pi);
    sclq = math.sin(t * 0.5 * math.pi);
    for (var i = 0; i < 3; i++) {
      qt[i] = sclp * p[i] + sclq * qt[i];
    }
  }
}

/// MathLib.QuaternionMatrix (rotation part only).
void ms3dQuaternionMatrix(Float64List q, Float32List m) {
  m[0] = 1.0 - 2.0 * q[1] * q[1] - 2.0 * q[2] * q[2];
  m[4] = 2.0 * q[0] * q[1] + 2.0 * q[3] * q[2];
  m[8] = 2.0 * q[0] * q[2] - 2.0 * q[3] * q[1];
  m[1] = 2.0 * q[0] * q[1] - 2.0 * q[3] * q[2];
  m[5] = 1.0 - 2.0 * q[0] * q[0] - 2.0 * q[2] * q[2];
  m[9] = 2.0 * q[1] * q[2] + 2.0 * q[3] * q[0];
  m[2] = 2.0 * q[0] * q[2] + 2.0 * q[3] * q[1];
  m[6] = 2.0 * q[1] * q[2] - 2.0 * q[3] * q[0];
  m[10] = 1.0 - 2.0 * q[0] * q[0] - 2.0 * q[1] * q[1];
}

/// MathLib.R_ConcatTransforms: out = in1 * in2 (3x4 affine).
void ms3dConcat(Float32List a, Float32List b, Float32List out) {
  final r = Float32List(12);
  for (var row = 0; row < 3; row++) {
    final a0 = a[row * 4], a1 = a[row * 4 + 1], a2 = a[row * 4 + 2];
    r[row * 4] = a0 * b[0] + a1 * b[4] + a2 * b[8];
    r[row * 4 + 1] = a0 * b[1] + a1 * b[5] + a2 * b[9];
    r[row * 4 + 2] = a0 * b[2] + a1 * b[6] + a2 * b[10];
    r[row * 4 + 3] = a0 * b[3] + a1 * b[7] + a2 * b[11] + a[row * 4 + 3];
  }
  out.setAll(0, r);
}

// ---------------------------------------------------------------------------
// Skeleton: bind pose + per-frame pose from an animation file's joints.
// ---------------------------------------------------------------------------

class Ms3dSkeleton {
  final List<Ms3dJoint> joints;

  /// Frames in the animation (Ms3dModel.totalFrames of the animation file).
  final int totalFrames;

  final List<Float32List> localBind = [];
  final List<Float32List> globalBind = [];
  final List<Float32List> local = [];
  final List<Float32List> global = [];

  double currentFrame = -1;

  /// MS3D keys are relative to the bind pose (local = bind * key). SMD
  /// animations store absolute local transforms, so they set this to true
  /// (local = key).
  final bool absoluteKeys;

  final Float64List _q = Float64List(4);
  final Float64List _q1 = Float64List(4);
  final Float64List _q2 = Float64List(4);
  final Float32List _anim = Float32List(12);

  Ms3dSkeleton(this.joints, this.totalFrames, {this.absoluteKeys = false}) {
    for (var i = 0; i < joints.length; i++) {
      final j = joints[i];
      final lb = Float32List(12);
      ms3dAngleMatrix(j.rotation, lb);
      lb[3] = j.position[0];
      lb[7] = j.position[1];
      lb[11] = j.position[2];
      final gb = Float32List(12);
      // Parents normally precede children; fall back to a lookup otherwise.
      if (j.parentIndex < 0) {
        gb.setAll(0, lb);
      } else if (j.parentIndex < i) {
        ms3dConcat(globalBind[j.parentIndex], lb, gb);
      } else {
        gb.setAll(0, lb); // fixed up below
      }
      localBind.add(lb);
      globalBind.add(gb);
      local.add(Float32List.fromList(lb));
      global.add(Float32List.fromList(gb));
      _setupTangents(j);
    }
    // Handle any joint whose parent was listed after it.
    for (var i = 0; i < joints.length; i++) {
      final p = joints[i].parentIndex;
      if (p > i) _recomputeBind(i);
    }
  }

  factory Ms3dSkeleton.fromModel(Ms3dModel animation) =>
      Ms3dSkeleton(animation.joints, animation.totalFrames);

  void _recomputeBind(int i) {
    final p = joints[i].parentIndex;
    if (p >= 0) {
      if (joints[p].parentIndex > p) _recomputeBind(p);
      ms3dConcat(globalBind[p], localBind[i], globalBind[i]);
      global[i].setAll(0, globalBind[i]);
    }
  }

  static void _setupTangents(Ms3dJoint j) {
    final keys = j.positionKeys;
    final n = keys.length;
    final tin = Float32List(n * 3);
    final tout = Float32List(n * 3);
    if (n > 2) {
      for (var k = 0; k < n; k++) {
        var k0 = k - 1;
        if (k0 < 0) k0 = n - 1;
        final k1 = k;
        var k2 = k + 1;
        if (k2 >= n) k2 = 0;
        final dt1 = keys.times[k1] - keys.times[k0];
        final dt2 = keys.times[k2] - keys.times[k1];
        final dt = dt1 + dt2;
        for (var c = 0; c < 3; c++) {
          final tangent = keys.values[k2 * 3 + c] - keys.values[k0 * 3 + c];
          tin[k1 * 3 + c] = dt == 0 ? 0 : tangent * dt1 / dt;
          tout[k1 * 3 + c] = dt == 0 ? 0 : tangent * dt2 / dt;
        }
      }
    }
    j.tangentIn = tin;
    j.tangentOut = tout;
  }

  /// Equivalent of MS3DModel.setFrame. A negative frame resets to bind pose.
  void setFrame(double frame) {
    if (frame < 0) {
      for (var i = 0; i < joints.length; i++) {
        local[i].setAll(0, localBind[i]);
        global[i].setAll(0, globalBind[i]);
      }
      currentFrame = frame;
      return;
    }
    for (var index = 0; index < joints.length; index++) {
      final joint = joints[index];
      var px = 0.0, py = 0.0, pz = 0.0;

      final pk = joint.positionKeys;
      final np = pk.length;
      if (np > 0) {
        var i1 = -1;
        for (var i = 0; i < np - 1; i++) {
          if (frame >= pk.times[i] && frame < pk.times[i + 1]) {
            i1 = i;
            break;
          }
        }
        if (i1 == -1) {
          final k = frame < pk.times[0] ? 0 : np - 1;
          px = pk.values[k * 3];
          py = pk.values[k * 3 + 1];
          pz = pk.values[k * 3 + 2];
        } else {
          final i2 = i1 + 1;
          final t = (frame - pk.times[i1]) / (pk.times[i2] - pk.times[i1]);
          final t2 = t * t, t3 = t2 * t;
          final h1 = 2.0 * t3 - 3.0 * t2 + 1.0;
          final h2 = -2.0 * t3 + 3.0 * t2;
          final h3 = t3 - 2.0 * t2 + t;
          final h4 = t3 - t2;
          final to = joint.tangentOut!, ti = joint.tangentIn!;
          px = h1 * pk.values[i1 * 3] + h3 * to[i1 * 3] + h2 * pk.values[i2 * 3] + h4 * ti[i2 * 3];
          py = h1 * pk.values[i1 * 3 + 1] + h3 * to[i1 * 3 + 1] + h2 * pk.values[i2 * 3 + 1] + h4 * ti[i2 * 3 + 1];
          pz = h1 * pk.values[i1 * 3 + 2] + h3 * to[i1 * 3 + 2] + h2 * pk.values[i2 * 3 + 2] + h4 * ti[i2 * 3 + 2];
        }
      }

      final rk = joint.rotationKeys;
      final nr = rk.length;
      _q[0] = 0;
      _q[1] = 0;
      _q[2] = 0;
      _q[3] = 1;
      if (nr > 0) {
        var i1 = -1;
        for (var i = 0; i < nr - 1; i++) {
          if (frame >= rk.times[i] && frame < rk.times[i + 1]) {
            i1 = i;
            break;
          }
        }
        if (i1 == -1) {
          final k = frame < rk.times[0] ? 0 : nr - 1;
          ms3dAngleQuaternion(rk.values[k * 3], rk.values[k * 3 + 1], rk.values[k * 3 + 2], _q);
        } else {
          final i2 = i1 + 1;
          final t = (frame - rk.times[i1]) / (rk.times[i2] - rk.times[i1]);
          ms3dAngleQuaternion(rk.values[i1 * 3], rk.values[i1 * 3 + 1], rk.values[i1 * 3 + 2], _q1);
          ms3dAngleQuaternion(rk.values[i2 * 3], rk.values[i2 * 3 + 1], rk.values[i2 * 3 + 2], _q2);
          ms3dQuaternionSlerp(_q1, _q2, t, _q);
        }
      }

      ms3dQuaternionMatrix(_q, _anim);
      _anim[3] = px;
      _anim[7] = py;
      _anim[11] = pz;
      if (absoluteKeys && (nr > 0 || np > 0)) {
        local[index].setAll(0, _anim);
      } else {
        ms3dConcat(localBind[index], _anim, local[index]);
      }
      final p = joint.parentIndex;
      if (p < 0) {
        global[index].setAll(0, local[index]);
      } else {
        ms3dConcat(global[p], local[index], global[index]);
      }
    }
    currentFrame = frame;
  }
}

// ---------------------------------------------------------------------------
// Skinning: deforms a mesh model's vertices by a skeleton's current pose.
// ---------------------------------------------------------------------------

class Ms3dSkinner {
  final Ms3dModel mesh;

  /// Skinned vertex positions (xyz * numVertices). Starts at the bind pose.
  late final Float32List skinned;

  /// The Java engine skinned with the primary bone only. Set to true to blend
  /// the optional MilkShape 1.8 extra weights (up to 4 bones per vertex).
  bool useVertexWeights;

  Ms3dSkinner(this.mesh, {this.useVertexWeights = false}) {
    skinned = Float32List.fromList(mesh.positions);
  }

  /// Equivalent of MS3DModel.transformVertices.
  void apply(Ms3dSkeleton? skeleton) {
    final src = mesh.positions;
    final n = mesh.numVertices;
    if (skeleton == null || skeleton.currentFrame < 0) {
      skinned.setAll(0, src);
      return;
    }
    final nj = skeleton.joints.length;
    final ids = mesh.extraBoneIds, ws = mesh.extraWeights;
    final blend = useVertexWeights && ids != null && ws != null;
    for (var i = 0; i < n; i++) {
      final b = mesh.boneIds[i];
      final x = src[i * 3], y = src[i * 3 + 1], z = src[i * 3 + 2];
      if (b < 0 || b >= nj) {
        skinned[i * 3] = x;
        skinned[i * 3 + 1] = y;
        skinned[i * 3 + 2] = z;
        continue;
      }
      if (!blend || (ws[i * 3] == 0 && ws[i * 3 + 1] == 0 && ws[i * 3 + 2] == 0)) {
        _transform(skeleton, b, x, y, z, i, 1.0, false);
      } else {
        final w0 = ws[i * 3], w1 = ws[i * 3 + 1], w2 = ws[i * 3 + 2];
        final bones = [b, ids[i * 3], ids[i * 3 + 1], ids[i * 3 + 2]];
        final weights = [w0, w1, w2, 100 - w0 - w1 - w2];
        skinned[i * 3] = 0;
        skinned[i * 3 + 1] = 0;
        skinned[i * 3 + 2] = 0;
        for (var k = 0; k < 4; k++) {
          if (weights[k] <= 0 || bones[k] < 0 || bones[k] >= nj) continue;
          _transform(skeleton, bones[k], x, y, z, i, weights[k] / 100.0, true);
        }
      }
    }
  }

  void _transform(Ms3dSkeleton s, int bone, double x, double y, double z,
      int i, double w, bool accumulate) {
    final gs = s.globalBind[bone];
    final g = s.global[bone];
    // Inverse bind (rotation is orthonormal, so transpose), then pose.
    final t0 = x - gs[3], t1 = y - gs[7], t2 = z - gs[11];
    final a = t0 * gs[0] + t1 * gs[4] + t2 * gs[8];
    final b = t0 * gs[1] + t1 * gs[5] + t2 * gs[9];
    final c = t0 * gs[2] + t1 * gs[6] + t2 * gs[10];
    final ox = a * g[0] + b * g[1] + c * g[2] + g[3];
    final oy = a * g[4] + b * g[5] + c * g[6] + g[7];
    final oz = a * g[8] + b * g[9] + c * g[10] + g[11];
    if (accumulate) {
      skinned[i * 3] += ox * w;
      skinned[i * 3 + 1] += oy * w;
      skinned[i * 3 + 2] += oz * w;
    } else {
      skinned[i * 3] = ox;
      skinned[i * 3 + 1] = oy;
      skinned[i * 3 + 2] = oz;
    }
  }
}
