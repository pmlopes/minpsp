#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=allegro
VERSION=4.4.1.1

download build "http://downloads.sourceforge.net/alleg" $LIBNAME-$VERSION tar.gz

cd build/$LIBNAME-$VERSION
cmake -G "Unix Makefiles" -DWANT_TESTS=off -DWANT_TOOLS=off -DWANT_LOGG=off -DWANT_ALLEGROGL=off -DSHARED=off -DCMAKE_TOOLCHAIN_FILE=cmake/Toolchain-psp-gcc.cmake -DCMAKE_INSTALL_PREFIX=../target/psp .
make
make install

cd ../..

makeInstaller $LIBNAME $VERSION zlib 1.2.2 libpng 1.2.8

echo "Done!"
