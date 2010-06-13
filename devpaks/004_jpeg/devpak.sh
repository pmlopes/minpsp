#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=jpeg
VERSION=6.2

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME
make

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp jconfig.h jpeglib.h jmorecfg.h jerror.h ../target/psp/include
cp libjpeg.a  ../target/psp/lib
cp libjpeg.doc  ../target/doc
cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
