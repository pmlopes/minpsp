#!/bin/sh

PS2DEV_SVN="http://psp.jim.sh/svn/psp/trunk/"
#PS2DEV_SVN="svn://svn.ps2dev.org/psp/trunk/"
SF_MIRROR="http://surfnet.dl.sourceforge.net/sourceforge"

GCC_VER=4.3.2
GCC_TC_VERSION=4.3.1
GMP_VER=4.2.3
MPFR_VER=2.3.1
GDB_VER=6.8
INSTALLDIR="/c/pspsdk"
INSTALLERDIR="/c/pspsdk-installer"
PSPSDK_VERSION=0.8.7

BINUTILS_VER=2.16.1
NEWLIB_VER=1.15.0
MINGW32_MAKE_VER=3.79.1-20010722
MINGW32_GROFF_VER=1.19.2
MINGW32_LESS_VER=394

GCC_CORE="gcc-core-$GCC_VER.tar.bz2"
GCC_GPP="gcc-g++-$GCC_VER.tar.bz2"
GMP="gmp-$GMP_VER.tar.bz2"
MPFR="mpfr-$MPFR_VER.tar.bz2"
BINUTILS="binutils-$BINUTILS_VER.tar.bz2"
NEWLIB="newlib-$NEWLIB_VER.tar.gz"
GDB="gdb-$GDB_VER.tar.bz2"
MINGW32_MAKE="make-$MINGW32_MAKE_VER.tar.gz"
UNXUTILS="UnxUtils.zip"
MINGW32_GROFF="groff-$MINGW32_GROFF_VER-bin.zip"
MINGW32_LESS="less-$MINGW32_LESS_VER-bin.zip"
MINGW32_LESS_DEP="less-$MINGW32_LESS_VER-dep.zip"

GCC_CORE_URL="http://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/$GCC_CORE"
GCC_GPP_URL="http://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/$GCC_GPP"
GMP_URL="http://ftp.gnu.org/gnu/gmp/$GMP"
MPFR_URL="http://www.mpfr.org/mpfr-current/$MPFR"
BINUTILS_URL="http://ftp.gnu.org/gnu/binutils/$BINUTILS"
NEWLIB_URL="ftp://sources.redhat.com/pub/newlib/$NEWLIB"
GDB_URL="http://ftp.gnu.org/gnu/gdb/$GDB"
MINGW32_MAKE_URL="$SF_MIRROR/mingw/$MINGW32_MAKE"
UNXUTILS_URL="$SF_MIRROR/unxutils/$UNXUTILS"
MINGW32_GROFF_URL="$SF_MIRROR/gnuwin32/$MINGW32_GROFF"
MINGW32_LESS_URL="$SF_MIRROR/gnuwin32/$MINGW32_LESS"
MINGW32_LESS_DEP_URL="$SF_MIRROR/gnuwin32/$MINGW32_LESS_DEP"

GMP_SRCDIR="gmp-$GMP_VER"
MPFR_SRCDIR="mpfr-$MPFR_VER"
BINUTILS_SRCDIR="binutils-$BINUTILS_VER"
GCC_SRCDIR="gcc-$GCC_VER"
GDB_SRCDIR="gdb-$GDB_VER"
NEWLIB_SRCDIR="newlib-$NEWLIB_VER"

MINGW32_MAKE_DIR="make-$MINGW32_MAKE_VER"
UNXUTILS_DIR="UnxUtils"
MINGW32_GROFF_DIR="groff-$MINGW32_GROFF_VER"
MINGW32_LESS_DIR="less-$MINGW32_LESS_VER"

builddir=psp
target=psp

#---------------------------------------------------------------------------------
# configuration finished
#---------------------------------------------------------------------------------
if test "`svn help`"
then
	SVN="svn"
else
	echo "ERROR: Please make sure you have 'subversion (svn)' installed."
	exit
fi

if test "`wget -V`"
then
	WGET=wget
else
	echo "ERROR: Please make sure you have 'wget' installed."
	exit
fi

[ ! -z "$INSTALLDIR" ] && mkdir -p $INSTALLDIR && touch $INSTALLDIR/nonexistantfile && rm $INSTALLDIR/nonexistantfile || exit 1;

if [ ! -f download_archives ]
then
	mkdir -p download
	cd download
	$WGET --passive-ftp -c $BINUTILS_URL || { echo "Error: Failed to download "$BINUTILS; exit; }
	$WGET -c $GMP_URL || { echo "Error: Failed to download "$GMP; exit; }
	$WGET -c $MPFR_URL || { echo "Error: Failed to download "$MPFR; exit; }
	$WGET -c $GCC_CORE_URL || { echo "Error: Failed to download "$GCC_CORE; exit; }
	$WGET -c $GCC_GPP_URL || { echo "Error: Failed to download "$GCC_GPP; exit; }
	$WGET -c $GDB_URL || { echo "Error: Failed to download "$GDB; exit; }
	$WGET --passive-ftp -c $NEWLIB_URL || { echo "Error: Failed to download "$NEWLIB; exit; }
	$WGET -c $MINGW32_MAKE_URL || { echo "Error: Failed to download "$MINGW32_MAKE; exit; }
	$WGET -c $UNXUTILS_URL || { echo "Error: Failed to download "$UNXUTILS; exit; }
	$WGET -c $MINGW32_GROFF_URL || { echo "Error: Failed to download "$MINGW32_GROFF; exit; }
	$WGET -c $MINGW32_LESS_URL || { echo "Error: Failed to download "$MINGW32_LESS; exit; }
	$WGET -c $MINGW32_LESS_DEP_URL || { echo "Error: Failed to download "$MINGW32_LESS_DEP; exit; }
	cd ..
	touch download_archives
fi


#---------------------------------------------------------------------------------
# find GCC version
#---------------------------------------------------------------------------------
GCC_VERSION=$(gcc --version|grep '(GCC) 4.3.0')
if [ ! "$GCC_VERSION" == "" ]; then
	echo "**************************************************************"
	echo "GCC 4.3.0 is known to have problems building GDB, I'll try to "
	echo "not assume warnings as errors during the build!"
	echo "**************************************************************"
	WITH_MINGW_GCC43=yes
else
	WITH_MINGW_GCC43=no
fi
export WITH_MINGW_GCC43

#---------------------------------------------------------------------------------
# find proper make
#---------------------------------------------------------------------------------
if [ -z "$MAKE" -a -x "$(which gnumake)" ]; then MAKE=$(which gnumake); fi
if [ -z "$MAKE" -a -x "$(which gmake)" ]; then MAKE=$(which gmake); fi
# msys make 3.81 was updated to support .S and .s distinguish and named cpmake
if [ -z "$MAKE" -a -x "$(which cpmake)" ]; then MAKE=$(which cpmake); fi
if [ -z "$MAKE" -a -x "$(which make)" ]; then MAKE=$(which make); fi
if [ -z "$MAKE" ]; then
	echo no make found
	exit 1
fi
echo use `$MAKE --version|grep Make` as make
export MAKE
  
#---------------------------------------------------------------------------------
# find proper gawk
#---------------------------------------------------------------------------------
if [ -z "$GAWK" -a -x "$(which gawk)" ]; then GAWK=$(which gawk); fi
if [ -z "$GAWK" -a -x "$(which awk)" ]; then GAWK=$(which awk); fi
if [ -z "$GAWK" ]; then
	echo no awk found
	exit 1
fi
echo use `$GAWK --version|grep Awk` as gawk
export GAWK

#---------------------------------------------------------------------------------
# find makeinfo, needed for newlib
#---------------------------------------------------------------------------------
if [ -z "$MAKEINFO" -a -x "$(which makeinfo)" ]; then MAKEINFO=$(which makeinfo); fi
if [ ! -x $(which makeinfo) ]; then
	echo makeinfo not found
	exit 1
fi
echo use `$MAKEINFO --version|grep texinfo` as makeinfo
export MAKEINFO

#---------------------------------------------------------------------------------
# Add installed devkit to the path, adjusting path on minsys
#---------------------------------------------------------------------------------
TOOLPATH=$(echo $INSTALLDIR | sed -e 's/^\([a-zA-Z]\):/\/\1/')
export PATH=$PATH:$TOOLPATH/bin

#---------------------------------------------------------------------------------
# Extract source packages
#---------------------------------------------------------------------------------
patchdir=$(pwd)/patches
scriptdir=$(pwd)/mingw

BUILDSCRIPTDIR=$(pwd)

if [ ! -f extracted_archives ]
then
	echo "Extracting $BINUTILS"
	tar -xjf $BUILDSCRIPTDIR/download/$BINUTILS || { echo "Error extracting "$BINUTILS; exit; }
	echo "Extracting $GMP"
	tar -xjf $BUILDSCRIPTDIR/download/$GMP || { echo "Error extracting "$GMP; exit; }
	echo "Extracting $MPFR"
	tar -xjf $BUILDSCRIPTDIR/download/$MPFR || { echo "Error extracting "$MPFR; exit; }
	echo "Extracting $GCC_CORE"
	tar -xjf $BUILDSCRIPTDIR/download/$GCC_CORE || { echo "Error extracting "$GCC_CORE; exit; }
	echo "Extracting $GCC_GPP"
	tar -xjf $BUILDSCRIPTDIR/download/$GCC_GPP || { echo "Error extracting "$GCC_GPP; exit; }
	echo "Extracting $NEWLIB"
	tar -xzf $BUILDSCRIPTDIR/download/$NEWLIB || { echo "Error extracting "$NEWLIB; exit; }
	echo "Extracting $GDB"
	tar -xjf $BUILDSCRIPTDIR/download/$GDB || { echo "Error extracting "$GDB; exit; }
	echo "Extracting $MINGW32_MAKE_DIR"
	mkdir $MINGW32_MAKE_DIR
	cd $MINGW32_MAKE_DIR
	tar -xzf $BUILDSCRIPTDIR/download/$MINGW32_MAKE || { echo "Error extracting "$MINGW32_MAKE; exit; }
	cd ..
	
	echo "Extracting $UNXUTILS"
	$scriptdir/bin/unzip -q $BUILDSCRIPTDIR/download/$UNXUTILS -d $UNXUTILS_DIR
	echo "Extracting $MINGW32_GROFF"
	$scriptdir/bin/unzip -q $BUILDSCRIPTDIR/download/$MINGW32_GROFF -d $MINGW32_GROFF_DIR
	echo "Extracting $MINGW32_LESS"
	$scriptdir/bin/unzip -q $BUILDSCRIPTDIR/download/$MINGW32_LESS -d $MINGW32_LESS_DIR
	echo "Extracting $MINGW32_LESS_DEP"
	$scriptdir/bin/unzip -q $BUILDSCRIPTDIR/download/$MINGW32_LESS_DEP -d $MINGW32_LESS_DIR
	
	touch extracted_archives
fi

#---------------------------------------------------------------------------------
# download patches
#---------------------------------------------------------------------------------
if [ ! -d patches ]
then
	svn checkout $PS2DEV_SVN/psptoolchain/patches || { echo "ERROR GETTING TOOLCHAIN PATCHES"; exit 1; }
else
	svn update patches
fi

cp -f $scriptdir/patches/* $patchdir

#---------------------------------------------------------------------------------
# apply patches
#---------------------------------------------------------------------------------
if [ ! -f patched_sources ]
then
	if [ -f $patchdir/binutils-$BINUTILS_VER-PSP.patch ]
	then
		patch -p1 -d $BINUTILS_SRCDIR -i $patchdir/binutils-$BINUTILS_VER-PSP.patch || { echo "Error patching binutils"; exit; }
	fi

	if [ -f $patchdir/gcc-$GCC_TC_VERSION-PSP.patch ]
	then
		patch -p1 -d $GCC_SRCDIR -i $patchdir/gcc-$GCC_TC_VERSION-PSP.patch || { echo "Error patching gcc"; exit; }
	fi

	if [ -f $patchdir/newlib-$NEWLIB_VER-PSP.patch ]
	then
		patch -p1 -d $NEWLIB_SRCDIR -i $patchdir/newlib-$NEWLIB_VER-PSP.patch || { echo "Error patching newlib"; exit; }
	fi

	if [ -f $patchdir/newlib-$NEWLIB_VER-MINPSPW.patch ]
	then
		patch -p1 -d $NEWLIB_SRCDIR -i $patchdir/newlib-$NEWLIB_VER-MINPSPW.patch || { echo "Error patching newlib (MINPSPW)"; exit; }
	fi
	
	if [ -f $patchdir/gdb-$GDB_VER-PSP.patch ]
	then
		patch -p1 -d $GDB_SRCDIR -i $patchdir/gdb-$GDB_VER-PSP.patch || { echo "Error patching gdb"; exit; }
	fi

	touch patched_sources
fi

#---------------------------------------------------------------------------------
# Build and install devkit components
#---------------------------------------------------------------------------------
# GCC 4.3 needs GMP and MPFR
if [ -f $scriptdir/build-gcc-deps.sh ]
then
	. $scriptdir/build-gcc-deps.sh || { echo "Error building toolchain"; exit; }
	cd $BUILDSCRIPTDIR
fi

if [ -f $scriptdir/build-gcc.sh ]
then
	. $scriptdir/build-gcc.sh || { echo "Error building toolchain"; exit; }
	cd $BUILDSCRIPTDIR
fi

if [ -f $scriptdir/build-tools.sh ]
then
	. $scriptdir/build-tools.sh || { echo "Error building tools"; exit; }
	cd $BUILDSCRIPTDIR
fi

if [ ! -f striped-binaries ]
then
	#---------------------------------------------------------------------------------
	# strip binaries
	# strip has trouble using wildcards so do it this way instead
	#---------------------------------------------------------------------------------
	for f in	$INSTALLDIR/bin/* \
				$INSTALLDIR/$target/bin/* \
				$INSTALLDIR/libexec/gcc/$target/$GCC_VER/*
	do
		strip $f
	done

	#---------------------------------------------------------------------------------
	# strip debug info from libraries
	#---------------------------------------------------------------------------------
	find $INSTALLDIR/lib/gcc -name *.a -exec $target-strip -d {} \;
	find $INSTALLDIR/$target -name *.a -exec $target-strip -d {} \;

	# strip corrupts this dll, so get it again
	cp $scriptdir/bin/cygwin1.dll $INSTALLDIR/bin/cygwin1.dll
	
	touch striped-binaries
fi

if [ ! -f patch-cmd ]
then
	patch -p1 -d $INSTALLDIR/psp/sdk -i $patchdir/pspsdk-CMD.patch || { echo "Error patching makefiles for Win CMD shell"; exit; }
	touch patch-cmd
fi

# add release notes
cp $BUILDSCRIPTDIR/readme.txt $INSTALLDIR/readme.txt

. $scriptdir/build-distro.sh
