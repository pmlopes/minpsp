#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=freetype
VERSION=2.1.10

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

sh autogen.sh
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host psp --prefix=$(pwd)/../target/psp
make

make install
rm -fR $(pwd)/../target/psp/share
make refdoc
mkdir -p $(pwd)/../target/doc/$LIBNAME
cp docs/reference/*.html $(pwd)/../target/doc/$LIBNAME
cd ..

mkdir -p target/bin

gcc -s -o target/bin/freetype-config ../freetype-config.c -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DFTVERSION=\"$VERSION\"

cd ..
makeInstaller $LIBNAME $VERSION

echo "Done!"

