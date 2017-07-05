#!/bin/bash

#set -x

# Initialising necessary variables
libvritdState=0
displayM="sddm" # Display manager
Vdevice="0000:01:00.0" # Graphics card
Adevice="0000:01:00.1" # Built in audio device

# Get service status
getStatus() {
  status=$( systemctl status $1.service|grep running )
  if [[ $status != "" ]]; then
    echo 1
  else
    echo 0
  fi
}

loadVfio() {
  status=$( lsmod|grep vfio_pci )
  if [[ $status == "" ]]; then
    modprobe vfio-pci
  fi
}

vfioBind() {
  loadVfio
  for dev in "$@"; do
    vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
    device=$(cat /sys/bus/pci/devices/$dev/device)
    if [ -e /sys/bus/pci/devices/$dev/driver ]; then
      echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
    fi
    echo $vendor $device > /sys/bus/pci/drivers/vfio-pci/new_id
  done
}

rescanGPU() {
  for dev in "$@"; do
    echo 1 > /sys/bus/pci/devices/$dev/remove
  done
  echo 1 > /sys/bus/pci/rescan
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

echo "Switching GPU... "
if [[ $libvirtdState == 1 ]]; then
  sudo -i vfioBind Vdevice Adevice
else
  modprobe -r vfio-pci
  sudo -i rescanGPU Vdevice Adevice
fi
echo "done"

echo "Starting $displayM... "
systemctl start $displayM.service
echo "done"

#set +x
