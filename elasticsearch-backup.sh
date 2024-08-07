#!/bin/bash

# Elasticsearch credentials
ES_HOST="http://localhost:9200"
ES_USER="elastic"
ES_PASSWORD="mypassword"
OUTPUT_DIR="/root/backup-data/elasticsearch"
BACKUPDAYS="5"

# ============================== Instrall Elasticdump =========================
# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if elasticdump is installed
if command_exists elasticdump; then
  echo "elasticdump is already installed."
else
  echo "elasticdump is not installed. Installing now..."
  # Install Node.js and npm if not already installed
  if ! command_exists node || ! command_exists npm; then
    echo "Node.js and npm are required. Installing Node.js and npm..."
    sudo apt update
    sudo apt install -y nodejs npm
  fi
  # Install elasticdump globally
  sudo npm install -g elasticdump
  echo "elasticdump has been installed."
fi

# ============================== Backup =======================================
# Create backup folder
if [ ! -d "$OUTPUT_DIR" ]; then
  mkdir -p $OUTPUT_DIR
fi

# Get the list of indices
indices=$(curl -s -u $ES_USER:$ES_PASSWORD "$ES_HOST/_cat/indices?h=index" | tr -d ' '| grep -v '^\.')

# Base64 encode credentials
credential_base64=$(echo -n $ES_USER:$ES_PASSWORD | base64)

# Loop through each index and back it up
for index in $indices; do
  echo "Backing up index: $index"
  elasticdump --input="$ES_HOST/$index" --output="$OUTPUT_DIR/$(date +%Y-%m-%d-%H-%M)_$index.json" --type=data --limit=10000 --headers='{"Authorization": "Basic '$credential_base64'"}'
done

# Cleanup old backups
find $OUTPUT_DIR -type f -mtime +$BACKUPDAYS -exec rm -f {} +
