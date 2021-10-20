#!/bin/bash
clear
rm ModPack.zip*
#BACKUP saves
echo -n "Backing up data..."
mkdir -p ./PCMod_Backup/saves
cp -r ~/.minecraft/saves/* ./PCMod_Backup/saves/
cp ~/.minecraft/options.txt ./PCMod_Backup/
cp ~/.minecraft/optionsof.txt ./PCMod_Backup/
echo " DONE"
#NETCheck
iface=`/sbin/ip -4 -o a | cut -d ' ' -f 2 | cut -d '/' -f 1 | grep -v "lo"`
ssid=`iwconfig $iface | grep ESSID | awk -F: '{print $2}' | sed 's/\"//g' | awk '{$1=$1};1'`
echo "SSID:'$ssid' IFACE:'$iface'"
if [[ "$ssid" == "Rewey Hub" ]]; then
        url=192.168.0.27
else
        url=markspi.ddns.net
fi
#DOWNLOAD
echo -n "Downloading 'Modpack.zip' from '$url'..."
wget "$url/pcmod/downloads/ModPack.zip" 2>wget.log
echo " DONE"
#CLEAN
echo -n "Cleaning old data..."
rm -R ~/.minecraft/*
echo " DONE"
#UNZIP and Install
echo -n "Installing..."
unzip ModPack.zip -d ~/.minecraft/
echo " DONE"
#RESTORE saves
echo -n "Restoring backed up data..."
cp -R ./PCMod_Backup/saves/* ~/.minecraft/saves/
cp ./PCMod_Backup/options.txt ~/.minecraft/
cp ./PCMod_Backup/optionsof.txt ~/.minecraft/
echo " DONE"
echo "Update Finished!"
sleep 2