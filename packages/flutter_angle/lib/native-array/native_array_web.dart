import 'dart:js_interop';
import 'dart:typed_data';
import 'index.dart';

abstract class PlatformNativeArray<T extends num> extends NativeArray<T> {
  TypedData get data;
  ByteBuffer get buffer => data.buffer;
  int get bytesLength => length * oneByteSize;

  PlatformNativeArray(int size) : super(size) {}
  PlatformNativeArray.fromList(List<T> listData) : super(listData.length) {}

  List<T> toDartList();

  @override
  void dispose() {}

  @override
  T operator [](int index) {
    final list = toDartList();
    if(index < 0)
      return list[0];
    if(index >= list.length)
      return list[index-list.length];
    else
      return list[index];
  }

  @override
  void operator []=(int index, T value) {
    toDartList()[index] = value;
  }
}

class NativeFloat32Array extends PlatformNativeArray<double> {
  late Float32List _list;

  Float32List get data => _list;
  JSFloat32Array get toJS => _list.toJS;

  NativeFloat32Array(int size) : super(size) {
    _list = Float32List(size);
    oneByteSize = Float32List.bytesPerElement;
  }

  NativeFloat32Array.fromList(List<double> listData) : super.fromList(listData) {
    _list = Float32List.fromList(listData);
    oneByteSize = Float32List.bytesPerElement;
  }

  ///from c++ layer shared pointer
  NativeFloat32Array.fromPoint(Float32List data, int size) : super(size) {
    _list = data;
    oneByteSize = Float32List.bytesPerElement;
    // isPointCpp = true;
  }
  @override
  NativeFloat32Array clone() {
    return NativeFloat32Array.fromList(_list);
  }

  @override
  Float32List toDartList() => _list;

  // setAt(newList, int index) {
  //   this
  //       .toDartList()
  //       .setAll(index, List<double>.fromList(newList.map((e) => e.toDouble())));
  //   return this;
  // }
}

class NativeUint16Array extends PlatformNativeArray<int> {
  late Uint16List _list;

  Uint16List get data => _list;
  JSUint16Array get toJS => _list.toJS;

  NativeUint16Array(int size) : super(size) {
    _list = Uint16List(size);
    oneByteSize = Uint16List.bytesPerElement;
  }
  NativeUint16Array.fromList(List<int> listData) : super.fromList(listData) {
    _list = Uint16List.fromList(listData);
    oneByteSize = Uint16List.bytesPerElement;
  }

  @override
  NativeUint16Array clone() {
    return NativeUint16Array.fromList(_list);
  }

  @override
  Uint16List toDartList() => _list;
}

class NativeUint32Array extends PlatformNativeArray<int> {
  late Uint32List _list;

  Uint32List get data => _list;
  JSUint32Array get toJS => _list.toJS;

  NativeUint32Array(int size) : super(size) {
    _list = Uint32List(size);
    oneByteSize = Uint32List.bytesPerElement;
  }
  NativeUint32Array.fromList(List<int> listData) : super.fromList(listData) {
    _list = Uint32List.fromList(listData);
    oneByteSize = Uint32List.bytesPerElement;
  }

  @override
  NativeUint32Array clone() {
    return NativeUint32Array.fromList(_list);
  }

  @override
  Uint32List toDartList() => _list;
}

class NativeInt8Array extends PlatformNativeArray<int> {
  late Int8List _list;

  Int8List get data => _list;
  JSInt8Array get toJS => _list.toJS;

  NativeInt8Array(int size) : super(size) {
    _list = Int8List(size);
    oneByteSize = Int8List.bytesPerElement;
  }

  NativeInt8Array.fromList(List<int> listData) : super.fromList(listData) {
    _list = Int8List.fromList(listData);
    oneByteSize = Int8List.bytesPerElement;
  }

  @override
  NativeInt8Array clone() {
    return NativeInt8Array.fromList(_list);
  }

  @override
  Int8List toDartList() => _list;
}

class NativeInt16Array extends PlatformNativeArray<int> {
  late Int16List _list;

  Int16List get data => _list;
  JSInt16Array get toJS => _list.toJS;

  NativeInt16Array(int size) : super(size) {
    _list = Int16List(size);
    oneByteSize = Int16List.bytesPerElement;
  }

  NativeInt16Array.fromList(List<int> listData) : super.fromList(listData) {
    _list = Int16List.fromList(listData);
    oneByteSize = Int16List.bytesPerElement;
  }

  @override
  NativeInt16Array clone() {
    return NativeInt16Array.fromList(_list);
  }

  @override
  Int16List toDartList() => _list;
}

class NativeInt32Array extends PlatformNativeArray<int> {
  late Int32List _list;

  Int32List get data => _list;
  JSInt32Array get toJS => _list.toJS;

  NativeInt32Array(int size) : super(size) {
    _list = Int32List(size);
    oneByteSize = Int32List.bytesPerElement;
  }

  NativeInt32Array.fromList(List<int> listData) : super.fromList(listData) {
    _list = Int32List.fromList(listData);
    oneByteSize = Int32List.bytesPerElement;
  }

  @override
  NativeInt32Array clone() {
    return NativeInt32Array.fromList(_list);
  }

  @override
  Int32List toDartList() => _list;
}

class NativeUint8Array extends PlatformNativeArray<int> {
  late Uint8List _list;

  Uint8List get data => _list;
  JSUint8Array get toJS => _list.toJS;

  NativeUint8Array(int size) : super(size) {
    _list = Uint8List(size);
    oneByteSize = Uint8List.bytesPerElement;
  }

  NativeUint8Array.fromList(List<int> listData) : super.fromList(listData) {
    _list = Uint8List.fromList(listData);
    oneByteSize = Uint8List.bytesPerElement;
  }

  @override
  NativeUint8Array clone() {
    return NativeUint8Array.fromList(_list);
  }

  @override
  Uint8List toDartList() => _list;
}

class NativeFloat64Array extends PlatformNativeArray<double> {
  late Float64List _list;

  Float64List get data => _list;
  JSFloat64Array get toJS => _list.toJS;

  NativeFloat64Array(int size) : super(size) {
    _list = Float64List(size);
    oneByteSize = Float64List.bytesPerElement;
  }

  NativeFloat64Array.fromList(List<double> listData) : super.fromList(listData) {
    _list = Float64List.fromList(listData);
    oneByteSize = Float64List.bytesPerElement;
  }

  @override
  NativeFloat64Array clone() {
    return NativeFloat64Array.fromList(_list);
  }

  @override
  Float64List toDartList() => _list;
}
