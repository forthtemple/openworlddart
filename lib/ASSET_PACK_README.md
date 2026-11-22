# openworld asset packs

Encrypt selected game assets (models, their textures, character skins) so they can't simply be copied out of the installed game folder. Sounds, small models and config files stay as normal Flutter assets.

Encryption is ChaCha20 (RFC 8439), and each file is checked with HMAC-SHA256 so damaged or tampered files are rejected. Files are zlib-compressed when that saves space. It's all pure Dart, with no native libraries.

> This stops casual copying. It won't stop a determined hacker, because the key has to be inside the game for it to run.

## Files

| File | Purpose |
|---|---|
| `lib/asset_pack.dart` | Runtime: `AssetPack.init`, plus the load helpers for three_js |
| `lib/asset_pack_crypto.dart` | Encryption and the `.owp` pack format (no Flutter imports, so it's shared with the tool) |
| `bin/pack_assets.dart` | Command-line tool that builds packs and makes keys |
| `test/asset_pack_crypto_test.dart` | RFC 8439 test vector, a pack round trip and tamper checks |

Requires `crypto` in openworld's pubspec (already there).

Check that it compiles and works:

```
flutter test test/asset_pack_crypto_test.dart
```

---

## 1. Changes to openworld.dart

At the top:

```dart
import 'asset_pack.dart';
```

Then replace these loader calls:

| Where | Before | After |
|---|---|---|
| `Model.createModel` | `await loaderu.fromAsset(path)` | `await AssetPack.loadGLTF(path)` |
| `Actor.createActor` | `await loaderu.fromAsset(path)` | `await AssetPack.loadGLTF(path)` |
| `Model.setTexture` | `await THREE.TextureLoader().fromAsset(texturepath)` | `await AssetPack.loadTexture(texturepath)` |
| plane texture | `await THREE.TextureLoader().fromAsset(path)` | `await AssetPack.loadTexture(path)` |
| sprite texture | `await THREE.TextureLoader().fromAsset(path)` | `await AssetPack.loadTexture(path)` |

When a file isn't in a pack, every helper falls back to the original `fromAsset` call, so nothing changes for unpacked assets.

## 2. OBJ + MTL models (e.g. the temple)

Replace the MTLLoader / OBJLoader block with:

```dart
THREE.Group? mesh = await AssetPack.loadOBJ(
    'assets/models/temple/temple.obj',
    mtlPath: 'assets/models/temple/temple.mtl');
```

Textures named in the MTL are served from the pack too, flipped the same way MTLLoader normally does (`flipY = true`).

If you need your own `LoadingManager`, call `AssetPack.installTextureHandler(manager)` before loading the MTL. You can also pass `manager:` to `loadOBJ`.

## 3. Make a key (once per game)

From the game's folder:

```
dart run openworld:pack_assets --gen-key
```

If `dart run` complains in a Flutter project, use `flutter pub run openworld:pack_assets ...` instead.

This creates `owp.key` and prints something like:

```dart
const _kA = [0x3f, 0x91, ...];
const _kB = [0xc2, 0x07, ...];
const _kC = [0x5d, 0xe8, ...];
```

- **Keep `owp.key` private.** Add it to `.gitignore`, and never put it in `assets/`. If you lose it, make a new key and rebuild the packs.
- Paste the three parts into **the game, not openworld**, ideally in different files. They XOR together to form the key, so the key never appears in one piece.
- To print a fresh split of the same key: `dart run openworld:pack_assets --print-parts`.

## 4. Start it up in the game

The game imports the runtime directly:

```dart
import 'package:openworld/asset_pack.dart';
```

Then, before any packed asset is loaded:

```dart
WidgetsFlutterBinding.ensureInitialized();   // if called in main()
await AssetPack.init(key: AssetPack.keyFromParts([_kA, _kB, _kC]));
```

Optional parameters:

- `packs: ['assets/packs/game.owp']` — the default. List several packs to split a large one.
- `devDir: 'protected'` — the default. Set it to `null` to always use the packs, even in debug.

## 5. Move the protected files

Move each file you want protected out of `assets/` into `protected/`, **keeping its path**:

```
protected/assets/models/temple/temple.obj
protected/assets/models/temple/temple.mtl
protected/assets/models/temple/<its textures>.jpg
protected/assets/<path to>/priest3.glb
protected/assets/<path to>/head31hair.jpg
```

- Code keeps using the original paths, e.g. `assets/models/temple/temple.obj`.
- Do **not** list `protected/` in pubspec.yaml.
- Make sure no unencrypted copy is left under `assets/`. If one is, it ships as-is and gets loaded from the pack anyway.
- Packed `.glb` files must have their textures embedded.

## 6. Build the pack

```
dart run openworld:pack_assets --in protected --out assets/packs/game.owp
```

The tool lists each file, reads the whole pack back to verify it, then writes it. Use `--key-file <path>` if your key isn't `owp.key`.

Add the pack folder to the game's pubspec.yaml:

```yaml
flutter:
  assets:
    - assets/packs/
```

Rebuild the pack whenever a protected file changes, before a release build.

## 7. Developing

In debug builds on desktop, files are read straight from `protected/` first, so you don't need to repack while you work. If the pack is missing in debug, you'll see a message and the game carries on using `protected/`. Release builds only use the packs.

## 8. Release builds

Build with obfuscation so the key parts are harder to find:

```
flutter build windows --release --obfuscate --split-debug-info=build/symbols
```

Keep `build/symbols` so you can read stack traces from crash reports.

## Other helpers

```dart
AssetPack.contains(path)      // true if path is in an open pack
await AssetPack.loadBytes(path)   // devDir, then pack, then bundle
await AssetPack.loadString(path)
```

## Notes

- Each pack is held in memory once it's loaded. Split large sets into several packs.
- Decryption happens on the main isolate. A few MB takes a few tens of ms, which is fine during level loading.
- A wrong key, or a damaged or tampered file, throws `AssetPackException`.
- Path lookup ignores case and backslashes, so MTL files written on Windows still match.

## Pack format (`.owp`)

| Bytes | Contents |
|---|---|
| 4 | `OWP1` |
| 12 | index nonce |
| 4 | index length (little-endian) |
| 32 | HMAC of the header and the encrypted index |
| n | encrypted JSON index: path, offset, lengths, compressed flag, nonce and MAC for each file |
| ... | encrypted file data |

Keys: `encKey = HMAC(master, "openworld-pack-enc")` and `macKey = HMAC(master, "openworld-pack-mac")`. Each file gets a random 12-byte nonce, and its MAC covers the path, the nonce and the ciphertext.
