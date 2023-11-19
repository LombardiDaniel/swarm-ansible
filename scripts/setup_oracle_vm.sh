#!/bin/bash

set -e

sudo apt-get update -y
sudo NEEDRESTART_MODE=a apt-get upgrade -y

# Docker Swarm:
sudo apt-get install vim cron apache2-utils -y
curl -fsSL https://get.docker.com -o get-docker.sh
chmod +x get-docker.sh
sudo ./get-docker.sh
rm get-docker.sh
# sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
# apt-cache policy docker-ce
sudo usermod -aG docker $USER
sudo usermod -aG docker $REMOTE_USER

echo "docker installed successfully"