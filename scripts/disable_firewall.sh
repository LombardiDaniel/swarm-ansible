#!/bin/bash

set -e

if ! which -s iptables > /dev/null; then
    echo "iptables is not installed"
    exit 0
fi

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F

sudo systemctl disable iptables

echo "firewall disabled successfully"
