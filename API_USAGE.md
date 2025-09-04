# How to Use the Supabase API

This guide explains how to use the Supabase API that's running in your multi-instance setup.

## API Access Points

### 1. Via Custom Domains (HTTPS - Recommended)
- **Manager Dashboard**: https://supabase.okiabrian.my.id
- **API Endpoint**: https://api.supabase.okiabrian.my.id
- **Studio Interface**: https://studio.supabase.okiabrian.my.id

### 2. Via HTTP (Temporary Workaround for SSL Issues)
- **API Endpoint**: http://api.supabase.okiabrian.my.id
- **Studio Interface**: http://studio.supabase.okiabrian.my.id

### 3. Via Localhost
- **Manager Dashboard**: http://localhost:8090
- **API Endpoint**: http://localhost:8081
- **Studio Interface**: http://localhost:3001

## Using the Supabase Manager Dashboard

The manager dashboard provides a web interface to manage your Supabase projects:

1. **Access the dashboard**:
   - Local: http://localhost:8090
   - Public: https://supabase.okiabrian.my.id

2. **Create a new project**:
   - Click "New Project" button
   - Enter a project name (lowercase letters, numbers, underscores only)
   - Click "Create Project"

3. **View existing projects**:
   - The dashboard shows a list of all created projects
   - Each project has "Open" and "Tables" buttons

## Using the REST API

### 1. Project Management API

#### List all projects
```bash
curl http://localhost:8090/projects
```

#### Create a new project
```bash
curl -X POST http://localhost:8090/projects 
  -H "Content-Type: application/json" 
  -d '{"name": "myproject", "description": "My new project"}'
```

#### Delete a project
```bash
curl -X DELETE http://localhost:8090/projects/myproject
```

#### Get project tables
```bash
curl http://localhost:8090/projects/myproject/tables
```

### 2. Supabase REST API (PostgREST)

Once you've created a project, you can access the Supabase REST API through the PostgREST endpoint:

#### Access project users table
```bash
# Using the public view created automatically
curl http://localhost:8081/rest/v1/myproject_users?select=*

# Using direct table access (requires authentication)
curl http://localhost:8081/rest/v1/users?select=*
```

#### Access project posts table
```bash
# Using the public view created automatically
curl http://localhost:8081/rest/v1/myproject_posts?select=*

# Using direct table access (requires authentication)
curl http://localhost:8081/rest/v1/posts?select=*
```

## Authentication

For authenticated access to the REST API, you'll need to use the API keys. The API Gateway (Kong) requires these keys for security.

### Available API Keys

#### Anonymous Key (for unauthenticated access)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
```

#### Service Role Key (for admin access)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
```

Use these keys in the Authorization header:
```bash
curl https://api.supabase.okiabrian.my.id/rest/v1/myproject_users?select=* 
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0" 
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
```

## Example Usage

### 1. Create a project and add data

```bash
# Create a project
curl -X POST http://localhost:8090/projects 
  -H "Content-Type: application/json" 
  -d '{"name": "ecommerce", "description": "E-commerce application"}'

# Add a user to the ecommerce project
curl -X POST https://api.supabase.okiabrian.my.id/rest/v1/ecommerce_users 
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU" 
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0" 
  -H "Content-Type: application/json" 
  -H "Prefer: return=representation" 
  -d '{"email": "user@example.com", "name": "John Doe"}'

# Get all users from the ecommerce project
curl https://api.supabase.okiabrian.my.id/rest/v1/ecommerce_users?select=* 
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0" 
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
```

### 2. Using the Studio Interface

1. Access the Studio at http://localhost:3001 or http://studio.supabase.okiabrian.my.id
2. The Studio provides a web-based interface for:
   - Browsing tables and data
   - Running SQL queries
   - Managing database structure
   - Viewing API documentation

## Troubleshooting

### SSL Issues
If you're having trouble accessing the HTTPS endpoints:
1. Try using HTTP instead (temporary workaround)
2. Check Cloudflare SSL configuration
3. Ensure the SSL certificate is properly installed

### Connection Issues
If you can't connect to any endpoints:
1. Check that all services are running: `./test-services.sh`
2. Verify Docker containers are up: `docker ps`
3. Check Cloudflare tunnel status: `./check-tunnel.sh`

### Authentication Issues
If you get 401 or 403 errors:
1. Make sure you're using the correct API keys
2. Verify the Authorization header format
3. Check that the service is properly configured

For detailed information about API authentication, see [API_AUTH.md](API_AUTH.md).
```