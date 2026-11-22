#include "include/opengl_renderer.h"
#include "include/fl_angle_texture_gl.h"
#include <flutter_linux/fl_texture_registrar.h>

OpenglRenderer::OpenglRenderer(
  FlTextureRegistrar* textureRegistrar,
  GdkGLContext* context,
  int width, 
  int height
){
  printf(".... OpenglRenderer create\n");
  this->textureRegistrar = textureRegistrar;
  this->context = context;
  this->width = width;
  this->height = height;

  changeSize(width, height);
}

FlValue *OpenglRenderer::createTexture() {
  g_autoptr(FlValue) value = fl_value_new_map ();
  fl_value_set_string_take(value, "textureId", fl_value_new_int(textureId));
  fl_value_set_string_take(value, "openglTexture", fl_value_new_int((int64_t)texId));
  return fl_value_ref(value);
}

void OpenglRenderer::changeSize(int width, int height) {
  this->width = width;
  this->height = height;

  if(texId != 0){
    dispose(false);
  }

  glGenTextures(1, &texId);
  glBindTexture(GL_TEXTURE_2D, texId);

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  auto ft = fl_angle_texture_gl_new(GL_TEXTURE_2D, texId, width, height);
  std::cerr << "Create Texture" <<std::endl;
  texture = FL_TEXTURE(ft);
  fl_texture_registrar_register_texture(textureRegistrar, texture);
  if(textureId == 0){
    textureId = fl_texture_get_id(texture);
  }
}

void OpenglRenderer::updateTexture() {
  fl_texture_registrar_mark_texture_frame_available(textureRegistrar,texture);
}

void OpenglRenderer::dispose(bool release_context) {
  std::cerr << "Disposed of and deleted everything." << std::endl;
  glDeleteTextures(1, &texId);
  texId = 0;
  if(release_context){
    fl_texture_registrar_unregister_texture(textureRegistrar,texture);
    gdk_gl_context_clear_current();
    textureId = 0;
    g_object_unref(context);
  }
}

OpenglRenderer::~OpenglRenderer() {
  //dispose(true);
}

// Move constructor definition
OpenglRenderer::OpenglRenderer(OpenglRenderer&& other) noexcept: 
  textureRegistrar(exchange(other.textureRegistrar, nullptr)), // Transfer ownership and nullify other's pointer
  context(exchange(other.context, nullptr)),
  width(exchange(other.width, 0)), // Simple members can be just exchanged or copied, depending on semantics
  height(exchange(other.height, 0)),
  textureId(exchange(other.textureId, 0)),
  texId(exchange(other.texId, 0)),
  texture(exchange(other.texture, nullptr)
){
    // Optionally, if there are more complex resources, perform shallow copy or move operations
    // For example, if you have std::vector<...> members, you would use std::move to transfer their contents
}


// Move assignment operator definition
OpenglRenderer& OpenglRenderer::operator=(OpenglRenderer&& other) noexcept {
  if (this != &other) { // Handle self-assignment
    // Release existing resources before stealing from other
    this->~OpenglRenderer(); // Call destructor to release resources

    // Transfer resources
    textureRegistrar = exchange(other.textureRegistrar, nullptr);
    context = exchange(other.context, nullptr);
    width = exchange(other.width, 0);
    height = exchange(other.height, 0);
    textureId = exchange(other.textureId, 0);
    texId = exchange(other.texId, 0);
    texture = exchange(other.texture, nullptr);
  }
  return *this;
}

// Helper swap function (useful for copy-and-swap idiom for copy assignment, though not strictly needed here)
void OpenglRenderer::swap(OpenglRenderer& other) noexcept {
  using std::swap;
  swap(textureRegistrar, other.textureRegistrar);
  swap(context, other.context);
  swap(width, other.width);
  swap(height, other.height);
  swap(textureId, other.textureId);
  swap(texId, other.texId);
  swap(texture, other.texture);
}