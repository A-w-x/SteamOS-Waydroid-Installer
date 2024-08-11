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
$usrname ALL=(ALL) NOPASSWD: /usr/local/bin/waydroid-fix-storage
$usrname ALL=(ALL) NOPASSWD: /usr/bin/systemctl start waydroid-container
$usrname ALL=(ALL) NOPASSWD: /usr/bin/systemctl stop waydroid-container
EOF

# lets check if this is a reinstall
if grep -i redfin /var/lib/waydroid/waydroid_base.prop &>/dev/null; then
	echo This seems to be a reinstall. No further config needed.
	echo Waydroid has been successfully installed!

else
	echo Config file missing. Lets configure waydroid.

	# lets initialize waydroid
	sudo waydroid init -s GAPPS

 	# check if waydroid initialization completed without errors
	if [ $? -eq 0 ]
	then
		echo Waydroid initialization completed without errors!

	else
		echo Waydroid did not initialize correctly
		echo Output of whereis python - $(whereis python)
		echo Output of which python - $(which python)
		echo Output of python version - $(python -V)
		exit 1
	fi

	# firewall config for waydroid0 interface to forward packets for internet to work
	sudo firewall-cmd --zone=trusted --add-interface=waydroid0 &> /dev/null
	sudo firewall-cmd --zone=trusted --add-port=53/udp &> /dev/null
	sudo firewall-cmd --zone=trusted --add-port=67/udp &> /dev/null
	sudo firewall-cmd --zone=trusted --add-forward &> /dev/null
	sudo firewall-cmd --runtime-to-permanent &> /dev/null

	# casualsnek script
	git clone https://github.com/casualsnek/waydroid_script

	if [ $? -eq 0 ]
	then
		echo Casualsnek repo has been successfully cloned!
	else
		echo Error cloning Casualsnek repo!
		exit 1
	fi

	cd waydroid_script
	python3 -m venv venv
	venv/bin/pip install -r requirements.txt &> /dev/null
	sudo venv/bin/python3 main.py install {libndk,widevine}

	if [ $? -eq 0 ]
	then
		cd ..
		echo Casualsnek script done.
		sudo rm -rf waydroid_script
	else
		cd ..
		echo Error with casualsnek script. Run the script again.
		sudo rm -rf waydroid_script
		exit 1
	fi

	# lets change the fingerprint so waydroid shows up as a Pixel 5 - Redfin
	sudo tee -a /var/lib/waydroid/waydroid_base.prop > /dev/null <<'EOF'

##########################################################################
# controller config for udev events
persist.waydroid.udev=true
persist.waydroid.uevent=true

##########################################################################
### start of custom build prop - you can safely delete if this causes issue

ro.product.brand=google
ro.product.manufacturer=Google
ro.system.build.product=redfin
ro.product.name=redfin
ro.product.device=redfin
ro.product.model=Pixel 5
ro.system.build.flavor=redfin-user
ro.build.fingerprint=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.system.build.description=redfin-user 11 RQ3A.211001.001 eng.electr.20230318.111310 release-keys
ro.bootimage.build.fingerprint=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.build.display.id=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.build.tags=release-keys
ro.build.description=redfin-user 11 RQ3A.211001.001 eng.electr.20230318.111310 release-keys
ro.vendor.build.fingerprint=google/redfin/redfin:11/RQ3A.211001.001/eng.electr.20230318.111310:user/release-keys
ro.vendor.build.id=RQ3A.211001.001
ro.vendor.build.tags=release-keys
ro.vendor.build.type=user
ro.odm.build.tags=release-keys

### end of custom build prop - you can safely delete if this causes issue
##########################################################################
EOF
	echo Waydroid has been successfully installed!
fi

# change GPU rendering to use minigbm_gbm_mesa
sudo sed -i "s/ro.hardware.gralloc=.*/ro.hardware.gralloc=minigbm_gbm_mesa/g" /var/lib/waydroid/waydroid_base.prop


