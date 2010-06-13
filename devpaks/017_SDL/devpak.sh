#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=SDL
VERSION=1.2.9

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME
sh autogen.sh
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host psp --prefix=$(pwd)/../target/psp --enable-pspirkeyb

make

make install
mkdir -p ../target ../target/doc
mv ../target/psp/share/man ../target
rm -fR ../target/psp/share
cp README.PSP ../target/doc/$LIBNAME.txt

cd ..

mkdir -p target/bin

gcc -s -o target/bin/sdl-config -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DVERSION=\"$VERSION\" ../sdl-config.c

cd ..

makeInstaller $LIBNAME $VERSION pspgl 2264 pspirkeyb 0.0.4

echo "Done!"

