#!/bin/bash

# Backup destination directory
BACKUP_DIR="volumes-backup"
DATE=$(date +%Y%m%d%H%M%S)

# Create the backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# List all Docker volumes
VOLUMES=$(docker volume ls -q)

# Loop through each volume and back it up
for VOLUME in $VOLUMES; do
  echo "Backing up volume: $VOLUME"

  # Define the backup file name (with volume name and timestamp)
  BACKUP_FILE="$BACKUP_DIR/$VOLUME-$DATE.tar.gz"

  # Use a temporary Docker container to back up the volume into a tar file
  docker run --rm -v $VOLUME:/volume -v $BACKUP_DIR:/backup alpine \
    tar czf /backup/$(basename $BACKUP_FILE) -C /volume .

  echo "Backup of volume $VOLUME successful: $BACKUP_FILE"
done

echo "Completed backing up all volumes."
