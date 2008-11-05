#!/bin/sh
. ../util/util.sh

LIBNAME=intraFont
PKG=$LIBNAME\_0.22
VERSION=0.22

downloadHTTP http://www.psp-programming.com/benhur $PKG.zip

if [ ! -d $LIBNAME ]
then
	../../mingw/bin/unzip -q $PKG.zip
fi

if [ ! -f $LIBNAME-patched ]
then
	patch -p1 -d $LIBNAME -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
fi

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error building $LIBNAME"; exit 1; }

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
