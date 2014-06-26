LOCAL_PATH := $(call my-dir)  
APP_ABI :=armeabi armeabi-v7a x86

include $(CLEAR_VARS)  
  
LOCAL_MODULE := protobuf-lite_static  
  
LOCAL_MODULE_FILENAME := libprotobuf-lite  
   
LOCAL_SRC_FILES := \
../../../src/google/protobuf/io/coded_stream.cc \
../../../srcgoogle/protobuf/stubs/common.cc \
../../../srcgoogle/protobuf/extension_set.cc \
../../../srcgoogle/protobuf/generated_message_util.cc \
../../../srcgoogle/protobuf/message_lite.cc \
../../../srcgoogle/protobuf/stubs/once.cc \
../../../srcgoogle/protobuf/repeated_field.cc \
../../../srcgoogle/protobuf/wire_format_lite.cc \
../../../srcgoogle/protobuf/io/zero_copy_stream.cc \
../../../srcgoogle/protobuf/io/zero_copy_stream_impl_lite.cc

LOCAL_EXPORT_C_INCLUDES :=
LOCAL_EXPORT_LDLIBS :=
LOCAL_C_INCLUDES :=\
$(LOCAL_PATH) \
$(LOCAL_PATH)/../../../src
  
LOCAL_LDLIBS := \
-llog \
-lz  

include $(BUILD_STATIC_LIBRARY)   
