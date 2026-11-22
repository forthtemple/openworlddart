#define EGL_EGLEXT_PROTOTYPES
#define GL_GLEXT_PROTOTYPES

#include "include/headers/flutter_gl_texture.h"
#include "include/gl2ext.h"
#include "include/eglext.h"
#include "include/eglext_angle.h"

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>

#include "include/headers/opengl_exception.h"
#include "include/headers/flutter_gl_texture.h"

#include <map>
#include <memory>
#include <sstream>
#include <thread>
#include <iostream>

#define FAIL(message)                                                 \
  std::cout << "media_kit: ANGLESurfaceManager: Failure: " << message \
            << std::endl;                                             \
  return false

#define CHECK_HRESULT(message) \
  if (FAILED(hr)) {            \
    FAIL(message);             \
  }


FlutterGLTexture::FlutterGLTexture(
    flutter::TextureRegistrar* textureRegistrar, 
    EGLInfo info,
    Structure st
){
  eglInfo.eglDisplay = info.eglDisplay;
  eglInfo.eglContext = info.eglContext;
  eglInfo.eglConfig = info.eglConfig;

  structure.width = st.width;
  structure.height = st.height;
  structure.useBuffer = st.useBuffer;

  this->textureRegistrar = textureRegistrar;

  if(structure.useBuffer){
    flutterTexture = std::make_unique<flutter::TextureVariant>(flutter::PixelBufferTexture(
        [this](size_t width, size_t height) -> const FlutterDesktopPixelBuffer* {
        return copyPixelBuffer();
    }));
  }
  else{
    createANGLETexture();
    
    gpuTexture = std::make_unique<FlutterDesktopGpuSurfaceDescriptor>();
    gpuTexture->struct_size = sizeof(FlutterDesktopGpuSurfaceDescriptor);
    gpuTexture->handle = surfaceHandle;
    gpuTexture->width = gpuTexture->visible_width = structure.width;
    gpuTexture->height = gpuTexture->visible_height = structure.height;
    gpuTexture->release_context = nullptr;
    gpuTexture->release_callback = [](void* release_context) {};
    gpuTexture->format = kFlutterDesktopPixelFormatBGRA8888;

    flutterTexture = std::make_unique<flutter::TextureVariant>(flutter::GpuSurfaceTexture(
        kFlutterDesktopGpuSurfaceTypeDxgiSharedHandle,
        [&](auto, auto) { return gpuTexture.get(); }
    ));
  }

  textureId = textureRegistrar->RegisterTexture(flutterTexture.get());
}

EGLInfo FlutterGLTexture::initOpenGL(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result){
    auto display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    EGLint major;
    EGLint minor;
    auto initializeResult = eglInitialize(display,&major,&minor);
    if (initializeResult != 1){
        result->Error("EGL InitError", "eglInit failed");
        return EGLInfo();
    }

    std::cerr << "EGL version in native plugin" << major << "." << minor << std::endl;
    
    const EGLint attribute_list[] = {
        EGL_RENDERABLE_TYPE,
        EGL_OPENGL_ES3_BIT,
        EGL_RED_SIZE, 8,
        EGL_GREEN_SIZE, 8,
        EGL_BLUE_SIZE, 8,
        EGL_ALPHA_SIZE, 8,
        EGL_DEPTH_SIZE, 24,
        EGL_STENCIL_SIZE, 8,
        EGL_NONE
    };

    EGLint num_config;
    EGLConfig config;
    auto chooseConfigResult = eglChooseConfig(display,attribute_list,&config,1,&num_config);
    if (chooseConfigResult != 1){
        result->Error("EGL InitError", "eglChooseConfig failed");
        return EGLInfo();
    }

    EGLint configId;
    eglGetConfigAttrib(display,config,EGL_CONFIG_ID,&configId);

    const EGLint contextAttributes[] ={
      EGL_CONTEXT_CLIENT_VERSION, 3,
      EGL_NONE
    };
    const EGLContext context = eglCreateContext(display,config,EGL_NO_CONTEXT,contextAttributes);
    
    eglMakeCurrent(display, EGL_NO_SURFACE, EGL_NO_SURFACE, context);

    auto v = glGetString(GL_VENDOR);
    int error = glGetError();
    if (error != GL_NO_ERROR){
        std::cerr << "GlError" << error << std::endl;
    }    
    auto r = glGetString(GL_RENDERER);
    auto v2 = glGetString(GL_VERSION);

    std::cerr << v << std::endl << r << std::endl << v2 << std::endl;

    /// we send back the context so that the Dart side can create a linked context. 
    auto response = flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("context"),
        flutter::EncodableValue((int64_t) context)},
        {flutter::EncodableValue("eglConfigId"),
        flutter::EncodableValue((int64_t) configId)}
    });
    result->Success(response);

    EGLInfo returnInfo;
    returnInfo.eglDisplay = display;
    returnInfo.eglContext = context;
    returnInfo.eglConfig = config;

    return returnInfo;
}

void FlutterGLTexture::changeSize(int setWidth, int setHeight, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result) {
  if (setWidth == structure.width && setHeight == structure.height && didStart) {
    return;
  }
  if(structure.useBuffer){
    int64_t size = setWidth * setHeight * 4;
    pixels.reset(new uint8_t[size]);

    pixelBuffer->buffer = pixels.get();
    pixelBuffer->width = setWidth;
    pixelBuffer->height = setHeight;
    memset(pixels.get(), 0x00, size);
    if(didStart){
      /// we send back the context so that the Dart side can create a linked context. 
      auto response = flutter::EncodableValue(flutter::EncodableMap{
        {flutter::EncodableValue("textureId"),
          flutter::EncodableValue(textureId)},
      });
      result->Success(response);
    }
    return;
  }

  structure.width = setWidth;
  structure.height = setHeight;

  createANGLETexture();

  gpuTexture->handle = surfaceHandle;
  gpuTexture->width = gpuTexture->visible_width = structure.width;
  gpuTexture->height = gpuTexture->visible_height = structure.height;
  
  /// we send back the context so that the Dart side can create a linked context. 
  auto response = flutter::EncodableValue(flutter::EncodableMap{
    {flutter::EncodableValue("textureId"),
      flutter::EncodableValue(textureId)},
    {flutter::EncodableValue("surfacePointer"),
    flutter::EncodableValue((int64_t)surfaceHandle)},
  });
  result->Success(response);

  return;
}

void FlutterGLTexture::createANGLETexture() {
  cleanUp(false);
  if (!createD3DTexture()) {
    throw std::runtime_error("Unable to create Windows Direct3D device.");
    return;
  }
  if (surfaceHandle == nullptr){
    throw std::runtime_error("Unable to retrieve Direct3D shared HANDLE.");
    return;
  }
}

void FlutterGLTexture::cleanUp(bool release_context) {
  if (release_context) {
    // Release D3D device & context if the instance is being destroyed.
    if(eglInfo.eglDisplay != nullptr){
      eglMakeCurrent(eglInfo.eglDisplay,EGL_NO_SURFACE,EGL_NO_SURFACE,EGL_NO_CONTEXT);
      if(eglInfo.eglConfig != nullptr){
        eglDestroyContext(eglInfo.eglDisplay, eglInfo.eglConfig);
        eglInfo.eglConfig = EGL_NO_CONTEXT;
      }
      eglTerminate(eglInfo.eglDisplay);
      std::cerr << "Terminated Display." << std::endl;
    }
    if(structure.useBuffer){
      glDeleteRenderbuffers(1, &textures.rboId);
      glDeleteFramebuffers(1, &textures.fboId);
      
      textures.rboId = 0;
      textures.fboId = 0;

      pixels.reset();
      pixelBuffer.reset();
    }else{
      CloseHandle(surfaceHandle);
    }
    if (d3d_11_device_context) {
      d3d_11_device_context->Release();
      d3d_11_device_context = nullptr;
    }
    if (d3d_11_device) {
      d3d_11_device->Release();
      d3d_11_device = nullptr;
    }
  } 
  if (d3d_11_texture_2D) {
    d3d_11_texture_2D->Release();
    d3d_11_texture_2D = nullptr;
  }
}

ID3D11Device* FlutterGLTexture::getANGLED3DDevice(){
    EGLAttrib angleDevice = 0;
    EGLAttrib device      = 0;
    
    if (eglQueryDisplayAttribEXT(eglInfo.eglDisplay, EGL_DEVICE_EXT, &angleDevice) != EGL_TRUE){
      return nullptr;
    }
    if (eglQueryDeviceAttribEXT((EGLDeviceEXT)angleDevice, EGL_D3D11_DEVICE_ANGLE, &device) != EGL_TRUE){
      return nullptr;
    }
    return reinterpret_cast<ID3D11Device*>(device);
}

bool FlutterGLTexture::createD3DTexture() {
  if(!d3d_11_device){
    d3d_11_device = getANGLED3DDevice();

    auto level = d3d_11_device->GetFeatureLevel();
    std::cout << "media_kit: FlutterGLTexture: Direct3D Feature Level: "
              << (((unsigned)level) >> 12) << "_"
              << ((((unsigned)level) >> 8) & 0xf) << std::endl;
  }

  auto d3d11_texture2D_desc = D3D11_TEXTURE2D_DESC{};
  d3d11_texture2D_desc.Width = structure.width;
  d3d11_texture2D_desc.Height = structure.height;
  d3d11_texture2D_desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
  d3d11_texture2D_desc.MipLevels = 1;
  d3d11_texture2D_desc.ArraySize = 1;
  d3d11_texture2D_desc.SampleDesc.Count = 1;
  d3d11_texture2D_desc.SampleDesc.Quality = 0;
  d3d11_texture2D_desc.Usage = D3D11_USAGE_DEFAULT;
  d3d11_texture2D_desc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
  d3d11_texture2D_desc.CPUAccessFlags = 0;
  d3d11_texture2D_desc.MiscFlags = D3D11_RESOURCE_MISC_SHARED;

  auto hr = d3d_11_device->CreateTexture2D(
    &d3d11_texture2D_desc, 
    nullptr,
    &d3d_11_texture_2D
  );

  CHECK_HRESULT("ID3D11Device::CreateTexture2D");
  auto resource = Microsoft::WRL::ComPtr<IDXGIResource>{};
  hr = d3d_11_texture_2D.As(&resource);
  CHECK_HRESULT("ID3D11Texture2D::As");
  // Retrieve the shared |HANDLE| for interop.
  hr = resource->GetSharedHandle(&surfaceHandle);
  CHECK_HRESULT("IDXGIResource::GetSharedHandle");
  d3d_11_texture_2D->AddRef();

  return true;
}

void FlutterGLTexture::setupOpenGLResources(){
  uint32_t fbo = 0;
  glGenFramebuffers(1, &fbo);
  glBindFramebuffer(GL_FRAMEBUFFER, fbo);

  uint32_t rbo = 0;
  glGenRenderbuffers(1, &rbo);
  glBindRenderbuffer(GL_RENDERBUFFER, rbo);  

  glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, structure.width, structure.height);
  
  auto error = glGetError();
  if (error != GL_NO_ERROR){
    std::cerr << "GlError while allocating Renderbuffer" << error << std::endl;
    throw new OpenGLException("GlError while allocating Renderbuffer", error);
  }
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER,rbo);

  auto frameBufferCheck = glCheckFramebufferStatus(GL_FRAMEBUFFER);
  if (frameBufferCheck != GL_FRAMEBUFFER_COMPLETE){
    std::cerr << "Framebuffer error" << frameBufferCheck << std::endl;
    throw new OpenGLException("Framebuffer Error while creating Texture", frameBufferCheck);
  }

  error = glGetError();
  if( error != GL_NO_ERROR){
    std::cerr << "GlError" << error << std::endl;
  }

  textures.fboId = fbo;
  textures.rboId = rbo;
}

void FlutterGLTexture::createTexture(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result){
  if(structure.useBuffer){
    pixelBuffer = std::make_unique<FlutterDesktopPixelBuffer>();
    changeSize(structure.width,structure.height,result);
    setupOpenGLResources();
  }

  didStart = true;
  
  auto response = flutter::EncodableValue(flutter::EncodableMap{
    {flutter::EncodableValue("textureId"),
    flutter::EncodableValue(textureId)},
    {flutter::EncodableValue("rbo"),
    flutter::EncodableValue((int64_t)textures.rboId)},
    {flutter::EncodableValue("surfacePointer"),
    flutter::EncodableValue((int64_t)surfaceHandle)},
  });

  result->Success(response);
  std::cerr << "Created a new texture " << structure.width << "x" << structure.height << std::endl;
}

void FlutterGLTexture::textureFrameAvailable(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>& result){
  if(structure.useBuffer){
    glBindFramebuffer(GL_FRAMEBUFFER, textures.fboId);
    glReadPixels(0, 0, (GLsizei)pixelBuffer->width, (GLsizei)pixelBuffer->height, GL_RGBA, GL_UNSIGNED_BYTE, (void*)pixelBuffer->buffer);
  }  
  textureRegistrar->MarkTextureFrameAvailable(textureId);
  result->Success();
}

FlutterGLTexture::~FlutterGLTexture() {
  cleanUp(true);
  std::cerr << "Disposed of and deleted everything." << std::endl;
  textureRegistrar->UnregisterTexture(textureId);
}

const FlutterDesktopPixelBuffer *FlutterGLTexture::copyPixelBuffer(){
  return pixelBuffer.get();
}