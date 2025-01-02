# Tool Script

A collection of useful scripts for managing PostgreSQL, MariaDB backups and restores, as well as Docker volume backups and restores.

## Features

- Backup and restore PostgreSQL and MariaDB databases
- Docker volume backup and restore
- Supports various customizable options like schema backups, excluding tables, compressing backups, etc.
- Includes utility scripts for Docker volume backups

## Installation

Clone the repository to your local machine:

```bash
git clone https://github.com/bmunknown/tool-script.git
cd tool-script
```

## Usage

### Backup PostgreSQL:

Run the backup script for PostgreSQL:

```bash
./bash/backup_postgres.sh
```

### Restore PostgreSQL:

Restore a PostgreSQL backup:

```bash
./bash/restore_postgres.sh
```

### Backup MariaDB:

Run the backup script for MariaDB:

```bash
./bash/backup_mariadb.sh
```

### Restore MariaDB:

Restore a MariaDB backup:

```bash
./bash/restore_mariadb.sh
```

### Docker Volumes Backup:

Backup all Docker volumes:

```bash
./bash/docker-volumes-backup-all.sh
```

### Docker Volumes Restore:

Restore all Docker volumes:

```bash
./bash/docker-volumes-restore-all.sh
```

## Customization

You can modify the scripts to include advanced options like:
- Excluding tables
- Including schema
- Compressing backups
- Customizing options for the backup and restore processes.
