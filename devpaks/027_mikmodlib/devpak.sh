#!/bin/sh
. ../util/util.sh

LIBNAME=mikmodlib
VERSION=3.0

svnGetPS2DEV $LIBNAME

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make libs || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/include ../target/psp/lib ../target/doc/$LIBNAME
	cp include/* ../target/psp/include
	cp lib/* ../target/psp/lib
	cp docs/*.doc ../target/doc/$LIBNAME
	cp docs/*.txt ../target/doc/$LIBNAME
fi

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
