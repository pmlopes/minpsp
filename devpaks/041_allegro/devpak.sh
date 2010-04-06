#!/bin/bash
. ../util/util.sh

LIBNAME=allegro
VERSION=4.2.3

downloadHTTP http://static.allegro.cc/file/library/$LIBNAME-$VERSION/$LIBNAME-$VERSION.tar.gz

if [ ! -d $LIBNAME-$VERSION ]
then
	tar -zxf $LIBNAME-$VERSION.tar.gz
fi

cd $LIBNAME-$VERSION

CFLAGS="-G0" LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lstdc++ -lpsplibc -lpspuser" ./configure --host=psp --disable-shared --disable-threads --prefix=$(pwd)/../target/psp

# patch -p0 -i ../../$LIBNAME-$VERSION.patch || { echo "Error patching $LIBNAME"; exit; }
make

make install || { echo "Error building $LIBNAME"; exit 1; }
mv ../target/psp/share/doc ../target
mv ../target/psp/share/man ../target
rm -rf ../target/psp/share

cd ..

makeInstaller $LIBNAME $VERSION

echo "Done!"

