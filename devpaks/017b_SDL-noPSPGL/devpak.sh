#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL
VERSION=1.2.14

download build "http://www.libsdl.org/release" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
make -s -f Makefile.psp
mkdir -p ../target/psp/lib ../target/psp/include/SDL ../target/doc/$LIBNAME-$VERSION
cp libSDL*.a ../target/psp/lib/
cp include/*.h ../target/psp/include/SDL/
cp -fR docs/man3 ../target/man
cp README.PSP ../target/doc/$LIBNAME.txt
cp -fR docs/html ../target/doc/$LIBNAME-$VERSION
cp -fR docs/images ../target/doc/$LIBNAME-$VERSION
cp docs/index.html ../target/doc/$LIBNAME-$VERSION

cd ..

mkdir -p target/bin
gcc -s -o target/bin/sdl-config -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DVERSION=\"$VERSION\" ../sdl-config.c

cd ..

makeInstaller $LIBNAME $VERSION pspirkeyb 0.0.4

echo "Done!"
