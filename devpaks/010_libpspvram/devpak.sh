#!/bin/sh
. ../util/util.sh

LIBNAME=libpspvram
VERSION=2227

svnGetPS2DEV $LIBNAME

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/lib ../target/psp/include
cp -v libpspvram.a libpspvalloc.a ../target/psp/lib
cp -v *.h ../target/psp/include

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
