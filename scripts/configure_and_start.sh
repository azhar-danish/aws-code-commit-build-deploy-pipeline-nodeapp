#!/bin/bash

set -e

export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

TARGET_DIR="/var/www/demo-app-dev"

echo "Changing to application directory..."
cd "$TARGET_DIR"

echo "Application files:"
ls -lah

echo "Node version:"
node --version

echo "NPM version:"
npm --version

echo "Installing dependencies..."
npm install

echo "Stopping previous application..."
pm2 delete demo-app-dev || true

echo "Starting application..."
pm2 start index.js --name demo-app-dev

pm2 save

echo "PM2 status:"
pm2 status