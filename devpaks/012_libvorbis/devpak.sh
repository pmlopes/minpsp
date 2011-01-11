#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libvorbis
VERSION=1.3.2

download build "http://downloads.xiph.org/releases/vorbis" $LIBNAME-$VERSION "tar.bz2"
cd build/$LIBNAME-$VERSION

LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lm -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp
make -s

make -s install

cd doc
make -s install
cd ..

mkdir -p ../target/doc
mv ../target/psp/share/doc/libvorbis-1.3.2 ../target/doc/libvorbis-1.3.2
rm -fR ../target/psp/share

cd ../..

makeInstaller $LIBNAME $VERSION libogg 1.2.1

echo "Done!"
