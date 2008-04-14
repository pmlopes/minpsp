#!/bin/sh

LIBNAME=tinyxml

if [ ! -d $LIBNAME ]
then
	wget http://surfnet.dl.sourceforge.net/sourceforge/tinyxml/${LIBNAME}_2_5_3.tar.gz
	tar -zxf ${LIBNAME}_2_5_3.tar.gz
fi

cp Makefile.PSP $LIBNAME

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make -f Makefile.PSP || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	make -f Makefile.PSP install || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-devpaktarget
fi

cd ..

echo "Run the NSIS script now!"
