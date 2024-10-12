#!/bin/bash

usage() {
    echo "Usage: $0 -p <folder_path> | --path <folder_path>"
    echo "  -p, --path    Path to the folder to be backed up"
    exit 1
}

if [ -z "$BACKUP_SECRET" ]; then
    echo "Error: BACKUP_SECRET environment variable is not set"
    exit 1
fi

FOLDER_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            FOLDER_PATH="$2"
            shift 2
            ;;
        -p=*|--path=*)
            FOLDER_PATH="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [ -z "$FOLDER_PATH" ]; then
    echo "Error: Folder path is required"
    usage
fi

FOLDER_PATH=$(realpath -q "$FOLDER_PATH")

if [ ! -d "$FOLDER_PATH" ]; then
    echo "Error: Folder does not exist: $FOLDER_PATH"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATE=$(date +"%Y%m%d_%H%M%S")
HASH=$(openssl rand -hex 5)
BACKUP_NAME="backup-${DATE}-${HASH}"
BACKUP_DIR="$SCRIPT_DIR/../backups/$BACKUP_NAME"

echo "Creating backup"

mkdir -p "$BACKUP_DIR"
tar -czf - -C "$(dirname "$FOLDER_PATH")" "$(basename "$FOLDER_PATH")" | \
    openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"$BACKUP_SECRET" | \
    split -b 20M - "${BACKUP_DIR}/${BACKUP_NAME}.enc.part-"

echo "Backup created: $BACKUP_DIR"

cd "$SCRIPT_DIR/.." || exit
git add "backups/$BACKUP_NAME"
git commit -m "$BACKUP_NAME"
git push origin main || echo "Warning: Failed to push to remote repository"

echo "Backup committed to git: $BACKUP_NAME"
