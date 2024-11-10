part of three_loaders;

class ImageLoader extends Loader {
  ImageLoader(manager) : super(manager){
    flipY = false;
  }

  @override
  loadAsync(url, [Function? onProgress]) async {
    var completer = Completer();

    load(url, (buffer) {
      completer.complete(buffer);
    }, onProgress, () {});

    return completer.future;
  }

  @override
  load(url, Function onLoad, [Function? onProgress, Function? onError]) async {
    String? cacheName;
    if (path != "" && url is String) {
      url = path + url;
      cacheName = url;
    }
    else if(url is Blob){
      cacheName = String.fromCharCodes(url.data).toString().substring(0,50);
    }

    url = manager.resolveURL(url);
    cacheName ??= url;
    var cached = Cache.get(cacheName!);

    if (cached != null) {
      manager.itemStart(cacheName);
      onLoad(cached);
      manager.itemEnd(cacheName);
      return cached;
    }

    final _resp = await ImageLoaderLoader.loadImage(url, flipY);
    Cache.add(cacheName,_resp);
    onLoad(_resp);

    return _resp;
  }
}
