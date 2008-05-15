#!/bin/sh

LIBNAME=intraFont
PKG=$LIBNAME\_0.22

if [ ! -d $LIBNAME ]
then
	wget http://www.psp-programming.com/benhur/$PKG.zip
	../../mingw/bin/unzip -q $PKG.zip
fi

if [ ! -f $LIBNAME-patched ]
then
	patch -p0 -d $LIBNAME -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	make install || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-devpaktarget
fi

cd ..

echo "Run the NSIS script now!"
