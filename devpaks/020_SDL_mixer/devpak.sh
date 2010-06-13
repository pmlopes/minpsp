#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL_mixer
VERSION=1.2.6

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

sh autogen.sh
AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host psp --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp --enable-music-mod

make

make install
mkdir -p ../target/doc
cp README ../target/doc/SDL_mixer.txt

cd ../..

makeInstaller $LIBNAME $VERSION libogg 1.1.2 libvorbis 1.1.2 SDL 1.2.9

echo "Done!"

