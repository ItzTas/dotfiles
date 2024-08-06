#!/bin/sh

if [ -n "$(yadm status --porcelain)" ]; then
	brewBundle
	yadm commit -a -m "updated"
	yadm push origin master
fi
