#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=cubicvr
VERSION=1232

svnGet build https://cubicvr.svn.sourceforge.net/svnroot/cubicvr/trunk cubicvr

cd build/$LIBNAME/psp
make
make install
cd ../../..

makeInstaller $LIBNAME $VERSION

echo "Done!"
