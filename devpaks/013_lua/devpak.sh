#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=lua
VERSION=5.1.4

download build "http://www.lua.org/ftp" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION

make -f Makefile.psp
make -f Makefile.psp TARGET=$(pwd)/../target/psp install

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
