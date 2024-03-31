#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi

# Check if dos2unix is installed, if not, install it
if ! command -v dos2unix &>/dev/null; then
    echo "dos2unix is not installed. Installing..."
    apt update && apt install dos2unix -y || { echo "Failed to install dos2unix. Exiting."; exit 1; }
fi

# Define the directory for scripts
SCRIPTS_DIR="/root/scripts"

# Check if the scripts directory exists, if not, create it
if [ ! -d "$SCRIPTS_DIR" ]; then
    mkdir -p "$SCRIPTS_DIR" || { echo "Failed to create $SCRIPTS_DIR. Exiting."; exit 1; }
fi

# Define the URL for the backup script (using the raw content URL)
BACKUP_SCRIPT_URL="https://raw.githubusercontent.com/darkbyte42/SysAdminOpsKit/staging/Ubuntu/create_backup.sh"

# Check if the backup script already exists
if [ -f "$SCRIPTS_DIR/create_backup.sh" ]; then
    # Prompt the user for permission to overwrite
    read -p "The backup script already exists. Do you want to overwrite it? (y/N): " overwrite_response
    case $overwrite_response in
        [Yy]* )
            echo "Downloading and overwriting create_backup.sh..."
            if curl -o "$SCRIPTS_DIR/create_backup.sh" "$BACKUP_SCRIPT_URL"; then
                echo "Successfully downloaded create_backup.sh. Converting to Unix format..."
                dos2unix "$SCRIPTS_DIR/create_backup.sh" &>/dev/null || { echo "Failed to convert create_backup.sh to Unix format. Exiting."; exit 1; }
            else
                echo "Failed to download create_backup.sh. Exiting."
                exit 1
            fi
            ;;
        * )
            echo "Not overwriting the existing script."
            ;;
    esac
else
    # Download the backup script since it doesn't exist
    echo "Downloading create_backup.sh..."
    if curl -o "$SCRIPTS_DIR/create_backup.sh" "$BACKUP_SCRIPT_URL"; then
        echo "Successfully downloaded create_backup.sh. Converting to Unix format..."
        dos2unix "$SCRIPTS_DIR/create_backup.sh" &>/dev/null || { echo "Failed to convert create_backup.sh to Unix format. Exiting."; exit 1; }
    else
        echo "Failed to download create_backup.sh. Exiting."
        exit 1
    fi
fi

# Convert the backup script to Unix format
dos2unix "$SCRIPTS_DIR/create_backup.sh" &>/dev/null || { echo "Failed to convert create_backup.sh to Unix format. Exiting."; exit 1; }

# Set execute permissions for the backup script
chmod +x "$SCRIPTS_DIR/create_backup.sh"

# Run the backup script
echo "Setup completed. Running create_backup.sh..."
"$SCRIPTS_DIR/create_backup.sh" || { echo "create_backup.sh failed to execute successfully."; }
