#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=bzip2
VERSION=1.0.6

download build "http://bzip.org/$VERSION" $LIBNAME-$VERSION "tar.gz"

cd build/$LIBNAME-$VERSION
make

make PREFIX=$(pwd)/../target/psp install
mkdir -p $(pwd)/../target/doc
cp manual.html  $(pwd)/../target/doc/$LIBNAME.html

cd ../..
makeInstaller $LIBNAME $VERSION

echo "Done!"

