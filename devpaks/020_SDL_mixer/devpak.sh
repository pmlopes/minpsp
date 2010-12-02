#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL_mixer
VERSION=1.2.11

download build "http://www.libsdl.org/projects/SDL_mixer/release" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
# disable flac because the build script cannot run cross compiled binaries on the host
CFLAGS="-G0 -g -O2" LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lvorbis -logg -lm -lc -lpspuser" ./configure --host=psp --disable-music-flac --enable-music-ogg-tremor --disable-music-cmd --prefix=$(pwd)/../target/psp
make
make install
mkdir -p ../target/doc
cp README ../target/doc/SDL_mixer.txt

cd ../..

makeInstaller $LIBNAME $VERSION libogg 1.2.1 libTremor 1.0.2 libvorbis 1.3.2 SDL 1.2.14

echo "Done!"
