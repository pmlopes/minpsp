#!/bin/sh

LIBNAME=pthreads-emb-1.0

if [ ! -d $LIBNAME ]
then
	wget http://surfnet.dl.sourceforge.net/sourceforge/pthreads-emb/$LIBNAME.tar.gz
	tar -zxf $LIBNAME.tar.gz
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	cd platform/psp
	make || { echo "Error building $LIBNAME"; exit 1; }
	cd ../..
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/lib ../target/psp/include ../target/doc/$LIBNAME
	cp platform/psp/libpthread-psp.a ../target/psp/lib
	cp *.h ../target/psp/include
	cp doc/* ../target/doc/$LIBNAME
	touch $LIBNAME-devpaktarget
fi

cd ..

echo "Run the NSIS script now!"
