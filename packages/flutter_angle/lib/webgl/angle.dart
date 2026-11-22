import 'dart:js_interop';

import '../shared/render_worker.dart';
import '../shared/classes.dart';
import '../shared/options.dart';
import 'dart:async';
import 'package:web/web.dart' as html;
import 'wrapper_wasm.dart';
import 'gles_bindings.dart';
import 'dart:ui_web' as ui;

class FlutterAngleTexture {
  final int textureId;
  late final int rboId;
  late final dynamic surfaceId;
  late final int fboId;
  late AngleOptions options;
  LibOpenGLES? _libOpenGLES;
  
  
  FlutterAngleTexture(
    FlutterAngle flutterAngle,
    this.textureId, 
    this.rboId, 
    this.fboId,
    this.options
  ){}

  FlutterAngleTexture.fromSurface(
    FlutterAngle flutterAngle,
    this.textureId,
    this.surfaceId,
    this.options
  ) {
    rboId = 0;
    fboId = 0;
  }

  LibOpenGLES get rawOpenGl {
    if (_libOpenGLES == null) {
      final rc = RenderingContext.createCanvas(
        surfaceId,
        {
          "alpha": options.alpha, 
          "antialias": options.antialias
        }.jsify()
      );
      _libOpenGLES = LibOpenGLES(rc);
    }

    return _libOpenGLES!;
  }

  Map<String, int> toMap() {
    return {
      'textureId': textureId,
      'rbo': rboId,
    };
  }

  /// Whenever you finished your rendering you have to call this function to signal
  /// the Flutterengine that it can display the rendering
  /// Despite this being an asyc function it probably doesn't make sense to await it
  Future<void> signalNewFrameAvailable() async {}

  /// As you can have multiple Texture objects, but WebGL allways draws in the currently
  /// active one you have to call this function if you use more than one Textureobject before
  /// you can start rendering on it. If you forget it you will render into the wrong Texture.
  void activate() {}
  RenderingContext getContext() {
    return RenderingContext.create(rawOpenGl,options.width, options.height);
  }
}

class FlutterAngle{
  RenderWorker? _worker;

  static void glDebugOutput(
    int source, 
    int type, 
    int id, 
    int severity,
    int length, 
    String pMessage, 
    int pUserParam
  ) {}

  Future<FlutterAngleTexture> createTexture(AngleOptions options) async {
    final _divId = DateTime.now().microsecondsSinceEpoch;
    final String id = 'canvas-id$_divId';
    final width = (options.width * options.dpr).toInt();
    final height = (options.height * options.dpr).toInt();

    late final newTexture;
    
    final element = html.HTMLCanvasElement()
    ..width = width
    ..height = height
    ..id = id;

    ui.platformViewRegistry.registerViewFactory(_divId.toString(), (int viewId) {
      return element;
    });

    newTexture = FlutterAngleTexture.fromSurface(
      this,
      _divId,
      element, 
      options
    );

    if (!options.customRenderer) {
      _worker = RenderWorker(newTexture);
    }

    return newTexture;
  }

  Future<void> init([bool useDebugContext = false, bool useAngle = false]) async {}
  void updateSource(FlutterAngleTexture texture, [WebGLTexture? sourceTexture]) async {
    if (sourceTexture != null) {
      texture.rawOpenGl.glClearColor(0.0, 0.0, 0.0, 0.0);
      texture.rawOpenGl.glClear(16384 | 256 | 1024);
      texture.rawOpenGl.glViewport(0, 0, (texture.options.width*texture.options.dpr).toInt(),( texture.options.height*texture.options.dpr).toInt());
      _worker?.renderTexture(sourceTexture,isFBO: true);
      texture.rawOpenGl.glFinish();
    }
  }
  Future<void> updateTexture(FlutterAngleTexture texture, [WebGLTexture? sourceTexture]) async {
    updateSource(texture,sourceTexture);
    if (sourceTexture == null) {
      texture.rawOpenGl.glFlush();
    }
  }
  Future<void> resize(FlutterAngleTexture texture, AngleOptions options) async{
    texture.surfaceId?.width = (options.width * options.dpr).toInt();
    texture.surfaceId?.height = (options.height * options.dpr).toInt();
  }
  Future<void> deleteTexture(FlutterAngleTexture texture) async {}
  void activateTexture(FlutterAngleTexture texture) {}
  void printOpenGLError(String message) {}
  void dispose([List<FlutterAngleTexture?>? textures]){
    _worker?.dispose();
    _worker = null;
  }
}