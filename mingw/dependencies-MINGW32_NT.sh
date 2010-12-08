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
    download deps "http://ftp.gnu.org/gnu/mpfr" "mpfr-"$MPFR_VER "tar.bz2"
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

# not needed right now
#installPPL
#installCLOOGPPL
#installMPC
#installLIBELF

# nice to have
installSDL
