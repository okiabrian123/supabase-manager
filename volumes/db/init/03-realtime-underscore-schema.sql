-- Create required roles if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role;
  END IF;
END
$$;

-- Create _realtime schema
CREATE SCHEMA IF NOT EXISTS _realtime;

-- Grant permissions
GRANT USAGE ON SCHEMA _realtime TO anon, authenticated, service_role, postgres;
GRANT ALL PRIVILEGES ON SCHEMA _realtime TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA _realtime TO service_role;