#!/bin/bash

libvritdState=0
displayM="sddm" # Display manager

# Get service status
getStatus() {
  status=$( systemctl status $1.service|grep inactive )
  if [[ $status == "" ]]; then
    echo 1
  else
    echo 0
  fi
}

if [[ $(getStatus $libvirtd) == 1 ]]; then # Check if libvirtd is running
  echo "Stopping libvirtd... "
  systemctl stop libvirtd.service
  while [[ $(getStatus libvirtd) == 1 ]]; do
    sleep 1s
  done
  libvirtdState=1
  echo "done."
fi

echo "status: " $( getStatus $displayM )
