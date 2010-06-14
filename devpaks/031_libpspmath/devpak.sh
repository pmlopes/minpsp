#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=libpspmath
VERSION=4

cd build

cp -R ../libpspmath libpspmath
cp -R ../sample sample

cd $LIBNAME

make

mkdir -p ../target/psp/sdk/lib ../target/psp/sdk/include ../target/psp/sdk/samples/pspmath
cp libpspmath.a ../target/psp/sdk/lib
cp pspmath.h ../target/psp/sdk/include
cp ../sample/* ../target/psp/sdk/samples/pspmath

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

