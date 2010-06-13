#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL_ttf
VERSION=2.0.7

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

sh autogen.sh
AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host psp --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp --with-freetype-prefix=$(psp-config --pspdev-path) --without-x

make

make install
mkdir -p ../target/doc
cp README ../target/doc/SDL_ttf.txt

cd ../..

makeInstaller $LIBNAME $VERSION freetype 2.1.10 SDL 1.2.9

echo "Done!"

