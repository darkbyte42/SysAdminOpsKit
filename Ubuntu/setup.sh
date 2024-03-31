#!/bin/bash

# Check if dos2unix is installed, if not, install it
if ! command -v dos2unix &>/dev/null; then
    echo "dos2unix is not installed. Installing..."
    sudo apt update
    sudo apt install dos2unix -y
fi

# Define the directory for scripts
SCRIPTS_DIR="/root/scripts"

# Check if the scripts directory exists, if not, create it
if [ ! -d "$SCRIPTS_DIR" ]; then
    sudo mkdir -p "$SCRIPTS_DIR"
fi

# Define the URL for the backup script
BACKUP_SCRIPT_URL="https://raw.githubusercontent.com/darkbyte42/SysAdminOpsKit/staging/Ubuntu/create_backup.sh"  # Replace with actual URL

# Download the backup script if it doesn't exist
if [ ! -f "$SCRIPTS_DIR/create_backup.sh" ]; then
    echo "Downloading create_backup.sh..."
    curl -o "$SCRIPTS_DIR/create_backup.sh" "$BACKUP_SCRIPT_URL"
fi

# Convert the backup script to Unix format if needed
dos2unix "$SCRIPTS_DIR/create_backup.sh" &>/dev/null

# Set execute permissions for the backup script
chmod +x "$SCRIPTS_DIR/create_backup.sh"

# Run the backup script
echo "Setup completed. Running create_backup.sh..."
"$SCRIPTS_DIR/create_backup.sh"
