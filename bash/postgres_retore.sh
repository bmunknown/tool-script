#!/bin/bash

# Check if PostgreSQL is installed
if ! command -v pg_restore &> /dev/null && ! command -v psql &> /dev/null
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

# Prompt for the backup file to restore
echo "Enter the backup file path to restore:"
read BACKUP_FILE

# Check if the backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file does not exist. Please check the file path."
    exit 1
fi

echo "Restoring from file: $BACKUP_FILE"

# Determine if the file is a full dump (pg_dumpall) or a single database dump (pg_dump)
if [[ "$BACKUP_FILE" == *"database_all"* ]]; then
    echo "Restoring all databases..."
    PGPASSWORD=$PG_PASS psql -h $PG_HOST -p $PG_PORT -U $PG_USER -f "$BACKUP_FILE"

    if [ $? -eq 0 ]; then
        echo "Restore of all databases completed successfully."
    else
        echo "An error occurred while restoring all databases."
        exit 1
    fi
else
    # For single database restore
    DB_NAME=$(basename "$BACKUP_FILE" .sql)

    # Drop and recreate the database before restoring
    echo "Dropping database if it exists..."
    PGPASSWORD=$PG_PASS psql -h $PG_HOST -p $PG_PORT -U $PG_USER -c "DROP DATABASE IF EXISTS $DB_NAME;"

    echo "Creating database $DB_NAME..."
    PGPASSWORD=$PG_PASS psql -h $PG_HOST -p $PG_PORT -U $PG_USER -c "CREATE DATABASE $DB_NAME;"

    echo "Restoring database $DB_NAME from backup file..."
    PGPASSWORD=$PG_PASS psql -h $PG_HOST -p $PG_PORT -U $PG_USER $DB_NAME < "$BACKUP_FILE"

    if [ $? -eq 0 ]; then
        echo "Restore of database $DB_NAME completed successfully."
    else
        echo "An error occurred while restoring the database $DB_NAME."
        exit 1
    fi
fi
