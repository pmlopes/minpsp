#!/bin/sh
. ../util/util.sh

LIBNAME=SDL
VERSION=1.2.9

svnGetPS2DEV $LIBNAME

cd $LIBNAME
./autogen.sh
LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host psp --prefix=$(pwd)/../target/psp

make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p ../target ../target/doc
mv ../target/psp/share/man ../target
rm -fR ../target/psp/bin
rm -fR ../target/psp/share
cp README.PSP ../target/doc/$LIBNAME.txt

cd ..

mkdir -p target/bin
gcc -o target/bin/sdl-config -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DVERSION=\"1.2.9\" sdl-config.c || exit 1
strip -s target/bin/sdl-config.exe

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
