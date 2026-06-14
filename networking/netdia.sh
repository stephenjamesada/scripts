#!/usr/bin/env bash

# TODO: Separate if blocks into different functions for cleaner code and better readability

main() {
    set -euo pipefail

    (( $# == 2 )) || {
        echo "Usage: $0 HOST PORT"
        exit 1
    }

    HOSTNAME=${1:?hostname required}
    PORT=${2:?port required}

    [[ "$PORT" =~ ^[0-9]+$ ]] || {
        echo "Port must be numeric."
        exit 1
    }

    if ((PORT < 1 || PORT > 65535)); then
        echo "$PORT is not a valid port." >&2
        exit 1
    fi

    RESOLVED=$(getent hosts "$HOSTNAME" | awk '{print $1}')
    [[ -z "$RESOLVED" ]] && { echo "Cannot resolve $HOSTNAME"; exit 1; }

    if ping -c 1 -W 2 "$HOSTNAME" &>/dev/null; then
        PING_RESULT="reachable"
    else
        PING_RESULT="unreachable"
    fi

    if ip route get "$RESOLVED" &>/dev/null; then
        ROUTE_STATUS="route exists"
    else
        ROUTE_STATUS="route does not exist"
    fi

    if dig +short "$HOSTNAME" >&/dev/null; then
        QUERY_TIME="$(dig $HOSTNAME | awk '/Query time/ {print $4}')"
    fi

    if nc -zv "$HOSTNAME" "$PORT" >&/dev/null; then
        PORT_STATUS="open"
    else
        PORT_STATUS="closed"
    fi
        

    JSON=$(jo host="$RESOLVED" port="$PORT" ping="$PING_RESULT" route-status="$ROUTE_STATUS" dns-query-time="$QUERY_TIME" port-status="$PORT_STATUS")

    echo "$JSON" | jq .
    }

main "$@"
