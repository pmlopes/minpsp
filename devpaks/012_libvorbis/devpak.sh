#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libvorbis
VERSION=1.1.2

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./autogen.sh --host=psp --prefix=$(pwd)/../target/psp

make

make install
cd doc
make install
cd ..
mkdir -p ../target/doc
mv ../target/psp/share/doc/libvorbis-1.1.1 ../target/doc/libvorbis-1.1.2
rm -fR ../target/psp/share

cd ../..

makeInstaller $LIBNAME $VERSION libogg 1.1.2

echo "Done!"
