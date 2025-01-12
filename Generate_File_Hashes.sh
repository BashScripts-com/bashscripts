#!/bin/bash
#
#        BashScripts.com  
#        Github: https://github.com/BashScripts-com
#
#
#		Summary: Generate a list of hashes for all files in a given directory
#			
#			Requirements: md5sum
#
#
#		Instructions: The script will prompt you for the directory you want to hash. Enter
#		the FULL path (i.e. /home/user/directory). The script works recursively so it will also
#		hash all files in directories inside of the directory you provided.
#		
#		The script will output the results (file hashes) in a single file in the PWD (where you started the script from)
#
#



DATE="$(date +%d-%b-%Y--%H-%M-%S)"

read -p "Which directory do you want hashes for (enter FULL path i.e. /home/user/folder) ?  " DIR_TO_HASH
sleep 2
echo -e "\n\n"
echo -e "\n\nGetting hashes for:  "$DIR_TO_HASH" ......"
sleep 2
echo -e "\n\nResults will appear in a file in your PWD (current working directory below)!\n\n"



HASH_LIST="$PWD/file_hashes_$DATE"

#test if directory exists, otherwise exit
if [[ ! -d "$DIR_TO_HASH" ]]; then
	
	echo -e "\n\nNOT A VALID DIRECTORY ... exiting script!\n\n"
	
	exit
fi


find "${DIR_TO_HASH:?error finding directory to create hash list}" -type f -exec md5sum {} + > "${HASH_LIST:?error creating hash list file}"



