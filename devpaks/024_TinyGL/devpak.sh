#!/bin/sh

LIBNAME=TinyGL

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
#else
#	svn update $LIBNAME
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
	mkdir -p ../target/psp/include/GL ../target/psp/lib ../target/doc
	cp include/GL/*.h ../target/psp/include/GL
	cp lib/*.a ../target/psp/lib
	cp README ../target/doc/$LIBNAME.txt
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
