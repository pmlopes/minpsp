#!/bin/sh

LIBNAME=bzip2

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
	make PREFIX=$(pwd)/../target/psp install || { echo "Error installing $LIBNAME"; exit 1; }
	mkdir -p $(pwd)/../target/doc
	cp manual.html  $(pwd)/../target/doc/$LIBNAME.html
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
