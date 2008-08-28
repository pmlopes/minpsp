#!/bin/sh

LANGUAGES="c,c++"

if [ "$WITH_MINGW_GCC43" == "yes" ]; then
	GDB_EXTRA_FLAGS="--disable-werror"
fi

mkdir -p $target/binutils
cd $target/binutils

if [ ! -f configured-binutils ]
then
	../../$BINUTILS_SRCDIR/configure \
		--prefix=$INSTALLDIR --target=$target --disable-nls --disable-shared --disable-debug \
		--disable-threads --with-gcc --with-gnu-as --with-gnu-ld --with-stabs \
		--with-gmp=$BUILDSCRIPTDIR/gcc-libs --with-mpfr=$BUILDSCRIPTDIR/gcc-libs \
			|| { echo "Error configuring binutils"; exit 1; }
	touch configured-binutils
fi

if [ ! -f built-binutils ]
then
	$MAKE -j 2 || { echo "Error building binutils"; exit 1; }
	touch built-binutils
fi

if [ ! -f installed-binutils ]
then
	$MAKE install || { echo "Error installing binutils"; exit 1; }
	touch installed-binutils
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install just the c compiler
#---------------------------------------------------------------------------------
mkdir -p $target/gcc
cd $target/gcc

if [ ! -f configured-gcc ]
then

	CFLAGS="-O2 -fomit-frame-pointer -D__USE_MINGW_ACCESS" \
	BOOT_CFLAGS="-O2 -fomit-frame-pointer -D__USE_MINGW_ACCESS" \
	BOOT_CXXFLAGS="-mthreads -fno-omit-frame-pointer -O2" \
	BOOT_LDFLAGS=-s \
	../../$GCC_SRCDIR/configure \
		--enable-languages=$LANGUAGES \
		--disable-multilib \
		--disable-shared --disable-win32-registry \
		--enable-cxx-flags="-G0" \
		--target=$target \
		--with-newlib \
		--prefix=$INSTALLDIR \
		--with-gmp=$BUILDSCRIPTDIR/gcc-libs --with-mpfr=$BUILDSCRIPTDIR/gcc-libs \
			|| { echo "Error configuring gcc"; exit 1; }
	touch configured-gcc
fi

if [ ! -f built-gcc ]
then
	$MAKE all-gcc || { echo "Error building gcc"; exit 1; }
	touch built-gcc
fi

if [ ! -f installed-gcc ]
then
	$MAKE install-gcc || { echo "Error installing gcc"; exit 1; }
	touch installed-gcc
fi

cd $BUILDSCRIPTDIR

if [ ! -d pspsdk ]
then
	svn checkout $PS2DEV_SVN/pspsdk || { echo "ERROR GETTING PSPSDK"; exit 1; }
else
	svn update pspsdk
fi

cd pspsdk
if [ ! -f bootstrap-sdk ]
then
	./bootstrap || { echo "ERROR RUNNING PSPSDK BOOTSTRAP"; exit 1; }
	touch bootstrap-sdk
fi

if [ ! -f configure-sdk ]
then
	./configure --with-pspdev="$INSTALLDIR" || { echo "ERROR RUNNING PSPSDK CONFIGURE"; exit 1; }
	touch configure-sdk
fi

if [ ! -f install-sdk-data ]
then
	$MAKE install-data || { echo "ERROR INSTALLING PSPSDK HEADERS"; exit 1; }
	touch install-sdk-data
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install newlib
#---------------------------------------------------------------------------------
mkdir -p $target/newlib
cd $target/newlib

if [ ! -f configured-newlib ]
then
	$BUILDSCRIPTDIR/$NEWLIB_SRCDIR/configure \
		--target=$target \
		--prefix=$INSTALLDIR \
		--with-gmp=$BUILDSCRIPTDIR/gcc-libs --with-mpfr=$BUILDSCRIPTDIR/gcc-libs \
			|| { echo "Error configuring newlib"; exit 1; }
	touch configured-newlib
fi

if [ ! -f built-newlib ]
then
	$MAKE -j 2 || { echo "Error building newlib"; exit 1; }
	touch built-newlib
fi

if [ ! -f installed-newlib ]
then
	$MAKE install || { echo "Error installing newlib"; exit 1; }
	touch installed-newlib
fi

cd $BUILDSCRIPTDIR


#---------------------------------------------------------------------------------
# build and install the final compiler
#---------------------------------------------------------------------------------

cd $target/gcc

if [ ! -f built-g++ ]
then
	$MAKE -j 2 || { echo "Error building g++"; exit 1; }
	touch built-g++
fi

if [ ! -f installed-g++ ]
then
	$MAKE install || { echo "Error installing g++"; exit 1; }
	touch installed-g++
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install the psp sdk
#---------------------------------------------------------------------------------
cd pspsdk

if [ ! -f built-sdk ]
then
	$MAKE -j 2 || { echo "ERROR BUILDING PSPSDK"; exit 1; }
	touch built-sdk
fi

if [ ! -f installed-sdk ]
then
	$MAKE install || { echo "ERROR INSTALLING PSPSDK"; exit 1; }
	touch installed-sdk
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install the debugger
#---------------------------------------------------------------------------------
mkdir -p $target/gdb
cd $target/gdb

if [ ! -f configured-gdb ]
then
	../../$GDB_SRCDIR/configure \
		--prefix=$INSTALLDIR --target=$target --disable-nls \
		--with-gmp=$BUILDSCRIPTDIR/gcc-libs --with-mpfr=$BUILDSCRIPTDIR/gcc-libs \
		$GDB_EXTRA_FLAGS \
			|| { echo "Error configuring gdb"; exit 1; }
	touch configured-gdb
fi

if [ ! -f built-gdb ]
then
	$MAKE -j 2 || { echo "Error building gdb"; exit 1; }
	touch built-gdb
fi

if [ ! -f installed-gdb ]
then
	$MAKE install || { echo "Error installing gdb"; exit 1; }
	touch installed-gdb
fi
