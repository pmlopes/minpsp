#!/bin/bash
. ../util/util.sh

LIBNAME=giflib
VERSION=4.1.6

downloadHTTP http://surfnet.dl.sourceforge.net/sourceforge/giflib $LIBNAME-$VERSION.tar.bz2

if [ ! -d $LIBNAME ]
then
	tar -jxf $LIBNAME-$VERSION.tar.bz2 || { echo "Failed to download "$1; exit 1; }
	patch -p0 -d $LIBNAME-$VERSION -i ../../$LIBNAME-$VERSION.patch || { echo "Error patching $LIBNAME"; exit; }
fi

cd $LIBNAME-$VERSION

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

echo "Done!"

