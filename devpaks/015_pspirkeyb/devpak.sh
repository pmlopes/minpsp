#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=pspirkeyb
VERSION=0.0.4

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

make

make install
rm -fR ../target/psp/sdk/samples/irkeyb/keymap/.svn

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

