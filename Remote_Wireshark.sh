#!/bin/bash

# ###############  BASHSCRIPTS.com  #################
# ###################################################
    
#    Summary:  Capture traffic on a REMOTE device and view it LOCALLY on your computer via WIRESHARK in real-time.
#    This captures all traffic except SSH traffic (otherwise you would capture your own ssh session)
#
#      Requirements: 1) Wireshark installed on LOCAL DEVICE (your computer)
#		     2) Tcpdump installed on REMOTE DEVICE (router, etc.)
#		     3) SSH already setup between the devices
#
#     The script will prompt you to enter the remote device IP, the remote interface to listen on, capture snaplength, and specific host to filter (optional)




PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


WIRESHARK_NAMED_PIPE="/tmp/wireshark_named_pipe"


echo "Remote wireshark script starting ..."
echo ""
read -p "What remote device are we SSH'ing into (format: username@ipaddress  ex: username@1.1.1.1)? " device
echo "SSH'ing into "$device""
echo ""
read -p "What remote interface should we capture on (eth0, eth1, etc.)? " interface
echo "capturing on interface "$interface""
echo ""
read -p "What snaplength should we use (type 0 for no limit)? " snaplength
echo "snaplength size is "$snaplength""
echo ""
#read -p "How many packets should we capture before exiting ? " packet_count
#echo "capturing "$packet_count" packets"
#echo ""


read -p "Filter for a specific host ? (enter IP address)(just press ENTER if you don't want a specific host and want all traffic instead) " filter_host
echo "only capture traffic for "${filter_host:-NO_HOST_ENTERED_SO_CAPTURING_ALL_HOSTS}""
echo ""


# ON LOCAL COMPUTER: if named pipe does not already exist, then create it in /tmp
if [[ ! -e "$WIRESHARK_NAMED_PIPE" ]]; then
 mkfifo "$WIRESHARK_NAMED_PIPE"
fi

#ON LOCAL COMPUTER: run wireshark and start reading from named pipe. Put into background"
/usr/bin/wireshark -k -i "$WIRESHARK_NAMED_PIPE" &

echo "starting Wireshark and reading from namedpipe"
echo ""

#CHECK IF FILTER_HOST VARIABLE SET, ADJUST TCPDUMP COMMAND ACCORDINGLY

if [[ ! -z "$filter_host" ]]; then

         ssh "$device" "/usr/sbin/tcpdump -i '"$interface"' -s'"$snaplength"' -n not port 22 and host '"$filter_host"' -w -" > \
		 "$WIRESHARK_NAMED_PIPE" 2> /dev/null 

else

## NOTE: looks like we cannot use '-t' because wireshark ERRORS when -t is added ****
#apparently we DON'T need "sudo" if we use the full binary path
ssh "$device" "/usr/sbin/tcpdump -i '"$interface"' -s'"$snaplength"' -n not port 22 -w -" > \
	"$WIRESHARK_NAMED_PIPE" 2> /dev/null

fi


#remove named pipe
rm "$WIRESHARK_NAMED_PIPE"

echo ""
echo "COMPLETED"
echo ""


