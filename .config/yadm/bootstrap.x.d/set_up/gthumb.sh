#!/bin/env bash

_set_defaults() {
    xdg-mime default org.gnome.gThumb.desktop image/jpeg
    xdg-mime default org.gnome.gThumb.desktop image/png
    xdg-mime default org.gnome.gThumb.desktop image/gif
    xdg-mime default org.gnome.gThumb.desktop image/webp
    xdg-mime default org.gnome.gThumb.desktop image/tiff
    xdg-mime default org.gnome.gThumb.desktop image/bmp
    xdg-mime default org.gnome.gThumb.desktop image/x-xpixmap
    xdg-mime default org.gnome.gThumb.desktop image/x-tga
    xdg-mime default org.gnome.gThumb.desktop image/x-portable-bitmap
    xdg-mime default org.gnome.gThumb.desktop image/x-portable-graymap
    xdg-mime default org.gnome.gThumb.desktop image/x-portable-pixmap
    xdg-mime default org.gnome.gThumb.desktop image/x-xbitmap
    xdg-mime default org.gnome.gThumb.desktop image/x-icon
    xdg-mime default org.gnome.gThumb.desktop image/heif
    xdg-mime default org.gnome.gThumb.desktop image/heic
    xdg-mime default org.gnome.gThumb.desktop image/avif
    xdg-mime default org.gnome.gThumb.desktop image/svg+xml

}

_set_up() {
    _set_defaults
    dconf load /org/gnome/gthumb/ <"$HOME/.config/yadm/misc/gthumb/gthumb-settings.dconf"
}

_set_up
