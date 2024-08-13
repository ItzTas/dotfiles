#!/bin/sh

rm "$HOME"/.snaplist
snap list >"$HOME"/.snaplist
rm "$HOME"/.aptlist
apt list --installed >"$HOME"/.aptlist
rm "$HOME"/.Brewfile
brew bundle dump --describe --file "$HOME"/.Brewfile
yadm commit -a -m "updated"
yadm push origin master
