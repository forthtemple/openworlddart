// Valve StudioMDL (.smd) text format loader.
//
// An SMD file is either a *reference* (skeleton + triangles) or an
// *animation* (skeleton frames only). Both are converted into the same
// structures used for MilkShape files ([Ms3dModel] / [Ms3dSkeleton]), so
// SMD meshes and animations go through exactly the same skinning and
// rendering path as .ms3d ones, and can be mixed (e.g. an SMD animation on an
// MS3D mesh, provided the bone order matches).
//
// Notes
//  * Rotations are XYZ radians in the same Half-Life Euler convention MS3D
//    uses, so [ms3dAngleMatrix] applies directly.
//  * SMD animation frames hold absolute local transforms (not deltas from the
//    bind pose), so skeletons built from them use `absoluteKeys: true`.
//  * Many exporters (Blender included) write Z-up data. The SMDs shipped with
//    the fish tank are Z-up versions of the .ms3d files. Use
//    [SmdFile.isLikelyZUp] or your own knowledge and rotate the rendered
//    object by -90° about X to stand it up (see SceneModel.zUpToYUp).
//  * Vertex "links" (multi-bone weights) are read; the parent bone is used as
//    the primary bone, and the strongest extra links fill the MS3D-style
//    extra weight slots.

import 'dart:convert';
import 'dart:typed_data';

import 'ms3d.dart';

class SmdNode {
  final int id;
  final String name;
  final int parent;
  SmdNode(this.id, this.name, this.parent);
}

class SmdVertex {
  int bone = -1;
  double x = 0, y = 0, z = 0;
  double nx = 0, ny = 0, nz = 0;
  double u = 0, v = 0;
  List<int> linkBones = const [];
  List<double> linkWeights = const [];
}

class SmdTriangle {
  String material;
  final List<SmdVertex> v;
  SmdTriangle(this.material, this.v);
}

class SmdFile {
  final List<SmdNode> nodes = [];

  /// frames[f][bone] = [px, py, pz, rx, ry, rz]; bones absent from a frame
  /// inherit the previous frame's value.
  final List<List<List<double>?>> frames = [];
  final List<int> frameTimes = [];
  final List<SmdTriangle> triangles = [];

  bool get isReference => triangles.isNotEmpty;

  static SmdFile parse(String text) {
    final smd = SmdFile();
    final lines = const LineSplitter().convert(text);
    var i = 0;
    String? section;
    List<List<double>?>? frame;
    while (i < lines.length) {
      final line = lines[i].trim();
      i++;
      if (line.isEmpty || line.startsWith('//')) continue;
      if (section == null) {
        if (line.startsWith('version')) continue;
        if (line == 'nodes' || line == 'skeleton' || line == 'triangles' ||
            line == 'vertexanimation') {
          section = line;
          frame = null;
        }
        continue;
      }
      if (line == 'end') {
        section = null;
        continue;
      }
      switch (section) {
        case 'nodes':
          final m = RegExp(r'^(-?\d+)\s+"([^"]*)"\s+(-?\d+)').firstMatch(line);
          if (m != null) {
            smd.nodes.add(SmdNode(int.parse(m.group(1)!), m.group(2)!,
                int.parse(m.group(3)!)));
          }
          break;
        case 'skeleton':
          if (line.startsWith('time')) {
            final t = int.parse(line.split(RegExp(r'\s+'))[1]);
            frame = List<List<double>?>.filled(smd.nodes.length, null);
            if (smd.frames.isNotEmpty) {
              final prev = smd.frames.last;
              for (var b = 0; b < prev.length; b++) {
                frame[b] = prev[b];
              }
            }
            smd.frames.add(frame);
            smd.frameTimes.add(t);
          } else if (frame != null) {
            final p = line.split(RegExp(r'\s+'));
            final bone = int.parse(p[0]);
            if (bone >= 0 && bone < frame.length) {
              frame[bone] = [for (var k = 1; k <= 6; k++) double.parse(p[k])];
            }
          }
          break;
        case 'triangles':
          // material line followed by three vertex lines
          final material = line;
          final verts = <SmdVertex>[];
          for (var k = 0; k < 3 && i < lines.length; k++) {
            verts.add(_parseVertex(lines[i].trim()));
            i++;
          }
          if (verts.length == 3) smd.triangles.add(SmdTriangle(material, verts));
          break;
        default:
          break;
      }
    }
    return smd;
  }

  static SmdVertex _parseVertex(String line) {
    final p = line.split(RegExp(r'\s+'));
    final v = SmdVertex()
      ..bone = int.parse(p[0])
      ..x = double.parse(p[1])
      ..y = double.parse(p[2])
      ..z = double.parse(p[3])
      ..nx = double.parse(p[4])
      ..ny = double.parse(p[5])
      ..nz = double.parse(p[6])
      ..u = double.parse(p[7])
      ..v = double.parse(p[8]);
    if (p.length > 9) {
      final n = int.parse(p[9]);
      final bones = <int>[];
      final weights = <double>[];
      for (var k = 0; k < n && 10 + k * 2 + 1 < p.length; k++) {
        bones.add(int.parse(p[10 + k * 2]));
        weights.add(double.parse(p[11 + k * 2]));
      }
      v.linkBones = bones;
      v.linkWeights = weights;
    }
    return v;
  }

  /// Heuristic: in Z-up files the tallest extent of the mesh is usually Z
  /// and the root bone is rotated about X by ~90°.
  bool get isLikelyZUp {
    if (frames.isEmpty || frames.first.isEmpty) return false;
    final root = frames.first.first;
    if (root == null) return false;
    return (root[3].abs() - 1.5708).abs() < 0.01;
  }

  /// The reference skeleton (first frame) as MS3D-style joints whose
  /// bind pose is frame 0 and whose keys are every frame (absolute).
  List<Ms3dJoint> toJoints() {
    final joints = <Ms3dJoint>[];
    final nFrames = frames.length;
    for (var b = 0; b < nodes.length; b++) {
      final node = nodes[b];
      final j = Ms3dJoint()
        ..name = node.name
        ..parentIndex = node.parent
        ..parentName = node.parent >= 0 && node.parent < nodes.length
            ? nodes[node.parent].name
            : '';
      final f0 = nFrames > 0 ? frames[0][b] : null;
      if (f0 != null) {
        j.position.setAll(0, [f0[0], f0[1], f0[2]]);
        j.rotation.setAll(0, [f0[3], f0[4], f0[5]]);
      }
      final times = Float32List(nFrames);
      final rot = Float32List(nFrames * 3);
      final pos = Float32List(nFrames * 3);
      for (var f = 0; f < nFrames; f++) {
        times[f] = frameTimes[f].toDouble();
        final v = frames[f][b] ?? f0 ?? const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
        pos[f * 3] = v[0];
        pos[f * 3 + 1] = v[1];
        pos[f * 3 + 2] = v[2];
        rot[f * 3] = v[3];
        rot[f * 3 + 1] = v[4];
        rot[f * 3 + 2] = v[5];
      }
      j.rotationKeys = Ms3dKeys(times, rot);
      j.positionKeys = Ms3dKeys(times, pos);
      joints.add(j);
    }
    return joints;
  }

  /// Skeleton for playing this file as an animation.
  Ms3dSkeleton toSkeleton() => Ms3dSkeleton(toJoints(),
      frameTimes.isEmpty ? 0 : frameTimes.last + 1,
      absoluteKeys: true);

  /// Converts the triangles into an [Ms3dModel] (one group per material,
  /// material names = SMD texture names). SMD stores one vertex per triangle
  /// corner, so vertices are not shared.
  Ms3dModel toMesh() {
    final m = Ms3dModel();
    final nt = triangles.length;
    final nv = nt * 3;
    m.vertexFlags = Uint8List(nv);
    m.positions = Float32List(nv * 3);
    m.boneIds = Int8List(nv);
    final extraIds = Int8List(nv * 3)..fillRange(0, nv * 3, -1);
    final extraW = Uint8List(nv * 3);
    var anyLinks = false;
    m.triangleVertexIndices = Uint16List(nt * 3);
    m.triangleNormals = Float32List(nt * 9);
    m.triangleS = Float32List(nt * 3);
    m.triangleT = Float32List(nt * 3);
    m.triangleSmoothingGroup = Uint8List(nt);
    m.triangleGroupIndex = Uint8List(nt);

    final groupOf = <String, int>{};
    final groupTris = <List<int>>[];
    for (var t = 0; t < nt; t++) {
      final tri = triangles[t];
      final g = groupOf.putIfAbsent(tri.material, () {
        groupTris.add(<int>[]);
        m.materials.add(Ms3dMaterial()
          ..name = tri.material
          ..texture = tri.material);
        return groupTris.length - 1;
      });
      groupTris[g].add(t);
      m.triangleGroupIndex[t] = g;
      for (var k = 0; k < 3; k++) {
        final v = tri.v[k];
        final vi = t * 3 + k;
        m.positions[vi * 3] = v.x;
        m.positions[vi * 3 + 1] = v.y;
        m.positions[vi * 3 + 2] = v.z;
        m.boneIds[vi] = v.bone.clamp(-1, 127);
        if (v.linkBones.isNotEmpty) {
          // Primary bone = strongest link; up to three more as extras.
          final order = List<int>.generate(v.linkBones.length, (i) => i)
            ..sort((a, b) => v.linkWeights[b].compareTo(v.linkWeights[a]));
          m.boneIds[vi] = v.linkBones[order[0]].clamp(-1, 127);
          if (order.length > 1) {
            // MS3D convention: weights[0..2] belong to the primary bone and
            // extra bones 1..2; the 4th (extra bone 3) gets 100 - sum.
            anyLinks = true;
            final used = order.take(4).toList();
            final total = used.fold<double>(0, (s, i) => s + v.linkWeights[i]);
            for (var e = 0; e < 3; e++) {
              extraIds[vi * 3 + e] = e + 1 < used.length
                  ? v.linkBones[used[e + 1]].clamp(-1, 127)
                  : -1;
              extraW[vi * 3 + e] = e < used.length
                  ? (100 * v.linkWeights[used[e]] / (total == 0 ? 1 : total))
                      .round()
                      .clamp(0, 100)
                  : 0;
            }
          }
        }
        m.triangleVertexIndices[t * 3 + k] = vi;
        m.triangleNormals[t * 9 + k * 3] = v.nx;
        m.triangleNormals[t * 9 + k * 3 + 1] = v.ny;
        m.triangleNormals[t * 9 + k * 3 + 2] = v.nz;
        m.triangleS[t * 3 + k] = v.u;
        // SMD V is bottom-up; MS3D T is top-down.
        m.triangleT[t * 3 + k] = 1.0 - v.v;
      }
    }
    for (var g = 0; g < groupTris.length; g++) {
      m.groups.add(Ms3dGroup()
        ..name = m.materials[g].name
        ..materialIndex = g
        ..triangleIndices = Uint16List.fromList(groupTris[g]));
    }
    if (anyLinks) {
      m.extraBoneIds = extraIds;
      m.extraWeights = extraW;
    }
    m.joints = toJoints();
    m.totalFrames = frameTimes.isEmpty ? 0 : frameTimes.last + 1;
    m.animationFPS = 30;
    return m;
  }
}
