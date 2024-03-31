#!/bin/bash

# Define the directory where backup files are stored
BACKUP_DIR="/backups"

# Prompt the user for the backup file name
read -p "Enter the name of the backup file to restore: " BACKUP_FILE

# Check if the specified backup file exists
if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    echo "Backup file '$BACKUP_FILE' not found in '$BACKUP_DIR'."
    exit 1
fi

# Verify the integrity of the backup file
echo "Verifying the integrity of the backup file..."
if sudo tar tzf "$BACKUP_DIR/$BACKUP_FILE" > /dev/null; then
    echo "Backup file '$BACKUP_FILE' is intact."
else
    echo "Error: Backup file '$BACKUP_FILE' is corrupted or invalid."
    exit 1
fi

# Prompt the user for the destination to restore
read -p "Enter the destination to restore (e.g., /): " RESTORE_DESTINATION

# Verify the specified destination
read -p "Are you sure you want to restore '$BACKUP_FILE' to '$RESTORE_DESTINATION'? (y/n): " -n 1 -r
echo    # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore operation canceled."
    exit 1
fi

# Restore the backup
echo "Restoring '$BACKUP_FILE' to '$RESTORE_DESTINATION'..."
sudo tar xzf "$BACKUP_DIR/$BACKUP_FILE" -C "$RESTORE_DESTINATION"
echo "Restore completed successfully."
