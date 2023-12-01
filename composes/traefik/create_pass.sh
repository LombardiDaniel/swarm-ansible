#!/bin/bash

password=""
# Check if an argument was provided
if [ $# -lt 1 ]; then
  # Set default password
  password="adminPass"
else
  # Use the provided argument as the password
  password=$1
fi

# We need double "$" so that docker-compose escapes it correctly

echo $(htpasswd -nb admin password) | sed -e s/\\$/\\$\\$/g