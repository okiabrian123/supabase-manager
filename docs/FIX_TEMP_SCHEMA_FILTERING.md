# Fix for Temporary Schema Filtering in Project Listing

## Problem Description

When listing projects in the Supabase Multi-Instance Manager, temporary PostgreSQL schemas (those starting with `pg_temp_` and `pg_toast_temp_`) were appearing in the results. These schemas are automatically created by PostgreSQL for temporary tables and should not be displayed as user projects.

## Root Cause

The original SQL query in the `getProjects()` function used string replacement functions to filter out temporary schemas:

```sql
AND REPLACE(schema_name, 'pg_temp_', '') = schema_name
AND REPLACE(schema_name, 'pg_toast_temp_', '') = schema_name
```

This approach was ineffective because:
1. It only checked if replacing the prefix resulted in the same string
2. It didn't properly handle schemas that actually start with these prefixes
3. The logic was flawed and didn't correctly identify temporary schemas

## Solution

The fix involved changing the SQL query to use proper pattern matching with the `NOT LIKE` operator:

```sql
AND schema_name NOT LIKE 'pg_temp_%'
AND schema_name NOT LIKE 'pg_toast_temp_%'
```

This approach:
1. Uses standard SQL pattern matching with wildcards
2. Properly excludes any schema that starts with the temporary schema prefixes
3. Is more readable and maintainable
4. Provides reliable filtering of temporary schemas

## Implementation Details

### File Modified
- `main.go` - Updated the `getProjects()` function

### Code Changes
```go
// Before (ineffective)
query := `
    SELECT schema_name, 
           CURRENT_TIMESTAMP as created_at
    FROM information_schema.schemata 
    WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast', 'auth', 'storage', 'supabase_functions', 'extensions', 'public', 'realtime', 'vault', 'graphql', 'graphql_public')
    AND REPLACE(schema_name, 'pg_temp_', '') = schema_name
    AND REPLACE(schema_name, 'pg_toast_temp_', '') = schema_name
    ORDER BY schema_name
`

// After (effective)
query := `
    SELECT schema_name, 
           CURRENT_TIMESTAMP as created_at
    FROM information_schema.schemata 
    WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast', 'auth', 'storage', 'supabase_functions', 'extensions', 'public', 'realtime', 'vault', 'graphql', 'graphql_public')
    AND schema_name NOT LIKE 'pg_temp_%'
    AND schema_name NOT LIKE 'pg_toast_temp_%'
    ORDER BY schema_name
`
```

## Testing the Fix

### Before the Fix
```json
[
  {
    "name": "ecommerce",
    "status": "active",
    "created_at": "2025-09-03T07:38:13.693393Z"
  },
  {
    "name": "pg_temp_13",
    "status": "active",
    "created_at": "2025-09-03T07:38:13.693393Z"
  },
  {
    "name": "pg_temp_14",
    "status": "active",
    "created_at": "2025-09-03T07:38:13.693393Z"
  },
  {
    "name": "pg_toast_temp_13",
    "status": "active",
    "created_at": "2025-09-03T07:38:13.693393Z"
  }
]
```

### After the Fix
```json
[
  {
    "name": "ecommerce",
    "status": "active",
    "created_at": "2025-09-03T08:23:27.866652Z"
  },
  {
    "name": "testproject",
    "status": "active",
    "created_at": "2025-09-03T08:23:27.866652Z"
  }
]
```

## Deployment

Since the application runs in Docker, after making the code changes, the Docker image must be rebuilt:

```bash
docker-compose down
docker-compose up -d --build
```

This ensures that the updated Go binary is compiled and included in the new Docker image.

## Verification

To verify the fix is working correctly:

1. Make sure the services are running:
   ```bash
   docker-compose ps
   ```

2. Test the API endpoint:
   ```bash
   curl -s http://localhost:8090/projects | jq .
   ```

3. Confirm that no schemas starting with `pg_temp_` or `pg_toast_temp_` appear in the results

## Best Practices

1. When filtering database objects by name patterns, prefer SQL pattern matching (`LIKE`/`NOT LIKE`) over string manipulation functions
2. Always rebuild Docker images after making code changes to ensure the changes take effect
3. Test API endpoints after deploying changes to verify the fix works as expected