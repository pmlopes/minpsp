#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=tinyxml
VERSION=2.5.3

download build "http://downloads.sourceforge.net/tinyxml" ${LIBNAME}_2_5_3 "tar.gz"

cp Makefile.PSP build/$LIBNAME

cd build/$LIBNAME

make -f Makefile.PSP
make -f Makefile.PSP install

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

