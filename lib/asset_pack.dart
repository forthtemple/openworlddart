// Encrypted asset packs for openworld.
//
// Selected assets (models, their textures, head skins, ...) are packed into an
// encrypted .owp file by bin/pack_assets.dart. At runtime the game calls
// AssetPack.init() once with its key, and the load helpers below then serve
// those assets from the pack under their usual paths, e.g.
// 'assets/models/temple/temple.obj'. Anything not in a pack (sounds, small
// models, config) is loaded from the Flutter bundle exactly as before.
//
// In debug builds on desktop, files are read first from the unpacked
// [devDir] folder (default 'protected'), so you don't need to repack while
// developing.
//
// The key belongs to each game, not to openworld: see AssetPack.keyFromParts.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:three_js/three_js.dart' as THREE;
import 'package:archive/archive.dart' show ZLibDecoder;
import 'asset_pack_crypto.dart';

export 'asset_pack_crypto.dart' show AssetPackException;

class _Located {
  final int pack;
  final PackEntry entry;
  _Located(this.pack, this.entry);
}

class _OpenPack {
  final Uint8List bytes;
  final int dataStart;
  _OpenPack(this.bytes, this.dataStart);
}

class AssetPack {
  static PackKeys? _keys;
  static final List<_OpenPack> _packs = [];
  static final Map<String, _Located> _index = {};
  static final Map<String, _Located> _indexLower = {};
  static final Expando<bool> _handled = Expando<bool>();

  /// Unpacked originals read in debug builds (desktop only). Null to disable.
  static String? devDir = 'protected';

  /// True once init() has run.
  static bool get ready => _keys != null;

  /// Opens the packs. Call once at start-up, before any packed asset is
  /// loaded. [packs] are Flutter asset paths listed in the game's pubspec.
  static Future<void> init({
    required List<int> key,
    List<String> packs = const ['assets/packs/game.owp'],
    String? devDir = 'protected',
  }) async {
    AssetPack.devDir = devDir;
    _keys = PackKeys.fromMaster(key);
    _packs.clear();
    _index.clear();
    _indexLower.clear();

    for (final name in packs) {
      Uint8List bytes;
      try {
        final data = await rootBundle.load(name);
        bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      } catch (e) {
        // Fine while developing from devDir; a real problem in release.
        if (kDebugMode && devDir != null) {
          debugPrint('AssetPack: $name not found, using $devDir/ only');
          continue;
        }
        throw AssetPackException('Could not load pack $name: $e');
      }
      final index = readPackIndex(bytes, _keys!);
      final packNo = _packs.length;
      _packs.add(_OpenPack(bytes, index.dataStart));
      for (final e in index.entries) {
        final loc = _Located(packNo, e);
        _index[e.path] = loc;
        _indexLower[e.path.toLowerCase()] = loc;
      }
    }
  }

  /// Rebuilds the key from parts that XOR together. Keeping the key as
  /// several scattered parts (and building with --obfuscate) means it never
  /// appears as one block in the executable. pack_assets --gen-key prints
  /// the parts for you.
  static List<int> keyFromParts(List<List<int>> parts) {
    final key = List<int>.filled(parts.first.length, 0);
    for (final p in parts) {
      if (p.length != key.length) {
        throw ArgumentError('All key parts must be the same length');
      }
      for (var i = 0; i < key.length; i++) {
        key[i] ^= p[i];
      }
    }
    return key;
  }

  static String _normalise(String path) {
    var p = path.replaceAll('\\', '/');
    while (p.startsWith('./')) {
      p = p.substring(2);
    }
    return p.replaceAll('/./', '/');
  }

  static _Located? _find(String path) {
    final p = _normalise(path);
    return _index[p] ?? _indexLower[p.toLowerCase()];
  }

  /// True if [path] is in an open pack.
  static bool contains(String path) => _find(path) != null;

  static File? _devFile(String path) {
    if (!kDebugMode || kIsWeb || devDir == null) return null;
    final f = File('$devDir/${_normalise(path)}');
    return f.existsSync() ? f : null;
  }

  /// Bytes from devDir (debug) or a pack; null if [path] is neither, meaning
  /// it should be loaded from the Flutter bundle as normal.
  static Future<Uint8List?> packedBytes(String path) async {
    final dev = _devFile(path);
    if (dev != null) return dev.readAsBytes();

    final loc = _find(path);
    if (loc == null) return null;
    final pack = _packs[loc.pack];
    final stored = decryptEntry(pack.bytes, pack.dataStart, loc.entry, _keys!);
    if (!loc.entry.compressed) return stored;
    return Uint8List.fromList(ZLibDecoder().decodeBytes(stored));
    //return Uint8List.fromList(zlib.decode(stored));
  }

  /// Loads any asset: devDir (debug), then the packs, then the bundle.
  static Future<Uint8List> loadBytes(String path) async {
    final b = await packedBytes(path);
    if (b != null) return b;
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  static Future<String> loadString(String path) async =>
      utf8.decode(await loadBytes(path));

  // -------------------------------------------------------------------------
  // three_js helpers. Each one behaves like the fromAsset call it replaces
  // when the file isn't packed.
  // -------------------------------------------------------------------------

  /// Replaces `THREE.TextureLoader().fromAsset(path)`.
  static Future<THREE.Texture?> loadTexture(String path, {bool flipY = false}) async {
    final loader = THREE.TextureLoader(flipY: flipY);
    final b = await packedBytes(path);
    return b != null ? loader.fromBytes(b) : loader.fromAsset(path);
  }

  /// Replaces `THREE.GLTFLoader().fromAsset(path)`. Packed models must be
  /// self-contained .glb files (textures embedded).
  static Future<THREE.GLTFData?> loadGLTF(String path) async {
    final b = await packedBytes(path);
    if (b == null) return THREE.GLTFLoader().fromAsset(path);
    final loader = THREE.GLTFLoader();
    loader.setPath(path.substring(0, path.lastIndexOf('/') + 1));
    return loader.fromBytes(b);
  }

  /// Loads an OBJ with its optional MTL. Textures named in the MTL are taken
  /// from the packs when they are packed, otherwise from the bundle.
  static Future<THREE.Group?> loadOBJ(String objPath,
      {String? mtlPath, THREE.LoadingManager? manager}) async {
    manager ??= THREE.LoadingManager();
    dynamic materials;
    if (mtlPath != null) {
      installTextureHandler(manager);
      final dir = mtlPath.substring(0, mtlPath.lastIndexOf('/') + 1);
      final mtlLoader = THREE.MTLLoader(manager);
      mtlLoader.setPath(dir);
      final b = await packedBytes(mtlPath);
      materials = b != null
          ? await mtlLoader.fromBytes(b)
          : await mtlLoader.fromAsset(mtlPath.substring(dir.length));
      await materials?.preload();
    }
    final loader = THREE.OBJLoader();
    loader.setMaterials(materials);
    final b = await packedBytes(objPath);
    return b != null ? loader.fromBytes(b) : loader.fromAsset(objPath);
  }

  /// Makes every texture requested through [manager] (e.g. by an MTL file)
  /// come from the packs when it is packed. Safe to call more than once.
  static void installTextureHandler(THREE.LoadingManager manager) {
    if (_handled[manager] == true) return;
    _handled[manager] = true;
    manager.addHandler(RegExp(r'.*'), _PackTextureLoader(manager));
  }
}

/// Texture loader used for MTL textures: packed files come from the pack,
/// everything else goes the normal way. flipY is true to match what
/// MTLLoader uses by default.
class _PackTextureLoader extends THREE.TextureLoader {
  _PackTextureLoader(THREE.LoadingManager manager) : super(manager: manager, flipY: true);

  @override
  Future<THREE.Texture?> unknown(dynamic url) async {
    if (url is String) {
      final b = await AssetPack.packedBytes(url);
      if (b != null) return fromBytes(b);
    }
    return super.unknown(url);
  }
}
