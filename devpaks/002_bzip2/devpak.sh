#!/bin/sh
. ../util/util.sh

LIBNAME=bzip2
VERSION=1.0.4

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME
make || { echo "Error building "$LIBNAME; exit 1; }

make PREFIX=$(pwd)/../target/psp install || { echo "Error installing "$LIBNAME; exit 1; }
mkdir -p $(pwd)/../target/doc
cp manual.html  $(pwd)/../target/doc/$LIBNAME.html

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
