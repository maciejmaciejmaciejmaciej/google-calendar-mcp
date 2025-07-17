#!/bin/bash

# Railway Deployment Script for Google Calendar MCP Server
# This script handles the deployment process on Railway

echo "🚀 Starting Google Calendar MCP Server on Railway..."

# Ensure we're in HTTP mode for Railway
export TRANSPORT=http
export HOST=0.0.0.0
export PORT=${PORT:-3000}

# Create tokens directory if it doesn't exist
mkdir -p /app/tokens

echo "📡 Starting server in HTTP mode on port $PORT..."

# Start the server
npm run start:http:public
