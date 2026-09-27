#!/bin/bash

set -e

echo "===== Linux Server Health Check ====="
echo

echo "[1] SSH"
systemctl is-active --quiet ssh && echo "SSH: OK" || echo "SSH: FAILED"

echo
echo "[2] Nginx"
systemctl is-active --quiet nginx && echo "Nginx: OK" || echo "Nginx: FAILED"

echo
echo "[3] Firewall"
ufw status | head -n 6

echo
echo "[4] HTTP Test"
curl -fsS http://localhost >/dev/null && echo "HTTP: OK" || echo "HTTP: FAILED"

echo
echo "[5] Disk"
df -h /

echo
echo "[6] Memory"
free -h

echo
echo "===== Health Check Complete ====="
