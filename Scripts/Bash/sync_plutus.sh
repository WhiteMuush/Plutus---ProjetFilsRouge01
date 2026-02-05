#!/bin/bash

# This script synchronizes files to a remote server

# Define source directory containing command files
COMMANDES_DIR="/var/www/plutusweb/commandes"              

# Define archive directory for processed files
ARCHIVE_DIR="/var/www/plutusweb/archives"

# Remote server connection details
REMOTE_USER="plutus-erp"
REMOTE_HOST="srv-erp-plutus"
REMOTE_DIR="C:/Temp/Commandes"

# Log file path for tracking script execution
LOG_FILE="./sync_plutus.log"

# Color palette for terminal output
RED='\033[0;31m'
NC='\033[0m'  # No color (reset)

# Function to log messages with timestamp
function log(){
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to create archive directory if it doesn't exist
function create_archive_dir(){
    if [ ! -d "$ARCHIVE_DIR" ]; then
        mkdir -p "$ARCHIVE_DIR"
        log "Archive directory created: $ARCHIVE_DIR"
    fi
}

# Function to iterate through files and sync them to remote server
function sync_files(){
    # Loop through all files in the commands directory
    for file in "$COMMANDES_DIR"/*; do
        # Skip if entry is not a file
        [ -f "$file" ] || continue

        # Copy file to remote server and handle success/failure
        if scp "$file" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"; then
            # Move file to archive directory on successful transfer
            mv "$file" "$ARCHIVE_DIR/"
            log "File archived: $(basename "$file")"
        else
            # Log error if file transfer fails
            log "Error syncing file: ${RED}$(basename "$file")${NC}"
        fi
    done
}

# Main function to orchestrate script execution
function main(){
    create_archive_dir
    sync_files
}

# Execute main function
main