#!/bin/sh
. ../util/util.sh

LIBNAME=freetype
VERSION=2.1.10

svnGetPS2DEV $LIBNAME

cd $LIBNAME
./autogen.sh
LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./configure --host psp --prefix=$(pwd)/../target/psp
make || { echo "Error building $LIBNAME"; exit 1; }

make install || { echo "Error installing $LIBNAME"; exit 1; }
rm -fR $(pwd)/../target/psp/bin
rm -fR $(pwd)/../target/psp/share
make refdoc || { echo "Error building $LIBNAME docs"; exit 1; }
mkdir -p $(pwd)/../target/doc/$LIBNAME
cp docs/reference/*.html $(pwd)/../target/doc/$LIBNAME
cd ..

mkdir -p target/bin
gcc -o target/bin/freetype-config freetype-config.c -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DFTVERSION=\"2.1.10\" || exit 1
strip -s target/bin/freetype-config.exe

makeInstaller $LIBNAME $VERSION zlib 1.2.2

echo "Run the NSIS script now!"
