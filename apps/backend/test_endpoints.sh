#!/bin/bash
BASE_URL="https://guardian.shadowchat.xyz/api/v1"
echo "Testing health..."
curl -s "$BASE_URL/health" | grep -q "ok" && echo "Health OK" || echo "Health FAILED"
echo "Testing get endpoints..."
# I can't easily test auth without a token.
