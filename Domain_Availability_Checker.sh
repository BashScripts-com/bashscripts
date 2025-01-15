#!/bin/bash
#
#        BashScripts.com  
#        Github: https://github.com/BashScripts-com
#
#
#		Summary: Search for available .COM domains from the command line.
#		NOTE: This script only works for .COM right now. Let us know if you want us to
#		add more extensions. 
#			
#			Requirements: WHOIS (available in most repositories)
#
#
#		Instructions: Provide a list of .COM domains in a separate file (one domain per line).
#		Run the script from the terminal. It will ask you for the location of your domain
#		list file. Enter the FULL path (i.e. /home/user/domains.txt).
#
#		The script will output AVAILABLE domains to the terminal (STDOUT) AND also create
#		a results folder in the PWD (wherever you ran the script from).
#		
#
#


DATE="$(date +%d-%b---%H-%M-%S)"


RESULTS_DIRECTORY="$PWD/domain_availability_script"
FINAL_OUTPUT="$RESULTS_DIRECTORY"/"$DATE"_final_domain_availability.txt


sleep 1
echo -e "\nChecking for required programs ....."
sleep 2

#check for required programs
if command -v whois > /dev/null 2>&1; then
	echo -e "\nSUCCESS: whois is installed on this device, continuing ....\n"
else
	echo -e "\nwhois NOT FOUND. You must install it to use this script. Exiting ...\n"
	exit
fi
sleep 1


echo -e "\n\nStarting .COM Domain Lookup script .....\n\n"
sleep 3
read -p "enter FULL PATH of the FILE with the domains you want to search (ex: /home/user/domains.txt) " domain_name_list
echo -e "\n\n"

sleep 2

if [[ ! -d "$RESULTS_DIRECTORY" ]]; then
	mkdir -p "$RESULTS_DIRECTORY"
fi

2>> "$RESULTS_DIRECTORY"/error_log.txt


#write info to results file
echo ""
echo "AVAILABLE DOMAINS WILL BE SHOWN BELOW:" >> $FINAL_OUTPUT
echo "" >> $FINAL_OUTPUT

#write info to STDOUT/terminal
echo "AVAILABLE DOMAINS:"
echo ""

#using the domain list file provided, do a WHOIS lookup for each domain. Grep for language indicating the domain is available.
#write results to file in PWD and write to STDOUT/terminal
while read -r line;
  do
    (timeout 10 /usr/bin/whois -- "$line" | sed -e 's/\*//g' -e 's/\@//g' -e 's/\!//g' | tr -cd '[:alnum:]\.\- \n' | tr -s ' ' | grep -Fqi "No match for domain") && echo "${line}" >> $FINAL_OUTPUT && echo "$line"
    sleep 2
  done < "$domain_name_list"

echo -e "\n\nScript Complete! If any domains were available, they were listed above and written to a file in your current directory!\n\n"



