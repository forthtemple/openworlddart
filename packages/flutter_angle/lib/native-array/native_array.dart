part of native_array;

class Float32Array extends NativeFloat32Array {
  Float32Array(int size) : super(size);
  Float32Array.fromList(List<double> listData) : super.fromList(listData);

  ///from c++ layer shared pointer
  Float32Array.fromPoint(dynamic pointFloat, int size)
      : super.fromPoint(pointFloat, size);
  Float32Array clone() {
    var dartList = this.toDartList();
    return Float32Array(dartList.length)..set(dartList);
  }
}

class Float64Array extends NativeFloat64Array {
  Float64Array(int size) : super(size);
  Float64Array.fromList(List<double> listData) : super.fromList(listData);

  Float64Array clone() {
    var dartList = this.toDartList();
    return Float64Array(dartList.length)..set(dartList);
  }
}

class Uint32Array extends NativeUint32Array {
  Uint32Array(int size) : super(size);
  Uint32Array.fromList(List<int> listData) : super.fromList(listData);

  Uint32Array clone() {
    var dartList = this.toDartList();
    return Uint32Array(dartList.length)..set(dartList);
  }
}

class Uint16Array extends NativeUint16Array {
  Uint16Array(int size) : super(size);
  Uint16Array.fromList(List<int> listData) : super.fromList(listData);

  Uint16Array clone() {
    var dartList = this.toDartList();
    return Uint16Array(dartList.length)..set(dartList);
  }
}

class Uint8Array extends NativeUint8Array {
  Uint8Array(int size) : super(size);
  Uint8Array.fromList(List<int> listData) : super.fromList(listData);

  Uint8Array clone() {
    var dartList = this.toDartList();
    return Uint8Array(dartList.length)..set(dartList);
  }
}

class Int8Array extends NativeInt8Array {
  Int8Array(int size) : super(size);
  Int8Array.fromList(List<int> listData) : super.fromList(listData);
}

class Int16Array extends NativeInt16Array {
  Int16Array(int size) : super(size);
  Int16Array.fromList(List<int> listData) : super.fromList(listData);

  Int16Array clone() {
    var dartList = this.toDartList();
    return Int16Array(dartList.length)..set(dartList);
  }
}

class Int32Array extends NativeInt32Array {
  Int32Array(int size) : super(size);
  Int32Array.fromList(List<int> listData) : super.fromList(listData);

  Int32Array clone() {
    var dartList = this.toDartList();
    return Int32Array(dartList.length)..set(dartList);
  }
}
