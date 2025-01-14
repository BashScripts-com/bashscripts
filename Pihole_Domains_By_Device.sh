#!/bin/bash
#
#     BashScripts.com  
#     Github: https://github.com/BashScripts-com
#		
#        Summary: Get all pihole DNS queries from today's log for a particular device on your network.
#
#			Required Programs: Pihole, SSH
#
#        The script will prompt you for: 
#        			
#        			1) the device/client ip or hostname you want DNS queries for 
#				2) the pihole ip address (for SSH)
#
#		The script will SSH into your pihole, parse the pihole.log list, and display a big list DNS lookups from whichever
#		client/device you provided. It will list the DNS queries by count in reverse descending order. 
#	
#
#


echo -e "\n\nPIHOLE LOOKUP script -- get a device's DNS queries from today's pihole.log file"
sleep 2
echo -e "\n\nWe'll show all DNS lookups in reverse decending order (highest to lowest)\n"
sleep 1
read -p "Enter the client/device IP or hostname whose DNS lookups you want: "  device_ip
echo ""
read -p "Enter pihole SSH information (ex: user@x.x.x.x): " pihole_ip

sleep 1
echo -e "\nChecking for required programs ....."
sleep 2

#check for required programs
if ssh "$pihole_ip" "command -v pihole" > /dev/null 2>&1; then
	echo -e "\nSUCCESS: PIHOLE is installed on the remote device, continuing ....\n"
else
	echo -e "\nPIHOLE NOT FOUND. You must install it on the remote device to use this script. Exiting ...\n"
	exit

fi
sleep 2
echo -e "\nSearching DNS queries from device: "$device_ip"\n"
sleep 3


#use REV trick to get the 3rd column from the end
ssh "$pihole_ip" 'echo -e "\n\nSearching CURRENT DAY pihole logs\n\n"; sudo grep -F "query[" /var/log/pihole/pihole.log \
	| sudo grep -F "'$device_ip'" | rev | cut -d" " -f3 | rev | sort | uniq -c | sort -nr; echo -e "\n\n";' ||\
	echo -e "\n\nERROR: Could not SSH into the device. Something went wrong!\n"
	
sleep 3
echo -e "\n\nFINISHED!\n\n"
