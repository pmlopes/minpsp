#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=zziplib
VERSION=0.13.59

download build "http://downloads.sourceforge.net/zziplib" $LIBNAME-$VERSION "tar.bz2"
cd build/$LIBNAME-$VERSION
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp --enable-builddir=psp
cd psp
make -s
make -s install
cd ..
mkdir -p ../target/doc
cp -Rf docs ../target/doc/$LIBNAME
mkdir -p ../target/man
cp -Rf ../target/psp/share/man/man3 ../target/man
rm -Rf ../target/psp/share
cd ../..

makeInstaller $LIBNAME $VERSION zlib 1.2.5

echo "Done!"

