part of three_loaders;

class TextureLoader extends Loader {

  TextureLoader([manager]) : super(manager);

  @override
  Future<Texture> loadAsync(url, [Function? onProgress]) async {
    Completer<Texture> completer = Completer<Texture>();

    load(url, (texture) {
      completer.complete(texture);
    }, onProgress, () {});

    return completer.future;
  }

  @override
  load(url, Function onLoad, [Function? onProgress, Function? onError]) {
    //print("voot"+StackTrace.current.toString());
    final Texture texture = Texture();

    final ImageLoader loader = ImageLoader(manager);
    loader.setCrossOrigin(crossOrigin);
    loader.setPath(path);

    final Completer<Texture> completer = Completer<Texture>();

    loader.flipY = flipY;
    loader.load(url, (image) {
      ImageElement imageElement;

      // Web better way ???
      if (kIsWeb && image is! Image) {
        imageElement = ImageElement(
            url: url is Blob ? "" : url,
            data: image,
            width: image.width!.toDouble(),
            height: image.height!.toDouble());
      } else {
        image = image as Image;
        //print("nnnn"+image.toString());
        image = image.convert(format:Format.uint8,numChannels: 4);

        // print(" _pixels : ${_pixels.length} ");
        // print(" ------------------------------------------- ");
        imageElement = ImageElement(
            url: url,
            data: Uint8Array.from(image.getBytes()),
            width: image.width,
            height: image.height);
      }

      //Image imagei=image;
      //imagei.isNotEmpty
     //  print(" image.width: ${image.width} image.height: ${image.height} isntempty"+image.isNotEmpty.toString());//isJPEG: ${isJPEG} ");

      texture.image = imageElement;
      texture.needsUpdate = true;

      onLoad(texture);

      completer.complete(texture);
    }, onProgress, onError);

    return completer.future;
  }

  @override
  TextureLoader setPath(String path){
    super.setPath(path);
    return this;
  }
  @override
  TextureLoader setCrossOrigin(String crossOrigin) {
    super.setCrossOrigin(crossOrigin);
    return this;
  }
  @override
  TextureLoader setWithCredentials(bool value) {
    super.setWithCredentials(value);
    return this;
  }
  @override
  TextureLoader setResourcePath(String? resourcePath) {
    super.setResourcePath(resourcePath);
    return this;
  }
  @override
  TextureLoader setRequestHeader(Map<String, dynamic> requestHeader) {
    super.setRequestHeader(requestHeader);
    return this;
  }
}
