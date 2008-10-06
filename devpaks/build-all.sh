#!/bin/sh

SDKPATH=$(psp-config --pspdev-path)
BASE=$(pwd)

#arg1 devpak folder number
#arg2 devpak
function buildAndInstallDevPak() {
	cd $1_$2 || exit 1
	./devpak.sh || exit 1
	cd $SDKPATH || exit 1
	tar xjfv $BASE/$1_$2/$2-*.tar.bz2 || exit 1
	cd $BASE || exit 1
}

buildAndInstallDevPak 001 zlib
buildAndInstallDevPak 002 bzip2
buildAndInstallDevPak 003 freetype
buildAndInstallDevPak 004 jpeg
buildAndInstallDevPak 005 libbulletml
buildAndInstallDevPak 006 libmad
buildAndInstallDevPak 007 libmikmod
buildAndInstallDevPak 008 libogg
buildAndInstallDevPak 009 libpng
buildAndInstallDevPak 010 libpspvram
buildAndInstallDevPak 011 libTremor

# need to remove /msys/local from the path only for the next lib
OLDPATH=$PATH
PATH=$(echo $PATH | sed 's/.\/usr\/local\/bin://g')
buildAndInstallDevPak 012 libvorbis
PATH=$OLDPATH

buildAndInstallDevPak 013 lua
buildAndInstallDevPak 014 pspgl
buildAndInstallDevPak 015 pspirkeyb
buildAndInstallDevPak 016 sqlite
buildAndInstallDevPak 017 SDL
buildAndInstallDevPak 017b SDL-noPSPGL
buildAndInstallDevPak 018 SDL_gfx
buildAndInstallDevPak 019 SDL_image
buildAndInstallDevPak 020 SDL_mixer
buildAndInstallDevPak 021 SDL_ttf
buildAndInstallDevPak 022 smpeg
buildAndInstallDevPak 023 ode
buildAndInstallDevPak 024 TinyGL
buildAndInstallDevPak 025 libpthreadlite
buildAndInstallDevPak 026 cal3D
buildAndInstallDevPak 027 mikmodlib
buildAndInstallDevPak 028 cpplibs
buildAndInstallDevPak 029 flac
buildAndInstallDevPak 030 giflib
buildAndInstallDevPak 031 libpspmath
buildAndInstallDevPak 032 pthreads-emb
buildAndInstallDevPak 033 tinyxml
buildAndInstallDevPak 034 oslib
buildAndInstallDevPak 035 libcurl
buildAndInstallDevPak 036 intrafont
buildAndInstallDevPak 037 libaac
buildAndInstallDevPak 038 Jello
buildAndInstallDevPak 039 zziplib
buildAndInstallDevPak 040 Mini-XML
