#!/bin/bash
. ../util/util.sh

LIBNAME=SDL_image
VERSION=1.2.4

svnGetPS2DEV $LIBNAME

cd $LIBNAME

sh autogen.sh
AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host psp --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp || { exit 1; }

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p ../target/doc
cp README ../target/doc/SDL_image.txt

cd ..

makeInstaller $LIBNAME $VERSION zlib 1.2.2 libpng 1.2.8 jpeg 6.2 SDL 1.2.9

echo "Done!"

