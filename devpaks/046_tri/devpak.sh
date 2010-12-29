#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=tri
VERSION=r93

svnGet build "http://tools.assembla.com/svn" "tri"
exit
cd build/tri

makeInstaller $LIBNAME $VERSION zlib 1.2.2 libpng 1.2.8 mikmodlib 3.0 libpspmath 4 intraFont 0.31 

echo "Done!"
