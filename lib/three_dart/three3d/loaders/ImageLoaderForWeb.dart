import 'dart:async';
import 'package:openworld/three_dart/extra/blob.dart';
import 'dart:html' as html;

class ImageLoaderLoader {
  // flipY
  static Future<html.ImageElement> loadImage(url, bool flipY,
      {Function? imageDecoder}) {
    var completer = Completer<html.ImageElement>();
    var imageDom = html.ImageElement();
    imageDom.crossOrigin = "";

    imageDom.onLoad.listen((e) {
      completer.complete(imageDom);
    });

    if (url is Blob) {
      var blob = html.Blob([url.data.buffer], url.options["type"]);
      imageDom.src = html.Url.createObjectUrl(blob);
    } else {
      if (url.startsWith("assets") || url.startsWith("packages")) {
        imageDom.src = "assets/" + url;
      } 
      else {
        imageDom.src = url;
      }
    }

    return completer.future;
  }
}
