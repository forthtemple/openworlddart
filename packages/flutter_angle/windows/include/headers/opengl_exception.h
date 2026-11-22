#ifndef OPENGL_EXCEPTION_H_
#define OPENGL_EXCEPTION_H_

#include "include/flutter_angle/flutter_angle_plugin.h"
#include "include/gl32.h"
#include "include/egl.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#if defined(__cplusplus)
extern "C" {
#endif

class OpenGLException{
    public:
        OpenGLException(char* message, int error);
        GLint error = 0;
        char* message ="";
};

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // OPENGL_EXCEPTION_H_