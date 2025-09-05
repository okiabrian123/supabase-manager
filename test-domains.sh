#!/bin/bash

echo "🔍 Testing Custom Domain Accessibility"

# Test custom domains
echo ""
echo "=== Testing Custom Domain Accessibility ==="

# Test Supabase Manager custom domain
echo "Testing Supabase Manager (supabase-okiabrian.my.id)..."
if curl -s -o /dev/null -w "%{http_code}" https://supabase-okiabrian.my.id | grep -q "200\|301\|302"; then
    echo "✅ Supabase Manager custom domain is accessible"
    curl -s -o /dev/null -w "   Status Code: %{http_code}\n" https://supabase-okiabrian.my.id
else
    echo "❌ Supabase Manager custom domain is not accessible"
    curl -s -o /dev/null -w "   Status Code: %{http_code}\n" https://supabase-okiabrian.my.id
fi

# Test Supabase API custom domain
echo "Testing Supabase API (api-supabase-okiabrian.my.id)..."
if curl -s -o /dev/null -w "%{http_code}" https://api-supabase-okiabrian.my.id | grep -q "200\|301\|302\|404"; then
    echo "✅ Supabase API custom domain is accessible"
    curl -s -o /dev/null -w "   Status Code: %{http_code}\n" https://api-supabase-okiabrian.my.id
else
    echo "❌ Supabase API custom domain is not accessible"
    curl -s -o /dev/null -w "   Status Code: %{http_code}\n" https://api-supabase-okiabrian.my.id
fi

# Test Supabase Studio custom domain
echo "Testing Supabase Studio (studio-supabase-okiabrian.my.id)..."
if curl -s -o /dev/null -w "%{http_code}" https://studio-supabase-okiabrian.my.id | grep -q "200\|301\|302"; then
    echo "✅ Supabase Studio custom domain is accessible"
    curl -s -o /dev/null -w "   Status Code: %{http_code}\n" https://studio-supabase-okiabrian.my.id
else
    echo "❌ Supabase Studio custom domain is not accessible"
    curl -s -o /dev/null -w "   Status Code: %{http_code}\n" https://studio-supabase-okiabrian.my.id
fi

echo ""
echo "📋 For more detailed information, you can also try:"
echo "   curl -I https://supabase-okiabrian.my.id"
echo "   curl -I https://api-supabase-okiabrian.my.id"
echo "   curl -I https://studio-supabase-okiabrian.my.id"