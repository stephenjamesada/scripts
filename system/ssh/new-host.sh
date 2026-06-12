#!/usr/bin/env bash

FILE=~/.ssh/config
HOST=$1
IP=$2
USER=$3
PORT=$4

(( $# == 4 )) || {
    echo "Usage: $0 <host> <ip> <user> <port>"
    exit 1
}

if ipcalc "$IP" >/dev/null 2>&1; then
    echo "$IP is valid."
else
    echo "$IP is invalid."
fi

if (( PORT < 1 || PORT > 65535 )); then
    echo "Not a valid port." >&2
    exit 1
fi

if [ ! -f "$FILE" ]; then
    touch $FILE
else
    echo -e "Host $HOST\n    HostName $IP\n    User $USER\n    Port $PORT" >> $FILE
    echo "FILE=$FILE"
    echo "HOST=$HOST"
    echo "HOSTNAME=$IP"
    echo "USER=$USER"
    echo "PORT=$PORT"
fi
