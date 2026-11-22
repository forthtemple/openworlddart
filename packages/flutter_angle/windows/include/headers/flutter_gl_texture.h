#ifndef FLUTTER_GL_TEXTURE_H_
#define FLUTTER_GL_TEXTURE_H_

#include "include/flutter_angle/flutter_angle_plugin.h"
#include "include/gl32.h"
#include "include/egl.h"

#include <d3d.h>
#include <d3d11.h>
#include <Windows.h>
#include <wrl.h>

#include <cstdint>
#include <functional>

#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>

#if defined(__cplusplus)
extern "C" {
#endif

struct TextureInfo {
    uint32_t rboId = 0;
    uint32_t fboId = 0;
    uint32_t wTextureId = 0;
    EGLSurface surface;
    int frameCount;
};

struct EGLInfo {
    EGLDisplay eglDisplay;
    EGLContext eglContext;
    EGLConfig eglConfig;
};

struct Structure{
    int width;
    int height;
    bool useBuffer;
};

class FlutterGLTexture{
    public:
        FlutterGLTexture(
            flutter::TextureRegistrar* textureRegistrar, 
            EGLInfo info,
            Structure structure
        );
        virtual ~FlutterGLTexture();

        static EGLInfo initOpenGL(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result);
        void createTexture(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result);
        void textureFrameAvailable(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result);
        void changeSize(int, int, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result);

        int64_t textureId;
        
    private:
        void createANGLETexture();
        void cleanUp(bool release_context);
        bool createD3DTexture();
        void setupOpenGLResources();
        const FlutterDesktopPixelBuffer *copyPixelBuffer();


        ID3D11Device* getANGLED3DDevice();
        EGLInfo eglInfo = EGLInfo();
        Structure structure;
        bool didStart = false;
        
        flutter::TextureRegistrar* textureRegistrar;
        std::unique_ptr<flutter::TextureVariant> flutterTexture;
        
        //Buffer
        std::unique_ptr<uint8_t> pixels;
        TextureInfo textures = TextureInfo();
        std::unique_ptr<FlutterDesktopPixelBuffer> pixelBuffer;
        
        // Surface
        HANDLE surfaceHandle = nullptr;
        std::unique_ptr<FlutterDesktopGpuSurfaceDescriptor> gpuTexture;
        ID3D11Device* d3d_11_device = nullptr;
        ID3D11DeviceContext* d3d_11_device_context = nullptr;
        Microsoft::WRL::ComPtr<ID3D11Texture2D> d3d_11_texture_2D;
};

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_GL_TEXTURE_H_