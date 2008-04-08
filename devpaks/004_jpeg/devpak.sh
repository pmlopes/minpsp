#!/bin/sh

LIBNAME=jpeg

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
	mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
	cp jconfig.h jpeglib.h jmorecfg.h jerror.h ../target/psp/include
	cp libjpeg.a  ../target/psp/lib
	cp libjpeg.doc  ../target/doc
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
