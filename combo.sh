#!usr/bin/env bash

clear
loadkeys es

#---------- Variables ----------

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
WHITE=$(tput sgr0)
CHROOT="arch-chroot /mnt"

ok() {
	printf "\n%s OK...%s\n" "$GREEN" "$WHITE"
	sleep 2
}

titleopts () {
	
	local textopts="${1:?}"
	printf " \n%s>>>%s %s%s%s\n" "${BLUE}" "${WHITE}" "${YELLOW}" "${textopts}" "${WHITE}"
}

logo() {
	
	local text="${1:?}"
	printf ' %s%s[%s %s %s]%s\n\n' "$BOLD" "$RED" "$YELLOW" "${text}" "$RED" "$WHITE"
}

#---------- Sistema base ----------
function base(){
    pacstrap /mnt \
            base base-devel \
            linux linux-firmware 

    ok
    clear
}

function fstab(){
    genfstab -U /mnt >> /mnt/etc/fstab

    ok
    clear

}

#--------- Idioma

function set_timezone_lang_keyboard() {
	logo "Configurando Timezone y Locales"
		
	$CHROOT ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
	$CHROOT hwclock --systohc
	echo
	echo "es_ES.UTF-8 UTF-8" >> /mnt/etc/locale.gen
	$CHROOT locale-gen
	echo "LANG=es_ES.UTF-8" >> /mnt/etc/locale.conf
	echo "KEYMAP=es" >> /mnt/etc/vconsole.conf
	export LANG=es_ES.UTF-8

	ok
	clear
}

#---------- Ejecutar funciones ----------

base
fstab
set_timezone_lang_keyboard