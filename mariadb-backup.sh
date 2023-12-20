#!/bin/bash
# Variables
BACKUP_FOLDER="/root/backup-data/" # Backup folder location
DATETIME=`date +"%Y-%m-%d-%H-%M"` # Date time format 
DATABASE_LIST="cds_apphd sbtest" # List of mariadb database, seperate by "space bar"
MARIADB_USER="user" # username of backup user
MARIADB_PASSWORD="password" # password of backup user
DAYSTORETAINBACKUP="14" # Days to keep newest file
# Create backup folder
if [ ! -d "$BACKUP_FOLDER" ]; then
  mkdir -p $BACKUP_FOLDER
fi
# Backup DB
for i in $DATABASE_LIST; do
  echo "Backing up $i database"
  mysqldump -u $MARIADB_USER -p$MARIADB_PASSWORD $i > $BACKUP_FOLDER$i-$DATETIME.sql
done

# Delete old files
find $BACKUP_FOLDER -type f -mtime +$DAYSTORETAINBACKUP -exec rm {} +
