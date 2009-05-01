#!/bin/bash
. ../util/util.sh

LIBNAME=zlib
VERSION=1.2.2

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME
make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/man/man3
cp zlib.h zconf.h ../target/psp/include
cp libz.a ../target/psp/lib
cp zlib.3 ../target/man/man3
	
cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
