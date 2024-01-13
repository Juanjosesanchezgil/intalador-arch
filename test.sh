#!/usr/bin/env bash

clear
loadkeys es
#-------------------------------------------------------------
#         Configurando Variables y Funciones Basicas
#-------------------------------------------------------------

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
CBO=$(tput bold)
CNC=$(tput sgr0)
CHROOT="arch-chroot /mnt"

logo () {
    
    local text="${1:?}"
    echo -en "
                   -
                  .o+
                  ooo/
                +oooooo:
               -+oooooo+:
              /:-:++oooo+:
             /++++/+++++++:
            /++++++++++++++:
           /+++ooooooooooooo/
         ./ooosssso++osssssso+
        .oossssso-````/ossssss+
       -osssssso.      :ssssssso.
      :osssssss/        osssso+++.
     /ossssssss/        +ssssooo/-
    /ossssso+/:-        -:/+osssso+-
   +sso+:-`                 `.-/+oso:
  ++:.                            -/+/
    .                                   / \n\n"
    printf ' \033[0;31m[ \033[0m\033[1;93m%s\033[0m \033[0;31m]\033[0m\n\n' "${text}"
    sleep 3
}

okie() {
    printf "\n%s OK...%s\n" "$CGR" "$CNC"
    sleep 2
}

titleopts () {
    
    local textopts="${1:?}"
    printf " \n%s>>>%s %s%s%s\n" "${CBL}" "${CNC}" "${CYE}" "${textopts}" "${CNC}"
}

# #-------------------------------------------------------------
#          Check  BIOS CPU And Graphics
# #-------------------------------------------------------------

arranque() {
    logo "Comprobando modo de arranque"
    
    if [ -d /sys/firmware/efi/efivars ]; then
        bootmode="uefi"
        printf " El Script se ejecutara en modo EFI"
        sleep 2
        clear
    else
        bootmode="mbrbios"
        printf " El Script se ejecutara en modo BIOS/MBR"
        sleep 2
        clear
    fi
}

#----------------------------------------
#          Testing Internet
#----------------------------------------
conexion () {
    logo "Checando conexion a internet.."
    
    if ping archlinux.org -c 1 >/dev/null 2>&1; then
        printf " Espera....\n\n"
        sleep 3
        printf " %sSi hay Internet!!%s" "${CGR}" "${CNC}"
        sleep 2
        clear
    else
        printf " Error: Parace que no hay internet..\n\n Saliendo...."
        sleep 2
        exit 0
    fi
}

#----------------------------------------
#       Basic configuration information
#----------------------------------------

teclado () {
    logo "Selecciona la distribucion de tu teclado"
    
    setkmap_options=("Ingles US" "Español")
    PS3="Selecciona la distrubucion de tu teclado (1 o 2): "
    select opt in "${setkmap_options[@]}"; do
        case "$REPLY" in
            1)
                setkmap_title='US';
                setkmap='us';
                x11keymap="us";
            break;;
            2)
                setkmap_title='Español';
                setkmap='la-latin1';
                
            x11keymap="latam";break;;
            *)
                echo "Opcion invalida, intenta de nuevo.";
            continue;;
        esac
    done
    
    printf '\nCambiando distribucion de teclado a %s\n' "${setkmap_title}"
    loadkeys "${setkmap}"
    okie
    clear
}

logo "Selecciona tu idioma"

PS3="Selecciona tu idioma: "
select idiomains in $(grep UTF-8 /etc/locale.gen | sed 's/\..*$//' | sed '/@/d' | awk '{print $1}' | uniq | sed 's/#//g')
do
    if [ "$idiomains" ]; then
        break
    fi
done

printf '\nCambiando idioma a %s ...\n' "${idiomains}"
echo "${idiomains}".UTF-8 UTF-8 >> /etc/locale.gen
locale-gen >/dev/null 2>&1
export LANG=${idiomains}.UTF-8
okie
clear

logo "Selecciona tu zona horaria"

tzselection=$(tzselect  | tail -n1 )
okie
clear

#----------------------------------------
#          Getting Information
#----------------------------------------
function get_necessary_info() {
    logo "Ingresa la informacion Necesaria"
    
    while true; do
        read -rp "Ingresa tu usuario: " USR
        if [[ "${USR}" =~ ^[a-z][_a-z0-9-]{0,30}$ ]]; then
            break
        else
            printf "\n%sIncorrecto!! Solo se permiten minúsculas.%s\n\n" "$CRE" "$CNC"
        fi
    done
    
    while true; do
        read -rsp "Ingresa tu password: " PASSWD
        echo
        read -rsp "Confirma tu password: " CONF_PASSWD
        
        if [ "$PASSWD" != "$CONF_PASSWD" ]; then
            printf "\n%sLas contraseñas no coinciden. Intenta nuevamente.!!%s\n\n" "$CRE" "$CNC"
        else
            printf "\n\n%sContraseña confirmada correctamente.\n\n%s" "$CGR" "$CNC"
            break
        fi
    done
    
    while true; do
        read -rsp "Ingresa tu password para ROOT: " PASSWDR
        echo
        read -rsp "Confirma tu password: " CONF_PASSWDR
        
        if [ "$PASSWDR" != "$CONF_PASSWDR" ]; then
            printf "\n%sLas contraseñas no coinciden. Intenta nuevamente.!!%s\n\n" "$CRE" "$CNC"
        else
            printf "\n\n%sContraseña confirmada correctamente.%s\n\n" "$CGR" "$CNC"
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

arranque
conexion
teclado
get_necessary_info
