#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=giflib
VERSION=4.1.6

download build "http://downloads.sourceforge.net/giflib" $LIBNAME-$VERSION "tar.bz2"

cd build/$LIBNAME-$VERSION

CFLAGS="-ffast-math -fsigned-char -G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp
cd lib
make -s

make -s install
mkdir -p ../../target/doc/$LIBNAME
cp ../doc/* ../../target/doc/$LIBNAME
rm ../../target/doc/$LIBNAME/Makefile.*
rm ../../target/doc/$LIBNAME/Makefile

cd ../../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
