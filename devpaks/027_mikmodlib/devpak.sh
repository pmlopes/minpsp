#!/bin/bash
. ../util/util.sh

LIBNAME=mikmodlib
VERSION=3.0

svnGetPS2DEV $LIBNAME

cd $LIBNAME
make libs || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc/$LIBNAME
cp include/* ../target/psp/include
cp lib/* ../target/psp/lib
cp docs/*.doc ../target/doc/$LIBNAME
cp docs/*.txt ../target/doc/$LIBNAME

cd ..

makeInstaller $LIBNAME $VERSION

echo "Done!"
