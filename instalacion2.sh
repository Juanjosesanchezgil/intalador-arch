#!/bin/bash
# -*- ENCODING: UTF-8 -*-

pacman -Sy

pacman -S alacritty docker docker-compose efibootmgr git grub i3-wm lightdm lightdm-gtk-greeter networkmanager os-prober pulseaudio xorg --noconfirm


echo -------------------------
echo Opciones de localizacion
echo -------------------------

ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

hwclock --systohc

sed -i 's/#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/g' /etc/locale.gen

locale-gen

echo LANG=es_ES.UTF-8 >> /etc/locale.conf
echo KEYMAP=es >> /etc/vconsole.conf

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

echo -------------------------
echo Instalando arranque
echo -------------------------

grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg

sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/g' /etc/default/grub

echo -------------------------
echo Creacion de .Xprofile
echo -------------------------

#echo "setxkbmap es &
#nm-applet &
#udiskie -t &
#volumeicon &
#alacritty -e git clone https://github.com/juanjosesanchezgil/arch.git
#chmod a+x arch/postinstalacion.sh
#alacritty -e ./arch/postinstalacion.sh" >> /home/"$usuario"/.xprofile


chown -R $usuario /home/$usuario/
chgrp -R $usuario /home/$usuario/







