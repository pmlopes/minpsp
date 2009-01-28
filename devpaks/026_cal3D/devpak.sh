#!/bin/sh
. ../util/util.sh

LIBNAME=cal3D
VERSION=0.10.0

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME

LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lstdc++ -lpsplibc -lpspuser" ./configure --host=psp --disable-shared --prefix=$(pwd)/../target/psp || { echo "Error building $LIBNAME"; exit 1; }

make || { echo "Error building $LIBNAME"; exit 1; }

make install
mkdir -p ../target/doc
cp README ../target/doc/$LIBNAME.txt

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
