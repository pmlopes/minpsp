function installGMP {
  if [ ! -f $1/deps/local/include/gmp.h ]
  then
    download deps "http://ftp.gnu.org/gnu/gmp" "gmp-"$GMP_VER "tar.bz2"
    MACHINE=$(uname -m)
    if [ "$MACHINE" = "i386" ]; then
      GMP_BUILD_TARGET="--build=i386-unknown-linux-gnu"
    fi
    if [ "$MACHINE" = "i686" ]; then
      GMP_BUILD_TARGET="--build=i686-unknown-linux-gnu"
    fi
    cd deps/"gmp-"$GMP_VER
    ./configure $EXTRA_BUILD_CFG $GMP_BUILD_TARGET \
      --disable-shared \
      --enable-static \
      --prefix=$1/deps/local --enable-cxx
    $MAKE_CMD
    $MAKE_CMD check
    $MAKE_CMD install
    cd ../..
  fi
}

function installMPFR {
  if [ ! -f $1/deps/local/include/mpfr.h ]
  then
    download deps "http://ftp.gnu.org/gnu/mpfr" "mpfr-"$MPFR_VER "tar.bz2"
    MACHINE=$(uname -m)
    if [ "$MACHINE" = "i386" ]; then
      MPFR_BUILD_TARGET="--build=i386-unknown-linux-gnu"
    fi
    if [ "$MACHINE" = "i686" ]; then
      MPFR_BUILD_TARGET="--build=i686-unknown-linux-gnu"
    fi
    cd deps/"mpfr-"$MPFR_VER
    ./configure $EXTRA_BUILD_CFG $MPFR_BUILD_TARGET \
      --disable-shared \
      --enable-static \
      --prefix=$1/deps/local \
      --with-gmp-include=$GMP_INCLUDE \
      --with-gmp-lib=$GMP_LIB
    $MAKE_CMD
    $MAKE_CMD check
    $MAKE_CMD install
    cd ../..
  fi
}

# GCC specific
mkdir -p $1/deps/local
installGMP $1
installMPFR $1

