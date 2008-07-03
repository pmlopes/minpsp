#!/bin/sh

LIBNAME=Jello

cd $LIBNAME
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
