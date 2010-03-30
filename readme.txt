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
0.10 Still to decide....


===============================================================================
 Changelog
===============================================================================
0.9.6
* updated the fpulib trig functions can use the FPU processor but
  we either use vfpu or software impl using libm. This can help to
  make a bit faster code if we do not need vectors.
* Updated newlib to 1.18
 - wide-char enhancements
 - long double math routines added for platforms where LDBL == DBL
 - long long math routines added
 - math cleanup
 - major locale charset overhaul including added charsets
 - various cleanups
 - various bug fixes
* Updated the dev environment to build under Windows Vista
* Updated binutils to 2.18 (for better integration with gcc 4.3.x)
* removed the patch that defines long as 64bit back to 32bit. This can
  lead to faster code but breaks old compiled libraries
* Disabled CDT-5.0.x bug fix
* gcov builds properly but not fully tested if works as expected
* added fixes from Luqman Aden in TinyXML

0.9.5
* Start to port the project also for OpenSolaris 2009.06 (vanilla).
* Added Visual Studio Project Files from Lukas Przytula
* 38 Devpaks as default instead of the base 20

0.9.4
* Start to port the project also for Ubuntu (vanilla).

0.9.3
* Patch the GCC for Windows On Eclipse CDT 5.0.2 bug (to be removed in the next
  major release).

0.9.2
* Newlib 1.17.0
  * new C99 wide-char function additions
  * movement of regex functions from sys/linux directory into
    shared libc/posix directory
  * string function optimizations
  * redesign of formatted I/O to reduce dependencies when using
    sprintf/sscanf family of functions
  * numerous warning cleanups
  * various bug fixes
* Patched SDK for missing functions (only declared on the ASM side)
* GDB works with the Slim (wasn't reading the correct memory address if the
  variables where above 0x0A000000
* Added threading support to GCC, which will improve Objective-C and enable
  exception handling on C++

0.8.11
* GMP updated to 4.2.4
* GCC updated to 4.3.3
* SDK updated to latest SVN

0.8.10
* Update to Newlib 1.16
* Pack the libraries into the Installer
  - zlib
  - bzip2
  - freetype
  - jpeg
  - libbulletml
  - libmad
  - libmikmod
  - libogg
  - libpng
  - libpspvram
  - libTremor
  - libvorbis
  - lua
  - pspgl
  - pspirkeyb
  - sqlite
  - SDL
  - SDL_gfx
  - SDL_image
  - SDL_mixer
  - SDL_ttf
  - smpeg
  - zziplib
 * Fix the Objective-C sample since it didn't show anything.

0.8.9
* Added Objective-C++ support to the toochain.
* Updated SDK docs to build without errors
* dot fixed now images in the docs are readable
* Shrunk the installer

0.8.8
* Added Objective-C support to the toochain. And a sample.

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

Maintaining a working native toolchain is hard, so I have decided to go with
the old stable builds instead of bleeding edge test releases. To start
download the mingw installer. At the time of writting of this mini howto it is
version 5.1.6 and install the current mingw into C:\msys\mingw. The
installation should consist of C and C++ compiler, do not include the make
tool. You can install other compilers if you want but they are not required for
building the cross compiler.

Download and unzip over c:\msys\mingw.

Optionally install GDB
http://downloads.sourceforge.net/mingw/gdb-7.0-2-mingw32-bin.tar.gz

2nd Download and install MSYS Developer Toolkit executable:
http://downloads.sourceforge.net/mingw/msysDTK-1.0.1.exe
Install to c:\msys.

3rd Download latest MSYS and install it:
http://prdownloads.sourceforge.net/mingw/MSYS-1.0.11.exe
Chose c:\msys as installation directory. Leave all other options unchanged.
During the postinstall script, please carefully answer all questions. 
Important: Do not skip questions with enter.

Note: Users of 64-bit Windows variants have to change the startmenu shortcut.
Change it to c:\WINDOWS\SysWOW64\cmd.exe /C c:\dev\msys\msys.bat (adjust path
to Windows directory as needed)

At this moment you have a working bash shell with the basic tools, however
to make it more convenient we need some extra libs and tools.

4th Download wget:
http://prdownloads.sourceforge.net/gnuwin32/wget-1.11.4-1-bin.zip
http://prdownloads.sourceforge.net/gnuwin32/wget-1.11.4-1-dep.zip
Unzip to C:\msys\local

5th Download the following files to your local home, open the MSys shell and
execute:
wget http://downloads.sourceforge.net/mingw/m4-1.4.13-1-msys-1.0.11-bin.tar.lzma
wget ftp://ftp.gnu.org/gnu/libtool/libtool-2.2.6a.tar.gz 
wget ftp://ftp.gnu.org/gnu/autoconf/autoconf-2.64.tar.bz2
wget ftp://ftp.gnu.org/gnu/automake/automake-1.10.2.tar.bz2

6th install the download software:
cd /
m4-1.4.13-1-msys-1.0.11-bin.tar.lzma

cd ~
tar -xvzf libtool-2.2.6a.tar.gz
cd libtool-2.2.6
./configure --prefix=/usr
make
make install

cd ~
tar -xvjf autoconf-2.64.tar.bz2
cd autoconf-2.64
./configure --prefix=/usr
make
make install

cd ~
tar -xvjf automake-1.10.2.tar.bz2
cd automake-1.10.2
./configure --prefix=/usr
make
make install

7th Install other packages we need (into C:\msys\local)
  - doxygen 1.5.7.1
    http://ftp.stack.nl/pub/users/dimitri/doxygen-1.5.7.1.windows.bin.zip
  - The following are in the wports folder
    * pod2man
    * dot 1.16
  - svn 1.6.5
    http://subversion.tigris.org

8th Install Python 2.5.4 (later may work but not tested)
  http://python.org/ftp/python/2.5.4/python-2.5.4.msi
  - Python 2.5.4 (Use the windows installer) Then add to the PATH
  - Add it to the MSys PATH by adding the line:
     SET PATH=%PATH%;C:\Python25
    In the beginning of the MSYS.BAT file

9th Some dev packs need bison since I've to patch some yy files,
get them from the mingw msys project:
  -flex-2.5.35-1-msys-1.0.11-bin.tar.lzma
    * Extract "over" the MSYS installation.
  - bison-2.4.1-1-msys-1.0.11-bin.tar.lzma
    * Extract "over" the MSYS installation.
  - libregex-0.12-1-msys-1.0.11-dll-0.tar.lzma
    * Extract "over" the MSYS installation.
	* Then rename to msys-regex-1.dll

To build run the toolchain script:

./toolchain.sh

===============================================================================
 How to build it myself (Ubuntu)?
===============================================================================

## Install the required packages.
 sudo apt-get install build-essential autoconf automake bison flex \
  libncurses5-dev libreadline-dev libusb-dev texinfo libgmp3-dev libmpfr-dev \
  subversion doxygen graphviz libtool unrar nsis mingw32

 ## Build and install the toolchain + sdk.
 sudo ./toolchain.sh


===============================================================================
 How to build it myself (OpenSolaris)?
===============================================================================

Install required packages:
pfexec pkg install gcc-dev-4 gcc-432 SUNWbison SUNWaconf SUNWgnu-automake-110 \
    SUNWlibtool
You also need unrar from rarlabs for solaris to build OSlib and readline for
the pspsh, usbhostfs_pc and remotejoy

I've uploaded a working readline lib to jucr.opensolaris.org so if I get
enough votes it will become available on the contrib repository.

===============================================================================
 Utils commands
===============================================================================

awk '{ sub("\r$", ""); print }' dosfile.txt > unixfile.txt
awk 'sub("$", "\r")' unixfile.txt > dosfile.txt
