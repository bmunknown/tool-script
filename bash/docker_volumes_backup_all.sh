#!/bin/bash

# Backup directory where the backup files will be stored
BACKUP_DIR="/backup/volumes-backup"

# Create the backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Get the current date in the format YYYY-MM-DD (e.g., 2025-01-03)
BACKUP_DATE=$(date +"%Y-%m-%d")

# Create a subdirectory with the current date
BACKUP_DATE_DIR="$BACKUP_DIR/$BACKUP_DATE"
mkdir -p "$BACKUP_DATE_DIR"

# Loop through each Docker volume and create a backup
for VOLUME in $(docker volume ls -q); do
  echo "Backing up volume: $VOLUME"

  # Backup the volume to a .tar.gz file without the date suffix
  BACKUP_FILE="$BACKUP_DATE_DIR/$VOLUME.tar.gz"

  # Perform the backup using a temporary container
  docker run --rm -v $VOLUME:/volume -v $BACKUP_DATE_DIR:/backup alpine \
    sh -c "tar czf /backup/$(basename $BACKUP_FILE) -C /volume ."

  # Check if the backup was successful
  if [ $? -eq 0 ]; then
    echo "Backup of volume $VOLUME successful: $BACKUP_FILE"
  else
    echo "Error backing up volume $VOLUME"
  fi
done

echo "Completed backing up all volumes."

