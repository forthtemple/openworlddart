import 'dart:isolate';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:openworld/three_dart/extra/blob.dart';

class ImageLoaderLoader {
  static Future<Image?> loadImage(url, bool flipY, {Function? imageDecoder}) async {
    final Image? image;
    if (imageDecoder == null) {
      final Uint8List? bytes;
      if (url is Blob) {
        bytes = url.data;
      } else if (url.startsWith("http")) {
        final http.Response response = await http.get(Uri.parse(url));
        bytes = response.bodyBytes;
      } else if (url.startsWith("assets") || url.startsWith("packages")) {
        final ByteData fileData = await rootBundle.load(url);
        bytes = Uint8List.view(fileData.buffer);
      } else {
        final File file = File(url);
        bytes = await file.readAsBytes();
      }

      image = await compute(imageProcess2, DecodeParam(bytes!, flipY, null));
    } else {
      image = await imageDecoder(null, url);
    }

    return image;
  }
}

class DecodeParam {
  DecodeParam(
    this.bytes, 
    this.flipY, 
    this.sendPort
  );

  Uint8List? bytes;
  bool flipY;
  SendPort? sendPort;
}

void decodeIsolate(DecodeParam param) {
  if (param.bytes == null) {
    param.sendPort?.send(null);
    return;
  }

  // Read an image from file (webp in this case).
  // decodeImage will identify the format of the image and use the appropriate
  // decoder.
  var image2 = imageProcess2(param);

  param.sendPort?.send(image2);
}

Image imageProcess2(DecodeParam param) {
  Image image = decodeImage(param.bytes!)!;

  if (param.flipY) {
    image = flipVertical(image);
  }

  return image;
}
