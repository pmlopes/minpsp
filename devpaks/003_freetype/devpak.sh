#!/bin/sh

LIBNAME=freetype

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

if [ ! -f $LIBNAME-patched ]
then
	patch -p0 -d $LIBNAME -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
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
	rm -fR $(pwd)/../target/psp/bin
	rm -fR $(pwd)/../target/psp/share
	make refdoc || { echo "Error building $LIBNAME docs"; exit 1; }
	mkdir -p $(pwd)/../target/doc/$LIBNAME
	cp docs/reference/*.html $(pwd)/../target/doc/$LIBNAME
	touch $LIBNAME-devpaktarget
fi

cd ..
if [ ! -f $LIBNAME-config-native ]
then
	mkdir -p target/bin
	gcc -o target/bin/freetype-config freetype-config.c -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DFTVERSION=\"2.1.10\" || exit 1
	strip -s target/bin/freetype-config.exe
	touch $LIBNAME-config-native
fi

echo "Run the NSIS script now!"
