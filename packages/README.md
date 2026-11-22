# Patched packages

These are copies of packages from pub.dev with fixes applied for openworld and
its games. The games use them through `dependency_overrides` in their
pubspec.yaml, so a normal `flutter pub get` picks them up. You don't need to
patch anything yourself.

- **three_js_core** 0.2.4
- **three_js_animations** 0.2.2
- **three_js_helpers** 0.2.2
- **flutter_angle** 0.3.9

The fixes include performance improvements, a Linux window-resize fix, iOS
memory freeing, an Android Qualcomm/Adreno animation fix, and class-name checks
that break in web release builds. They target these exact versions (three_js
0.2.x), not the newer 0.3.x releases.

Each package keeps its original licence (MIT); see the LICENSE file in its
folder. Original packages: https://pub.dev/packages/three_js and
https://pub.dev/packages/flutter_angle

To regenerate this folder from a patched pub cache, run from the repo root:

    dart run tool/vendor_packages.dart --force
