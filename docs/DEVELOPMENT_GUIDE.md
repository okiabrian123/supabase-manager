# Supabase Multi-Instance Manager Development Guide

This guide provides important information for developers working on the Supabase Multi-Instance Manager project.

## Development Environment Setup

1. Clone the repository
2. Install Go 1.21
3. Install Docker and Docker Compose
4. Run `go mod download` to fetch dependencies

## Building the Application

### Local Development

For local development and testing, you can build and run the application directly:

```bash
# Build the application
go build -o main

# Run the application
./main
```

### Docker Build

For production deployment or testing in a containerized environment:

```bash
# Build and start services
docker-compose up -d --build

# Stop services
docker-compose down
```

## Important: Docker Image Rebuilding

When making changes to the Go code, it's crucial to rebuild the Docker image for the changes to take effect. Simply restarting the containers without rebuilding will not apply your code changes.

### Correct Approach

```bash
# Rebuild and restart services
docker-compose down
docker-compose up -d --build
```

### Incorrect Approach

```bash
# This will NOT apply code changes
docker-compose restart
```

## API Development

The application uses the Gin web framework. Routes are defined in [main.go](../main.go).

### Adding New Routes

1. Define the route in the `main()` function
2. Create a handler method in the `DatabaseManager` struct
3. Test the route

### Testing API Endpoints

```bash
# List all projects
curl http://localhost:8090/projects

# Create a new project
curl -X POST http://localhost:8090/projects \
  -H "Content-Type: application/json" \
  -d '{"name": "myproject", "description": "My new project"}'

# Delete a project
curl -X DELETE http://localhost:8090/projects/myproject
```

## Database Schema Management

The application creates separate schemas for each project in the PostgreSQL database. Each schema contains:

- `users` table
- `posts` table
- Appropriate views for API access

### Creating Project Schemas

Project schemas are created automatically when a user creates a new project through the API.

### Deleting Project Schemas

Project schemas are deleted when a user deletes a project through the API.

## Testing

### Unit Tests

Run unit tests with:

```bash
go test -v
```

### Integration Tests

Integration tests are handled through the test scripts:

- [test-services.sh](../test-services.sh) - Tests service accessibility
- [test-api-usage.sh](../test-api-usage.sh) - Tests API functionality
- [test-domains.sh](../test-domains.sh) - Tests domain accessibility

## Deployment

### Production Deployment

1. Update configuration files as needed
2. Build and deploy Docker images
3. Start services with `docker-compose up -d --build`

### Cloudflare Tunnel Configuration

Ensure the Cloudflare Tunnel is properly configured for custom domain access:

1. Update [cloudflared-custom.yml](../cloudflared-custom.yml) with correct domains
2. Ensure credentials file exists at `/root/.cloudflared/[TUNNEL_ID].json`
3. Start tunnel with `cloudflared tunnel --config cloudflared-custom.yml run [TUNNEL_ID]`

## Troubleshooting

### Common Issues

1. **Changes not appearing**: Remember to rebuild Docker images after code changes
2. **Port conflicts**: Check if services are already running on the required ports
3. **Database connection issues**: Verify database credentials and connectivity
4. **Cloudflare Tunnel issues**: Check tunnel status and configuration

### Useful Commands

```bash
# View running containers
docker ps

# View container logs
docker-compose logs

# Check port usage
lsof -i :8090

# Test service accessibility
curl http://localhost:8090/projects

# Check Cloudflare Tunnel status
ps aux | grep cloudflared
```

## Documentation

Documentation files are located in:
- Root directory: Main documentation files (README.md, API_USAGE.md, etc.)
- [docs/](.) directory: Technical documentation and guides

When adding new features or fixing issues, update the relevant documentation files.