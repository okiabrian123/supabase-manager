# Supabase Multi-Instance Manager

This repository contains a clean, portable version of the Supabase Multi-Instance Manager that can be deployed on any server with Docker and Go installed.

## Overview

The Supabase Multi-Instance Manager is a Go-based application that provides a web interface for managing multiple Supabase instances. It allows users to create, manage, and access multiple isolated database schemas within a single PostgreSQL database, with each schema representing a separate "project".

## Prerequisites

- Docker and Docker Compose
- Go 1.21+
- Cloudflare account with Tunnel configured (for public access)

## Installation

1. Clone this repository to your server:
   ```bash
   git clone <repository-url>
   cd supabase-manager
   ```

2. Ensure you have the required dependencies installed:
   ```bash
   # Check if Docker is installed
   docker --version
   docker-compose --version
   go version
   ```

3. If any dependencies are missing, install them according to your system's package manager.

## Quick Start

To start all services:

```bash
./start-all.sh
```

This will:
1. Start the Supabase Manager and database
2. Start the full Supabase stack
3. Start the Cloudflare Tunnel for public access (if configured)

## Service Management Scripts

- `./start-all.sh` - Starts all services
- `./stop-all.sh` - Stops all services
- `./restart-all.sh` - Restarts all services
- `./start-supabase.sh` - Starts only the Supabase stack
- `./check-tunnel.sh` - Checks Cloudflare Tunnel status
- `./test-services.sh` - Tests service accessibility
- `./test-api-usage.sh` - Demonstrates API usage
- `./test-domains.sh` - Tests custom domain accessibility

## Accessing Services

After starting the services, you can access:

- Supabase Manager Dashboard: http://localhost:8090
- Supabase Database: localhost:5432
- Supabase API Gateway: http://localhost:8081
- Supabase Studio: http://localhost:3001

If Cloudflare Tunnel is configured, you can also access:

- Supabase Manager: https://supabase.yourdomain.com
- Supabase API: https://api.supabase.yourdomain.com
- Supabase Studio: https://studio.supabase.yourdomain.com

## Configuration

### Environment Configuration

The application can be configured through:

1. `config.yaml` - Main application configuration
2. Environment variables (will override config.yaml values)
3. `.env` files in the Supabase directories

### Cloudflare Tunnel Configuration

To enable public access through Cloudflare Tunnel:

1. Update `cloudflared-custom.yml` with your tunnel configuration
2. Ensure you have the tunnel credentials file in the correct location
3. Update the custom domains in the configuration file

## API Usage

For detailed information on how to use the Supabase API, see [API_USAGE.md](API_USAGE.md).

## Documentation

Additional documentation can be found in the following files:

- [docs/SUPABASE_MANAGER_ARCHITECTURE.md](docs/SUPABASE_MANAGER_ARCHITECTURE.md) - Comprehensive system architecture documentation
- [API_USAGE.md](API_USAGE.md) - Detailed API usage instructions
- [API_AUTH.md](API_AUTH.md) - Authentication information for the API
- [CLOUDFLARE_SETUP.md](CLOUDFLARE_SETUP.md) - Cloudflare Tunnel setup instructions
- [DNS_SETUP.md](DNS_SETUP.md) - DNS configuration instructions
- [SCRIPTS.md](SCRIPTS.md) - Detailed script documentation

## Development

To build the manager application:

```bash
go build -o main
```

To run tests:

```bash
go test -v
```

For development guidelines, see [docs/DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md).

## Troubleshooting

If you encounter issues:

1. Check service status: `./test-services.sh`
2. Check Docker containers: `docker ps`
3. Check logs: `docker-compose logs`
4. Restart services: `./restart-all.sh`

For common issues and solutions, see the documentation files.
