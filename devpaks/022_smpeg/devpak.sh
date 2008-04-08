#!/bin/sh

LIBNAME=smpeg-psp

if [ ! -d $LIBNAME ]
then
	svn checkout http://smpeg-psp.googlecode.com/svn/trunk $LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
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
	mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
	cp -v libsmpeg.a ../target/psp/lib
	cp -v *.h ../target/psp/include
	cp README ../target/doc/$LIBNAME.txt
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
