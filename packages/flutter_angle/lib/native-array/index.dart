/// used for better performance on app & desktop
/// when buffer need change frequent
/// if use Dart List, will need memory copy every time convert to pointer
library native_array;

import 'dart:math' as math;
import 'native_array_app.dart' if (dart.library.js_interop) './native_array_web.dart';
part 'base_native_array.dart';
part 'native_array.dart';
