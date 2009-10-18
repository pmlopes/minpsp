#!/bin/bash
. ../util/util.sh

LIBNAME=OSLib
VERSION=2.10

downloadHTTP http://brunni.dev-fr.org/dl/psp OSLib_210_src.rar

if [ ! -d OSLib_210_src ]
then
	unrar x OSLib_210_src.rar || ../../../mingw/bin/UnRAR x OSLib_210_src.rar || { echo "Failed to download"; exit 1; }
	patch -p0 -d OSLib_210_src -i ../../OSLib.patch || { echo "Error patching OSLib"; exit; }
fi

cp ../Doxyfile OSLib_210_src/$LIBNAME
cd OSLib_210_src/$LIBNAME
make lib || { echo "Failed to build"; exit 1; }

mkdir -p ../../target/psp/include/oslib ../../target/psp/lib ../../target/doc/$LIBNAME
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

cp -fR ../../target/doc/oslib/html/* ../../target/doc/oslib
rm -fR ../../target/doc/oslib/html

cd ../..

makeInstaller $LIBNAME $VERSION zlib 1.2.2 libpng 1.2.8 libmikmod 3.1.11
mv build/OSLib-2.10.tar.bz2 build/oslib-2.10.tar.bz2

echo "Done!"

