#!/bin/bash

# Check if MariaDB is installed
if ! command -v mysql &> /dev/null
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

# Prompt for the backup file to restore
echo "Enter the backup file to restore:"
read BACKUP_FILE

# Check if the file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file $BACKUP_FILE does not exist."
    exit 1
fi

# Prompt for the database name to restore
echo "Enter the database to restore (if restoring all databases, enter 'all'):"
read DB_NAME

# Restore the database from the backup file
if [ "$DB_NAME" == "all" ]; then
    echo "Restoring all databases from $BACKUP_FILE"
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS < "$BACKUP_FILE"
else
    echo "Restoring database $DB_NAME from $BACKUP_FILE"
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME < "$BACKUP_FILE"
fi

# Completion message
echo "Restore completed from $BACKUP_FILE"
