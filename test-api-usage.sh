#!/bin/bash

# Simple test script to demonstrate API usage

echo "🚀 Testing Supabase API Usage"
echo "============================="

# Test 1: Check if manager is accessible
echo ""
echo "1. Testing Manager Dashboard Access"
echo "-----------------------------------"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8090 | grep -q "200"; then
    echo "✅ Manager Dashboard is accessible at http://localhost:8090"
else
    echo "❌ Manager Dashboard is not accessible"
fi

# Test 2: List projects (empty initially)
echo ""
echo "2. Testing Project List API"
echo "---------------------------"
response=$(curl -s http://localhost:8090/projects)
if [ "$response" = "[]" ]; then
    echo "✅ Project list is empty (as expected for new installation)"
else
    echo "ℹ️  Project list: $response"
fi

# Test 3: Test API endpoint accessibility
echo ""
echo "3. Testing REST API Access"
echo "--------------------------"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/ | grep -q "404"; then
    echo "✅ REST API is accessible at http://localhost:8081 (returns 404 for root path as expected)"
else
    echo "❌ REST API is not accessible"
fi

# Test 4: Test Studio access
echo ""
echo "4. Testing Studio Access"
echo "------------------------"
status_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/)
if [ "$status_code" = "307" ]; then
    echo "✅ Studio is accessible at http://localhost:3001 (returns 307 redirect as expected)"
else
    echo "❌ Studio is not accessible (status code: $status_code)"
fi

# Test 5: Demonstrate project creation
echo ""
echo "5. Demonstrating Project Creation"
echo "---------------------------------"
echo "To create a new project, run:"
echo "curl -X POST http://localhost:8090/projects \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"name\": \"myproject\", \"description\": \"My new project\"}'"
echo ""
echo "To list projects after creation:"
echo "curl http://localhost:8090/projects"
echo ""
echo "To access project data via REST API:"
echo "curl http://localhost:8081/rest/v1/myproject_users?select=* \\"
echo "  -H \"Authorization: Bearer YOUR_API_KEY\" \\"
echo "  -H \"apikey: YOUR_API_KEY\""

echo ""
echo "📋 For complete API usage instructions, see API_USAGE.md"