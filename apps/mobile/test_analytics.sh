#!/bin/bash

# Load .env variables if .env file exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# 1. Test Aptabase Analytics (using the key loaded from .env)
echo "Testing Aptabase Analytics..."
if [ -z "$APTABASE_APP_KEY" ]; then
  echo "Skipping Aptabase test because APTABASE_APP_KEY is not set in .env."
else
  curl -X POST https://api.aptabase.com/v0/event \
    -H "Content-Type: application/json" \
    -H "App-Key: ${APTABASE_APP_KEY}" \
    -d '{
      "name": "test_event_from_postman",
      "sessionId": "agent-test-session",
      "system": {
        "name": "Postman Emulator Script",
        "version": "1.0",
        "locale": "en"
      }
    }' -i
fi

echo -e "\n\n---------------------------------------------\n"

FIREBASE_APP_ID="${FIREBASE_APP_ID_ANDROID}"
API_SECRET="${FIREBASE_MEASUREMENT_API_SECRET}"

echo "Testing Firebase Analytics Measurement Protocol..."
if [ -z "$API_SECRET" ] || [ -z "$FIREBASE_APP_ID" ]; then
  echo "Skipping Firebase test because API_SECRET or FIREBASE_APP_ID is not set in .env."
  echo "Please check your .env file."
else
  curl -X POST "https://www.google-analytics.com/mp/collect?firebase_app_id=${FIREBASE_APP_ID}&api_secret=${API_SECRET}" \
    -H "Content-Type: application/json" \
    -d '{
      "app_instance_id": "test_app_instance_12345",
      "events": [
        {
          "name": "test_event_from_postman",
          "params": {}
        }
      ]
    }' -i
fi
