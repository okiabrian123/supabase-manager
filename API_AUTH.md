# How to Use the Supabase API with Authentication

When accessing the Supabase API, you need to provide an API key for authentication. The API Gateway (Kong) requires this key for security purposes.

## Available API Keys

### 1. Anonymous Key (for public access)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
```

### 2. Service Role Key (for admin access)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
```

## Using the API Keys

### Method 1: Using the `apikey` header
```bash
curl -H "apikey: YOUR_API_KEY" \
  https://api-supabase.okiabrian.my.id/rest/v1/your_table?select=*
```

### Method 2: Using the `Authorization` header
```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
  -H "apikey: YOUR_API_KEY" \
  https://api-supabase.okiabrian.my.id/rest/v1/your_table?select=*
```

## Example Usage

### Get data from a project table
```bash
# Replace 'myproject' with your actual project name
curl -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0" \
  https://api-supabase.okiabrian.my.id/rest/v1/myproject_users?select=*
```

### Insert data into a project table
```bash
curl -X POST \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{"email": "user@example.com", "name": "John Doe"}' \
  https://api-supabase.okiabrian.my.id/rest/v1/myproject_users
```

## Note about the "Open" Button in Dashboard

The "Open" button in the project dashboard will open the API endpoint in your browser, but you'll need to manually add the API key headers to make requests. For programmatic access, use the curl examples above.