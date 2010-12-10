#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libogg
VERSION=1.2.1

download build "http://downloads.xiph.org/releases/ogg" $LIBNAME-$VERSION "tar.bz2"

cd build/$LIBNAME-$VERSION
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp

make -s
make -s install
mkdir -p $(pwd)/../target/doc
mv $(pwd)/../target/psp/share/doc/$LIBNAME-$VERSION $(pwd)/../target/doc
rm -fR $(pwd)/../target/psp/share

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
