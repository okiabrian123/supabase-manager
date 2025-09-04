#!/bin/bash

echo "🚀 Starting Supabase Multi-Instance Setup"

# Start Docker services for manager
echo "🐳 Starting Supabase Manager..."
cd .
docker-compose up -d

# Wait a moment for manager to start
sleep 5

# Check if manager services are running
echo "🔍 Checking manager service status..."
if docker ps | grep -q "supabase-manager"; then
    echo "✅ Supabase Manager is running"
else
    echo "❌ Supabase Manager failed to start"
    exit 1
fi

# Start the full Supabase stack
echo "🐳 Starting Full Supabase Stack..."
./start-supabase.sh

# Wait a moment for all services to start
sleep 10

# Start Cloudflare Tunnel in the background with custom domain configuration
echo "☁️  Starting Cloudflare Tunnel for all custom domains..."
cloudflared tunnel --config ./cloudflared-custom.yml run a8b5c87a-f853-4a0d-b4a2-6c26620079ec &

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo "🗄️  Supabase Manager: http://localhost:8090"
echo "📦 Database: localhost:5432"
echo "🌐 API Gateway: http://localhost:8081"
echo "🎨 Studio: http://localhost:3001"
echo "☁️  Cloudflare Tunnel Manager: https://supabase.okiabrian.my.id"
echo "☁️  Cloudflare Tunnel API: https://api.supabase.okiabrian.my.id"
echo "☁️  Cloudflare Tunnel Studio: https://studio.supabase.okiabrian.my.id"
echo ""
echo "To stop manager services, run: docker-compose down"
echo "To stop full stack services, run: docker-compose -f supabase-full-stack.yml down"