#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=freetype
VERSION=2.4.3

download build "http://download.savannah.gnu.org/releases/freetype" $LIBNAME-$VERSION "tar.bz2"

cd build/$LIBNAME-$VERSION
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp
make -s

make -s install
rm -fR $(pwd)/../target/psp/share
make -s refdoc
mkdir -p $(pwd)/../target/doc/$LIBNAME
cp docs/reference/*.html $(pwd)/../target/doc/$LIBNAME
cd ..

mkdir -p target/bin

gcc -s -o target/bin/freetype-config ../freetype-config.c -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DFTVERSION=\"$VERSION\"

cd ..
makeInstaller $LIBNAME $VERSION

echo "Done!"
