cmake_minimum_required(VERSION 3.31.4)

project(angle_android_graphic_jni)

# Find required Android libraries
find_library(log-lib log)
find_library(android-lib android)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set paths based on build type
# if(CMAKE_BUILD_TYPE STREQUAL "Debug")
#     set(ANGLE_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../debug/jniLibs/${ANDROID_ABI})
#     set(OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../debug/jniLibs/${ANDROID_ABI})
# else()
    set(ANGLE_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../release/jniLibs/${ANDROID_ABI})
    set(OUTPUT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../release/jniLibs/${ANDROID_ABI})
# endif()

message(STATUS "ANGLE_LIB_DIR: ${ANGLE_LIB_DIR}")
message(STATUS "OUTPUT_DIR: ${OUTPUT_DIR}")

# Add your source files
add_library(angle_android_graphic_jni SHARED
    angle_android_graphic_jni.cpp)

# Include directories
target_include_directories(angle_android_graphic_jni PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${ANDROID_NDK}/sources/android/native_app_glue)

# Add ANGLE libraries directory to linker search path
link_directories(${ANGLE_LIB_DIR})

# Link against the required libraries
target_link_libraries(angle_android_graphic_jni
    ${log-lib}
    ${android-lib}
    ${ANGLE_LIB_DIR}/libEGL_angle.so
    ${ANGLE_LIB_DIR}/libGLESv2_angle.so)

# Set output directory
set_target_properties(angle_android_graphic_jni PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${OUTPUT_DIR})
