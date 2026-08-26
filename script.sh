#!/bin/bash
set -e

# =========================
# تنظیمات
# =========================
ROOT_PASSWORD='radin123#'

# =========================
# نصب
# =========================
apt-get update
apt-get install -y curl openssh-server

# =========================
# تنظیم پسورد root
# =========================
echo "root:${ROOT_PASSWORD}" | chpasswd

# =========================
# فعال کردن ورود root با SSH
# =========================
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# =========================
# نصب Tailscale
# =========================
curl -fsSL https://tailscale.com/install.sh | sh

# اتصال به Tailnet
tailscale up

# =========================
# اجرای SSH
# =========================
mkdir -p /run/sshd
/usr/sbin/sshd

echo "=== Tailscale IP ==="
tailscale ip -4

echo "=== SSH ==="
echo "User: root"
echo "SSH is ready."

sleep 5m
