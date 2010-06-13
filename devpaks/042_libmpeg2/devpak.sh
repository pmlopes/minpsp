#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libmpeg2
VERSION=0.5.1

download build http://libmpeg2.sourceforge.net/files $LIBNAME-$VERSION tar.gz

cd build/$LIBNAME-$VERSION

CFLAGS="-G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --disable-sdl --host=psp --prefix=$(pwd)/../target/psp

make

make install
mv ../target/psp/share/doc ../target
mv ../target/psp/share/man ../target
rm -rf ../target/psp/share
mkdir -p ../target/doc/$LIBNAME
cp doc/* ../target/doc/$LIBNAME
rm ../target/doc/$LIBNAME/Makefile.*
rm ../target/doc/$LIBNAME/Makefile

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
