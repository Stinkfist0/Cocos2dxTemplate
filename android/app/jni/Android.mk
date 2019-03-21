LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cpp_empty_test_shared

LOCAL_MODULE_FILENAME := libcpp_empty_test

LOCAL_ARM_MODE := arm

LOCAL_SRC_FILES := main.cpp \
                   ../../../src/AppDelegate.cpp \
                   ../../../src/HelloWorldScene.cpp

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../../src \
                    $(LOCAL_PATH)/../../../../../extensions \
                    $(LOCAL_PATH)/../../../../.. \
                    $(LOCAL_PATH)/../../../../../cocos/editor-support

LOCAL_STATIC_LIBRARIES := cc_static

include $(BUILD_SHARED_LIBRARY)

$(call import-module, cocos)