#!/bin/bash
set -e

# ==============================
#       YOUR SETTINGS
# ==============================

ROOT_PASSWORD="radin123#"
TS_AUTHKEY="tskey-auth-kMVzgEtvg921CNTRL-irwUFn8nqbNLo7fRMy3kbNxqN1324Zp8b"

# ==============================

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y curl openssh-server iproute2

echo "=== Installing Tailscale ==="
curl -fsSL https://tailscale.com/install.sh | sh

echo "=== Configuring SSH ==="

echo "root:$ROOT_PASSWORD" | chpasswd

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

grep -q '^PermitRootLogin' /etc/ssh/sshd_config || \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

grep -q '^PasswordAuthentication' /etc/ssh/sshd_config || \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

mkdir -p /run/sshd
/usr/sbin/sshd -t

echo "=== Starting tailscaled ==="

mkdir -p /var/lib/tailscale
mkdir -p /run/tailscale

tailscaled \
    --state=/var/lib/tailscale/tailscaled.state \
    --socket=/run/tailscale/tailscaled.sock \
    > /tmp/tailscaled.log 2>&1 &

echo "tailscaled started"

echo "=== Waiting for tailscaled ==="

READY=0

for i in $(seq 1 30); do
    if tailscale \
        --socket=/run/tailscale/tailscaled.sock \
        status >/dev/null 2>&1
    then
        READY=1
        echo "tailscaled is ready"
        break
    fi

    sleep 1
done

if [ "$READY" != "1" ]; then
    echo "ERROR: tailscaled failed to start"
    echo "========== LOG =========="
    cat /tmp/tailscaled.log
    exit 1
fi

echo "=== Connecting to Tailscale ==="

tailscale \
    --socket=/run/tailscale/tailscaled.sock \
    up \
    --auth-key="$TS_AUTHKEY"

echo "=== Starting SSH ==="

/usr/sbin/sshd

echo ""
echo "=============================="
echo "       TAILSCALE STATUS"
echo "=============================="

tailscale \
    --socket=/run/tailscale/tailscaled.sock \
    status

echo ""
echo "=============================="
echo "       TAILSCALE IP"
echo "=============================="

tailscale \
    --socket=/run/tailscale/tailscaled.sock \
    ip -4

echo ""
echo "=============================="
echo "          SSH READY"
echo "=============================="

echo "User: root"
echo "Port: 22"

echo ""
echo "Keeping runner alive for 5 minutes..."

sleep 5m
