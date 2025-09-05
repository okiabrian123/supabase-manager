# Cloudflare Tunnel Setup for supabase-okiabrian.my.id

## Prerequisites

1. A domain (`okiabrian.my.id`) registered and managed by Cloudflare
2. Cloudflare Tunnel credentials (already set up in this environment)

## Configuration

The tunnel has already been configured with the following settings:

- Tunnel Name: `supabase-tunnel`
- Tunnel ID: `a8b5c87a-f853-4a0d-b4a2-6c26620079ec`
- Credentials file: `/root/.cloudflared/a8b5c87a-f853-4a0d-b4a2-6c26620079ec.json`
- Configuration file: `/root/supabase_multi-instance/cloudflared-custom.yml`

## Method 1: Public Hostname Configuration (Recommended)

1. **Log in to Cloudflare Dashboard**
   - Visit https://dash.cloudflare.com
   - Log in with your credentials

2. **Navigate to Tunnel Settings**
   - In the left sidebar, go to "Zero Trust" → "Network" → "Tunnels"
   - Find and click on the tunnel with ID `a8b5c87a-f853-4a0d-b4a2-6c26620079ec`

3. **Add Public Hostname**
   - Click "Add a public hostname"
   - Fill in:
     - Subdomain: `supabase`
     - Domain: `okiabrian.my.id`
     - Type: `HTTP`
     - URL: `http://localhost:8090`
   - Click "Save hostname"

## Method 2: Direct DNS Configuration

1. **Log in to Cloudflare Dashboard**
   - Visit https://dash.cloudflare.com
   - Log in with your credentials

2. **Navigate to DNS Settings**
   - Select your domain `okiabrian.my.id`
   - Go to the DNS section

3. **Add CNAME Record**
   - Click "Add Record"
   - Fill in:
     - Type: `CNAME`
     - Name: `supabase`
     - Target: `a8b5c87a-f853-4a0d-b4a2-6c26620079ec.cfargotunnel.com`
     - Proxy status: Proxied (orange cloud)
   - Click "Save"

## Starting the Services

To start all services including Cloudflare Tunnel:

```bash
cd /root/supabase_multi-instance
./start-all.sh
```

## Accessing the Application

Once configured, you can access the Supabase Manager at:
- Local: http://localhost:8090
- Public: http://supabase-okiabrian.my.id

## Stopping the Services

To stop all services:

```bash
cd /root/supabase_multi-instance
./stop-all.sh
```