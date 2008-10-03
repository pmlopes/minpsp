#!/bin/sh
. ../util/util.sh

LIBNAME=pspirkeyb
VERSION=0.0.4

svnGetPS2DEV $LIBNAME

if [ ! -f $LIBNAME-patched ]
then
	patch -p0 -d $LIBNAME -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
fi

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
rm -fR ../target/psp/sdk/samples/irkeyb/keymap/.svn

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
