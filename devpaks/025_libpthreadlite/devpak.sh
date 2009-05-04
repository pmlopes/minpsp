#!/bin/bash
. ../util/util.sh

LIBNAME=libpthreadlite
VERSION=2336

svnGetPS2DEV $LIBNAME


cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp pthreadlite.h ../target/psp/include
cp libpthreadlite.a ../target/psp/lib
cp README ../target/doc/pthreadlite.txt
	
cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
