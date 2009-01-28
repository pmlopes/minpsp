#!/bin/sh
. ../util/util.sh

LIBNAME=zziplib
VERSION=0.13.38

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME

LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host psp --prefix=$(pwd)/../target/psp

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p ../target/doc/$LIBNAME
cp docs/* ../target/doc/$LIBNAME

cd ..

makeInstaller $LIBNAME $VERSION zlib 1.2.2

echo "Run the NSIS script now!"
