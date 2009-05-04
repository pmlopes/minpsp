#!/bin/bash
. ../util/util.sh

LIBNAME=SDL_ttf
VERSION=2.0.7

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME

sh autogen.sh
AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host psp --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp --with-freetype-prefix=$(psp-config --pspdev-path) --without-x || { exit 1; }

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p ../target/doc
cp README ../target/doc/SDL_ttf.txt

cd ..

makeInstaller $LIBNAME $VERSION freetype 2.1.10 SDL 1.2.9

makeNSISInstaller $LIBNAME

echo "Done!"

