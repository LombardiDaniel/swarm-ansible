#!/bin/bash

set -e

sudo apt-get update -y
sudo NEEDRESTART_MODE=a apt-get upgrade -y

# Docker Swarm:
sudo apt-get install vim cron -y
curl -fsSL test.docker.com -o get-docker.sh && sh get-docker.sh && rm get-docker.sh
sudo usermod -aG docker $USER

echo "docker installed successfully"