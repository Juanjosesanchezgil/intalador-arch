#!/bin/bash
# -*- ENCODING: UTF-8 -*-

pacman -Sy

pacman -S alacritty docker docker-compose efibootmgr git grub i3-wm lightdm lightdm-gtk-greeter networkmanager os-prober pulseaudio xorg --noconfirm


usermod -aG wheel,audio,video,storage,docker $usuario

sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers


echo -------------------------
echo Activar servicios
echo -------------------------

systemctl enable NetworkManager.service
systemctl enable lightdm.service
systemctl enable docker.service


#echo "setxkbmap es &
#nm-applet &
#udiskie -t &
#volumeicon &
#alacritty -e git clone https://github.com/juanjosesanchezgil/arch.git
#chmod a+x arch/postinstalacion.sh
#alacritty -e ./arch/postinstalacion.sh" >> /home/"$usuario"/.xprofile






