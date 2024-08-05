#!/bin/bash

# ref
# https://stackoverflow.com/questions/1078196/take-perfect-backup-with-mysqldump

# MySQL credentials
USER="root"
PASSWORD="mypassword"
BACKUP_FOLDER="/root/backup-data/mariadb"
DAYSTORETAINBACKUP="3" # Days to keep newest file

# Create backup folder
if [ ! -d "$BACKUP_FOLDER" ]; then
  mkdir -p $BACKUP_FOLDER
fi

# Get the list of databases
databases=$(mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

# Loop through each database and back it up
for db in $databases; do
  if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]]; then
    echo "Backing up database: $db"
    mysqldump -u $USER -p$PASSWORD --databases $db -R -e --triggers --single-transaction > $BACKUP_FOLDER/$(date +%Y-%m-%d-%H-%M)_$db.sql
  fi
done

# Backup full database
echo "Backing up full database"
mysqldump -u $USER -p$PASSWORD -A -R -E --triggers --single-transaction > $BACKUP_FOLDER/$(date +%Y-%m-%d-%H-%M)_full.sql

# Delete old files
find $BACKUP_FOLDER -type f -mtime +$DAYSTORETAINBACKUP -exec rm {} +
