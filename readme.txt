Welcome to the MINPSPW (Minimalist PSP homebrew SDK for Windows).

With this SDK you are able to code your own applications for the amazing
device that is the Sony PlayStation Portable. If you finished the installation
and you are reading this document you are ready to code.

Pick the code examples from the psp/sdk/samples directory and investigate
the code. To write your own applications, just grab your favourite IDE for
C/C++ and start right away, use the makefile templates from the samples
directory and remember that the compiler is based on GNU GCC compiler set
so no Microsoft extensions are available for you.


===============================================================================
 If you got this as a collection of shell scripts
===============================================================================

This program will automatically build and install a compiler and other
tools used in the creation of homebrew software for the Sony Playstation
Portable handheld videogame system.


===============================================================================
 TODO
===============================================================================
0.9
* Patched SDK for missing functions (only declared on the ASM side)


===============================================================================
 Changelog
===============================================================================
0.8.7
* Updated SVN
* Since ps2dev started to use the patches I was hosting, legacy builds are over
* Update GCC 4.3.2
* Update GMP 4.2.3

0.8.6
* Update SDK to latest SVN 2418
* Some tweak on the SDK

0.8.5
* Updated PSPLINKUSB
* patch PSPLINKUSB to support BIG MEMORY
* Update SDK to latest SVN 2413
* Debugging works (fully tested)
* Reduced dependency on cygwin (DLL packed with UPX)

0.8.4
* Upgrade MinGW GCC to 4.3.1
* Patched newlib int == int32_t (reduces compile errors) instead of
  long == int32_t. Since PSP is a 32bit machine both are valid options but
  int make it more natural.
* updated SDK to latest SVN 
  
0.8.3
* Split installer into 2 packages with doc/without doc for size reasons
* Test the compiler by compiling all the samples in the TC script
* Vista Support
* Upgrade MinGW GCC to 4.3.0, this forces the GDB to be build with -Werror
  disabled.

0.8.2
* GCC 4.3.0 & GDB 6.8 are the base versions from now on.

0.7.4
* Sync to SVN 2387
 - Added sceUtilityLoadModule() and sceUtilityUnloadModule().
 - Added the remaining stubs and prototypes for sceAudio*, found from various
   sources including cooleyes, lteixeira, Saotome, cswindle, Fanjita,
   SilverSpring.

0.7.3
* Sync to SVN 2385
* HTTP Browser support added to SDK

0.8.1
* GCC 4.3.0
* GDB 6.8

0.7.2
* Sync to PS2DEV SVN
* Reduce differences between MinPSPW patches and Official patches

0.7.1
* builds ASM files without errors due to bad make
* added true.exe for makefile assertions
* GDB was kept out of 0.7 by mistake

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


===============================================================================
 What's different?
===============================================================================
 
The main difference is that this is a native cross compiler for Microsoft
Windows Operating Systems.
  
Second, you can run it directly from a DOS Command Prompt BOX or from your
favorite IDE (Eclipse and Visual Studio Express tested)
  
===============================================================================
 Where do I go from here?
===============================================================================

Visit the following sites to learn more:

http://www.ps2dev.org
http://forums.ps2dev.org

My MINGW specific stuff:
http://www.jetcube.eu


===============================================================================
 How to build it myself?
===============================================================================

1) Set up your environment by installing the following software:

* Follow the Install wizard:
 - MSYS-1.0.11-2004.04.30-1.exe
* You also need some common GNU tools, install then wizard:
 - msysDTK-1.0.1.exe
* Then unzip the files over your MSYS installation e.g. (C:\msys)
 - msysCORE-1.0.11-2007.01.19-1.tar.bz2
 - MSYS-1.0.11-20071204.tar.bz2
 - bash-3.1-MSYS-1.0.11-1.tar.bz2
 - coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2
* You also need a Compiler I recommend getting the 4.3 unzip over C:\msys\mingw
 - binutils-2.18.50-20080109-2.tar.gz
 - gcc-part-core-4.3.0-20080502-2-mingw32-alpha-bin.tar.gz
 - gcc-part-c++-4.3.0-20080502-2-mingw32-alpha-bin.tar.gz
 - mingw-runtime-3.14.tar.gz
 - w32api-3.11.tar.gz
* Extras you also need (unzip over C:\msys\bin):
 - wget-1.9.1-mingwPORT.tar.bz2
 - svn-win32-1.4.6.zip
 - doxygen 1.5.5
 - pod2man
 - texinfo 4.8 bin
 - texinfo 4.8 dep
 - flex 2.5.33
 - regex 0.12
* Extras you also need (unzip over C:\msys\local):
 - graphviz
* Extras you also need to build from sources (unzip over C:\msys\local):
 - autoconf 2.61
 - automake 1.10
 - libtool 1.5.22
 - libiconv 1.9.2
* Extras you might want:
 - Windows Python 2.5 (for FreeType docs)
    
All these files (except the SVN) you can find at the MINGW sourceforge
site. http://www.sourceforge.net/projects/mingw
  
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
