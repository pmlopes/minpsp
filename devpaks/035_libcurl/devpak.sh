#!/bin/sh
. ../util/util.sh

LIBNAME=libcurl
VERSION=7.15.1

svnGetPSPWARE $LIBNAME

cd $LIBNAME

LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspnet_inet -lpspnet_resolver -lpspuser" ./configure --host=psp --disable-shared --prefix=$(pwd)/../target/psp

make CFLAGS=-G0 || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }

cd ..

mkdir -p target/bin
rm -fR target/psp/bin
gcc -o target/bin/curl-config curl-config.c || exit 1
strip -s target/bin/curl-config.exe

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
