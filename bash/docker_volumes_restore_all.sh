#!/bin/bash

# Prompt for the full path to the backup directory (e.g., /backup/volumes-backup)
echo "Enter the full path to the backup directory (e.g., /backup/volumes-backup):"
read BACKUP_DIR

# Check if the backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
  echo "The backup directory $BACKUP_DIR does not exist. Exiting."
  exit 1
fi

# List the date folders (subdirectories) in the backup directory
echo "Backup directories found in $BACKUP_DIR:"
ls -d $BACKUP_DIR/*/

# Prompt the user to enter the date folder to restore from
echo "Enter the backup date folder to restore from (e.g., 2025-01-03):"
read BACKUP_DATE

# Define the full path for the backup folder
BACKUP_PATH="$BACKUP_DIR/$BACKUP_DATE"

# Check if the specified backup folder exists
if [ ! -d "$BACKUP_PATH" ]; then
  echo "The backup folder $BACKUP_PATH does not exist. Exiting."
  exit 1
fi

# Find all .tar.gz files in the specified backup folder
BACKUP_FILES=($BACKUP_PATH/*.tar.gz)

# If no backup files exist, exit
if [ ${#BACKUP_FILES[@]} -eq 0 ]; then
  echo "No backup files found in $BACKUP_PATH. Exiting."
  exit 1
fi

# List all backup files found in the backup folder
echo "Backup files found in $BACKUP_PATH:"
for FILE in "${BACKUP_FILES[@]}"; do
  echo "$FILE"
done

# Loop through each backup file and restore the volumes
for BACKUP_FILE in "${BACKUP_FILES[@]}"; do
  # Extract the volume name from the backup file name (without timestamp)
  VOLUME=$(basename "$BACKUP_FILE" .tar.gz)

  # Print the extracted volume name
  echo "Restoring volume: $VOLUME from $BACKUP_FILE"

  # Check if the volume already exists
  if docker volume inspect "$VOLUME" &>/dev/null; then
    echo "Volume $VOLUME already exists. Restoring data..."
  else
    # If the volume does not exist, create it
    echo "Volume $VOLUME does not exist. Creating it..."
    docker volume create "$VOLUME"
  fi

  # Restore the volume from the backup file using a temporary container
  docker run --rm \
    -v "$VOLUME":/volume \
    -v "$BACKUP_PATH":/backup \
    alpine \
    sh -c "tar xzf /backup/$(basename "$BACKUP_FILE") -C /volume"

  # Check if the restore was successful
  if [ $? -eq 0 ]; then
    echo "Restoration of volume $VOLUME completed successfully."
  else
    echo "Error restoring volume $VOLUME."
  fi
done

echo "Completed restoring all volumes."
