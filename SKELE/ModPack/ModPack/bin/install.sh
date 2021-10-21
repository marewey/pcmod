#!/bin/bash
clear
cd ..
#Verify the correct directory...
if [[ ! -e options.txt ]]; then
	echo "ERROR: Does the data exist? in..."`pwd`
	sleep 5
	exit
fi
#Check if .minecraft exists
if [[ ! -e ~/.minecraft/options.txt ]]; then
	mkdir ~/mcbackup/
	cp -R ~/.minecraft/* ~/mcbackup/
fi
#install
echo "Installing PCMod... "
echo `pwd`"/ --> "`dirname ~/.minecraft`"/.minecraft/"
mkdir ~/.minecraft
sleep 2
cp -R -v * ~/.minecraft/
#Clean
echo "Cleaning..."
rm -R ~/.minecraft/bin
#Launch
./launch.sh