#!/bin/bash
#
#   BashScripts.com  
#   Github: https://github.com/BashScripts-com
#    
#
#    Summary:  Check a directory (recursively) for duplicate files. We do this by getting the MD5SUM hash of every file and grepping for
#    	       hashes that appear more than once.
#
#      Requirements: 1) MD5SUM   
#
#      The script will ask you which directory you want to check. It will create a big list of files + hash in your /TMP directory. 
#      It will then output any duplicate files to the terminal (STDOUT).




TEMP_HASH_LIST="/tmp/temp_hash_list.txt"

echo -e "\n"
read -p "Enter the directory you want to check: (/the/full/path)  "  directory_to_check
echo -e "\n\n"
echo -e "checking "$directory_to_check" for duplicate files. Any duplicates will show below!\n\n"


/usr/bin/find "${directory_to_check:?MUST PROVIDE FULL PATH OF A DIRECTORY AS ARGUMENT}"/ -type f -exec /usr/bin/md5sum {} + > "$TEMP_HASH_LIST" 

awk '{print $1}' "$TEMP_HASH_LIST" | sort | uniq -c | while read count hash; do \
	[[ $count -gt 1 ]] && grep -n -- "$hash" "$TEMP_HASH_LIST"; done

echo -e "\n\n"

rm -- "$TEMP_HASH_LIST"



