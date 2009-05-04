#!/bin/bash
. ../util/util.sh

LIBNAME=pthreads-emb-1.0
VERSION=1.0

downloadHTTP http://surfnet.dl.sourceforge.net/sourceforge/pthreads-emb $LIBNAME.tar.gz

if [ ! -d $LIBNAME ]
then
	tar -zxf $LIBNAME.tar.gz || { echo "Failed to unpack "$1; exit 1; }
fi

cd $LIBNAME

cd platform/psp
make || { echo "Error building $LIBNAME"; exit 1; }
cd ../..

mkdir -p ../target/psp/lib ../target/psp/include ../target/doc/$LIBNAME
cp platform/psp/libpthread-psp.a ../target/psp/lib
cp *.h ../target/psp/include
cp doc/* ../target/doc/$LIBNAME

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
