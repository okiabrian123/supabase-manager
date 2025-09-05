# Script Documentation

This document provides documentation for the helper scripts in this project.

## start-all.sh

Starts all Supabase services including:
- Supabase Manager (port 8090)
- Full Supabase Stack (API on port 8081, Studio on port 3001)
- Cloudflare Tunnel for custom domain access

Usage:
```bash
./start-all.sh
```

## stop-all.sh

Stops all Supabase services and the Cloudflare Tunnel.

Usage:
```bash
./stop-all.sh
```

## restart-all.sh

Restarts all Supabase services by stopping and starting them.

Usage:
```bash
./restart-all.sh
```

## start-supabase.sh

Starts only the full Supabase stack (without the manager).

Usage:
```bash
./start-supabase.sh
```

## test-services.sh

Tests the accessibility of all Supabase services running on localhost.

Usage:
```bash
./test-services.sh
```

## test-api-usage.sh

Demonstrates API usage with examples and tests basic functionality.

Usage:
```bash
./test-api-usage.sh
```

## check-tunnel.sh

Checks the status of the Cloudflare Tunnel and displays configuration information.

Usage:
```bash
./check-tunnel.sh
```

## run-db-init.sh

Manually runs the database initialization scripts and restarts all services. This should be used when the database container is restarted with existing data and the initialization scripts need to be run again.

Usage:
```bash
./run-db-init.sh
```