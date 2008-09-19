#!/bin/sh
while [ $# -gt 0 ]; do
	cd `dirname $1`
	make || { echo "Error compiling the SDK sample "$1; exit 1; }
	make clean
	shift;
done
