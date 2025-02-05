#!/bin/bash
#
#        BashScripts.com  
#        Github: https://github.com/BashScripts-com
# 
#
#    		Summary:  Capture traffic on a REMOTE device and view it LOCALLY on your computer via WIRESHARK in real-time.
#    		This captures all traffic except SSH traffic (otherwise you would capture your own ssh session)
#
#      		Requirements:   1) Wireshark installed on LOCAL DEVICE (your computer)
#		     		2) Tcpdump installed on REMOTE DEVICE (router, etc.)
#		     	 	3) SSH already setup between the devices
#
#     		Run the script on your LOCAL device (i.e. computer). The script will prompt you to enter the remote device IP, 
#     		the remote interface to listen on, capture snaplength, and specific host to filter (optional)


WIRESHARK_NAMED_PIPE="/tmp/wireshark_named_pipe"

echo ""
echo "Remote wireshark script starting ... When you are finished, press CTRL+C after closing Wireshark to fully exit the script!"
sleep 3
echo ""
read -p "What remote device are we SSH'ing into (format: username@ipaddress  ex: username@1.1.1.1)? " device
echo ""
sleep 2
echo "SSH'ing into "$device""
echo ""
sleep 2
read -p "What remote interface should we capture on (eth0, eth1, etc.)? " interface
echo ""
sleep 2
echo "Capturing on interface "$interface""
echo ""
sleep 2
read -p "What snaplength should we use (type 0 for no limit)? " snaplength
echo ""
sleep 2
echo "Snaplength size is "$snaplength""
echo ""
sleep 2
read -p "Filter for a specific host ? (enter IP address)(just press ENTER if you don't want a specific host and want all traffic instead) " filter_host
sleep 2
echo -e "\nOnly capture traffic for "${filter_host:-NO_HOST_ENTERED_SO_CAPTURING_ALL_HOSTS}""
echo ""


sleep 2
echo -e "\nChecking for required programs ....."
sleep 2

#check for required programs
if command -v wireshark > /dev/null 2>&1; then
	echo -e "\nSUCCESS: Wireshark is installed on this device, continuing ....\n"
 else
	echo -e "\nWireshark NOT FOUND. You must install it to use this script. Exiting ...\n"
	exit
fi
sleep 1

if ssh "$device" "command -v tcpdump" > /dev/null 2>&1; then
	echo -e "\nSUCCESS: TCPDUMP is installed on the remote device, continuing ....\n"
else
	echo -e "\nTCPDUMP NOT FOUND. You must install it on the remote device to use this script. Exiting ...\n"
	exit
fi
sleep 2


# ON LOCAL COMPUTER: if named pipe does not already exist, then create it in /tmp
if [[ ! -e "$WIRESHARK_NAMED_PIPE" ]]; then
 mkfifo "$WIRESHARK_NAMED_PIPE"
fi

#ON LOCAL COMPUTER: run wireshark and start reading from named pipe. Put into background"
/usr/bin/wireshark -k -i "$WIRESHARK_NAMED_PIPE" &

echo "starting Wireshark and reading from namedpipe"
echo ""
sleep 3

#CHECK IF FILTER_HOST VARIABLE SET, ADJUST TCPDUMP COMMAND ACCORDINGLY

if [[ ! -z "$filter_host" ]]; then

         ssh "$device" "/usr/sbin/tcpdump -i '"$interface"' -s'"$snaplength"' -n not port 22 and host '"$filter_host"' -w -" > \
		 "$WIRESHARK_NAMED_PIPE" 2> /dev/null || echo -e "\n\nERROR: Could not SSH into the device. Something went wrong!\n"

else

## NOTE: looks like we cannot use '-t' because wireshark ERRORS when -t is added ****
#apparently we DON'T need "sudo" if we use the full binary path
ssh "$device" "/usr/sbin/tcpdump -i '"$interface"' -s'"$snaplength"' -n not port 22 -w -" > \
	"$WIRESHARK_NAMED_PIPE" 2> /dev/null || echo -e "\n\nERROR: Could not SSH into the device. Something went wrong!\n"

fi

#remove named pipe
rm "$WIRESHARK_NAMED_PIPE"

sleep 2
echo ""
echo "SCRIPT COMPLETED -- if the script hangs, press CTRL+C to exit and return to your terminal."
echo ""
sleep 2
