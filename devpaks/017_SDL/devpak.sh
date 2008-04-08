#!/bin/sh

LIBNAME=SDL

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
	LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host psp --prefix=$(pwd)/../target/psp
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
	mkdir -p ../target ../target/doc
	mv ../target/psp/man ../target
	rm -fR ../target/psp/bin
	rm -fR ../target/psp/share
	cp README.PSP ../target/doc/$LIBNAME.txt
	touch $LIBNAME-devpaktarget
fi

cd ..
if [ ! -f $LIBNAME-config-native ]
then
	mkdir -p target/bin
	gcc -o target/bin/sdl-config -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DVERSION=\"1.2.9\" sdl-config.c || exit 1
	strip -s target/bin/sdl-config.exe
	touch $LIBNAME-config-native
fi

echo "Run the NSIS script now!"
