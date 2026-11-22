#include "include/headers/opengl_exception.h"

OpenGLException::OpenGLException(char* message, int error){
    this->error = error;
    message = message;
}