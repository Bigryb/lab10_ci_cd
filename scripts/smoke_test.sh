#!/usr/bin/env bash

set -euo pipefail

URL="http://127.0.0.1:18080/health"

EXPECTED_VERSION="${1:?Commit hash is required}"

MAX_ATTEMPTS=15

echo "Starting smoke test..."
echo "URL: $URL"
echo "Expected version: $EXPECTED_VERSION"

for ((i=1; i<=MAX_ATTEMPTS; i++)); do

    echo "Attempt $i/$MAX_ATTEMPTS"

    if response=$(curl \
        --fail \
        --silent \
        --show-error \
        --max-time 5 \
        --write-out '\n%{http_code}' \
        "$URL"); then

        body="${response%$'\n'*}"
        status="${response##*$'\n'}"

        if [[ "$status" == "200" ]] && \
            python3 -c '
import json
import sys

data = json.loads(sys.argv[1])

assert data["status"] == "ok"
assert data["service"] == "lab10-flask"
assert data["version"] == sys.argv[2]
' "$body" "$EXPECTED_VERSION"; then

            echo "HTTP status: $status"
            echo "Response: $body"
            echo "Smoke test passed!"
            echo "Deployment successful!"

            exit 0
        fi
    fi

    echo "Waiting for application..."
    sleep 2

done

echo "Smoke test failed!"

exit 1
