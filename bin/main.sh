#!/bin/bash

usage() {
    echo "Usage: $0 <action> [params...]"
    echo "Actions:"
    echo "  save     - Save a backup"
    echo "  load     - Load a backup"
    echo "  list     - List available backups"
    echo "  automate - Start or stop automatic daily backups"
    echo "  help     - Display this help message"
}

check_dependencies() {
    local missing_deps=()
    for cmd in tar split git openssl crontab; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=($cmd)
        fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Error: The following dependencies are missing: ${missing_deps[*]}"
        echo "Please install them and try again."
        exit 1
    fi
}
check_dependencies

check_git_setup() {
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        echo "Error: Not in a git repository. Please initialize git in this directory."
        exit 1
    fi

    if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
        echo "Error: Git user name or email is not set. Please configure git."
        exit 1
    fi
}
check_git_setup

load_env() {
    if [ -f .env ]; then
        export $(grep -v '^#' .env | xargs)
    fi

    if [ -z "$BACKUP_SECRET" ]; then
        echo "Error: BACKUP_SECRET environment variable is not set"
        echo "Please set it in your .env file or export it in your shell"
        exit 1
    fi
}
load_env

if [ $# -eq 0 ]; then
    echo "Error: No action specified"
    usage
    exit 1
fi

action="$1"
shift

action_dir="$(dirname "$0")"
action_script="${action_dir}/${action}.sh"
if [ ! -f "$action_script" ]; then
    echo "Error: Invalid action '$action'"
    usage
    exit 1
fi

export BACKUP_SECRET
export BACKUP_SOURCE

exec "$action_script" "$@"
