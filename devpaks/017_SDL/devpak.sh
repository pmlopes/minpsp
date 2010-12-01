#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL
VERSION=1.2.14

download build "http://www.libsdl.org/release" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
make -f Makefile.psp
mkdir -p ../target/lib ../target/include/SDL ../target/doc/$LIBNAME-$VERSION
cp libSDL*.a ../target/lib/
cp include/*.h ../target/include/SDL/
cp -fR docs/man3 ../target/man
cp README.PSP ../target/doc/$LIBNAME.txt
cp -fR docs/html ../target/doc/$LIBNAME-$VERSION
cp -fR docs/images ../target/doc/$LIBNAME-$VERSION
cp docs/index.html ../target/doc/$LIBNAME-$VERSION

cd ..

mkdir -p target/bin
gcc -s -o target/bin/sdl-config -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DVERSION=\"$VERSION\" ../sdl-config.c

cd ..

makeInstaller $LIBNAME $VERSION pspgl 2264 pspirkeyb 0.0.4

echo "Done!"
