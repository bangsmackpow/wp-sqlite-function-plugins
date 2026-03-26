#!/usr/bin/env bash
set -euo pipefail

WORKFLOW="Build and Push WP SQLite Image"
MAIN_BRANCH="main"
POLL_INTERVAL=${POLL_INTERVAL:-60}

echo "[auto-ci] Starting CI auto-loop for ${WORKFLOW} on ${MAIN_BRANCH}"

while true; do
  # Fetch latest run for this workflow/branch
  RUNS=$(gh run list --workflow "$WORKFLOW" --branch "$MAIN_BRANCH" --limit 1 --json id,status,conclusion)
  RUN_ID=$(echo "$RUNS" | jq -r '.[]?.id')
  STATUS=$(echo "$RUNS" | jq -r '.[]?.status')
  CONCLUSION=$(echo "$RUNS" | jq -r '.[]?.conclusion')

  if [ -z "$RUN_ID" ] || [ "$RUN_ID" = "null" ]; then
    echo "[auto-ci] No runs found yet. Waiting..."; sleep "$POLL_INTERVAL"; continue
  fi

  echo "[auto-ci] Latest run: $RUN_ID status=$STATUS conclusion=$CONCLUSION"

  if [ "$STATUS" = "completed" ]; then
    if [ "$CONCLUSION" = "success" ]; then
      echo "[auto-ci] Build succeeded on run $RUN_ID. Stopping loop."
      break
    else
      echo "[auto-ci] Build failed on run $RUN_ID. Pushing patch to retry."
      # Stage and commit a no-op patch to trigger a new run (or pick up existing changes)
      git add -A
      git commit -m "ci: retry WP SQLite Alpine build (RTK auto)" || true
      git push origin "$MAIN_BRANCH"
      echo "[auto-ci] Triggered new run via push. Waiting for next run..."
      sleep "$POLL_INTERVAL"
      continue
    fi
  else
    echo "[auto-ci] Run in progress. Waiting..."
    sleep "$POLL_INTERVAL"
  fi
done
