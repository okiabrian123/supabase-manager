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

-- Create auth schema and required tables
CREATE SCHEMA IF NOT EXISTS auth;

-- Create required extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create auth.users table
CREATE TABLE IF NOT EXISTS auth.users (
  instance_id uuid NULL,
  id uuid NOT NULL UNIQUE,
  aud varchar(255) NULL,
  "role" varchar(255) NULL,
  email varchar(255) NULL UNIQUE,
  encrypted_password varchar(255) NULL,
  confirmed_at timestamptz NULL,
  invited_at timestamptz NULL,
  confirmation_token varchar(255) NULL,
  confirmation_sent_at timestamptz NULL,
  recovery_token varchar(255) NULL,
  recovery_sent_at timestamptz NULL,
  email_change_token varchar(255) NULL,
  email_change varchar(255) NULL,
  email_change_sent_at timestamptz NULL,
  last_sign_in_at timestamptz NULL,
  raw_app_meta_data jsonb NULL,
  raw_user_meta_data jsonb NULL,
  is_super_admin bool NULL,
  created_at timestamptz NULL,
  updated_at timestamptz NULL,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS users_instance_id_email_idx ON auth.users USING btree (instance_id, email);
CREATE INDEX IF NOT EXISTS users_instance_id_idx ON auth.users USING btree (instance_id);

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';

-- Create auth.refresh_tokens table
CREATE TABLE IF NOT EXISTS auth.refresh_tokens (
  instance_id uuid NULL,
  id bigserial NOT NULL,
  "token" varchar(255) NULL,
  user_id varchar(255) NULL,
  revoked bool NULL,
  created_at timestamptz NULL,
  updated_at timestamptz NULL,
  CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);
CREATE INDEX IF NOT EXISTS refresh_tokens_token_idx ON auth.refresh_tokens USING btree (token);

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';

-- Create auth.instances table
CREATE TABLE IF NOT EXISTS auth.instances (
  id uuid NOT NULL,
  uuid uuid NULL,
  raw_base_config text NULL,
  created_at timestamptz NULL,
  updated_at timestamptz NULL,
  CONSTRAINT instances_pkey PRIMARY KEY (id)
);

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';

-- Create auth.audit_log_entries table
CREATE TABLE IF NOT EXISTS auth.audit_log_entries (
  instance_id uuid NULL,
  id uuid NOT NULL,
  payload json NULL,
  created_at timestamptz NULL,
  CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';

-- Create auth.schema_migrations table
CREATE TABLE IF NOT EXISTS auth.schema_migrations (
  "version" varchar(255) NOT NULL,
  CONSTRAINT schema_migrations_pkey PRIMARY KEY ("version")
);

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';

-- Create functions
CREATE OR REPLACE FUNCTION auth.uid() 
RETURNS uuid AS $$
  SELECT nullif(current_setting('request.jwt.claim.sub', true), '')::uuid;
$$ LANGUAGE sql STABLE;

CREATE OR REPLACE FUNCTION auth.role() 
RETURNS text AS $$
  SELECT nullif(current_setting('request.jwt.claim.role', true), '')::text;
$$ LANGUAGE sql STABLE;

-- Additional tables and types needed for auth service migrations

-- Create factor_type enum
CREATE TYPE auth.factor_type AS ENUM ('totp', 'webauthn');

-- Create mfa_factors table
CREATE TABLE IF NOT EXISTS auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text NULL,
    factor_type auth.factor_type NOT NULL,
    status text NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    secret text NULL,
    CONSTRAINT mfa_factors_pkey PRIMARY KEY (id)
);

-- Create mfa_challenges table
CREATE TABLE IF NOT EXISTS auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamptz NOT NULL,
    verified_at timestamptz NULL,
    ip_address inet NOT NULL,
    CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id)
);

-- Grant permissions
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;
GRANT ALL PRIVILEGES ON TABLE auth.users TO service_role;
GRANT ALL PRIVILEGES ON TABLE auth.refresh_tokens TO service_role;
GRANT ALL PRIVILEGES ON TABLE auth.instances TO service_role;
GRANT ALL PRIVILEGES ON TABLE auth.audit_log_entries TO service_role;
GRANT ALL PRIVILEGES ON TABLE auth.schema_migrations TO service_role;
GRANT ALL PRIVILEGES ON TABLE auth.mfa_factors TO service_role;
GRANT ALL PRIVILEGES ON TABLE auth.mfa_challenges TO service_role;
GRANT ALL PRIVILEGES ON TYPE auth.factor_type TO service_role;