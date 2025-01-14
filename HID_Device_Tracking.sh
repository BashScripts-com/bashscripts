#!/bin/bash
#
#     BashScripts.com  
#     Github: https://github.com/BashScripts-com
#		
#        Summary: Monitor USB activity specifically for "HID" (Human Interface) devices.
#
#			Required Programs: udev, sed, stdbuf
#
#	This script monitors USB activity events (add/remove/bind/unbind/change etc.) with udevadm, then greps specifically for
#	"HID", and displays the manufacturer of the device. It is useful to see if a device is properly showing up
#	as HID. This also helps to detect if a rogue device (like a flash drive) is secretly presenting itself as an HID device (BadUSB).

#
#	Press CTRL+C to end the script.
#


sleep 2
echo -e "\nChecking for required programs ....."
sleep 2

#check for required programs
if command -v sed > /dev/null 2>&1; then
	
	echo -e "\nSUCCESS: sed is installed on this device, continuing ....\n"

else
	echo -e "\nsed NOT FOUND. You must install it to use this script. Exiting ...\n"
	exit

fi
sleep 1

if command -v stdbuf > /dev/null 2>&1; then
	
	echo -e "\nSUCCESS: stdbuf is installed on this device, continuing ....\n"

else
	echo -e "\nstdbuf NOT FOUND. You must install it on this device to use this script. Exiting ...\n"
	exit

fi
sleep 2


echo -e "\n\nStarting HID (Human Interface Device) monitoring script. Any USB events involving an "HID" device will show below:\n\n"
echo -e "\n\nYou can stop the script by pressing CTRL+C\n\n"
sleep 3

while read -r line; do
	
	#grep for USB up to last "/", then CUT only for path to get rid of excess
	just_device_directory="$(echo "$line" | grep -Eo "\/usb.*\/" | cut -d"/" -f1,2,3,4)"

	#if the path contains ':', its too long, shorten by 1 field
	if echo "$just_device_directory" | grep -q ":"; then 

		just_device_directory="$(echo "$just_device_directory" | cut -d"/" -f1,2,3)"
	fi   		


	full_path="/sys/bus/usb/devices"$just_device_directory""


 	device_manufacturer="$(cat "$full_path"/manufacturer)"

	echo ""$line" ----- "$device_manufacturer""


done < <(/usr/bin/udevadm monitor | stdbuf -oL grep -i '(hid)') 
