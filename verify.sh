#!/bin/bash
set -e

source ./variables.sh
source ./state.env

echo "Verifying Minecraft server"
echo "PUBLIC_IP=$PUBLIC_IP"

echo
echo "Testing Minecraft port 25565 - nmap"
nmap -sV -Pn -p T:25565 "$PUBLIC_IP" || true

echo
echo "Testing Minecraft port 25565 - netcat"
nc -vz "$PUBLIC_IP" 25565 || true
