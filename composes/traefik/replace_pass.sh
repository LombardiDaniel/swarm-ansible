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

hash=$(htpasswd -nBb admin $password | sed -e s/\\$/\\$\\$/g)

awk -v hash="$hash" '{gsub("MATCH_FOR_AWK", hash)}1' docker-compose.template.yml > docker-compose.yml
