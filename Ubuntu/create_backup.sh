#!/bin/bash

# Check for necessary commands
if ! command -v tar &> /dev/null || ! command -v date &> /dev/null || ! command -v hostname &> /dev/null; then
    echo "Error: Required command(s) not found. Ensure tar, date, and hostname are installed."
    exit 1
fi

# Get current date and time in YYYY-MM-DD-HHMM format
use_timestamp=true
read -p "Do you want to include a timestamp in the backup filename? (yes/no): " include_timestamp
if [[ $include_timestamp =~ [Nn][Oo] ]]; then
    use_timestamp=false
fi

TIMESTAMP=""
if $use_timestamp; then
    TIMESTAMP=$(date +"%Y-%m-%d-%H%M")
fi

# Get the hostname or prompt for a custom name if not set
HOSTNAME=$(hostname)
if [ -z "$HOSTNAME" ]; then
    read -p "Hostname not set. Please enter a custom name for the backup: " custom_name
    if [ -z "$custom_name" ]; then
        echo "Error: No name provided for the backup. Exiting."
        exit 1
    fi
    HOSTNAME=$custom_name
fi

# Define backup destination directory
BACKUP_DIR="/backups"

# Check if backup directory exists and is writable, if not, attempt to create it
if [ ! -w "$BACKUP_DIR" ]; then
    sudo mkdir -p "$BACKUP_DIR" &> /dev/null
    if [ ! -w "$BACKUP_DIR" ]; then
        echo "Failed to create or write to backup directory. Exiting."
        exit 1
    fi
fi

# Define backup destination with optional timestamp and hostname
FILENAME="${HOSTNAME}${TIMESTAMP:+_${TIMESTAMP}}_full_backup.tar.gz"
DESTINATION="$BACKUP_DIR/$FILENAME"

# Create a compressed tar archive of the entire root filesystem excluding specified directories
echo "Starting backup to $DESTINATION..."
if ! sudo tar czf "$DESTINATION" --exclude=/proc --exclude=/sys --exclude=/tmp --exclude=/dev --exclude=/mnt --exclude=/media / ; then
    echo "Backup failed. Exiting."
    exit 1
fi

# Verify the integrity of the backup
if ! tar tzf "$DESTINATION" > /dev/null; then
    echo "Backup verification failed. The archive might be corrupt."
    exit 1
fi

echo "Backup completed: $DESTINATION"

# Backup Rotation: Keep only the last 5 backups
echo "Checking for old backups to maintain only the last 5..."
cd "$BACKUP_DIR"
ls -t | grep "${HOSTNAME}_.*_full_backup.tar.gz" | tail -n +6 | xargs -r rm --

# Logging
LOGFILE="$BACKUP_DIR/backup_log.txt"
{
    echo "Backup Log - $(date)"
    echo "Backup created: $DESTINATION"
    echo "Old backups removed to maintain a maximum of 5."
} >> "$LOGFILE"

echo "Backup process complete. Details logged to $LOGFILE"
