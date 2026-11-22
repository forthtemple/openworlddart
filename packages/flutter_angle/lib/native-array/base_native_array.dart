part of native_array;

class AllNativeData{
  List<NativeArray> allData = [];

  int get length => allData.length;

  bool _disposingAll = false;

  void add(NativeArray array){
    allData.add(array);
  }

  void dispose(){
    _disposingAll = true;
    allData.forEach((a){
      a.dispose();
    });

    allData.clear();
  }

  void removeAt(NativeArray array){
    if(_disposingAll) return;
    allData.remove(array);
  }
}

AllNativeData allNativeData = AllNativeData();

abstract class NativeArray<T extends num> {
  late int _size;
  late int oneByteSize;
  int get length => _size;
  int get lengthInBytes => length * oneByteSize;

  int get byteLength => lengthInBytes;
  int get len => length;
  int get BYTES_PER_ELEMENT => oneByteSize;
  
  bool disposed = false;
  //Is it a shared pointer in the CPP layer, and does it not need to be released by Dart
  bool isPointCpp = false;
  get data;
  get toJS;

  T operator [](int index); //=> data[index];
  void operator []=(int index, T value); // => data[index] = value;

  NativeArray(int size) : _size = size;

  List<T> toJson() => toDartList();
  List<T> toList() => toDartList();
  List<T> toDartList();
  List<T> sublist(int start, [int? end]) => toDartList().sublist(start, end);
  NativeArray set(List<T> newList, [int index = 0]) {
    toDartList().setAll(index, newList.sublist(0, math.min(newList.length, length)));
    return this;
  }

  NativeArray clone();

  void copy(NativeArray source) {
    set(source.toDartList() as List<T>);
  }

  void dispose(){
    allNativeData.removeAt(this);
  }
}