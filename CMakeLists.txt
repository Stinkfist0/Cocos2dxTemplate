#/****************************************************************************
# Copyright (c) 2015-2017 Chukong Technologies Inc.

# http://www.cocos2d-x.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ****************************************************************************/

# NOTE cocos console parses this CMakeLists.txt and looks for a variable named APP_NAME
# so it's recommended not to rename it to anything else.
set(APP_NAME Cocos2dxTemplate)

project(${APP_NAME})

option(SUPPRESS_ENGINE_BUILD_WARNINGS "Suppress engine code's build warnings (there are plenty of them)." ON)

if (NOT DEFINED COCOS2DX_ROOT_PATH)
    message(FATAL_ERROR "COCOS2DX_ROOT_PATH not defined, aborting.")
endif()
message(STATUS "COCOS2DX_ROOT_PATH=${COCOS2DX_ROOT_PATH}")

set(CMAKE_MODULE_PATH ${COCOS2DX_ROOT_PATH}/cmake/Modules/)
# The next line will fail if COCOS2DX_ROOT_PATH does not point to a valid Cocos2d-x directory structure
include(CocosBuildSet)

# 3.6 is the minimum for Cocos2d-x 3.17.1.
# 3.7 is required for BUILDSYSTEM_TARGETS.
# TODO Use 3.7+, but currently getting weird invalid char error with it
if (ANDROID)
    cmake_minimum_required(VERSION 3.6)
else()
    cmake_minimum_required(VERSION 3.7)
endif()

# Were only interested in the engine, not in the editor. Extensions seem to contain some usable stuff, so keep them on.
set(BUILD_EDITOR_COCOSBUILDER OFF CACHE BOOL "Build editor support for cocosbuilder" FORCE)
set(BUILD_EDITOR_COCOSTUDIO OFF CACHE BOOL "Build editor support for cocostudio" FORCE)
set(BUILD_EDITOR_SPINE OFF CACHE BOOL "Build editor support for spine" FORCE)
#set(BUILD_EXTENSIONS OFF CACHE BOOL "Build extension library" FORCE)

# Suppress Policy CMP0003 spam coming from COCOS2DX_ROOT_PATH/cocos/CMakeLists.txt
if (COMMAND cmake_policy)
    cmake_policy(SET CMP0003 NEW)
endif()
add_subdirectory(${COCOS2DX_ROOT_PATH}/cocos ${ENGINE_BINARY_PATH}/cocos/core)

if (NOT ANDROID AND SUPPRESS_ENGINE_BUILD_WARNINGS)
    # Supress vast amount of warning spam coming from dependencies and cocos2d itself.
    include(Utils.cmake)
    SuppressCocosEngineBuildWarnings()
endif()

# Shared source files
list(APPEND GAME_HEADER
    src/AppMacros.h
    src/IncludeCocos2dBegin.h
    src/IncludeCocos2dEnd.h
    src/HelloWorldScene.h
    src/AppDelegate.h
)
list(APPEND GAME_SOURCE
    src/AppDelegate.cpp
    src/HelloWorldScene.cpp
)

# Platform-specific source and resource files
set(GAME_RES_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/res")
if (APPLE OR VS)
    cocos_mark_multi_resources(cc_common_res RES_TO "Resources" FOLDERS ${GAME_RES_FOLDER})
endif()

if (ANDROID)
    list(APPEND GAME_SOURCE android/app/jni/main.cpp)
elseif(WINDOWS)
    list(APPEND GAME_HEADER win32/resource.h)
    list(APPEND GAME_SOURCE src/main.cpp win32/${APP_NAME}.rc ${common_res_files})
elseif(LINUX)
    list(APPEND GAME_SOURCE src/main.cpp)
elseif(APPLE)
    if(IOS)
        list(APPEND GAME_HEADER
             ios/AppController.h
             ios/RootViewController.h
         )
        set(APP_UI_RES
            ios/LaunchScreen.storyboard
            ios/LaunchScreenBackground.png
            ios/Images.xcassets
        )
        list(APPEND GAME_SOURCE
             ios/main.m
             ios/AppController.mm
             ios/RootViewController.mm
             ${APP_UI_RES}
         )
    elseif(MACOSX)
        set(APP_UI_RES
            macos/Icon.icns
            macos/Info.plist
            macos/en.lproj/MainMenu.xib
            macos/en.lproj/InfoPlist.strings
        )
        list(APPEND GAME_SOURCE src/main.cpp ${APP_UI_RES})
    endif()
    list(APPEND GAME_SOURCE ${cc_common_res})
endif()

if (ANDROID)
    # The native code is included to Android application as a shared library so alter
    # the name to reflect this. The name must match to the name in android/app/AndroidManifest.xml.
    set(APP_NAME "${APP_NAME}Lib")
    add_library(${APP_NAME} SHARED ${GAME_HEADER} ${GAME_SOURCE})
    add_subdirectory(${COCOS2DX_ROOT_PATH}/cocos/platform/android ${ENGINE_BINARY_PATH}/cocos/platform)
    target_link_libraries(${APP_NAME} -Wl,--whole-archive cpp_android_spec -Wl,--no-whole-archive)
else()
    add_executable(${APP_NAME} ${GAME_HEADER} ${GAME_SOURCE})
endif()

# TODO Preferably 17
set_property(TARGET ${APP_NAME} PROPERTY CXX_STANDARD 14)
# With CMake >= 3.8 use target_compile_features() is recommended:
#target_compile_features(${APP_NAME} PRIVATE cxx_std_17)

target_link_libraries(${APP_NAME} cocos2d)

target_include_directories(${APP_NAME} PRIVATE src)

# TODO Support for "cocos deploy"
# if (WIN32)
    # set_target_properties(
        # ${APP_NAME} PROPERTIES
        # RUNTIME_OUTPUT_DIRECTORY_DEBUG "${CMAKE_BINARY_DIR}/Debug.win32/${APP_NAME}"
        # RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/Release.win32/${APP_NAME}"
    # )
# endif()

if (MSVC)
    target_compile_options(${APP_NAME} PRIVATE /W4 /utf-8 /permissive-)
    # Enforce Unicode for Win32 and CRT APIs.
    target_compile_definitions(${APP_NAME} PRIVATE -DUNICODE -D_UNICODE)
else()
    target_compile_options(${APP_NAME} PRIVATE -Wall -Wextra -Wshadow)
    # Don't want to use -Wpedantic for GCC < 8.1 as it would cause warning spam
    # (extraneous semicolons) that cannot be suppressed.
    if (CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 8.0)
        target_compile_options(${APP_NAME} PRIVATE -Wpedantic)
    endif()
endif()

# mark app resources
setup_cocos_app_config(${APP_NAME})
if(APPLE)
    set_target_properties(${APP_NAME} PROPERTIES RESOURCE "${APP_UI_RES}")
    if(MACOSX)
        set_target_properties(
            ${APP_NAME} PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/macos/Info.plist"
        )
    elseif(IOS)
        cocos_pak_xcode(${APP_NAME} INFO_PLIST "iOSBundleInfo.plist.in")
        set_xcode_property(${APP_NAME} ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon")
        set_xcode_property(${APP_NAME} CODE_SIGN_IDENTITY "iPhone Developer")
        set_xcode_property(${APP_NAME} DEVELOPMENT_TEAM "")
        set_xcode_property(${APP_NAME} CODE_SIGN_IDENTITY "iPhone Developer")
    endif()
elseif(WINDOWS)
    cocos_copy_target_dll(${APP_NAME} COPY_TO ${APP_RES_DIR}/..)
    # TODO If using the latest cocos2d-x sources: cocos_copy_target_dll(${APP_NAME})
endif()

if(LINUX OR WINDOWS)
    cocos_copy_res(COPY_TO ${APP_RES_DIR} FOLDERS ${GAME_RES_FOLDER})
    # The following is not available after 3.17.1
    cocos_copy_res(COPY_TO ${APP_RES_DIR} FOLDERS ${GAME_RES_FOLDER})
    # Must use this instead:
    #set(APP_RES_DIR "$<TARGET_FILE_DIR:${APP_NAME}>/Resources")
    #cocos_copy_target_res(${APP_NAME} COPY_TO ${APP_RES_DIR} FOLDERS ${GAME_RES_FOLDER})
endif()
