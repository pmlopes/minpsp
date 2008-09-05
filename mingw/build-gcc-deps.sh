#!/bin/sh

#---------------------------------------------------------------------------------
# build and install zlib
#---------------------------------------------------------------------------------

if [ ! -f /mingw/include/zlib.h ]
then
	cd $ZLIB_SRCDIR
	
	if [ ! -f built-zlib ]
	then
		$MAKE || { echo "Error building ZLIB"; exit 1; }
		touch built-zlib
	fi

	if [ ! -f installed-zlib ]
	then
		$MAKE install prefix=/mingw || { echo "Error installing ZLIB"; exit 1; }
		touch installed-zlib
	fi
	
	cd $BUILDSCRIPTDIR
fi

#---------------------------------------------------------------------------------
# build and install pthreads-w32
#---------------------------------------------------------------------------------

if [ ! -f /usr/local/include/pthread.h ]
then
	cd $PTHREADS_SRCDIR
	
	if [ ! -f built-pthreads ]
	then
		$MAKE clean GC-static || { echo "Error building PTHREADS"; exit 1; }
		touch built-pthreads
	fi

	if [ ! -f installed-pthreads ]
	then
		mkdir -p /usr/local/lib /usr/local/include
	
		cp libpthreadGC2.a /usr/local/lib/libpthread.a
		cp pthread.h /usr/local/include/pthread.h
		cp semaphore.h /usr/local/include/semaphore.h
		cp sched.h /usr/local/include/sched.h
		touch installed-pthreads
	fi

	cd $BUILDSCRIPTDIR
fi

#---------------------------------------------------------------------------------
# build and install GMP
#---------------------------------------------------------------------------------

if [ ! -f /usr/local/include/gmp.h ]
then
	cd $GMP_SRCDIR
	
	if [ ! -f configured-gmp ]
	then
		./configure --prefix=/usr/local || { echo "Error configuring GMP"; exit 1; }
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
fi

#---------------------------------------------------------------------------------
# build and install MPFR
#---------------------------------------------------------------------------------

if [ ! -f /usr/local/include/mpfr.h ]
then
	cd $MPFR_SRCDIR
	
	if [ ! -f configured-mpfr ]
	then
		./configure --prefix=/usr/local --with-gmp=/usr/local || { echo "Error configuring MPFR"; exit 1; }
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
fi
