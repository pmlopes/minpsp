#!/bin/sh
set -e

VERSION=`grep PSPSDK_VERSION= toolchain.sh|cut -d= -f2`
MACHINE=$(uname -m)
if [ "$MACHINE" == "i386" ]; then
  ARCH=i386
fi
if [ "$MACHINE" == "x86_64" ]; then
  ARCH=amd64
fi


mkdir -p  ~/rpmbuild/BUILD/minpspw-$VERSION/opt
cp -R	 ../pspsdk ~/rpmbuild/BUILD/minpspw-$VERSION/opt



# Put the pspsdk bin PATH in the PATH
mkdir -p ~/rpmbuild/BUILD/minpspw-$VERSION/etc/profile.d

cat > ~/rpmbuild/BUILD/minpspw-$VERSION/etc/profile.d/minpspw-$VERSION <<EOF
export PATH=/opt/pspsdk/bin:\$PATH
EOF

# create the source tgz file
cd ~/rpmbuild/BUILD/minpspw-$VERSION
tar -czf ~/rpmbuild/SOURCES/minpspw-$VERSION.tgz ./

# create spec file
cat > ~/rpmbuild/SPECS/minpspw.spec <<EOF
%define name minpspw

Summary:  minpspw a development environment for the psp
Name: %{name}
Version: $VERSION
Release: .fc14
License: GPL 
Group: PSP/system
BuildRoot: %{_tmppath}/%{name}-root
Packager: Serge Sterck <serge_sterck@hotmail.com>

Source1: minpspw-$VERSION.tgz

%description
The MinPSPW is a development environment for building applications,
 games, and components targetting the Playstation Portable.

%install
rm -rf \$RPM_BUILD_ROOT
mkdir -p \$RPM_BUILD_ROOT
cd \$RPM_BUILD_ROOT
tar xvf %{SOURCE1}

%clean
rm -rf \$RPM_BUILD_ROOT

%files
#include all the files
%defattr(-,root,root)

%changelog
* Sun Nov 28 2010 Serge Sterck <serge_sterck@hotmail.com>
- initial release for Fedora 14
EOF

cd ~/rpmbuild/SPECS
rpmbuild -ba minpspw.spec
