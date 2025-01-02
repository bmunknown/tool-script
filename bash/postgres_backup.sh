#!/bin/bash

# Kiểm tra xem PostgreSQL có được cài đặt hay không
if ! command -v pg_dump &> /dev/null
then
    echo "PostgreSQL is not installed. Please install PostgreSQL before continuing."
    exit 1
fi

# Prompt cho thông tin kết nối PostgreSQL
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

# Kiểm tra kết nối với PostgreSQL
export PGPASSWORD=$PG_PASS
pg_isready -h $PG_HOST -p $PG_PORT -U $PG_USER > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Unable to connect to PostgreSQL. Please check your connection details."
    exit 1
fi

# Prompt cho đường dẫn lưu trữ backup
echo "Enter the backup directory (default is /backup/postgres/):"
read BACKUP_DIR
BACKUP_DIR=${BACKUP_DIR:-/backup/postgres/}

# Tạo thư mục backup nếu không tồn tại
mkdir -p "$BACKUP_DIR"

# Lựa chọn backup all databases hay 1 database cụ thể
echo "Choose backup option:"
echo "1. Backup all databases"
echo "2. Backup a single database"
read -p "Enter option (1 or 2): " BACKUP_OPTION

# Đặt tên file backup theo thời gian hiện tại
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

# Prompt thêm các lựa chọn tuỳ chọn khi backup
echo "Would you like to include additional options for the backup?"
echo "1. Include oplog"
echo "2. Compress backup"
echo "3. Include schema"
echo "4. Exclude certain tables"
echo "5. Customize options (advanced)"
echo "0. No additional options"
read -p "Enter option (0-5): " ADDITIONAL_OPTION

# Xử lý các lựa chọn bổ sung
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

echo "Backup completed: $BACKUP_FILE"
