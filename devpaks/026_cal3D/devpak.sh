#!/bin/sh

LIBNAME=cal3D

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f ../$LIBNAME-config ]
then
	LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lstdc++ -lpsplibc -lpspuser" ./configure --host=psp --disable-shared --prefix=$(pwd)/../target/psp || { echo "Error building $LIBNAME"; exit 1; }
	touch ../$LIBNAME-config
fi

if [ ! -f ../$LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch ../$LIBNAME-build
fi

if [ ! -f ../$LIBNAME-devpaktarget ]
then
	make install
	mkdir -p ../target/doc
	cp README ../target/doc/$LIBNAME.txt
	touch ../$LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
