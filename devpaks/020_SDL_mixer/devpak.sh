#!/bin/bash
. ../util/util.sh

LIBNAME=SDL_mixer
VERSION=1.2.6

svnGetPS2DEV $LIBNAME

cd $LIBNAME

sh autogen.sh
AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host psp --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp --enable-music-mod || { exit 1; }

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p ../target/doc
cp README ../target/doc/SDL_mixer.txt

cd ..

makeInstaller $LIBNAME $VERSION libogg 1.1.2 libvorbis 1.1.2 SDL 1.2.9

echo "Done!"

