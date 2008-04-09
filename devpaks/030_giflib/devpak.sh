#!/bin/sh

LIBNAME=giflib-4.1.6

if [ ! -d $LIBNAME ]
then
	wget http://surfnet.dl.sourceforge.net/sourceforge/giflib/$LIBNAME.tar.bz2
	tar -jxf $LIBNAME.tar.bz2
fi

if [ ! -f $LIBNAME-patched ]
then
	patch -p0 -d $LIBNAME -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	CFLAGS="-ffast-math -fsigned-char -G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp
	cd lib
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	make install || { echo "Error building $LIBNAME"; exit 1; }
	mkdir -p ../../target/doc/$LIBNAME
	cp ../doc/* ../../target/doc/$LIBNAME
	rm ../../target/doc/$LIBNAME/Makefile.*
	rm ../../target/doc/$LIBNAME/Makefile
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
