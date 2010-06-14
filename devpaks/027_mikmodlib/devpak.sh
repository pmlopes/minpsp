#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=mikmodlib
VERSION=3.0

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME
make libs

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc/$LIBNAME
cp include/* ../target/psp/include
cp lib/* ../target/psp/lib
cp docs/*.doc ../target/doc/$LIBNAME
cp docs/*.txt ../target/doc/$LIBNAME

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
