#!/bin/bash
. ../util/util.sh

LIBNAME=cpplibs
VERSION=1547

svnGetPS2DEV $LIBNAME

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include/libpsp2d ../target/psp/include/libpspsnd ../target/psp/lib ../target/doc
cp libpsp2d/*.h ../target/psp/include/libpsp2d
cp libpsp2d/*.il ../target/psp/include/libpsp2d
cp libpsp2d/libpsp2d.a ../target/psp/lib

cp libpspsnd/*.h ../target/psp/include/libpspsnd
cp libpspsnd/libpspsnd.a  ../target/psp/lib
	
cp README ../target/doc/$LIBNAME.txt

cd ..

makeInstaller $LIBNAME $VERSION

makeNSISInstaller $LIBNAME

echo "Done!"

