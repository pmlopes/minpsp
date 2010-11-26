#!/bin/bash
set -e

#---------------------------------------------------------------------------------
# configuration
#---------------------------------------------------------------------------------

# package version
PSPSDK_VERSION=0.10.1

# sdk versions
BINUTILS_VER=2.18
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
    EXTRA_BUILD_CFG=""
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

    #-----------------------------------------------------------------------------
    # pre requisites
    #-----------------------------------------------------------------------------
    # generic
    installZlib
    installICONV
    installPTHREADS
    # disbled since the patch for readline fixes the termcap missing features
    # installPDCURSES
    installREADLINE
    # GCC specific
    installGMP
    installMPFR
#    # not needed right now
#    installPPL
#    installCLOOGPPL
#    installMPC
#    installLIBELF
    # nice to have
    installSDL
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
  export PATH=$TOOLPATH/bin:$PATH
}

function checkTool {
  if [ ! -f `which $1` ]; then
    echo "Please make sure you have '"$1"' installed."
    exit 1
  fi
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
    wget -c -O ../offline/$DOWNLOAD_DIR/$3.$4 $2/$3.$4
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
    cd $TARGET_DIR
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

function installZlib {
  if [ ! -f /mingw/include/zlib.h ]
  then
    download deps "http://www.zlib.net" "zlib-"$ZLIB_VER "tar.gz"
    cd deps/"zlib-"$ZLIB_VER
#    ./configure --prefix=/mingw --static
#    make
#    make install
    # version 1.2.5 seems another hack
    make -f win32/Makefile.gcc
    install zlib.h /mingw/include
    install zconf.h /mingw/include
    install libz.a /mingw/lib
    cd ../..
  fi
}

function installGMP {
  if [ ! -f /usr/local/include/gmp.h ]
  then
    download deps "http://ftp.gnu.org/gnu/gmp" "gmp-"$GMP_VER "tar.bz2"
    cd deps/"gmp-"$GMP_VER
    ./configure $EXTRA_BUILD_CFG \
      --prefix=/usr/local --enable-cxx
    make
    make check
    make install
    cd ../..
  fi
}

function installMPFR {
  if [ ! -f /usr/local/include/mpfr.h ]
  then
    download deps "http://www.mpfr.org/mpfr-"$MPFR_VER "mpfr-"$MPFR_VER "tar.bz2"
    cd deps/"mpfr-"$MPFR_VER
    ./configure $EXTRA_BUILD_CFG \
      --prefix=/usr/local \
      --with-gmp-include=$GMP_INCLUDE \
      --with-gmp-lib=$GMP_LIB
    make
    make check
    make install
    cd ../..
  fi
}

#function installPPL {
#  if [ ! -f /usr/local/include/ppl_c.h ]
#  then
#    download deps "http://www.cs.unipr.it/ppl/Download/ftp/releases/"$PPL_VER "ppl-"$PPL_VER "tar.bz2"
#    cd deps/"ppl-"$PPL_VER
#    ./configure $EXTRA_BUILD_CFG \
#      --prefix=/usr/local \
#      --with-libgmp-prefix=$GMP_PREFIX \
#      --with-libgmpxx-prefix=$GMP_PREFIX
#    make
#    make check
#    make install
#    cd ../..
#  fi
#}

#function installCLOOGPPL {
#  if [ ! -f /usr/local/include/cloog/cloog.h ]
#  then
#    download deps "ftp://gcc.gnu.org/pub/gcc/infrastructure" "cloog-ppl-"$CLOOG_PPL_VER "tar.gz"
#    cd deps/"cloog-ppl-"$CLOOG_PPL_VER
#    ./configure $EXTRA_BUILD_CFG \
#      --prefix=/usr/local \
#      --with-gmp-include=$GMP_INCLUDE \
#      --with-gmp-library=$GMP_LIB \
#      --with-ppl=$PPL_PREFIX
#    make
#    make check
#    make install
#    cd ../..
#  fi
#}

#function installMPC {
#  if [ ! -f /usr/local/include/mpc.h ]
#  then
#    download deps "http://www.multiprecision.org/mpc/download" "mpc-"$MPC_VER "tar.gz"
#    cd deps/"mpc-"$MPC_VER
#    ./configure $EXTRA_BUILD_CFG \
#      --prefix=/usr/local \
#      --enable-static \
#      --disable-shared \
#      --with-gmp-include=$GMP_INCLUDE \
#      --with-gmp-lib=$GMP_LIB \
#      --with-mpfr-include=$MPFR_INCLUDE \
#      --with-mpfr-lib=$MPFR_LIB
#    make
#    make check
#    make install
#    cd ../..
#  fi
#}

#function installLIBELF {
#  if [ ! -f /usr/local/include/libelf.h ]
#  then
#    download deps "http://www.mr511.de/software" "libelf-"$LIBELF_VER "tar.gz"
#    cd deps/"libelf-"$LIBELF_VER
#    ./configure \
#      --prefix=/usr/local \
#      --disable-shared
#    make
#    make install
#    cd ../..
#  fi
#}

#function installPDCURSES {
#  if [ ! -f /mingw/include/curses.h ]
#  then
#    download deps "http://downloads.sourceforge.net/pdcurses" "PDCurses-"$LIBPDCURSES_VER "tar.gz"
#    cd deps/"PDCurses-"$LIBPDCURSES_VER/win32
#    make -f mingwin32.mak DLL=n
#    cp pdcurses.a /mingw/lib/libcurses.a
#    cp pdcurses.a /mingw/lib/libpanel.a
#    cp ../curses.h /mingw/include
#    cp ../panel.h /mingw/include
#    cd ../../..
#  fi
#}

function installREADLINE {
  if [ ! -f /mingw/include/readline/readline.h ]
  then
    download deps "ftp://ftp.gnu.org/gnu/readline" "readline-"$LIBREADLINE_VER "tar.gz"
    cd deps/"readline-"$LIBREADLINE_VER
    ./configure \
      --prefix=/mingw \
      --without-curses \
      --disable-shared
    make
    make install
    cd ../..
  fi
}

function installICONV {
  if [ ! -f /mingw/include/iconv.h ]
  then
    download deps "ftp://ftp.gnu.org/gnu/libiconv" "libiconv-"$LIBICONV_VER "tar.gz"
    cd deps/"libiconv-"$LIBICONV_VER
    ./configure \
      --prefix=/mingw \
      --disable-shared \
      --enable-static
    make
    make install
    cd ../..
  fi
}

function installPTHREADS {
  if [ ! -f /mingw/include/pthread.h ]
  then
    download deps "ftp://sourceware.org/pub/pthreads-win32" "pthreads-w32-"$PTHREADS_VER"-release" "tar.gz"
    cd deps/"pthreads-w32-"$PTHREADS_VER"-release"
    make clean GC
    cp pthreadGC2.dll /mingw/lib/pthreadGC2.dll
    cp pthreadGC2.dll /mingw/bin/pthreadGC2.dll
    cp pthreadGC2.dll /mingw/lib/pthread.dll
    cp pthread.h sched.h /mingw/include
    cd ../..
  fi
}

function installSDL {
  if [ ! -f /usr/local/include/SDL/SDL.h ]
  then
    download deps "http://www.libsdl.org/release" "SDL-"$SDL_VER "tar.gz"
    cd deps/"SDL-"$SDL_VER
    ./configure \
      --prefix=/usr/local \
      --disable-shared \
      --enable-static
    make
    make install
    cd ../..
  fi
}

function downloadPatches {
  svnGet psp "svn://svn.ps2dev.org/psp/trunk/psptoolchain" "patches"
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
        --disable-shared \
        --with-stabs \
        --disable-werror \
        --disable-nls
  else
    cd psp/build/$BINUTILS_SRCDIR
    make clean
  fi

  make LDFLAGS="-s"
  make install
  cd ../../..
}

# build a compiler so we can bootstrap the SDK and the newlib
function buildXGCC {
  GCC_SRCDIR="gcc-"$GCC_VER

  download psp "http://ftp.gnu.org/gnu/gcc/gcc-"$GCC_VER "gcc-"$GCC_VER "tar.bz2"

  if [ ! -d psp/build/x$GCC_SRCDIR ]
  then
    # the patch does not keep the exec bit
    chmod a+x psp/$GCC_SRCDIR/libphobos/config/x3

    mkdir -p psp/build/x$GCC_SRCDIR
    cd psp/build/x$GCC_SRCDIR

    ../../$GCC_SRCDIR/configure $EXTRA_BUILD_CFG \
        --prefix=$INSTALLDIR \
        --target=psp \
        --enable-languages="c" \
        --disable-multilib \
        --disable-shared \
        --with-newlib \
        --without-headers \
        --disable-libssp \
        --disable-win32-registry \
        --disable-nls \
        --with-gmp-include=$GMP_INCLUDE \
        --with-gmp-lib=$GMP_LIB \
        --with-mpfr-include=$MPFR_INCLUDE \
        --with-mpfr-lib=$MPFR_LIB
  else
    cd psp/build/x$GCC_SRCDIR
    make clean
  fi

  if [ "$OS" == "MINGW32_NT" ]; then
    make CFLAGS="-D__USE_MINGW_ACCESS" LDFLAGS="-s" all-gcc
  else
    make LDFLAGS="-s" all-gcc
  fi

  make install-gcc
  cd ../../..
}

function bootstrapSDK {
  svnGet psp "svn://svn.ps2dev.org/psp/trunk" "pspsdk"
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
    ../../pspsdk/configure --with-pspdev="$INSTALLDIR"
  else
    cd build/pspsdk
    make clean
  fi

  make install-data
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
        --disable-nls \
        --prefix=$INSTALLDIR
  else
    cd psp/build/$NEWLIB_SRCDIR
    make clean
  fi

  make LDFLAGS="-s"
  make install
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
        --enable-languages="c,c++,objc,obj-c++,d" \
        --disable-multilib \
        --disable-shared \
        --enable-cxx-flags="-G0" \
        --with-newlib \
        --with-headers \
        --disable-win32-registry \
        --disable-nls \
        --enable-c99 \
        --enable-long-long \
        --with-gmp-include=$GMP_INCLUDE \
        --with-gmp-lib=$GMP_LIB \
        --with-mpfr-include=$MPFR_INCLUDE \
        --with-mpfr-lib=$MPFR_LIB
  else
    cd psp/build/$GCC_SRCDIR
    make clean
  fi

  if [ "$OS" == "MINGW32_NT" ]; then
    make CFLAGS="-D__USE_MINGW_ACCESS" CFLAGS_FOR_TARGET="-G0 -O2" LDFLAGS="-s"
  else
    make CFLAGS_FOR_TARGET="-G0 -O2" LDFLAGS="-s"
  fi

  make install
  cd ../../..
}

function buildSDK {
  cd psp/build/pspsdk
  make clean
  make LDFLAGS="-s"
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
        --disable-shared \
        --disable-werror
  else
    cd psp/build/$GDB_SRCDIR
    make clean
  fi

  make LDFLAGS="-s"
  make install
  cd ../../..
}

function installExtraBinaries {
  if [ "$OS" == "MINGW32_NT" ]; then
    UNXUTILS_DIR="UnxUtils"
    download deps "http://downloads.sourceforge.net/unxutils" "UnxUtils" "zip" $UNXUTILS_DIR

    cd deps/$UNXUTILS_DIR
    cp usr/local/wbin/cp.exe $INSTALLDIR/bin
    cp usr/local/wbin/rm.exe $INSTALLDIR/bin
    cp usr/local/wbin/mkdir.exe $INSTALLDIR/bin
    cp usr/local/wbin/sed.exe $INSTALLDIR/bin
    cd ../..

    MINGW32_MAKE_DIR="make-"$MINGW32_MAKE_VER
    download deps "http://downloads.sourceforge.net/mingw" "make-"$MINGW32_MAKE_VER "tar.gz" $MINGW32_MAKE_DIR

    cd deps/$MINGW32_MAKE_DIR
    cp make.exe $INSTALLDIR/bin
    cp -Rf info $INSTALLDIR/info
    cd ../..

    # true for some samples (namely minifire asm demo)
    gcc -s -Wall -O3 -o $INSTALLDIR/bin/true.exe mingw/true.c
    # visual studio support
    cp mingw/bin/vsmake.bat $INSTALLDIR/bin

    # in case any win32 native bin was linked with threads we
    # add the dll to the output install dir too
    cp /mingw/bin/pthreadGC2.dll $INSTALLDIR/bin
  fi

  # need to have psp-pkg-config hack for building some packages
  gcc -s -Wall -O3 -o $INSTALLDIR/bin/psp-pkg-config mingw/psp-pkg-config.c
}

function installPSPLinkUSB {
  svnGet psp "svn://svn.ps2dev.org/psp/trunk" "psplinkusb"
  cd psp
  if [ "$OS" == "MINGW32_NT" ]; then
    cd psplinkusb
    CC=gcc CXX=g++ BUILD_WIN32=1 make -C pspsh install
    CC=gcc CXX=g++ BUILD_WIN32=1 make -C tools/remotejoy/pcsdl install
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

function installMan {

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
}

function installInfo {
  cp mingw/bin/info.bat $INSTALLDIR/bin
  cp mingw/bin/ginfo.exe $INSTALLDIR/bin
}

function patchCMD {
  # make sure the line endings are correct (UNIX style)
  awk '{ sub("\r$", ""); print }' $INSTALLDIR/psp/sdk/lib/build.mak > $INSTALLDIR/psp/sdk/lib/build.mak.unix
  mv -f $INSTALLDIR/psp/sdk/lib/build.mak.unix $INSTALLDIR/psp/sdk/lib/build.mak

  awk '{ sub("\r$", ""); print }' $INSTALLDIR/psp/sdk/lib/build_prx.mak > $INSTALLDIR/psp/sdk/lib/build_prx.mak.unix
  mv -f $INSTALLDIR/psp/sdk/lib/build_prx.mak.unix $INSTALLDIR/psp/sdk/lib/build_prx.mak

  patch -p1 -d $INSTALLDIR/psp/sdk -i $(pwd)/mingw/patches/pspsdk-CMD.patch
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
  else
    # generate doxygen docs
    cd psp/build/pspsdk
    make doxygen-doc
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
  buildAndInstallDevPak $BASE 023 ode $DEVPAK_TARGET
  #buildAndInstallDevPak $BASE 024 TinyGL $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 025 libpthreadlite $DEVPAK_TARGET
  buildAndInstallDevPak $BASE 026 cal3D $DEVPAK_TARGET
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
validateSDK
buildGDB
#---------------------------------------------------------------------------------
# PSPLink
#---------------------------------------------------------------------------------
installPSPLinkUSB
#---------------------------------------------------------------------------------
# Extra binaries such as psp-pkg-config hack, true, etc...
#---------------------------------------------------------------------------------
installExtraBinaries
#---------------------------------------------------------------------------------
# Man and Info so windows users can read all documentation
#---------------------------------------------------------------------------------
if [ "$OS" == "MINGW32_NT" ]; then
  installMan
  installInfo
  #---------------------------------------------------------------------------------
  # patch SDK to run without msys
  #---------------------------------------------------------------------------------
  patchCMD
fi
#---------------------------------------------------------------------------------
# prepare distro
#---------------------------------------------------------------------------------
prepareDistro
#---------------------------------------------------------------------------------
# Build base devpaks
#---------------------------------------------------------------------------------
buildBaseDevpaks

echo
echo "Run the NSIS script to build the Installer"
