#!/bin/sh

#---------------------------------------------------------------------------------
# Install and build the pspsdk
#---------------------------------------------------------------------------------
cd pspsdk

if [ ! -f build-install-pspsdk-crtl ]
then
	./configure || { echo "ERROR RUNNING PSPSDK CONFIGURE"; exit 1; }
	$MAKE || { echo "ERROR BUILDING PSPSDK"; exit 1; }
	$MAKE install || { echo "ERROR INSTALLING PSPSDK"; exit 1; }
	touch build-install-pspsdk-crtl
fi
