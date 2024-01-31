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

function evitar_error_pgpkey () {
    umount /etc/pacman.d/gnupg
    rm -rf /etc/pacman.d/gnupg
    pacman-key --init
    pacman-key --populate
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
			printf "\n\n%sContraseña confirmada correctamente.%s\n\n" "$GREEN" "$WHITE"
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

#--------- Particiones --------

function particion(){
    echo "
    -------------------------------------
    Instalador automatico personalizado
    -------------------------------------
    "
    fdisk -l
    echo "
    ¿En que unidad deseas intalar?: 
    -------------------------------------
    "
    contador=0
    while [[ true ]]
    do
    ((contador+=1))
    unidad=$(fdisk -l | grep "Disk /dev/" | awk 'NR=='$contador'{print $0}' | awk {'print $2'} | cut -d '/' -f3 | cut -d ':' -f1)
    if [[ -z "$unidad" ]]
    then
        break
    fi
    if [[ $unidad == sd* ]] || [[ $unidad == nvme* ]]
    then
        echo "$contador" "$unidad"
    fi
    done
    echo 
    read -p "Introduce el numero: " contador
    echo

    unidad=$(fdisk -l | grep "Disk /dev/" | awk 'NR=='$contador'{print $0}' | awk {'print $2'} | cut -d '/' -f3 | cut -d ':' -f1)

    # Automatizar particionado
    cfdisk /dev/"$unidad"

    fdisk -l | grep $unidad

    echo 
    read -p "¿Es una instalacion multiboot? s/n: " arranque
    echo "----------------------------------------------
    "

    echo "-------------------------
    Sistema de particiones
    -------------------------
    "
    if [[ $unidad =~ nvme* ]]
    then 
    unidad="${unidad}p"
    fi  

    if [[ $arranque =~ ^(S|s)$ ]]
    then
    mkswap /dev/"$unidad"1
    mkfs.ext4 /dev/"$unidad"2
    mkfs.ext4 /dev/"$unidad"3
    
    echo -------------------------
    echo Montando particiones
    echo -------------------------
    
    swapon /dev/"$unidad"1
    mount /dev/"$unidad"2 /mnt
    mount --mkdir /dev/"$unidad"3 /mnt/home
    
    echo -------------------------
    echo Opciones particion Boot
    echo -------------------------
    
    fdisk -l
    unidad=$(fdisk -l | grep "EFI System" | awk 'NR=='1'{print $0}' | awk {'print $1'} | cut -d '/' -f3 | cut -d ':' -f1)
    mount --mkdir /dev/"$unidad" /mnt/boot
    else

    mkswap /dev/"$unidad"2
    mkfs.ext4 /dev/"$unidad"3
    mkfs.ext4 /dev/"$unidad"4
    
    echo -------------------------
    echo Montando particiones
    echo -------------------------
    
    swapon /dev/"$unidad"2
    mount /dev/"$unidad"3 /mnt
    mount --mkdir /dev/"$unidad"4 /mnt/home
    
    echo -------------------------
    echo Opciones particion Boot
    echo -------------------------
    
    mkfs.fat -F 32 /dev/"$unidad"1
    mount --mkdir /dev/"$unidad"1 /mnt/boot
    fi
}

#---------- Sistema base ----------
function base(){
    sed -i 's/#Color/Color/; s/#ParallelDownloads = 5/ParallelDownloads = 5/; /^ParallelDownloads =/a ILoveCandy' /etc/pacman.conf
    pacstrap /mnt \
            base base-devel \
            linux linux-firmware \
            git zsh

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

#---------- Hostname & Hosts ----------
function set_hostname_hosts() {
	logo "Configurando Internet"

	echo "${HNAME}" >> /mnt/etc/hostname
	cat >> /mnt/etc/hosts <<- EOL		
		127.0.0.1   localhost
		::1         localhost
		127.0.1.1   ${HNAME}.localdomain ${HNAME}
	EOL
	ok
	clear
}

#---------- Users & Passwords ----------
function create_user_and_password() {
	logo "Usuario Y Passwords"

	echo "root:$PASSWDR" | $CHROOT chpasswd
	$CHROOT useradd -m -g users -G wheel -s /usr/bin/zsh "${USR}"
	echo "$USR:$PASSWD" | $CHROOT chpasswd
	sed -i 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/; /^root ALL=(ALL:ALL) ALL/a '"${USR}"' ALL=(ALL:ALL) ALL' /mnt/etc/sudoers
	echo "Defaults insults" >> /mnt/etc/sudoers
	printf " %sroot%s : %s%s%s\n %s%s%s : %s%s%s\n" "${BOLD}" "${WHITE}" "${RED}" "${PASSWDR}" "${WHITE}" "${YELLOW}" "${USR}" "${WHITE}" "${RED}" "${PASSWD}" "${WHITE}"
	ok
	sleep 3
	clear
}

#-------- Grub
function install_grub() {
	logo "Instalando GRUB"

	$CHROOT pacman -S grub efibootmgr os-prober ntfs-3g --noconfirm >/dev/null
	$CHROOT grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot
	
	sed -i 's/quiet/zswap.enabled=0 mitigations=off nowatchdog/; s/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /mnt/etc/default/grub
	sed -i "s/MODULES=()/MODULES=(intel_agp i915 zram)/" /mnt/etc/mkinitcpio.conf
	echo
	$CHROOT grub-mkconfig -o /boot/grub/grub.cfg
	ok
	clear  
}

function conf_keyboard() {
	cat >> /mnt/etc/X11/xorg.conf.d/00-keyboard.conf <<EOL
Section "InputClass"
		Identifier	"system-keyboard"
		MatchIsKeyboard	"on"
		Option	"XkbLayout"	"es"
EndSection
EOL
	printf "%s00-keyboard.conf%s generated in --> /etc/X11/xorg.conf.d\n" "${GREEN}" "${WHITE}"
}

function install_lightdm() {
    logo "Instalando LightDM"
    $CHROOT pacman -S \
                        lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfirm
}

function install_video(){
    logo "Instalando graficos"
    $CHROOT pacman -S \
                        xorg-server \
                        --noconfirm
}

function install_wm(){
    logo "Intalando WM"
    $CHROOT pacman -S i3-wm --noconfirm
}

function install_apps(){
    logo "Instalando aplicaciones"
    $CHROOT pacman -S \
                      alacritty \
                      --noconfirm
}

function activar_servicios() {
    logo "Activando Servicios"

	$CHROOT systemctl enable lightdm.service
}

function install_yay (){

    echo "cd && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd" | $CHROOT su "$USR"
}

function install_aur_app(){
    logo "Instalado apps aur"

    echo "cd && yay -S google-chrome visual-studio-code-bin --skipreview --noconfirm --removemake" | $CHROOT su "$USR"
    
}


#---------- Ejecutar funciones ----------
get_necessary_info
particion
base
fstab
set_timezone_lang_keyboard
set_hostname_hosts
create_user_and_password
install_grub
conf_keyboard
install_lightdm
install_video
install_wm
install_apps
activar_servicios
install_yay
install_aur_app