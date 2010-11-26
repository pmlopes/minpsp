#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=Tremor
VERSION=1.0.2

svnGet build http://svn.xiph.org/trunk $LIBNAME

cd build/$LIBNAME
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./autogen.sh --host=psp --prefix=$(pwd)/../target/psp

make
make install

mkdir -p $(pwd)/../target/doc/$LIBNAME
cp doc/*.html $(pwd)/../target/doc/$LIBNAME
cp doc/*.css $(pwd)/../target/doc/$LIBNAME

cd ../..

makeInstaller lib$LIBNAME $VERSION

echo "Done!"
