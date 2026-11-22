package org.fluttergl.flutter_angle;

import android.graphics.SurfaceTexture;
import android.opengl.EGL14;
import android.opengl.EGLObjectHandle;
import android.opengl.EGLSurface;
import android.os.Build;
import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.view.TextureRegistry;

import android.graphics.SurfaceTexture;
import android.opengl.EGL14;
import android.opengl.EGL15;
import android.opengl.EGLConfig;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLObjectHandle;
import android.opengl.EGLSurface;
import android.opengl.GLES30;
import android.os.Build;
import android.util.Log;
import android.view.Surface;

import java.util.HashMap;
import java.util.Map;

import static android.opengl.EGL14.EGL_ALPHA_SIZE;
import static android.opengl.EGL14.EGL_BLUE_SIZE;
import static android.opengl.EGL14.EGL_CONTEXT_CLIENT_VERSION;
import static android.opengl.EGL14.EGL_DEFAULT_DISPLAY;
import static android.opengl.EGL14.EGL_DEPTH_SIZE;
import static android.opengl.EGL14.EGL_GREEN_SIZE;
import static android.opengl.EGL14.EGL_HEIGHT;
import static android.opengl.EGL14.EGL_NONE;
import static android.opengl.EGL14.EGL_NO_CONTEXT;
import static android.opengl.EGL14.EGL_NO_SURFACE;
import static android.opengl.EGL14.EGL_RED_SIZE;
import static android.opengl.EGL14.EGL_RENDERABLE_TYPE;
import static android.opengl.EGL14.EGL_WIDTH;
import static android.opengl.EGL14.eglCreateWindowSurface;
import static android.opengl.EGL14.eglMakeCurrent;
import static android.opengl.EGL15.EGL_OPENGL_ES3_BIT;
import static android.opengl.EGL15.EGL_PLATFORM_ANDROID_KHR;
import static android.opengl.EGLExt.EGL_OPENGL_ES3_BIT_KHR;
import static android.opengl.GLES20.GL_NO_ERROR;
import static android.opengl.GLES20.GL_RENDERER;
import static android.opengl.GLES20.GL_VENDOR;
import static android.opengl.GLES20.GL_VERSION;
import static android.opengl.GLES20.glGetError;

class AngleCheck {
  public static boolean isEmulator() {
    Log.i("FlutterAnglePlugin", "Using Android Virtual Device.");
    return (Build.FINGERPRINT.startsWith("generic")
      || Build.FINGERPRINT.contains("vbox")
      || Build.FINGERPRINT.contains("sdk_gphone")
      || Build.PRODUCT.contains("sdk")
      || Build.PRODUCT.contains("emulator")
      || Build.PRODUCT.contains("google_sdk")
      || Build.HARDWARE.contains("goldfish")
      || Build.HARDWARE.contains("ranchu")
      || Build.MANUFACTURER.contains("Genymotion")
      || Build.MANUFACTURER.contains("Google")
      || Build.MODEL.contains("google_sdk")
      || Build.MODEL.contains("Emulator")
    );
  }

  public static boolean isVersionAllowed() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
      Log.i("FlutterAnglePlugin", "Android version is lower than 28.");
      return false;
    }

    Log.i("FlutterAnglePlugin", "Android version is greater than or equal to 28.");
    return true;
  }

  public static boolean isAllowed() {
    if (!isVersionAllowed() || isBlacklistedForAngle()) {
      return false;
    } 
    return true;
  }
  
  /*

  public static boolean isBlacklistedForAngle() {
    String m = Build.MANUFACTURER != null ? Build.MANUFACTURER.toLowerCase() : "";
    String b = Build.BRAND != null ? Build.BRAND.toLowerCase() : "";
    String d = Build.DEVICE != null ? Build.DEVICE.toLowerCase() : "";

    return m.contains("huawei") || b.contains("huawei") || b.contains("honor")|| b.contains("oppo");  //claude suggested oppo
  }*/
  
  // this is the function recommended by claude to solve issue of animations not working on oppo
  public static boolean isBlacklistedForAngle() {
    String m = Build.MANUFACTURER != null ? Build.MANUFACTURER.toLowerCase() : "";
    String b = Build.BRAND != null ? Build.BRAND.toLowerCase() : "";
    String h = Build.HARDWARE != null ? Build.HARDWARE.toLowerCase() : "";
    String board = Build.BOARD != null ? Build.BOARD.toLowerCase() : "";

    boolean huawei = m.contains("huawei") || b.contains("huawei") || b.contains("honor");

    // Qualcomm Snapdragon (Adreno GPU): skinned animations freeze under ANGLE/Vulkan
    boolean qualcomm = h.contains("qcom") || board.contains("qcom");
    if (Build.VERSION.SDK_INT >= 31 && Build.SOC_MANUFACTURER != null) {
      String soc = Build.SOC_MANUFACTURER.toLowerCase();
      qualcomm = qualcomm || soc.contains("qti") || soc.contains("qualcomm");
    }

    return huawei || qualcomm;
  }
}

class OpenGLException extends Throwable {
  int error;
  String message;

  OpenGLException(String message, int error) {
    this.error = error;
    this.message = message;
  }
}

@RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
class MyEGLContext extends EGLObjectHandle {
  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  MyEGLContext(long handle) {
    super(handle);
  }
}

/** FlutterAnglePlugin */
public class FlutterAnglePlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private OpenGLManager openGLManager = null;
  private TextureRegistry textureRegistry;
  
  private Map<Long, FlutterGLTexture> flutterTextureMap;
  private static final String TAG = "FlutterAnglePlugin";

  // Load ANGLE native libraries (used by ANGLE methods)
  static {
    try {
      System.loadLibrary("EGL_angle");
      System.loadLibrary("GLESv2_angle");
      System.loadLibrary("angle_android_graphic_jni");
      Log.i(TAG, "Native ANGLE libraries loaded successfully");
    } catch (UnsatisfiedLinkError e) {
      Log.e(TAG, "Failed to load native ANGLE libraries", e);
    }
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
    channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_angle");
    channel.setMethodCallHandler(this);
    textureRegistry = binding.getTextureRegistry();
    flutterTextureMap = new HashMap<>();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + Build.VERSION.RELEASE);
        break;
      // Plugin1 methods (non‑ANGLE)
      case "initOpenGL":
        initOpenGLImplementation(result);
        break;
      case "createTexture":
        createTextureImplementation(call, result);
        break;
      // Plugin2 methods (ANGLE) – note the "Angle" suffix
      case "initOpenGLAngle":
        if(AngleCheck.isAllowed()){
          initOpenGLAngleImplementation(result);
        }
        else{
          initOpenGLImplementation(result);
        }
        break;
      case "createTextureAngle":
        if(AngleCheck.isAllowed()){
          createTextureAngleImplementation(call, result);
        }
        else{
          createTextureImplementation(call, result);
        }
        break;
      case "resizeTexture":
        changeSize(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  private void initOpenGLImplementation(MethodChannel.Result result) {
    // Plugin1: using OpenGLManager
    openGLManager = (openGLManager == null) ? new OpenGLManager() : openGLManager;
    if (!openGLManager.initGL()) {
      result.error("OpenGL Init Error", openGLManager.getError(), null);
      return;
    }

    long dummySurface = openGLManager.createDummySurface().getNativeHandle();

    Map<String, Object> response = new HashMap<>();
    response.put("context", openGLManager.getEGLContext().getNativeHandle());
    response.put("eglConfigId", openGLManager.getConfigId());
    response.put("dummySurface", dummySurface);
    response.put("forceOpengl", !AngleCheck.isAllowed());
    result.success(response);
  }

  private void createTextureImplementation(MethodCall call, MethodChannel.Result result) {
    // Plugin1: create texture using FlutterGLTexture
    Map<String, Object> arguments = (Map<String, Object>) call.arguments;
    int width = (int) arguments.get("width");
    int height = (int) arguments.get("height");
    boolean useSurfaceProducer = (boolean) arguments.get("useSurfaceProducer");

    if (width <= 0) {
      result.error("no texture width", "no texture width", 0);
      return;
    }
    if (height <= 0) {
      result.error("no texture height", "no texture height", null);
      return;
    }
    FlutterGLTexture texture;
        
    try {
      if (useSurfaceProducer) {
        // Use the new API
        TextureRegistry.SurfaceProducer producer = textureRegistry.createSurfaceProducer();
        texture = new FlutterGLTexture(producer, openGLManager, width, height);
        Log.i(TAG, "Created texture using SurfaceProducer API");
      } 
      else {
        // Fall back to the old API
        TextureRegistry.SurfaceTextureEntry surfaceTextureEntry = textureRegistry.createSurfaceTexture();
        texture = new FlutterGLTexture(surfaceTextureEntry, openGLManager, width, height);
        Log.i(TAG, "Created texture using SurfaceTextureEntry API (legacy)");
      }
    } catch (Exception ex) {
      result.error(ex.getMessage() + " : " + ex.toString(), null, null);
      return;
    }
    flutterTextureMap.put(texture.getTextureId(), texture);
    Map<String, Object> response = new HashMap<>();
    response.put("textureId", texture.getTextureId());
    response.put("surface", texture.surface.getNativeHandle());
    result.success(response);

    Log.i(TAG, "Created a new texture " + width + "x" + height);
  }

  private void changeSize(MethodCall call, MethodChannel.Result result){
    Map<String, Object> arguments = (Map<String, Object>) call.arguments;
    int width = (int) arguments.get("width");
    int height = (int) arguments.get("height");
    int textureId = (int) arguments.get("textureId");
    
    if (width <= 0) {
      result.error("no texture width", "no texture width", 0);
      return;
    }
    if (height <= 0) {
      result.error("no texture height", "no texture height", null);
      return;
    }
    if (textureId <= 0) {
      result.error("no texture textureId", "no texture textureId", null);
      return;
    }

    Long id = Long.valueOf(textureId);
    flutterTextureMap.get(id).resize(width,height);
  }

  // ANGLE (plugin2) methods: renamed with 'Angle'
  private void initOpenGLAngleImplementation(MethodChannel.Result result) {
    // Plugin2: using native ANGLE functions
    if (!init()) {
      String error = getError();
      Log.e(TAG, "ANGLE init failed: " + error);
      result.error("OpenGL Init Error", error, null);
      return;
    }

    Map<String, Object> response = new HashMap<>();
    response.put("forceOpengl", !AngleCheck.isAllowed());
    result.success(response);

    Log.i(TAG, "ANGLE OpenGL initialized successfully");
  }

  private void createTextureAngleImplementation(MethodCall call, MethodChannel.Result result) {
    try {
      @SuppressWarnings("unchecked")
      Map<String, Object> args = (Map<String, Object>) call.arguments;
      int width = (int) args.get("width");
      int height = (int) args.get("height");
      boolean useSurfaceProducer = (boolean) args.get("useSurfaceProducer");

      if (width <= 0 || height <= 0) {
        result.error("Invalid dimensions", "Width and height must be positive", null);
        return;
      }
      
      FlutterGLTexture texture;
      if (useSurfaceProducer) {
        try {
          // Use the new API
          TextureRegistry.SurfaceProducer producer = textureRegistry.createSurfaceProducer();
          producer.setSize(width, height);
          texture = new FlutterGLTexture(producer);
          Log.i(TAG, "Created ANGLE texture using SurfaceProducer API");
        } catch (Exception e) {
          // Fall back to old API if SurfaceProducer fails
          Log.w(TAG, "SurfaceProducer failed, falling back to SurfaceTextureEntry", e);
          TextureRegistry.SurfaceTextureEntry entry = textureRegistry.createSurfaceTexture();
          texture = new FlutterGLTexture(entry, width, height);
          Log.i(TAG, "Created ANGLE texture using SurfaceTextureEntry API (fallback)");
        }
      } else {
        // Explicitly use old API
        TextureRegistry.SurfaceTextureEntry entry = textureRegistry.createSurfaceTexture();
        texture = new FlutterGLTexture(entry, width, height);
        Log.i(TAG, "Created ANGLE texture using SurfaceTextureEntry API (legacy)");
      }
      
      flutterTextureMap.put(texture.getTextureId(), texture);

      Map<String, Object> response = new HashMap<>();
      response.put("textureId", texture.getTextureId());
      response.put("surface", texture.surfaceHandle);
      result.success(response);

      Log.i(TAG, String.format("Created ANGLE texture %dx%d", width, height));
    } catch (Exception e) {
      Log.e(TAG, "ANGLE texture creation failed", e);
      result.error("Texture creation failed", e.getMessage(), null);
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    // Dispose Plugin1 textures
    for (FlutterGLTexture texture : flutterTextureMap.values()) {
      try {
        texture.finalize();
      } catch (Throwable e) {
        Log.e(TAG, "Error disposing Flutter texture", e);
      }
    }
    flutterTextureMap.clear();

    try {
      // Deinitialize native ANGLE resources
      deinit();
    }
    catch (UnsatisfiedLinkError e) {
      Log.e(TAG, "Error deinitializing native ANGLE resources", e);
    }
    catch (Throwable t) {
      Log.e(TAG, "General exception in deinit()", t);
    }
  }

  // --- Native methods (used for ANGLE calls) ---
  private static native boolean init();
  private static native void deinit();
  private static native String getError();
  private static native long getCurrentContext();
  private static native long createWindowSurfaceFromTexture(SurfaceTexture texture);
  private static native long createWindowSurfaceFromSurface(Surface surface);

  private static class FlutterGLTexture {
    //final TextureRegistry textureRegistry;
    final OpenGLManager openGLManager;

    int width;
    int height;

    EGLSurface surface;
    public final TextureRegistry.SurfaceTextureEntry surfaceTextureEntry;
    public final TextureRegistry.SurfaceProducer surfaceProducer;
    public final boolean usingSurfaceProducer;

    private boolean disposed = false;
    final long surfaceHandle;

    public FlutterGLTexture(
      TextureRegistry.SurfaceTextureEntry textureEntry, 
      OpenGLManager openGLManager, 
      int width,
      int height
    ) {
      this.width = width;
      this.height = height;
      this.openGLManager = openGLManager;
      this.usingSurfaceProducer = false;
      this.surfaceTextureEntry = textureEntry;
      this.surfaceProducer = null;
      this.surfaceHandle = 0;
      surfaceTextureEntry.surfaceTexture().setDefaultBufferSize(width, height);
      surface = openGLManager.createSurfaceFromTexture(surfaceTextureEntry.surfaceTexture());
    }

    public FlutterGLTexture(
      TextureRegistry.SurfaceProducer surfaceProducer, 
      OpenGLManager openGLManager, 
      int width,
      int height
    ) {
      this.width = width;
      this.height = height;
      this.openGLManager = openGLManager;
      this.usingSurfaceProducer = true;
      this.surfaceTextureEntry = null;
      this.surfaceHandle = 0;
      this.surfaceProducer = surfaceProducer;
      surfaceProducer.setSize(width, height);
      surface = openGLManager.createSurfaceFromSurface(surfaceProducer.getSurface());
    }

    public FlutterGLTexture(
      TextureRegistry.SurfaceTextureEntry entry, 
      int width, 
      int height
    ) {
      this.surfaceTextureEntry = entry;
      this.surfaceProducer = null;
      this.openGLManager = null;
      this.usingSurfaceProducer = false;
      this.width = width;
      this.height = height;
      surfaceTextureEntry.surfaceTexture().setDefaultBufferSize(width, height);
      this.surfaceHandle = createWindowSurfaceFromTexture(surfaceTextureEntry.surfaceTexture());
      if (this.surfaceHandle == 0) {
        throw new RuntimeException("Failed to create EGL surface: " + getError());
      }
    }
      
    public FlutterGLTexture(
      TextureRegistry.SurfaceProducer producer
    ) {
      this.surfaceProducer = producer;
      this.surfaceTextureEntry = null;
      this.openGLManager = null;
      this.usingSurfaceProducer = true;
      this.width = surfaceProducer.getWidth();
      this.height = surfaceProducer.getHeight();
      this.surfaceHandle = createWindowSurfaceFromSurface(surfaceProducer.getSurface());
      if (this.surfaceHandle == 0) {
        throw new RuntimeException("Failed to create EGL surface: " + getError());
      }
    }

    protected void resize(int width,int height) {
      // if (usingSurfaceProducer && surfaceProducer != null) {
      //   surfaceProducer.setSize(width, height);
      // } 
      // else if (surfaceTextureEntry != null) {
      //   surfaceTextureEntry.surfaceTexture().setDefaultBufferSize(width, height);
      // }
    }
    
    protected void dispose() {
      if (!disposed) {
        if (usingSurfaceProducer && surfaceProducer != null) {
          surfaceProducer.release();
        } else if (surfaceTextureEntry != null) {
          surfaceTextureEntry.release();
        }

        if(openGLManager != null){
          EGLDisplay dis = openGLManager.getEglDisplayAndroid();
          EGL14.eglMakeCurrent(dis, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT);
          EGL14.eglDestroySurface(dis, surface);
          openGLManager.deinitGL();
        }
        disposed = true;
      }
    }

    @Override
    protected void finalize() throws Throwable {
      dispose();
      super.finalize();
    }

    public long getTextureId() {
      return usingSurfaceProducer ? surfaceProducer.id() : surfaceTextureEntry.id();
    }
  }
}
