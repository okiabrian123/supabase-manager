#!/bin/bash

echo "🔧 Setting up Supabase Manager Auto-start Service"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

# Check if systemd is available
if ! command -v systemctl &> /dev/null; then
  echo "❌ Systemd is not available on this system"
  exit 1
fi

# Check if service file already exists
if [ -f "/etc/systemd/system/supabase-manager.service" ]; then
  echo "⚠️  Supabase Manager service already exists"
  echo "Do you want to reinstall it? (y/N)"
  read -r response
  if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Exiting..."
    exit 0
  fi
  echo "Removing existing service..."
  systemctl stop supabase-manager.service 2>/dev/null || true
  systemctl disable supabase-manager.service 2>/dev/null || true
  rm -f /etc/systemd/system/supabase-manager.service
fi

# Create the systemd service file
echo "📝 Creating systemd service file..."

cat > /etc/systemd/system/supabase-manager.service << 'EOF'
[Unit]
Description=Supabase Multi-Instance Manager
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/root/supabase_multi-instance
ExecStart=/root/supabase_multi-instance/start-all.sh
ExecStop=/root/supabase_multi-instance/stop-all.sh
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon to recognize the new service
echo "🔄 Reloading systemd daemon..."
systemctl daemon-reload

# Enable the service to start on boot
echo "✅ Enabling service to start on boot..."
systemctl enable supabase-manager.service

# Check if service is enabled
if systemctl is-enabled supabase-manager.service &> /dev/null; then
  echo "✅ Supabase Manager auto-start service has been successfully installed and enabled!"
  echo ""
  echo "🔧 To manually start the service now:"
  echo "   sudo systemctl start supabase-manager.service"
  echo ""
  echo "🔧 To check the service status:"
  echo "   sudo systemctl status supabase-manager.service"
  echo ""
  echo "🔧 To stop the service:"
  echo "   sudo systemctl stop supabase-manager.service"
  echo ""
  echo "The Supabase Manager will now automatically start on system boot."
else
  echo "❌ Failed to enable the service"
  exit 1
fi