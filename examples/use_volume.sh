#!/bin/bash

set -euo pipefail

DOCKER_VOL_SRC="/var/lib/docker/volumes"
DOCKER_VOL_DST="/mnt/block/volumes"
BACKUP_DIR="/var/lib/docker/volumes.bak"

# echo ">>> Stopping Docker..."
sudo systemctl stop docker

# echo ">>> Creating destination directory at $DOCKER_VOL_DST..."
sudo mkdir -p "$DOCKER_VOL_DST"

# echo ">>> Copying existing Docker volumes to destination..."
sudo rsync -aP "$DOCKER_VOL_SRC/" "$DOCKER_VOL_DST/"

# echo ">>> Backing up original Docker volumes directory to $BACKUP_DIR..."
sudo mv "$DOCKER_VOL_SRC" "$BACKUP_DIR"

# echo ">>> Creating empty mount point at $DOCKER_VOL_SRC..."
sudo mkdir -p "$DOCKER_VOL_SRC"

# echo ">>> Bind mounting $DOCKER_VOL_DST to $DOCKER_VOL_SRC..."
sudo mount --bind "$DOCKER_VOL_DST" "$DOCKER_VOL_SRC"

# echo ">>> Adding bind mount to /etc/fstab (if not already present)..."
BIND_ENTRY="$DOCKER_VOL_DST $DOCKER_VOL_SRC none bind 0 0"
if ! grep -Fxq "$BIND_ENTRY" /etc/fstab; then
  echo "$BIND_ENTRY" | sudo tee -a /etc/fstab > /dev/null
else
  echo ">>> Entry already exists in /etc/fstab, skipping."
fi

# echo ">>> Starting Docker again..."
sudo systemctl start docker

# echo "✅ Done. Docker volumes are now stored in $DOCKER_VOL_DST"
