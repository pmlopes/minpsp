#!/bin/sh

PS2DEVSVN_URL="svn://svn.pspdev.org/psp/trunk"
PS2DEVSVN_MIRROR="http://psp.jim.sh/svn/psp/trunk"

PSPWARESVN_URL="svn://svn.pspdev.org/pspware/trunk"
PSPWARESVN_MIRROR="http://psp.jim.sh/svn/pspware/trunk"

#arg1 devpak
#arg2 svn url
#arg3 svn module
function svnGet() {
	if [ ! -d $1 ]
	then
		svn checkout $2 $3 || { echo "ERROR GETTING "$1; exit 1; }
		if [ ! -f $1.patch ]
		then
			patch -p0 -d $1 -i ../$1.patch || { echo "Error patching "$1; exit; }
		fi
	else
		svn update $1
	fi
}

# Gets the sources from the PS2DEV SVN reppo, on failure tries to fallback to JimParis mirror
#arg1 devpak
function svnGetPS2DEV() {
	if [ ! -d $1 ]
	then
		svn checkout $2 $3 $PS2DEVSVN_URL/$1 || svn checkout $PS2DEVSVN_MIRROR/$1 || { echo "ERROR GETTING "$1; exit 1; }
		if [ ! -f $1.patch ]
		then
			patch -p0 -d $1 -i ../$1.patch || { echo "Error patching "$1; exit; }
		fi
	else
		svn update $2 $3 $1
	fi
}

# Gets the sources from the PS2DEV pspware SVN reppo, on failure tries to fallback to JimParis mirror
#arg1 devpak
function svnGetPSPWARE() {
	if [ ! -d $1 ]
	then
		svn checkout $PSPWARESVN_URL/$1 || svn checkout $PSPWARESVN_MIRROR/$1 || { echo "ERROR GETTING "$1; exit 1; }
	else
		svn update $1
	fi
}

# arg1 url
# arg2 file
function downloadHTTP {
	if [ ! -f $2 ]
	then
		wget -c $1/$2 || { echo "Failed to download "$2; exit 1; }
	fi
}

#arg1 dep
#arg2 version
#arg3 file.bin
function addDep() {
	echo "	dep=\$(grep $1-$2 \$SDKPATH/psp/sdk/devpaks)"			>> $3
	echo "	if [ ! \"\$dep\" == \"\" ]; then"						>> $3
	echo "		echo \"\""											>> $3
	echo "		echo \"ERROR: Please install $1 ($2) first.\""		>> $3
	echo "		exit 1"												>> $3
	echo "	fi"														>> $3
}

#arg1 libname
#arg1 version
function makeInstaller() {
	NIXINSTALLER=$1-$2-install.bin
	echo "#!/bin/sh"																			> $NIXINSTALLER
	echo "LINES=@@_LINES@@"																		>> $NIXINSTALLER
	echo "trap 'rm -f /tmp/$1-$2.tar.bz2; exit 1' HUP INT QUIT TERM" 							>> $NIXINSTALLER
	echo "SDKPATH=\$(psp-config --pspdev-path)"													>> $NIXINSTALLER
	echo "touch \$SDKPATH/psp/sdk/devpaks"														>> $NIXINSTALLER
	echo "if [ \"\$SDKPATH\" == \"\" ]; then"													>> $NIXINSTALLER
	echo "	echo \"ERROR: Please make sure you have a valid pspsdk installed on your path.\""	>> $NIXINSTALLER
	echo "	exit 1"																				>> $NIXINSTALLER
	echo "else"																					>> $NIXINSTALLER

	# check for duplicate
	echo "	dep=\$(grep $1-$2 \$SDKPATH/psp/sdk/devpaks)"			>> $NIXINSTALLER
	echo "	if [ ! \"\$dep\" == \"\" ]; then"						>> $NIXINSTALLER
	echo "		echo \"\""											>> $NIXINSTALLER
	echo "		echo \"WARN: $1 ($2) is already installed!\""		>> $NIXINSTALLER
	echo "		exit 0"												>> $NIXINSTALLER
	echo "	fi"														>> $NIXINSTALLER
	
	if [ ! "$3" == "" ]
	then
		addDep $3 $4 $NIXINSTALLER
	fi

	if [ ! "$5" == "" ]
	then
		addDep $5 $6 $NIXINSTALLER
	fi
	
	if [ ! "$7" == "" ]
	then
		addDep $7 $8 $NIXINSTALLER
	fi

	if [ ! "$9" == "" ]
	then
		addDep $9 $10 $NIXINSTALLER
	fi
	
	echo "	cat <<EOF"																			>> $NIXINSTALLER
	cat license.txt																				>> $NIXINSTALLER
	echo "EOF"																					>> $NIXINSTALLER
	echo "	echo \"\""																			>> $NIXINSTALLER
	echo "	echo -n \"You must agree with the license before installing this DEVPAK [y/N] \""	>> $NIXINSTALLER
	echo "	read agree in"																		>> $NIXINSTALLER
	echo "	if [ \"\$agree\" == \"y\" ]; then"													>> $NIXINSTALLER
	# prepare installation
	echo "		tail -n +\$LINES \"\$0\" > /tmp/$1-$2.tar.bz2"									>> $NIXINSTALLER
	# install
	echo "		cd \$SDKPATH"																	>> $NIXINSTALLER
	echo "		tar xjfv /tmp/$1-$2.tar.bz2"													>> $NIXINSTALLER
	echo "		rm /tmp/$1-$2.tar.bz2"															>> $NIXINSTALLER
	# register devpak
	echo "		echo $1-$2 >> \$SDKPATH/psp/sdk/devpaks"										>> $NIXINSTALLER
	# done
	echo "		echo \"\""																		>> $NIXINSTALLER
	echo "		echo \"$1-$2 has been installed on your SDK.\""									>> $NIXINSTALLER
	echo "	else"																				>> $NIXINSTALLER
	echo "		echo \"ERROR: You opt not to install this DEVPAK.\""							>> $NIXINSTALLER
	echo "	fi"																					>> $NIXINSTALLER
	echo "fi"																					>> $NIXINSTALLER
	echo "echo \"Please visit minpspw.sourceforge.net for other DEVPAKs.\""						>> $NIXINSTALLER
	echo "exit 0"																				>> $NIXINSTALLER
	echo ""																						>> $NIXINSTALLER
	LINES=`cat $NIXINSTALLER| wc -l`
	LINES=$((LINES+1))
	mv $NIXINSTALLER $NIXINSTALLER.sh
	cat $NIXINSTALLER.sh | sed s/@@_LINES@@/$LINES/ > $NIXINSTALLER
	# rm $NIXINSTALLER.sh
	cd target
	tar cjvf ../$1-$2.tar.bz2 *
	cd ..
	cat $1-$2.tar.bz2 >> $NIXINSTALLER
}
