#!/bin/bash
echo "Performing internal health validation..."
# Adjust the port (e.g., 3000) and endpoint route to match your Node.js config
curl --silent --fail http://localhost:3000/health || exit 1
