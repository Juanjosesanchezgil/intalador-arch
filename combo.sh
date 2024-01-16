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

function get_necessary_info() {
	logo "Ingresa la informacion Necesaria"

	while true; do
		read -rp "Ingresa tu usuario: " USR
			if [[ "${USR}" =~ ^[a-z][_a-z0-9-]{0,30}$ ]]; then
				break
			else
				printf "\n%sIncorrecto!! Solo se permiten minúsculas.%s\n\n" "$RED" "$WHITE"
			fi 		
	done 

	while true; do
		read -rsp "Ingresa tu password: " PASSWD
		echo
		read -rsp "Confirma tu password: " CONF_PASSWD

		if [ "$PASSWD" != "$CONF_PASSWD" ]; then
			printf "\n%sLas contraseñas no coinciden. Intenta nuevamente.!!%s\n\n" "$RED" "$WHITE"
		else
			printf "\n\n%sContraseña confirmada correctamente.\n\n%s" "$GREEN" "$WHITE"
			break
		fi
	done

	while true; do
		read -rsp "Ingresa tu password para ROOT: " PASSWDR
		echo
		read -rsp "Confirma tu password: " CONF_PASSWDR

		if [ "$PASSWDR" != "$CONF_PASSWDR" ]; then
        printf "\n%sLas contraseñas no coinciden. Intenta nuevamente.!!%s\n\n" "$RED" "$WHITE"
		else
			printf "\n\n%sContraseña confirmada correctamente.%s\n\n" "$GREE" "$WHITE"
			break
		fi
	done

	while true; do
		read -rp "Ingresa el nombre de tu máquina: " HNAME
    
		if [[ "$HNAME" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]; then
			break
		else
			printf "%sIncorrecto!! El nombre no puede incluir mayúsculas ni símbolos especiales.%s\n\n" "$CRE" "$CNC"
		fi
	done
	clear
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
get_necessary_info
base
fstab
set_timezone_lang_keyboard