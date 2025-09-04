#!/bin/bash

echo "🚀 Starting Full Supabase Stack"

# Start the full Supabase stack with the proper configuration
cd .
docker-compose -f supabase-full-stack.yml up -d

# Wait a moment for services to start
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
if docker ps | grep -q "supabase"; then
    echo "✅ Supabase services are running"
else
    echo "❌ Supabase services failed to start"
    exit 1
fi

echo ""
echo "🎉 Full Supabase Stack Started!"
echo "==============================="
echo "🗄️  Supabase Manager: http://localhost:8090"
echo "📦 Database: localhost:5432"
echo "🌐 API Gateway: http://localhost:8081"
echo "🎨 Studio: http://localhost:3001"
echo ""
echo "To stop services, run: docker-compose -f supabase-full-stack.yml down"