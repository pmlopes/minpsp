#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=ode
VERSION=0.11.1

download build "http://downloads.sourceforge.net/opende" $LIBNAME-$VERSION "tar.bz2"
cd build/$LIBNAME-$VERSION
CFLAGS="-G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc" LIBS="-lc -lpspuser" ./configure --host=psp --with-drawstuff=none --disable-demos --prefix=$(pwd)/../target/psp
make
make install

cd ..

mkdir -p target/bin
gcc -Wall -s -o target/bin/ode-config -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DVERSION=\"$VERSION\" ../ode-config.c

cd ..

# disabled since we need to patch extra stuff pspgl 2264
makeInstaller $LIBNAME $VERSION

echo "Done!"
