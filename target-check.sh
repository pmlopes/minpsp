#!/bin/bash

# tell me your OS name
echo "OS id -------------------"
uname -s
uname -a

# tell me your compiler
echo "gcc -------------------"
which gcc && gcc --version
echo "g++ -------------------"
which g++ && g++ --version
echo "ld -------------------"
which ld && ld --version
echo "as -------------------"
which as && as --version

# tell me your tools
echo "svn -------------------"
which svn && svn --version
echo "wget -------------------"
which wget && wget --version
echo "make -------------------"
which make && make --version
echo "awk -------------------"
which awk && awk --version
echo "makeinfo -------------------"
which makeinfo && makeinfo --version
echo "python -------------------"
which python && python --version
echo "flex -------------------"
which flex && flex --version
echo "bison -------------------"
which bison && bison --version
echo "sdl-config -------------------"
which sdl-config && sdl-config --version
echo "doxygen -------------------"
which doxygen && doxygen --version

# tell me your software
echo "zlib.h -------------------"
find / -name "zlib.h"
echo "gmp.h -------------------"
find / -name "gmp.h"
echo "mpfr.h -------------------"
find / -name "mpfr.h"
echo "readline.h -------------------"
find / -name "readline.h"
echo "iconv.h -------------------"
find / -name "iconv.h"
echo "pthread.h -------------------"
find / -name "pthread.h"
echo "SDL.h -------------------"
find / -name "SDL.h"
echo "usb.h -------------------"
find / -name "usb.h"
echo "libusb.h -------------------"
find / -name "libusb.h"
