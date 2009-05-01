#!/bin/bash
. ../util/util.sh

LIBNAME=pspirkeyb
VERSION=0.0.4

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
rm -fR ../target/psp/sdk/samples/irkeyb/keymap/.svn

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
