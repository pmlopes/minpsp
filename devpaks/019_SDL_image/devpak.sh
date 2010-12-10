#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL_image
VERSION=1.2.10

download build "http://www.libsdl.org/projects/SDL_image/release" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
CFLAGS="-g -O2 -G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp
make -s

make -s install
mkdir -p ../target/doc
cp README ../target/doc/SDL_image.txt

cd ../..

makeInstaller $LIBNAME $VERSION zlib 1.2.5 libpng 1.4.4 jpeg 8.0 SDL 1.2.14

echo "Done!"
