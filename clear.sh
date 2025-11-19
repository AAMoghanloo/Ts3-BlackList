#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

HOSTS_FILE="/etc/hosts"
LINE1="blacklist.teamspeak.com       127.0.0.1"
LINE2="blacklist2.teamspeak.com      127.0.0.1"

if [[ $EUID -ne 0 ]]; then
    echo -e "  ${RED}Error: This script must be run as root (sudo).${RESET}"
    exit 1
fi

append_if_missing() {
    local line="$1"
    if grep -Fxq "$line" "$HOSTS_FILE"; then
        echo -e "  ${GREEN}Already exists: $line${RESET}"
    else
        echo "$line" >> "$HOSTS_FILE"
        if [[ $? -eq 0 ]]; then
            echo -e "  ${GREEN}Added: $line${RESET}"
        else
            echo -e "  ${RED}Failed to add: $line${RESET}"
            exit 1
        fi
    fi
}

append_if_missing "$LINE1"
append_if_missing "$LINE2"

if systemctl restart systemd-networkd; then
    echo -e "  ${GREEN}Network service restarted successfully.${RESET}"
else
    echo -e "  ${RED}Failed to restart network service.${RESET}"
    exit 1
fi

echo -e "  ${GREEN}Please close and reopen your TeamSpeak client to apply changes.${RESET}"

