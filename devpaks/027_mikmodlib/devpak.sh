#!/bin/sh

LIBNAME=mikmodlib

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
#else
#	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make libs || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/include ../target/psp/lib ../target/doc/$LIBNAME
	cp include/* ../target/psp/include
	cp lib/* ../target/psp/lib
	cp docs/*.doc ../target/doc/$LIBNAME
	cp docs/*.txt ../target/doc/$LIBNAME
fi

echo "Run the NSIS script now!"
