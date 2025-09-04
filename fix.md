# Supabase Custom Domain Setup - Fix Documentation

## Overview
This document outlines the steps taken to fix the custom domain configuration for Supabase services using Cloudflare Tunnel, and the current status of the setup.

## Issues Identified
1. Cloudflare Tunnel was not properly routing traffic to Supabase services
2. Only the Supabase Manager service was running (port 8090), but not the full Supabase stack (API on port 8080, Studio on port 3000)
3. Custom domains were returning "000" status codes indicating connectivity issues
4. Missing scripts to properly start and stop the full Supabase stack
5. Temporary PostgreSQL schemas were appearing in the project listing

## Fixes Implemented

### 1. Fixed Cloudflare Tunnel Configuration
- **File**: [start-all.sh](file:///root/supabase_multi-instance/start-all.sh)
- **Issue**: Incorrect command syntax for starting the tunnel
- **Fix**: Updated the command to include the tunnel ID:
  ```bash
  # Before (incorrect):
  cloudflared tunnel --config /root/supabase_multi-instance/cloudflared-custom.yml run &
  
  # After (correct):
  cloudflared tunnel --config /root/supabase_multi-instance/cloudflared-custom.yml run a8b5c87a-f853-4a0d-b4a2-6c26620079ec &
  ```

### 2. Updated Cloudflare Tunnel Ingress Rules
- **File**: [cloudflared-custom.yml](file:///root/supabase_multi-instance/cloudflared-custom.yml)
- **Changes**: Configured proper routing for all three domains:
  ```yaml
  ingress:
    # Route for your custom domain pointing to Supabase Manager
    - hostname: supabase.okiabrian.my.id
      service: http://localhost:8090
    # Route for Supabase API
    - hostname: api.supabase.okiabrian.my.id
      service: http://localhost:8081
    # Route for Supabase Studio
    - hostname: studio.supabase.okiabrian.my.id
      service: http://localhost:3001
    # Fallback route
    - service: http_status:404
  ```

### 3. Created Full Supabase Stack Configuration
- **Files Created**:
  - [supabase-full-stack.yml](file:///root/supabase_multi-instance/supabase-full-stack.yml) - Docker Compose for full Supabase stack
  - [start-supabase.sh](file:///root/supabase_multi-instance/start-supabase.sh) - Script to start the full stack
  - [stop-all.sh](file:///root/supabase_multi-instance/stop-all.sh) - Script to stop all services
  - [restart-all.sh](file:///root/supabase_multi-instance/restart-all.sh) - Script to restart all services
  - [test-services.sh](file:///root/supabase_multi-instance/test-services.sh) - Script to test service accessibility
  - [check-tunnel.sh](file:///root/supabase_multi-instance/check-tunnel.sh) - Script to check tunnel status

### 4. Updated Start Script to Launch Full Stack
- **File**: [start-all.sh](file:///root/supabase_multi-instance/start-all.sh)
- **Changes**: Modified to start both the manager and the full Supabase stack, with proper status checking

### 5. Updated Environment Configuration
- **Files Updated**:
  - [.env](file:///root/supabase_multi-instance/.env) - Updated ports to match service configuration
  - [supabase-full-stack.yml](file:///root/supabase_multi-instance/supabase-full-stack.yml) - Verified port mappings match environment settings

### 6. Fixed Temporary Schema Filtering
- **File**: [main.go](file:///root/supabase_multi-instance/main.go)
- **Issue**: Temporary PostgreSQL schemas (starting with `pg_temp_` and `pg_toast_temp_`) were appearing in the project listing
- **Fix**: Updated the SQL query in the `getProjects()` function to properly filter out temporary schemas using `NOT LIKE` patterns:
  ```sql
  -- Before (ineffective):
  AND REPLACE(schema_name, 'pg_temp_', '') = schema_name
  AND REPLACE(schema_name, 'pg_toast_temp_', '') = schema_name
  
  -- After (effective):
  AND schema_name NOT LIKE 'pg_temp_%'
  AND schema_name NOT LIKE 'pg_toast_temp_%'
  ```
- **Documentation**: Added detailed documentation in [docs/FIX_TEMP_SCHEMA_FILTERING.md](docs/FIX_TEMP_SCHEMA_FILTERING.md)

### 7. Started Services Successfully
- Executed [start-all.sh](file:///root/supabase_multi-instance/start-all.sh) which:
  - Started Docker containers (manager and database)
  - Started the full Supabase stack (API, Studio, Auth, etc.)
  - Started Cloudflare Tunnel with proper configuration
  - Cloudflare Tunnel is now running with ingress rules for all three domains

## Current Status
- ✅ Supabase Manager is running on port 8090
- ✅ Supabase API is running on port 8081
- ✅ Supabase Studio is running on port 3001
- ✅ Cloudflare Tunnel is running with proper configuration
- ✅ Docker containers are up (manager, database, and full stack)
- ✅ Temporary schemas are properly filtered out from project listings
- ⚠️ Need to verify accessibility of custom domains (supabase.okiabrian.my.id, api.supabase.okiabrian.my.id, studio.supabase.okiabrian.my.id)

## Testing Instructions
1. Run `./start-all.sh` to start all services
2. Verify that all services are running with `docker ps`
3. Check that Cloudflare Tunnel is running with `ps aux | grep cloudflared`
4. Test access to:
   - Manager: http://localhost:8090
   - API: http://localhost:8081
   - Studio: http://localhost:3001
5. Test custom domain access:
   - Manager: https://supabase.okiabrian.my.id
   - API: https://api.supabase.okiabrian.my.id
   - Studio: https://studio.supabase.okiabrian.my.id
6. To stop all services, run `./stop-all.sh`

## API Usage
For detailed instructions on how to use the Supabase API, see [API_USAGE.md](API_USAGE.md).

## Troubleshooting
If any services fail to start:
1. Check Docker logs: `docker-compose logs` or `docker-compose -f supabase-full-stack.yml logs`
2. Verify port conflicts: `lsof -i :8090` or `lsof -i :8081` or `lsof -i :3001`
3. Restart services: `./restart-all.sh`
4. Test service accessibility: `./test-services.sh`
5. Check tunnel status: `./check-tunnel.sh`