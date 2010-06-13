#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=TinyGL
VERSION=0.4

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

make

mkdir -p ../target/psp/include/GL ../target/psp/lib ../target/doc
cp include/GL/*.h ../target/psp/include/GL
cp lib/*.a ../target/psp/lib
cp README ../target/doc/$LIBNAME.txt

cd ../..

makeInstaller $LIBNAME $VERSION SDL 1.2.9

echo "Done!"
