#!/bin/bash

echo "=== Host ==="
hostname
cat /etc/os-release

echo
echo "=== IP addresses ==="
hostname -I

echo
echo "=== Network interfaces ==="
ip addr

echo
echo "=== Routes ==="
ip route

echo
echo "=== Public IP ==="
apt-get update -qq
apt-get install -y -qq curl
curl -s https://api.ipify.org
echo

echo
echo "=== SSH ==="
apt-get install -y -qq openssh-server
mkdir -p /run/sshd
/usr/sbin/sshd

echo "SSH is listening:"
ss -lntp | grep ':22' || true

echo
echo "Keeping container alive..."
sleep 3h
