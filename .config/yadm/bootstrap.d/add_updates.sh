#!/bin/sh

if [ -n "$(yadm status --porcelain)" ]; then
	yadm commit -a -m "updated"
fi
