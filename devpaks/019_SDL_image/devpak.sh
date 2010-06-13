#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL_image
VERSION=1.2.4

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

sh autogen.sh
AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host psp --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp

make

make install
mkdir -p ../target/doc
cp README ../target/doc/SDL_image.txt

cd ../..

makeInstaller $LIBNAME $VERSION zlib 1.2.2 libpng 1.2.8 jpeg 6.2 SDL 1.2.9

echo "Done!"

