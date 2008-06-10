#!/bin/sh
if [ "$LEGACY" == "yes" ]; then
	INSTALLDIR="/c/pspsdk-legacy"
else
	INSTALLDIR="/c/pspsdk32"
fi

while [ $# -gt 0 ]; do
	# reset to home
	cd $INSTALLDIR
	SAMPLE=`dirname $1`
	cd $INSTALLDIR/$SAMPLE
	pwd
	make || { echo "Error compiling the SDK sample"; exit 1; }
	make clean
	shift;
done

