#!/bin/bash
. ../util/util.sh

LIBNAME=freetype
VERSION=2.1.10

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME

cd builds/unix
automake --add-missing
cd ../..
sh autogen.sh
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
gcc -s -o target/bin/freetype-config freetype-config.c -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DFTVERSION=\"2.1.10\"

makeInstaller $LIBNAME $VERSION


echo "Run the NSIS script now!"
