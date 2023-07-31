#!/bin/bash

REPO_URL="https://raw.githubusercontent.com/Akvityxs/iptables-ip-blocking-script/main/banned_ips.txt"
UREPO_URL="https://raw.githubusercontent.com/Akvityxs/iptables-ip-blocking-script/main/unbanned_ips.txt"

IPS=$(curl -s "$REPO_URL")
UIPS=$(curl -s "$UREPO_URL")

clear
echo "Installing required packages..."
apt install -y iptables tcpdump curl
clear

cd /etc/
mkdir -p iptables
iptables -A INPUT -p tcp --dport 7777 -m connlimit --connlimit-above 1 --connlimit-mask 32 -j DROP
sysctl -w net.ipv4.tcp_max_syn_backlog=1024
sysctl -w net.ipv4.tcp_synack_retries=1
sysctl -w net.ipv4.tcp_syncookies=1
clear

echo "Additional IPTables protection rules have been applied."

for IP in $IPS; do
    iptables -A INPUT -s "$IP" -j DROP
    echo "Blocked IP: $IP"
done

for UIP in $UIPS; do
    iptables -D INPUT -s "$UIP" -j DROP
    echo "Unblocked IP: $UIP"
done

iptables-save > /etc/iptables/rules.v4

echo "Script execution complete."
