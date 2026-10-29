#!/bin/bash
# setup.sh - Prepares the local environment for Docker Compose

echo "Setting up OpenCart source..."

# Clean up any existing directory to avoid conflicts
rm -rf opencart_src

# Download and extract OpenCart 3.0.3.8
mkdir -p opencart_src
cd opencart_src
curl -L https://github.com/opencart/opencart/releases/download/3.0.3.8/opencart-3.0.3.8.zip -o opencart.zip
unzip -q opencart.zip
mv upload/* .
rm -rf upload opencart.zip

# Create required config files
cp config-dist.php config.php
cp admin/config-dist.php admin/config.php

# Set permissions for Fedora SELinux and Apache
chmod -R 777 system/storage image config.php admin/config.php

echo "OpenCart source is ready!"
echo "You can now run: docker compose up -d --build"