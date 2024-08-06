#!/bin/sh

if [ -n "$(yadm status --porcelain)" ]; then
	rm "$HOME"/.aptlis
	rm "$HOME"/.Brewfile
	brew bundle dump --describe --file "$HOME"/.Brewfile
	yadm commit -a -m "updated"
	yadm push origin master
fi
