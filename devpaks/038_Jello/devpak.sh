#!/bin/sh

LIBNAME=Jello

if [ ! -d PSP_JellyPhysic ]
then
	svn checkout http://jphysicmod.googlecode.com/svn/trunk/PSP_JellyPhysic || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update PSP_JellyPhysic
fi

if [ ! -f $LIBNAME-patched ]
then
	patch -p0 -d PSP_JellyPhysic -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
fi

cd PSP_JellyPhysic

if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/include/Jello ../target/psp/lib
	cp *.h ../target/psp/include/Jello
	cp libJello.a ../target/psp/lib
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
