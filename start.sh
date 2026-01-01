#!/bin/sh
set -e

# Use PORT from environment, default to 8080
PORT="${PORT:-8080}"
HOST="${HOST:-0.0.0.0}"

echo "Starting Meta Ads MCP server on $HOST:$PORT"

exec python -m meta_ads_mcp --transport streamable-http --host "$HOST" --port "$PORT"
