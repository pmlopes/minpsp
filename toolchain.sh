#!/bin/bash
set -e

#---------------------------------------------------------------------------------
# configuration
#---------------------------------------------------------------------------------

# package version
PSPSDK_VERSION=0.11.3

# supported languages
#LANGUAGES="c,c++"
LANGUAGES="c,c++,objc,obj-c++,d"

# sdk versions
# Downgraded since there is a bug that is 100% reproducible with Daedalus
# BINUTILS_VER=2.18
BINUTILS_VER=2.16.1
GCC_VER=4.3.5
NEWLIB_VER=1.18.0
#debugger version
GDB_VER=6.8

# gcc >= 4.x deps versions
GMP_VER=4.2.4
# minimal is 2.3.2
MPFR_VER=2.4.1
## for gcc >= 4.4 (graphite)
#PPL_VER=0.10.2
#CLOOG_PPL_VER=0.15.7
#MPC_VER=0.7
## for gcc >= 4.5 (lto)
#LIBELF_VER=0.8.12

# gdb + pspusbsh + etc...
ZLIB_VER=1.2.5
LIBPDCURSES_VER=3.4
LIBREADLINE_VER=5.1
LIBICONV_VER=1.13.1
PTHREADS_VER=2-8-0
SDL_VER=1.2.14

#extra deps version
MINGW32_MAKE_VER=3.79.1-20010722
MINGW32_GROFF_VER=1.19.2
MINGW32_LESS_VER=394

#---------------------------------------------------------------------------------
# functions
#---------------------------------------------------------------------------------

function checkTool {
  type -P $1 &> /dev/null || { echo  "Please make sure you have '"$1"' installed."; exit 1; }
}

# arg1 target-build
# arg2 url
# arg3 base
# arg4 compression
# arg5 [target-dir]
# psp http://server file tar.gz [dir]
function download {
  DOWNLOAD_DIR=`echo "$2"|cut -d: -f2-|cut -b3-`
  cd $1
  if [ ! -f ../offline/$DOWNLOAD_DIR/$3.$4 ]; then
    mkdir -p ../offline/$DOWNLOAD_DIR
    wget -c -O ../offline/$DOWNLOAD_DIR/$3.$4 $2/$3.$4 || rm ../offline/$DOWNLOAD_DIR/$3.$4
  fi
  if [ "$5" == "" ]; then
    TARGET_DIR=$3
    CREATE_TARGET=0
    DOWNLOAD_PREFIX=../offline/$DOWNLOAD_DIR
  else
    TARGET_DIR=$5
    CREATE_TARGET=1
    DOWNLOAD_PREFIX=../../offline/$DOWNLOAD_DIR
  fi
  if [ ! -d $TARGET_DIR ]; then
    if [ $CREATE_TARGET == 1 ]; then
      mkdir $TARGET_DIR
      cd $TARGET_DIR
    fi
    if [ $4 == tar.gz ]; then
      tar -zxf $DOWNLOAD_PREFIX/$3.$4
    fi
    if [ $4 == tar.bz2 ]; then
      tar -jxf $DOWNLOAD_PREFIX/$3.$4
    fi
    if [ $4 == zip ]; then
      unzip -q $DOWNLOAD_PREFIX/$3.$4
    fi
    if [ $4 == rar ]; then
      unrar x $DOWNLOAD_PREFIX/$3.$4
    fi
    if [ $CREATE_TARGET == 1 ]; then
      cd ..
    fi
    if [ -d $TARGET_DIR ]; then
      cd $TARGET_DIR
      if [ -f ../patches/$3-PSP.patch ]; then
        patch -p1 < ../patches/$3-PSP.patch
      fi
      if [ -f ../psptoolchain/patches/$3-PSP.patch ]; then
        patch -p1 < ../psptoolchain/patches/$3-PSP.patch
      fi
      if [ -f ../../mingw/patches/$3-MINPSPW.patch ]; then
        patch -p1 < ../../mingw/patches/$3-MINPSPW.patch
      fi
      if [ -f ../../mingw/patches/$3-$OS.patch ]; then
        patch -p1 < ../../mingw/patches/$3-$OS.patch
      fi
      if [ -f $3.patch ]; then
        patch -p1 < $3.patch
      fi
      cd ..
    fi
  fi
  cd ..
}

# arg1 target
# arg2 svn reppo
# arg3 module
function svnGet {
  DOWNLOAD_DIR=`echo "$2"|cut -d: -f2-|cut -b3-`
  cd $1
  if [ ! -d $3 ]
  then
    if [ ! -d ../offline/$DOWNLOAD_DIR/$3 ]; then
      mkdir -p ../offline/$DOWNLOAD_DIR
      cd ../offline/$DOWNLOAD_DIR
      svn co $2/$3 $3
      cd -
    else
      cd ../offline/$DOWNLOAD_DIR/$3
      svn up || echo "*** SVN not updated!!! ***"
      cd -
    fi
    cp -Rf ../offline/$DOWNLOAD_DIR/$3 .
    cd $3
    # some SDK files are in DOS format, fix back to UNIX
    if [ -f src/samples/Makefile.am ]; then
      awk '{ sub("\r$", ""); print }' src/samples/Makefile.am > tmp
      mv -f tmp src/samples/Makefile.am
    fi
    if [ -f src/base/build.mak ]; then
      awk '{ sub("\r$", ""); print }' src/base/build.mak > tmp
      mv -f tmp src/base/build.mak
    fi
    # normal patching
    if [ -f ../psptoolchain/patches/$3-PSP.patch ]; then
      patch -p1 < ../psptoolchain/patches/$3-PSP.patch
    fi
    if [ -f ../patches/$3-PSP.patch ]; then
      patch -p1 < ../patches/$3-PSP.patch
    fi
    if [ -f ../../mingw/patches/$3-MINPSPW.patch ]; then
      patch -p1 < ../../mingw/patches/$3-MINPSPW.patch
    fi
    if [ -f $3.patch ]; then
      patch -p1 < $3.patch
    fi
    cd ..
  else
    cd $3
    svn up || echo "*** SVN not updated!!! ***"
    cd ..
  fi
  cd ..
}

# arg1 target
# arg2 git reppo
# arg3 name
function gitClone {
  DOWNLOAD_DIR=`echo "$2"|cut -d: -f2-|cut -b3-`
  cd $1
  if [ ! -d $3 ]
  then
    if [ ! -d ../offline/$DOWNLOAD_DIR/$3 ]; then
      mkdir -p ../offline/$DOWNLOAD_DIR
      cd ../offline/$DOWNLOAD_DIR
      git clone $2
      cd -
    else
      cd ../offline/$DOWNLOAD_DIR/$3
      git pull || echo "*** Git not updated!!! ***"
      cd -
    fi
    cp -Rf ../offline/$DOWNLOAD_DIR/$3 .
    cd $3
    # normal patching
    if [ -f ../patches/$3-PSP.patch ]; then
      patch -p1 < ../patches/$3-PSP.patch
    fi
    if [ -f ../psptoolchain/patches/$3-PSP.patch ]; then
      patch -p1 < ../psptoolchain/patches/$3-PSP.patch
    fi
    if [ -f ../../mingw/patches/$3-MINPSPW.patch ]; then
      patch -p1 < ../../mingw/patches/$3-MINPSPW.patch
    fi
    if [ -f $3.patch ]; then
      patch -p1 < $3.patch
    fi
    cd ..
  else
    cd $3
    git pull || echo "*** Git not updated!!! ***"
    cd ..
  fi
  cd ..
}

function prepare {

  mkdir -p psp/build
  mkdir -p deps

  export OS=$(uname -s)

  if [ "$OS" == "SunOS" ]; then
    EXTRA_BUILD_CFG=""
    INSTALLDIR="$(pwd)/../pspsdk"
    GMP_INCLUDE=/usr/include/gmp
    MPFR_INCLUDE=/usr/include/mpfr
    GMP_LIB=/usr/lib
    MPFR_LIB=/usr/lib
    GMP_PREFIX=/usr
    PPL_PREFIX=/usr
    ICONV_PREFIX=/usr
    MAKE_CMD=make

    if [ ! -e compat ]; then
      mkdir -p compat
      ln -s `which gcc-4.3.2` compat/gcc
      ln -s `which g++-4.3.2` compat/g++
      ln -s /opt/SunStudioExpress/bin/cc compat/cc
      ln -s /opt/SunStudioExpress/bin/CC compat/CC
      ln -s /usr/bin/automake-1.10 compat/automake
      ln -s /usr/bin/aclocal-1.10 compat/aclocal
    fi
    export PATH=`pwd`/compat:$PATH
  fi

  if [ "$OS" == "Linux" ]; then
    EXTRA_BUILD_CFG="--disable-multilib"
    INSTALLDIR="$(pwd)/../pspsdk"
    GMP_INCLUDE=$(pwd)/deps/local/include
    MPFR_INCLUDE=$(pwd)/deps/local/include
    GMP_LIB=$(pwd)/deps/local/lib
    MPFR_LIB=$(pwd)/deps/local/lib
    GMP_PREFIX=$(pwd)/deps/local
    PPL_PREFIX=$(pwd)/deps/local
    ICONV_PREFIX=/usr
    MAKE_CMD="make -s -j2 LDFLAGS=\"-s\""
    #-----------------------------------------------------------------------------
    # pre requisites
    #-----------------------------------------------------------------------------
    . ./mingw/dependencies-Linux.sh $(pwd)
  fi

  # --- XP 32 bits
  if [ "$OS" == "MINGW32_NT-5.1" ]; then
    OS=MINGW32_NT
  fi
  # --- Vista 32 bits
  if [ "$OS" == "MINGW32_NT-6.0" ]; then
    OS=MINGW32_NT
  fi
  # --- Windows 7 32 bits
  if [ "$OS" == "MINGW32_NT-6.1" ]; then
    OS=MINGW32_NT
  fi

  if [ "$OS" == "MINGW32_NT" ]; then
    # since I'm running this under a Xeon processor, I don't want it to be
    # build that cpu, so I must instruct mingw to target a i686
    EXTRA_BUILD_CFG="--build=i686-pc-mingw32"
    # GDC has a bug that forces the install to be hardcoded
    INSTALLDIR="/pspsdk"
    INSTALLERDIR="/c/pspsdk-installer"
    GMP_INCLUDE=/usr/local/include
    MPFR_INCLUDE=/usr/local/include
    GMP_LIB=/usr/local/lib
    MPFR_LIB=/usr/local/lib
    GMP_PREFIX=/usr/local
    PPL_PREFIX=/usr/local
    ICONV_PREFIX=/usr/local
    MAKE_CMD="make -s LDFLAGS=\"-s\""

    #-----------------------------------------------------------------------------
    # pre requisites
    #-----------------------------------------------------------------------------
    . ./mingw/dependencies-MINGW32_NT.sh
  fi

  if [ "$OS" == "Darwin" ]; then
    EXTRA_BUILD_CFG=""
    INSTALLDIR="$(pwd)/../pspsdk"
    GMP_INCLUDE=/opt/local/include
    MPFR_INCLUDE=/opt/local/include
    GMP_LIB=/opt/local/lib
    MPFR_LIB=/opt/local/lib
    GMP_PREFIX=/opt/local
    PPL_PREFIX=/opt/local
    ICONV_PREFIX=/opt/local
    MAKE_CMD=make
  fi

  checkTool svn
  checkTool git
  checkTool wget
  checkTool make
  checkTool awk
  checkTool makeinfo
  checkTool python
  checkTool flex
  checkTool bison
  checkTool cmake

  # nice to have
  #installPremake

  TOOLPATH=$(echo $INSTALLDIR | sed -e 's/^\([a-zA-Z]\):/\/\1/')
  [ ! -z "$INSTALLDIR" ] && mkdir -p $INSTALLDIR && touch $INSTALLDIR/nonexistantfile && rm $INSTALLDIR/nonexistantfile || exit 1;
  export PATH=$TOOLPATH/bin:$PATH
}

#arg1 base path
#arg2 devpak folder number
#arg3 devpak
#arg4 installer path
function buildAndInstallDevPak {
  cd $1/$2_$3
  rm -Rf build || true
  ./devpak.sh
  tar -C $(psp-config --pspdev-path) -xjf $1/$2_$3/build/$3-*.tar.bz2
  # only install if we are on windows
  if [ "$OS" == "MINGW32_NT" ]; then
    tar -C $4 -xjf $1/$2_$3/build/$3-*.tar.bz2
  fi
}

function installPremake {
  PREMAKE_BIN=premake4

  if [ "$OS" == "MINGW32_NT" ]; then
    PREMAKE_BIN=$PREMAKE_BIN.exe
  fi

  if [ ! -f ./mingw/bin/$PREMAKE_BIN ]; then
    download deps "http://downloads.sourceforge.net/premake" "premake-4.3-src" "zip"
    if [ "$OS" == "MINGW32_NT" ]; then
      cd deps/premake-4.3/build/gmake.windows
      CC=gcc CXX=g++ $MAKE_CMD
    fi
    if [ "$OS" == "Linux" ]; then
      cd deps/premake-4.3/build/gmake.unix
      $MAKE_CMD
    fi
    if [ "$OS" == "SunOS" ]; then
      cd deps/premake-4.3/build/gmake.unix
      $MAKE_CMD
    fi
    if [ "$OS" == "Darwin" ]; then
      cd deps/premake-4.3/build/gmake.macosx
      $MAKE_CMD
    fi

    cp ../../bin/release/* ../../../../mingw/bin/
    cd ../../../..
  fi
}

function downloadPatches {
  svnGet psp "svn://svn.ps2dev.org/psp/trunk/psptoolchain" "patches"
  gitClone psp "https://github.com/pspdev/psptoolchain.git" "psptoolchain"
}

function buildBinutils {
  BINUTILS_SRCDIR="binutils-"$BINUTILS_VER

  download psp "http://ftp.gnu.org/gnu/binutils" "binutils-"$BINUTILS_VER "tar.bz2"

  if [ ! -d psp/build/$BINUTILS_SRCDIR ]
  then
    mkdir -p psp/build/$BINUTILS_SRCDIR
    cd psp/build/$BINUTILS_SRCDIR

    ../../$BINUTILS_SRCDIR/configure $EXTRA_BUILD_CFG \
        --prefix=$INSTALLDIR \
        --target=psp \
        --enable-install-libbfd \
        --disable-werror \
        --disable-nls
  else
    cd psp/build/$BINUTILS_SRCDIR
  fi

  if [ "$OS" == "Darwin" ]; then
    $MAKE_CMD -r
    $MAKE_CMD -r install
  else
    $MAKE_CMD
    $MAKE_CMD install
  fi
  cd ../../..
}

# build a compiler so we can bootstrap the SDK and the newlib
function buildXGCC {
  GCC_SRCDIR="gcc-"$GCC_VER

  download psp "http://ftp.gnu.org/gnu/gcc/gcc-"$GCC_VER "gcc-"$GCC_VER "tar.bz2"

  if [ ! -d psp/build/x$GCC_SRCDIR ]
  then
    # the patch does not keep the exec bit
    if [ -f psp/$GCC_SRCDIR/libphobos/config/x3 ]; then
      chmod a+x psp/$GCC_SRCDIR/libphobos/config/x3
    fi

    mkdir -p psp/build/x$GCC_SRCDIR
    cd psp/build/x$GCC_SRCDIR

    ../../$GCC_SRCDIR/configure $EXTRA_BUILD_CFG \
        --prefix=$INSTALLDIR \
        --target=psp \
        --enable-languages="c" \
        --with-newlib \
        --without-headers \
        --disable-win32-registry \
        --disable-nls \
        --disable-libstdcxx-pch \
        --with-libiconv-prefix=$ICONV_PREFIX \
        --with-gmp-include=$GMP_INCLUDE \
        --with-gmp-lib=$GMP_LIB \
        --with-mpfr-include=$MPFR_INCLUDE \
        --with-mpfr-lib=$MPFR_LIB
  else
    cd psp/build/x$GCC_SRCDIR
  fi

  if [ "$OS" == "MINGW32_NT" ]; then
    $MAKE_CMD CFLAGS="-D__USE_MINGW_ACCESS" all-gcc
  else
    $MAKE_CMD all-gcc
  fi

  $MAKE_CMD install-gcc
  cd ../../..
}

function bootstrapSDK {
  gitClone psp "https://github.com/pspdev/pspsdk.git" "pspsdk"
  cd psp
  if [ ! -f pspsdk/configure ]
  then
    cd pspsdk
    ./bootstrap
    cd ..
  fi

  if [ ! -d build/pspsdk ]
  then
    mkdir -p build/pspsdk
    cd build/pspsdk
    ../../pspsdk/configure --with-pspdev="$INSTALLDIR" --enable-werror
  else
    cd build/pspsdk
  fi

  $MAKE_CMD install-data
  cd ../../..
}

function buildNewlib {
  NEWLIB_SRCDIR="newlib-"$NEWLIB_VER
  download psp "ftp://sources.redhat.com/pub/newlib" "newlib-"$NEWLIB_VER "tar.gz"

  if [ ! -d psp/build/$NEWLIB_SRCDIR ]
  then
    mkdir -p psp/build/$NEWLIB_SRCDIR
    cd psp/build/$NEWLIB_SRCDIR

    ../../$NEWLIB_SRCDIR/configure \
        --target=psp \
        --enable-newlib-hw-fp \
        --disable-nls \
        --prefix=$INSTALLDIR
  else
    cd psp/build/$NEWLIB_SRCDIR
  fi

  $MAKE_CMD
  $MAKE_CMD install
  cd ../../..
}

function buildGCC {

  GCC_SRCDIR="gcc-"$GCC_VER

  if [ ! -d psp/build/$GCC_SRCDIR ]
  then
    mkdir -p psp/build/$GCC_SRCDIR
    cd psp/build/$GCC_SRCDIR

    # in order to get gcov to build libgcov we need to specify with-headers in conjuction with newlib
    ../../$GCC_SRCDIR/configure $EXTRA_BUILD_CFG \
        --prefix=$INSTALLDIR \
        --target=psp \
        --enable-languages=$LANGUAGES \
        --enable-cxx-flags="-G0" \
        --with-newlib \
        --with-headers \
        --disable-win32-registry \
        --disable-nls \
        --disable-libstdcxx-pch \
        --with-libiconv-prefix=$ICONV_PREFIX \
        --with-gmp-include=$GMP_INCLUDE \
        --with-gmp-lib=$GMP_LIB \
        --with-mpfr-include=$MPFR_INCLUDE \
        --with-mpfr-lib=$MPFR_LIB
  else
    cd psp/build/$GCC_SRCDIR
  fi

  if [ "$OS" == "MINGW32_NT" ]; then
    $MAKE_CMD CFLAGS="-D__USE_MINGW_ACCESS" CFLAGS_FOR_TARGET="-G0"
  else
    $MAKE_CMD CFLAGS_FOR_TARGET="-G0"
  fi

  $MAKE_CMD install
  cd ../../..
}

function buildSDK {
  cd psp/build/pspsdk
  make
  make install
  cd ../../..
}

function validateSDK {
  if [ "$OS" == "MINGW32_NT" ]; then
    # GDC on windows must be installed on this path it is a bug, known one!!!
    cp -Rf $INSTALLDIR /c/$INSTALLDIR
  fi
  find $INSTALLDIR/psp/sdk/samples -type f -name "Makefile" | xargs $(pwd)/mingw/build-sample.sh $1
  if [ "$OS" == "MINGW32_NT" ]; then
    rm -Rf /c/$INSTALLDIR
  fi
}

function buildGDB {
  GDB_SRCDIR="gdb-"$GDB_VER

  download psp "http://ftp.gnu.org/gnu/gdb" "gdb-"$GDB_VER "tar.bz2"

  if [ ! -d psp/build/$GDB_SRCDIR ]
  then
    mkdir -p psp/build/$GDB_SRCDIR
    cd psp/build/$GDB_SRCDIR

    ../../$GDB_SRCDIR/configure $EXTRA_BUILD_CFG \
        --prefix=$INSTALLDIR \
        --target=psp \
        --disable-nls \
        --disable-werror \
		--enable-static \
		--disable-shared \
        --with-libiconv-prefix=$ICONV_PREFIX \
        --with-gmp-include=$GMP_INCLUDE \
        --with-gmp-lib=$GMP_LIB \
        --with-mpfr-include=$MPFR_INCLUDE \
        --with-mpfr-lib=$MPFR_LIB
  else
    cd psp/build/$GDB_SRCDIR
  fi

  $MAKE_CMD
  $MAKE_CMD install
  cd ../../..
}

function installExtraBinaries {
  if [ "$OS" == "MINGW32_NT" ]; then
    UNXUTILS_DIR="UnxUtils"
    download deps "http://downloads.sourceforge.net/unxutils" "UnxUtils" "zip" $UNXUTILS_DIR

    cd deps/$UNXUTILS_DIR
    /bin/cp usr/local/wbin/cp.exe $INSTALLDIR/bin
    /bin/cp usr/local/wbin/rm.exe $INSTALLDIR/bin
    /bin/cp usr/local/wbin/mkdir.exe $INSTALLDIR/bin
    /bin/cp usr/local/wbin/sed.exe $INSTALLDIR/bin
    cd ../..

    MINGW32_MAKE_DIR="make-"$MINGW32_MAKE_VER
    download deps "http://downloads.sourceforge.net/mingw" "make-"$MINGW32_MAKE_VER "tar.gz" $MINGW32_MAKE_DIR

    cd deps/$MINGW32_MAKE_DIR
    /bin/cp make.exe $INSTALLDIR/bin
    /bin/cp -Rf info $INSTALLDIR/info
    cd ../..

    # true for some samples (namely minifire asm demo)
    gcc -s -Wall -O3 -o $INSTALLDIR/bin/true.exe mingw/true.c
    # visual studio support
    /bin/cp mingw/bin/vsmake.bat $INSTALLDIR/bin

    # in case any win32 native bin was linked with threads we
    # add the dll to the output install dir too
    # cp /mingw/bin/pthreadGC2.dll $INSTALLDIR/bin
  fi

  # need to have psp-pkg-config hack for building some packages
  gcc -s -Wall -O3 -o $INSTALLDIR/bin/psp-pkg-config mingw/psp-pkg-config.c
}

function installPSPLinkUSB {
  gitClone psp "https://github.com/pspdev/psplinkusb.git" "psplinkusb"
  cd psp
  if [ "$OS" == "MINGW32_NT" ]; then
    cd psplinkusb
    CC=gcc CXX=g++ BUILD_WIN32=1 $MAKE_CMD -C pspsh clean install
    CC=gcc CXX=g++ BUILD_WIN32=1 $MAKE_CMD -C tools/remotejoy/pcsdl clean install
    cd ..
    # usbhostfs_pc (not yet ported to native win32)
    cp ../mingw/bin/usbhostfs_pc.exe $INSTALLDIR/bin
    cp ../mingw/bin/cygncurses-8.dll $INSTALLDIR/bin
    cp ../mingw/bin/cygreadline6.dll $INSTALLDIR/bin
    cp ../mingw/bin/cygwin1.dll $INSTALLDIR/bin

    # copy the drivers for windows
    mkdir -p $INSTALLDIR/bin/driver
    cp ../mingw/bin/usb/driver/libusb0.dll $INSTALLDIR/bin/driver
    cp ../mingw/bin/usb/driver/libusb0.sys $INSTALLDIR/bin/driver
    cp ../mingw/bin/usb/driver/psp.cat $INSTALLDIR/bin/driver
    cp ../mingw/bin/usb/driver/psp.inf $INSTALLDIR/bin/driver
    # 64 bits
    mkdir -p $INSTALLDIR/bin/driver_x64
    cp ../mingw/bin/usb/driver_x64/libusb0.dll $INSTALLDIR/bin/driver_x64
    cp ../mingw/bin/usb/driver_x64/libusb0.sys $INSTALLDIR/bin/driver_x64
    cp ../mingw/bin/usb/driver_x64/psp.cat $INSTALLDIR/bin/driver_x64
    cp ../mingw/bin/usb/driver_x64/psp.inf $INSTALLDIR/bin/driver_x64
    cp ../mingw/bin/usb/driver_x64/libusb0_x64.dll $INSTALLDIR/bin/driver_x64
    cp ../mingw/bin/usb/driver_x64/libusb0_x64.sys $INSTALLDIR/bin/driver_x64
    cp ../mingw/bin/usb/driver_x64/psp_x64.cat $INSTALLDIR/bin/driver_x64
  fi
  if [ "$OS" == "SunOS" ]; then
    cd psplinkusb
    CC=cc CXX=CC BUILD_SOLARIS=1 $MAKE_CMD -f Makefile.clients clean install
    cd ..
  fi
  if [ "$OS" == "Darwin" ]; then
    cd psplinkusb
    BUILD_MACOSX=1 BUILD_LIBUSB10=1 $MAKE_CMD -f Makefile.clients clean install
    cd ..
  fi
  if [ "$OS" == "Linux" ]; then
    cd psplinkusb
    $MAKE_CMD -f Makefile.clients clean install
    cd ..
  fi

  cd psplinkusb
  make -f Makefile.psp clean
  make -f Makefile.psp release
  cd release

  install -d $INSTALLDIR/psplink/psp
  install -d $INSTALLDIR/psplink/psp/scripts
  install -m 644 scripts/loadvsh.sh $INSTALLDIR/psplink/psp/scripts
  install -m 644 scripts/README $INSTALLDIR/psplink/psp/scripts
  install -d $INSTALLDIR/psplink/psp/v1.0
  install -d $INSTALLDIR/psplink/psp/v1.0/psplink
  install -m 644 v1.0/psplink/EBOOT.PBP $INSTALLDIR/psplink/psp/v1.0/psplink/EBOOT.PBP
  install -m 644 v1.0/psplink/psplink.ini $INSTALLDIR/psplink/psp/v1.0/psplink/psplink.ini
  install -m 644 v1.0/psplink/psplink.prx $INSTALLDIR/psplink/psp/v1.0/psplink/psplink.prx
  install -m 644 v1.0/psplink/psplink_user.prx $INSTALLDIR/psplink/psp/v1.0/psplink/psplink_user.prx
  install -m 644 v1.0/psplink/usbgdb.prx $INSTALLDIR/psplink/psp/v1.0/psplink/usbgdb.prx
  install -m 644 v1.0/psplink/usbhostfs.prx $INSTALLDIR/psplink/psp/v1.0/psplink/usbhostfs.prx
  install -d $INSTALLDIR/psplink/psp/v1.5
  install -d $INSTALLDIR/psplink/psp/v1.5/psplink
  install -m 644 v1.5/psplink/EBOOT.PBP $INSTALLDIR/psplink/psp/v1.5/psplink/EBOOT.PBP
  install -m 644 v1.5/psplink/psplink.ini $INSTALLDIR/psplink/psp/v1.5/psplink/psplink.ini
  install -m 644 v1.5/psplink/psplink.prx $INSTALLDIR/psplink/psp/v1.5/psplink/psplink.prx
  install -m 644 v1.5/psplink/psplink_user.prx $INSTALLDIR/psplink/psp/v1.5/psplink/psplink_user.prx
  install -m 644 v1.5/psplink/usbgdb.prx $INSTALLDIR/psplink/psp/v1.5/psplink/usbgdb.prx
  install -m 644 v1.5/psplink/usbhostfs.prx $INSTALLDIR/psplink/psp/v1.5/psplink/usbhostfs.prx
  install -d $INSTALLDIR/psplink/psp/v1.5/psplink\%
  install -m 644 v1.5/psplink\%/EBOOT.PBP $INSTALLDIR/psplink/psp/v1.5/psplink\%/EBOOT.PBP
  install -d $INSTALLDIR/psplink/psp/v1.5_nocorrupt
  install -d $INSTALLDIR/psplink/psp/v1.5_nocorrupt/__SCE__psplink
  install -m 644 v1.5_nocorrupt/__SCE__psplink/EBOOT.PBP $INSTALLDIR/psplink/psp/v1.5_nocorrupt/__SCE__psplink/EBOOT.PBP
  install -m 644 v1.5_nocorrupt/__SCE__psplink/psplink.ini $INSTALLDIR/psplink/psp/v1.5_nocorrupt/__SCE__psplink/psplink.ini
  install -m 644 v1.5_nocorrupt/__SCE__psplink/psplink.prx $INSTALLDIR/psplink/psp/v1.5_nocorrupt/__SCE__psplink/psplink.prx
  install -m 644 v1.5_nocorrupt/__SCE__psplink/psplink_user.prx $INSTALLDIR/psplink/psp/v1.5_nocorrupt/__SCE__psplink/psplink_user.prx
  install -m 644 v1.5_nocorrupt/__SCE__psplink/usbgdb.prx $INSTALLDIR/psplink/psp/v1.5_nocorrupt/__SCE__psplink/usbgdb.prx
  install -m 644 v1.5_nocorrupt/__SCE__psplink/usbhostfs.prx $INSTALLDIR/psplink/psp/v1.5_nocorrupt/__SCE__psplink/usbhostfs.prx
  install -d $INSTALLDIR/psplink/psp/v1.5_nocorrupt/\%__SCE__psplink
  install -m 644 v1.5_nocorrupt/\%__SCE__psplink/EBOOT.PBP $INSTALLDIR/psplink/psp/v1.5_nocorrupt/\%__SCE__psplink/EBOOT.PBP
  install -m 644 LICENSE $INSTALLDIR/psplink
  install -m 644 psplink_manual.pdf $INSTALLDIR/psplink
  install -m 644 README $INSTALLDIR/psplink

  cd ..
  make -f Makefile.oe clean
  make -f Makefile.oe release

  cd release_oe
  install -d $INSTALLDIR/psplink/psp/oe
  install -d $INSTALLDIR/psplink/psp/oe/psplink
  install -m 644 psplink/EBOOT.PBP $INSTALLDIR/psplink/psp/oe/psplink/EBOOT.PBP
  install -m 644 psplink/psplink.ini $INSTALLDIR/psplink/psp/oe/psplink/psplink.ini
  install -m 644 psplink/psplink.prx $INSTALLDIR/psplink/psp/oe/psplink/psplink.prx
  install -m 644 psplink/psplink_user.prx $INSTALLDIR/psplink/psp/oe/psplink/psplink_user.prx
  install -m 644 psplink/usbgdb.prx $INSTALLDIR/psplink/psp/oe/psplink/usbgdb.prx
  install -m 644 psplink/usbhostfs.prx $INSTALLDIR/psplink/psp/oe/psplink/usbhostfs.prx

  cd ../../..
}

function buildPRXTool {
  gitClone psp "https://github.com/pspdev/prxtool.git" "prxtool"
  cd psp
  if [ ! -f prxtool/configure ]
  then
    cd prxtool
    ./bootstrap || true
    cd ..
  fi

  if [ ! -d build/prxtool ]
  then
    mkdir -p build/prxtool
    cd build/prxtool
	if [ "$OS" == "MINGW32_NT" ]; then
	  LDFLAGS="-static -s" ../../prxtool/configure --prefix=$INSTALLDIR
	else
	  ../../prxtool/configure --prefix=$INSTALLDIR
	fi
  else
    cd build/prxtool
  fi

  $MAKE_CMD
  $MAKE_CMD install
  cd ../../..
}

function installMan {
  if [ "$OS" == "MINGW32_NT" ]; then
    MINGW32_GROFF_DIR="groff-"$MINGW32_GROFF_VER
    download deps "http://downloads.sourceforge.net/gnuwin32" "groff-"$MINGW32_GROFF_VER"-bin" "zip" "groff-"$MINGW32_GROFF_VER

    cd deps
    cp $MINGW32_GROFF_DIR/bin/groff.exe $INSTALLDIR/bin
    cp $MINGW32_GROFF_DIR/bin/grotty.exe $INSTALLDIR/bin
    cp $MINGW32_GROFF_DIR/bin/troff.exe $INSTALLDIR/bin
    mkdir -p $INSTALLDIR/share
    cp -Rf $MINGW32_GROFF_DIR/share/groff/$MINGW32_GROFF_VER/font $INSTALLDIR/share
    cp -Rf $MINGW32_GROFF_DIR/share/groff/$MINGW32_GROFF_VER/tmac $INSTALLDIR/share
    cd ..

    MINGW32_LESS_DIR="less-"$MINGW32_LESS_VER
    download deps "http://downloads.sourceforge.net/gnuwin32" "less-"$MINGW32_LESS_VER"-bin" "zip" "less-"$MINGW32_LESS_VER"-bin"
    download deps "http://downloads.sourceforge.net/gnuwin32" "less-"$MINGW32_LESS_VER"-dep" "zip" "less-"$MINGW32_LESS_VER"-dep"

    cd deps
    cp $MINGW32_LESS_DIR"-bin"/bin/less.exe $INSTALLDIR/bin
    cp $MINGW32_LESS_DIR"-dep"/bin/pcre3.dll $INSTALLDIR/bin
    cp ../mingw/bin/man.bat $INSTALLDIR/bin
    cd ..
  fi
}

function installInfo {
  if [ "$OS" == "MINGW32_NT" ]; then
    cp mingw/bin/info.bat $INSTALLDIR/bin
    cp mingw/bin/ginfo.exe $INSTALLDIR/bin
  fi
}

function patchCMD {
  if [ "$OS" == "MINGW32_NT" ]; then
    # make sure the line endings are correct (UNIX style)
    awk '{ sub("\r$", ""); print }' $INSTALLDIR/psp/sdk/lib/build.mak > $INSTALLDIR/psp/sdk/lib/build.mak.unix
    mv -f $INSTALLDIR/psp/sdk/lib/build.mak.unix $INSTALLDIR/psp/sdk/lib/build.mak

    awk '{ sub("\r$", ""); print }' $INSTALLDIR/psp/sdk/lib/build_prx.mak > $INSTALLDIR/psp/sdk/lib/build_prx.mak.unix
    mv -f $INSTALLDIR/psp/sdk/lib/build_prx.mak.unix $INSTALLDIR/psp/sdk/lib/build_prx.mak

    patch -p1 -d $INSTALLDIR/psp/sdk -i $(pwd)/mingw/patches/pspsdk-CMD.patch
  fi
}

function prepareDistro {
  # add release notes
  cp readme.txt $INSTALLDIR/readme.txt

  if [ "$OS" == "MINGW32_NT" ]; then
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

    mv $INSTALLERDIR/base/bin/groff.exe $INSTALLERDIR/documentation/man_info/bin/groff.exe
    mv $INSTALLERDIR/base/bin/grotty.exe $INSTALLERDIR/documentation/man_info/bin/grotty.exe
    mv $INSTALLERDIR/base/bin/less.exe $INSTALLERDIR/documentation/man_info/bin/less.exe
    mv $INSTALLERDIR/base/bin/man.bat $INSTALLERDIR/documentation/man_info/bin/man.bat
    mv $INSTALLERDIR/base/bin/pcre3.dll $INSTALLERDIR/documentation/man_info/bin/pcre3.dll
    mv $INSTALLERDIR/base/bin/troff.exe $INSTALLERDIR/documentation/man_info/bin/troff.exe
    # create info stuff and add info viewer
    mv $INSTALLERDIR/base/info $INSTALLERDIR/documentation/man_info/info

    mv $INSTALLERDIR/base/bin/info.bat $INSTALLERDIR/documentation/man_info/bin/info.bat
    mv $INSTALLERDIR/base/bin/ginfo.exe $INSTALLERDIR/documentation/man_info/bin/info.exe

    # generate doxygen docs
    cd psp/build/pspsdk
    $MAKE_CMD doxygen-doc
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
  else
    # generate doxygen docs
    cd psp/build/pspsdk
    $MAKE_CMD doxygen-doc
    mkdir -p $INSTALLDIR/doc
    cp -fR doc $INSTALLDIR/doc/pspsdk
    cd ../../..
  fi
}

function buildBaseDevpaks {
  # create the base set of devpaks
  if [ "$OS" == "MINGW32_NT" ]; then
    mkdir -p $INSTALLERDIR/devpaks
    DEVPAK_TARGET=$INSTALLERDIR/devpaks
    # need to disable all commands that interfere with msys
    mv $INSTALLDIR/bin/cp.exe $INSTALLDIR/bin/cp-minpspw.exe || true
    mv $INSTALLDIR/bin/rm.exe $INSTALLDIR/bin/rm-minpspw.exe || true
    mv $INSTALLDIR/bin/mkdir.exe $INSTALLDIR/bin/mkdir-minpspw.exe || true
    mv $INSTALLDIR/bin/sed.exe $INSTALLDIR/bin/sed-minpspw.exe || true
    mv $INSTALLDIR/bin/make.exe $INSTALLDIR/bin/make-minpspw.exe || true
    mv $INSTALLDIR/bin/groff.exe $INSTALLDIR/bin/groff-minpspw.exe || true
    mv $INSTALLDIR/bin/grotty.exe $INSTALLDIR/bin/grotty-minpspw.exe || true
    mv $INSTALLDIR/bin/troff.exe $INSTALLDIR/bin/troff-minpspw.exe || true
    mv $INSTALLDIR/bin/less.exe $INSTALLDIR/bin/less-minpspw.exe || true
  fi
  BASE=$(pwd)/devpaks

  buildAndInstallDevPak $BASE 001 zlib $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 002 bzip2 $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 003 freetype $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 004 jpeg $DEVPAK_TARGET
  # bulletml deppends on tinyxml
  buildAndInstallDevPak $BASE 033 tinyxml $DEVPAK_TARGET
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
  #disabled at the moment, although it builds it doesn't work as expected
  #buildAndInstallDevPak $BASE 023 ode $DEVPAK_TARGET
  #buildAndInstallDevPak $BASE 024 TinyGL $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 025 libpthreadlite $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 026 cal3d $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 027 mikmodlib $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 028 cpplibs $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 029 flac $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 030 giflib $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 031 libpspmath $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 032 pthreads-emb $DEVPAK_TARGET
  #buildAndInstallDevPak $BASE 034 oslib $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 035 libcurl $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 036 intrafont $DEVPAK_TARGET
  #buildAndInstallDevPak $BASE 037 libaac $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 038 Jello $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 039 zziplib $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 040 Mini-XML $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 041 allegro $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 042 libmpeg2 $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 043 bullet $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 044 cubicvr $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 045 oslibmod $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 046 openTRI $DEVPAK_TARGET

  # restore
  if [ "$OS" == "MINGW32_NT" ]; then
    mv $INSTALLDIR/bin/cp-minpspw.exe $INSTALLDIR/bin/cp.exe || true
    mv $INSTALLDIR/bin/rm-minpspw.exe $INSTALLDIR/bin/rm.exe || true
    mv $INSTALLDIR/bin/mkdir-minpspw.exe $INSTALLDIR/bin/mkdir.exe || true
    mv $INSTALLDIR/bin/sed-minpspw.exe $INSTALLDIR/bin/sed.exe || true
    mv $INSTALLDIR/bin/make-minpspw.exe $INSTALLDIR/bin/make.exe || true
    mv $INSTALLDIR/bin/groff-minpspw.exe $INSTALLDIR/bin/groff.exe || true
    mv $INSTALLDIR/bin/grotty-minpspw.exe $INSTALLDIR/bin/grotty.exe || true
    mv $INSTALLDIR/bin/troff-minpspw.exe $INSTALLDIR/bin/troff.exe || true
    mv $INSTALLDIR/bin/less-minpspw.exe $INSTALLDIR/bin/less.exe || true
  fi
}

#---------------------------------------------------------------------------------
# main
#---------------------------------------------------------------------------------
prepare
if [ "$BUILD_ONLY_DEVPAKS" == "1" ]; then
  buildBaseDevpaks
else
  #---------------------------------------------------------------------------------
  # gather patches in a single place
  #---------------------------------------------------------------------------------
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
  if [ "$LANGUAGES" == "c,c++,objc,obj-c++,d" ]; then
    # this is because samples include D and ObjC examples
    # if you do not build all languages the script will fail
    # here
    validateSDK
  fi
  buildGDB
  #---------------------------------------------------------------------------------
  # PSPLink
  #---------------------------------------------------------------------------------
  buildPRXTool
  installPSPLinkUSB
  #---------------------------------------------------------------------------------
  # Extra binaries such as psp-pkg-config hack, true, etc...
  #---------------------------------------------------------------------------------
  installExtraBinaries
  #---------------------------------------------------------------------------------
  # Man and Info so windows users can read all documentation
  #---------------------------------------------------------------------------------
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
  #---------------------------------------------------------------------------------
  # Build base devpaks
  #---------------------------------------------------------------------------------
  #buildBaseDevpaks

  echo
  echo "Run the NSIS script to build the Installer"
fi
