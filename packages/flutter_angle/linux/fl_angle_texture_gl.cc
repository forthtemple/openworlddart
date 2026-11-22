#include "include/fl_angle_texture_gl.h"

// https://github.com/lattice0/external_texture_flutter_linux/tree/master/external_texture/linux

#include <iostream>
G_DEFINE_TYPE(
  FlAngleTextureGL,
  fl_angle_texture_gl,
  fl_texture_gl_get_type()
)

static gboolean fl_angle_texture_gl_populate(
  FlTextureGL *texture,
  uint32_t *target,
  uint32_t *name,
  uint32_t* width,
  uint32_t* height,
  GError **error
){
  // std::cout << "attention: populate called" << std::endl;
  FlAngleTextureGL* f = (FlAngleTextureGL*) texture;
  *target = f->target;
  *name = f->name;
  *width = f->width;
  *height = f->height;
  return true;
}

FlAngleTextureGL *fl_angle_texture_gl_new(
  uint32_t target,
  uint32_t name,
  uint32_t width,
  uint32_t height
){
  auto r = FL_ANGLE_TEXTURE_GL(g_object_new(fl_angle_texture_gl_get_type(), nullptr));
  r->target = target;
  r->name = name;
  r->width = width;
  r->height = height;
  return r;
}

static void fl_angle_texture_gl_class_init(FlAngleTextureGLClass *klass){
  FL_TEXTURE_GL_CLASS(klass)->populate = fl_angle_texture_gl_populate;
}

static void fl_angle_texture_gl_init(FlAngleTextureGL *self){}