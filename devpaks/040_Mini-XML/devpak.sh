#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=mxml
VERSION=2.5

download build http://ftp.easysw.com/pub/mxml/2.5 $LIBNAME-$VERSION tar.gz

cd build/$LIBNAME-$VERSION
CFLAGS="-G0" LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lstdc++ -lpsplibc -lpspuser" ./configure --host=psp --disable-shared --disable-threads --prefix=$(pwd)/../target/psp
patch -p0 -i ../../$LIBNAME-$VERSION-postconfig.patch
echo "There will be an error during the test phase (it is expected)"
make -s || true
make -s install
mv ../target/psp/share/doc ../target
mv ../target/psp/share/man ../target
rm -rf ../target/psp/share

cd ../..

makeInstaller $LIBNAME $VERSION
mv build/mxml-2.5-psp.tar.bz2 build/tmp
mv build/tmp build/Mini-XML-2.5.tar.bz2

echo "Done!"

