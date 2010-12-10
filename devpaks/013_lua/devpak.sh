#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=lua
VERSION=5.1.4

download build "http://www.lua.org/ftp" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION

make -s -f Makefile.psp
make -s -f Makefile.psp TARGET=$(pwd)/../target/psp install

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
