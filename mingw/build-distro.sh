#!/bin/sh

#---------------------------------------------------------------------------------
# create a distro
#---------------------------------------------------------------------------------
[ ! -z "$INSTALLERDIR" ] && mkdir -p $INSTALLERDIR && touch $INSTALLERDIR/nonexistantfile && rm $INSTALLERDIR/nonexistantfile || exit 1;

cd $INSTALLERDIR
mkdir base
mkdir -p vstudio/bin
mkdir -p psplink/bin
mkdir -p documentation/pspdoc
mkdir -p documentation/man_info
mkdir -p samples/psp/sdk
# clone the base installation
cp -fR $INSTALLDIR/* $INSTALLERDIR/base
# copy visual studio tools
mv $INSTALLERDIR/base/bin/sed.exe $INSTALLERDIR/vstudio/bin/sed.exe
mv $INSTALLERDIR/base/bin/vsmake.bat $INSTALLERDIR/vstudio/bin/vsmake.bat
# move binary psplinkusb
mv $INSTALLERDIR/base/bin/pspsh.exe $INSTALLERDIR/psplink/bin/
mv $INSTALLERDIR/base/bin/usbhostfs_pc.exe $INSTALLERDIR/psplink/bin/
mv $INSTALLERDIR/base/bin/cygncurses-8.dll $INSTALLERDIR/psplink/bin/
mv $INSTALLERDIR/base/bin/cygreadline6.dll $INSTALLERDIR/psplink/bin/
mv $INSTALLERDIR/base/bin/cygwin1.dll $INSTALLERDIR/psplink/bin/
# move psp psplink
mv $INSTALLERDIR/base/psplink $INSTALLERDIR/psplink
# move the docs
mv $INSTALLERDIR/base/man $INSTALLERDIR/documentation/man_info/man

mkdir -p $INSTALLERDIR/documentation/man_info/bin
mkdir -p $INSTALLERDIR/documentation/man_info/share

mv $INSTALLERDIR/base/share/font $INSTALLERDIR/documentation/man_info/share/font
mv $INSTALLERDIR/base/share/tmac $INSTALLERDIR/documentation/man_info/share/tmac

mv	$INSTALLERDIR/base/bin/groff.exe $INSTALLERDIR/documentation/man_info/bin/groff.exe
mv	$INSTALLERDIR/base/bin/grotty.exe $INSTALLERDIR/documentation/man_info/bin/grotty.exe
mv	$INSTALLERDIR/base/bin/less.exe $INSTALLERDIR/documentation/man_info/bin/less.exe
mv	$INSTALLERDIR/base/bin/man.bat $INSTALLERDIR/documentation/man_info/bin/man.bat
mv	$INSTALLERDIR/base/bin/pcre3.dll $INSTALLERDIR/documentation/man_info/bin/pcre3.dll
mv	$INSTALLERDIR/base/bin/troff.exe $INSTALLERDIR/documentation/man_info/bin/troff.exe
# create info stuff and add info viewer
mv $INSTALLERDIR/base/info $INSTALLERDIR/documentation/man_info/info

mv $INSTALLERDIR/base/bin/info.bat $INSTALLERDIR/documentation/man_info/bin/info.bat
mv $INSTALLERDIR/base/bin/ginfo.exe $INSTALLERDIR/documentation/man_info/bin/info.exe

# generate doxygen docs
cd $BUILDSCRIPTDIR/pspsdk
make doxygen-doc
cp -fR doc $INSTALLERDIR/documentation/pspdoc
rm $INSTALLERDIR/documentation/pspdoc/doc/pspsdk.tag
mv $INSTALLERDIR/documentation/pspdoc/doc/html $INSTALLERDIR/documentation/pspdoc/doc/pspsdk

# move samples
mv $INSTALLERDIR/base/psp/sdk/samples $INSTALLERDIR/samples/psp/sdk/samples

# copy nsis scripts to the installer folder
cp $BUILDSCRIPTDIR/installer/AddToPath.nsh $INSTALLERDIR
cp $BUILDSCRIPTDIR/installer/licenses.txt $INSTALLERDIR
sed s/@MINPSPW_VERSION@/$PSPSDK_VERSION/ < $BUILDSCRIPTDIR/installer/setup.nsi > $INSTALLERDIR/setup.nsi

echo
echo "You should now run the NSIS script to build the final installer"
