#!/bin/bash

# Requirment
## Already have backup account, config export DIR
## CREATE DIRECTORY export_dir AS '/u01/app/oracle/export';
## grant read,write on directory EXPORT_DIR to dump;

BACKUP_FOLDER="/root/backup-data/oracle" # Backup folder location
EXPORT_DIRECTORY="/u01/app/oracle/export" # Export dir location
EXPORT_PARENT_DIRECTORY="/u01"
DATETIME=`date +"%Y-%m-%d-%H-%M"` # Date time format
EXPORT_ACCOUNT="dump"
EXPORT_PASSWORD="123456"
ORACLE_CONTAINER_NAME="oracle-19c"
DAYSTORETAINBACKUP="10" # Days to keep newest file

CHECK_DIR_EXIST=$(docker exec $ORACLE_CONTAINER_NAME ls $EXPORT_DIRECTORY -A)
# Check if export directory exist? if not, create and chmod
if [[ -z $CHECK_DIR_EXIST  ]]; then ## return true if null ## dir not exist
  docker exec --user root $ORACLE_CONTAINER_NAME mkdir -p $EXPORT_DIRECTORY
  echo "Created dir"
  docker exec --user root $ORACLE_CONTAINER_NAME chmod -R 777 /u01 $EXPORT_PARENT_DIRECTORY
  echo "Chmod success"
fi


# Dump
docker exec $ORACLE_CONTAINER_NAME expdp $EXPORT_ACCOUNT/$EXPORT_PASSWORD@XE directory=EXPORT_DIR  dumpfile=$DATETIME-full.dmp FULL=Y logfile=$DATETIME-fullexp.log


# Create backup folder
if [ ! -d "$BACKUP_FOLDER" ]; then
  mkdir -p $BACKUP_FOLDER
fi


# Copy from container to host machine
docker cp $ORACLE_CONTAINER_NAME:$EXPORT_DIRECTORY/. $BACKUP_FOLDER

# Delete old backup in container
docker exec $ORACLE_CONTAINER_NAME rm -rf $EXPORT_DIRECTORY/*
# Delete old backup in hostmachine
find $BACKUP_FOLDER -type f -mtime +$DAYSTORETAINBACKUP -exec rm {} +
