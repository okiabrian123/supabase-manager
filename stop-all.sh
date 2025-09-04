#!/bin/bash

echo "🛑 Stopping Supabase Multi-Instance Setup"

# Stop Cloudflare Tunnel
echo "☁️  Stopping Cloudflare Tunnel..."
pkill -f "cloudflared tunnel"

# Stop the full Supabase stack
echo "🐳 Stopping Full Supabase Stack..."
cd .
docker-compose -f supabase-full-stack.yml down

# Stop manager services
echo "🐳 Stopping Supabase Manager..."
docker-compose down

echo ""
echo "✅ All services stopped!"
echo "======================"