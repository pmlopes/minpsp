#!/bin/bash
set -e
. ../util/util.sh

LIBNAME=lua
VERSION=5.1

svnGet build svn://svn.ps2dev.org/psp/trunk $LIBNAME

cd build/$LIBNAME

make -f Makefile.psp

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc/lua
cp src/lua.h src/luaconf.h src/lualib.h src/lauxlib.h etc/lua.hpp ../target/psp/include
cp *.a ../target/psp/lib
cp doc/manual.html ../target/doc/lua
cp doc/contents.html ../target/doc/lua
cp doc/logo.gif ../target/doc/lua
cp doc/lua.css ../target/doc/lua

cd ../..

makeInstaller $LIBNAME $VERSION

echo "Done!"

