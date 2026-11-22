// Pure-Dart core of the openworld asset pack: ChaCha20 encryption, HMAC-SHA256
// authentication and the .owp pack file format.
//
// No Flutter imports, so it is shared by the game at runtime (asset_pack.dart)
// and by the command-line packer (bin/pack_assets.dart).
//
// Pack file layout (all integers little-endian):
//
//   "OWP1"                  4 bytes   magic
//   index nonce            12 bytes
//   index length            4 bytes
//   index MAC              32 bytes   HMAC(macKey, magic|nonce|length|encrypted index)
//   encrypted index         n bytes   ChaCha20 of a UTF-8 JSON list of entries
//   data region                       each file's ciphertext, back to back
//
// Each index entry: {"p": logical path, "o": offset in data region,
// "l": stored length, "n": original length, "z": 1 if zlib-compressed,
// "iv": base64 nonce, "m": base64 HMAC(macKey, path|0|nonce|ciphertext)}.
//
// The two working keys are derived from the game's 32-byte master key:
//   encKey = HMAC(master, "openworld-pack-enc")
//   macKey = HMAC(master, "openworld-pack-mac")

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

const List<int> owpMagic = [0x4F, 0x57, 0x50, 0x31]; // "OWP1"
const int owpHeaderLength = 4 + 12 + 4 + 32;

/// Thrown when a pack is damaged, tampered with or opened with the wrong key.
class AssetPackException implements Exception {
  final String message;
  AssetPackException(this.message);
  @override
  String toString() => 'AssetPackException: $message';
}

/// The two keys actually used for a pack, derived from the master key.
class PackKeys {
  final Uint8List encKey;
  final Uint8List macKey;
  PackKeys._(this.encKey, this.macKey);

  factory PackKeys.fromMaster(List<int> master) {
    if (master.length != 32) {
      throw AssetPackException('Master key must be 32 bytes (got ${master.length})');
    }
    return PackKeys._(
      hmacSha256(master, utf8.encode('openworld-pack-enc')),
      hmacSha256(master, utf8.encode('openworld-pack-mac')),
    );
  }
}

Uint8List hmacSha256(List<int> key, List<int> data) =>
    Uint8List.fromList(crypto.Hmac(crypto.sha256, key).convert(data).bytes);

/// HMAC over several byte chunks without first joining them into one list.
Uint8List hmacSha256Parts(List<int> key, List<List<int>> parts) {
  final out = _DigestSink();
  final input = crypto.Hmac(crypto.sha256, key).startChunkedConversion(out);
  for (final p in parts) {
    input.add(p);
  }
  input.close();
  return Uint8List.fromList(out.value!.bytes);
}

class _DigestSink implements Sink<crypto.Digest> {
  crypto.Digest? value;
  @override
  void add(crypto.Digest data) => value = data;
  @override
  void close() {}
}

/// Compares two MACs in constant time.
bool macEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}

Uint8List _u32le(int v) =>
    Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little);

/// MAC for a single file. The path is included so entries can't be swapped.
Uint8List entryMac(Uint8List macKey, String path, List<int> nonce, List<int> cipher) =>
    hmacSha256Parts(macKey, [utf8.encode(path), const [0], nonce, cipher]);

Uint8List indexMac(Uint8List macKey, List<int> nonce, int length, List<int> cipher) =>
    hmacSha256Parts(macKey, [owpMagic, nonce, _u32le(length), cipher]);

// ---------------------------------------------------------------------------
// ChaCha20 (RFC 8439): 32-byte key, 12-byte nonce, 32-bit block counter.
// Encryption and decryption are the same operation.
// ---------------------------------------------------------------------------

int _rotl(int v, int n) => ((v << n) | (v >> (32 - n))) & 0xffffffff;

/// Returns [data] XORed with the ChaCha20 keystream. [data] is not modified.
Uint8List chacha20(List<int> key, List<int> nonce, List<int> data, {int counter = 0}) {
  if (key.length != 32) throw ArgumentError('ChaCha20 key must be 32 bytes');
  if (nonce.length != 12) throw ArgumentError('ChaCha20 nonce must be 12 bytes');

  final kb = Uint8List.fromList(key).buffer.asByteData();
  final nb = Uint8List.fromList(nonce).buffer.asByteData();
  final init = Uint32List(16);
  init[0] = 0x61707865;
  init[1] = 0x3320646e;
  init[2] = 0x79622d32;
  init[3] = 0x6b206574;
  for (var i = 0; i < 8; i++) {
    init[4 + i] = kb.getUint32(i * 4, Endian.little);
  }
  init[12] = counter;
  for (var i = 0; i < 3; i++) {
    init[13 + i] = nb.getUint32(i * 4, Endian.little);
  }

  final out = Uint8List.fromList(data);
  final ks = Uint32List(16);
  final ksBytes = Uint8List(64);
  final ksView = ksBytes.buffer.asByteData();

  for (var pos = 0; pos < out.length; pos += 64) {
    var x0 = init[0], x1 = init[1], x2 = init[2], x3 = init[3];
    var x4 = init[4], x5 = init[5], x6 = init[6], x7 = init[7];
    var x8 = init[8], x9 = init[9], x10 = init[10], x11 = init[11];
    var x12 = init[12], x13 = init[13], x14 = init[14], x15 = init[15];

    for (var r = 0; r < 10; r++) {
      // Column rounds.
      x0 = (x0 + x4) & 0xffffffff; x12 = _rotl(x12 ^ x0, 16);
      x8 = (x8 + x12) & 0xffffffff; x4 = _rotl(x4 ^ x8, 12);
      x0 = (x0 + x4) & 0xffffffff; x12 = _rotl(x12 ^ x0, 8);
      x8 = (x8 + x12) & 0xffffffff; x4 = _rotl(x4 ^ x8, 7);

      x1 = (x1 + x5) & 0xffffffff; x13 = _rotl(x13 ^ x1, 16);
      x9 = (x9 + x13) & 0xffffffff; x5 = _rotl(x5 ^ x9, 12);
      x1 = (x1 + x5) & 0xffffffff; x13 = _rotl(x13 ^ x1, 8);
      x9 = (x9 + x13) & 0xffffffff; x5 = _rotl(x5 ^ x9, 7);

      x2 = (x2 + x6) & 0xffffffff; x14 = _rotl(x14 ^ x2, 16);
      x10 = (x10 + x14) & 0xffffffff; x6 = _rotl(x6 ^ x10, 12);
      x2 = (x2 + x6) & 0xffffffff; x14 = _rotl(x14 ^ x2, 8);
      x10 = (x10 + x14) & 0xffffffff; x6 = _rotl(x6 ^ x10, 7);

      x3 = (x3 + x7) & 0xffffffff; x15 = _rotl(x15 ^ x3, 16);
      x11 = (x11 + x15) & 0xffffffff; x7 = _rotl(x7 ^ x11, 12);
      x3 = (x3 + x7) & 0xffffffff; x15 = _rotl(x15 ^ x3, 8);
      x11 = (x11 + x15) & 0xffffffff; x7 = _rotl(x7 ^ x11, 7);

      // Diagonal rounds.
      x0 = (x0 + x5) & 0xffffffff; x15 = _rotl(x15 ^ x0, 16);
      x10 = (x10 + x15) & 0xffffffff; x5 = _rotl(x5 ^ x10, 12);
      x0 = (x0 + x5) & 0xffffffff; x15 = _rotl(x15 ^ x0, 8);
      x10 = (x10 + x15) & 0xffffffff; x5 = _rotl(x5 ^ x10, 7);

      x1 = (x1 + x6) & 0xffffffff; x12 = _rotl(x12 ^ x1, 16);
      x11 = (x11 + x12) & 0xffffffff; x6 = _rotl(x6 ^ x11, 12);
      x1 = (x1 + x6) & 0xffffffff; x12 = _rotl(x12 ^ x1, 8);
      x11 = (x11 + x12) & 0xffffffff; x6 = _rotl(x6 ^ x11, 7);

      x2 = (x2 + x7) & 0xffffffff; x13 = _rotl(x13 ^ x2, 16);
      x8 = (x8 + x13) & 0xffffffff; x7 = _rotl(x7 ^ x8, 12);
      x2 = (x2 + x7) & 0xffffffff; x13 = _rotl(x13 ^ x2, 8);
      x8 = (x8 + x13) & 0xffffffff; x7 = _rotl(x7 ^ x8, 7);

      x3 = (x3 + x4) & 0xffffffff; x14 = _rotl(x14 ^ x3, 16);
      x9 = (x9 + x14) & 0xffffffff; x4 = _rotl(x4 ^ x9, 12);
      x3 = (x3 + x4) & 0xffffffff; x14 = _rotl(x14 ^ x3, 8);
      x9 = (x9 + x14) & 0xffffffff; x4 = _rotl(x4 ^ x9, 7);
    }

    ks[0] = x0 + init[0]; ks[1] = x1 + init[1]; ks[2] = x2 + init[2]; ks[3] = x3 + init[3];
    ks[4] = x4 + init[4]; ks[5] = x5 + init[5]; ks[6] = x6 + init[6]; ks[7] = x7 + init[7];
    ks[8] = x8 + init[8]; ks[9] = x9 + init[9]; ks[10] = x10 + init[10]; ks[11] = x11 + init[11];
    ks[12] = x12 + init[12]; ks[13] = x13 + init[13]; ks[14] = x14 + init[14]; ks[15] = x15 + init[15];
    for (var i = 0; i < 16; i++) {
      ksView.setUint32(i * 4, ks[i], Endian.little);
    }

    final n = (out.length - pos) < 64 ? out.length - pos : 64;
    for (var i = 0; i < n; i++) {
      out[pos + i] ^= ksBytes[i];
    }

    init[12] = (init[12] + 1) & 0xffffffff;
    if (init[12] == 0) {
      throw AssetPackException('File too large for one ChaCha20 nonce (256 GB)');
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// Pack index
// ---------------------------------------------------------------------------

class PackEntry {
  final String path;
  final int offset; // within the data region
  final int storedLength;
  final int originalLength;
  final bool compressed;
  final Uint8List nonce;
  final Uint8List mac;

  PackEntry({
    required this.path,
    required this.offset,
    required this.storedLength,
    required this.originalLength,
    required this.compressed,
    required this.nonce,
    required this.mac,
  });

  Map<String, dynamic> toJson() => {
        'p': path,
        'o': offset,
        'l': storedLength,
        'n': originalLength,
        'z': compressed ? 1 : 0,
        'iv': base64.encode(nonce),
        'm': base64.encode(mac),
      };

  factory PackEntry.fromJson(Map<String, dynamic> j) => PackEntry(
        path: j['p'] as String,
        offset: j['o'] as int,
        storedLength: j['l'] as int,
        originalLength: j['n'] as int,
        compressed: j['z'] == 1,
        nonce: base64.decode(j['iv'] as String),
        mac: base64.decode(j['m'] as String),
      );
}

class PackIndex {
  final List<PackEntry> entries;
  /// Where the data region begins in the pack.
  final int dataStart;
  PackIndex(this.entries, this.dataStart);
}

/// Reads and checks the header and index of a pack.
PackIndex readPackIndex(Uint8List pack, PackKeys keys) {
  if (pack.length < owpHeaderLength ||
      pack[0] != owpMagic[0] || pack[1] != owpMagic[1] ||
      pack[2] != owpMagic[2] || pack[3] != owpMagic[3]) {
    throw AssetPackException('Not an openworld asset pack');
  }
  final nonce = Uint8List.sublistView(pack, 4, 16);
  final len = pack.buffer.asByteData(pack.offsetInBytes).getUint32(16, Endian.little);
  final mac = Uint8List.sublistView(pack, 20, 52);
  if (owpHeaderLength + len > pack.length) {
    throw AssetPackException('Pack is truncated');
  }
  final cipher = Uint8List.sublistView(pack, owpHeaderLength, owpHeaderLength + len);
  if (!macEquals(mac, indexMac(keys.macKey, nonce, len, cipher))) {
    throw AssetPackException('Pack index failed authentication (wrong key or damaged file)');
  }
  final json = jsonDecode(utf8.decode(chacha20(keys.encKey, nonce, cipher))) as List;
  return PackIndex(
    [for (final e in json) PackEntry.fromJson(e as Map<String, dynamic>)],
    owpHeaderLength + len,
  );
}

/// Checks and decrypts one entry. Returns the stored bytes, which still need
/// inflating with zlib when [PackEntry.compressed] is true.
Uint8List decryptEntry(Uint8List pack, int dataStart, PackEntry e, PackKeys keys) {
  final start = dataStart + e.offset;
  if (start + e.storedLength > pack.length) {
    throw AssetPackException('Pack is truncated at ${e.path}');
  }
  final cipher = Uint8List.sublistView(pack, start, start + e.storedLength);
  if (!macEquals(e.mac, entryMac(keys.macKey, e.path, e.nonce, cipher))) {
    throw AssetPackException('${e.path} failed authentication (damaged or tampered)');
  }
  return chacha20(keys.encKey, e.nonce, cipher);
}

/// Builds a pack. [files] maps logical path -> original bytes.
/// [compress] is zlib deflate (dart:io's zlib in the packer).
/// [randomBytes] supplies nonces (Random.secure in the packer).
Uint8List buildPack(
  Map<String, Uint8List> files,
  PackKeys keys, {
  required List<int> Function(List<int>) compress,
  required Uint8List Function(int) randomBytes,
}) {
  final entries = <PackEntry>[];
  final data = BytesBuilder(copy: false);
  var offset = 0;
  final paths = files.keys.toList()..sort();
  for (final path in paths) {
    final original = files[path]!;
    var stored = original;
    var compressed = false;
    final z = compress(original);
    // Only keep compression when it saves at least 5% (JPGs/PNGs won't).
    if (z.length < original.length * 0.95) {
      stored = Uint8List.fromList(z);
      compressed = true;
    }
    final nonce = randomBytes(12);
    final cipher = chacha20(keys.encKey, nonce, stored);
    entries.add(PackEntry(
      path: path,
      offset: offset,
      storedLength: cipher.length,
      originalLength: original.length,
      compressed: compressed,
      nonce: nonce,
      mac: entryMac(keys.macKey, path, nonce, cipher),
    ));
    data.add(cipher);
    offset += cipher.length;
  }

  final indexNonce = randomBytes(12);
  final indexPlain = utf8.encode(jsonEncode([for (final e in entries) e.toJson()]));
  final indexCipher = chacha20(keys.encKey, indexNonce, indexPlain);

  final out = BytesBuilder(copy: false)
    ..add(owpMagic)
    ..add(indexNonce)
    ..add(_u32le(indexCipher.length))
    ..add(indexMac(keys.macKey, indexNonce, indexCipher.length, indexCipher))
    ..add(indexCipher)
    ..add(data.takeBytes());
  return out.takeBytes();
}
