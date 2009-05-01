#!/bin/bash
. ../util/util.sh

LIBNAME=libpng
VERSION=1.2.8

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/man/man3
cp png.h pngconf.h ../target/psp/include
cp libpng.a ../target/psp/lib
cp libpng.3 ../target/man/man3

cd ..

makeInstaller $LIBNAME $VERSION zlib 1.2.2

echo "Run the NSIS script now!"
