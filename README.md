# Linux Server Setup & Security Lab

A hands-on Linux server administration and security project built on Ubuntu 26.04 LTS running under WSL2.

## Project Overview

This project demonstrates the setup, hardening, monitoring, and automation of a Linux server environment.

The project includes:

* Linux user and group management
* SSH configuration and hardening
* SSH key-based authentication
* Nginx web server
* UFW firewall
* Systemd service management
* Server logging and monitoring
* Bash automation
* Automated backups
* Backup restoration testing
* Git version control
* Technical documentation

## Architecture

```text
                    Host / Network
                         |
                    SSH :22
                    HTTP :80
                         |
                         v
              +----------------------+
              |   Ubuntu 26.04 LTS   |
              |        WSL2          |
              |                      |
              |  +----------------+  |
              |  |     OpenSSH    |  |
              |  +----------------+  |
              |                      |
              |  +----------------+  |
              |  |     Nginx      |  |
              |  +----------------+  |
              |                      |
              |  +----------------+  |
              |  |      UFW       |  |
              |  +----------------+  |
              |                      |
              |  +----------------+  |
              |  | Bash Automation |  |
              |  +----------------+  |
              |                      |
              |  +----------------+  |
              |  |    Systemd     |  |
              |  +----------------+  |
              +----------+-----------+
                         |
                         v
                 Backup Storage
```

## Environment

| Component        | Details             |
| ---------------- | ------------------- |
| Operating System | Ubuntu 26.04 LTS    |
| Environment      | WSL2                |
| Architecture     | x86_64              |
| CPU              | Intel Core i5-8350U |
| Logical CPUs     | 8                   |
| Memory           | ~3.7 GiB            |
| Swap             | 1 GiB               |
| Disk             | ~1 TB               |
| Init System      | systemd             |
| Web Server       | Nginx               |
| SSH Server       | OpenSSH             |
| Firewall         | UFW                 |
| Automation       | Bash                |
| Version Control  | Git                 |

## User Management

Dedicated administrative accounts were configured for server administration.

### Users

* `hashim` — primary Linux user
* `sysadmin` — system administration account
* `opsadmin` — operations administration account

`opsadmin` was configured with sudo access.

SSH access is restricted to:

```text
opsadmin
```

## SSH Security

OpenSSH was installed and configured with security hardening.

Implemented security controls:

* ED25519 SSH key authentication
* Password authentication disabled
* Root SSH login disabled
* Keyboard-interactive authentication disabled
* X11 forwarding disabled
* Maximum authentication attempts limited to 3
* Login grace time limited to 30 seconds
* SSH access restricted to `opsadmin`

Effective SSH configuration:

```text
Port 22
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
X11Forwarding no
MaxAuthTries 3
LoginGraceTime 30
AllowUsers opsadmin
```

SSH configuration was validated using:

```bash
sudo sshd -t
sudo sshd -T
```

## Nginx Web Server

Nginx was installed and configured as the web server.

Website directory:

```text
/var/www/linux-server
```

Custom Nginx configuration:

```text
/etc/nginx/sites-available/linux-server
```

Enabled site:

```text
/etc/nginx/sites-enabled/linux-server
```

The default Nginx site was removed.

Configuration validation:

```bash
sudo nginx -t
```

HTTP testing:

```bash
curl -I http://localhost
```

Expected response:

```text
HTTP/1.1 200 OK
```

## Firewall

UFW was configured using a default-deny incoming policy.

Configuration:

```text
Default incoming: deny
Default outgoing: allow
```

Allowed services:

```text
22/tcp  SSH
80/tcp  HTTP
```

Firewall verification:

```bash
sudo ufw status numbered
```

Expected rules include:

```text
22/tcp ALLOW IN
80/tcp ALLOW IN
```

## Logging & Monitoring

Systemd journal and service logs are used to monitor the server.

Useful commands:

```bash
sudo journalctl -u ssh --no-pager
```

```bash
sudo journalctl -u nginx --no-pager
```

Nginx access log:

```text
/var/log/nginx/access.log
```

Nginx error log:

```text
/var/log/nginx/error.log
```

UFW logs can be checked through:

```bash
sudo journalctl -k | grep -i ufw
```

## Health Check

A Bash health-check script was created:

```text
scripts/health-check.sh
```

It checks:

* SSH service
* Nginx service
* Firewall status
* HTTP availability
* Disk usage
* Memory usage

Run it with:

```bash
sudo /home/hashim/linux-server-setup/scripts/health-check.sh
```

## Backup Automation

Automated backups are stored in:

```text
/var/backups/linux-server
```

The backup script is:

```text
scripts/backup.sh
```

The backup contains:

* Website files
* Nginx configuration
* SSH hardening configuration
* UFW rules
* Backup manifest

Each backup is timestamped.

A SHA-256 checksum is also generated for backup integrity verification.

Run a backup manually:

```bash
sudo /home/hashim/linux-server-setup/scripts/backup.sh
```

## Automated Backups

Systemd is used to schedule backups.

Check the backup timer:

```bash
systemctl list-timers --all | grep linux-server-backup
```

The timer runs the backup automatically.

## Backup Restoration

Backups can be safely tested by extracting them into a temporary directory.

Example:

```bash
BACKUP=$(sudo find /var/backups/linux-server -name "*.tar.gz" | sort | tail -n 1)

sudo mkdir -p /tmp/linux-server-restore-test

sudo tar -xzf "$BACKUP" -C /tmp/linux-server-restore-test
```

Restoration files can then be inspected without modifying the live server.

## Security Principles

The project applies several basic Linux security principles:

### Least Privilege

Administrative access is provided through dedicated accounts rather than direct root SSH access.

### Key-Based Authentication

SSH public-key authentication is used instead of password authentication.

### Default-Deny Firewall

Incoming network traffic is denied by default and only required services are allowed.

### Service Validation

SSH and Nginx configurations are tested before and after changes.

### Backup Integrity

Backups are protected with SHA-256 checksums.

## Project Structure

```text
linux-server-setup/
│
├── README.md
│
├── docs/
│   ├── architecture.md
│   ├── security.md
│   └── troubleshooting.md
│
├── scripts/
│   ├── backup.sh
│   └── health-check.sh
│
└── screenshots/
```

## Verification

### Check SSH

```bash
sudo systemctl status ssh --no-pager
```

### Check SSH Hardening

```bash
sudo sshd -T | grep -E '^(permitrootlogin|pubkeyauthentication|passwordauthentication|kbdinteractiveauthentication|x11forwarding|maxauthtries|logingracetime|allowusers)'
```

### Check Nginx

```bash
sudo systemctl status nginx --no-pager
```

```bash
sudo nginx -t
```

### Test Website

```bash
curl -I http://localhost
```

### Check Firewall

```bash
sudo ufw status numbered
```

### Check Listening Services

```bash
sudo ss -tulpn
```

### Check Backups

```bash
sudo ls -lh /var/backups/linux-server
```

### Run Health Check

```bash
sudo /home/hashim/linux-server-setup/scripts/health-check.sh
```

## Skills Demonstrated

* Linux Administration
* Ubuntu
* WSL2
* Bash Scripting
* Systemd
* OpenSSH
* SSH Hardening
* Nginx
* UFW
* Networking
* Linux Permissions
* Logging
* Monitoring
* Backup Automation
* Disaster Recovery Testing
* Git
* Technical Documentation

## WSL2 Limitation

This project runs inside WSL2 rather than on a dedicated physical or cloud server.

Therefore, UFW inside WSL2 should not be considered equivalent to a cloud-provider perimeter firewall or the Windows host firewall.

The project is intended as a controlled Linux administration and security laboratory demonstrating practical server-management concepts.

## Project Status

```text
[✓] Linux environment configured
[✓] Users and groups configured
[✓] Sudo access configured
[✓] SSH installed
[✓] SSH key authentication configured
[✓] SSH hardened
[✓] Nginx installed
[✓] Nginx website configured
[✓] UFW configured
[✓] Logging configured
[✓] Health check created
[✓] Backup automation created
[✓] Backup restoration tested
[✓] Systemd backup timer configured
[✓] Git repository configured
[✓] Documentation completed
```

## Author

**Hashim Khan**

Linux • Networking • Cloud • Infrastructure • Security
