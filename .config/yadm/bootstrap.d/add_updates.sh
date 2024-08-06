#!/bin/sh

if [ -n "$(yadm status --porcelain)" ]; then
	brew bundle dump --describe --file "$HOME"/.Brewfile
	brewBundle
	yadm commit -a -m "updated"
	yadm push origin master
fi
