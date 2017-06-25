#!/bin/bash

#   copyright xer0.design - licenced under gpl 3.0
#   https://github.com/xer0design/led-matrix-controller

echo "                ___      _           _             "
echo "__  _____ _ __ / _ \  __| | ___  ___(_) __ _ _ __  "
echo "\ \/ / _ \ '__| | | |/ _\` |/ _ \/ __| |/ _\` | '_ \ "
echo " >  <  __/ |  | |_| | (_| |  __/\__ \ | (_| | | | |"
echo "/_/\_\___|_|   \___(_)__,_|\___||___/_|\__, |_| |_|"
echo "                                       |___/       "
echo "welcome. this is beta code but should work. you should be running raspbian lite."
echo "setup will start in 10 seconds."
sleep 10
#update and upgrade all packages if requested
read -r -p "Would you like to update apt and upgrade all packages? (recommended) [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
	echo "okay, upgrading packages"
	sudo apt update
	sudo apt -y upgrade
else
    echo "okay, continuing..."
fi
#install apache2
echo "installing apache2 required extensions to run the web ui"
sudo apt install apache2 php5 python python-dev python-imaging python-pip -y
#allowing gpio pins to be run by www-data, and www-data to run the 3 scripts we need sudo for.
echo "allowing all users to access gpio and run the scripts we need"
sudo adduser www-data gpio
sudo adduser pi gpio
echo "www-data ALL=NOPASSWD: /home/pi/led-matrix-controller/rpi-rgb-led-matrix/examples-api-use/php.sh, /home/pi/led-matrix-controller/rpi-rgb-led-matrix/examples-api-use/pithon.py, /home/pi/led-matrix-controller/rpi-rgb-led-matrix/examples-api-use/loadpithon.sh, /home/pi/led-matrix-controller/scripts/*, /home/pi/led-matrix-controller/rpi-rgb-led-matrix/examples-api-use/time.sh" >> /etc/sudoers
#below is alternative method, this will allow www-data to run ANY command though so make sure only you have access to website. disabled as defaultfor security.
#echo "chmod 666 /dev/mem" >> /etc/rc.local
#install tools for generating images
echo "installing tools required for generating images and text on the fly"
sudo apt-get install libgraphicsmagick++-dev libwebp-dev -y
sudo pip install Pillow emoji
#enter examples and make
echo "making required programs"
cd rpi-rgb-led-matrix/examples-api-use
make
#add video programs, enter utilities and make image and video
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev
make video-viewer
make led-image-viewer
cd ../utils 
cd ../..
#disable pi sound
echo "dtparam=audio=off" >> /boot/config.txt
cat <<EOF | sudo tee /etc/modprobe.d/blacklist-rgb-matrix.conf
blacklist snd_bcm2835
EOF
sudo update-initramfs -u
#setup apache
echo "setting up web controller"
#remove current html directory
sudo rm -rf /var/www/html
#make symlink for website to load from current folder and make sure permissions are okay
ln -s /home/pi/led-matrix-controller/www/ /var/www/html
sudo chmod -R 777 www
sudo chown -R www-data:www-data www
#add cronjob to display ip address on boot
echo "adding cronjob to show ip address on boot"
sudo echo "@reboot /home/pi/led-matrix-controller/scripts/ip.sh" >> /var/spool/cron/crontabs/pi
clear
printf  "system will reboot in 10 seconds.\nafter reboot, you should see the ip address on your led panel.\ngo to that address to update the screen.\n\nthe default password is \"password\".\n\n"
sleep 5
echo "5"
sleep 1
echo "4"
sleep 1
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
echo "goodbye"
sudo reboot
exit
