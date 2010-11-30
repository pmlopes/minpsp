#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL_gfx
VERSION=2.0.22

download build "http://downloads.sourceforge.net/sdlgfx" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
make -f Makefile.psp
mkdir -p ../target/psp/include/SDL ../target/psp/lib ../target/doc
cp libSDL_gfx.a ../target/psp/lib
cp SDL_framerate.h SDL_gfxPrimitives.h SDL_imageFilter.h SDL_rotozoom.h ../target/psp/include/SDL
cp -R Docs ../target/doc/SDL_gfx
rm ../target/doc/SDL_gfx/html.doxyfile

cd ../..

makeInstaller $LIBNAME $VERSION SDL 1.2.14

echo "Done!"
