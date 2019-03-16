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

# 3.6 is the minimum for Cocos2d-x 3.17.1.
# 3.7 is required for BUILDSYSTEM_TARGETS.
cmake_minimum_required(VERSION 3.7)

set(APP_NAME Cocos2dxTemplate)

project(${APP_NAME} CXX)

if(NOT DEFINED COCOS2DX_ROOT_PATH)
    message(FATAL_ERROR "COCOS2DX_ROOT_PATH not defined, aborting.")
endif()

# TODO Checkt that COCOS2DX_ROOT_PATH appears to be a valid directory structure

set(CMAKE_MODULE_PATH ${COCOS2DX_ROOT_PATH}/cmake/Modules/)

include(CocosBuildSet)
add_subdirectory(${COCOS2DX_ROOT_PATH}/cocos ${ENGINE_BINARY_PATH}/cocos/core)

function(get_all_targets _result _dir)
    get_property(_subdirs DIRECTORY "${_dir}" PROPERTY SUBDIRECTORIES)
    foreach(_subdir IN LISTS _subdirs)
        get_all_targets(${_result} "${_subdir}")
    endforeach()
    get_property(_sub_targets DIRECTORY "${_dir}" PROPERTY BUILDSYSTEM_TARGETS)
    set(${_result} ${${_result}} ${_sub_targets} PARENT_SCOPE)
endfunction()

# Supress vast amount of warning spam coming from dependencies and cocos2d itself.
get_all_targets(targets "${CMAKE_CURRENT_SOURCE_DIR}")
foreach(target IN LISTS targets)
    set_target_properties(${target} PROPERTIES COMPILE_FLAGS "/W1 /D_CRT_SECURE_NO_WARNINGS")
endforeach()

# record sources, headers, resources...
set(GAME_SOURCE)
set(GAME_HEADER)

set(GAME_RES_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/Resources")
if(APPLE OR VS)
    cocos_mark_multi_resources(cc_common_res RES_TO "Resources" FOLDERS ${GAME_RES_FOLDER})
endif()

list(APPEND GAME_HEADER
    Classes/AppMacros.h
    Classes/IncludeCocos2dBegin.h
    Classes/IncludeCocos2dEnd.h
    Classes/HelloWorldScene.h
    Classes/AppDelegate.h
)
list(APPEND GAME_SOURCE
    Classes/AppDelegate.cpp
    Classes/HelloWorldScene.cpp
    Classes/main.cpp
)

if(ANDROID)
    # change APP_NAME to the share library name for Android, it's value depend on AndroidManifest.xml
    set(APP_NAME cpp_empty_test)
    list(APPEND GAME_SOURCE android/app/jni/main.cpp)
elseif(LINUX)
elseif(WINDOWS)
    list(APPEND GAME_SOURCE ${cc_common_res})
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
        list(APPEND GAME_SOURCE ${APP_UI_RES})
    endif()
    list(APPEND GAME_SOURCE ${cc_common_res})
endif()

set(all_code_files ${GAME_HEADER} ${GAME_SOURCE})

# mark app complie info
if(NOT ANDROID)
    add_executable(${APP_NAME} ${all_code_files})
else()
    add_library(${APP_NAME} SHARED ${all_code_files})
    add_subdirectory(${COCOS2DX_ROOT_PATH}/cocos/platform/android ${ENGINE_BINARY_PATH}/cocos/platform)
    target_link_libraries(${APP_NAME} -Wl,--whole-archive cpp_android_spec -Wl,--no-whole-archive)
endif()

target_link_libraries(${APP_NAME} cocos2d)

target_include_directories(${APP_NAME} PRIVATE Classes)

target_compile_features(${APP_NAME} PRIVATE cxx_std_17)

if (MSVC)
    target_compile_options(${APP_NAME} PRIVATE /W4 /utf-8 /permissive-)
    # Enforce Unicode for Win32 and CRT APIs.
    target_compile_definitions(${APP_NAME} PRIVATE -DUNICODE -D_UNICODE)
else()
    target_compile_options(${APP_NAME} PRIVATE -Wall -Wextra -Wpedantic -fvisibility=hidden -Wshadow)
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
        set_xcode_property(${APP_NAME} ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon-${APP_NAME}")
    endif()
elseif(WINDOWS)
    cocos_copy_target_dll(${APP_NAME} COPY_TO ${APP_RES_DIR}/..)
endif()

if(LINUX OR WINDOWS)
    cocos_copy_res(COPY_TO ${APP_RES_DIR} FOLDERS ${GAME_RES_FOLDER})
endif()
