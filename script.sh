#!/bin/bash

echo "Updating package lists..."
apt-get update

echo "Installing curl..."
apt-get install -y curl

echo "Public IP:"
curl -s ifconfig.co

echo
echo "Done."
