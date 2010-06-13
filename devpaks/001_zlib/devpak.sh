#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=zlib
VERSION=1.2.2

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME
make

mkdir -p ../target/psp/include ../target/psp/lib ../target/man/man3
cp zlib.h zconf.h ../target/psp/include
cp libz.a ../target/psp/lib
cp zlib.3 ../target/man/man3
	
cd ../..
makeInstaller $LIBNAME $VERSION

echo "Done!"

