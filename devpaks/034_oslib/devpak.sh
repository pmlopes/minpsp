#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=OSLib
VERSION=2.10

download build http://brunni.dev-fr.org/dl/psp OSLib_210_src rar

cd build

cp ../Doxyfile OSLib_210_src/$LIBNAME
cd OSLib_210_src/$LIBNAME
mv zlibInterface.h tmp
mv tmp zlibinterface.h
make lib

mkdir -p ../../target/psp/include/oslib ../../target/psp/lib ../../target/doc/Oslib
cp libosl.a ../../target/psp/lib

cp audio.h ../../target/psp/include/oslib
cp bgm.h ../../target/psp/include/oslib
cp drawing.h ../../target/psp/include/oslib
cp keys.h ../../target/psp/include/oslib
cp map.h ../../target/psp/include/oslib
cp messagebox.h ../../target/psp/include/oslib
cp oslib.h ../../target/psp/include/oslib
cp text.h ../../target/psp/include/oslib
cp vfpu.h ../../target/psp/include/oslib
cp VirtualFile.h ../../target/psp/include/oslib
cp vram_mgr.h ../../target/psp/include/oslib

doxygen

cp -fR ../../target/doc/Oslib/html/* ../../target/doc/Oslib
rm -fR ../../target/doc/Oslib/html

cd ../../..

makeInstaller $LIBNAME $VERSION zlib 1.2.2 libpng 1.2.8 libmikmod 3.1.11
# broke into 2 commands to make msys happy
mv build/OSLib-2.10-psp.tar.bz2 build/tmp
mv build/tmp build/oslib-2.10.tar.bz2

echo "Done!"
