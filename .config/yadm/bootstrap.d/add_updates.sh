#!/bin/sh

rm "$HOME"/.golist
rm "$HOME"/.snaplist
rm "$HOME"/.aptlist
rm "$HOME"/.Brewfile

ls -1 "$HOME"/go/bin >"$HOME"/.golist
snap list >"$HOME"/.snaplist
apt list --installed >"$HOME"/.aptlist
brew bundle dump --describe --file "$HOME"/.Brewfile

yadm commit -a -m "updated"
yadm push origin master
