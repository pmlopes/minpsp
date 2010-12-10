#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=pspgl
VERSION=2264

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

make -s

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
mkdir -p ../target/psp/include/GL ../target/psp/include/GLES
cp GL/*.h ../target/psp/include/GL
cp GLES/*.h ../target/psp/include/GLES
cp libGL.a ../target/psp/lib
cp libGLU.a ../target/psp/lib
cp libglut.a ../target/psp/lib
cp README ../target/doc/pspgl.txt
	
cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

