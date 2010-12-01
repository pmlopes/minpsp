#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libcurl
VERSION=7.15.1

svnGet build svn://svn.ps2dev.org/pspware/trunk $LIBNAME

cd build/$LIBNAME

LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspnet_inet -lpspnet_resolver -lpspuser" ./configure --host=psp --disable-shared --prefix=$(pwd)/../target/psp

make CFLAGS=-G0
make install

cd ..

mkdir -p target/bin
gcc -D__CURL_VERSION="\"$VERSION\"" -s -o target/bin/curl-config ../curl-config.c

cd ..

makeInstaller $LIBNAME $VERSION

echo "Done!"

