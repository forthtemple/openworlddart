#include <jni.h>
#include <android/log.h>
#include <android/native_window_jni.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <cstring>

#ifndef EGL_OPENGL_ES3_BIT_KHR
#define EGL_OPENGL_ES3_BIT_KHR 0x0040
#endif

#define LOG_TAG "angle_android_graphic_jni"
#define ALOG(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define ALOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

static EGLDisplay g_display = EGL_NO_DISPLAY;
static EGLContext g_context = EGL_NO_CONTEXT;
static EGLSurface g_pbufferSurface = EGL_NO_SURFACE;
static EGLConfig g_config = nullptr;
static char g_errorMessage[256] = {0};

static void setError(const char* err) {
    strncpy(g_errorMessage, err, sizeof(g_errorMessage) - 1);
    g_errorMessage[sizeof(g_errorMessage) - 1] = '\0';
    ALOGE("%s", err);
}

extern "C" {

JNIEXPORT jboolean JNICALL
Java_org_fluttergl_flutter_1angle_FlutterAnglePlugin_init(JNIEnv* env, jclass clazz) {
    g_display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (g_display == EGL_NO_DISPLAY) {
        setError("eglGetDisplay failed");
        return JNI_FALSE;
    }

    EGLint eglVersion[2];
    if (!eglInitialize(g_display, &eglVersion[0], &eglVersion[1])) {
        setError("eglInitialize failed");
        return JNI_FALSE;
    }

    const EGLint configAttribs[] = {
            EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT_KHR,
            EGL_RED_SIZE, 8,
            EGL_GREEN_SIZE, 8,
            EGL_BLUE_SIZE, 8,
            EGL_ALPHA_SIZE, 8,
            EGL_DEPTH_SIZE, 24,
            EGL_STENCIL_SIZE, 8,
            EGL_NONE
    };

    EGLint numConfigs;
    if (!eglChooseConfig(g_display, configAttribs, &g_config, 1, &numConfigs) || numConfigs < 1) {
        setError("Failed to choose EGL config");
        return JNI_FALSE;
    }

    const EGLint contextAttribs[] = {
            EGL_CONTEXT_CLIENT_VERSION, 3,
            EGL_NONE
    };

    g_context = eglCreateContext(g_display, g_config, EGL_NO_CONTEXT, contextAttribs);
    if (g_context == EGL_NO_CONTEXT) {
        setError("Failed to create EGL context");
        return JNI_FALSE;
    }

    const EGLint surfaceAttribs[] = {
            EGL_WIDTH, 16,
            EGL_HEIGHT, 16,
            EGL_NONE
    };

    g_pbufferSurface = eglCreatePbufferSurface(g_display, g_config, surfaceAttribs);
    if (g_pbufferSurface == EGL_NO_SURFACE) {
        setError("Failed to create EGL pbuffer surface");
        return JNI_FALSE;
    }

    if (!eglMakeCurrent(g_display, g_pbufferSurface, g_pbufferSurface, g_context)) {
        setError("eglMakeCurrent failed");
        return JNI_FALSE;
    }

    const char* glVendor = (const char*)glGetString(GL_VENDOR);
    const char* glRenderer = (const char*)glGetString(GL_RENDERER);
    const char* glVersion = (const char*)glGetString(GL_VERSION);
    ALOG("OpenGL initialized: Vendor=%s, Renderer=%s, Version=%s",
         glVendor, glRenderer, glVersion);

    return JNI_TRUE;
}

JNIEXPORT void JNICALL
Java_org_fluttergl_flutter_1angle_FlutterAnglePlugin_deinit(JNIEnv* env, jclass clazz) {
    if (g_display != EGL_NO_DISPLAY) {
        eglMakeCurrent(g_display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (g_pbufferSurface != EGL_NO_SURFACE) {
            eglDestroySurface(g_display, g_pbufferSurface);
            g_pbufferSurface = EGL_NO_SURFACE;
        }
        if (g_context != EGL_NO_CONTEXT) {
            eglDestroyContext(g_display, g_context);
            g_context = EGL_NO_CONTEXT;
        }
        eglTerminate(g_display);
        g_display = EGL_NO_DISPLAY;
        ALOG("OpenGL deinitialized successfully");
    }
}

JNIEXPORT jstring JNICALL
Java_org_fluttergl_flutter_1angle_FlutterAnglePlugin_getError(JNIEnv* env, jclass clazz) {
    return env->NewStringUTF(g_errorMessage);
}

JNIEXPORT jlong JNICALL
Java_org_fluttergl_flutter_1angle_FlutterAnglePlugin_getCurrentContext(JNIEnv* env, jclass clazz) {
    return reinterpret_cast<jlong>(eglGetCurrentContext());
}

JNIEXPORT jlong JNICALL
Java_org_fluttergl_flutter_1angle_FlutterAnglePlugin_createWindowSurfaceFromTexture(JNIEnv* env, jclass clazz, jobject surfaceTexture) {
    if (g_display == EGL_NO_DISPLAY || !g_config) {
        setError("EGL not initialized");
        return 0;
    }

    // Create Surface from SurfaceTexture
    jclass surfaceClass = env->FindClass("android/view/Surface");
    if (!surfaceClass) {
        setError("Failed to find Surface class");
        return 0;
    }

    jmethodID surfaceConstructor = env->GetMethodID(surfaceClass, "<init>", "(Landroid/graphics/SurfaceTexture;)V");
    if (!surfaceConstructor) {
        setError("Failed to find Surface constructor");
        return 0;
    }

    jobject surface = env->NewObject(surfaceClass, surfaceConstructor, surfaceTexture);
    if (!surface) {
        setError("Failed to create Surface");
        return 0;
    }

    // Create the EGL surface
    ANativeWindow* window = ANativeWindow_fromSurface(env, surface);
    if (!window) {
        setError("Failed to get native window");
        env->DeleteLocalRef(surface);
        env->DeleteLocalRef(surfaceClass);
        return 0;
    }

    const EGLint attribs[] = { EGL_NONE };
    EGLSurface eglSurface = eglCreateWindowSurface(g_display, g_config, window, attribs);
    ANativeWindow_release(window);

    // Clean up Java objects
    env->DeleteLocalRef(surface);
    env->DeleteLocalRef(surfaceClass);

    if (eglSurface == EGL_NO_SURFACE) {
        setError("Failed to create window surface");
        return 0;
    }

    ALOG("Created window surface from texture: %p", eglSurface);
    return reinterpret_cast<jlong>(eglSurface);
}

// Add new method to create window surface directly from Surface object
JNIEXPORT jlong JNICALL
Java_org_fluttergl_flutter_1angle_FlutterAnglePlugin_createWindowSurfaceFromSurface(JNIEnv* env, jclass clazz, jobject surface) {
    if (g_display == EGL_NO_DISPLAY || !g_config) {
        setError("EGL not initialized");
        return 0;
    }

    // Create the EGL surface directly from Surface
    ANativeWindow* window = ANativeWindow_fromSurface(env, surface);
    if (!window) {
        setError("Failed to get native window from Surface");
        return 0;
    }

    const EGLint attribs[] = { EGL_NONE };
    EGLSurface eglSurface = eglCreateWindowSurface(g_display, g_config, window, attribs);
    ANativeWindow_release(window);

    if (eglSurface == EGL_NO_SURFACE) {
        setError("Failed to create window surface from Surface");
        return 0;
    }

    ALOG("Created window surface from Surface: %p", eglSurface);
    return reinterpret_cast<jlong>(eglSurface);
}

} // extern "C"