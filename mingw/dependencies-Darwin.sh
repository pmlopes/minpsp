function installGMP {
  if [ ! -f $1/deps/local/include/gmp.h ]
  then
    download deps "http://ftp.gnu.org/gnu/gmp" "gmp-"$GMP_VER "tar.bz2"
    MACHINE=$(uname -m)
    cd deps/"gmp-"$GMP_VER
    ./configure $GMP_BUILD_TARGET \
      --disable-shared \
      --enable-static \
      --prefix=$1/deps/local --enable-cxx
    make -s
    make -s install
    cd ../..
  fi
}

function installMPFR {
  if [ ! -f $1/deps/local/include/mpfr.h ]
  then
    download deps "http://ftp.gnu.org/gnu/mpfr" "mpfr-"$MPFR_VER "tar.bz2"
    cd deps/"mpfr-"$MPFR_VER
    ./configure $MPFR_BUILD_TARGET \
      --disable-shared \
      --enable-static \
      --prefix=$1/deps/local \
      --with-gmp-include=$1/deps/local/include \
      --with-gmp-lib=$1/deps/local/lib
    make -s
    make -s install
    cd ../..
  fi
}

# GCC specific
mkdir -p $1/deps/local
installGMP $1
installMPFR $1
