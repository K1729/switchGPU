#!/bin/bash

modprobe -r vfio_pci

for dev in "$@"; do
    vendor=$(cat /sys/bus/pci/devices/$dev/vendor)
    device=$(cat /sys/bus/pci/devices/$dev/device)
    echo "Remove PCI device"
    echo 1 > /sys/bus/pci/devices/${dev}/remove
    while [[ -e "/sys/bus/pci/devices/${dev}" ]]; do
        sleep 0.1
    done
done
echo "Rescanning..."
echo 1 > /sys/bus/pci/rescan
