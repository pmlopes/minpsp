#!/bin/sh

LIBNAME=libcurl

if [ ! -d $LIBNAME ]
then
	svn checkout http://psp.jim.sh/svn/pspware/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-configured ]
then
	LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" \
	 	LIBS="-lc -lpspnet_inet -lpspnet_resolver -lpspuser" \
	 	./configure --host=psp --disable-shared --prefix=$(pwd)/../target/psp
	touch $LIBNAME-configured
fi

if [ ! -f $LIBNAME-build ]
then
	make CFLAGS=-G0 || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	make install || { echo "Error installing $LIBNAME"; exit 1; }
	touch $LIBNAME-devpaktarget
fi

cd ..
if [ ! -f $LIBNAME-config-native ]
then
	mkdir -p target/bin
	rm -fR target/psp/bin
	gcc -o target/bin/curl-config curl-config.c || exit 1
	strip -s target/bin/curl-config.exe
	touch $LIBNAME-config-native
fi


echo "Run the NSIS script now!"
