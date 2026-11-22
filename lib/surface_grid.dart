// For consistency this should be part of openworld.dart rather than seperate as it is only used in openworld.dart
// It helps make terrain intersections faster
// Fast "straight down" terrain intersection.
//
// Every terrain query in OpenWorld casts a ray straight down (direction
// 0,-1,0). A three_js Mesh.raycast tests the ray against EVERY triangle of
// the mesh, which is slow on a big terrain. Because the ray is always
// vertical, the problem becomes 2D: which triangles cover this (x, z) point?
//
// SurfaceGrid answers that by bucketing every surface triangle into a
// uniform 2D grid over x/z (by the triangle's x/z bounding box). A query
// only looks at the handful of triangles in one grid cell, does a 2D
// point-in-triangle test, and interpolates the height. The result is exact
// (no 0.02 grid stepping) and is returned as a normal THREE.Intersection
// with the same fields Mesh.raycast fills in: distance, point, object,
// face (a, b, c, local normal, materialIndex), faceIndex, barycoord, uv,
// uv1 and normal.
//
// It follows the same rules as the three_js raycaster so results match:
//  - only the objects passed in are tested (not their children), and only
//    Meshes with a material, whose layers match the raycaster's layers
//  - material.side is respected (FrontSide only hits faces facing up,
//    BackSide only faces facing down, DoubleSide both)
//  - GroupMaterial + geometry.groups and geometry.drawRange are respected
//  - the closest hit below the ray origin wins (i.e. the highest surface
//    below the origin)
//
// Assumes the surface meshes don't move after the grid is built (true for
// terrain). Morph targets / skinning on surface meshes are ignored.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:three_js/three_js.dart' as THREE;

class SurfaceGrid {
  // Per mesh
  final List<THREE.Mesh> _meshes = [];
  final List<THREE.Matrix4> _matrices = []; // snapshot of matrixWorld
  final List<THREE.Vector3> _localDown = []; // (0,-1,0) in mesh local space

  // Per triangle (parallel arrays): mesh index, first index-buffer (or
  // vertex) position j of the triangle, and material index (-1 = none).
  late Int32List _triMesh;
  late Int32List _triStart;
  late Int32List _triMatIndex;

  // Grid in compressed form: triangles of cell k are
  // _cellTris[_cellStart[k] .. _cellStart[k+1]-1]
  late Int32List _cellStart;
  late Int32List _cellTris;

  double _minX = 0, _minZ = 0, _cellSize = 1;
  int _nx = 0, _nz = 0;
  int triangleCount = 0;
  bool get isEmpty => triangleCount == 0;

  // x/z extent covered by the grid
  double get minX => _minX;
  double get minZ => _minZ;
  double get maxX => _minX + _nx * _cellSize;
  double get maxZ => _minZ + _nz * _cellSize;

  // Scratch vectors so queries allocate as little as possible.
  final _a = THREE.Vector3(), _b = THREE.Vector3(), _c = THREE.Vector3();

  // Keeps memory bounded: at most this many cells.
  static const int _maxCells = 4000000;

  SurfaceGrid.build(List<THREE.Object3D> objects, THREE.Layers raycasterLayers) {
    final sw = Stopwatch()..start();

    // ---- Pass 1: collect hittable triangles and their x/z bounds ----------
    final triMesh = <int>[];
    final triStart = <int>[];
    final triMat = <int>[];
    final bounds = <double>[]; // minX, maxX, minZ, maxZ per triangle
    double sumExtent = 0;

    for (final obj in objects) {
      if (obj is! THREE.Mesh) continue;
      if (!obj.layers.test(raycasterLayers)) continue;
      final material = obj.material;
      final geometry = obj.geometry;
      if (material == null || geometry == null) continue;
      final position = geometry.attributes['position'];
      if (position == null) continue;

      final matrix = obj.matrixWorld.clone();
      // A mirrored transform (negative determinant) flips which side
      // of a triangle faces the ray, same as it does in Mesh.raycast.
      final detSign = matrix.determinant() < 0 ? -1.0 : 1.0;
      final inverse = obj.matrixWorld.clone()..invert();
      final localDown = THREE.Vector3(0, -1, 0).transformDirection(inverse);

      final meshIndex = _meshes.length;
      _meshes.add(obj);
      _matrices.add(matrix);
      _localDown.add(localDown);

      final index = geometry.index;
      final int vertexCount = index != null ? index.count : position.count as int;
      final drawStart = geometry.drawRange['start'] ?? 0;
      final drawCount = geometry.drawRange['count'] ?? vertexCount;
      // drawRange count defaults to the max int, so avoid overflow.
      final drawEnd = drawCount >= vertexCount ? vertexCount : math.min(vertexCount, drawStart + drawCount);

      void addRange(int start, int end, THREE.Material m, int matIndex) {
        final side = m.side;
        for (int j = start; j + 2 < end; j += 3) {
          final ia = index != null ? index.getX(j)!.toInt() : j;
          final ib = index != null ? index.getX(j + 1)!.toInt() : j + 1;
          final ic = index != null ? index.getX(j + 2)!.toInt() : j + 2;
          _a.fromBuffer(position, ia).applyMatrix4(matrix);
          _b.fromBuffer(position, ib).applyMatrix4(matrix);
          _c.fromBuffer(position, ic).applyMatrix4(matrix);

          // y component of the world-space face normal (b-a) x (c-a).
          final ny = (_b.z - _a.z) * (_c.x - _a.x) - (_b.x - _a.x) * (_c.z - _a.z);
          if (ny == 0) continue; // vertical or degenerate: a vertical ray can't hit it
          final facing = ny * detSign; // > 0: front face points up
          if (side == THREE.FrontSide && facing <= 0) continue;
          if (side == THREE.BackSide && facing >= 0) continue;

          final minX = math.min(_a.x, math.min(_b.x, _c.x));
          final maxX = math.max(_a.x, math.max(_b.x, _c.x));
          final minZ = math.min(_a.z, math.min(_b.z, _c.z));
          final maxZ = math.max(_a.z, math.max(_b.z, _c.z));
          bounds..add(minX)..add(maxX)..add(minZ)..add(maxZ);
          sumExtent += math.max(maxX - minX, maxZ - minZ);
          triMesh.add(meshIndex);
          triStart.add(j);
          triMat.add(matIndex);
        }
      }

      if (material is THREE.GroupMaterial) {
        for (final group in geometry.groups) {
          final int mi = group['materialIndex'] ?? 0;
          if (mi < 0 || mi >= material.children.length) continue;
          final int gStart = group['start'] ?? 0;
          final int gCount = group['count'] ?? 0;
          final start = math.max(gStart, drawStart);
          final end = math.min(drawEnd, gStart + gCount);
          addRange(start, end, material.children[mi], mi);
        }
      } else {
        final start = math.max(0, drawStart);
        final end = drawEnd;
        addRange(start, end, material, -1);
      }
    }

    triangleCount = triMesh.length;
    _triMesh = Int32List.fromList(triMesh);
    _triStart = Int32List.fromList(triStart);
    _triMatIndex = Int32List.fromList(triMat);

    if (triangleCount == 0) {
      _cellStart = Int32List(1);
      _cellTris = Int32List(0);
      return;
    }

    // ---- Choose the grid ----------------------------------------------
    double minX = double.infinity, maxX = -double.infinity;
    double minZ = double.infinity, maxZ = -double.infinity;
    for (int t = 0; t < triangleCount; t++) {
      minX = math.min(minX, bounds[t * 4]);
      maxX = math.max(maxX, bounds[t * 4 + 1]);
      minZ = math.min(minZ, bounds[t * 4 + 2]);
      maxZ = math.max(maxZ, bounds[t * 4 + 3]);
    }
    // Cells about twice the size of an average triangle keep each cell to
    // a handful of triangles without each triangle spanning many cells.
    double cell = math.max(sumExtent / triangleCount * 2.0, 1e-4);
    int nx, nz;
    while (true) {
      nx = math.max(1, ((maxX - minX) / cell).floor() + 1);
      nz = math.max(1, ((maxZ - minZ) / cell).floor() + 1);
      if (nx * nz <= _maxCells) break;
      cell *= 1.5;
    }
    _minX = minX;
    _minZ = minZ;
    _cellSize = cell;
    _nx = nx;
    _nz = nz;

    // ---- Pass 2: count triangles per cell --------------------------------
    final counts = Int32List(nx * nz + 1);
    for (int t = 0; t < triangleCount; t++) {
      final x0 = _cellX(bounds[t * 4]), x1 = _cellX(bounds[t * 4 + 1]);
      final z0 = _cellZ(bounds[t * 4 + 2]), z1 = _cellZ(bounds[t * 4 + 3]);
      for (int cz = z0; cz <= z1; cz++) {
        for (int cx = x0; cx <= x1; cx++) {
          counts[cz * nx + cx + 1]++;
        }
      }
    }
    for (int k = 1; k < counts.length; k++) {
      counts[k] += counts[k - 1];
    }
    _cellStart = counts;

    // ---- Pass 3: fill ----------------------------------------------------
    _cellTris = Int32List(counts[nx * nz]);
    final fill = Int32List.fromList(counts.sublist(0, nx * nz));
    for (int t = 0; t < triangleCount; t++) {
      final x0 = _cellX(bounds[t * 4]), x1 = _cellX(bounds[t * 4 + 1]);
      final z0 = _cellZ(bounds[t * 4 + 2]), z1 = _cellZ(bounds[t * 4 + 3]);
      for (int cz = z0; cz <= z1; cz++) {
        for (int cx = x0; cx <= x1; cx++) {
          _cellTris[fill[cz * nx + cx]++] = t;
        }
      }
    }

    sw.stop();
    print('SurfaceGrid: $triangleCount triangles, ${nx}x$nz cells of '
        '${cell.toStringAsFixed(3)}, ${_cellTris.length} entries, '
        'built in ${sw.elapsedMilliseconds}ms');
  }

  int _cellX(double x) => ((x - _minX) / _cellSize).floor().clamp(0, _nx - 1);
  int _cellZ(double z) => ((z - _minZ) / _cellSize).floor().clamp(0, _nz - 1);

  /// Same result as casting a ray from (x, originY, z) straight down and
  /// taking the first hit, or null if nothing is below.
  THREE.Intersection? intersectDown(double x, double originY, double z) {
    if (triangleCount == 0) return null;
    final fx = (x - _minX) / _cellSize;
    final fz = (z - _minZ) / _cellSize;
    if (fx < 0 || fz < 0) return null;
    final cx = fx.floor(), cz = fz.floor();
    if (cx >= _nx || cz >= _nz) return null;
    final cellIndex = cz * _nx + cx;

    int bestTri = -1;
    double bestY = -double.infinity;
    double bestWa = 0, bestWb = 0, bestWc = 0;

    for (int k = _cellStart[cellIndex], end = _cellStart[cellIndex + 1]; k < end; k++) {
      final t = _cellTris[k];
      _loadWorldTriangle(t);

      // 2D barycentric weights of (x, z) in triangle a, b, c.
      final d = (_b.z - _c.z) * (_a.x - _c.x) + (_c.x - _b.x) * (_a.z - _c.z);
      if (d == 0) continue;
      final wa = ((_b.z - _c.z) * (x - _c.x) + (_c.x - _b.x) * (z - _c.z)) / d;
      final wb = ((_c.z - _a.z) * (x - _c.x) + (_a.x - _c.x) * (z - _c.z)) / d;
      final wc = 1.0 - wa - wb;
      // Small tolerance so points exactly on shared edges never fall
      // through a crack due to rounding.
      const eps = -1e-9;
      if (wa < eps || wb < eps || wc < eps) continue;

      final y = wa * _a.y + wb * _b.y + wc * _c.y;
      if (y > originY) continue; // above the ray origin: the ray can't hit it
      if (y > bestY) {
        bestY = y;
        bestTri = t;
        bestWa = wa;
        bestWb = wb;
        bestWc = wc;
      }
    }
    if (bestTri < 0) return null;
    return _makeIntersection(bestTri, x, bestY, z, originY - bestY, bestWa, bestWb, bestWc);
  }

  void _vertexIndices(int t, List<int> out) {
    final mesh = _meshes[_triMesh[t]];
    final index = mesh.geometry!.index;
    final j = _triStart[t];
    if (index != null) {
      out[0] = index.getX(j)!.toInt();
      out[1] = index.getX(j + 1)!.toInt();
      out[2] = index.getX(j + 2)!.toInt();
    } else {
      out[0] = j;
      out[1] = j + 1;
      out[2] = j + 2;
    }
  }

  final List<int> _abc = [0, 0, 0];

  void _loadWorldTriangle(int t) {
    final m = _triMesh[t];
    final position = _meshes[m].geometry!.attributes['position'];
    final matrix = _matrices[m];
    _vertexIndices(t, _abc);
    _a.fromBuffer(position, _abc[0]).applyMatrix4(matrix);
    _b.fromBuffer(position, _abc[1]).applyMatrix4(matrix);
    _c.fromBuffer(position, _abc[2]).applyMatrix4(matrix);
  }

  THREE.Intersection _makeIntersection(int t, double x, double y, double z,
      double distance, double wa, double wb, double wc) {
    final m = _triMesh[t];
    final mesh = _meshes[m];
    final geometry = mesh.geometry!;
    _vertexIndices(t, _abc);
    final ia = _abc[0], ib = _abc[1], ic = _abc[2];

    // Face normal in LOCAL space, exactly like Mesh.raycast.
    final position = geometry.attributes['position'];
    final la = THREE.Vector3().fromBuffer(position, ia);
    final lb = THREE.Vector3().fromBuffer(position, ib);
    final lc = THREE.Vector3().fromBuffer(position, ic);
    final faceNormal = THREE.Vector3()
        .sub2(lc, lb)
        .cross(THREE.Vector3().sub2(la, lb));
    final len = faceNormal.length;
    if (len > 0) faceNormal.scale(1 / len);

    final matIndex = _triMatIndex[t];
    final intersection = THREE.Intersection(
      distance: distance,
      point: THREE.Vector3(x, y, z),
      object: mesh,
      face: THREE.Face(ia, ib, ic, faceNormal, matIndex < 0 ? 0 : matIndex),
      faceIndex: (_triStart[t] / 3).floor(),
      barycoord: THREE.Vector3(wa, wb, wc),
    );

    final uv = geometry.attributes['uv'];
    if (uv != null) intersection.uv = _interp2(uv, ia, ib, ic, wa, wb, wc);
    final uv1 = geometry.attributes['uv1'];
    if (uv1 != null) intersection.uv1 = _interp2(uv1, ia, ib, ic, wa, wb, wc);
    final normal = geometry.attributes['normal'];
    if (normal != null) {
      final n = THREE.Vector3(
        _get(normal, ia, 0) * wa + _get(normal, ib, 0) * wb + _get(normal, ic, 0) * wc,
        _get(normal, ia, 1) * wa + _get(normal, ib, 1) * wb + _get(normal, ic, 1) * wc,
        _get(normal, ia, 2) * wa + _get(normal, ib, 2) * wb + _get(normal, ic, 2) * wc,
      );
      if (n.dot(_localDown[m]) > 0) n.scale(-1);
      intersection.normal = n;
    }
    return intersection;
  }

  static double _get(dynamic attr, int i, int comp) {
    final num? v = comp == 0 ? attr.getX(i) : comp == 1 ? attr.getY(i) : attr.getZ(i);
    return (v ?? 0).toDouble();
  }

  static THREE.Vector2 _interp2(dynamic attr, int a, int b, int c, double wa, double wb, double wc) {
    return THREE.Vector2(
      _get(attr, a, 0) * wa + _get(attr, b, 0) * wb + _get(attr, c, 0) * wc,
      _get(attr, a, 1) * wa + _get(attr, b, 1) * wb + _get(attr, c, 1) * wc,
    );
  }
}
