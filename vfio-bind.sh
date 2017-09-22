#!/bin/bash

modprobe vfio_pci

for dev in "$@"; do
	vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
	device=$(cat /sys/bus/pci/devices/$dev/device)
	echo $vendor $device > /sys/bus/pci/drivers/vfio-pci/new_id
	if [ -e /sys/bus/pci/devices/$dev/driver ]; then
		echo $dev > /sys/bus/pci/devices/$dev/driver/unbind
	fi
	echo $dev > /sys/bus/pci/drivers/vfio-pci/bind
	echo $vendor $device > /sys/bus/pci/drivers/vfio-pci/remove_id
done
