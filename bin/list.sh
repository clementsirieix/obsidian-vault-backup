#!/bin/bash

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help    Display this help message"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BACKUPS_DIR="$SCRIPT_DIR/../backups"

if [ ! -d "$BACKUPS_DIR" ]; then
    echo "Error: Backups directory does not exist: $BACKUPS_DIR"
    exit 1
fi

BACKUPS=$(ls -1d "$BACKUPS_DIR"/backup-* 2>/dev/null)

if [ -z "$BACKUPS" ]; then
    echo "No backups found."
else
    echo "Available backups:"
    echo "$BACKUPS" | while read -r backup; do
        backup_name=$(basename "$backup")
        echo "  $backup_name"
    done
fi
