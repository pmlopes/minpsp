#!/bin/sh
. ../util/util.sh

LIBNAME=mxml-2.5
VERSION=2.5

downloadHTTP http://ftp.easysw.com/pub/mxml/2.5 $LIBNAME.tar.gz

if [ ! -d $LIBNAME ]
then
	tar -zxf $LIBNAME.tar.gz
fi

cd $LIBNAME

CFLAGS="-G0" LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lstdc++ -lpsplibc -lpspuser" ./configure --host=psp --disable-shared --disable-threads --prefix=$(pwd)/../target/psp

patch -p0 -i ../$LIBNAME.patch || { echo "Error patching $LIBNAME"; exit; }

echo "There will be an error during the test phase (it is expected)"
make

make install || { echo "Error building $LIBNAME"; exit 1; }
mv ../target/psp/share/doc ../target
mv ../target/psp/share/man ../target
rm -rf ../target/psp/share

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
