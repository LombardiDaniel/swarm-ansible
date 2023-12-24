#!/bin/bash

set -e

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F

sudo systemctl disable iptables

echo "firewall disabled successfully"
