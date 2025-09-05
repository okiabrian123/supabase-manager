#!/bin/bash

echo "🔍 Testing Supabase Services Accessibility"

# Test localhost services
echo ""
echo "=== Testing Localhost Services ==="

# Test Supabase Manager (port 8090)
echo "Testing Supabase Manager (localhost:8090)..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8090 | grep -q "200"; then
    echo "✅ Supabase Manager is accessible"
else
    echo "❌ Supabase Manager is not accessible"
fi

# Test Supabase API (port 8081)
echo "Testing Supabase API (localhost:8081)..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 | grep -q "200\|404"; then
    echo "✅ Supabase API is accessible"
else
    echo "❌ Supabase API is not accessible"
fi

# Test Supabase Studio (port 3001)
echo "Testing Supabase Studio (localhost:3001)..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3001 | grep -q "200\|302"; then
    echo "✅ Supabase Studio is accessible"
else
    echo "❌ Supabase Studio is not accessible"
fi

# Test Docker containers
echo ""
echo "=== Testing Docker Containers ==="
if docker ps | grep -q "supabase"; then
    echo "✅ Supabase containers are running"
    echo "Running containers:"
    docker ps | grep "supabase" | awk '{print "  - " $NF}'
else
    echo "❌ No Supabase containers are running"
fi

# Test Cloudflare Tunnel
echo ""
echo "=== Testing Cloudflare Tunnel ==="
if pgrep -f "cloudflared.*tunnel" > /dev/null; then
    echo "✅ Cloudflare Tunnel is running"
else
    echo "❌ Cloudflare Tunnel is not running"
fi

echo ""
echo "📋 To test custom domain accessibility, try:"
echo "   curl -I https://supabase-okiabrian.my.id"
echo "   curl -I https://api-supabase-okiabrian.my.id"
echo "   curl -I https://studio-supabase-okiabrian.my.id"