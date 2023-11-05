#!/bin/bash

registry_password=""
# Check if an argument was provided
if [ $# -lt 1 ]; then
  # Set default password
  registry_password="adminPass"
else
  # Use the provided argument as the password
  registry_password=$1
fi

sudo mkdir /mnt
sudo mkdir /mnt/auth
sudo echo $(htpasswd -nb admin ${registry_password}) > /mnt/auth/registry.password

sudo mkdir /mnt/registry