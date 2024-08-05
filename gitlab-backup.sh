#!/bin/bash

# Variables
GITLABBACKUPS=/var/opt/gitlab/backups/
BACKUPDAYS="7"

# Create back up
gitlab-backup create SKIP=registry

# Cleanup old backups
find $GITLABBACKUPS -type f -mtime +$BACKUPDAYS -exec rm -f {} +
