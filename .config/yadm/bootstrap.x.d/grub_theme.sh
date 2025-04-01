_change_grub_theme() {
   sudo cp -r "$HOME/.config/grubthemes/Elegant-mojave-window-grub-themes/left-dark-1080p" /boot/grub/themes/elegant-mojave
   echo 'GRUB_THEME="/boot/grub/themes/elegant-mojave"' | sudo bash -c 'cat >> /etc/default/grub'
   sudo grub-mkconfig -o /boot/grub/grub.cfg
}

_change_grub_theme
