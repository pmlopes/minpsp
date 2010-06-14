#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=smpeg-psp
VERSION=0.4.5

svnGet build http://smpeg-psp.googlecode.com/svn trunk

cd build/trunk

make

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
cp -v libsmpeg.a ../target/psp/lib
cp -v *.h ../target/psp/include
cp README ../target/doc/$LIBNAME.txt

cd ..

mkdir -p target/bin

gcc -s -o target/bin/smpeg-config -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DVERSION=\"$VERSION\" ../smpeg-config.c

cd ..

makeInstaller $LIBNAME $VERSION SDL 1.2.9

echo "Done!"
