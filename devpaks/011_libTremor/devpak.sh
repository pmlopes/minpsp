#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libTremor
VERSION=1.0.2

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./autogen.sh --host psp --prefix=$(pwd)/../target/psp

make

make install
mkdir -p $(pwd)/../target/doc/$LIBNAME
cp doc/*.html $(pwd)/../target/doc/$LIBNAME
cp doc/*.css $(pwd)/../target/doc/$LIBNAME

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

