-- Create realtime schema
CREATE SCHEMA IF NOT EXISTS realtime;

-- Grant permissions
GRANT USAGE ON SCHEMA realtime TO anon, authenticated, service_role;