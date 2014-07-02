#!/bin/sh

#  Automatic build script for libcurl 
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Miyabi Kazamatsuri on 19.04.11.
#  Copyright 2011 Miyabi Kazamatsuri. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#  Change values here                             #
#                                     #
VERSION="2.5.0"                              #
SDKVERSION="7.1"                              #
OPENSSL=""
#                                     #
###########################################################################
#                                     #
# Don't change anything under this line!                  #
#                                     #
###########################################################################

CURRENTPATH=`pwd`
DEVELOPER=`xcode-select --print-path`

LIPO="xcrun -sdk iphoneos lipo"
STRIP="xcrun -sdk iphoneos strip"
ios_deploy_version="7.0"

# test for Xcode 4.3+
if ! test -d "${DEVELOPER}/Platforms" ; then
    echo "You must install Xcode first from the App Store"
fi

xcode_base="${DEVELOPER}/Platforms"
ios_sdk_root=""
ios_toolchain="${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin"
ios_sdk_version=${SDKVERSION}

set -e
if [ ! -e protobuf-${VERSION}.tar.gz ]; then
    echo "Downloading protobuf-${VERSION}.tar.gz"
    #curl -O https://protobuf.googlecode.com/files/protobuf-${VERSION}.tar.gz
else
    echo "Using protobuf-${VERSION}.tar.gz"
fi

if [ -d  ${CURRENTPATH}/src ]; then
    rm -rf ${CURRENTPATH}/src
fi

if [ -d ${CURRENTPATH}/bin ]; then
    rm -rf ${CURRENTPATH}/bin
fi

mkdir -p "${CURRENTPATH}/src"
tar zxf protobuf-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
cd "${CURRENTPATH}/src/protobuf-${VERSION}"


##############
# MAC OS

export AS=as
export CC=clang
export CXX=clang++
export CPP="clang -E"
export LD=ld
export AR=ar
export RANLIB=ranlib
export STRIP=strip

export CFLAGS="-pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="-pipe -Wno-implicit-int -Wno-return-type"
export LDFLAGS=""
export LIBS=""

mkdir -p "${CURRENTPATH}/bin/MACOS.platform"

LOG="${CURRENTPATH}/bin/MACOS.platform/build-libprotobuf-${VERSION}.log"

./configure --prefix=${CURRENTPATH}/bin/MACOS.platform --exec-prefix=${CURRENTPATH}/bin/MACOS.platform
make  >> "${LOG}" 2>&1
make install  >> "${LOG}" 2>&1
make clean >> "${LOG}" 2>&1

####################

# set the compilers
export AS="$ios_toolchain"/as
export CC="$ios_toolchain"/clang
export CXX="$ios_toolchain"/clang++
export CPP="$ios_toolchain/clang -E"
export LD="$ios_toolchain"/ld
export AR="$ios_toolchain"/ar
export RANLIB="$ios_toolchain"/ranlib
export STRIP="$ios_toolchain"/strip
############

# iPhone Simulator
ios_arch=i386
ARCH=${ios_arch}
PLATFORM="iPhoneSimulator"
ios_target=${PLATFORM}
echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
    echo "Invalid SDK version"
fi


export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include  -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc"
#export CFLAGS="-arch ${ARCH} -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk "
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-libprotobuf-${VERSION}.log"

echo "Configure libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure -prefix=${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk --with-protoc=${CURRENTPATH}/bin/MACOS.platform/bin/protoc -disable-shared -with-random=/dev/urandom # --without-ssl --without-libssh2 # --with-ssl # > "${LOG}" 2>&1

echo "Make libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make  >> "${LOG}" 2>&1
make install  >> "${LOG}" 2>&1
make clean >> "${LOG}" 2>&1

echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"

#############

#############
# iPhoneOS armv7
ios_arch="armv7"
ARCH=${ios_arch}
PLATFORM="iPhoneOS"
ios_target=${PLATFORM}

echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
    echo "Invalid SDK version"
fi

export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include   -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc"
#export CFLAGS="-arch ${ARCH} -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk "
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-libprotobuf-${VERSION}.log"

echo "Configure libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure -prefix=${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk --with-protoc=${CURRENTPATH}/bin/MACOS.platform/bin/protoc --host=${ARCH}-apple-darwin --disable-shared -with-random=/dev/urandom # > "${LOG}" 2>&1

echo "Make libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make  >> "${LOG}" 2>&1
make install  >> "${LOG}" 2>&1
make clean  >> "${LOG}" 2>&1

echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"
#############

#############
# iPhoneOS armv7s
ios_arch="armv7s"
ARCH=${ios_arch}
PLATFORM="iPhoneOS"
ios_target=${PLATFORM}

echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
    echo "Invalid SDK version"
fi


export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include  -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc"
#export CFLAGS="-arch ${ARCH} -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk "
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-libprotobuf-${VERSION}.log"

echo "Configure libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure -prefix=${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk --with-protoc=${CURRENTPATH}/bin/MACOS.platform/bin/protoc --host=${ARCH}-apple-darwin --disable-shared -with-random=/dev/urandom # > "${LOG}" 2>&1

echo "Make libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make >> "${LOG}" 2>&1
make install  >> "${LOG}" 2>&1
make clean >> "${LOG}" 2>&1

echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"
#############


#############
# iPhoneSimulator x86_64
ios_arch="x86_64"
ARCH=${ios_arch}
PLATFORM="iPhoneSimulator"
ios_target=${PLATFORM}

echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
echo "Invalid SDK version"
fi

export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc"
#export CFLAGS="-arch ${ARCH} -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk "
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-libprotobuf-${VERSION}.log"

echo "Configure libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

./configure -prefix=${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk --with-protoc=${CURRENTPATH}/bin/MACOS.platform/bin/protoc --host=arm-apple-darwin --disable-shared -with-random=/dev/urandom # > "${LOG}" 2>&1

echo "Make libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make >> "${LOG}" 2>&1
make install  >> "${LOG}" 2>&1
make clean >> "${LOG}" 2>&1

echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"
#############

#############
# iPhoneOS arm64
ios_arch="arm64"
ARCH=${ios_arch}
PLATFORM="iPhoneOS"
ios_target=${PLATFORM}

echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"
echo "Please stand by..."

# test to see if the actual sdk exists
ios_sdk_root="$xcode_base"/$ios_target.platform/Developer/SDKs/$ios_target"$ios_sdk_version".sdk

if ! test -d "$ios_sdk_root" ; then
echo "Invalid SDK version"
fi

export LDFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -v"
export CFLAGS="-isysroot $ios_sdk_root -arch $ios_arch -miphoneos-version-min=$ios_deploy_version -I$ios_sdk_root/usr/include  -pipe -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS=""

#export CC="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin/gcc"
#export CFLAGS="-arch ${ARCH} -isysroot ${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk "
mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-libprotobuf-${VERSION}.log"

echo "Configure libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

patch -p1 < ${CURRENTPATH}/patch-64/0001-Add-generic-GCC-support-for-atomic-operations.patch
patch -p1 < ${CURRENTPATH}/patch-64/0001-Add-generic-gcc-header-to-Makefile.am.patch

./configure -prefix=${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk --with-protoc=${CURRENTPATH}/bin/MACOS.platform/bin/protoc --host=arm-apple-darwin --disable-shared -with-random=/dev/urandom # > "${LOG}" 2>&1

echo "Make libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}"

make >> "${LOG}" 2>&1
make install  >> "${LOG}" 2>&1
make clean >> "${LOG}" 2>&1

echo "Building libprotobuf for ${PLATFORM} ${SDKVERSION} ${ARCH}, finished"
#############


#############
# Universal Library
# echo "Build universal library..."
mkdir -p ${CURRENTPATH}/protobuf/prebuilt/ios
$LIPO -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libprotobuf.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/lib/libprotobuf.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libprotobuf.a  ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib/libprotobuf.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib/libprotobuf.a -output ${CURRENTPATH}/protobuf/prebuilt/ios/libprotobuf.a
# remove debugging info
$STRIP -S ${CURRENTPATH}/protobuf/prebuilt/ios/libprotobuf.a

$LIPO -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libprotobuf-lite.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/lib/libprotobuf-lite.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libprotobuf-lite.a  ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib/libprotobuf-lite.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib/libprotobuf-lite.a -output ${CURRENTPATH}/protobuf/prebuilt/ios/libprotobuf-lite.a
# remove debugging info
$STRIP -S ${CURRENTPATH}/protobuf/prebuilt/ios/libprotobuf-lite.a

$LIPO -info ${CURRENTPATH}/protobuf/prebuilt/ios/libprotobuf.a
$LIPO -info ${CURRENTPATH}/protobuf/prebuilt/ios/libprotobuf-lite.a
    
mkdir -p ${CURRENTPATH}/protobuf/include
cp -R ${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/include/ ${CURRENTPATH}/protobuf/include

#################
#MACOS.platform x86_64
mkdir -p ${CURRENTPATH}/protobuf/prebuilt/mac
$LIPO -create ${CURRENTPATH}/bin/MACOS.platform/lib/libprotobuf.a -output ${CURRENTPATH}/protobuf/prebuilt/mac/libprotobuf.a
$LIPO -create ${CURRENTPATH}/bin/MACOS.platform/lib/libprotobuf-lite.a -output ${CURRENTPATH}/protobuf/prebuilt/mac/libprotobuf-lite.a
$STRIP -S ${CURRENTPATH}/protobuf/prebuilt/mac/libprotobuf.a
$STRIP -S ${CURRENTPATH}/protobuf/prebuilt/mac/libprotobuf-lite.a
$LIPO -info ${CURRENTPATH}/protobuf/prebuilt/mac/libprotobuf.a
$LIPO -info ${CURRENTPATH}/protobuf/prebuilt/mac/libprotobuf-lite.a
$LIPO -info ${CURRENTPATH}/protobuf/prebuilt/mac/libprotobuf.a
$LIPO -info ${CURRENTPATH}/protobuf/prebuilt/mac/libprotobuf-lite.a


# echo "Building all steps done."
# echo "Cleaning up..."
rm -rf ${CURRENTPATH}/src
rm -rf ${CURRENTPATH}/bin
echo "Done."