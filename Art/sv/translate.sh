#!/bin/bash

set -avx

HERE="`dirname "$0"`"
for i in "$HERE"/*.svg; do
	DIE_NAME="`basename "$i" .svg`"
	NEW_DIE_NAME="`echo "$DIE_NAME"|sed s/d/T/g`"
	cat "$i" | sed s/"$DIE_NAME"/"$NEW_DIE_NAME"/g > "$i".new.svg
	mv "$i".new.svg "$i"
done