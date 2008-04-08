#!/bin/sh

LIBNAME=libpthreadlite

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
#else
#	svn update $LIBNAME
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
	cp pthreadlite.h ../target/psp/include
	cp libpthreadlite.a ../target/psp/lib
	cp README ../target/doc/pthreadlite.txt
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
