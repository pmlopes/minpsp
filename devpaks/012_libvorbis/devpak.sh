#!/bin/sh

LIBNAME=libvorbis
VERSION=1.1.2

if [ ! -d $LIBNAME ]
then
	svn checkout http://psp.jim.sh/svn/psp/trunk/$LIBNAME || { echo "ERROR GETTING $LIBNAME"; exit 1; }
else
	svn update $LIBNAME
fi

AC_VERSION=$(autoconf --version | grep 2.56)
AM_VERSION=$(automake --version | grep 1.7)
UUENCODE=/usr/local_/bin/uuencode

if [ ! "$AC_VERSION" == "autoconf (GNU Autoconf) 2.56" ]; then
	if [ ! "$AM_VERSION" == "automake (GNU automake) 1.7.1" ]; then
		echo "You need to use automake 1.7"
		exit 1
	fi
	echo "You need to use autoconf 2.56"
	exit 1
fi

cd $LIBNAME
if [ ! -f $LIBNAME-configured ]
then
	LDFLAGS="-L$(psp-config --pspsdk-path)/lib -lc -lpspuser" ./autogen.sh --host psp --prefix=$(pwd)/../target/psp || { echo "Error configuring $LIBNAME"; exit 1; }
	touch $LIBNAME-configured
fi

if [ ! -f $LIBNAME-build ]
then
	make || { echo "Error building $LIBNAME"; exit 1; }
	touch $LIBNAME-build
fi

if [ ! -f $LIBNAME-devpaktarget ]
then
	make install || { echo "Error installing $LIBNAME"; exit 1; }
	mkdir -p $(pwd)/../target/doc
	mv $(pwd)/../target/psp/share/doc/libvorbis-1.1.1 $(pwd)/../target/doc
	rm -fR $(pwd)/../target/psp/share
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
	echo "		# check for dependencies"															>> $NIXINSTALLER
	echo "		dep=\`grep libogg-1.1.2 psp/sdk/devpaks | wc -l\`"									>> $NIXINSTALLER
	echo "		if [ \"\$dep\" == \"0\" ]; then"													>> $NIXINSTALLER
	echo "			echo \"\""																		>> $NIXINSTALLER
	echo "			echo \"ERROR: Please install libogg (1.1.2) first.\""							>> $NIXINSTALLER
	echo "			exit"																			>> $NIXINSTALLER
	echo "		fi"																					>> $NIXINSTALLER
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
	$UUENCODE $LIBNAME-$VERSION.tar.bz2 $LIBNAME-$VERSION.tar.bz2 >> $NIXINSTALLER

	touch $LIBNAME-nixdevpaktarget
fi

echo "Run the NSIS script now!"
