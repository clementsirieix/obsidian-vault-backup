#!/bin/bash

usage() {
    echo "Usage: $0 -n <backup_name> -o <output_directory>"
    echo "  -n, --name     Name of the backup to load"
    echo "  -o, --output   Directory to extract the backup to"
    exit 1
}

if [ -z "$BACKUP_SECRET" ]; then
    echo "Error: BACKUP_SECRET environment variable is not set"
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            BACKUP_NAME="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -n=*|--name=*)
            BACKUP_NAME="${1#*=}"
            shift
            ;;
        -o=*|--output=*)
            OUTPUT_DIR="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [ -z "$BACKUP_NAME" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Error: Both backup name and output directory are required"
    usage
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUPS_DIR="$SCRIPT_DIR/../backups"
BACKUP_PATH="$BACKUPS_DIR/$BACKUP_NAME"

if [ ! -d "$BACKUP_PATH" ]; then
    echo "Error: Backup not found: $BACKUP_NAME"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Extracting backup $BACKUP_NAME to $OUTPUT_DIR"
cat "$BACKUP_PATH"/*.enc.part-* | \
    openssl enc -d -aes-256-cbc -salt -pbkdf2 -pass pass:"$BACKUP_SECRET" | \
    tar -xzf - -C "$OUTPUT_DIR"

if [ $? -eq 0 ]; then
    echo "Backup extracted successfully"
else
    echo "Error: Failed to extract backup"
    exit 1
fi
