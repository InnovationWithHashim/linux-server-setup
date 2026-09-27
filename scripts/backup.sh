#!/bin/bash

set -euo pipefail

BACKUP_DIR="/var/backups/linux-server"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/linux-server-$TIMESTAMP.tar.gz"
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

echo "Starting Linux server backup..."

mkdir -p "$TEMP_DIR/website"
mkdir -p "$TEMP_DIR/nginx"
mkdir -p "$TEMP_DIR/ssh"
mkdir -p "$TEMP_DIR/ufw"

cp -a /var/www/linux-server "$TEMP_DIR/website/"
cp -a /etc/nginx/sites-available/linux-server "$TEMP_DIR/nginx/"
cp -a /etc/nginx/nginx.conf "$TEMP_DIR/nginx/"
cp -a /etc/ssh/sshd_config.d/99-server-hardening.conf "$TEMP_DIR/ssh/"
cp -a /etc/ufw/user.rules "$TEMP_DIR/ufw/" 2>/dev/null || true
cp -a /etc/ufw/user6.rules "$TEMP_DIR/ufw/" 2>/dev/null || true

cat > "$TEMP_DIR/manifest.txt" <<MANIFEST
Linux Server Backup
Created: $(date)
Hostname: $(hostname)
OS: $(. /etc/os-release && echo "$PRETTY_NAME")
Kernel: $(uname -r)
MANIFEST

tar -czf "$BACKUP_FILE" -C "$TEMP_DIR" .

sha256sum "$BACKUP_FILE" > "$BACKUP_FILE.sha256"

chmod 600 "$BACKUP_FILE" "$BACKUP_FILE.sha256"

echo
echo "Backup completed successfully:"
echo "$BACKUP_FILE"
echo
echo "Checksum:"
cat "$BACKUP_FILE.sha256"
