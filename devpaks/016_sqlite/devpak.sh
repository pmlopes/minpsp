#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=sqlite
VERSION=3.3.17

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME
export PSPDEV=$(psp-config --pspdev-path)
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lpspuser" ./configure --host=psp --disable-readline --disable-tcl --prefix=$(pwd)/../target/psp

make

make install
rm -fR ../target/psp/lib/pkgconfig

cd ../..

makeInstaller $LIBNAME $VERSION

unset PSPDEV
echo "Done!"

