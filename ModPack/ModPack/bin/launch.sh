#!/bin/bash
clear
version="1.9.4c"
#Net Info
iface=`/sbin/ip -4 -o a | cut -d ' ' -f 2 | cut -d '/' -f 1 | grep -v "lo"`
ssid=`iwconfig $iface | grep ESSID | awk -F: '{print $2}' | sed 's/\"//g' | awk '{$1=$1};1'`
echo "SSID:'$ssid' IFACE:'$iface'"
if [[ "$ssid" == "Rewey Hub" ]]; then
        url=192.168.0.27
elif [[ "$ssid" == "Rewey Hub" ]]; then
		url=192.168.0.27
elif [[ "$ssid" == "Rewey Hub" ]]; then
		url=192.168.0.27
else
        url=markspi.ddns.net
fi
#SKINS
wget "$url/pcmod/skins/skins.zip" 2>wget.log
unzip skins.zip -d ~/.minecraft/cachedImages/
#CHECK UPDATE
wget -O version "$url/pcmod2/version" 2>wget.log
version_=`cat version`
if [[ "$version" != "$version_" ]]; then
	echo "Update Availible: $version_"
	read -p "Are you sure? " -n 1 -r
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		./update.sh
		exit
	fi
fi
#LAUNCH
java -jar Minecraft.jar