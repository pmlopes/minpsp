#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL_gfx
VERSION=2.0.13

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

sh autogen.sh
AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host psp --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp --disable-mmx --disable-shared

make

make install
mkdir -p ../target/doc
cp -R Docs ../target/doc/SDL_gfx
rm -fR ../target/doc/SDL_gfx/Screenshots/.svn
rm -fR ../target/doc/SDL_gfx/.svn

cd ../..

makeInstaller $LIBNAME $VERSION SDL 1.2.9

echo "Done!"

