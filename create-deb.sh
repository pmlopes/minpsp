#!/bin/sh
set -e

VERSION=0.9.7

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
tar czf data.tar.gz ./opt

# create control file
cat >> control <<EOF
Package: minpspw-pspsdk
Version: $VERSION
Maintainer: Paulo Lopes <pmlopes@gmail.com>
Installed-Size: `du -ks opt|cut -f 1`
Priority: optional
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

tar czf control.tar.gz control preinst postrm

# create deb
ar -r ../minpspw_$VERSION-1ubuntu0.deb debian-binary control.tar.gz data.tar.gz

cd ..

