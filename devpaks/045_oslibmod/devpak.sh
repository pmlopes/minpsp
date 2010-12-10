#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=oslibmod
VERSION=2.10

svnGet build "http://tools.assembla.com/svn/oslibmod" trunk
cd build/trunk
make -s lib
mkdir -p ../target/psp/include/oslib
mkdir -p ../target/psp/include/oslib/intraFont
mkdir -p ../target/psp/include/oslib/libpspmath
mkdir -p ../target/psp/include/oslib/adhoc
mkdir -p ../target/psp/lib
mkdir -p ../target/doc

echo "Copying lib...."
cp -f  libosl.a ../target/psp/lib/

echo "Copying header files...."
cp -f intraFont/intraFont.h ../target/psp/include/oslib/intraFont/
cp -f intraFont/libccc.h ../target/psp/include/oslib/intraFont/
cp -f libpspmath/pspmath.h ../target/psp/include/oslib/libpspmath/
cp -f adhoc/pspadhoc.h ../target/psp/include/oslib/adhoc/
cp -f oslmath.h ../target/psp/include/oslib/
cp -f net.h ../target/psp/include/oslib/
cp -f browser.h ../target/psp/include/oslib/
cp -f audio.h ../target/psp/include/oslib/
cp -f bgm.h ../target/psp/include/oslib/
cp -f dialog.h ../target/psp/include/oslib/
cp -f drawing.h ../target/psp/include/oslib/
cp -f keys.h ../target/psp/include/oslib/
cp -f map.h ../target/psp/include/oslib/
cp -f messagebox.h ../target/psp/include/oslib/
cp -f osk.h ../target/psp/include/oslib/
cp -f saveload.h ../target/psp/include/oslib/
cp -f oslib.h ../target/psp/include/oslib/
cp -f text.h ../target/psp/include/oslib/
cp -f usb.h ../target/psp/include/oslib/
cp -f vfpu_ops.h ../target/psp/include/oslib/
cp -f VirtualFile.h ../target/psp/include/oslib/
cp -f vram_mgr.h ../target/psp/include/oslib/
cp -f ccc.h ../target/psp/include/oslib/
cp -f sfont.h ../target/psp/include/oslib/

doxygen

cp -fR OSLib_MOD_Documentation/html ../target/doc/oslibmod

cd ../..

makeInstaller $LIBNAME $VERSION zlib 1.2.5 libpng 1.4.4 mikmodlib 3.0 libpspmath 4 intraFont 0.31 

echo "Done!"
