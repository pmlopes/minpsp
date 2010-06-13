#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=smpeg-psp
VERSION=0.4.5

svnGet build http://smpeg-psp.googlecode.com/svn/trunk $LIBNAME

cd build/$LIBNAME

make

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp -v libsmpeg.a ../target/psp/lib
cp -v *.h ../target/psp/include
cp README ../target/doc/$LIBNAME.txt
	
cd ../..

makeInstaller $LIBNAME $VERSION SDL 1.2.9

echo "Done!"

