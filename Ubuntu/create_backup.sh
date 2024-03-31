#!/bin/bash

# Get current date and time in YYYY-MM-DD-HHMM format
TIMESTAMP=$(date +"%Y-%m-%d-%H%M")

# Get the hostname or FQDN
HOSTNAME=$(hostname)

# Define backup destination directory
BACKUP_DIR="/backups"

# Check if backup directory exists, if not, create it
if [ ! -d "$BACKUP_DIR" ]; then
    sudo mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        echo "Failed to create backup directory. Exiting."
        exit 1
    fi
fi

# Define backup destination with timestamp and hostname
DESTINATION="$BACKUP_DIR/${HOSTNAME}_${TIMESTAMP}_full_backup.tar.gz"

# Create a compressed tar archive of the entire root filesystem excluding specified directories
sudo tar czf $DESTINATION --exclude=/proc --exclude=/sys --exclude=/tmp --exclude=/dev --exclude=/mnt --exclude=/media / 
if [ $? -ne 0 ]; then
    echo "Backup failed. Exiting."
    exit 1
fi

# Optional: Verify the integrity of the backup
if ! tar tzf $DESTINATION > /dev/null; then
    echo "Backup verification failed. The archive might be corrupt."
    # Consider whether to exit or just warn, depending on your preference
    exit 1
fi

echo "Backup completed: $DESTINATION"