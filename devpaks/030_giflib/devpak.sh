#!/bin/sh
. ../util/util.sh

LIBNAME=giflib-4.1.6
VERSION=4.1.6

downloadHTTP http://surfnet.dl.sourceforge.net/sourceforge/giflib $LIBNAME.tar.bz2

if [ ! -d $LIBNAME ]
then
	tar -jxf $LIBNAME.tar.gz || { echo "Failed to download "$1; exit 1; }
fi

if [ ! -f $LIBNAME-patched ]
then
	patch -p0 -d $LIBNAME -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
fi

cd $LIBNAME

CFLAGS="-ffast-math -fsigned-char -G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host=psp --prefix=$(pwd)/../target/psp
cd lib
make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error building $LIBNAME"; exit 1; }
mkdir -p ../../target/doc/$LIBNAME
cp ../doc/* ../../target/doc/$LIBNAME
rm ../../target/doc/$LIBNAME/Makefile.*
rm ../../target/doc/$LIBNAME/Makefile

cd ../..	

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
