#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=cal3D
VERSION=0.10.0

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME
LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lstdc++ -lpsplibc -lpspuser" ./configure --host=psp --disable-shared --prefix=$(pwd)/../target/psp

LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lstdc++ -lpsplibc -lpspuser" make

LDFLAGS="-L$(psp-config --pspsdk-path)/lib" LIBS="-lstdc++ -lpsplibc -lpspuser" make install 
mkdir -p ../target/doc
cp README ../target/doc/$LIBNAME.txt

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

