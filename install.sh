#!/usr/bin/env bash

##### install prerequisites #####
#: <<'END'
printf "\n###\n Start update and upgrade \n###\n"
sudo apt-get update
#sudo apt-get -y upgrade

printf "\n###\n install pip, lirc and python-lirc \n###\n"
sudo apt-get install -y python-pip lirc python-lirc

printf "\n###\n install soco \n###\n"
sudo pip install soco

##### kernel check and /boot/config.txt #####

printf "\n###\n Check Kernel version and change /boot/config.txt \n###\n"

# get kernel number by removing the point, e.g. 4.4 => 44
VERSION=$(awk -F. '{print $1$2}' <<< $(uname -r))
echo "Version $(uname -r)"

# make 44 to 440 to be bigger than 318
if [ $VERSION -gt 39 ] && [ $VERSION -lt 100 ]
then
	VERSION=$((VERSION * 10))
fi

# if Kernel ≥ 3.18 edit /boot/config.txt, else edit /etc/modules
if [ $VERSION -ge 318 ]
then
	#echo "Greater: $VERSION"
	# replace lines in file, create backup file
	sudo sed -i_backup -e 's/#dtoverlay=lirc-rpi/dtoverlay=lirc-rpi/g'  /boot/config.txt
	printf "\nEdited /boot/config.txt and created backup /boot/config.txt_backup\n"
else
	#echo "Smaller: $VERSION"
	# create backup file and add lines
	sudo cp /etc/modules /etc/modules_backup
	sudo echo lirc_dev >> /etc/modules
	sudo echo lirc_rpi >> /etc/modules
	printf "\nEdited /etc/modules and created backup /etc/modules_backup\n"
fi

##### hardware.conf #####

printf "\n###\n Edit hardware.conf \n###\n"

# create backup and change lines
sudo cp /etc/lirc/hardware.conf /etc/lirc/hardware.conf_backup
sudo sed -i -e 's/LIRCD_ARGS=""/LIRCD_ARGS="--uinput"/g' /etc/lirc/hardware.conf
sudo sed -i -e 's/DRIVER="UNCONFIGURED"/DRIVER="default"/g' /etc/lirc/hardware.conf
sudo sed -i -e 's/DEVICE=""/DEVICE="\/dev\/lirc0"/g' /etc/lirc/hardware.conf
sudo sed -i -e 's/MODULES=""/MODULES="lirc_rpi"/g' /etc/lirc/hardware.conf

printf "\nEdited /etc/lirc/hardware.conf and created backup /etc/lirc/hardware.conf_backup\n"

##### lirc #####

printf "\n###\n Copy lirc configuration files \n###\n"

DIR_PATH=${PWD}
echo $DIR_PATH

sudo cp /etc/lirc/lircd.conf /etc/lirc/lircd.conf_backup
sudo cp /etc/lirc/lircrc /etc/lirc/lircrc_backup

sudo cp "$DIR_PATH/lircd.conf" /etc/lirc/
sudo cp "$DIR_PATH/lircrc" /etc/lirc/

printf "\nCreated backups and edited files in /etc/lirc/ \n"

##### specific setup, IP #####

# write Sonos Zones to file and read the file
python get_sonos_ip.py

printf "\n#####\nChoose the zone, enter the number and press [ENTER]: \n"
J=1
while IFS=, read name ip
do
	echo "$J. $name"
	IP_LIST[$J]=${ip:19:-1}
	J=$(($J + 1))
done < discovered.csv

# waiting for input
read ZONE

# replace string in config.py
sudo sed -i -e "s/IP_ADDRESS='.*'/IP_ADDRESS='${IP_LIST[$ZONE]}'/g" "$DIR_PATH/config.py"

rm discovered.csv

printf "\nSaved chosen zone in $DIR_PATH/config.py \n"
#END

##### Enable daemon #####

# Only for systemd!!!

printf "\n###\n Configuring Service \n###\n"

# change dir path
sudo sed -i -e "s/ExecStart=\/home\/pi\/SonosRemote\/sore.py/ExecStart=$DIR_PATH\/sore.py/g" "$DIR_PATH/sore.service"

# copy service
sudo cp "$DIR_PATH/sore.service" /etc/systemd/system/
sudo chmod 664 /etc/systemd/system/sore.service

# enable service
sudo systemctl daemon-reload
sudo systemctl enable sore.service
systemctl status sore.service

printf "\nCreated and enabled sore.service \n"

##### Reboot #####

printf "\nThe changes will take effect after the next reboot. Would you like to reboot now? \n"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) sudo shutdown -r now; break;;
        No ) exit;;
    esac
done
