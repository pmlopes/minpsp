#!/bin/sh
. ../util/util.sh

LIBNAME=smpeg-psp
VERSION=0.4.5

svnGet $LIBNAME http://smpeg-psp.googlecode.com/svn/trunk $LIBNAME

if [ ! -f $LIBNAME-patched ]
then
	patch -p0 -d $LIBNAME -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
	touch $LIBNAME-patched
fi

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp -v libsmpeg.a ../target/psp/lib
cp -v *.h ../target/psp/include
cp README ../target/doc/$LIBNAME.txt
	
cd ..

makeInstaller $LIBNAME $VERSION SDL 1.2.9

echo "Run the NSIS script now!"
