#!/bin/bash

# Fix local domain resolution for Open edX
# This script adds the necessary entries to /etc/hosts

echo "=================================================="
echo "Fixing Local Domain Resolution"
echo "=================================================="
echo ""

# Check if entries already exist
if grep -q "local.overhang.io" /etc/hosts; then
    echo "✓ Hosts entries already exist"
    echo ""
    echo "Current entries:"
    grep "overhang.io" /etc/hosts
else
    echo "Adding local domain entries to /etc/hosts..."
    echo ""
    echo "127.0.0.1 local.overhang.io studio.local.overhang.io apps.local.overhang.io discovery.local.overhang.io" | sudo tee -a /etc/hosts
    echo ""
    echo "✓ Hosts entries added successfully!"
fi

echo ""
echo "=================================================="
echo "Testing Domain Resolution"
echo "=================================================="
echo ""

# Test domain resolution
echo "Testing local.overhang.io..."
ping -c 1 local.overhang.io > /dev/null 2>&1 && echo "✓ local.overhang.io resolves" || echo "✗ local.overhang.io failed"

echo "Testing studio.local.overhang.io..."
ping -c 1 studio.local.overhang.io > /dev/null 2>&1 && echo "✓ studio.local.overhang.io resolves" || echo "✗ studio.local.overhang.io failed"

echo "Testing apps.local.overhang.io..."
ping -c 1 apps.local.overhang.io > /dev/null 2>&1 && echo "✓ apps.local.overhang.io resolves" || echo "✗ apps.local.overhang.io failed"

echo ""
echo "=================================================="
echo "Next Steps"
echo "=================================================="
echo ""
echo "1. Close your browser completely"
echo "2. Reopen your browser"
echo "3. Visit: http://studio.local.overhang.io"
echo "4. Login with:"
echo "   Email: tamagusko@gmail.com"
echo "   Password: AdminTRIGGER2024!"
echo ""
