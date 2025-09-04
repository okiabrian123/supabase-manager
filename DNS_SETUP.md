# DNS Configuration for Supabase Services

To access your Supabase services through your custom domain, you need to create the following CNAME records in your DNS provider:

## Required DNS Records

| Subdomain | Type | Value |
|-----------|------|-------|
| supabase.okiabrian.my.id | CNAME | a8b5c87a-f853-4a0d-b4a2-6c26620079ec.cfargotunnel.com |
| api.supabase.okiabrian.my.id | CNAME | a8b5c87a-f853-4a0d-b4a2-6c26620079ec.cfargotunnel.com |
| studio.supabase.okiabrian.my.id | CNAME | a8b5c87a-f853-4a0d-b4a2-6c26620079ec.cfargotunnel.com |

## How to set up DNS records

1. Log in to your Cloudflare dashboard
2. Select your domain (okiabrian.my.id)
3. Go to the DNS section
4. Add the CNAME records listed above

## Access URLs

Once the DNS records are set up and propagated, you can access your services at:

- Supabase Manager Dashboard: https://supabase.okiabrian.my.id
- Supabase API: https://api.supabase.okiabrian.my.id
- Supabase Studio: https://studio.supabase.okiabrian.my.id

## Testing

After setting up the DNS records, you can test the connectivity with:

```bash
# Test the manager dashboard
curl -I https://supabase.okiabrian.my.id

# Test the API
curl -I https://api.supabase.okiabrian.my.id/rest/v1/

# Test the Studio
curl -I https://studio.supabase.okiabrian.my.id
```