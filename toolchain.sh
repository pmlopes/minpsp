#!/bin/bash

#---------------------------------------------------------------------------------
# configuration
#---------------------------------------------------------------------------------

PS2DEVSVN_URL="svn://svn.pspdev.org/psp/trunk"
PS2DEVSVN_MIRROR="http://psp.jim.sh/svn/psp/trunk"

#SF_MIRROR="http://surfnet.dl.sourceforge.net/sourceforge"
SF_MIRROR="http://voxel.dl.sourceforge.net/sourceforge"

# testing
DISABLE_SVN=1

# sdk versions
BINUTILS_VER=2.18
GCC_VER=4.3.4
GCC_TC_VER=4.3.2
NEWLIB_VER=1.17.0
#debugger version
GDB_VER=6.8

# gcc >= 4.x deps versions
GMP_VER=4.2.4
# minimal is 2.3.2
MPFR_VER=2.4.1
## for gcc >= 4.4 (graphite)
PPL_VER=0.10.2
CLOOG_PPL_VER=0.15.7
MPC_VER=0.7
# for gcc >= 4.5 (lto)
LIBELF_VER=0.8.12

ZLIB_VER=1.2.3

LIBPDCURSES_VER=3.4
LIBREADLINE_VER=5.2

#extra deps version
MINGW32_MAKE_VER=3.79.1-20010722
MINGW32_GROFF_VER=1.19.2
MINGW32_LESS_VER=394

# package version
PSPSDK_VERSION=0.9.6

#---------------------------------------------------------------------------------
# functions
#---------------------------------------------------------------------------------

#arg1 func
function die {
	echo "Error: "$1
	exit 1
}


function prepare {

	mkdir -p psp/build
	mkdir -p deps
	
	export OS=$(uname -s)

	if [ "$OS" == "SunOS" ]; then
		INSTALLDIR="$(pwd)/../pspsdk"
		GMP_INCLUDE=/usr/include/gmp
		MPFR_INCLUDE=/usr/include/mpfr
		GMP_LIB=/usr/lib
		MPFR_LIB=/usr/lib
		GMP_PREFIX=/usr
		PPL_PREFIX=/usr
		
		if [ ! -e compat ]; then
			mkdir -p compat
			ln -s `which gcc-4.3.2` compat/gcc
			ln -s `which g++-4.3.2` compat/g++
			ln -s /opt/SunStudioExpress/bin/cc compat/cc
			ln -s /opt/SunStudioExpress/bin/CC compat/CC
			ln -s /usr/bin/automake-1.10 compat/automake
			ln -s /usr/bin/aclocal-1.10 compat/aclocal
		fi
		export PATH=$PATH:`pwd`/compat
	fi
		
	if [ "$OS" == "Linux" ]; then
		INSTALLDIR="$(pwd)/../pspsdk"
		GMP_INCLUDE=/usr/include
		MPFR_INCLUDE=/usr/include
		GMP_LIB=/usr/lib
		MPFR_LIB=/usr/lib
		GMP_PREFIX=/usr
		PPL_PREFIX=/usr
	fi

	# --- XP 32 bits
	if [ "$OS" == "MINGW32_NT-5.1" ]; then
		OS=MINGW32_NT
	fi
	# --- Vista 32 bits
	if [ "$OS" == "MINGW32_NT-6.0" ]; then
		OS=MINGW32_NT
	fi
	
	if [ "$OS" == "MINGW32_NT" ]; then
		INSTALLDIR="/c/pspsdk"
		INSTALLERDIR="/c/pspsdk-installer"
		GMP_INCLUDE=/usr/local/include
		MPFR_INCLUDE=/usr/local/include
		GMP_LIB=/usr/local/lib
		MPFR_LIB=/usr/local/lib
		GMP_PREFIX=/usr/local
		PPL_PREFIX=/usr/local

		#-----------------------------------------------------------------------------
		# pre requisites
		#-----------------------------------------------------------------------------
		# GCC
		installZlib
		installGMP
		installMPFR
		installPPL
		installCLOOGPPL
		installMPC
		installLIBELF
		# GDB
		installPDCURSES
		installREADLINE
	fi
	
	checkTool svn
	checkTool wget
	checkTool make
	checkTool gawk
	checkTool makeinfo
	checkTool python
	checkTool flex
	checkTool bison
	
	TOOLPATH=$(echo $INSTALLDIR | sed -e 's/^\([a-zA-Z]\):/\/\1/')
	[ ! -z "$INSTALLDIR" ] && mkdir -p $INSTALLDIR && touch $INSTALLDIR/nonexistantfile && rm $INSTALLDIR/nonexistantfile || exit 1;
	export PATH=$PATH:$TOOLPATH/bin
}

function checkTool {
	if [ -z $1 ]; then
		die "Please make sure you have '"$1"' installed."
	fi
}

# Gets the sources from the PS2DEV SVN reppo,
# if it fails again use a local backup
# on failure tries to fallback to JimParis mirror,
#arg1 devpak
function svnGetPS2DEV {
	if [ ! -d $(basename $1) ]
	then
		if [ "$DISABLE_SVN" == "1" ]; then
			cp -fR ../ps2dev/psp-svn/$1 $(basename $1) || svn checkout $PS2DEVSVN_MIRROR/$1 || die "ERROR GETTING "$1
		else
			svn checkout $2 $3 $PS2DEVSVN_URL/$1 || cp -fR ../ps2dev/psp-svn/$1 $(basename $1) || svn checkout $PS2DEVSVN_MIRROR/$1 || die "ERROR GETTING "$1
		fi
	else
		if [ ! "$DISABLE_SVN" == "1" ]; then
		  svn update $2 $3 $(basename $1)
		fi
	fi
}

#arg1 file
#arg2 from
#arg3 to
function installFile {
	cp $2/$1 $INSTALLDIR/$3/$1 || die "Failed to install file "$1
}

#arg1 from
#arg2 to
function installDir {
	cp -fR $1 $INSTALLDIR/$2 || die "Failed to install dir "$1
}

# arg1 base
# arg2 file
# arg3 url
function downloadHTTP {
	if [ ! -f $1/$2 ]
	then
		cd $1
		wget -c $3/$2 || die "Failed to download "$2
		cd ..
	fi

}

# arg1 base
# arg2 file
# arg3 url
function downloadFTP {
	if [ ! -f $1/$2 ]
	then
		cd $1
		wget --passive-ftp -c $3/$2 || die "Failed to download "$2
		cd ..
	fi

}

#arg1 base path
#arg2 devpak folder number
#arg3 devpak
#arg4 installer path
function buildAndInstallDevPak {
	cd $1 || exit 1
	cd $2_$3 || exit 1
	rm -Rf build
	./devpak.sh || exit 1
	cd $(psp-config --pspdev-path) || exit 1
	tar xjfv $1/$2_$3/build/$3-*.tar.bz2 || exit 1
	# only install if we are on windows
	if [ "$OS" == "MINGW32_NT" ]; then
		cd $4 || exit 1
		tar xjfv $1/$2_$3/build/$3-*.tar.bz2 || exit 1
	fi
}

function installZlib {
	if [ ! -f /mingw/include/zlib.h ]
	then
		ZLIB="zlib-"$ZLIB_VER".tar.gz"

		downloadHTTP deps $ZLIB "http://www.zlib.net"
		cd deps
		tar -xzf $ZLIB || die "extracting "$ZLIB

		cd "zlib-"$ZLIB_VER
		make CC=gcc || die "building "$ZLIB
		make install prefix=/mingw || die "installing "$ZLIB
		cd ../..
	fi
}

function installGMP {
	if [ ! -f /usr/local/include/gmp.h ]
	then
		GMP="gmp-"$GMP_VER".tar.bz2"
		
		downloadHTTP deps $GMP "http://ftp.gnu.org/gnu/gmp"
		cd deps
		tar -xjf $GMP || die "extracting "$GMP

		cd "gmp-"$GMP_VER
		./configure \
			--build=pentium3-pc-mingw32 \
			--prefix=/usr/local --enable-cxx || die "configuring gmp"
		make || die "building gmp"
		make check || die "checking gmp"
		make install || die "installing gmp"
		cd ../..
	fi
}

function installMPFR {
	if [ ! -f /usr/local/include/mpfr.h ]
	then
		MPFR="mpfr-"$MPFR_VER".tar.bz2"
		
		downloadHTTP deps $MPFR "http://www.mpfr.org/mpfr-"$MPFR_VER
		cd deps
		tar -xjf $MPFR || die "extracting "$MPFR

		cd "mpfr-"$MPFR_VER
		./configure \
			 --build=pentium3-pc-mingw32 \
			--prefix=/usr/local \
			--with-gmp-include=$GMP_INCLUDE --with-gmp-lib=$GMP_LIB || die "configuring mpfr"
		make || die "building mpfr"
		make check || die "checking mpfr"
		make install || die "installing mpfr"
		cd ../..
	fi
}

function installPPL {
	if [ ! -f /usr/local/include/ppl_c.h ]
	then
		PPL="ppl-"$PPL_VER".tar.bz2"
		
		downloadHTTP deps $PPL "http://www.cs.unipr.it/ppl/Download/ftp/releases/"$PPL_VER
		cd deps
		tar -xjf $PPL || die "extracting "$PPL

		cd "ppl-"$PPL_VER
		./configure \
			 --build=pentium3-pc-mingw32 \
			--prefix=/usr/local \
			--with-libgmp-prefix=$GMP_PREFIX \
			--with-libgmpxx-prefix=$GMP_PREFIX || die "configuring ppl"
		make || die "building ppl"
		make check || die "checking ppl"
		make install || die "installing ppl"
		cd ../..
	fi
}

function installCLOOGPPL {
	if [ ! -f /usr/local/include/cloog/cloog.h ]
	then
		CLOOG_PPL="cloog-ppl-"$CLOOG_PPL_VER".tar.gz"
		
		downloadFTP deps $CLOOG_PPL "ftp://gcc.gnu.org/pub/gcc/infrastructure"
		cd deps
		tar -xzf $CLOOG_PPL || die "extracting "$CLOOG_PPL

		cd "cloog-ppl-"$CLOOG_PPL_VER
		./configure \
			 --build=pentium3-pc-mingw32 \
			--prefix=/usr/local \
			--with-gmp-include=$GMP_INCLUDE --with-gmp-library=$GMP_LIB \
			--with-ppl=$PPL_PREFIX || die "configuring cloog-ppl"
		make || die "building cloog-ppl"
		make check || die "checking cloog-ppl"
		make install || die "installing cloog-ppl"
		cd ../..
	fi
}

function installMPC {
	if [ ! -f /usr/local/include/mpc.h ]
	then
		MPC="mpc-"$MPC_VER".tar.gz"
		
		downloadHTTP deps $MPC "http://www.multiprecision.org/mpc/download"
		cd deps
		tar -xzf $MPC || die "extracting "$MPC

		cd "mpc-"$MPC_VER
		./configure \
			 --build=pentium3-pc-mingw32 \
			--prefix=/usr/local \
			--enable-static --disable-shared \
			--with-gmp-include=$GMP_INCLUDE --with-gmp-lib=$GMP_LIB \
			--with-mpfr-include=$MPFR_INCLUDE --with-mpfr-lib=$MPFR_LIB || die "configuring mpc"
		make || die "building mpc"
		make check || die "checking mpc"
		make install || die "installing mpc"
		cd ../..
	fi
}

function installLIBELF {
	if [ ! -f /usr/local/include/libelf.h ]
	then
		LIBELF="libelf-"$LIBELF_VER".tar.gz"
		
		downloadHTTP deps $LIBELF "http://www.mr511.de/software"
		cd deps
		tar -xzf $LIBELF || die "extracting "$LIBELF

		cd "libelf-"$LIBELF_VER
		./configure \
			--prefix=/usr/local \
			--disable-shared || die "configuring libelf"
		make || die "building libelf"
		make install || die "installing libelf"
		cd ../..
	fi
}

function installPDCURSES {
	if [ ! -f /mingw/include/curses.h ]
	then
		LIBPDCURSES="PDCurses-"$LIBPDCURSES_VER".tar.gz"
		
		downloadHTTP deps $LIBPDCURSES $SF_MIRROR"/pdcurses"
		cd deps
		tar -xzf $LIBPDCURSES || die "extracting "$LIBPDCURSES

		cd "PDCurses-"$LIBPDCURSES_VER/win32
		make -f mingwin32.mak DLL=n
		cp pdcurses.a /mingw/lib/libcurses.a
		cp pdcurses.a /mingw/lib/libpanel.a
		cp ../curses.h /mingw/include
		cp ../panel.h /mingw/include
		cd ../../..
	fi
}

function installREADLINE {
	if [ ! -f /mingw/include/readline/readline.h ]
	then
		LIBREADLINE="readline-"$LIBREADLINE_VER".tar.gz"
		
		downloadFTP deps $LIBREADLINE "ftp://ftp.gnu.org/gnu/readline"
		cd deps
		tar -xzf $LIBREADLINE || die "extracting "$LIBREADLINE

		cd "readline-"$LIBREADLINE_VER
		./configure \
			--prefix=/mingw \
			--with-curses \
			--disable-shared || die "configuring readline"
		make || die "building readline"
		make install || die "installing readline"
		cd ../..
	fi
}

function downloadPatches {
	cd psp
	svnGetPS2DEV psptoolchain/patches

	cp ../mingw/patches/* patches || die "adding MinPSPW patches"
	cd ..
}

function buildBinutils {
	BINUTILS="binutils-"$BINUTILS_VER".tar.bz2"
	BINUTILS_SRCDIR="binutils-"$BINUTILS_VER
	
	downloadFTP psp $BINUTILS "http://ftp.gnu.org/gnu/binutils"
	
	if [ ! -d psp/$BINUTILS_SRCDIR ]
	then
		cd psp
		tar -xjf $BINUTILS || die "extracting "$BINUTILS
		patch -p1 -d $BINUTILS_SRCDIR -i ../patches/binutils-$BINUTILS_VER-MINPSPW.patch || die "patching binutils"
		cd ..
	fi
	
	if [ ! -d psp/build/$BINUTILS_SRCDIR ]
	then
		mkdir -p psp/build/$BINUTILS_SRCDIR
		cd psp/build/$BINUTILS_SRCDIR
	
		../../$BINUTILS_SRCDIR/configure \
				--prefix=$INSTALLDIR \
				--target=psp \
				--enable-install-libbfd \
				--disable-werror \
				--disable-nls || die "configuring binutils"
	else
		cd psp/build/$BINUTILS_SRCDIR
		make clean
	fi

	make LDFLAGS="-s" || die "Error building binutils"
	make install || die "Error installing binutils"
	cd ../../..
}

# build a compiler so we can bootstrap the SDK and the newlib
function buildXGCC {
	GCC_CORE="gcc-core-"$GCC_VER".tar.bz2"
	GCC_GPP="gcc-g++-"$GCC_VER".tar.bz2"
	GCC_OBJC="gcc-objc-"$GCC_VER".tar.bz2"
	
	GCC_SRCDIR="gcc-"$GCC_VER
	
	downloadHTTP psp $GCC_CORE "http://ftp.gnu.org/gnu/gcc/gcc-"$GCC_VER
	downloadHTTP psp $GCC_GPP "http://ftp.gnu.org/gnu/gcc/gcc-"$GCC_VER
	downloadHTTP psp $GCC_OBJC "http://ftp.gnu.org/gnu/gcc/gcc-"$GCC_VER
	
	if [ ! -d psp/$GCC_SRCDIR ]
	then
		cd psp
		tar -xjf $GCC_CORE || die "extracting "$GCC_CORE
		tar -xjf $GCC_GPP || die "extracting "$GCC_GPP
		tar -xjf $GCC_OBJC || die "extracting "$GCC_OBJC
		patch -p1 -d $GCC_SRCDIR -i ../patches/gcc-$GCC_TC_VER-PSP.patch || die "patching gcc"
		cd ..
	fi

	if [ ! -d psp/build/$GCC_SRCDIR ]
	then
		mkdir -p psp/build/$GCC_SRCDIR
		cd psp/build/$GCC_SRCDIR
	
		../../$GCC_SRCDIR/configure \
				--prefix=$INSTALLDIR \
				--target=psp \
				--enable-languages="c" \
				--with-newlib \
				--without-headers \
				--disable-libssp \
				--disable-win32-registry \
				--disable-nls \
				--with-gmp-include=$GMP_INCLUDE --with-gmp-lib=$GMP_LIB \
				--with-mpfr-include=$MPFR_INCLUDE --with-mpfr-lib=$MPFR_LIB || die "configuring gcc"
	else
		cd psp/build/$GCC_SRCDIR
		make clean
	fi

	if [ "$OS" == "MINGW32_NT" ]; then
		make CFLAGS="-D__USE_MINGW_ACCESS" LDFLAGS="-s" all-gcc || die "building gcc"
	else
		make LDFLAGS="-s" all-gcc || die "building gcc"
	fi

	make install-gcc || die "installing gcc"
	cd ../../..
}

function bootstrapSDK {
	cd psp
	if [ ! -d pspsdk ]
	then
		svnGetPS2DEV pspsdk
		# some SDK files are in DOS format, fix back to UNIX
		awk '{ sub("\r$", ""); print }' pspsdk/src/samples/Makefile.am > tmp
		mv -f tmp pspsdk/src/samples/Makefile.am
		awk '{ sub("\r$", ""); print }' pspsdk/src/base/build.mak > tmp
		mv -f tmp pspsdk/src/base/build.mak
		patch -p1 -d pspsdk -i ../patches/pspsdk-MINPSPW.patch || die "patching pspsdk"
	else
		svnGetPS2DEV pspsdk
	fi
	
	if [ ! -f pspsdk/configure ]
	then
		cd pspsdk
		./bootstrap || die "running pspsdk bootstrap"
		cd ..
	fi
	
	if [ ! -d build/pspsdk ]
	then
		mkdir -p build/pspsdk
		cd build/pspsdk
		../../pspsdk/configure --with-pspdev="$INSTALLDIR" || die "running pspsdk configure"
	else
		cd build/pspsdk
		make clean
	fi

	make install-data || die "installing pspsdk headers"
	cd ../../..
}

function buildNewlib {
	NEWLIB="newlib-$NEWLIB_VER.tar.gz"
	NEWLIB_SRCDIR="newlib-"$NEWLIB_VER
	
	downloadFTP psp $NEWLIB "ftp://sources.redhat.com/pub/newlib"
	
	if [ ! -d psp/$NEWLIB_SRCDIR ]
	then
		cd psp
		tar -xzf $NEWLIB || die "extracting "$NEWLIB
		patch -p1 -d $NEWLIB_SRCDIR -i ../patches/newlib-$NEWLIB_VER-MINPSPW.patch || die "Error patching newlib (MINPSPW)"
		cd ..
	fi
	
	if [ ! -d psp/build/$NEWLIB_SRCDIR ]
	then
		mkdir -p psp/build/$NEWLIB_SRCDIR
		cd psp/build/$NEWLIB_SRCDIR

		../../$NEWLIB_SRCDIR/configure \
				--target=psp \
				--disable-nls \
				--prefix=$INSTALLDIR || die "configuring newlib"
	else
		cd psp/build/$NEWLIB_SRCDIR
		make clean
	fi

	make LDFLAGS="-s" || die "building newlib"
	make install || die "installing newlib"
	cd ../../..
}

function buildGCC {

	GCC_SRCDIR="gcc-"$GCC_VER
	cd psp/build/"gcc-"$GCC_VER

	# directory is dirty with bootstrap compiler, should clean just in case
	make clean

	# in order to get gcov to build libgcov we need to specify with-headers in conjuction with newlib
	../../$GCC_SRCDIR/configure \
			--prefix=$INSTALLDIR \
			--target=psp \
			--enable-languages="c,c++,objc,obj-c++" \
			--enable-cxx-flags="-G0" \
			--with-newlib \
			--with-headers \
			--disable-win32-registry \
			--disable-nls \
			--with-gmp-include=$GMP_INCLUDE --with-gmp-lib=$GMP_LIB \
			--with-mpfr-include=$MPFR_INCLUDE --with-mpfr-lib=$MPFR_LIB || die "configuring gcc"
	

	if [ "$OS" == "MINGW32_NT" ]; then
		make CFLAGS="-D__USE_MINGW_ACCESS" CFLAGS_FOR_TARGET="-G0 -O2" LDFLAGS="-s" || die "building final gcc collection"
	else
		make CFLAGS_FOR_TARGET="-G0 -O2" LDFLAGS="-s" || die "building final gcc collection"
	fi

	make install || die "installing final gcc collection"
	cd ../../..
}

function buildSDK {
	cd psp/build/pspsdk
	make clean
	make LDFLAGS="-s" || die "building pspsdk"
	make install || die "installing pspsdk"
	cd ../../..
}

function validateSDK {
	find $INSTALLDIR/psp/sdk/samples -type f -name "Makefile" | xargs $(pwd)/mingw/build-sample.sh $1 || exit 1;
}

function buildGDB {
	GDB="gdb-"$GDB_VER".tar.bz2"
	GDB_SRCDIR="gdb-"$GDB_VER

	downloadHTTP psp $GDB "http://ftp.gnu.org/gnu/gdb"
	
	if [ ! -d psp/$GDB_SRCDIR ]
	then
		cd psp
		tar -xjf $GDB || die "extracting "$GDB
		patch -p1 -d $GDB_SRCDIR -i ../patches/gdb-$GDB_VER-PSP.patch || die "patching gdb"
		patch -p1 -d $GDB_SRCDIR -i ../patches/gdb-$GDB_VER-MINPSPW.patch || die "patching gdb MINPSPW"
		cd ..
	fi
	
	if [ ! -d psp/build/$GDB_SRCDIR ]
	then
		mkdir -p psp/build/$GDB_SRCDIR
		cd psp/build/$GDB_SRCDIR

		../../$GDB_SRCDIR/configure \
				--prefix=$INSTALLDIR \
				--target=psp \
				--disable-nls \
				--disable-werror || die "configuring gdb"
	else
		cd psp/build/$GDB_SRCDIR
		make clean
	fi

	make LDFLAGS="-s" || die "building gdb"
	make install || die "installing gdb"
	cd ../../..
}

function installExtraBinaries {
	UNXUTILS="UnxUtils.zip"
	UNXUTILS_DIR="UnxUtils"
	
	downloadHTTP deps $UNXUTILS $SF_MIRROR"/unxutils"
	
	if [ ! -d deps/$UNXUTILS_DIR ]
	then
		cd deps
		../mingw/bin/unzip -q $UNXUTILS -d $UNXUTILS_DIR
		cd ..
	fi
	
	cd deps
	installFile cp.exe $UNXUTILS_DIR/usr/local/wbin bin
	installFile rm.exe $UNXUTILS_DIR/usr/local/wbin bin
	installFile mkdir.exe $UNXUTILS_DIR/usr/local/wbin bin
	installFile sed.exe $UNXUTILS_DIR/usr/local/wbin bin
	cd ..
	
	MINGW32_MAKE="make-"$MINGW32_MAKE_VER".tar.gz"
	MINGW32_MAKE_DIR="make-"$MINGW32_MAKE_VER

	downloadHTTP deps $MINGW32_MAKE $SF_MIRROR"/mingw"
	
	if [ ! -d deps/$MINGW32_MAKE_DIR ]
	then
		cd deps
		mkdir $MINGW32_MAKE_DIR
		cd $MINGW32_MAKE_DIR
		tar -xzf ../$MINGW32_MAKE || die "extracting "$MINGW32_MAKE
		cd ../..
	fi
	
	cd deps/$MINGW32_MAKE_DIR
	installFile make.exe . bin
	installDir info .
	cd ../..
	
	# true for some samples (namely minifire asm demo)
	gcc -s -Wall -O3 -o $INSTALLDIR/bin/true.exe mingw/true.c
	# visual studio support
	installFile vsmake.bat mingw/bin bin
	cd mingw
	installDir VC .
	cd ..
}

function installPSPLinkUSB {
	cd psp
	if [ ! -d psplinkusb ]
	then
		svnGetPS2DEV psplinkusb
		patch -p1 -d psplinkusb -i ../patches/psplinkusb-MINPSPW.patch || die "patching psplinkusb"
	else
		svnGetPS2DEV psplinkusb
	fi

	
if [ "$OS" == "MINGW32_NT" ]; then
	# pspsh + usbhostfs_pc
	installFile pspsh.exe ../mingw/bin bin
	installFile usbhostfs_pc.exe ../mingw/bin bin
	installFile cygncurses-8.dll ../mingw/bin bin
	installFile cygreadline6.dll ../mingw/bin bin
	installFile cygwin1.dll ../mingw/bin bin
	
	# copy the drivers for windows
	mkdir -p $INSTALLDIR/bin/driver
	mkdir -p $INSTALLDIR/bin/driver_x64
	installFile libusb0.dll ../mingw/bin/usb/driver bin/driver
	installFile libusb0.sys ../mingw/bin/usb/driver bin/driver
	installFile psp.cat ../mingw/bin/usb/driver bin/driver
	installFile psp.inf ../mingw/bin/usb/driver bin/driver
	# 64 bits
	installFile libusb0.dll ../mingw/bin/usb/driver_x64 bin/driver_x64
	installFile libusb0.sys ../mingw/bin/usb/driver_x64 bin/driver_x64
	installFile psp.cat ../mingw/bin/usb/driver_x64 bin/driver_x64
	installFile psp.inf ../mingw/bin/usb/driver_x64 bin/driver_x64
	installFile libusb0_x64.dll ../mingw/bin/usb/driver_x64 bin/driver_x64
	installFile libusb0_x64.sys ../mingw/bin/usb/driver_x64 bin/driver_x64
	installFile psp_x64.cat ../mingw/bin/usb/driver_x64 bin/driver_x64
else
	cd psplinkusb
	
	if [ "$OS" == "SunOS" ]; then
		cp -f ../../mingw/solaris/Makefile.pspsh pspsh/Makefile
		cp -f ../../mingw/solaris/Makefile.usbhostfs_pc usbhostfs_pc/Makefile
		cp -f ../../mingw/solaris/Makefile.remotejoy tools/remotejoy/pcsdl/Makefile
	fi
	
	make -f Makefile.clients install
	cd ..
fi

	cd psplinkusb
	make -f Makefile.psp clean || die "cleaning PSPLINKUSB (PSP)"
	make -f Makefile.psp release || die "building PSPLINKUSB (PSP)"
	cd release

	mkdir -p $INSTALLDIR/psplink/psp
	installDir scripts psplink/psp
	rm -fR $INSTALLDIR/psplink/psp/scripts/.svn
	installDir v1.0 psplink/psp
	installDir v1.5 psplink/psp
	installDir v1.5_nocorrupt psplink/psp
	installFile LICENSE . psplink
	installFile psplink_manual.pdf . psplink
	installFile README . psplink
	
	cd ..
	make -f Makefile.oe clean || die "cleaning PSPLINKUSB (OE)"
	make -f Makefile.oe release || die "building PSPLINKUSB (OE)"
	
	cd release_oe

	installDir psplink psplink/psp/oe
	
	cd ../../..
}

function installMan {

	MINGW32_GROFF="groff-"$MINGW32_GROFF_VER"-bin.zip"
	MINGW32_GROFF_DIR="groff-"$MINGW32_GROFF_VER

	MINGW32_LESS="less-"$MINGW32_LESS_VER"-bin.zip"
	MINGW32_LESS_DEP="less-"$MINGW32_LESS_VER"-dep.zip"
	MINGW32_LESS_DIR="less-"$MINGW32_LESS_VER

	downloadHTTP deps $MINGW32_GROFF $SF_MIRROR"/gnuwin32"
	downloadHTTP deps $MINGW32_LESS $SF_MIRROR"/gnuwin32"
	downloadHTTP deps $MINGW32_LESS_DEP $SF_MIRROR"/gnuwin32"
	
	if [ ! -d deps/$MINGW32_GROFF_DIR ]
	then
		cd deps
		../mingw/bin/unzip -q $MINGW32_GROFF -d $MINGW32_GROFF_DIR
		cd ..
	fi

	cd deps
	installFile groff.exe $MINGW32_GROFF_DIR/bin bin
	installFile grotty.exe $MINGW32_GROFF_DIR/bin bin
	installFile troff.exe $MINGW32_GROFF_DIR/bin bin
	mkdir -p $INSTALLDIR/share
	
	installDir $MINGW32_GROFF_DIR/share/groff/$MINGW32_GROFF_VER/font share
	installDir $MINGW32_GROFF_DIR/share/groff/$MINGW32_GROFF_VER/tmac share
	cd ..
	
	if [ ! -d deps/$MINGW32_LESS_DIR ]
	then
		cd deps
		../mingw/bin/unzip -q $MINGW32_LESS -d $MINGW32_LESS_DIR
		../mingw/bin/unzip -q $MINGW32_LESS_DEP -d $MINGW32_LESS_DIR
		cd ..
	fi
	
	cd deps
	installFile less.exe $MINGW32_LESS_DIR/bin bin
	installFile pcre3.dll $MINGW32_LESS_DIR/bin bin
	installFile man.bat ../mingw/bin bin
	cd ..
}

function installInfo {
	installFile info.bat mingw/bin bin
	installFile ginfo.exe mingw/bin bin
}

function patchCMD {
	# make sure the line endings are correct (UNIX style)
	awk '{ sub("\r$", ""); print }' $INSTALLDIR/psp/sdk/lib/build.mak > $INSTALLDIR/psp/sdk/lib/build.mak.unix
	mv -f $INSTALLDIR/psp/sdk/lib/build.mak.unix $INSTALLDIR/psp/sdk/lib/build.mak
	
	awk '{ sub("\r$", ""); print }' $INSTALLDIR/psp/sdk/lib/build_prx.mak > $INSTALLDIR/psp/sdk/lib/build_prx.mak.unix
	mv -f $INSTALLDIR/psp/sdk/lib/build_prx.mak.unix $INSTALLDIR/psp/sdk/lib/build_prx.mak

	patch -p1 -d $INSTALLDIR/psp/sdk -i $(pwd)/psp/patches/pspsdk-CMD.patch || die "patching makefiles for Win CMD shell"
}

function prepareDistro {
	# add release notes
	cp readme.txt $INSTALLDIR/readme.txt
	
	[ ! -z "$INSTALLERDIR" ] && mkdir -p $INSTALLERDIR && touch $INSTALLERDIR/nonexistantfile && rm $INSTALLERDIR/nonexistantfile || exit 1;

	mkdir -p $INSTALLERDIR/base
	mkdir -p $INSTALLERDIR/eclipse/bin
	mkdir -p $INSTALLERDIR/vstudio/bin
	mkdir -p $INSTALLERDIR/psplink/bin
	mkdir -p $INSTALLERDIR/documentation/pspdoc
	mkdir -p $INSTALLERDIR/documentation/man_info
	mkdir -p $INSTALLERDIR/samples/psp/sdk
	# clone the base installation
	cp -fR $INSTALLDIR/* $INSTALLERDIR/base
#	Eclipse Works great again so disable this since it causes problems with local GCCs
#	# copy eclipse tools
#	cp $INSTALLERDIR/base/bin/psp-gcc.exe $INSTALLERDIR/eclipse/bin/gcc.exe
#	cp $INSTALLERDIR/base/bin/psp-g++.exe $INSTALLERDIR/eclipse/bin/g++.exe
	# copy visual studio tools
	mv $INSTALLERDIR/base/bin/sed.exe $INSTALLERDIR/vstudio/bin/sed.exe
	mv $INSTALLERDIR/base/bin/vsmake.bat $INSTALLERDIR/vstudio/bin/vsmake.bat
	mv $INSTALLERDIR/base/VC $INSTALLERDIR/vstudio/VC
	# move binary psplinkusb
	mv $INSTALLERDIR/base/bin/driver $INSTALLERDIR/psplink/bin/
	mv $INSTALLERDIR/base/bin/driver_x64 $INSTALLERDIR/psplink/bin/
	mv $INSTALLERDIR/base/bin/pspsh.exe $INSTALLERDIR/psplink/bin/
	mv $INSTALLERDIR/base/bin/usbhostfs_pc.exe $INSTALLERDIR/psplink/bin/
	mv $INSTALLERDIR/base/bin/cygncurses-8.dll $INSTALLERDIR/psplink/bin/
	mv $INSTALLERDIR/base/bin/cygreadline6.dll $INSTALLERDIR/psplink/bin/
	mv $INSTALLERDIR/base/bin/cygwin1.dll $INSTALLERDIR/psplink/bin/
	# move psp psplink
	mv $INSTALLERDIR/base/psplink $INSTALLERDIR/psplink
	# move the docs
	mv $INSTALLERDIR/base/man $INSTALLERDIR/documentation/man_info/man

	mkdir -p $INSTALLERDIR/documentation/man_info/bin
	mkdir -p $INSTALLERDIR/documentation/man_info/share

	mv $INSTALLERDIR/base/share/font $INSTALLERDIR/documentation/man_info/share/font
	mv $INSTALLERDIR/base/share/tmac $INSTALLERDIR/documentation/man_info/share/tmac

	mv	$INSTALLERDIR/base/bin/groff.exe $INSTALLERDIR/documentation/man_info/bin/groff.exe
	mv	$INSTALLERDIR/base/bin/grotty.exe $INSTALLERDIR/documentation/man_info/bin/grotty.exe
	mv	$INSTALLERDIR/base/bin/less.exe $INSTALLERDIR/documentation/man_info/bin/less.exe
	mv	$INSTALLERDIR/base/bin/man.bat $INSTALLERDIR/documentation/man_info/bin/man.bat
	mv	$INSTALLERDIR/base/bin/pcre3.dll $INSTALLERDIR/documentation/man_info/bin/pcre3.dll
	mv	$INSTALLERDIR/base/bin/troff.exe $INSTALLERDIR/documentation/man_info/bin/troff.exe
	# create info stuff and add info viewer
	mv $INSTALLERDIR/base/info $INSTALLERDIR/documentation/man_info/info

	mv $INSTALLERDIR/base/bin/info.bat $INSTALLERDIR/documentation/man_info/bin/info.bat
	mv $INSTALLERDIR/base/bin/ginfo.exe $INSTALLERDIR/documentation/man_info/bin/info.exe

	# generate doxygen docs
	cd psp/build/pspsdk
	make doxygen-doc
	cp -fR doc $INSTALLERDIR/documentation/pspdoc
	cd ../../..
	rm $INSTALLERDIR/documentation/pspdoc/doc/pspsdk.tag
	rm -rf $INSTALLERDIR/documentation/pspdoc/doc/.svn
	rm -f $INSTALLERDIR/documentation/pspdoc/doc/html/*.dot
	mv $INSTALLERDIR/documentation/pspdoc/doc/html $INSTALLERDIR/documentation/pspdoc/doc/pspsdk

	# move samples
	mv $INSTALLERDIR/base/psp/sdk/samples $INSTALLERDIR/samples/psp/sdk/samples

	# copy nsis scripts to the installer folder
	cp installer/AddToPath.nsh $INSTALLERDIR
	cp installer/licenses.txt $INSTALLERDIR
	sed s/@MINPSPW_VERSION@/$PSPSDK_VERSION/ < installer/setup.nsi > $INSTALLERDIR/setup.nsi
}

function prepareDistroNIX {
	# add release notes
	cp readme.txt $INSTALLDIR/readme.txt
	
	# generate doxygen docs
	cd psp/build/pspsdk
	make doxygen-doc
	mkdir -p $INSTALLDIR/doc
	cp -fR doc $INSTALLDIR/doc/pspsdk
	cd ../../..
}

function buildBaseDevpaks {
	# create the base set of devpaks
	if [ "$OS" == "MINGW32_NT" ]; then
		mkdir -p $INSTALLERDIR/devpaks
		DEVPAK_TARGET=$INSTALLERDIR/devpaks
	fi
	BASE=$(pwd)/devpaks
	
	buildAndInstallDevPak $BASE 001 zlib $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 002 bzip2 $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 003 freetype $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 004 jpeg $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 005 libbulletml $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 006 libmad $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 007 libmikmod $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 008 libogg $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 009 libpng $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 010 libpspvram $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 011 libTremor $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 012 libvorbis $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 013 lua $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 014 pspgl $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 015 pspirkeyb $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 016 sqlite $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 017 SDL $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 018 SDL_gfx $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 019 SDL_image $DEVPAK_TARGET
	# according to Luqman Aden smpeg must be build before SDL_mixer
	# otherwise there is no MP3 support on SDL mixer
	buildAndInstallDevPak $BASE 022 smpeg $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 020 SDL_mixer $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 021 SDL_ttf $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 023 ode $DEVPAK_TARGET
#	buildAndInstallDevPak $BASE 024 TinyGL $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 025 libpthreadlite $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 026 cal3D $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 027 mikmodlib $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 028 cpplibs $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 029 flac $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 030 giflib $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 031 libpspmath $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 032 pthreads-emb $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 033 tinyxml $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 034 oslib $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 035 libcurl $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 036 intrafont $DEVPAK_TARGET
#	buildAndInstallDevPak $BASE 037 libaac $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 038 Jello $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 039 zziplib $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 040 Mini-XML $DEVPAK_TARGET
}

#---------------------------------------------------------------------------------
# main
#---------------------------------------------------------------------------------
prepare

downloadPatches

#---------------------------------------------------------------------------------
# build sdk
#---------------------------------------------------------------------------------
buildBinutils
buildXGCC
bootstrapSDK
buildNewlib
buildGCC
buildSDK
validateSDK
buildGDB

#---------------------------------------------------------------------------------
# build tools
#---------------------------------------------------------------------------------
if [ "$OS" == "MINGW32_NT" ]; then
	installExtraBinaries
fi

#---------------------------------------------------------------------------------
# PSPLink
#---------------------------------------------------------------------------------
installPSPLinkUSB

#---------------------------------------------------------------------------------
# Distro + Docs
#---------------------------------------------------------------------------------
if [ "$OS" == "MINGW32_NT" ]; then
	installMan
	installInfo

	#---------------------------------------------------------------------------------
	# patch SDK to run without msys
	#---------------------------------------------------------------------------------
	patchCMD

	#---------------------------------------------------------------------------------
	# prepare distro
	#---------------------------------------------------------------------------------
	prepareDistro
else
	#---------------------------------------------------------------------------------
	# prepare distro for *nix
	#---------------------------------------------------------------------------------
	prepareDistroNIX
fi

buildBaseDevpaks

echo
echo "Run the NSIS script to build the Installer"
