#!/bin/bash

# Check if MariaDB is installed
if ! command -v mysqldump &> /dev/null
then
    echo "MariaDB is not installed. Please install MariaDB before continuing."
    exit 1
fi

# Prompt for connection details to MariaDB
echo "Enter MariaDB host (default is localhost):"
read DB_HOST
DB_HOST=${DB_HOST:-localhost}

echo "Enter MariaDB port (default is 3306):"
read DB_PORT
DB_PORT=${DB_PORT:-3306}

echo "Enter MariaDB user:"
read DB_USER

echo "Enter MariaDB password:"
read -s DB_PASS

# Test the connection to MariaDB
mysqladmin ping -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS --silent > /dev/null
if [ $? -ne 0 ]; then
    echo "Unable to connect to MariaDB. Please check your connection details."
    exit 1
fi

# Prompt for the backup directory
echo "Enter the backup directory (default is /backup/mariadb/):"
read BACKUP_DIR
BACKUP_DIR=${BACKUP_DIR:-/backup/mariadb/}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Prompt for the backup type: all databases or a single database
echo "Choose backup option:"
echo "1. Backup all databases"
echo "2. Backup a single database"
read -p "Enter option (1 or 2): " BACKUP_OPTION

# Set the filename based on the current date and time
DATE=$(date +%Y-%m-%d_%H-%M-%S)

if [ "$BACKUP_OPTION" -eq 1 ]; then
    BACKUP_FILE="$BACKUP_DIR/${DATE}_all_databases.sql"
    echo "Backing up all databases to $BACKUP_FILE"
    mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS --all-databases > "$BACKUP_FILE"
else
    echo "Enter the name of the database to backup:"
    read DB_NAME
    BACKUP_FILE="$BACKUP_DIR/${DATE}_$DB_NAME.sql"
    echo "Backing up database $DB_NAME to $BACKUP_FILE"
    mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME > "$BACKUP_FILE"
fi

# Additional options for backup (compression, excluding tables, or custom options)
echo "Would you like to include additional options for the backup?"
echo "1. Compress backup"
echo "2. Exclude certain tables"
echo "3. Customize options (advanced)"
echo "0. No additional options"
read -p "Enter option (0-3): " ADDITIONAL_OPTION

# Handle additional backup options
case $ADDITIONAL_OPTION in
    1)
        echo "Compressing the backup..."
        gzip "$BACKUP_FILE"
        BACKUP_FILE="$BACKUP_FILE.gz"
        echo "Backup compressed: $BACKUP_FILE"
        ;;
    2)
        echo "Enter the tables to exclude (comma-separated):"
        read EXCLUDE_TABLES
        EXCLUDE_OPTIONS=""
        for TABLE in $(echo $EXCLUDE_TABLES | tr "," "\n"); do
            EXCLUDE_OPTIONS="$EXCLUDE_OPTIONS --ignore-table=$DB_NAME.$TABLE"
        done
        echo "Excluding tables: $EXCLUDE_TABLES"
        mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $EXCLUDE_OPTIONS $DB_NAME > "$BACKUP_FILE"
        ;;
    3)
        echo "Enter custom options (e.g., --no-tablespaces, --routines, etc.):"
        read CUSTOM_OPTIONS
        echo "Executing mysqldump with custom options: $CUSTOM_OPTIONS"
        mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $CUSTOM_OPTIONS $DB_NAME > "$BACKUP_FILE"
        ;;
    0)
        echo "No additional options selected."
        ;;
    *)
        echo "Invalid option selected."
        exit 1
        ;;
esac

# Completion message
echo "Backup completed: $BACKUP_FILE"
