#!/bin/bash

# Backup directory where the backup files are stored
BACKUP_DIR="/path/to/backup/dir/volume-backup"

# Loop through each backup file in the volume-backup directory
for BACKUP_FILE in $BACKUP_DIR/*.tar.gz; do
  # Extract the volume name from the backup file name (before the timestamp part)
  VOLUME=$(basename "$BACKUP_FILE" | sed -r 's/-(\d{8}\d{6})\.tar\.gz//')

  echo "Restoring volume: $VOLUME from $BACKUP_FILE"

  # Check if the volume already exists
  if docker volume inspect $VOLUME &>/dev/null; then
    echo "Volume $VOLUME already exists. Restoring data..."
  else
    # If the volume does not exist, create it
    echo "Volume $VOLUME does not exist. Creating it..."
    docker volume create $VOLUME
  fi

  # Restore the volume from the backup file using a temporary container
  docker run --rm -v $VOLUME:/volume -v $BACKUP_DIR:/backup alpine \
    sh -c "tar xzf /backup/$(basename $BACKUP_FILE) -C /volume"

  echo "Restoration of volume $VOLUME completed."
done

echo "Completed restoring all volumes."
