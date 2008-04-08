#!/bin/sh

LIBNAME=libmikmod

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make -f Makefile.psp || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
	cp include/mikmod_build.h ../target/psp/include/mikmod.h
	cp libmikmod/libmikmod.a ../target/psp/lib
	cp docs/mikmod.html ../target/doc
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
