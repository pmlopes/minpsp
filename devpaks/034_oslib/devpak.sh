#!/bin/sh
. ../util/util.sh

LIBNAME=OSlib
VERSION=2.10

downloadHTTP http://brunni.dev-fr.org/dl/psp OSLib_210_src.rar

if [ ! -d OSLib_210_src ]
then
	../../mingw/bin/UnRAR x OSLib_210_src.rar || { echo "Failed to download"; exit 1; }
fi

cp Doxyfile OSLib_210_src/$LIBNAME
cd OSLib_210_src/$LIBNAME
make lib

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

echo "Run the NSIS script now!"
