#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=zlib
VERSION=1.2.5

download build "http://www.zlib.net" $LIBNAME-$VERSION "tar.bz2"
cd build/$LIBNAME-$VERSION
make -s -f psp/Makefile

mkdir -p ../target/psp/include ../target/psp/lib ../target/man/man3
cp zlib.h zconf.h ../target/psp/include
cp libz.a ../target/psp/lib
cp zlib.3 ../target/man/man3

cd ../..
makeInstaller $LIBNAME $VERSION

echo "Done!"
