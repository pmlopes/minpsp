#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=openTRI
VERSION=r45

svnGet build "http://svn2.assembla.com/svn/openTRI" "trunk"
cd build/trunk/src
FT=1 PNG=1 make install
cd ../../..

makeInstaller $LIBNAME $VERSION zlib 1.2.5 freetype 2.4.3 libpng 1.4.4

echo "Done!"
