#!/bin/bash
. ../util/util.sh

LIBNAME=libvorbis
VERSION=1.1.2

svnGetPS2DEV $LIBNAME

cd $LIBNAME

LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./autogen.sh --host=psp --prefix=$(pwd)/../target/psp || { echo "Error configuring $LIBNAME"; exit 1; }

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p $(pwd)/../target/doc
mv $(pwd)/../target/psp/share/doc/libvorbis-1.1.2 $(pwd)/../target/doc
rm -fR $(pwd)/../target/psp/share

cd ..

makeInstaller $LIBNAME $VERSION libogg 1.1.2

echo "Done!"
