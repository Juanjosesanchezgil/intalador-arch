#!usr/bin/env bash

#---------- Variables ----------

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
WHITE=$(tput sgr0)
CHROOT="arch-chroot /mnt"

#---------- Sistema base ----------
function base(){
    pacstrap /mnt \
            base base-devel \
            linux linux-firmware 

    okie
    clear
}

function fstab(){
    genfstab -U /mnt >> /mnt/etc/fstab

    okie
    clear

}

#---------- Ejecutar funciones ----------

base
fstab