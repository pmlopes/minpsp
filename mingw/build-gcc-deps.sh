#!/bin/sh

#---------------------------------------------------------------------------------
# build and install GMP
#---------------------------------------------------------------------------------

mkdir -p $target/gmp
cd $target/gmp

if [ ! -f configured-gmp ]
then
	../../$GMP_SRCDIR/configure \
		--prefix="$BUILDSCRIPTDIR/gcc-libs" --disable-nls \
			|| { echo "Error configuring GMP"; exit 1; }
	touch configured-gmp
fi

if [ ! -f built-gmp ]
then
	$MAKE || { echo "Error building GMP"; exit 1; }
	touch built-gmp
fi

if [ ! -f installed-gmp ]
then
	$MAKE install || { echo "Error installing GMP"; exit 1; }
	touch installed-gmp
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install MPFR
#---------------------------------------------------------------------------------

mkdir -p $target/mpfr
cd $target/mpfr

if [ ! -f configured-mpfr ]
then
	../../$MPFR_SRCDIR/configure \
		--prefix="$BUILDSCRIPTDIR/gcc-libs" --with-gmp="$BUILDSCRIPTDIR/gcc-libs" --disable-nls \
			|| { echo "Error configuring MPFR"; exit 1; }
	touch configured-mpfr
fi

if [ ! -f built-mpfr ]
then
	$MAKE || { echo "Error building MPFR"; exit 1; }
	touch built-mpfr
fi

if [ ! -f installed-mpfr ]
then
	$MAKE install || { echo "Error installing MPFR"; exit 1; }
	touch installed-mpfr
fi

cd $BUILDSCRIPTDIR
