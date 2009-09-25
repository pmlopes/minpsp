#!/bin/bash
. ../util/util.sh

LIBNAME=TinyGL
VERSION=0.4

svnGetPS2DEV $LIBNAME

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include/GL ../target/psp/lib ../target/doc
cp include/GL/*.h ../target/psp/include/GL
cp lib/*.a ../target/psp/lib
cp README ../target/doc/$LIBNAME.txt

cd ..

makeInstaller $LIBNAME $VERSION SDL 1.2.9

echo "Done!"

