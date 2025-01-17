#!/bin/bash
#
#   BashScripts.com  
#   Github: https://github.com/BashScripts-com
#    
#
#   	 Summary:  Get the size of one or more directories and sort by size.
#   	 You can choose to get the size of just that 1 folder, or ALL folders inside recursively.
#	 You will also be asked if you want to run the script as your normal user or with SUDO (to be
#	 able to search privileged directories)
#
#


sleep 1
echo -e "\n\nStarting directory size script. Enter the FULL path of the target Directory (i.e. /home/user/folder):  \n"
read dir_to_size
sleep 2

if [[ ! -d "$dir_to_size" ]]; then
	echo -e "\n\nNot a valid directory! Exiting script!\n\n"
	sleep 2
	exit
fi

echo -e "\nDo you want to search privileged directories? (This requires ROOT or SUDO privileges)\n"
sleep 2


options=("Search privileged directories -- run with root/sudo" "Just run as normal user" "Exit")

select choice in "${options[@]}"; do
  case $choice in
    "Search privileged directories -- run with root/sudo")

    	user_selection="sudo"
	echo -e "\nRunning the du size command with SUDO\n"
	sleep 1
	break
      ;;
    "Just run as normal user")

	user_selection="normal user"
	echo -e "\nRunning the du size command as normal user\n"
	sleep 1
	break
      ;;
    "Exit")
      exit
      ;;
    *)
        echo "Invalid option -- select 1, 2, or 3"
      ;;
  esac
done


sleep 2
echo -e "\n\nGetting the size of $dir_to_size"
sleep 2
echo -e "\n\nDo you want the size of that directory and the size of ALL folders inside of it too, or just the size of that one directory?\n\n"
sleep 2

options=("ALL directories recursively" "Just that ONE directory" "Exit")

select choice in "${options[@]}"; do
  case $choice in
    "ALL directories recursively")
	    
	echo -e "\nGetting size of this directory and ALL directories inside of it, sorted from largest to smallest\n"
	sleep 1

        if [[ "$user_selection" == "sudo" ]]; then
		sudo find "$dir_to_size" -type d -exec du -h {} \; | sort -hr -k1,1
        else
		find "$dir_to_size" -type d -exec du -h {} \; | sort -hr -k1,1
	fi
	;;

    "Just that ONE directory")
      
	echo -e "\nGetting size of just this one directory\n"
	sleep 1
	
	if [[ "$user_selection" == "sudo" ]]; then
		sudo du -h --max-depth=0 "$dir_to_size"
    	else
		du -h --max-depth=0 "$dir_to_size"
	fi		
      ;;
    Exit)
      exit
      ;;
    *)
        echo "Invalid option -- select 1, 2, or 3"
      ;;
  esac
done

sleep 2
echo -e "\n\nScript complete! The sizes are shown above.\n"
sleep 2
