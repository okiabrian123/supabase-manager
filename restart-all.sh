#!/bin/bash

echo "🔄 Restarting Supabase Multi-Instance Setup"

# Stop all services first
./stop-all.sh

# Wait a moment
sleep 5

# Start all services
./start-all.sh