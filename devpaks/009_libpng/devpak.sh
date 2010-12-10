#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libpng
VERSION=1.4.4

download build "http://downloads.sourceforge.net/libpng" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp
make -s
make -s install
mkdir -p ../target/psp/sdk/samples/libpng/screenshot
cp screenshot/* ../target/psp/sdk/samples/libpng/screenshot

cd ../..

makeInstaller $LIBNAME $VERSION zlib 1.2.5

echo "Done!"
