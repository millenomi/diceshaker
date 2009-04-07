#!/bin/bash

set -avx

# $1 file name; $2 string to replace to.
function DSReplaceContentInFile() {
	BASENAME="`basename "$1" .svg`"
	cat "$1" | sed -E s/"$BASENAME"/"$2"/g > "$1".replaced.tmp
	mv "$1".replaced.tmp "$1"
}

DSReplaceContentInFile d2.svg "$1"2
DSReplaceContentInFile d3.svg "$1"3
DSReplaceContentInFile d4.svg "$1"4
DSReplaceContentInFile d6.svg "$1"6
DSReplaceContentInFile d8.svg "$1"8
DSReplaceContentInFile d10.svg "$1"10
DSReplaceContentInFile d12.svg "$1"12
DSReplaceContentInFile d20.svg "$1"20
DSReplaceContentInFile d100.svg "$1"100