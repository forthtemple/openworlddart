// Builds encrypted openworld asset packs.
//
// Run from the game's folder:
//
//   dart run openworld:pack_assets --gen-key
//       Creates owp.key (keep it private, never ship or commit it) and prints
//       the key parts to paste into the game's AssetPack.init call.
//
//   dart run openworld:pack_assets --print-parts
//       Prints the parts again for an existing owp.key (new random split).
//
//   dart run openworld:pack_assets --in protected --out assets/packs/game.owp
//       Packs every file under protected/. A file at
//       protected/assets/models/temple/temple.obj is stored under the
//       logical path assets/models/temple/temple.obj.
//
// Options: --key-file <path> (default owp.key).

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:openworld/asset_pack_crypto.dart';

void main(List<String> args) {
  String? opt(String name) {
    final i = args.indexOf(name);
    return (i >= 0 && i + 1 < args.length) ? args[i + 1] : null;
  }

  final keyFile = opt('--key-file') ?? 'owp.key';
  try {
    if (args.contains('--gen-key')) {
      _genKey(keyFile);
    } else if (args.contains('--print-parts')) {
      _printParts(_readKey(keyFile));
    } else if (opt('--in') != null && opt('--out') != null) {
      _pack(opt('--in')!, opt('--out')!, _readKey(keyFile));
    } else {
      stdout.writeln('Usage:\n'
          '  dart run openworld:pack_assets --gen-key [--key-file owp.key]\n'
          '  dart run openworld:pack_assets --print-parts [--key-file owp.key]\n'
          '  dart run openworld:pack_assets --in protected --out assets/packs/game.owp [--key-file owp.key]');
      exitCode = 64;
    }
  } on AssetPackException catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
  }
}

final _rng = Random.secure();

Uint8List _random(int n) => Uint8List.fromList(List.generate(n, (_) => _rng.nextInt(256)));

String _hex(List<int> b) => b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

Uint8List _readKey(String path) {
  final f = File(path);
  if (!f.existsSync()) {
    throw AssetPackException('Key file $path not found. Create one with --gen-key.');
  }
  final hex = f.readAsStringSync().trim();
  if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hex)) {
    throw AssetPackException('$path should contain 64 hex characters');
  }
  return Uint8List.fromList(List.generate(32, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16)));
}

void _genKey(String path) {
  final f = File(path);
  if (f.existsSync()) {
    throw AssetPackException('$path already exists. Delete it first if you really want a '
        'new key (existing packs will then need rebuilding).');
  }
  final key = _random(32);
  f.writeAsStringSync('${_hex(key)}\n');
  stdout.writeln('Wrote $path. Keep it out of git and out of the game\'s assets.\n');
  _printParts(key);
}

void _printParts(Uint8List key) {
  final a = _random(32), b = _random(32);
  final c = Uint8List.fromList(List.generate(32, (i) => key[i] ^ a[i] ^ b[i]));
  String list(List<int> p) =>
      '[${p.map((x) => '0x${x.toRadixString(16).padLeft(2, '0')}').join(', ')}]';
  stdout.writeln('Paste these into the game (they can live in different files), then:\n'
      '  await AssetPack.init(key: AssetPack.keyFromParts([_kA, _kB, _kC]));\n');
  stdout.writeln('const _kA = ${list(a)};');
  stdout.writeln('const _kB = ${list(b)};');
  stdout.writeln('const _kC = ${list(c)};');
}

void _pack(String inDir, String outPath, Uint8List key) {
  final root = Directory(inDir);
  if (!root.existsSync()) throw AssetPackException('Folder $inDir not found');
  final rootPath = root.absolute.path.replaceAll('\\', '/');
  final files = <String, Uint8List>{};
  for (final e in root.listSync(recursive: true)) {
    if (e is! File) continue;
    final abs = e.absolute.path.replaceAll('\\', '/');
    final rel = abs.substring(rootPath.length).replaceFirst(RegExp(r'^/+'), '');
    final name = rel.split('/').last;
    if (name.startsWith('.') || name == 'Thumbs.db') continue;
    files[rel] = e.readAsBytesSync();
  }
  if (files.isEmpty) throw AssetPackException('No files found in $inDir');

  final keys = PackKeys.fromMaster(key);
  final pack = buildPack(files, keys,
      compress: (b) => ZLibCodec(level: 9).encode(b), randomBytes: _random);

  // Read it straight back to be sure it opens and every file matches.
  final index = readPackIndex(pack, keys);
  var original = 0;
  for (final e in index.entries) {
    var data = decryptEntry(pack, index.dataStart, e, keys);
    if (e.compressed) data = Uint8List.fromList(zlib.decode(data));
    final want = files[e.path]!;
    if (data.length != want.length || !macEquals(data, want)) {
      throw AssetPackException('Verification failed for ${e.path}');
    }
    original += want.length;
    stdout.writeln('  ${e.path}  ${_size(want.length)}${e.compressed ? '  (compressed to ${_size(e.storedLength)})' : ''}');
  }

  File(outPath)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(pack);
  stdout.writeln('\nPacked ${files.length} files (${_size(original)}) into $outPath (${_size(pack.length)}), verified.');
}

String _size(int n) => n < 1024 * 1024 ? '${(n / 1024).toStringAsFixed(1)} KB' : '${(n / 1048576).toStringAsFixed(2)} MB';
