#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=Jello
VERSION=0.0.1

svnGet build http://jphysicmod.googlecode.com/svn/trunk PSP_JellyPhysic

cd build/PSP_JellyPhysic

make

mkdir -p ../target/psp/include/Jello ../target/psp/lib
cp *.h ../target/psp/include/Jello
cp libJello.a ../target/psp/lib

cd ../..

makeInstaller $LIBNAME $VERSION pspgl 2264

echo "Done!"
