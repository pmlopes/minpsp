#!/bin/sh

LIBNAME=zlib

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/include ../target/psp/lib ../target/man/man3
	cp zlib.h zconf.h ../target/psp/include
	cp libz.a ../target/psp/lib
	cp zlib.3 ../target/man/man3
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
