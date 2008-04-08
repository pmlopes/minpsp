====================
 What does this do?
====================

This program will automatically build and install a compiler and other
tools used in the creation of homebrew software for the Sony Playstation
Portable handheld videogame system.


==========================
 TODO
==========================
0.8
* make sure debugging works
* reduce dependency on cygwin


==========================
 Changelog
==========================
0.7.1
* builds ASM files without errors due to bad make
* added true.exe for makefile assertions
* GDB was keept out of 0.7 by mistache

0.7
* Removed the dependency on groff, less, cp, mkdir, rm on the script,
  now they are downloaded from the internet
* Added patch for GCC to accept: -mpreferred-stack-boundary=#
* update to SVN 2377
* PS2DEV toolchain patches are downloaded from the internet, so no
  need to keep then sync with this TC
* Update usbpsplink to latest SVN
* No input required during all TC script, all configs are
  - SourceForge MIRROR url
  - SVN host for PS2DEV
  - target dir (c:/pspsdk)

0.6
* Removed the dependency for the env var PSPSDK
* Fixed psp-config
* Better vsmake.bat
* Better man.bat
* Fixed issue that some installations would end up without env vars due to
  delayed hdd writes.
* No need to hack SDK makefiles anymore
* GNU tools (cp, rm, mkdir, sed) called with the original names no need to
  append a "2"

0.5
* First good release
* Started the concept of DEVPAKs


==========================
 What's different?
==========================
 
The main difference is that this is a native cross compiler for Microsoft
Windows Operating Systems.
  
Second is that the cross compiler uses the latest release of GCC 4.1.2
instead of the initial release 4.1.0 (this means some bugs were fixed).
  
Third, you can run it directly from a Dos Command Prompt BOX or from your
favourite IDE (Eclipse and Visual Studio Express tested)
  
==========================
 Where do I go from here?
==========================

Visit the following sites to learn more:

http://www.ps2dev.org
http://forums.ps2dev.org

My MINGW specific stuff:
http://www.jetcube.eu


==================
 How to build it myself?
==================

1) Set up your environment by installing the following software:

Option A)
* Follow the Install wizard:
  MSYS-1.0.11-2004.04.30-1.exe
* Then unzip the files over your MSYS installation e.g. (C:\msys)
  MSYS-1.0.11-20071204.tar.bz2
  bash-3.1-MSYS-1.0.11-snapshot.tar.bz2
  coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2
* You also need a Compiler I recommend getting the latest 4.2.1
  and unzip over C:\msys\mingw
 - binutils-2.18.50-20080109.tar.gz
 - gcc-core-4.2.1-sjlj-2.tar.gz
 - gcc-g++-4.2.1-sjlj-2.tar.gz
 - mingw-runtime-3.14.tar.gz
 - w32api-3.11.tar.gz
* You also need some common GNU tools, install then wizard:
 - msysDTK-1.0.1.exe
* Extras you also need:
 - wget-1.9.1-mingwPORT.tar.bz2
 - svn-win32-1.4.6.zip
* Extras you might want:
 - doxygen 1.5.5
 - graphviz
 - pod2man
 - Windows Python 2.5 (for FreeType docs)
 - autoconf 2.61
 - automake 1.10
 - texinfo 4.8
  install to C:\msys\local
    
All these files (except the SVN) you can find at the MINGW sourceforge
site. http://www.sourceforge.net/projects/mingw
  
Option B)
* Download a ziped version of the installation described above from
  my website.

2) Prepare your environment:

This is a MINGW port of the PSP Toolchain, it means you don't
need a emulation layer (cygwin) and that you will be able to
run your tools from a common DOS Command Prompt.
  
The limitations are however that some of the tools in these
installers are badly outdated and some patching need to be done
to the current scripts/patches.
  
Make sure you also have subversion installed and you can call
it from the command line: e.g. svn --version
  
3) Run the toolchain script:

Open the MSYS shell and run the script, once you've built the
Toolchain successfully you don't need that shell anymore.
  
./toolchain.sh


==========================
 What's should be inside?
==========================
 
autoconf 2.61
automake 1.10
GNU make 3.79.1
gawk 3.0.4
gcc 4.2.1
g++ 4.2.1
makeinfo 4.8
sed 3.02
