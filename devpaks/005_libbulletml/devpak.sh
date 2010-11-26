#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=bulletml
VERSION=0.0.6

download build "http://shinh.skr.jp/libbulletml" lib$LIBNAME-$VERSION "tar.bz2"

cd build/$LIBNAME/src
make

mkdir -p ../../target/psp/include/bulletml ../../target/psp/lib ../../target/doc
mkdir -p ../../target/psp/include/boost/config
mkdir -p ../../target/psp/include/boost/config/stdlib
mkdir -p ../../target/psp/include/boost/config/compiler
mkdir -p ../../target/psp/include/boost/config/platform
mkdir -p ../../target/psp/include/boost/detail
cp bulletml*.h formula.h tree.h ../../target/psp/include/bulletml
find boost -name *.hpp -exec cp -R {} ../../target/psp/include/{} \;
cp libbulletml.a ../../target/psp/lib
cp ../README.en ../../target/doc/bulletml.txt
cd ../../..

makeInstaller lib$LIBNAME $VERSION tinyxml 2.6.1

echo "Done!"
