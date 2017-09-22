#!/bin/bash

set -x

# Initialising necessary variables
libvritdState=0
displayM="sddm" # Display manager
Vdevice="0000:01:00.0" # Graphics card
Adevice="0000:01:00.1" # Built in audio device
pwd=$( pwd )

# Get service status
getStatus() {
  status=$( systemctl status $1.service|grep inactive )
  if [[ $status == "" ]]; then
    echo 1
  else
    echo 0
  fi
}

loadDrivers() {
	for dev in "$@";do
		lsmod=$(lsmod|grep $dev)
		if ($lsmod != ""); then
			sudo modprobe $dev
		fi
	done
}

if [[ $(getStatus libvirtd) == 1 ]]; then # Check if libvirtd is running
  echo "Stopping libvirtd... "
  systemctl stop libvirtd.service
  while [[ $(getStatus libvirtd) == 1 ]]; do
    sleep 1s
  done
  libvirtdState=1
  echo "done."
fi

if [[ $(getStatus $displayM) == 1 ]]; then # Check if Display manager is running
	echo "Stopping $displayM... "
	systemctl stop $displayM.service
	while [[ $(getStatus $displayM) == 1 ]]; do
		sleep 1s
	done
	echo "done."
fi

echo -ne "Loading necessary drivers... "
loadDrivers vfio_pci amdgpu
echo "Done"

echo "Switching GPU... "
if [[ $libvirtdState != 0 ]]; then
	sudo -i source $pwd/vfio-unbind.sh $Vdevice $Adevice
else
	sudo -i source $pwd/vfio-bind.sh $Vdevice $Adevice
fi
echo "done"

echo "Starting $displayM... "
systemctl start $displayM.service
echo "done"

set +x
