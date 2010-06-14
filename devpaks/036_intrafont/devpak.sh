#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=intraFont
PKG=$LIBNAME\_0.31
VERSION=0.31

download build http://www.psp-programming.com/benhur $PKG zip $LIBNAME

cd build/$LIBNAME

make
make install

cd ../..

makeInstaller $LIBNAME $VERSION
# 2 mv for msys
mv build/intraFont-0.31-psp.tar.bz2 build/tmp
mv build/tmp build/intrafont-0.31.tar.bz2

echo "Done!"
