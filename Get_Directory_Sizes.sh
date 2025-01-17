#!/bin/bash
#
#   BashScripts.com  
#   Github: https://github.com/BashScripts-com
#    
#
#   	 Summary:  Get the size of one or more directories and sort by size.
#   	 You can choose to get the size of just that 1 folder, or ALL folders inside recursively.
#
#
#


sleep 1
echo -e "\n\nStarting directory size script. Enter the FULL path of the target Directory (i.e. /home/user/folder):  \n\n"
read dir_to_size

if [[ ! -d "$dir_to_size" ]]; then
	echo -e "\n\nNot a valid directory! Exiting script!\n\n"
	sleep 2
	exit
fi

sleep 2
echo -e "\n\nGetting the size of $dir_to_size"
sleep 2
echo -e "\n\nDo you want the size of that directory and the size of ALL folders inside of it too, or just the size of that one directory?\n"
sleep 2

options=("ALL directories recursively" "Just that ONE directory" "Exit")

select choice in "${options[@]}"; do
  case $choice in
    "ALL directories recursively")
	
	echo -e "\nGetting size of this directory and ALL directories inside of it, sorted from largest to smallest\n"
	sleep 1
	find "$dir_to_size" -type d -exec du -h {} \; | sort -hr -k1,1
      ;;
    "Just that ONE directory")
      
	echo -e "\nGetting size of just this one directory\n"
	sleep 1
	du -h --max-depth=0 "$dir_to_size"	    
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

