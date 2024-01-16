#!/bin/bash
# -*- ENCODING: UTF-8 -*-

pacman -Sy

pacman -S alacritty docker docker-compose efibootmgr git grub i3-wm lightdm lightdm-gtk-greeter networkmanager os-prober pulseaudio xorg --noconfirm


echo -------------------------
echo Opciones de usuario
echo -------------------------

echo -------------------------
echo Clave usuario root
echo -------------------------

passwd

echo -------------------------
echo Introduce nombre de usuario
echo -------------------------

read usuario


useradd -m $usuario

echo -------------------------
echo Clave usuario $usuario
echo -------------------------

passwd $usuario

usermod -aG wheel,audio,video,storage,docker $usuario

sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

read -p "Introduce el nombre de tu host " host

echo $host >> /etc/hostname
echo "127.0.0.1 localhost
::1 localhost
127.0.1.1 $host " >> /etc/hosts

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


chown -R $usuario /home/$usuario/
chgrp -R $usuario /home/$usuario/







