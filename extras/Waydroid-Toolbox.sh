#!/bin/bash
PASSWORD=$(zenity --password --title "sudo Password Authentication")
echo $PASSWORD | sudo -S ls &> /dev/null
if [ $? -ne 0 ]
then
	echo sudo password is wrong! | \
		zenity --text-info --title "Clover Toolbox" --width 400 --height 200
	exit
fi

while true
do
Choice=$(zenity --width 850 --height 250 --list --radiolist --multiple 	--title "Waydroid Toolbox for SteamOS Waydroid script  - https://github.com/ryanrudolfoba/steamos-waydroid-installer"\
	--column "Select One" \
	--column "Option" \
	--column="Description - Read this carefully!"\
	FALSE ADBLOCK "Disable or update the custom adblock hosts file."\
	FALSE AUDIO "Enable or disable the custom audio fixes."\
	FALSE Uninstall "Choose this to uninstall Waydroid and revert any changes made."\
	TRUE EXIT "***** Exit the Waydroid Toolbox *****")

if [ $? -eq 1 ] || [ "$Choice" == "EXIT" ]
then
	echo User pressed CANCEL / EXIT.
	exit

elif [ "$Choice" == "ADBLOCK" ]
then
ADBLOCK_Choice=$(zenity --width 600 --height 220 --list --radiolist --multiple --title "Waydroid Toolbox" --column "Select One" \
	--column "Option" --column="Description - Read this carefully!"\
	FALSE DISABLE "Disable the custom adblock hosts file."\
	FALSE UPDATE "Update and enable the custom adblock hosts file."\
	TRUE MENU "***** Go back to Waydroid Toolbox Main Menu *****")

	if [ $? -eq 1 ] || [ "$ADBLOCK_Choice" == "MENU" ]
	then
		echo User pressed CANCEL. Going back to main menu.

	elif [ "$ADBLOCK_Choice" == "DISABLE" ]
	then
		# Disable the custom adblock hosts file
		echo -e $PASSWORD\n | sudo -S mv /var/lib/waydroid/overlay/system/etc/hosts /var/lib/waydroid/overlay/system/etc/hosts.disable &> /dev/null

		zenity --warning --title "Waydroid Toolbox" --text "Custom adblock hosts file has been disabled!" --width 450 --height 75

	elif [ "$ADBLOCK_Choice" == "UPDATE" ]
	then
		# get the latest custom adblock hosts file from steven black github
		echo -e $PASSWORD\n | sudo -S rm /var/lib/waydroid/overlay/system/etc/hosts.disable &> /dev/null
		echo -e $PASSWORD\n | sudo -S wget https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts \
		       -O /var/lib/waydroid/overlay/system/etc/hosts	

		zenity --warning --title "Waydroid Toolbox" --text "Custom adblock hosts file has been updated!" --width 450 --height 75
	fi

elif [ "$Choice" == "AUDIO" ]
then
AUDIO_Choice=$(zenity --width 600 --height 220 --list --radiolist --multiple 	--title "Waydroid Toolbox" --column "Select One" --column "Option" --column="Description - Read this carefully!"\
	FALSE DISABLE "Disable the custom audio config."\
	FALSE ENABLE "Enable the custom audio config to lower audio latency."\
	TRUE MENU "***** Go back to Waydroid Toolbox Main Menu *****")
	if [ $? -eq 1 ] || [ "$AUDIO_Choice" == "MENU" ]
	then
		echo User pressed CANCEL. Going back to main menu.

	elif [ "$AUDIO_Choice" == "DISABLE" ]
	then
		# Disable the custom audio config
		echo -e $PASSWORD\n | sudo -S mv /var/lib/waydroid/overlay/system/etc/init/audio.rc \
		       	/var/lib/waydroid/overlay/system/etc/init/audio.rc.disable &> /dev/null

		zenity --warning --title "Waydroid Toolbox" --text "Custom audio config has been disabled!" --width 450 --height 75

	elif [ "$AUDIO_Choice" == "ENABLE" ]
	then
		# Enable the custom audio config
		echo -e $PASSWORD\n | sudo -S mv /var/lib/waydroid/overlay/system/etc/init/audio.rc.disable \
		       	/var/lib/waydroid/overlay/system/etc/init/audio.rc &> /dev/null

		zenity --warning --title "Waydroid Toolbox" --text "Custom audio config has been enabled!" --width 450 --height 75
	fi

elif [ "$Choice" == "Uninstall" ]
then
	# disable the steamos readonly
	echo -e $PASSWORD\n | sudo -S steamos-readonly disable
	
	# remove the kernel module and packages installed
	echo -e $PASSWORD\n | sudo -S systemctl stop waydroid-container
	echo -e $PASSWORD\n | sudo -S rm /lib/modules/$(uname -r)/binder_linux.ko.zst
	echo -e $PASSWORD\n | sudo -S pacman -R --noconfirm libglibutil libgbinder python-gbinder waydroid wlroots dnsmasq lxc
	
	# delete the waydroid directories and config
	echo -e $PASSWORD\n | sudo -S rm -rf ~/waydroid /var/lib/waydroid ~/.local/share/waydroid ~/.local/share/applications/waydroid* ~/AUR
	
	# delete waydroid config and scripts
	echo -e $PASSWORD\n | sudo -S rm /etc/sudoers.d/zzzzzzzz-waydroid /etc/modules-load.d/waydroid.conf /usr/bin/waydroid-fix-controllers \
		/usr/bin/waydroid-container-stop /usr/bin/waydroid-container-start
	
	# delete cage binaries
	echo -e $PASSWORD\n | sudo -S rm /usr/bin/cage /usr/bin/wlr-randr

	# delete Waydroid Toolbox symlink
	rm ~/Desktop/Waydroid-Toolbox
	
	# delete contents of ~/Android_Waydroid
	rm -rf ~/Android_Waydroid/
	
	# re-enable the steamos readonly
	echo -e $PASSWORD\n | sudo -S steamos-readonly enable
	
	zenity --warning --title "Waydroid Toolbox" --text "Waydroid has been uninstalled! Goodbye!" --width 600 --height 75
	exit
fi
done
