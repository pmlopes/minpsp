#!/bin/sh

LIBNAME=lua

if [ ! -d $LIBNAME ]
then
	svn checkout svn://svn.pspdev.org/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make -f Makefile.psp || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/include ../target/psp/lib ../target/doc/lua
	cp src/lua.h src/luaconf.h src/lualib.h src/lauxlib.h etc/lua.hpp ../target/psp/include
	cp *.a ../target/psp/lib
	cp doc/manual.html ../target/doc/lua
	cp doc/contents.html ../target/doc/lua
	cp doc/logo.gif ../target/doc/lua
	cp doc/lua.css ../target/doc/lua

	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
