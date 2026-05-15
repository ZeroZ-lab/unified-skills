#!/usr/bin/env bash
# Unified Skills — poll-deploy.sh
# Background monitor for ship-workflow-ship skill.
# Polls deployment health every 30 seconds.
# Outputs status lines that are delivered to Claude as notifications.
set -u

interval=30
endpoint="${1:-}"

while true; do
  # If no endpoint configured, output a placeholder
  if [ -z "$endpoint" ]; then
    echo "[deploy-monitor] No endpoint configured. Set via /config or env var."
    sleep "$interval"
    continue
  fi

  # Poll the endpoint
  status=$(curl -s -o /dev/null -w "%{http_code}" "$endpoint" 2>/dev/null || echo "000")

  if [ "$status" = "200" ]; then
    echo "[deploy-monitor] ✓ $endpoint — healthy (HTTP $status)"
  elif [ "$status" = "000" ]; then
    echo "[deploy-monitor] ✗ $endpoint — unreachable"
  else
    echo "[deploy-monitor] ⚠ $endpoint — HTTP $status"
  fi

  sleep "$interval"
done