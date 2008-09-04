#!/bin/sh

#---------------------------------------------------------------------------------
# build and install GMP
#---------------------------------------------------------------------------------

mkdir -p psp/gmp
cd psp/gmp

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

if [ ! -f check-gmp ]
then
	$MAKE check || { echo "Error checking GMP"; exit 1; }
	touch check-gmp
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

mkdir -p psp/mpfr
cd psp/mpfr

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

if [ ! -f check-mpfr ]
then
	$MAKE check || { echo "Error checking MPFR"; exit 1; }
	touch check-mpfr
fi

if [ ! -f installed-mpfr ]
then
	$MAKE install || { echo "Error installing MPFR"; exit 1; }
	touch installed-mpfr
fi

cd $BUILDSCRIPTDIR

#---------------------------------------------------------------------------------
# build and install pthreads-w32
#---------------------------------------------------------------------------------

cd $PTHREADS_SRCDIR

if [ ! -f built-pthreads ]
then
	$MAKE clean GC-static || { echo "Error building PTHREADS"; exit 1; }
	touch built-pthreads
fi

if [ ! -f installed-pthreads ]
then
	mkdir -p $BUILDSCRIPTDIR/gcc-libs/lib $BUILDSCRIPTDIR/gcc-libs/include
	
	cp libpthreadGC2.a $BUILDSCRIPTDIR/gcc-libs/lib/libpthread.a
	cp pthread.h $BUILDSCRIPTDIR/gcc-libs/include/pthread.h
	cp semaphore.h $BUILDSCRIPTDIR/gcc-libs/include/semaphore.h
	cp sched.h $BUILDSCRIPTDIR/gcc-libs/include/sched.h
	touch installed-pthreads
fi

cd $BUILDSCRIPTDIR
