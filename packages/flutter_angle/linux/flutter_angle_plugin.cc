#include "include/flutter_angle/flutter_angle_plugin.h"
#include "include/fl_angle_texture_gl.h"
#include "flutter_angle_plugin_private.h"
#include  "include/opengl_renderer.h"

#include <flutter_linux/flutter_linux.h>
#include <flutter_linux/fl_view.h>
#include <sys/utsname.h>
#include <glib.h>

#include <map>
#include <memory>
#include <sstream>
#include <thread>
#include <iostream>
#include <cstring>

G_DEFINE_TYPE(FlutterAnglePlugin, flutter_angle_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void flutter_angle_plugin_handle_method_call(FlutterAnglePlugin *self, FlMethodCall *method_call){
  g_autoptr(FlMethodResponse) response = nullptr;

	const gchar *method = fl_method_call_get_name(method_call);
	FlValue *args = fl_method_call_get_args(method_call);

	if (strcmp(method, "getPlatformVersion") == 0) {
		response = get_platform_version();
	} 
	else if (strcmp(method, "initOpenGL") == 0){
    g_autoptr(GError) error = nullptr;
    
    self->window = gtk_widget_get_parent_window(GTK_WIDGET(self->fl_view));
    printf(".... initOpenGL\n");

    self->context = gdk_window_create_gl_context(self->window, &error);
    gdk_gl_context_realize (self->context,&error);

    g_autoptr(FlValue) value = fl_value_new_map ();
    fl_value_set_string_take(value, "context", fl_value_new_int ((int64_t)self->context));
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));

    self->map = new Map();
  }
	else if (strcmp(method, "createTexture") == 0){
    std::cerr << "EGL createTexture" << std::endl;
    int width = 0;
    int height = 0;
    if(args){
      width = fl_value_get_int(fl_value_lookup_string(args, "width"));
      height = fl_value_get_int(fl_value_lookup_string(args, "height"));
      if(!width || !height){
        response = FL_METHOD_RESPONSE(fl_method_error_response_new("EGL DeleteError", "Missing with or height.",nullptr));
        fl_method_call_respond(method_call, response, nullptr);
        return;
      }
    }
    std::cerr << "Window Size:" << width << "," << height << std::endl;

    auto currentTexture = std::make_unique<OpenglRenderer>(
      self->textureRegistrar,
      self->context,
      width,
      height
    );

    auto textureId = currentTexture->textureId;
    self->map->renderers[textureId] = std::move(currentTexture);
    g_autoptr(FlValue) value = self->map->renderers.at(textureId)->createTexture();
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
  }
	else if (strcmp(method, "textureFrameAvailable") == 0){
    int64_t textureId = 0;
    if(args){
      textureId = fl_value_get_int(fl_value_lookup_string(args, "textureId"));
      if(!textureId){
        response = FL_METHOD_RESPONSE(fl_method_error_response_new("EGL DeleteError", "Missing textureId.",nullptr));
        fl_method_call_respond(method_call, response, nullptr);
        return;
      }
    }
    
    if (self->map->renderers.find(textureId) == self->map->renderers.end()){
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("EGL DeleteError", "Invalid texture ID.",nullptr));
      fl_method_call_respond(method_call, response, nullptr);
      return;
    }

    self->map->renderers[textureId]->updateTexture();

    g_autoptr(FlValue) result = fl_value_new_null();
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
	}
	else if (strcmp(method, "resizeTexture") == 0){
    std::cerr << "EGL resizeTexture" << std::endl;
    int width = 0;
    int height = 0;
    int64_t textureId = 0;
    if(args){
      width = fl_value_get_int(fl_value_lookup_string(args, "width"));
      height = fl_value_get_int(fl_value_lookup_string(args, "height"));
      textureId = fl_value_get_int(fl_value_lookup_string(args, "textureId"));
      if(!width || !height){
        response = FL_METHOD_RESPONSE(
        fl_method_error_response_new("EGL ResizeError", "Missing with, height, or textureID.",nullptr));
        fl_method_call_respond(method_call, response, nullptr);
        return;
      }
      else if(!textureId){
        response = FL_METHOD_RESPONSE(fl_method_error_response_new("EGL ResizeError", "Missing textureId.",nullptr));
        fl_method_call_respond(method_call, response, nullptr);
        return;
      }
    }
    std::cerr << "Window Size:" << width << "," << height << std::endl;

    if (self->map->renderers.find(textureId) == self->map->renderers.end()){
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("EGL DeleteError", "Invalid texture ID.",nullptr));
      fl_method_call_respond(method_call, response, nullptr);
      return;
    }

    self->map->renderers[textureId]->changeSize(width,height);
    
    g_autoptr(FlValue) result = fl_value_new_null();
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
	}
	else if (strcmp(method, "deleteTexture") == 0){
    std::cerr << "EGL deleteTexture" << std::endl;
    int64_t textureId = 0;
    if(args){
      textureId = fl_value_get_int(fl_value_lookup_string(args, "textureId"));
      if(!textureId){
        response = FL_METHOD_RESPONSE(fl_method_error_response_new("EGL DeleteError", "Missing textureId.", nullptr));
        fl_method_call_respond(method_call, response, nullptr);
        return;
      }
    }

    // Check if the received ID is registered
    if (self->map->renderers.find(textureId) == self->map->renderers.end()){
      response = FL_METHOD_RESPONSE(fl_method_error_response_new("EGL DeleteError", "Invalid texture ID.",nullptr));
      fl_method_call_respond(method_call, response, nullptr);
      return;
    }

    self->map->renderers[textureId]->dispose(true);
    self->map->renderers.erase(textureId);

    g_autoptr(FlValue) result = fl_value_new_null();
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
	}
	else{
		response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
	}

	fl_method_call_respond(method_call, response, nullptr);
}

FlMethodResponse* get_platform_version() {
  struct utsname uname_data = {};
  uname(&uname_data);
  g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
  g_autoptr(FlValue) result = fl_value_new_string(version);
  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static void flutter_angle_plugin_dispose(GObject *object){
	G_OBJECT_CLASS(flutter_angle_plugin_parent_class)->dispose(object);
}

static void flutter_angle_plugin_class_init(FlutterAnglePluginClass *klass){
	G_OBJECT_CLASS(klass)->dispose = flutter_angle_plugin_dispose;
}

static void flutter_angle_plugin_init(FlutterAnglePlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call, gpointer user_data){
	FlutterAnglePlugin *plugin = FLUTTER_ANGLE_PLUGIN(user_data);
	flutter_angle_plugin_handle_method_call(plugin, method_call);
}

void flutter_angle_plugin_register_with_registrar(FlPluginRegistrar *registrar){
	FlutterAnglePlugin *plugin = FLUTTER_ANGLE_PLUGIN(g_object_new(flutter_angle_plugin_get_type(), nullptr));

	FlView *fl_view = fl_plugin_registrar_get_view(registrar);
	plugin->fl_view = fl_view;
	plugin->textureRegistrar = fl_plugin_registrar_get_texture_registrar(registrar);

	g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
	g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
    fl_plugin_registrar_get_messenger(registrar),
    "flutter_angle",
    FL_METHOD_CODEC(codec)
  );

	fl_method_channel_set_method_call_handler(
		channel,
		method_call_cb,
		g_object_ref(plugin),
		g_object_unref
  );

	g_object_unref(plugin);
}

extern int makeCurrent(GdkGLContext* context){
  gdk_gl_context_make_current(context);
  return 1;
}