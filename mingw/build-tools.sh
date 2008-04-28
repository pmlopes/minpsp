#---------------------------------------------------------------------------------
# add extra tools to the sdk
#---------------------------------------------------------------------------------
cd $BUILDSCRIPTDIR

if [ ! -f extra-binaries ]
then
	cp $UNXUTILS_DIR/usr/local/wbin/cp.exe $INSTALLDIR/bin/cp.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $UNXUTILS_DIR/usr/local/wbin/rm.exe $INSTALLDIR/bin/rm.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $UNXUTILS_DIR/usr/local/wbin/mkdir.exe $INSTALLDIR/bin/mkdir.exe || { echo "ERROR Extra Binaries"; exit 1; }
# true for some samples (namely minifire asm demo)
	gcc -Wall -O3 -o $INSTALLDIR/bin/true.exe $scriptdir/true.c
	strip -s $INSTALLDIR/bin/true.exe
#	visual studio support
	cp $UNXUTILS_DIR/usr/local/wbin/sed.exe $INSTALLDIR/bin/sed.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $scriptdir/bin/vsmake.bat $INSTALLDIR/bin/vsmake.bat || { echo "ERROR Extra Binaries"; exit 1; }
	
	cp $MINGW32_MAKE_DIR/make.exe $INSTALLDIR/bin/make.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $MINGW32_MAKE_DIR/info/*.* $INSTALLDIR/info || { echo "ERROR Extra Binaries"; exit 1; }
	
	touch extra-binaries
fi

#---------------------------------------------------------------------------------
# build psplinkusb for the debugger
#---------------------------------------------------------------------------------
cd $BUILDSCRIPTDIR

if [ ! -d psplinkusb ]
then
	svn checkout $PS2DEV_SVN/psplinkusb || { echo "ERROR GETTING PSPLINKUSB"; exit 1; }
else
	svn update psplinkusb
fi

# PC part doesn't build under mingw
#cd psplinkusb
#if [ ! -f build-psplinkusb-pc ]
#then
#  $MAKE -f Makefile.clients || { echo "ERROR building PSPLINKUSB"; exit 1; }
#  touch build-psplinkusb-pc
#fi

cd $BUILDSCRIPTDIR
if [ ! -f installed-psplinkusb-pc ]
then
#	$MAKE -f Makefile.clients install || { echo "ERROR installing PSPLINKUSB"; exit 1; }
	# pspsh + usbhostfs_pc
	cp $scriptdir/bin/pspsh.exe $INSTALLDIR/bin/pspsh.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $scriptdir/bin/usbhostfs_pc.exe $INSTALLDIR/bin/usbhostfs_pc.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $scriptdir/bin/cygncurses-8.dll $INSTALLDIR/bin/cygncurses-8.dll || { echo "ERROR Extra Binaries"; exit 1; }
	cp $scriptdir/bin/cygreadline6.dll $INSTALLDIR/bin/cygreadline6.dll || { echo "ERROR Extra Binaries"; exit 1; }
	cp $scriptdir/bin/cygwin1.dll $INSTALLDIR/bin/cygwin1.dll || { echo "ERROR Extra Binaries"; exit 1; }
	
	# copy the drivers for windows
	mkdir -p $INSTALLDIR/bin/driver
	mkdir -p $INSTALLDIR/bin/driver_x64
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver/libusb0.dll $INSTALLDIR/bin/driver/libusb0.dll || { echo "ERROR Extra Binaries"; exit 1; }
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver/libusb0.sys $INSTALLDIR/bin/driver/libusb0.sys || { echo "ERROR Extra Binaries"; exit 1; }
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver/psp.cat $INSTALLDIR/bin/driver/psp.cat || { echo "ERROR Extra Binaries"; exit 1; }
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver/psp.inf $INSTALLDIR/bin/driver/psp.inf || { echo "ERROR Extra Binaries"; exit 1; }
	# 64 bits (i've no idea if it works)
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver_x64/libusb0.dll $INSTALLDIR/bin/driver_x64/libusb0.dll || { echo "ERROR Extra Binaries"; exit 1; }
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver_x64/libusb0.sys $INSTALLDIR/bin/driver_x64/libusb0.sys || { echo "ERROR Extra Binaries"; exit 1; }
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver_x64/psp.cat $INSTALLDIR/bin/driver_x64/psp.cat || { echo "ERROR Extra Binaries"; exit 1; }
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver_x64/psp.inf $INSTALLDIR/bin/driver_x64/psp.inf || { echo "ERROR Extra Binaries"; exit 1; }
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver_x64/libusb0_x64.dll $INSTALLDIR/bin/driver_x64/libusb0_x64.dll || { echo "ERROR Extra Binaries"; exit 1; }
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver_x64/libusb0_x64.sys $INSTALLDIR/bin/driver_x64/libusb0_x64.sys || { echo "ERROR Extra Binaries"; exit 1; }
	cp $BUILDSCRIPTDIR/psplinkusb/windows/driver_x64/psp_x64.cat $INSTALLDIR/bin/driver_x64/psp_x64.cat || { echo "ERROR Extra Binaries"; exit 1; }
	
	touch installed-psplinkusb-pc
fi

cd $BUILDSCRIPTDIR
cd psplinkusb

if [ ! -f build-psplinkusb-psp ]
then
	$MAKE -f Makefile.psp clean || { echo "ERROR building PSPLINKUSB (PSP)"; exit 1; }
	$MAKE -f Makefile.psp release || { echo "ERROR building PSPLINKUSB (PSP)"; exit 1; }
	
	touch build-psplinkusb-psp
fi

cd $BUILDSCRIPTDIR
cd psplinkusb
cd release

if [ ! -f install-psplinkusb-psp ]
then
	mkdir -p $INSTALLDIR/psplink/psp
	cp -fR scripts $INSTALLDIR/psplink/psp
	rm -fR $INSTALLDIR/psplink/psp/scripts/.svn
	cp -fR v1.0 $INSTALLDIR/psplink/psp
	cp -fR v1.5 $INSTALLDIR/psplink/psp
	cp -fR v1.5_nocorrupt $INSTALLDIR/psplink/psp
	cp LICENSE $INSTALLDIR/psplink
	cp psplink_manual.pdf $INSTALLDIR/psplink
	cp README $INSTALLDIR/psplink
	touch install-psplinkusb-psp
fi

cd $BUILDSCRIPTDIR
cd psplinkusb

if [ ! -f build-psplinkusb-oe ]
then
	$MAKE -f Makefile.oe clean || { echo "ERROR building PSPLINKUSB (OE)"; exit 1; }
	$MAKE -f Makefile.oe release || { echo "ERROR building PSPLINKUSB (OE)"; exit 1; }
	
	touch build-psplinkusb-oe
fi

cd $BUILDSCRIPTDIR
cd psplinkusb
cd release_oe

if [ ! -f install-psplinkusb-oe ]
then
	cp -fR psplink $INSTALLDIR/psplink/psp/oe
	touch install-psplinkusb-oe
fi

cd $BUILDSCRIPTDIR
if [ ! -f installed-man ]
then
	cp $MINGW32_GROFF_DIR/bin/groff.exe $INSTALLDIR/bin/groff.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $MINGW32_GROFF_DIR/bin/grotty.exe $INSTALLDIR/bin/grotty.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $MINGW32_GROFF_DIR/bin/troff.exe $INSTALLDIR/bin/troff.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $MINGW32_LESS_DIR/bin/less.exe $INSTALLDIR/bin/less.exe || { echo "ERROR Extra Binaries"; exit 1; }
	cp $MINGW32_LESS_DIR/bin/pcre3.dll $INSTALLDIR/bin/pcre3.dll || { echo "ERROR Extra Binaries"; exit 1; }
	cp $scriptdir/bin/man.bat $INSTALLDIR/bin/man.bat || { echo "ERROR Extra Binaries"; exit 1; }
	
	mkdir -p $INSTALLDIR/share
	
	cp -fR $MINGW32_GROFF_DIR/share/groff/$MINGW32_GROFF_VER/font $INSTALLDIR/share
	cp -fR $MINGW32_GROFF_DIR/share/groff/$MINGW32_GROFF_VER/tmac $INSTALLDIR/share
	
	touch installed-man
fi

cd $BUILDSCRIPTDIR
if [ ! -f installed-info ]
then
	cp $scriptdir/bin/info.bat $INSTALLDIR/bin/info.bat || { echo "ERROR Extra Binaries"; exit 1; }
	cp $scriptdir/bin/ginfo.exe $INSTALLDIR/bin/ginfo.exe || { echo "ERROR Extra Binaries"; exit 1; }
	
	touch installed-info
fi
