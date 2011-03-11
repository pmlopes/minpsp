#!/bin/sh
set -e

if [ ! "`whoami`" = "root" ]; then
  echo "This script must be run as root or with fakeroot!"
  exit
fi


VERSION=`grep PSPSDK_VERSION= toolchain.sh|cut -d= -f2`
MACHINE=$(uname -m)

if [ "$MACHINE" = "i386" ]; then
  ARCH=i386
fi

if [ "$MACHINE" = "i686" ]; then
  ARCH=i386
fi

if [ "$MACHINE" = "x86_64" ]; then
  ARCH=amd64
fi

rm -Rf minpspw-$VERSION || true
mkdir minpspw-$VERSION
chown root:root minpspw-$VERSION

cd minpspw-$VERSION

# create basic debian-binary
echo 2.0 > debian-binary

# create the data package
mkdir -p opt
cp -Rf $(pwd)/../../pspsdk opt
chown -R root:root ./opt
tar -c --lzma -f data.tar.lzma ./opt

# create control file
cat >> control <<EOF
Package: minpspw-pspsdk
Version: $VERSION
Maintainer: Paulo Lopes <pmlopes@gmail.com>
Provides: pspsdk
Conflicts: pspsdk
Replaces: pspsdk
Installed-Size: `du -ks opt|cut -f 1`
Priority: optional
Architecture: $ARCH
Section: devel
Homepage: http://www.jetdrone.com/
Description: PSP Homebrew Development Kit $VERSION
 The MinPSPW is a development environment for building applications,
 games, and components targetting the Playstation Portable.
EOF

cat >> preinst <<EOF
#!/bin/sh
set -e
. /usr/share/debconf/confmodule
exit 0
EOF
chmod a+x preinst

cat >> postrm <<EOF
#!/bin/sh
set -e
. /usr/share/debconf/confmodule
exit 0
EOF
chmod a+x postrm

GZIP=--best tar czf control.tar.gz control preinst postrm

# create deb
ar -r ../minpspw_$VERSION-1ubuntu0_$ARCH.deb debian-binary control.tar.gz data.tar.lzma
# for convenience save the tar
cp data.tar.lzma ../minpspw_$VERSION-$ARCH.tar.lzma
cd ..
# convert to rpm
alien -r -k minpspw_$VERSION-1ubuntu0_$ARCH.deb
rm -Rf minpspw-$VERSION

