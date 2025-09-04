#!/bin/bash

echo "🔍 Checking Cloudflare Tunnel Status"

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo "❌ cloudflared is not installed"
    exit 1
fi

echo "✅ cloudflared is installed"

# Check if tunnel is running
if pgrep -f "cloudflared.*tunnel" > /dev/null; then
    echo "✅ Cloudflare Tunnel is running"
    
    # Show tunnel process info
    echo ""
    echo "=== Tunnel Process Info ==="
    pgrep -af "cloudflared.*tunnel"
    
    # Show active tunnels
    echo ""
    echo "=== Active Tunnels ==="
    cloudflared tunnel list 2>/dev/null || echo "Unable to list tunnels (may require authentication)"
else
    echo "❌ Cloudflare Tunnel is not running"
    
    echo ""
    echo "To start the tunnel, run:"
    echo "  cloudflared tunnel --config /root/supabase_multi-instance/cloudflared-custom.yml run a8b5c87a-f853-4a0d-b4a2-6c26620079ec &"
fi

echo ""
echo "=== Tunnel Configuration ==="
echo "Config file: /root/supabase_multi-instance/cloudflared-custom.yml"
echo "Tunnel ID: a8b5c87a-f853-4a0d-b4a2-6c26620079ec"
echo ""
echo "Ingress rules:"
grep -A 10 "ingress:" /root/supabase_multi-instance/cloudflared-custom.yml