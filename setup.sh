#!/bin/bash

# Interrupt handler
trap '{ echo "Hey, you pressed Ctrl-C.  Time to quit." ; kill "$infiloop"; exit 1; }' INT

if [ $(id -u) = 0 ]; then
   echo "This script changes your users gsettings and should thus not be run as root!"
   echo "You need to enter your password only one time"
   exit 1
fi

###
# Make infinite loop for sudo, so I don't have to enter password again
###
sudo echo "Enter the password to start the script!"
while :; do sudo -v; sleep 1; done &
infiloop=$!


sudo rpm-ostree override remove virtualbox-guest-additions

# Kill infinite sudo loop
kill "$infiloop"
