#!/bin/bash

# Check if PostgreSQL is installed
if ! command -v pg_dump &> /dev/null
then
    echo "PostgreSQL is not installed. Please install PostgreSQL before continuing."
    exit 1
fi

# Prompt for PostgreSQL connection details
echo "Enter PostgreSQL host (default is localhost):"
read PG_HOST
PG_HOST=${PG_HOST:-localhost}

echo "Enter PostgreSQL port (default is 5432):"
read PG_PORT
PG_PORT=${PG_PORT:-5432}

echo "Enter PostgreSQL user:"
read PG_USER

echo "Enter PostgreSQL password:"
read -s PG_PASS

# Check connection to PostgreSQL
export PGPASSWORD=$PG_PASS
pg_isready -h $PG_HOST -p $PG_PORT -U $PG_USER > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Unable to connect to PostgreSQL. Please check your connection details."
    exit 1
fi

# Prompt for backup directory
echo "Enter the backup directory (default is /backup/postgres/):"
read BACKUP_DIR
BACKUP_DIR=${BACKUP_DIR:-/backup/postgres/}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Choose backup option: all databases or a specific database
echo "Choose backup option:"
echo "1. Backup all databases"
echo "2. Backup a single database"
read -p "Enter option (1 or 2): " BACKUP_OPTION

# Set backup filename based on the current date and time
DATE=$(date +%Y-%m-%d_%H-%M-%S)

if [ "$BACKUP_OPTION" -eq 1 ]; then
    BACKUP_FILE="$BACKUP_DIR/${DATE}_database_all.sql"
    echo "Backing up all databases to $BACKUP_FILE"
    pg_dumpall -h $PG_HOST -p $PG_PORT -U $PG_USER -f "$BACKUP_FILE"
else
    echo "Enter the name of the database to backup:"
    read DB_NAME
    BACKUP_FILE="$BACKUP_DIR/${DATE}_$DB_NAME.sql"
    echo "Backing up database $DB_NAME to $BACKUP_FILE"
    pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER -d $DB_NAME -f "$BACKUP_FILE"
fi

# Prompt for additional backup options
echo "Would you like to include additional options for the backup?"
echo "1. Include oplog"
echo "2. Compress backup"
echo "3. Include schema"
echo "4. Exclude certain tables"
echo "5. Customize options (advanced)"
echo "0. No additional options"
read -p "Enter option (0-5): " ADDITIONAL_OPTION

# Handle additional options
case $ADDITIONAL_OPTION in
    1)
        echo "Including oplog in backup..."
        # Add logic to include oplog (specific to your PostgreSQL setup)
        ;;
    2)
        echo "Compressing the backup..."
        gzip "$BACKUP_FILE"
        BACKUP_FILE="$BACKUP_FILE.gz"
        echo "Backup compressed: $BACKUP_FILE"
        ;;
    3)
        echo "Including schema in backup..."
        pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER --no-password --no-owner --no-comments --no-privileges --create --schema-only -d "$DB_NAME" -f "$BACKUP_FILE"
        ;;
    4)
        echo "Enter the tables to exclude (comma-separated):"
        read EXCLUDE_TABLES
        for TABLE in $(echo $EXCLUDE_TABLES | tr "," "\n"); do
            echo "Excluding table $TABLE..."
            pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER -d $DB_NAME --no-password --no-owner --no-comments --no-privileges -T $TABLE -f "$BACKUP_FILE"
        done
        ;;
    5)
        echo "Enter custom options (e.g., --no-comments, --no-owner, etc.):"
        read CUSTOM_OPTIONS
        echo "Executing pg_dump with custom options: $CUSTOM_OPTIONS"
        pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER $CUSTOM_OPTIONS -d "$DB_NAME" -f "$BACKUP_FILE"
        ;;
    0)
        echo "No additional options selected."
        ;;
    *)
        echo "Invalid option selected."
        exit 1
        ;;
esac

# Final message indicating backup completion
echo "Backup completed: $BACKUP_FILE"
