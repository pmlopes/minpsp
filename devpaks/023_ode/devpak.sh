#!/bin/bash
. ../util/util.sh

LIBNAME=ode
VERSION=0.5

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include/ode ../target/psp/include/drawstuff ../target/psp/lib ../target/doc/ode/pix
cp -v lib/libdrawstuff.a ../target/psp/lib
cp -v lib/libode.a ../target/psp/lib
cp -v include/*.h ../target/psp/include
cp -v include/ode/*.h ../target/psp/include/ode
cp -v include/drawstuff/*.h ../target/psp/include/drawstuff
cp -v ode/doc/ode.* ../target/doc/ode
cp -v ode/doc/pix/*.jpg ../target/doc/ode/pix
cp README ../target/doc/$LIBNAME.txt

cd ..

makeInstaller $LIBNAME $VERSION pspgl 2264

makeNSISInstaller $LIBNAME

echo "Done!"

