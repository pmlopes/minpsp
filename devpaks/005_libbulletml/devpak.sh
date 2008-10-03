#!/bin/sh
. ../util/util.sh

LIBNAME=libbulletml
VERSION=0.0.5

svnGetPS2DEV $LIBNAME

cd $LIBNAME/src
make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../../target/psp/include/bulletml ../../target/psp/lib ../../target/doc
mkdir -p ../../target/psp/include/boost/config
mkdir -p ../../target/psp/include/boost/config/stdlib
mkdir -p ../../target/psp/include/boost/config/compiler
mkdir -p ../../target/psp/include/boost/config/platform
mkdir -p ../../target/psp/include/boost/detail
cp bulletml*.h formula.h tree.h tinyxml/tinyxml.h ../../target/psp/include/bulletml
find boost -name *.hpp -exec cp -R {} ../../target/psp/include/{} \;
cp libbulletml.a ../../target/psp/lib
cp ../README.en ../../target/doc/libbulletml.txt
cd ../..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
