#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=sqlite
VERSION=3.3.17

download build "http://mirrors.isc.org/pub/MidnightBSD/distfiles" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host=psp --disable-readline --disable-tcl --prefix=$(pwd)/../target/psp

PSPDEV=$(psp-config --pspdev-path) make -s
make -s install

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
