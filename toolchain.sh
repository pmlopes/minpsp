#!/bin/sh

#---------------------------------------------------------------------------------
# configuration
#---------------------------------------------------------------------------------

PS2DEVSVN_URL="svn://svn.pspdev.org/psp/trunk"
PS2DEVSVN_MIRROR="http://psp.jim.sh/svn/psp/trunk"

#SF_MIRROR="http://surfnet.dl.sourceforge.net/sourceforge"
SF_MIRROR="http://voxel.dl.sourceforge.net/sourceforge"

# gcc deps versions
ZLIB_VER=1.2.3
GMP_VER=4.2.4
MPFR_VER=2.3.2

# sdk versions
BINUTILS_VER=2.16.1
GCC_VER=4.3.3
GCC_TC_VER=4.3.2
NEWLIB_VER=1.17.0

#debugger version
GDB_VER=6.8

#extra deps version
MINGW32_MAKE_VER=3.79.1-20010722
MINGW32_GROFF_VER=1.19.2
MINGW32_LESS_VER=394

# package version
PSPSDK_VERSION=0.9.1

INSTALLDIR="/c/pspsdk"
INSTALLERDIR="/c/pspsdk-installer"

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

# Gets the sources from the PS2DEV SVN reppo, on failure tries to fallback to JimParis mirror
#arg1 devpak
function svnGetPS2DEV() {
	if [ ! -d $(basename $1) ]
	then
		svn checkout $2 $3 $PS2DEVSVN_URL/$1 || svn checkout $PS2DEVSVN_MIRROR/$1 || die "ERROR GETTING "$1
	else
		svn update $2 $3 $(basename $1)
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
function buildAndInstallDevPak() {
	cd $1 || exit 1
	cd $2_$3 || exit 1
	./devpak.sh || exit 1
	cd $(psp-config --pspdev-path) || exit 1
	tar xjfv $1/$2_$3/$3-*.tar.bz2 || exit 1
	cd $4 || exit 1
	tar xjfv $1/$2_$3/$3-*.tar.bz2 || exit 1
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
		MPFR="mpfr-"$MPFR_VER".tar.bz2"
		
		downloadHTTP deps $MPFR "http://www.mpfr.org/mpfr-current"
		cd deps
		tar -xjf $MPFR || die "extracting "$MPFR

		cd "mpfr-"$MPFR_VER
		./configure --prefix=/usr/local --with-gmp=/usr/local || die "configuring "$MPFR
		make || die "building "$MPFR
		make check || die "checking "$MPFR
		make install || die "installing "$MPFR
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
		patch -p1 -d $BINUTILS_SRCDIR -i ../patches/binutils-$BINUTILS_VER-PSP.patch || die "patching binutils"
		cd ..
	fi
	
	mkdir -p psp/build/$BINUTILS_SRCDIR
	cd psp/build/$BINUTILS_SRCDIR
	
	../../$BINUTILS_SRCDIR/configure \
			--prefix=$INSTALLDIR \
			--target=psp \
			--enable-install-libbfd \
			--disable-nls \
			--with-gmp=/usr/local \
			--with-mpfr=/usr/local || die "configuring binutils"

	make clean
	make LDFLAGS="-s" || die "Error building binutils"
	make install || die "Error installing binutils"
	cd ../../..
}

# build a compiler so we can bootstrap the SDK and the newlib
function buildXGCC {
	GCC_CORE="gcc-core-"$GCC_VER".tar.bz2"
	GCC_GPP="gcc-g++-"$GCC_VER".tar.bz2"
	GCC_OBJC="gcc-objc-"$GCC_VER".tar.bz2"
	GCC_GCJ="gcc-java-"$GCC_VER".tar.bz2"
	
	GCC_SRCDIR="gcc-"$GCC_VER
	
	downloadHTTP psp $GCC_CORE "http://ftp.gnu.org/gnu/gcc/gcc-"$GCC_VER
	downloadHTTP psp $GCC_GPP "http://ftp.gnu.org/gnu/gcc/gcc-"$GCC_VER
	downloadHTTP psp $GCC_OBJC "http://ftp.gnu.org/gnu/gcc/gcc-"$GCC_VER
#	downloadHTTP psp $GCC_GCJ "http://ftp.gnu.org/gnu/gcc/gcc-"$GCC_VER
#	downloadFTP psp ecj-latest.jar "ftp://sourceware.org/pub/java"
	
	if [ ! -d psp/$GCC_SRCDIR ]
	then
		cd psp
		tar -xjf $GCC_CORE || die "extracting "$GCC_CORE
		tar -xjf $GCC_GPP || die "extracting "$GCC_GPP
		tar -xjf $GCC_OBJC || die "extracting "$GCC_OBJC
		patch -p1 -d $GCC_SRCDIR -i ../patches/gcc-$GCC_TC_VER-PSP.patch || die "patching gcc"
		cd ..
	fi

	mkdir -p psp/build/$GCC_SRCDIR
	cd psp/build/$GCC_SRCDIR
	
	../../$GCC_SRCDIR/configure \
			--enable-languages="c,c++,objc,obj-c++" \
			--disable-win32-registry \
			--enable-cxx-flags="-G0" \
			--target=psp \
			--with-newlib \
			--disable-shared \
			--disable-nls \
			--prefix=$INSTALLDIR \
			--with-gmp=/usr/local \
			--with-mpfr=/usr/local || die "configuring gcc"
	
	make clean
	make CFLAGS="-D__USE_MINGW_ACCESS" LDFLAGS="-s" all-gcc || die "building gcc"
	make install-gcc || die "installing gcc"
	cd ../../..
}

function bootstrapSDK {
	cd psp
	if [ ! -d pspsdk ]
	then
		svnGetPS2DEV pspsdk
		patch -p1 -i ../patches/pspsdk-objc-MINPSPW.patch || die "patching pspsdk (ObjC Support)"
		patch -p1 -i ../patches/pspsdk-MINPSPW.patch || die "patching pspsdk (Missing API)"
	else
		svnGetPS2DEV pspsdk
	fi
	
	cd pspsdk
	./bootstrap || die "running pspsdk bootstrap"
	cd ..
	
	mkdir -p build/pspsdk
	cd build/pspsdk
	
	../../pspsdk/configure --with-pspdev="$INSTALLDIR" || die "running pspsdk configure"
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
	
	mkdir -p psp/build/$NEWLIB_SRCDIR
	cd psp/build/$NEWLIB_SRCDIR

	../../$NEWLIB_SRCDIR/configure \
			--target=psp \
			--disable-nls \
			--prefix=$INSTALLDIR \
			--with-gmp=/usr/local \
			--with-mpfr=/usr/local || die "configuring newlib"
	make LDFLAGS="-s" || die "building newlib"
	make install || die "installing newlib"
	cd ../../..
}

function buildGCC {
	
	cd psp/build/"gcc-"$GCC_VER
	make CFLAGS_FOR_TARGET="-G0 -O2" LDFLAGS="-s" || die "building final compiler"
	make install || die "installing final compiler"
	cd ../../..
}

function buildSDK {
	cd psp/build/pspsdk
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
		cd ..
	fi
	
	mkdir -p psp/build/$GDB_SRCDIR
	cd psp/build/$GDB_SRCDIR
	
	../../$GDB_SRCDIR/configure \
			--prefix=$INSTALLDIR \
			--disable-nls \
			--target=psp \
			--with-gmp=/usr/local \
			--with-mpfr=/usr/local || die "configuring gdb"
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
	touch install-psplinkusb-psp
	
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
	patch -p1 -d $INSTALLDIR/psp/sdk -i $(pwd)/psp/patches/pspsdk-CMD.patch || die "patching makefiles for Win CMD shell"
}

function prepareDistro {
	# add release notes
	cp readme.txt $INSTALLDIR/readme.txt
	
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
	sed s/@MINPSPW_VERSION@/$PSPSDK_VERSION/ < installer/setup-nodoc.nsi > $INSTALLERDIR/setup-nodoc.nsi
}

function buildBaseDevpaks {
	# create the base set of devpaks
	mkdir -p $INSTALLERDIR/devpaks
	DEVPAK_TARGET=$INSTALLERDIR/devpaks
	BASE=$(pwd)/devpaks
	
	buildAndInstallDevPak $BASE 001 zlib $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 002 bzip2 $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 003 freetype $DEVPAK_TARGET
	gcc -s -o $DEVPAK_TARGET/bin/freetype-config $BASE/003_freetype/freetype-config.c -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DFTVERSION=\"2.1.10\" || exit 1
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
	gcc -s -o $DEVPAK_TARGET/bin/sdl-config -DPREFIX=\"\" -DEXEC_PREFIX=\"\" -DVERSION=\"1.2.9\" $BASE/017_SDL/sdl-config.c || exit 1
	buildAndInstallDevPak $BASE 018 SDL_gfx $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 019 SDL_image $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 020 SDL_mixer $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 021 SDL_ttf $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 022 smpeg $DEVPAK_TARGET
	buildAndInstallDevPak $BASE 039 zziplib $DEVPAK_TARGET

	rm $DEVPAK_TARGET/bin/freetype-config
	rm $DEVPAK_TARGET/bin/sdl-config
}

#---------------------------------------------------------------------------------
# main
#---------------------------------------------------------------------------------
checkTool svn
checkTool wget
checkTool make
checkTool gawk
checkTool makeinfo
checkTool python

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
installExtraBinaries
installPSPLinkUSB
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
buildBaseDevpaks

echo
echo "Run the devpak script to add DEVPAKs to the Full SDK"
