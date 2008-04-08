#!/bin/sh

LIBNAME=libbulletml

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME/src
if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../../target/psp/include/bulletml ../../target/psp/lib ../../target/doc
	mkdir -p ../../target/psp/include/boost/config
	mkdir -p ../../target/psp/include/boost/config/stdlib
	mkdir -p ../../target/psp/include/boost/config/compiler
	mkdir -p ../../target/psp/include/boost/config/platform
	mkdir -p ../../target/psp/include/boost/detail
	cp bulletml*.h formula.h tree.h tinyxml/tinyxml.h ../../target/psp/include/bulletml
	find boost -name *.hpp -exec cp -R {} ../../target/psp/include/{} \;
	cp libbulletml.a ../../target/psp/lib
	cp ../README.en ../../target/doc/libbulletml.txt
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
