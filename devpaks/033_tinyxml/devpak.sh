#!/bin/sh
. ../util/util.sh

LIBNAME=tinyxml
VERSION=2.5.3

downloadHTTP http://surfnet.dl.sourceforge.net/sourceforge/tinyxml ${LIBNAME}_2_5_3.tar.gz
if [ ! -d $LIBNAME ]
then
	tar -zxf ${LIBNAME}_2_5_3.tar.gz
fi

cp Makefile.PSP $LIBNAME

cd $LIBNAME

make -f Makefile.PSP || { echo "Error building $LIBNAME"; exit 1; }

make -f Makefile.PSP install || { echo "Error building $LIBNAME"; exit 1; }

cd ..

makeInstaller $LIBNAME $VERSION

echo "Run the NSIS script now!"
