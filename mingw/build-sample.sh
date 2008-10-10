#!/bin/sh
while [ $# -gt 0 ]; do
	cd `dirname $1` || { echo "Error entering SDK sample dir "$1; exit 1; }
	make || { echo "Error compiling the SDK sample "$1; exit 1; }
	make clean || { echo "Error cleaning the SDK sample "$1; exit 1; }
	shift;
done
