// Terrain height / walkability queries on an MS3D model, as used by
// MudClient3D's Space.getCollisionHeight + MS3DModel.getCollision.
//
// * "level" groups are the walkable surfaces. In config.xml
//   <SPACE levels="0:Monument"> means level 0 = groups 0..index("Monument").
// * "obstacle" groups (<SPACE obstacle="obstacle">) block movement: a point
//   inside an obstacle triangle (in the XZ plane) is not walkable.
// * Heights are returned in *model* units (multiply by rawscale for world).
//
// Coordinates here are model-space X and Z (MUD x = modelX, MUD y = -modelZ
// for a terrain placed at the origin with scale 1).

import 'dart:math' as math;
import 'dart:typed_data';

import 'ms3d.dart';

class Ms3dTerrain {
  final Ms3dModel model;

  /// Walkable triangles per level (level number -> triangle indices), in the
  /// engine's search order (last group first, last triangle first).
  final Map<int, Uint32List> _levelTris = {};
  late final Uint32List _obstacleTris;

  // Uniform XZ grid over all candidate triangles.
  late final double _minX, _minZ, _cell;
  late final int _nx, _nz;
  // Per cell, triangles in engine search order: one list per level + obstacles.
  final Map<int, List<List<int>>> _levelCells = {};
  late final List<List<int>> _obstacleCells;

  Ms3dTerrain(this.model, {Map<int, List<int>> levelGroups = const {}, List<int> obstacleGroups = const [], double cellSize = 2.0}) {
    final all = <int>{};
    if (levelGroups.isEmpty) {
      _levelTris[0] = _trisOf(List.generate(model.groups.length, (i) => i));
    } else {
      levelGroups.forEach((level, groups) => _levelTris[level] = _trisOf(groups));
    }
    _obstacleTris = _trisOf(obstacleGroups);
    for (final l in _levelTris.values) {
      all.addAll(l);
    }
    all.addAll(_obstacleTris);
    _buildGrid(all, cellSize);
  }

  /// Parses `levels="0:Monument,1:Roof"` the way Space.setTerrain did:
  /// each level spans from the previous level's end (or group 0, or an
  /// explicit "Start..End") up to and including the named group.
  static Map<int, List<int>> parseLevels(Ms3dModel m, String levels) {
    final out = <int, List<int>>{};
    if (levels.trim().isEmpty) return out;
    var nextStart = 0;
    for (final part in levels.split(',')) {
      final kv = part.split(':');
      if (kv.length != 2) continue;
      final level = int.tryParse(kv[0].trim()) ?? 0;
      final range = kv[1].split('..');
      final end = m.groupIndexByName(range.last.trim());
      if (end < 0) continue;
      final start = range.length > 1 ? m.groupIndexByName(range.first.trim()) : nextStart;
      out[level] = [for (var g = start; g <= end; g++) g];
      nextStart = end + 1;
    }
    return out;
  }

  /// All groups whose name is in [names] (comma separated).
  static List<int> groupsNamed(Ms3dModel m, String names) {
    final set = names.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();
    return [for (var i = 0; i < m.groups.length; i++) if (set.contains(m.groups[i].name)) i];
  }

  Uint32List _trisOf(List<int> groups) {
    final out = <int>[];
    for (final g in groups.reversed) {
      if (g < 0 || g >= model.groups.length) continue;
      final ti = model.groups[g].triangleIndices;
      for (var i = ti.length - 1; i >= 0; i--) {
        out.add(ti[i]);
      }
    }
    return Uint32List.fromList(out);
  }

  void _buildGrid(Set<int> tris, double cellSize) {
    var minX = double.infinity, minZ = double.infinity, maxX = -double.infinity, maxZ = -double.infinity;
    final p = model.positions, vi = model.triangleVertexIndices;
    for (final t in tris) {
      for (var k = 0; k < 3; k++) {
        final v = vi[t * 3 + k];
        minX = math.min(minX, p[v * 3]);
        maxX = math.max(maxX, p[v * 3]);
        minZ = math.min(minZ, p[v * 3 + 2]);
        maxZ = math.max(maxZ, p[v * 3 + 2]);
      }
    }
    if (tris.isEmpty) {
      minX = minZ = 0;
      maxX = maxZ = 1;
    }
    _minX = minX;
    _minZ = minZ;
    _cell = cellSize;
    _nx = math.max(1, ((maxX - minX) / cellSize).ceil() + 1);
    _nz = math.max(1, ((maxZ - minZ) / cellSize).ceil() + 1);
    List<List<int>> bucket(Uint32List ordered) {
      final cells = List.generate(_nx * _nz, (_) => <int>[]);
      for (final t in ordered) {
        for (final c in _cellsOf(t)) {
          cells[c].add(t);
        }
      }
      return cells;
    }

    _levelTris.forEach((level, ordered) => _levelCells[level] = bucket(ordered));
    _obstacleCells = bucket(_obstacleTris);
  }

  Iterable<int> _cellsOf(int t) sync* {
    final p = model.positions, vi = model.triangleVertexIndices;
    {
      var x0 = double.infinity, x1 = -double.infinity, z0 = double.infinity, z1 = -double.infinity;
      for (var k = 0; k < 3; k++) {
        final v = vi[t * 3 + k];
        x0 = math.min(x0, p[v * 3]);
        x1 = math.max(x1, p[v * 3]);
        z0 = math.min(z0, p[v * 3 + 2]);
        z1 = math.max(z1, p[v * 3 + 2]);
      }
      final cx0 = ((x0 - _minX) / _cell).floor().clamp(0, _nx - 1);
      final cx1 = ((x1 - _minX) / _cell).floor().clamp(0, _nx - 1);
      final cz0 = ((z0 - _minZ) / _cell).floor().clamp(0, _nz - 1);
      final cz1 = ((z1 - _minZ) / _cell).floor().clamp(0, _nz - 1);
      for (var cz = cz0; cz <= cz1; cz++) {
        for (var cx = cx0; cx <= cx1; cx++) {
          yield cz * _nx + cx;
        }
      }
    }
  }

  int _cellIndex(double x, double z) {
    final cx = ((x - _minX) / _cell).floor();
    final cz = ((z - _minZ) / _cell).floor();
    if (cx < 0 || cz < 0 || cx >= _nx || cz >= _nz) return -1;
    return cz * _nx + cx;
  }

  /// MS3DModel.inTriangle (all three edge orientations equal).
  bool _inTri(int t, double x, double z) {
    final p = model.positions, vi = model.triangleVertexIndices;
    final a = vi[t * 3], b = vi[t * 3 + 1], c = vi[t * 3 + 2];
    final x1 = p[a * 3], z1 = p[a * 3 + 2];
    final x2 = p[b * 3], z2 = p[b * 3 + 2];
    final x3 = p[c * 3], z3 = p[c * 3 + 2];
    int o(double ax, double az, double bx, double bz) {
      final v = (bx - ax) * (z - az) - (x - ax) * (bz - az);
      return v > 0 ? 1 : (v < 0 ? -1 : 0);
    }

    final o1 = o(x1, z1, x2, z2), o2 = o(x2, z2, x3, z3), o3 = o(x3, z3, x1, z1);
    return o1 == o2 && o2 == o3;
  }

  /// Height (model Y) of triangle [t]'s plane at (x, z).
  double _planeY(int t, double x, double z) {
    final p = model.positions, vi = model.triangleVertexIndices;
    final a = vi[t * 3], b = vi[t * 3 + 1], c = vi[t * 3 + 2];
    final x1 = p[a * 3], y1 = p[a * 3 + 1], z1 = p[a * 3 + 2];
    final x2 = p[b * 3], y2 = p[b * 3 + 1], z2 = p[b * 3 + 2];
    final x3 = p[c * 3], y3 = p[c * 3 + 1], z3 = p[c * 3 + 2];
    final aa = y1 * (z2 - z3) + y2 * (z3 - z1) + y3 * (z1 - z2);
    var bb = z1 * (x2 - x3) + z2 * (x3 - x1) + z3 * (x1 - x2);
    final cc = x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2);
    final dd = -(x1 * (y2 * z3 - y3 * z2) + x2 * (y3 * z1 - y1 * z3) + x3 * (y1 * z2 - y2 * z1));
    if (bb == 0) bb = 0.1;
    return -(dd + aa * x + cc * z) / bb;
  }

  /// True if (x, z) is inside an obstacle triangle.
  bool isObstacle(double x, double z) {
    final c = _cellIndex(x, z);
    if (c < 0) return false;
    for (final t in _obstacleCells[c]) {
      if (_inTri(t, x, z)) return true;
    }
    return false;
  }

  /// Walkable height (model Y) at (x, z) on [level], or null if the point is
  /// off the walkable surface (or blocked when [checkObstacle]).
  double? heightAt(double x, double z, {int level = 0, bool checkObstacle = true}) {
    if (checkObstacle && isObstacle(x, z)) return null;
    final cells = _levelCells[level] ?? _levelCells[0];
    if (cells == null) return null;
    final c = _cellIndex(x, z);
    if (c < 0) return null;
    for (final t in cells[c]) {
      if (_inTri(t, x, z)) return _planeY(t, x, z);
    }
    return null;
  }
}
