#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=zziplib
VERSION=0.13.38

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host psp --prefix=$(pwd)/../target/psp

make

make install
mkdir -p ../target/doc/$LIBNAME
cp docs/* ../target/doc/$LIBNAME

cd ../..

makeInstaller $LIBNAME $VERSION zlib 1.2.2

echo "Done!"

