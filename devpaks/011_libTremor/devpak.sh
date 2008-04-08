#!/bin/sh

LIBNAME=libTremor

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-configured ]
then
	LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./autogen.sh --host psp --prefix=$(pwd)/../target/psp
	touch $LIBNAME-configured
fi

if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	make install || { echo "Error installing $LIBNAME"; exit 1; }
	mkdir -p $(pwd)/../target/doc/$LIBNAME
	cp doc/*.html $(pwd)/../target/doc/$LIBNAME
	cp doc/*.css $(pwd)/../target/doc/$LIBNAME
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
