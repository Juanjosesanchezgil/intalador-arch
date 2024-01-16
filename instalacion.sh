#!/bin/bash
# -*- ENCODING: UTF-8 -*-
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



umount -l /mnt

reboot
