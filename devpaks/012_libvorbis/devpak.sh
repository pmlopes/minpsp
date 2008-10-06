#!/bin/sh
. ../util/util.sh

LIBNAME=libvorbis
VERSION=1.1.2

svnGetPS2DEV $LIBNAME

# need to remove /msys/local from the path only for the next lib
OLDPATH=$PATH
PATH=$(echo $PATH | sed 's/\/usr\/local\/bin://g')

AC_VERSION=$(autoconf --version | grep 2.56)
AM_VERSION=$(automake --version | grep 1.7)

if [ ! "$AC_VERSION" == "autoconf (GNU Autoconf) 2.56" ]; then
	if [ ! "$AM_VERSION" == "automake (GNU automake) 1.7.1" ]; then
		echo "You need to use automake 1.7"
		exit 1
	fi
	echo "You need to use autoconf 2.56"
	exit 1
fi

cd $LIBNAME

AR=psp-ar LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./autogen.sh --host psp --prefix=$(pwd)/../target/psp || { echo "Error configuring $LIBNAME"; exit 1; }

make || { echo "Error building $LIBNAME"; exit 1; }

# revert back to the original path
PATH=$OLDPATH
make install || { echo "Error installing $LIBNAME"; exit 1; }
mkdir -p $(pwd)/../target/doc
mv $(pwd)/../target/psp/share/doc/libvorbis-1.1.1 $(pwd)/../target/doc
rm -fR $(pwd)/../target/psp/share

cd ..

makeInstaller $LIBNAME $VERSION libogg 1.1.2

echo "Run the NSIS script now!"
