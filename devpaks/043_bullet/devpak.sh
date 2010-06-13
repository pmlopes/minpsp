#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=bullet
VERSION=2.70

download build http://bullet.googlecode.com/files $LIBNAME-$VERSION tgz

cd build/$LIBNAME-$VERSION

CFLAGS="-G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp

make
make install

mv ../target/psp/share/doc ../target
mv ../target/psp/share/man ../target
rm -rf ../target/psp/share
mkdir -p ../target/doc/$LIBNAME
cp doc/* ../target/doc/$LIBNAME
rm ../target/doc/$LIBNAME/Makefile.*
rm ../target/doc/$LIBNAME/Makefile

cd ..

makeInstaller $LIBNAME $VERSION

echo "Done!"

