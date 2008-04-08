#!/bin/sh

LIBNAME=pspgl

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
	mkdir -p ../target/psp/include/GL ../target/psp/include/GLES
	cp GL/*.h ../target/psp/include/GL
	cp GLES/*.h ../target/psp/include/GLES
	cp libGL.a ../target/psp/lib
	cp libGLU.a ../target/psp/lib
	cp libglut.a ../target/psp/lib
	cp README ../target/doc/pspgl.txt
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
