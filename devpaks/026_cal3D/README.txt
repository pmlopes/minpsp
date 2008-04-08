cal3D build process:

cal3D is more tricky to build than the previous devpak's. Cal3D requires beter
autotools. You need to download and install:

autoconf-2.61.tar.bz2

tar -jxvf autoconf-2.61.tar.bz2
cd autoconf-2.61
./configure --perfix=/usr/local
make
make install


automake-1.10.tar.bz2

tar -jxvf automake-1.10.tar.bz2
cd automake-1.10
./configure --perfix=/usr/local
make
make install


libtool-1.5.22.tar.gz

tar -zxvf libtool-1.5.22.tar.gz
cd libtool-1.5.22
./configure --perfix=/usr/local
make
make install

now run the devpak script. The problem here is that your script is not allowed
to touch any file inside the cal3D folder or it won't work.

To build manually execute:

cd cal3D
LDFLAGS="-L$(psp-config --psp-prefix)/lib -L$(psp-config --pspsdk-path)/lib" LIBS="-lc -lstdc++ -lpsplibc -lpspuser" ./configure --host=psp --disable-shared --prefix=$(pwd)/../target/psp
make
make install


To revert back to the original autotools, rename the base /usr/local folder.
