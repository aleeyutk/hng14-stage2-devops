#!/bin/bash
set -e

echo "Starting integration test..."

# Submit a job
echo "Submitting job..."
RESPONSE=$(curl -s -X POST http://localhost:3000/submit -H "Content-Type: application/json")
echo "Response: $RESPONSE"

JOB_ID=$(echo $RESPONSE | python3 -c "import sys,json; print(json.load(sys.stdin)['job_id'])")
echo "Job ID: $JOB_ID"

if [ -z "$JOB_ID" ] || [ "$JOB_ID" = "None" ]; then
  echo "ERROR: Failed to get job_id"
  exit 1
fi

# Poll for completion with timeout
echo "Polling for job completion..."
TIMEOUT=60
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS=$(curl -s http://localhost:3000/status/$JOB_ID | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','unknown'))")
  echo "Status after ${ELAPSED}s: $STATUS"
  if [ "$STATUS" = "completed" ]; then
    echo "SUCCESS: Job completed!"
    exit 0
  fi
  sleep 2
  ELAPSED=$((ELAPSED + 2))
done

echo "ERROR: Job did not complete within ${TIMEOUT}s"
exit 1
