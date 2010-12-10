#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=jpeg
VERSION=8b

download build "http://www.ijg.org/files" jpegsrc.v$VERSION "tar.gz"

cd build/$LIBNAME-$VERSION
make -s

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp jconfig.h jpeglib.h jmorecfg.h jerror.h ../target/psp/include
cp libjpeg.a  ../target/psp/lib
cp libjpeg.txt  ../target/doc
cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
