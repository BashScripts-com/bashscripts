#!/bin/bash
#
#        BashScripts.com  
#        Github: https://github.com/BashScripts-com
#
#
#		Summary:  use NMAP to do a basic discovery scan (-sn) of your networks. Place each subnet/network
#		that you want to scan into the array below (i.e. '192.168.1.1/24'). Replace the example subnets based on
#		your custom environment. The script automatically creates results files/folders in a folder
#		called NMAP_SCAN_SCRIPT in the PWD (wherever you ran the script)
#
#			Requirements:  nmap
#
#
#
#
#
#

# Manually enter the subnets that you want to scan. Each subnet is a separate item in the array
subnets=('192.168.1.1/24' '192.168.2.1/24' '192.168.3.1/24' '192.168.10.1/24' '192.168.20.1/24' '192.168.30.1/24' '192.168.40.1/24')

echo -e "\n\nStarting NMAP HOST SCAN script. We will use the networks you manually entered into the subnets \
array (hardcoded into script)\n\n"
sleep 3

DATE="$(date +%d-%b---%H-%M-%S)"
RESULTS_DIRECTORY="$PWD/nmap_scan_script/results/${DATE}"

if [[ ! -d "$RESULTS_DIRECTORY" ]]; then
	mkdir -m 750 -p "$RESULTS_DIRECTORY"
fi

2>> "$RESULTS_DIRECTORY"/error_stats_logs.txt



#temporary output for that one scan
#put subnets into an array. Loop through each subnet and do the basic discovery NMAP scan
#use string replacement to put subnet into actual output filename


for subnet in "${subnets[@]}";
	do
		filename_subnet="${subnet%%/*}"
		sudo nmap -sn "$subnet" > "$RESULTS_DIRECTORY"/temp_"${filename_subnet}".txt
		echo '===========================================' >> "$RESULTS_DIRECTORY"/temp_"${filename_subnet}".txt
	done


#full running list of appended scans (cat temp results file into one running file)
for subnet in "${subnets[@]}";
	do
		filename_subnet="${subnet%%/*}"
		cat "$RESULTS_DIRECTORY"/temp_"${filename_subnet}".txt >> "$RESULTS_DIRECTORY"/full_"${filename_subnet}".txt
	done


#final aggregate count files
for subnet in "${subnets[@]}";
	do
		filename_subnet="${subnet%%/*}"
		cat "$RESULTS_DIRECTORY"/full_"${filename_subnet}".txt | grep 'Nmap scan report for' | sort | uniq -c | sort -nr > "$RESULTS_DIRECTORY"/FINAL_"${filename_subnet}".txt
		echo '' >> "$RESULTS_DIRECTORY"/FINAL_"${filename_subnet}".txt
	done

echo -e "\n\nScript complete! Results will be in a folder called nmap_scan_script in the PWD (current working directory)\n\n"
sleep 3



