#!/bin/sh

#---------------------------------------------------------------------------------
# configuration
#---------------------------------------------------------------------------------

#PS2DEV_SVN="svn://svn.ps2dev.org/psp/trunk/"
PS2DEV_SVN="http://psp.jim.sh/svn/psp/trunk/"
#SF_MIRROR="http://surfnet.dl.sourceforge.net/sourceforge"
SF_MIRROR="http://voxel.dl.sourceforge.net/sourceforge"

GCC_VER=4.3.2
GCC_TC_VERSION=4.3.1
GMP_VER=4.2.3
MPFR_VER=2.3.2
ZLIB_VER=1.2.3
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
ZLIB="zlib-$ZLIB_VER.tar.gz"

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
ZLIB_URL="http://www.zlib.net/$ZLIB"

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
ZLIB_SRCDIR="zlib-$ZLIB_VER"

BINUTILS_SRCDIR="binutils-$BINUTILS_VER"
GCC_SRCDIR="gcc-$GCC_VER"
GDB_SRCDIR="gdb-$GDB_VER"
NEWLIB_SRCDIR="newlib-$NEWLIB_VER"

MINGW32_MAKE_DIR="make-$MINGW32_MAKE_VER"
UNXUTILS_DIR="UnxUtils"
MINGW32_GROFF_DIR="groff-$MINGW32_GROFF_VER"
MINGW32_LESS_DIR="less-$MINGW32_LESS_VER"

#---------------------------------------------------------------------------------
# functions
#---------------------------------------------------------------------------------

#arg1 func
function die {
	echo "Error: "$1
	exit 1
}

function checkTool {
	if [ -z $1 ]; then
		die "Please make sure you have '"$1"' installed."
	fi
}

# arg1 base
# arg2 file
# arg3 url
function downloadHTTP {
	if [ ! -f $1/$2 ]
	then
		cd $1
		wget -c $3 || die "Failed to download "$2
		cd ..
	fi

}

function downloadFTP {
	if [ ! -f $1/$2 ]
	then
		cd $1
		wget --passive-ftp -c $3 || die "Failed to download "$2
		cd ..
	fi

}

function installZlib {
	if [ ! -f /mingw/include/zlib.h ]
	then
		downloadHTTP deps $ZLIB $ZLIB_URL
		cd deps
		tar -xzf $ZLIB || die "extracting "$ZLIB

		cd $ZLIB_SRCDIR
		make CC=gcc || die "building "$ZLIB
		make install prefix=/mingw || die "installing "$ZLIB
		cd ../..
	fi
}

function installGMP {
	if [ ! -f /usr/local/include/gmp.h ]
	then
		downloadHTTP deps $GMP $GMP_URL
		cd deps
		tar -xjf $GMP || die "extracting "$GMP

		cd $GMP_SRCDIR
		./configure --prefix=/usr/local || die "configuring "$GMP
		make || die "building "$GMP
		make check || die "checking "$GMP
		make install || die "installing "$GMP
		cd ../..
	fi
}

function installMPFR {
	if [ ! -f /usr/local/include/mpfr.h ]
	then
		downloadHTTP deps $MPFR $MPFR_URL
		cd deps
		tar -xjf $MPFR || die "extracting "$MPFR

		cd $MPFR_SRCDIR
		./configure --prefix=/usr/local --with-gmp=/usr/local || die "configuring "$MPFR
		make || die "building "$MPFR
		make check || die "checking "$MPFR
		make install || die "installing "$MPFR
		cd ../..
	fi
}

function downloadPatches {
	cd psp
	if [ ! -d patches ]
	then
		svn checkout $PS2DEV_SVN/psptoolchain/patches || die "Getting toolchain patches"
	else
		svn update patches
	fi

	cp ../mingw/patches/* patches || die "adding MinPSPW patches"
	cd ..
}

function buildBinutils {
	downloadFTP psp $BINUTILS $BINUTILS_URL
	
	if [ ! -d psp/$BINUTILS_SRCDIR ]
	then
		cd psp
		tar -xjf $BINUTILS || die "extracting "$BINUTILS
		patch -p1 -d $BINUTILS_SRCDIR -i ../patches/binutils-$BINUTILS_VER-PSP.patch || die "patching binutils"
		cd ..
	fi
	
	mkdir -p psp/build/$BINUTILS_SRCDIR
	cd psp/build/$BINUTILS_SRCDIR
		
	../../$BINUTILS_SRCDIR/configure \
			--prefix=$INSTALLDIR \
			--target=psp \
			--disable-nls \
			--disable-shared \
			--disable-debug \
			--disable-threads \
			--with-gcc \
			--with-gnu-as \
			--with-gnu-ld \
			--with-stabs \
			--with-gmp=/usr/local \
			--with-mpfr=/usr/local || die "configuring binutils"
	make || die "Error building binutils"
	make install || die "Error installing binutils"
	cd ../../..
}

function buildBaseCompiler {
	downloadHTTP psp $GCC_CORE $GCC_CORE_URL
	downloadHTTP psp $GCC_GPP $GCC_GPP_URL
	
	if [ ! -d psp/$GCC_SRCDIR ]
	then
		cd psp
		tar -xjf $GCC_CORE || die "extracting "$GCC_CORE
		tar -xjf $GCC_GPP || die "extracting "$GCC_GPP
		patch -p1 -d $GCC_SRCDIR -i ../patches/gcc-$GCC_TC_VERSION-PSP.patch || die "patching gcc"
		cd ..
	fi

	mkdir -p psp/build/$GCC_SRCDIR
	cd psp/build/$GCC_SRCDIR
		
	CFLAGS="-O2 -fomit-frame-pointer -D__USE_MINGW_ACCESS" \
	BOOT_CFLAGS="-O2 -fomit-frame-pointer -D__USE_MINGW_ACCESS" \
	BOOT_CXXFLAGS="-mthreads -fno-omit-frame-pointer -O2" \
	BOOT_LDFLAGS=-s \
	../../$GCC_SRCDIR/configure \
			--enable-languages="c,c++" \
			--disable-multilib \
			--disable-shared \
			--disable-win32-registry \
			--enable-cxx-flags="-G0" \
			--target=psp \
			--with-newlib \
			--prefix=$INSTALLDIR \
			--with-gmp=/usr/local \
			--with-mpfr=/usr/local || die "configuring gcc"
	make all-gcc || die "building gcc"
	make install-gcc || die "installing gcc"
	cd ../../..
}

function bootstrapSDK {
	if [ ! -d psp/pspsdk ]
	then
		cd psp
		svn checkout $PS2DEV_SVN/pspsdk || die "getting pspsdk"
		cd pspsdk
		./bootstrap || die "running pspsdk bootstrap"
		cd ../..
	else
		svn update pspsdk
	fi
	
	mkdir -p psp/build/pspsdk
	cd psp/build/pspsdk
	../../pspsdk/configure --with-pspdev="$INSTALLDIR" || die "running pspsdk configure"
	make install-data || die "installing pspsdk headers"
	cd ../../..
}

function buildNewlib {
	downloadFTP psp $NEWLIB $NEWLIB_URL
	
	if [ ! -d psp/$NEWLIB_SRCDIR ]
	then
		cd psp
		tar -xzf $NEWLIB || die "extracting "$NEWLIB
		patch -p1 -d $NEWLIB_SRCDIR -i ../patches/newlib-$NEWLIB_VER-PSP.patch || die "patching newlib"
		patch -p1 -d $NEWLIB_SRCDIR -i ../patches/newlib-$NEWLIB_VER-MINPSPW.patch || die "Error patching newlib (MINPSPW)"
		cd ..
	fi
	
	mkdir -p psp/build/$NEWLIB_SRCDIR
	cd psp/build/$NEWLIB_SRCDIR
	../../$NEWLIB_SRCDIR/configure \
			--target=psp \
			--prefix=$INSTALLDIR \
			--with-gmp=/usr/local \
			--with-mpfr=/usr/local || die "configuring newlib"
	make || die "building newlib"
	make install || die "installing newlib"
	cd ../../..
}

function buildFinalCompiler {
	cd psp/build/$GCC_SRCDIR
	make || die "building g++"
	make install || die "installing g++"
	cd ../../..
}

function buildSDK {
	cd psp/build/pspsdk
	make || die "building pspsdk"
	make install || die "installing pspsdk"
	cd ../../..
}

function buildGDB {
	downloadHTTP psp $GDB $GDB_URL
	
	if [ ! -d psp/$GDB_SRCDIR ]
	then
		cd psp
		tar -xjf $GDB || die "extracting "$GDB
		patch -p1 -d $GDB_SRCDIR -i ../patches/gdb-$GDB_VER-PSP.patch || die "patching gdb"
		cd ..
	fi
	
	mkdir -p psp/build/$GDB_SRCDIR
	cd psp/build/$GDB_SRCDIR
	../../$GDB_SRCDIR/configure \
			--prefix=$INSTALLDIR \
			--target=psp \
			--disable-nls \
			--with-gmp=/usr/local \
			--with-mpfr=/usr/local || die "configuring gdb"
	make || die "building gdb"
	make install || die "installing gdb"
	cd ../../..
}

function installExtraBinaries {
	downloadHTTP deps $UNXUTILS $UNXUTILS_URL
	
	if [ ! -d deps/$UNXUTILS_DIR ]
	then
		cd deps
		../mingw/bin/unzip -q $UNXUTILS -d $UNXUTILS_DIR
		cp $UNXUTILS_DIR/usr/local/wbin/cp.exe $INSTALLDIR/bin/cp.exe || die "cp"
		cp $UNXUTILS_DIR/usr/local/wbin/rm.exe $INSTALLDIR/bin/rm.exe || die "rm"
		cp $UNXUTILS_DIR/usr/local/wbin/mkdir.exe $INSTALLDIR/bin/mkdir.exe || die "mkdir"
		cp $UNXUTILS_DIR/usr/local/wbin/sed.exe $INSTALLDIR/bin/sed.exe || die "sed"
		cd ..
	fi
	
	downloadHTTP deps $MINGW32_MAKE $MINGW32_MAKE_URL
	
	if [ ! -d deps/$MINGW32_MAKE_DIR ]
	then
		cd deps
		mkdir $MINGW32_MAKE_DIR
		cd $MINGW32_MAKE_DIR
		tar -xzf ../$MINGW32_MAKE || die "extracting "$MINGW32_MAKE
		cp make.exe $INSTALLDIR/bin/make.exe || die "make"
		cp info/*.* $INSTALLDIR/info || die "info"
		cd ../..
	fi
	
	# true for some samples (namely minifire asm demo)
	gcc -Wall -O3 -o $INSTALLDIR/bin/true.exe mingw/true.c
	strip -s $INSTALLDIR/bin/true.exe
	# visual studio support
	cp mingw/bin/vsmake.bat $INSTALLDIR/bin/vsmake.bat || die "vsmake"
}

function installPSPLinkUSB {
	cd psp
	if [ ! -d psplinkusb ]
	then
		svn checkout $PS2DEV_SVN/psplinkusb || die "getting psplinkusb"
	else
		svn update psplinkusb
	fi
	# pspsh + usbhostfs_pc
	cp ../mingw/bin/pspsh.exe $INSTALLDIR/bin/pspsh.exe || die "pspsh"
	cp ../mingw/bin/usbhostfs_pc.exe $INSTALLDIR/bin/usbhostfs_pc.exe || die "usbhostfs_pc"
	cp ../mingw/bin/cygncurses-8.dll $INSTALLDIR/bin/cygncurses-8.dll || die "cygncurses-8.dll"
	cp ../mingw/bin/cygreadline6.dll $INSTALLDIR/bin/cygreadline6.dll || die "cygreadline6.dll"
	cp ../mingw/bin/cygwin1.dll $INSTALLDIR/bin/cygwin1.dll || die "cygwin1.dll"
	
	# copy the drivers for windows
	mkdir -p $INSTALLDIR/bin/driver
	mkdir -p $INSTALLDIR/bin/driver_x64
	cp ../mingw/bin/usb/driver/libusb0.dll $INSTALLDIR/bin/driver/libusb0.dll || die "libusb0.dll"
	cp ../mingw/bin/usb/driver/libusb0.sys $INSTALLDIR/bin/driver/libusb0.sys || die "libusb0.sys"
	cp ../mingw/bin/usb/driver/psp.cat $INSTALLDIR/bin/driver/psp.cat || die "psp.cat"
	cp ../mingw/bin/usb/driver/psp.inf $INSTALLDIR/bin/driver/psp.inf || die "psp.inf"
	# 64 bits (i've no idea if it works)
	cp ../mingw/bin/usb/driver_x64/libusb0.dll $INSTALLDIR/bin/driver_x64/libusb0.dll || die "libusb0.dll x64"
	cp ../mingw/bin/usb/driver_x64/libusb0.sys $INSTALLDIR/bin/driver_x64/libusb0.sys || die "libusb0.sys x64"
	cp ../mingw/bin/usb/driver_x64/psp.cat $INSTALLDIR/bin/driver_x64/psp.cat || die "psp.cat x64"
	cp ../mingw/bin/usb/driver_x64/psp.inf $INSTALLDIR/bin/driver_x64/psp.inf || die "psp.inf x64"
	cp ../mingw/bin/usb/driver_x64/libusb0_x64.dll $INSTALLDIR/bin/driver_x64/libusb0_x64.dll || die "libusb0_x64.dll"
	cp ../mingw/bin/usb/driver_x64/libusb0_x64.sys $INSTALLDIR/bin/driver_x64/libusb0_x64.sys || die "libusb0_x64.sys"
	cp ../mingw/bin/usb/driver_x64/psp_x64.cat $INSTALLDIR/bin/driver_x64/psp_x64.cat || die "psp_x64.cat"
	
	cd psplinkusb
	make -f Makefile.psp clean || die "cleaning PSPLINKUSB (PSP)"
	make -f Makefile.psp release || die "building PSPLINKUSB (PSP)"
	
	cd release

	mkdir -p $INSTALLDIR/psplink/psp
	cp -fR scripts $INSTALLDIR/psplink/psp
	rm -fR $INSTALLDIR/psplink/psp/scripts/.svn
	cp -fR v1.0 $INSTALLDIR/psplink/psp
	cp -fR v1.5 $INSTALLDIR/psplink/psp
	cp -fR v1.5_nocorrupt $INSTALLDIR/psplink/psp
	cp LICENSE $INSTALLDIR/psplink
	cp psplink_manual.pdf $INSTALLDIR/psplink
	cp README $INSTALLDIR/psplink
	touch install-psplinkusb-psp
	
	cd ..
	
	make -f Makefile.oe clean || die "cleaning PSPLINKUSB (OE)"
	make -f Makefile.oe release || die "building PSPLINKUSB (OE)"
	
	cd release_oe

	cp -fR psplink $INSTALLDIR/psplink/psp/oe
	
	cd ../../..
}

function installMan {

	downloadHTTP deps $MINGW32_GROFF $MINGW32_GROFF_URL
	downloadHTTP deps $MINGW32_LESS $MINGW32_LESS_URL
	downloadHTTP deps $MINGW32_LESS_DEP $MINGW32_LESS_DEP_URL
	
	if [ ! -d deps/$MINGW32_GROFF_DIR ]
	then
		cd deps
		../mingw/bin/unzip -q $MINGW32_GROFF -d $MINGW32_GROFF_DIR
		cp $MINGW32_GROFF_DIR/bin/groff.exe $INSTALLDIR/bin/groff.exe || die "groff"
		cp $MINGW32_GROFF_DIR/bin/grotty.exe $INSTALLDIR/bin/grotty.exe || die "grotty"
		cp $MINGW32_GROFF_DIR/bin/troff.exe $INSTALLDIR/bin/troff.exe || die "troff"
		mkdir -p $INSTALLDIR/share
		
		cp -fR $MINGW32_GROFF_DIR/share/groff/$MINGW32_GROFF_VER/font $INSTALLDIR/share
		cp -fR $MINGW32_GROFF_DIR/share/groff/$MINGW32_GROFF_VER/tmac $INSTALLDIR/share
		cd ..
	fi

	if [ ! -d deps/$MINGW32_LESS_DIR ]
	then
		cd deps
		../mingw/bin/unzip -q $MINGW32_LESS -d $MINGW32_LESS_DIR
		../mingw/bin/unzip -q $MINGW32_LESS_DEP -d $MINGW32_LESS_DIR
		cp $MINGW32_LESS_DIR/bin/less.exe $INSTALLDIR/bin/less.exe || die "less"
		cp $MINGW32_LESS_DIR/bin/pcre3.dll $INSTALLDIR/bin/pcre3.dll || die "prce3.dll"
		cp ../mingw/bin/man.bat $INSTALLDIR/bin/man.bat || die "man"
		cd ..
	fi
}

function installInfo {
	cp mingw/bin/info.bat $INSTALLDIR/bin/info.bat || die "info"
	cp mingw/bin/ginfo.exe $INSTALLDIR/bin/ginfo.exe || die "ginfo"
}

function stripBinaries {
	#---------------------------------------------------------------------------------
	# strip binaries
	# strip has trouble using wildcards so do it this way instead
	#---------------------------------------------------------------------------------
	for f in	$INSTALLDIR/bin/* \
				$INSTALLDIR/psp/bin/* \
				$INSTALLDIR/libexec/gcc/psp/$GCC_VER/*
	do
		strip $f
	done

	#---------------------------------------------------------------------------------
	# strip debug info from libraries
	#---------------------------------------------------------------------------------
	find $INSTALLDIR/lib/gcc -name *.a -exec psp-strip -d {} \;
	find $INSTALLDIR/psp -name *.a -exec psp-strip -d {} \;

	# strip corrupts this dll, so get it again
	cp mingw/bin/cygwin1.dll $INSTALLDIR/bin/cygwin1.dll
}

function patchCMD {
	patch -p1 -d $INSTALLDIR/psp/sdk -i $(pwd)/psp/patches/pspsdk-CMD.patch || die "patching makefiles for Win CMD shell"
}

function prepareDistro {
	# add release notes
	cp readme.txt $INSTALLDIR/readme.txt
	
	#---------------------------------------------------------------------------------
	# validate the compiler
	#---------------------------------------------------------------------------------	
	find $INSTALLDIR/psp/sdk/samples -type f -name "Makefile" | xargs $(pwd)/mingw/build-sample.sh $1 || exit 1;

	#---------------------------------------------------------------------------------
	# create a distro
	#---------------------------------------------------------------------------------
	[ ! -z "$INSTALLERDIR" ] && mkdir -p $INSTALLERDIR && touch $INSTALLERDIR/nonexistantfile && rm $INSTALLERDIR/nonexistantfile || exit 1;

	mkdir -p $INSTALLERDIR/base
	mkdir -p $INSTALLERDIR/vstudio/bin
	mkdir -p $INSTALLERDIR/psplink/bin
	mkdir -p $INSTALLERDIR/documentation/pspdoc
	mkdir -p $INSTALLERDIR/documentation/man_info
	mkdir -p $INSTALLERDIR/samples/psp/sdk
	# clone the base installation
	cp -fR $INSTALLDIR/* $INSTALLERDIR/base
	# copy visual studio tools
	mv $INSTALLERDIR/base/bin/sed.exe $INSTALLERDIR/vstudio/bin/sed.exe
	mv $INSTALLERDIR/base/bin/vsmake.bat $INSTALLERDIR/vstudio/bin/vsmake.bat
	# move binary psplinkusb
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
	mv $INSTALLERDIR/documentation/pspdoc/doc/html $INSTALLERDIR/documentation/pspdoc/doc/pspsdk

	# move samples
	mv $INSTALLERDIR/base/psp/sdk/samples $INSTALLERDIR/samples/psp/sdk/samples

	# copy nsis scripts to the installer folder
	cp installer/AddToPath.nsh $INSTALLERDIR
	cp installer/licenses.txt $INSTALLERDIR
	sed s/@MINPSPW_VERSION@/$PSPSDK_VERSION/ < installer/setup.nsi > $INSTALLERDIR/setup.nsi
	sed s/@MINPSPW_VERSION@/$PSPSDK_VERSION/ < installer/setup-nodoc.nsi > $INSTALLERDIR/setup-nodoc.nsi

	echo
	echo "You should now run the NSIS script to build the final installer"
}

#---------------------------------------------------------------------------------
# main
#---------------------------------------------------------------------------------

checkTool svn
checkTool wget
checkTool make
checkTool gawk
checkTool makeinfo

#---------------------------------------------------------------------------------
# pre requisites
#---------------------------------------------------------------------------------

mkdir -p deps
mkdir -p psp/build

installZlib
installGMP
installMPFR

downloadPatches

#---------------------------------------------------------------------------------
# Add installed devkit to the path, adjusting path on minsys
#---------------------------------------------------------------------------------
TOOLPATH=$(echo $INSTALLDIR | sed -e 's/^\([a-zA-Z]\):/\/\1/')
[ ! -z "$INSTALLDIR" ] && mkdir -p $INSTALLDIR && touch $INSTALLDIR/nonexistantfile && rm $INSTALLDIR/nonexistantfile || exit 1;
export PATH=$PATH:$TOOLPATH/bin

#---------------------------------------------------------------------------------
# build sdk
#---------------------------------------------------------------------------------

buildBinutils
buildBaseCompiler
bootstrapSDK
buildNewlib
buildFinalCompiler
buildSDK
buildGDB

#---------------------------------------------------------------------------------
# build tools
#---------------------------------------------------------------------------------

installExtraBinaries
installPSPLinkUSB
installMan
installInfo

#---------------------------------------------------------------------------------
# strip binaries
#---------------------------------------------------------------------------------

stripBinaries

#---------------------------------------------------------------------------------
# patch SDK to run without msys
#---------------------------------------------------------------------------------

patchCMD

#---------------------------------------------------------------------------------
# prepare distro
#---------------------------------------------------------------------------------

prepareDistro
