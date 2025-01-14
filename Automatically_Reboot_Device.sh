#!/bin/bash

#     BashScripts.com  
#     Github: https://github.com/BashScripts-com
#		
#        Summary: Automatically reboot your router/device if it loses internet (after a certain amount of failed pings, reboot device).
#		  Can be run INTERACTIVELY (from terminal) with the TERMINAL argument when starting script. Otherwise by default
#		  it runs NON-INTERACTIVELY (run from crontab, SystemD, etc.)
#
#		      Requirements: 1) Ping 
#		    		    2) ability to execute REBOOT command without password (edit sudoers file 
#		      		    or run as ROOT if necessary)
#
#
#	This script repeatedly "pings" a server every 60 seconds. If the ping fails, we write the result to a temporary file 
#	and start counting failed pings (but now we ping every 10 seconds). If the failed ping count reaches X pings, we
#	reboot the device. This would mean X failed pings * 10 seconds of downtime. The script will ask you the # of failed pings you want
#	before reboot.
#
#	VARIABLE YOU MUST SET BELOW:
#		1) The current server to ping is OPENDNS (208.67.222.222). You can change it below.
#		2) The directory you want to write to whenever there is a REBOOT (a file keeps track of reboots)	
#		3) # of failed pings until reboot (we wait 10 seconds in between each of these pings)
#
#	Remember, you can set up a crontab entry "@reboot" for the script so that it automatically starts after every reboot
#	====> alternatively, use SystemD if you prefer.
#
#


#DIRECTORY where the file with "reboot times/dates" will be written to so you know when the device rebooted
REBOOT_TIMES_DIRECTORY="/home/$USER"

#Hardcoded number of failed pings you want if NOT running interactively (from terminal)
HARDCODED_NUMBER_OF_PINGS="15"

#IP that we will ping (currently using OpenDNS)
PING_TARGET="208.67.222.222"





#if directory provided does not exist, exit script
if [[ ! -d "$REBOOT_TIMES_DIRECTORY" ]]; then

	echo -e "\n\nREBOOT_TIMES_DIRECTORY not found. Set this inside the script! This is where we write the reboot dates/times!\n\n"

	exit
fi


DATE="$(date +%d-%b-%Y)"

RESULTS_DIRECTORY="/tmp/uptime_monitoring/results/${DATE}"

if [[ ! -d "$RESULTS_DIRECTORY" ]]; then
	mkdir -p "$RESULTS_DIRECTORY"
fi

2>> "$RESULTS_DIRECTORY"/error_log.txt






INTERACTIVE_TERMINAL_PROMPT='(terminal|Terminal|TERMINAL)'

if [[ "$1" =~ $INTERACTIVE_TERMINAL_PROMPT ]]; then

	echo -e "\n\nAuto_Reboot_Device.sh script starting ....."
	sleep 3
	echo -e "\n\nThis script will ping a DNS server (OpenDNS) every 60 seconds. If ping fails,"
	echo -e "we start a countdown timer. If ping still down after X pings, we reboot the device\n"
	sleep 2
	read -p "How many failed pings should we execute before rebooting the device? " number_of_pings
	sleep 1
	echo -e "\n\nWaiting "$number_of_pings" failed pings then rebooting, with 10 seconds between each ping\n\n"
	sleep 3
	echo -e "\n\nIf the device reboots, we will write the time to: "$REBOOT_TIMES_DIRECTORY"\n\n"
	echo -e "\n\nPress CTRL+C to stop the script.\n\n"
	sleep 3

	#We wait 10 seconds in between each of these pings, so total time is # of pings times 10 seconds
	NUMBER_OF_PINGS_UNTIL_REBOOT="$number_of_pings"

    else

	NUMBER_OF_PINGS_UNTIL_REBOOT="$HARDCODED_NUMBER_OF_PINGS"


fi





#sleep for three minutes before starting script, because we auto-start script on router @REBOOT
#this way we give the router some time (3 minutes) to finish starting up and loading programs, dhcp, etc.
#we're pinging OpenDNS (208.67.222.222)
sleep 180


#run the ping tests in a continuous loop

i=0

while [[ "$i" -lt "$NUMBER_OF_PINGS_UNTIL_REBOOT" ]];
	do
		#sleep for 60 seconds at start of loop
		sleep 60
		if ping -c1 "$PING_TARGET" > /dev/null 2>&1; then
			 #if ping succeeded, go back up top to beginning of loop
			 i=0
			 continue
		else
			 #ping failed, set i to zero and start counting failures every 10 seconds
			 echo "PRIMARY ping failed: "$(date +%H-%M-%S)"" >> "$RESULTS_DIRECTORY"/downtime.txt
			 echo "PRIMARY ping failed: "$(date +%H-%M-%S)""

				 while [[ "$i" -lt "$NUMBER_OF_PINGS_UNTIL_REBOOT" ]];
				 	sleep 10
					do
					 if ping -c1 "$PING_TARGET" > /dev/null 2>&1; then
						  #secondary ping succeeded, break out of mini counting loop to finish main loop
						  i=0	
						  break
					 else
						  #secondary ping failed, increment i by 1
						  echo "SECONDARY ping failed: "$(date +%H-%M-%S)"" >> "$RESULTS_DIRECTORY"/downtime.txt
						  echo "SECONDARY ping failed: "$(date +%H-%M-%S)""
						  ((i++))

						  	if [[ "$i" -ge "$NUMBER_OF_PINGS_UNTIL_REBOOT" ]]; then
							#after X consecutive fails in a row, sleep then reboot
							#echo to REBOOT_TIMES_DIRECTORY that we are about to REBOOT
							echo ""$NUMBER_OF_PINGS_UNTIL_REBOOT" Pings in a row failed, rebooting: "$(date +%d-%b-%Y)" --- "$(date +%H-%M-%S)"" >> "$REBOOT_TIMES_DIRECTORY"/REBOOT_TIMES.txt
							echo ""$NUMBER_OF_PINGS_UNTIL_REBOOT" Pings in a row failed, rebooting: "$(date +%d-%b-%Y)" --- "$(date +%H-%M-%S)""	
							sleep 10
							/usr/sbin/reboot

							fi

					 fi
				  done


		fi

done
		
