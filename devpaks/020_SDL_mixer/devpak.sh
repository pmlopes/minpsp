#!/bin/sh
. ../util/util.sh

LIBNAME=SDL_mixer
VERSION=1.2.6

svnGetPS2DEV $LIBNAME

cd $LIBNAME

./autogen.sh
AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host psp --disable-music-mp3 --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp --disable-music-libmikmod --enable-music-mod || { exit 1; }

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p ../target/doc
cp README ../target/doc/SDL_mixer.txt

cd ..

makeInstaller $LIBNAME $VERSION libogg 1.1.2 libvorbis 1.1.2 SDL 1.2.9

echo "Run the NSIS script now!"
