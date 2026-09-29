#!/bin/bash
echo "Installing Node.js 24 and development utilities..."

# Ensure system package manifests are refreshed and curl is installed
apt-get update && apt-get install -y curl

echo "Checking Curl version..."
curl --version

# Download and run the NVM installation script
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# CRUCIAL FIX: Manually load NVM directly into the current execution thread
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Verifying NVM installation version..."
nvm --version

# Install Node.js 24 specifically (instead of generic LTS)
echo "Installing Node.js 24..."
nvm install 24
nvm use 24
nvm alias default 24

echo "Verifying Node.js and npm versions..."
node --version
npm --version

# Install PM2 globally using the newly mapped node environment path context
echo "Installing process manager..."
npm install pm2 -g
