cmake_minimum_required(VERSION 3.15)

# Project-level configuration.
set(PROJECT_NAME "flutter_angle")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_angle_plugin")

add_library(
  ${PLUGIN_NAME} SHARED 
  "flutter_angle_plugin.cpp"
  "flutter_gl_texture.cpp"
  "opengl_exception.cpp"
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
  
target_link_directories(
  ${PLUGIN_NAME} PUBLIC 
  ${OPENGL_LIB_DIR} 
)

target_link_libraries(
  ${PLUGIN_NAME} PRIVATE 
  flutter 
  flutter_wrapper_plugin 
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/lib/libEGL.dll.lib" 
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/lib/libGLESv2.dll.lib"
)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_angle_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/dll/libEGL.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/dll/libGLESv2.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/dll/libc++.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/dll/msvcp140d.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/dll/ucrtbased.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/dll/vccorlib140d.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/dll/vcruntime140_1d.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/dll/vcruntime140d.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/bin/dll/zlib.dll"
  PARENT_SCOPE
)