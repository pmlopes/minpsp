#!/bin/sh
. ../util/util.sh

LIBNAME=libmad
VERSION=0.15.1

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME
make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp README ../target/doc/$LIBNAME.txt
cp include/mad.h ../target/psp/include
cp lib/libmad.a  ../target/psp/lib
cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
