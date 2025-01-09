#!/bin/bash

###########     BASHSCRIPTS.com    ##############
##
##		Summary: Monitor website uptime/errors using CURL
#
#		Requirements: CURL
#
#		Simply run the script in your terminal. 
#		
#		The script will ask you for: 
#			
#			1) website address, just enter the base domain name (i.e. google.com)
#			2) how often to check (# of minutes)
#	
#		Using the curl command we just get the "response code". Code 200 means OK/NORMAL. Anything else is usually an error. 
#		Everytime there is an error, we write it to STDOUT (the terminal) and into a file in the Present Working 
#		Directory (wherever you ran the script) along with the exact time and error code. The script continues in a loop
#		until you exit (CTRL+C)
#

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin




DATE_SHORT="$(date +%d-%b-%Y)"
RESULTS_FILE="$PWD/website_errors_"$DATE_SHORT".txt"



read -p "Enter the website address you want to monitor (example: google.com) " website_address
echo -e "\n\nYou entered "$website_address"\n\n"
read -p "How often do you want to check (enter # of minutes)? " minutes
echo -e "\n\nYou entered "$minutes" minute(s)\n\n"

echo -e "\n\nBeginning script. Curl'ing "$website_address" every "$minutes" minute(s). Also writing errors to a file in the PWD.\n\n"


#convert minutes to seconds
SLEEP_TIME="$(($minutes * 60))"


while true; do


##  curl just for response code
##  -o /dev/null = do not display the body
##  -s = Don not show any download progress
##  -w "%{http_code}" = Write the http response code to stdout after exit
##  -L = follow all redirects

  #save response code to variable

  WEBSITE_RESPONSE="$(timeout 25 curl -sL -o /dev/null -I -w "%{http_code}" http://"${website_address}")"

  

#if response code is NOT successful (200 means success), then output to STDOUT and a file in PWD

  if [[ ! "$WEBSITE_RESPONSE" -eq 200 ]]; then

    #write error to STDOUT	  
    echo "ERROR -- "$website_address" --- response code: "$WEBSITE_RESPONSE" --- "$(date +%H-%M-%S)""
    
    #also write error to file
    echo "ERROR -- "$website_address" --- response code: "$WEBSITE_RESPONSE" --- "$(date +%H-%M-%S)"" >> "${RESULTS_FILE}"

  fi

  #sleep for chosen amount of time (converted to seconds) then repeat loop
  sleep "$SLEEP_TIME"


 done
