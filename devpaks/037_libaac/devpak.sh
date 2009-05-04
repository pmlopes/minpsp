#!/bin/bash
. ../util/util.sh

LIBNAME=libAac
VERSION=1088

svnGetPS2DEV $LIBNAME --revision 1088

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc

cp include/aaccommon.h ../target/psp/include
cp include/aacdec.h ../target/psp/include
cp include/statname.h ../target/psp/include
cp lib/libAac.a ../target/psp/lib
cp readme.txt ../target/doc/$LIBNAME.txt
	
cd ..

makeInstaller $LIBNAME $VERSION

makeNSISInstaller $LIBNAME

echo "Done!"

