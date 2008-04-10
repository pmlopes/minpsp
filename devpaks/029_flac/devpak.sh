#!/bin/sh

LIBNAME=flac-1.2.1

if [ ! -d $LIBNAME ]
then
#	wget http://surfnet.dl.sourceforge.net/sourceforge/flac/$LIBNAME.tar.gz
	tar -zxf $LIBNAME.tar.gz
fi

if [ ! -f $LIBNAME-patched ]
then
	patch -p0 -d $LIBNAME -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	CFLAGS="-ffast-math -fsigned-char -G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --enable-maintainer-mode --host=psp --prefix=$(pwd)/../target/psp --with-ogg=$(psp-config --psp-prefix)
	cd src/libFLAC
	make || { echo "Error building $LIBNAME"; exit 1; }
	cd ../../include/FLAC
	make || { echo "Error building $LIBNAME"; exit 1; }
	cd ../..
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	cd src/libFLAC
	make install || { echo "Error building $LIBNAME"; exit 1; }
	cd ../../include/FLAC
	make install || { echo "Error building $LIBNAME"; exit 1; }
	cd ../..
	mkdir -p ../target/doc/$LIBNAME
	cp -fR doc/html/* ../target/doc/$LIBNAME
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
