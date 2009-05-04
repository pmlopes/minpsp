#!/bin/bash
. ../util/util.sh

LIBNAME=Jello
VERSION=0.0.1

svnGet PSP_JellyPhysic http://jphysicmod.googlecode.com/svn/trunk/PSP_JellyPhysic

cd PSP_JellyPhysic

make || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include/Jello ../target/psp/lib
cp *.h ../target/psp/include/Jello
cp libJello.a ../target/psp/lib
	
cd ..

makeInstaller $LIBNAME $VERSION pspgl 2264

echo "Run the NSIS script now!"
