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
* Updated the Msys/MinGW environment. I had to reinstall and it was a mess. 
* Updated the scripts to a single one that seems not to crash with cyg_heap
   commit exception. (less FDs required)

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

Initial builds were made in a custom Msys/MinGW environment. Keeping this env
up to date was a terrible task since there were conflicts constantly between
updated dlls and tools.

1st Download latest MinGW version and install it:
http://downloads.sf.net/mingw/MinGW-5.1.4.exe Choose c:\msys\mingw as 
installation directory. Select "candidate" package version and check the g++
option on the packages list.

2nd Download latest MSYS and install it:
http://prdownloads.sourceforge.net/mingw/MSYS-1.0.11-2004.04.30-1.exe
Chose c:\msys as installation directory. Leave all other options unchanged.
During the postinstall script, please carefully answer all questions. 
Important: Do not skip questions with enter.

Note: Users of 64-bit Windows variants have to change the startmenu shortcut.
Change it to c:\WINDOWS\SysWOW64\cmd.exe /C c:\dev\msys\msys.bat (adjust path
to Windows directory as needed)

3rd Download and install MSYS Developer Toolkit executable:
http://downloads.sourceforge.net/mingw/msysDTK-1.0.1.exe
Install to c:\msys as well.

4th Start msys. Type in the following commands:

echo "export LDFLAGS=-L/local/lib" > ~/.profile
echo "export CPPFLAGS=-I/local/include" >> ~/.profile
exit

5th Download wget:
http://prdownloads.sourceforge.net/gnuwin32/wget-1.10.1-bin.zip
http://prdownloads.sourceforge.net/gnuwin32/wget-1.10.1-dep.zip
Unzip to C:\msys\local

6th Download the following files to your local home:
wget http://downloads.sourceforge.net/mingw/m4-1.4.7-MSYS.tar.bz2
wget ftp://ftp.gnu.org/gnu/libtool/libtool-2.2.4.tar.bz2 
wget ftp://ftp.gnu.org/gnu/autoconf/autoconf-2.62.tar.bz2
wget ftp://ftp.gnu.org/gnu/automake/automake-1.10.1.tar.bz2
wget ftp://ftp.gnu.org/gnu/libiconv/libiconv-1.11.1.tar.gz

7th install the download software:
cd /
tar -xvjf /c/dev/download/m4-1.4.7-MSYS.tar.bz2

cd ~
tar -xvjf libtool-2.2.4.tar.bz2
cd libtool-2.2.4
./configure --disable-ltdl-install
make
make install

cd ~
tar -xvjf autoconf-2.62.tar.bz2
cd autoconf-2.62
./configure
make
make install

cd ~
tar -xvjf automake-1.10.1.tar.bz2
cd automake-1.10.1
./configure
make
make install

cd ~
tar -xvzf libiconv-1.11.1.tar.gz
cd libiconv-1.11.1
./configure --disable-shared --enable-static
make
make install

8th Install other packages we need
  - doxygen 1.5.6
  - pod2man
  - graphviz 2.16.1
  - texinfo 4.8
  - svn

To build run the toolchain script:

./toolchain.sh
