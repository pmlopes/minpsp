#!/bin/bash
. ../util/util.sh

LIBNAME=pspgl
VERSION=2264

svnGetPS2DEV $LIBNAME

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
mkdir -p ../target/psp/include/GL ../target/psp/include/GLES
cp GL/*.h ../target/psp/include/GL
cp GLES/*.h ../target/psp/include/GLES
cp libGL.a ../target/psp/lib
cp libGLU.a ../target/psp/lib
cp libglut.a ../target/psp/lib
cp README ../target/doc/pspgl.txt
	
cd ..

makeInstaller $LIBNAME $VERSION

echo "Done!"

