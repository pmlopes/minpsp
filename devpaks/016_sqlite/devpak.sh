#!/bin/sh

LIBNAME=sqlite

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-configured ]
then
	export PSPDEV=$(psp-config --pspdev-path)
	LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host psp --disable-readline --disable-tcl --prefix=$(pwd)/../target/psp
	touch $LIBNAME-configured
fi

if [ ! -f $LIBNAME-build ]
then
	export PSPDEV=$(psp-config --pspdev-path)
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	make install || { echo "Error installing $LIBNAME"; exit 1; }
	rm -fR ../target/psp/lib/pkgconfig
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
