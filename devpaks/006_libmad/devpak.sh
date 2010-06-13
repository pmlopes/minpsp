#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libmad
VERSION=0.15.1

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME
make

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp README ../target/doc/$LIBNAME.txt
cp include/mad.h ../target/psp/include
cp lib/libmad.a  ../target/psp/lib
cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

