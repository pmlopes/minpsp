#!/bin/sh

LIBNAME=pspirkeyb

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
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
	make install || { echo "Error installing $LIBNAME"; exit 1; }
	rm -fR ../target/psp/sdk/samples/irkeyb/keymap/.svn
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
