#!/bin/sh

LIBNAME=mxml-2.5

if [ ! -f $LIBNAME.tar.gz ]
then
	wget http://ftp.easysw.com/pub/mxml/2.5/${LIBNAME}.tar.gz
fi

if [ ! -d $LIBNAME ]
then
	tar -zxf ${LIBNAME}.tar.gz
fi

cd $LIBNAME
if [ ! -f $LIBNAME-configured ]
then
	CFLAGS="-G0" LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lstdc++ -lpsplibc -lpspuser" ./configure --host=psp --disable-shared --disable-threads --prefix=$(pwd)/../target/psp
	touch $LIBNAME-configured
fi

if [ ! -f $LIBNAME-patched ]
then
	patch -p0 -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
fi

if [ ! -f $LIBNAME-build ]
then
	echo "There will be an error during the test phase (it is expected)"
	make
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	make install || { echo "Error building $LIBNAME"; exit 1; }
	mv ../target/psp/share/doc ../target
	mv ../target/psp/share/man ../target
	rm -rf ../target/psp/share
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
