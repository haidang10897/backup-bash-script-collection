#!/bin/bash
# Variables
BACKUP_ARCHIVE_FOLDER="/root/backup-data/elasticsearch" # Backup folder location
BACKUP_TMP_FOLDER="/backup/elasticsearch"
ELASTICSEARCH_SYSTEM_USER="elasticsearch"
ELASTICSEARCH_USER="elastic"
ELASTICSEARCH_PASSWORD="password"
ELASTICSEARCH_URL="http://192.168.1.1:9200"
SNAPSHOT_NAME="snapshot_event_io"
INDICES="event,identity_object"

# Create backup folder
if [ ! -d "$BACKUP_ARCHIVE_FOLDER" ]; then
  mkdir -p $BACKUP_ARCHIVE_FOLDER
fi

# Create backup tmp folder
if [ ! -d "$BACKUP_TMP_FOLDER" ]; then
  mkdir -p $BACKUP_TMP_FOLDER
fi

# Grant permission for user elasticsearch to folder
chown -R $ELASTICSEARCH_SYSTEM_USER:$ELASTICSEARCH_SYSTEM_USER $BACKUP_TMP_FOLDER

# Check if backup snapshot with above repository exist?
response=`curl -s --user $ELASTICSEARCH_USER:$ELASTICSEARCH_PASSWORD $ELASTICSEARCH_URL/_snapshot/_all\?pretty\=true | grep $BACKUP_TMP_FOLDER | wc -l`
if [ $response == "1" ]; then
  echo "Backup snapshot exist!! No need to create"
else
  curl -s --user $ELASTICSEARCH_USER:$ELASTICSEARCH_PASSWORD $ELASTICSEARCH_URL/_snapshot/backup_repo --header 'Content-Type: application/json' --data-raw '{ "type": "fs", "settings": { "location": "'$BACKUP_TMP_FOLDER'", "compress": true } }'
fi

# Delete old snapshot
curl --location --request DELETE --user $ELASTICSEARCH_USER:$ELASTICSEARCH_PASSWORD $ELASTICSEARCH_URL/_snapshot/backup_repo/$SNAPSHOT_NAME
echo "DELETED OLD SNAPSHOT"

# Snapshot
curl --location --request PUT --user $ELASTICSEARCH_USER:$ELASTICSEARCH_PASSWORD $ELASTICSEARCH_URL/_snapshot/backup_repo/$SNAPSHOT_NAME?wait_for_completion=false --header 'Content-Type: application/json' --data-raw '{ "indices": "'$INDICES'", "ignore_unavailable": true, "include_global_state": false, "metadata": { "taken_by": "backup_script", "taken_because": "manual_snapshot" }, "index_settings": { "index.codec": "best_compression" }}'
echo "SNAPSHOT DONE"
