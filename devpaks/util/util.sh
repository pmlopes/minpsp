unset CC
unset CXX
unset LD
unset AR
unset LIBS
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
unset PSPDEV

# arg1 target-build
# arg2 url
# arg3 base
# arg4 compression
# arg5 [target-dir]
# psp http://server file tar.gz [dir]
function download {
	DOWNLOAD_DIR=`echo "$2"|cut -d: -f2-|cut -b3-`
	cd $1
	if [ ! -f ../../../offline/$DOWNLOAD_DIR/$3.$4 ]; then
		mkdir -p ../../../offline/$DOWNLOAD_DIR
		wget -c -O ../../../offline/$DOWNLOAD_DIR/$3.$4 $2/$3.$4
	fi
	if [ "$5" == "" ]; then
		TARGET_DIR=$3
		CREATE_TARGET=0
		DOWNLOAD_PREFIX=../../../offline/$DOWNLOAD_DIR
	else
		TARGET_DIR=$5
		CREATE_TARGET=1
		DOWNLOAD_PREFIX=../../../../offline/$DOWNLOAD_DIR
	fi
	if [ ! -d $TARGET_DIR ]; then
		if [ $CREATE_TARGET == 1 ]; then
			mkdir $TARGET_DIR
			cd $TARGET_DIR
		fi
		if [ $4 == tar.gz ]; then
			tar -zxf $DOWNLOAD_PREFIX/$3.$4
		fi
		if [ $4 == tgz ]; then
			tar -zxf $DOWNLOAD_PREFIX/$3.$4
		fi
		if [ $4 == tar.bz2 ]; then
			tar -jxf $DOWNLOAD_PREFIX/$3.$4
		fi
		if [ $4 == zip ]; then
			unzip -q $DOWNLOAD_PREFIX/$3.$4
		fi
		if [ $4 == rar ]; then
			unrar x $DOWNLOAD_PREFIX/$3.$4
		fi
		if [ $CREATE_TARGET == 1 ]; then
			cd ..
		fi
		cd $TARGET_DIR || cd `echo "$TARGET_DIR"|cut -d_ -f1` || cd `echo "$TARGET_DIR"|cut -d- -f1`
		if [ -f ../patches/$3-PSP.patch ]; then
			patch -p1 < ../patches/$3-PSP.patch
		fi
		if [ -f ../../mingw/patches/$3-MINPSPW.patch ]; then
			patch -p1 < ../../mingw/patches/$3-MINPSPW.patch
		fi
		if [ -f ../../$3.patch ]; then
			patch -p0 < ../../$3.patch
		fi
		cd ..
	fi
	cd ..
}

# arg1 target
# arg2 svn reppo
# arg3 module
function svnGet {
	DOWNLOAD_DIR=`echo "$2"|cut -d: -f2-|cut -b3-`
	cd $1
	if [ ! -d $3 ]
	then
		if [ ! -d ../../../offline/$DOWNLOAD_DIR/$3 ]; then
			mkdir -p ../../../offline/$DOWNLOAD_DIR
			cd ../../../offline/$DOWNLOAD_DIR
			svn co $2/$3 $3
			cd -
		else
			cd ../../../offline/$DOWNLOAD_DIR/$3
			svn up || echo "*** SVN not updated!!! ***"
			cd -
		fi
		cp -Rf ../../../offline/$DOWNLOAD_DIR/$3 .
		cd $3
		# some SDK files are in DOS format, fix back to UNIX
		if [ -f src/samples/Makefile.am ]; then
			awk '{ sub("\r$", ""); print }' src/samples/Makefile.am > tmp
			mv -f tmp src/samples/Makefile.am
		fi
		if [ -f src/base/build.mak ]; then
			awk '{ sub("\r$", ""); print }' src/base/build.mak > tmp
			mv -f tmp src/base/build.mak
		fi
		# normal patching
		if [ -f ../patches/$3-PSP.patch ]; then
			patch -p1 < ../patches/$3-PSP.patch
		fi
		if [ -f ../../mingw/patches/$3-MINPSPW.patch ]; then
			patch -p1 < ../../mingw/patches/$3-MINPSPW.patch
		fi
		if [ -f ../../$3.patch ]; then
			patch -p0 < ../../$3.patch
		fi
		cd ..
	else
		cd $3
		svn up || echo "*** SVN not updated!!! ***"
		cd ..
	fi
	cd ..
}

#arg1 dep
#arg2 version
#arg3 file.bin
function addDep {
	echo "	dep=\$(grep $1-$2 \$SDKPATH/psp/sdk/devpaks)"			>> $3
	echo "	if [ \"\$dep\" == \"\" ]; then"							>> $3
	echo "		echo \"\""											>> $3
	echo "		echo \"ERROR: Please install $1 ($2) first.\""		>> $3
	echo "		exit 1"												>> $3
	echo "	fi"														>> $3
}

#arg1 libname
#arg1 version
function makeInstaller {
	NIXINSTALLER=build/$1-$2-install.bin
	echo "#!/bin/bash"																			> $NIXINSTALLER
	echo "LINES=@@_LINES@@"																		>> $NIXINSTALLER
	echo "trap 'rm -f /tmp/$1-$2-psp.tar.bz2; exit 1' HUP INT QUIT TERM" 						>> $NIXINSTALLER
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
		addDep $9 ${10} $NIXINSTALLER
	fi
	
	echo "	cat <<EOF" >> $NIXINSTALLER
	cat license.txt >> $NIXINSTALLER
	echo "EOF" >> $NIXINSTALLER
	echo "	echo \"\"" >> $NIXINSTALLER
	echo "	echo -n \"You must agree with the license before installing this DEVPAK [y/N] \"" >> $NIXINSTALLER
	echo "	read agree in" >> $NIXINSTALLER
	echo "	if [ \"\$agree\" == \"y\" ]; then" >> $NIXINSTALLER
	# prepare installation
	echo "		tail -n +\$LINES \"\$0\" > /tmp/$1-$2-psp.tar.bz2" >> $NIXINSTALLER
	# install
	echo "		cd \$SDKPATH" >> $NIXINSTALLER
	echo "		tar xjfv /tmp/$1-$2-psp.tar.bz2" >> $NIXINSTALLER
	echo "		rm /tmp/$1-$2-psp.tar.bz2" >> $NIXINSTALLER
	# post installl
	if [ ! "$POSTINSTALL" == "" ]
	then
		echo "		"$POSTINSTALL >> $NIXINSTALLER
	fi
	# register devpak
	echo "		echo $1-$2 >> \$SDKPATH/psp/sdk/devpaks" >> $NIXINSTALLER
	# done
	echo "		echo \"\"" >> $NIXINSTALLER
	echo "		echo \"$1-$2 has been installed on your SDK.\""									>> $NIXINSTALLER
	echo "	else" >> $NIXINSTALLER
	echo "		echo \"ERROR: You opt not to install this DEVPAK.\"" >> $NIXINSTALLER
	echo "	fi" >> $NIXINSTALLER
	echo "fi" >> $NIXINSTALLER
	echo "echo \"Please visit minpspw.sourceforge.net for other DEVPAKs.\"" >> $NIXINSTALLER
	echo "exit 0" >> $NIXINSTALLER
	echo ""	>> $NIXINSTALLER
	LINES=`cat $NIXINSTALLER| wc -l`
	LINES=$((LINES+1))
	mv $NIXINSTALLER $NIXINSTALLER.sh
	cat $NIXINSTALLER.sh | sed s/@@_LINES@@/$LINES/ > $NIXINSTALLER
	# rm $NIXINSTALLER.sh
	cd build/target
	tar cjvf ../$1-$2-psp.tar.bz2 *
	cd ../..
	cat build/$1-$2-psp.tar.bz2 >> $NIXINSTALLER
	chmod a+x $NIXINSTALLER

	if [ "$OS" == "MINGW32_NT" ]; then
		makensis $1.nsi || true
	fi
}

#build preparation
mkdir -p build