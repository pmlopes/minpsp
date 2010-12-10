#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=cal3d
VERSION=0.11.0

download build "http://download.gna.org/cal3d/sources" $LIBNAME-$VERSION "tar.gz"
cd build/$LIBNAME-$VERSION
LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc" LIBS="-lc -lpspnet -lpspnet_inet -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp
make -s
make -s install
mkdir -p ../target/man
cp -Rf ../target/psp/share/man/man1 ../target/man
rm -Rf ../target/psp/share

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
