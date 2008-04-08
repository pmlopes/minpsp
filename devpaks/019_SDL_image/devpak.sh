#!/bin/sh

LIBNAME=SDL_image

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-configured ]
then
	./autogen.sh
	AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host psp --with-sdl-prefix=$(psp-config --pspdev-path) --prefix=$(pwd)/../target/psp || { exit 1; }
	touch $LIBNAME-configured
fi

if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	make install || { echo "Error installing $LIBNAME"; exit 1; }
	mkdir -p ../target/doc
	cp README ../target/doc/SDL_image.txt
#	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
