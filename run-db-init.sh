#!/bin/bash

# Script to manually run database initialization scripts
# This should be used when the database container is restarted with existing data
# and the initialization scripts need to be run again

echo "🔄 Running database initialization scripts..."

# Run the auth schema script
echo "📦 Running 01-auth-schema.sql..."
docker-compose exec db psql -U postgres -d postgres -f /docker-entrypoint-initdb.d/01-auth-schema.sql

# Run the realtime schema script
echo "📡 Running 02-realtime-schema.sql..."
docker-compose exec db psql -U postgres -d postgres -f /docker-entrypoint-initdb.d/02-realtime-schema.sql

# Run the realtime underscore schema script
echo "📝 Running 03-realtime-underscore-schema.sql..."
docker-compose exec db psql -U postgres -d postgres -f /docker-entrypoint-initdb.d/03-realtime-underscore-schema.sql

echo "✅ Database initialization scripts completed!"
echo "🔄 Restarting Supabase services..."
docker-compose -f supabase-full-stack.yml down
docker-compose -f supabase-full-stack.yml up -d

echo "🎉 All services restarted successfully!"