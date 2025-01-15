#!/bin/bash
clear

usrname=$(whoami)

echo "Custom SteamOS Waydroid Installer Script to install on vanilla Arch by awx"
echo -ne "https://github.com/ryanrudolfoba/SteamOS-Waydroid-Installer (official ryanrudolf repo)\n\n"

# custom sudoers file, do not ask for sudo for the custom waydroid scripts
sudo tee /etc/sudoers.d/waydroid-cmds >/dev/null <<- EOF
$usrname ALL=(ALL) NOPASSWD: /usr/local/bin/android-waydroid-cage
$usrname ALL=(ALL) NOPASSWD: /usr/local/bin/waydroid-container-stop
$usrname ALL=(ALL) NOPASSWD: /usr/local/bin/waydroid-container-start
$usrname ALL=(ALL) NOPASSWD: /usr/local/bin/waydroid-startup-script
$usrname ALL=(ALL) NOPASSWD: /usr/bin/systemctl start waydroid-container
$usrname ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop waydroid-container
EOF

if [[ -f /var/lib/waydroid/images/system.img ]]; then
	echo Waydroid is already installed.
	exit 0
fi

# lets initialize waydroid
sudo waydroid init -s GAPPS

# check if waydroid initialization completed without errors
if [ $? -eq 0 ]; then
	echo Waydroid initialization completed without errors!

else
	echo Waydroid did not initialize correctly
	echo Output of whereis python - $(whereis python)
	echo Output of which python - $(which python)
	echo Output of python version - $(python -V)
	exit 1
fi

if ! which firewall-cmd; then
	# firewall config for waydroid0 interface to forward packets for internet to work
	sudo firewall-cmd --zone=trusted --add-interface=waydroid0 &> /dev/null
	sudo firewall-cmd --zone=trusted --add-port=53/udp &> /dev/null
	sudo firewall-cmd --zone=trusted --add-port=67/udp &> /dev/null
	sudo firewall-cmd --zone=trusted --add-forward &> /dev/null
	sudo firewall-cmd --runtime-to-permanent &> /dev/null
fi

git clone https://github.com/huakim/waydroid_script

if [ $? -eq 0 ]; then
	echo waydroid_script repo has been successfully cloned!

else
	echo Error cloning waydroid_script repo!
	exit 1
fi

cd waydroid_script
python3 -m venv venv
venv/bin/pip install -r requirements.txt &> /dev/null
sudo venv/bin/python3 main.py install {libndk,widevine}

if [ $? -eq 0 ]; then
	cd ..
	echo waydroid_script done.
	sudo rm -rf waydroid_script

else
	cd ..
	echo Error with waydroid_script. Run the script again.
	sudo rm -rf waydroid_script
	exit 1
fi

echo Waydroid has been successfully installed!
