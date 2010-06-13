#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libogg
VERSION=1.1.2

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./autogen.sh --host psp --prefix=$(pwd)/../target/psp

make

make install
mkdir -p $(pwd)/../target/doc
mv $(pwd)/../target/psp/share/doc/libogg-1.1.2 $(pwd)/../target/doc
rm -fR $(pwd)/../target/psp/share

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

