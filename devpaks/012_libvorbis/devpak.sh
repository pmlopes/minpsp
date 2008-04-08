#!/bin/sh

LIBNAME=libvorbis

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
	mkdir -p $(pwd)/../target/doc
	mv $(pwd)/../target/psp/share/doc/libvorbis-1.1.1 $(pwd)/../target/doc
	rm -fR $(pwd)/../target/psp/share
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
