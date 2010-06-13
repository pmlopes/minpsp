#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=flac
VERSION=1.2.1

download build "http://downloads.sourceforge.net/flac" $LIBNAME-$VERSION "tar.gz"

cd build/$LIBNAME-$VERSION

CFLAGS="-ffast-math -fsigned-char -G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --enable-maintainer-mode --host=psp --prefix=$(pwd)/../target/psp --with-ogg=$(psp-config --psp-prefix)
cd src/libFLAC
make
cd ../../include/FLAC
make
cd ../..

cd src/libFLAC
make install
cd ../../include/FLAC
make install
cd ../..
mkdir -p ../target/doc/$LIBNAME
cp -fR doc/html/* ../target/doc/$LIBNAME

cd ../..

makeInstaller $LIBNAME $VERSION libogg 1.1.2

echo "Done!"
