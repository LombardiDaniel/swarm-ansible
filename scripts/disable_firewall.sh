#!/bin/bash

set -e

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F

echo "firewall disabled successfully"