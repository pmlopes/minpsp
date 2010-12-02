#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL_ttf
VERSION=2.0.10

download build "http://www.libsdl.org/projects/SDL_ttf/release" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp --with-freetype-prefix=$(psp-config --pspdev-path) --without-x
make

make install
mkdir -p ../target/doc
cp README ../target/doc/SDL_ttf.txt

cd ../..

makeInstaller $LIBNAME $VERSION freetype 2.4.3 SDL 1.2.14

echo "Done!"
