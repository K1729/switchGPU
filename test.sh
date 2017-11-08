#!/bin/bash

libvirtdState=0

# Get service status
getStatus() {
  status=$( systemctl status $@.service|grep inactive )
  if [[ $status == "" ]]; then
    echo 1
  else
    echo 0
  fi
}

if [[ $(getStatus "libvirtd") == 1 ]]; then
  libvirtdState=1
fi

echo "status: " $libvirtdState
