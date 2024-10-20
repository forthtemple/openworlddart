part of three_loaders;

abstract class Loader {
  late LoadingManager manager;
  late String crossOrigin;
  late bool withCredentials;
  late String path;
  String? resourcePath;
  late Map<String, dynamic> requestHeader;
  String responseType = "text";
  late String mimeType;
  bool flipY = false;

  Loader([manager]) {
    this.manager = (manager != null) ? manager : DefaultLoadingManager;

    crossOrigin = 'anonymous';
    withCredentials = false;
    path = '';
    resourcePath = '';
    requestHeader = {};
  }

  load(url, Function onLoad, [Function? onProgress, Function? onError]) {
    throw (" load need implement ............. ");
  }

  Future loadAsync(url) async {
    throw (" loadAsync need implement ............. ");
  }

  parse(json, [String path = '', Function? onLoad, Function? onError]) {}

  Loader setCrossOrigin(String crossOrigin) {
    this.crossOrigin = crossOrigin;
    return this;
  }

  Loader setWithCredentials(bool value) {
    withCredentials = value;
    return this;
  }

  Loader setPath(String path) {
    this.path = path;
    return this;
  }

  Loader setResourcePath(String? resourcePath) {
    this.resourcePath = resourcePath;
    return this;
  }

  Loader setRequestHeader(Map<String, dynamic> requestHeader) {
    this.requestHeader = requestHeader;
    return this;
  }
}
