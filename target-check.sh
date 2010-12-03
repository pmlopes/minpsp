#!/bin/bash

# tell me your OS name
uname -s
uname -a
echo "-------------------"

# tell me your compiler
which gcc && gcc --version
echo "-------------------"
which g++ && g++ --version
echo "-------------------"
which ld && ld --version
echo "-------------------"
which as && as --version
echo "-------------------"

# tell me your tools
which svn && svn --version
echo "-------------------"
which wget && wget --version
echo "-------------------"
which make && make --version
echo "-------------------"
which awk && awk --version
echo "-------------------"
which makeinfo && makeinfo --version
echo "-------------------"
which python && python --version
echo "-------------------"
which flex && flex --version
echo "-------------------"
which bison && bison --version
echo "-------------------"

# tell me your software
find / -name "zlib.h"
echo "-------------------"
find / -name "gmp.h"
echo "-------------------"
find / -name "mpfr.h"
echo "-------------------"
find / -name "readline.h"
echo "-------------------"
find / -name "iconv.h"
echo "-------------------"
find / -name "pthread.h"
echo "-------------------"
find / -name "SDL.h"
echo "-------------------"