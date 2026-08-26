#!/bin/bash
set -e

# ==============================
# CONFIG
# ==============================

ROOT_PASSWORD='radin123#'

# اختیاری:
# کلید Tailscale را اینجا بگذار
# مثال: tskey-auth-xxxxxxxx
TS_AUTHKEY='tskey-auth-kQPFceLKXK11CNTRL-e82oujkhKE2vr4BYYL7YE2EMZ5BWNfxBX'

# ==============================
# CHECK ROOT
# ==============================

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: Run this script as root."
    exit 1
fi

if [ "$ROOT_PASSWORD" = "CHANGE_ME_TO_A_STRONG_PASSWORD" ] || [ -z "$ROOT_PASSWORD" ]; then
    echo "ERROR: Set ROOT_PASSWORD in the script first."
    exit 1
fi

echo "=============================="
echo " Installing packages"
echo "=============================="

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y curl openssh-server

# ==============================
# ROOT PASSWORD
# ==============================

echo "Setting root password..."
echo "root:$ROOT_PASSWORD" | chpasswd

# ==============================
# SSH CONFIG
# ==============================

echo "Configuring SSH..."

mkdir -p /run/sshd

# Root login
if grep -qE '^[#[:space:]]*PermitRootLogin' /etc/ssh/sshd_config; then
    sed -i 's/^[#[:space:]]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
else
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
fi

# Password authentication
if grep -qE '^[#[:space:]]*PasswordAuthentication' /etc/ssh/sshd_config; then
    sed -i 's/^[#[:space:]]*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
else
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
fi

# Validate SSH configuration
/usr/sbin/sshd -t

# ==============================
# INSTALL TAILSCALE
# ==============================

echo "=============================="
echo " Installing Tailscale"
echo "=============================="

curl -fsSL https://tailscale.com/install.sh | sh

# ==============================
# START TAILSCALED
# ==============================

echo "Starting tailscaled..."

mkdir -p /var/lib/tailscale
mkdir -p /var/run/tailscale

# اگر قبلاً اجرا شده باشد، نادیده بگیر
if ! pgrep -x tailscaled >/dev/null 2>&1; then
    tailscaled \
        --state=/var/lib/tailscale/tailscaled.state \
        > /var/log/tailscaled.log 2>&1 &
fi

echo "Waiting for tailscaled..."

for i in $(seq 1 20); do
    if tailscale status >/dev/null 2>&1; then
        echo "tailscaled is ready."
        break
    fi
    sleep 1
done

# ==============================
# TAILSCALE LOGIN
# ==============================

echo "=============================="
echo " Connecting to Tailscale"
echo "=============================="

if [ -n "$TS_AUTHKEY" ]; then
    tailscale up --authkey="$TS_AUTHKEY"
else
    echo ""
    echo "No Tailscale auth key was provided."
    echo "Run:"
    echo ""
    echo "    tailscale up"
    echo ""
    echo "and open the authentication URL."
    echo ""
fi

# ==============================
# START SSH
# ==============================

echo "Starting SSH..."

mkdir -p /run/sshd

if ! pgrep -x sshd >/dev/null 2>&1; then
    /usr/sbin/sshd
fi

# ==============================
# INFORMATION
# ==============================

echo ""
echo "=============================="
echo "        TAILSCALE INFO"
echo "=============================="

echo "Tailscale status:"
tailscale status || true

echo ""
echo "Tailscale IPv4:"
tailscale ip -4 || true

echo ""
echo "=============================="
echo "          SSH INFO"
echo "=============================="

echo "User: root"
echo "Port: 22"
echo "SSH: READY"

echo ""
echo "=============================="
echo "         LOG FILES"
echo "=============================="

echo "Tailscale log:"
echo "/var/log/tailscaled.log"

echo ""
echo "Done."

sleep 5m
