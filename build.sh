#!/bin/bash

bash ./clean.sh

# check THEOS settings
if [ -z "$THEOS" ]; then
    export THEOS=~/theos
fi

if [ ! -d "$THEOS/lib" ]; then
    echo "THEOS lib [$THEOS/lib] not exists"
    exit 1
fi

# set temp working dir
rm -rf .theos_building
mkdir -p .theos_building

######################################################
# build static lib for iOS using golib
######################################################
set -e
PWD=`pwd`

# build arm64
export CGO_ENABLED=1
export GOARCH=arm64
export CC=$PWD/clangwrap.sh
export CXX=$PWD/clangwrap.sh

echo "building darwin/arm64 static lib"
go build -buildmode=c-archive -o ./.theos_building/libgolang_arm64.a
if [ ! -f ./.theos_building/libgolang_arm64.a ]; then
    echo "failed to build darwin/arm64 static lib!"
    exit 1
fi

# build armv7
export CGO_ENABLED=1
export GOARCH=arm
export GOARM=7
export CC=$PWD/clangwrap.sh
export CXX=$PWD/clangwrap.sh

echo "building darwin/armv7 static lib"
go build -buildmode=c-archive -o ./.theos_building/libgolang_armv7.a
if [ ! -f ./.theos_building/libgolang_armv7.a ]; then
    echo "failed to build darwin/armv7 static lib!"
    exit 1
fi

# Make universal library
cd ./.theos_building/
echo "joining darwin/arm64 & darwin/armv7 static libs to a universal one"
lipo libgolang_arm64.a libgolang_armv7.a -create -output libgolang.a
rm libgolang_arm64.a libgolang_armv7.a
rm libgolang_arm64.h libgolang_armv7.h
if [ ! -f libgolang.a ]; then
    echo "failed to build the universal lib!"
    exit 1
fi

######################################################
# build debian binary for iOS using theos
######################################################

# move static lib to theos lib folder
currentTime=$(date +%s)
staticLibFileName="libgolang"$currentTime".a"
staticLibLdFlags="-lgolang"$currentTime
cp libgolang.a $THEOS"/lib/"$staticLibFileName

# Makefile of .deb package
echo 'include $(THEOS)/makefiles/common.mk

TOOL_NAME = dccxxcls
dccxxcls_FILES = main.mm
dccxxcls_LDFLAGS = '$staticLibLdFlags'

include $(THEOS_MAKE_PATH)/tool.mk
' > ./Makefile

# control file of .deb package
echo 'Package: dccxx.cls
Name: dccxxcls
Depends: 
Version: 0.0.1
Architecture: iphoneos-arm
Description: ----------------------- DCCXX -----------------------
Maintainer: DCCXX
Author: DCCXX
Section: System
Tag: role::hacker
' > ./control

# copy main.h and main.mm to dest
cp ../main.mm ../main.h ./

# make the deb package
echo "building theos package"
make package FINALPACKAGE=1

######################################################
# extract the single program from deb package
######################################################
# echo "extracting executable file from .deb package"
# mkdir extracted_deb
# dpkg -x packages/*.deb ./extracted_deb
# mkdir ../bin
# find ./extracted_deb -name "golangtool"|while read line; do cp $line ../bin/cmd; done

#remove temp path
# cd ..
# rm -rf ./.theos_building/
rm $THEOS"/lib/libgolang"*".a"
