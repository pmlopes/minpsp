#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=bzip2
VERSION=1.0.4

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME
make

make PREFIX=$(pwd)/../target/psp install
mkdir -p $(pwd)/../target/doc
cp manual.html  $(pwd)/../target/doc/$LIBNAME.html

cd ../..
makeInstaller $LIBNAME $VERSION

echo "Done!"

