#!/bin/bash
. ../util/util.sh

LIBNAME=lua
VERSION=5.1

svnGetPS2DEV $LIBNAME

cleanUp $LIBNAME $VERSION

cd $LIBNAME

make -f Makefile.psp || { echo "Error building $LIBNAME"; exit 1; }

mkdir -p ../target/psp/include ../target/psp/lib ../target/doc/lua
cp src/lua.h src/luaconf.h src/lualib.h src/lauxlib.h etc/lua.hpp ../target/psp/include
cp *.a ../target/psp/lib
cp doc/manual.html ../target/doc/lua
cp doc/contents.html ../target/doc/lua
cp doc/logo.gif ../target/doc/lua
cp doc/lua.css ../target/doc/lua

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
