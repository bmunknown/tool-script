#!/bin/bash

# Check if PostgreSQL is installed
if ! command -v pg_dump &> /dev/null
then
    echo "PostgreSQL is not installed. Please install PostgreSQL before continuing."
    exit 1
fi

# Prompt for PostgreSQL connection information
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

# Check PostgreSQL connection (test login)
export PGPASSWORD=$PG_PASS
pg_isready -h $PG_HOST -p $PG_PORT -U $PG_USER > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Unable to connect to PostgreSQL. Please check your connection details."
    exit 1
fi

# Prompt for backup storage directory (default is /backup/postgres/$(date +%Y-%m-%d)/)
echo "Enter backup storage directory (default is /backup/postgres/$(date +%Y-%m-%d)/):"
read BACKUP_DIR
BACKUP_DIR=${BACKUP_DIR:-/backup/postgres/$(date +%Y-%m-%d)}

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Prompt for backup type
echo "Select backup type:"
echo "1. Backup all databases"
echo "2. Backup a specific database"
read -p "Enter your choice (1 or 2): " OPTION

if [ "$OPTION" -eq 1 ]; then
    BACKUP_FILE="$BACKUP_DIR/database_all.sql"

    echo "Performing backup of all databases..."
    pg_dumpall -h $PG_HOST -p $PG_PORT -U $PG_USER > "$BACKUP_FILE"

    if [ $? -eq 0 ]; then
        echo "Backup of all databases completed successfully. Backup file saved at: $BACKUP_FILE"
    else
        echo "An error occurred while performing the backup."
        exit 1
    fi

elif [ "$OPTION" -eq 2 ]; then
    echo "Enter the name of the database to backup:"
    read DB_NAME

    BACKUP_FILE="$BACKUP_DIR/$DB_NAME.sql"

    echo "Performing backup of database $DB_NAME..."
    pg_dump -h $PG_HOST -p $PG_PORT -U $PG_USER $DB_NAME > "$BACKUP_FILE"

    if [ $? -eq 0 ]; then
        echo "Backup of database $DB_NAME completed successfully. Backup file saved at: $BACKUP_FILE"
    else
        echo "An error occurred while performing the backup."
        exit 1
    fi

else
    echo "Invalid choice. Please choose 1 or 2."
    exit 1
fi

# Ask if the user wants to add any additional options (like oplog)
echo "Do you want to add any additional options? (Enter numbers separated by space or press Enter to skip)"
echo "1. Include oplog"
echo "2. Compress backup"
echo "3. Include schema"
echo "4. Exclude certain tables"
read -p "Enter your choices (e.g., 1 3 or just press Enter): " ADDITIONAL_OPTIONS

# If any option is selected, display them
if [ ! -z "$ADDITIONAL_OPTIONS" ]; then
    echo "You selected the following options: $ADDITIONAL_OPTIONS"
    # Add code here to handle each option as needed.
    # Example: if the user selects option 1, include oplog; if 2, compress the backup, etc.
    # You can modify the backup commands (pg_dump, pg_dumpall) based on these options.
else
    echo "No additional options selected."
fi
