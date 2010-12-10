#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libmad
VERSION=0.15.1b

download build "http://downloads.sourceforge.net/mad" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
make -s

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp README ../target/doc/$LIBNAME.txt
cp mad.h ../target/psp/include
cp libmad.a  ../target/psp/lib
cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
