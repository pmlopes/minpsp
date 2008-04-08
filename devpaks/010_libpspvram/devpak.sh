#!/bin/sh

LIBNAME=libpspvram

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
	mkdir -p ../target/psp/lib ../target/psp/include
	cp -v libpspvram.a libpspvalloc.a ../target/psp/lib
	cp -v *.h ../target/psp/include
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
