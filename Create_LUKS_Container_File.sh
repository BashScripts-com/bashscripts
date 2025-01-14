#!/bin/bash

#     BashScripts.com  
#     Github: https://github.com/BashScripts-com
#		
#        Summary: Create an encrypted LUKS container file with an EXT4 filesystem in it.
#
#
#		      Required Programs: cryptsetup, dd 
#
#	This script creates an ENCRYPTED LUKS CONTAINER called encrypted_container.img in the PWD (current working directory -- wherever 
#	you initialize this script from). It uses "dd" to write an empty container. Then it uses cryptsetup to encrypt the container with 
#	LUKS encryption. Finally we create an EXT4 file system inside the container. The script will ask you how big you want the 
#	container to be (i.e. 200M, 800M, 5G, etc.). 
#
#	Don't forget to MOUNT/UNMOUNT and then CLOSE the container when you are finished!
#
#


	sleep 1
	echo -e "\nChecking for required programs ....."
	sleep 2

	#check for required programs
	if command -v cryptsetup > /dev/null 2>&1; then
		echo -e "\nSUCCESS: cryptsetup is installed on this device, continuing ....\n"
	else
		echo -e "\ncryptsetup NOT FOUND. You must install it to use this script. Exiting ...\n"
	exit
	fi

	sleep 1

	if command -v dd > /dev/null 2>&1; then
		echo -e "\nSUCCESS: dd is installed on this device, continuing ....\n"

	else
		echo -e "\ndd NOT FOUND. You must install it on this device to use this script. Exiting ...\n"
	exit
	fi
	sleep 2

	echo -e "\n\n***** Creating an empty container called "encrypted_container.img" with DD.\n\n"
	sleep 3
	read -p "***** How big do you want the container to be? (ex: 100M, 500M, 2G, etc.) " container_size
	echo -e "\n\n***** You entered "$container_size""
	sleep 3
	echo -e "\n\n***** Now creating the container in the PWD (present working directory)\n\n"
	sleep 3

	#create the container using dd with zeros
	if dd if=/dev/zero of=encrypted_container.img bs=1 count=0 seek="$container_size"; then
	       
		echo -e "\n\n***** encrypted_container.img created !"

	     else 

		echo -e "\n\n***** ERROR! - exiting script\n\n" && exit

	fi		


	sleep 3
	echo -e "\n\n***** Now encrypting the container with Cryptsetup. Type YES to continue and create an ENCRYPTION PASSWORD:\n"
	sleep 3


	if cryptsetup luksFormat encrypted_container.img; then
	       
		echo -e "\n\n***** encrypted_container.img successfully encrypted!\n\n"
	       
	   else	
			
		echo -e "\n\nERROR -- exiting\n\n" && exit 

	fi


	sleep 3
	echo -e "\n\n***** Now it's time to create the EXT4 filesystem. Enter the encryption password you just created to unlock the container"
	echo -e "***** BUT you MAY need to enter your SUDO password FIRST, depending on which password prompt shows below:\n\n"	

	
	if sudo cryptsetup luksOpen encrypted_container.img temp_container; then

		echo -e "\n\nencrypted container OPENED and assigned the temporary name "temp_container"\n\n"

	      else

		echo -e "\n\nERROR! - exiting!" && exit

	fi

	sleep 3
	echo -e "\n\n***** Creating the EXT4 filesystem ....\n\n"
	sleep 3

	if sudo mkfs.ext4 /dev/mapper/temp_container; then

		echo -e "\n\n***** EXT4 filesystem successfully created on /dev/mapper/temp_container\n\n"
		
	      else

		echo -e "\n\nERROR - exiting!\n\n" && exit

	fi


	sleep 3
	echo -e "\n\n***** Now you can MOUNT the container (/dev/mapper/temp_container) to a mount point and continue using it"
	echo -e "********** example:  sudo mount /dev/mapper/temp_container /YOUR/MOUNTPOINT/HERE"
	echo -e "***** You may have to change the permissions of the MOUNTPOINT from ROOT to your USER to begin using it"
	echo -e "********** example: sudo chown user:user /YOUR/MOUNTPOINT/HERE\n\n"
	sleep 3
	echo "***** SCRIPT FINISHED. Remember to unmount and close the encrypted container when you are finished!"
	sleep 1
	echo -e "\n***** you can use the following commands to do that:\n\n" 
	echo "************** sudo umount /YOUR/MOUNTPOINT" 
	echo -e "************** sudo cryptsetup luksClose temp_container\n\n"





