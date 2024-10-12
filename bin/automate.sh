#!/bin/bash

usage() {
    echo "Usage: $0 <start|stop>"
    echo "  start - Start automatic daily backups"
    echo "  stop  - Stop automatic daily backups"
}

if [ $# -eq 0 ]; then
    echo "Error: No option specified"
    usage
    exit 1
fi

option="$1"

if [ -z "$BACKUP_SOURCE" ]; then
    echo "Error: BACKUP_SOURCE environment variable is not set"
    echo "Please set it in your .env file or export it in your shell"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_SCRIPT="$SCRIPT_DIR/main.sh"
CRON_JOB="0 0 * * * cd $SCRIPT_DIR/.. && BACKUP_SECRET='$BACKUP_SECRET' BACKUP_SOURCE='$BACKUP_SOURCE' $MAIN_SCRIPT save -p '$BACKUP_SOURCE' >> $SCRIPT_DIR/../logfile.log 2>&1"

case "$option" in
    start)
        if crontab -l | grep -q "$MAIN_SCRIPT"; then
            echo "Automatic backup is already scheduled."
        else
            (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
            echo "Automatic daily backup has been scheduled."
        fi
        ;;
    stop)
        if crontab -l | grep -q "$MAIN_SCRIPT"; then
            crontab -l | grep -v "$MAIN_SCRIPT" | crontab -
            echo "Automatic daily backup has been stopped."
        else
            echo "No automatic backup was scheduled."
        fi
        ;;
    *)
        echo "Error: Invalid option '$option'"
        usage
        exit 1
        ;;
esac
