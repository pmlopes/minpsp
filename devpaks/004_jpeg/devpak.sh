#!/bin/sh

LIBNAME=jpeg
VERSION=6.2

if [ ! -d $LIBNAME ]
then
	svn checkout http://psp.jim.sh/svn/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

cd $LIBNAME
if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	mkdir -p ../target/psp/include ../target/psp/lib ../target/doc
	cp jconfig.h jpeglib.h jmorecfg.h jerror.h ../target/psp/include
	cp libjpeg.a  ../target/psp/lib
	cp libjpeg.doc  ../target/doc
	
	touch $LIBNAME-devpaktarget
fi

cd ..
if [ ! -f $LIBNAME-nixdevpaktarget ]
then
	NIXINSTALLER=$LIBNAME-$VERSION-install.sh
	echo "#!/bin/sh"			> $NIXINSTALLER
	echo "DEVPAK=$LIBNAME"		>> $NIXINSTALLER
	echo "VERSION=$VERSION"		>> $NIXINSTALLER
	echo "cat <<EOF"			>> $NIXINSTALLER
	cat license.txt				>> $NIXINSTALLER
	echo "EOF"					>> $NIXINSTALLER
	echo "echo \"\""			>> $NIXINSTALLER
	echo "printf \"You must agree with the license before installing this DEVPAK [y/N] \""			>> $NIXINSTALLER
	echo "read agree in"																			>> $NIXINSTALLER
	echo "if [ \"\$agree\" == \"y\" ]; then"														>> $NIXINSTALLER
	echo "	sdkpath=\`psp-config --pspdev-path\`"													>> $NIXINSTALLER
	echo "	if [ \"\$sdkpath\" == \"\" ]; then"														>> $NIXINSTALLER
	echo "		echo \"ERROR: Please make sure you have a valid pspsdk installed on your path.\""	>> $NIXINSTALLER
	echo "		exit"																				>> $NIXINSTALLER
	echo "	else"																					>> $NIXINSTALLER
	echo "		# prepare installation"																>> $NIXINSTALLER
	echo "		dir=\`dirname \$0\`;"																>> $NIXINSTALLER
	echo "		if [ \"x\$dir\" = \"x.\" ];"														>> $NIXINSTALLER
	echo "		then"																				>> $NIXINSTALLER
	echo "		    dir=\`pwd\`"																	>> $NIXINSTALLER
	echo "		fi"																					>> $NIXINSTALLER
	echo "		base=\`basename \$0\`;"																>> $NIXINSTALLER
	echo "		mkdir -p \$sdkpath/tmp"																>> $NIXINSTALLER
	echo "		cd \$sdkpath"																		>> $NIXINSTALLER
	echo "		# install"																			>> $NIXINSTALLER
	echo "		uudecode \$dir/\$base -o tmp/\$DEVPAK-\$VERSION.tar.bz2"							>> $NIXINSTALLER
	echo "		tar xjfv tmp/\$DEVPAK-\$VERSION.tar.bz2"											>> $NIXINSTALLER
	echo "		rm tmp/\$DEVPAK-\$VERSION.tar.bz2"													>> $NIXINSTALLER
	echo "		# register devpak"																	>> $NIXINSTALLER
	echo "		touch psp/sdk/devpaks"																>> $NIXINSTALLER
	echo "		echo \$DEVPAK-\$VERSION >> psp/sdk/devpaks"											>> $NIXINSTALLER
	echo "		# done"																				>> $NIXINSTALLER
	echo "		echo \"\""																			>> $NIXINSTALLER
	echo "		echo \"\$DEVPAK-\$VERSION has been installed on your SDK.\""						>> $NIXINSTALLER
	echo "	fi"																						>> $NIXINSTALLER
	echo "else"																						>> $NIXINSTALLER
	echo "	echo \"ERROR: You opt not to install this DEVPAK.\""									>> $NIXINSTALLER
	echo "fi"																						>> $NIXINSTALLER
	echo "echo \"Please visit minpspw.sourceforge.net for other DEVPAKs.\""							>> $NIXINSTALLER
	echo "exit"																						>> $NIXINSTALLER
	echo ""																							>> $NIXINSTALLER
	cd target
	tar cjvf ../$LIBNAME-$VERSION.tar.bz2 *
	cd ..
	uuencode $LIBNAME-$VERSION.tar.bz2 $LIBNAME-$VERSION.tar.bz2 >> $NIXINSTALLER

	touch $LIBNAME-nixdevpaktarget
fi

echo "Run the NSIS script now!"
