#!/bin/bash
. ../util/util.sh

LIBNAME=SDL_gfx
VERSION=2.0.13

svnGetPS2DEV $LIBNAME

cd $LIBNAME

sh autogen.sh
AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host psp --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp --disable-mmx --disable-shared || { exit 1; }

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p ../target/doc
cp -R Docs ../target/doc/SDL_gfx
rm -fR ../target/doc/SDL_gfx/Screenshots/.svn
rm -fR ../target/doc/SDL_gfx/.svn

cd ..

makeInstaller $LIBNAME $VERSION SDL 1.2.9

echo "Done!"

