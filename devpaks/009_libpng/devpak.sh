#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libpng
VERSION=1.2.8

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

make

mkdir -p ../target/psp/include ../target/psp/lib ../target/man/man3
cp png.h pngconf.h ../target/psp/include
cp libpng.a ../target/psp/lib
cp libpng.3 ../target/man/man3

cd ../..

makeInstaller $LIBNAME $VERSION zlib 1.2.2

echo "Done!"

