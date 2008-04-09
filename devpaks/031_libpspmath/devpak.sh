#!/bin/sh

LIBNAME=libpspmath

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/sdk/lib ../target/psp/sdk/include ../target/psp/sdk/samples/pspmath
	cp libpspmath.a ../target/psp/sdk/lib
	cp pspmath.h ../target/psp/sdk/include
	cp ../sample/* ../target/psp/sdk/samples/pspmath
	touch $LIBNAME-devpaktarget
fi

cd ..

echo "Run the NSIS script now!"
