#!/bin/sh

set -e

if [[ $EUID -ne 0 ]]; then
    echo "Script must be run with sudo to update the system."
    exit 1
fi

if apt-get update && apt-get full-upgrade; then
    echo "Update/upgrade process complete. Removing unused packages/services..."
    sleep 1
    
    if apt-get autoremove --purge && apt-get clean; then
        sleep 1
        echo "Unused package and service removal process complete!"
    else
        echo "Oops! Something went wrong during package/service removal." >&2
    fi
else
    echo "Oops! Something went wrong during the update/upgrade process." >&2
fi
