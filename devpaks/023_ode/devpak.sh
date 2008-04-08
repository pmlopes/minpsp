#!/bin/sh

LIBNAME=ode

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
	mkdir -p ../target/psp/include/ode ../target/psp/include/drawstuff ../target/psp/lib ../target/doc/ode/pix
	cp -v lib/libdrawstuff.a ../target/psp/lib
	cp -v lib/libode.a ../target/psp/lib
	cp -v include/*.h ../target/psp/include
	cp -v include/ode/*.h ../target/psp/include/ode
	cp -v include/drawstuff/*.h ../target/psp/include/drawstuff
	cp -v ode/doc/ode.* ../target/doc/ode
	cp -v ode/doc/pix/*.jpg ../target/doc/ode/pix
	cp README ../target/doc/$LIBNAME.txt
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
