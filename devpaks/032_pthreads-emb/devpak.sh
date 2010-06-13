#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=pthreads-emb
VERSION=1.0

download build "http://downloads.sourceforge.net/pthreads-emb" $LIBNAME-$VERSION "tar.gz"

cd build/$LIBNAME-$VERSION

cd platform/psp
make
cd ../..

mkdir -p ../target/psp/lib ../target/psp/include ../target/doc/$LIBNAME
cp platform/psp/libpthread-psp.a ../target/psp/lib
cp *.h ../target/psp/include
cp doc/* ../target/doc/$LIBNAME

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
