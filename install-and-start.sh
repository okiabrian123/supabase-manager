#!/bin/bash

echo "🚀 Installing and Starting Supabase Manager with Auto-start"

# Run the setup script
echo "🔧 Setting up auto-start service..."
sudo /root/supabase_multi-instance/setup-autostart.sh

# Start the service
echo "🏃 Starting Supabase Manager service..."
sudo systemctl start supabase-manager.service

# Check if service started successfully
if systemctl is-active supabase-manager.service &> /dev/null; then
  echo "✅ Supabase Manager service started successfully!"
  echo ""
  echo "The Supabase Manager is now running and will automatically start on system boot."
  echo ""
  echo "🗄️  Supabase Manager: http://localhost:8090"
  echo "📦 Database: localhost:5432"
  echo "🌐 API Gateway: http://localhost:8081"
  echo "🎨 Studio: http://localhost:3001"
else
  echo "❌ Failed to start Supabase Manager service"
  echo "Check the service status with: sudo systemctl status supabase-manager.service"
  exit 1
fi