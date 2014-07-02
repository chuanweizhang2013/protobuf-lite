LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := protobuf-lite_static
LOCAL_MODULE_FILENAME := protobuf-lite
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libprotobuf-lite.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../include
include $(PREBUILT_STATIC_LIBRARY)
