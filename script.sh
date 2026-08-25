#!/bin/bash

set -e

echo "================================"
echo "     WireGuard Lab"
echo "================================"

# ==========================================
# تنظیمات
# ==========================================

PHONE_PUBLIC_KEY="2Wm5GaRrt39+H4HiRnGlShccgCPFjLx4I2qMn+o7Zks="

SERVER_IP="10.99.0.1"
PHONE_IP="10.99.0.2"
WG_PORT="51820"

# ==========================================
# بررسی Public Key گوشی
# ==========================================

if [ "$PHONE_PUBLIC_KEY" = "YOUR_PHONE_PUBLIC_KEY" ]; then
    echo
    echo "ERROR: Put your phone WireGuard public key"
    echo "inside PHONE_PUBLIC_KEY first."
    exit 1
fi

# ==========================================
# نصب پکیج‌ها
# ==========================================

echo
echo "[1/7] Updating packages..."

apt-get update -qq

echo "[2/7] Installing WireGuard and network tools..."

DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    wireguard \
    iproute2 \
    iptables

# ==========================================
# ساخت پوشه
# ==========================================

echo
echo "[3/7] Creating WireGuard directory..."

mkdir -p /etc/wireguard
chmod 700 /etc/wireguard

umask 077

# ==========================================
# ساخت کلید سرور
# ==========================================

echo
echo "[4/7] Generating server keys..."

wg genkey > /etc/wireguard/server_private.key

cat /etc/wireguard/server_private.key \
    | wg pubkey > /etc/wireguard/server_public.key

SERVER_PRIVATE=$(cat /etc/wireguard/server_private.key)
SERVER_PUBLIC=$(cat /etc/wireguard/server_public.key)

echo
echo "Server Public Key:"
echo "$SERVER_PUBLIC"

echo
echo "Phone Public Key:"
echo "$PHONE_PUBLIC_KEY"

# ==========================================
# ساخت کانفیگ WireGuard
# ==========================================

echo
echo "[5/7] Creating server configuration..."

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $SERVER_PRIVATE
Address = $SERVER_IP/24
ListenPort = $WG_PORT

[Peer]
PublicKey = $PHONE_PUBLIC_KEY
AllowedIPs = $PHONE_IP/32
EOF

chmod 600 /etc/wireguard/wg0.conf

# ==========================================
# نمایش کانفیگ بدون Private Key
# ==========================================

echo
echo "================================"
echo "WireGuard Server Configuration"
echo "================================"

echo "[Interface]"
echo "Address = $SERVER_IP/24"
echo "ListenPort = $WG_PORT"

echo
echo "[Peer]"
echo "PublicKey = $PHONE_PUBLIC_KEY"
echo "AllowedIPs = $PHONE_IP/32"

# ==========================================
# اجرای WireGuard
# ==========================================

echo
echo "[6/7] Starting WireGuard..."

mkdir -p /run/wireguard

wg-quick up wg0 || true

echo
echo "================================"
echo "WireGuard Status"
echo "================================"

wg show || true

echo
echo "================================"
echo "Network Interface"
echo "================================"

ip addr show wg0 || true

echo
echo "================================"
echo "Listening Ports"
echo "================================"

ss -lunp 2>/dev/null | grep 51820 || true

# ==========================================
# اطلاعات کلاینت
# ==========================================

echo
echo "================================"
echo "PHONE CONFIG INFORMATION"
echo "================================"

echo
echo "Phone Address:"
echo "$PHONE_IP/24"

echo
echo "Server Address:"
echo "$SERVER_IP"

echo
echo "Server Public Key:"
echo "$SERVER_PUBLIC"

echo
echo "WireGuard Port:"
echo "$WG_PORT/UDP"

echo
echo "IMPORTANT:"
echo "The phone's PrivateKey must remain on the phone."
echo "Do NOT put the phone PrivateKey in GitHub."

# ==========================================
# زنده نگه داشتن محیط
# ==========================================

echo
echo "================================"
echo "Lab will remain active for 15 minutes"
echo "================================"

sleep 15m

echo
echo "15 minutes finished."
echo "Stopping WireGuard..."

wg-quick down wg0 || true

echo "Done."
