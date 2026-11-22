#ifndef FL_ANGLE_TEXTURE_H
#define FL_ANGLE_TEXTURE_H

#include  "opengl_renderer.h"
#include "flutter_angle/flutter_angle_plugin.h"

#include <gtk/gtk.h>
#include <glib-object.h>
#include <flutter_linux/flutter_linux.h>

#include <GLES3/gl3.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>

#include <iostream>
#include <memory>
#include <mutex>

G_DECLARE_FINAL_TYPE(
  FlAngleTextureGL,
  fl_angle_texture_gl,
  FL,
  ANGLE_TEXTURE_GL,
  FlTextureGL
)

struct _FlAngleTextureGL{
  FlTextureGL parent_instance;
  uint32_t target;
  uint32_t name;
  uint32_t width;
  uint32_t height;
};


#define FLUTTER_ANGLE_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_angle_plugin_get_type(), \
                              FlutterAnglePlugin))

struct _FlutterAnglePlugin{
  GObject parent_instance;

  FlTextureRegistrar *textureRegistrar = nullptr;
  FlView *fl_view = nullptr;
  GdkWindow *window = nullptr;
  GdkGLContext* context;

  Map *map = nullptr;
};

FlAngleTextureGL *fl_angle_texture_gl_new(
  uint32_t target,
  uint32_t name,
  uint32_t width,
  uint32_t height
);

#endif // FL_ANGLE_TEXTURE_H
