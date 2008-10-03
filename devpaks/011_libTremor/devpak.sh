#!/bin/sh
. ../util/util.sh

LIBNAME=libTremor
VERSION=1.0.2

svnGetPS2DEV $LIBNAME

cd $LIBNAME
LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./autogen.sh --host psp --prefix=$(pwd)/../target/psp

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p $(pwd)/../target/doc/$LIBNAME
cp doc/*.html $(pwd)/../target/doc/$LIBNAME
cp doc/*.css $(pwd)/../target/doc/$LIBNAME

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
