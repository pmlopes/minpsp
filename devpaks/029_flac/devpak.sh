#!/bin/bash
. ../util/util.sh

LIBNAME=flac-1.2.1
VERSION=1.2.1

downloadHTTP http://surfnet.dl.sourceforge.net/sourceforge/flac $LIBNAME.tar.gz

if [ ! -d $LIBNAME ]
then
	tar -zxf $LIBNAME.tar.gz || { echo "Failed to download "$1; exit 1; }
	patch -p0 -d $LIBNAME -i ../../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }
fi

cd $LIBNAME

CFLAGS="-ffast-math -fsigned-char -G0" LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --enable-maintainer-mode --host=psp --prefix=$(pwd)/../target/psp --with-ogg=$(psp-config --psp-prefix)
cd src/libFLAC
make || { echo "Error building $LIBNAME"; exit 1; }
cd ../../include/FLAC
make || { echo "Error building $LIBNAME"; exit 1; }
cd ../..

cd src/libFLAC
make install || { echo "Error building $LIBNAME"; exit 1; }
cd ../../include/FLAC
make install || { echo "Error building $LIBNAME"; exit 1; }
cd ../..
mkdir -p ../target/doc/$LIBNAME
cp -fR doc/html/* ../target/doc/$LIBNAME

cd ..
	
makeInstaller $LIBNAME $VERSION libogg 1.1.2

echo "Done!"

