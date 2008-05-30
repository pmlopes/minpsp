#!/bin/sh

LIBNAME=libAac

if [ ! -d $LIBNAME ]
then
	svn checkout --revision 1088 http://psp.jim.sh/svn/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update --revision 1088 $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/include ../target/psp/lib ../target/doc

	cp include/aaccommon.h ../target/psp/include
	cp include/aacdec.h ../target/psp/include
	cp include/statname.h ../target/psp/include
	cp lib/libAac.a ../target/psp/lib
	cp readme.txt ../target/doc/$LIBNAME.txt
	
	touch $LIBNAME-devpaktarget
fi

echo "Run the NSIS script now!"
