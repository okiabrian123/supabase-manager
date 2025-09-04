-- Create _realtime schema
CREATE SCHEMA IF NOT EXISTS _realtime;

-- Grant permissions
GRANT USAGE ON SCHEMA _realtime TO anon, authenticated, service_role, postgres;
GRANT ALL PRIVILEGES ON SCHEMA _realtime TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA _realtime TO service_role;