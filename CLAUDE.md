# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Meta Ads MCP is a Model Context Protocol server for interacting with Meta (Facebook/Instagram) Ads API. It allows LLMs to analyze, manage, and optimize Meta advertising campaigns.

## Common Commands

### Install dependencies
```bash
pip install -e .
# or with uv
uv pip install -e .
```

### Run the MCP server (stdio transport - default)
```bash
python -m meta_ads_mcp
# or after install:
meta-ads-mcp
```

### Run with HTTP transport
```bash
python -m meta_ads_mcp --transport streamable-http --port 8080
```

### Authenticate with Meta
```bash
python -m meta_ads_mcp --login --app-id YOUR_META_APP_ID
```

### Run tests
```bash
pytest                           # Run all unit tests (excludes e2e)
pytest tests/test_targeting.py   # Run a single test file
pytest -m e2e                    # Run e2e tests only (requires running server)
```

## Architecture

### Core Structure
- `meta_ads_mcp/` - Main package
  - `__init__.py` - Package entry point, exports `entrypoint()` for CLI
  - `core/` - All business logic modules
    - `server.py` - FastMCP server setup, CLI argument parsing, transport configuration
    - `api.py` - Base Meta Graph API client utilities
    - `auth.py` / `authentication.py` - OAuth and token management
    - `pipeboard_auth.py` - Pipeboard cloud authentication integration

### Domain Modules (in `core/`)
Each module registers MCP tools via the `@mcp_server.tool()` decorator:
- `accounts.py` - Ad account management (`get_ad_accounts`, `get_account_info`, `get_account_pages`)
- `campaigns.py` - Campaign CRUD operations
- `adsets.py` - Ad set management
- `ads.py` - Ad and creative management, image handling
- `insights.py` - Performance metrics and analytics
- `targeting.py` - Interest/behavior/demographic/geo targeting search
- `budget_schedules.py` - Budget scheduling
- `duplication.py` - Campaign/adset/ad duplication
- `reports.py` - Reporting functionality

### Key Patterns
- Tools are registered on the shared `mcp_server` instance from `server.py`
- Most tools accept an optional `access_token` parameter; if not provided, they use cached tokens
- Account IDs use format `act_XXXXXXXXX`
- Campaign objectives use ODAX format (e.g., `OUTCOME_AWARENESS`, `OUTCOME_TRAFFIC`)
- Budgets are specified in cents (e.g., 10000 = $100.00)

### Transport Modes
1. **stdio** (default) - For MCP clients like Claude Desktop
2. **streamable-http** - HTTP API with Bearer token or OAuth authentication

### Test Structure
- `tests/` - All tests use pytest with async support
- Tests marked `@pytest.mark.e2e` require a running server
- Default test run excludes e2e tests (see `pyproject.toml` pytest config)

## Environment Variables
- `META_APP_ID` - Meta Developer App ID
- `META_APP_SECRET` - Meta Developer App Secret (server-side only)
- `PIPEBOARD_API_TOKEN` - For Pipeboard cloud authentication
- `MCP_TEST_SERVER_URL` - Test server URL (default: http://localhost:8080)

## Railway Deployment

### Quick Deploy
1. Connect your GitHub repo to Railway
2. Railway auto-detects the Dockerfile
3. Set environment variables in Railway dashboard

### Required Environment Variables (set in Railway)
```
PIPEBOARD_API_TOKEN=your_pipeboard_token
```

### Optional Environment Variables
```
META_APP_ID=your_meta_app_id
META_APP_SECRET=your_meta_app_secret
```

### Files for Railway
- `Dockerfile` - Configured for HTTP transport with `$PORT` env var
- `railway.toml` - Railway-specific configuration
- `Procfile` - Backup deployment method

### After Deployment
Your MCP endpoint will be: `https://your-app.up.railway.app/mcp`

Test with:
```bash
curl -X POST https://your-app.up.railway.app/mcp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_PIPEBOARD_TOKEN" \
  -d '{"jsonrpc":"2.0","method":"tools/list","id":1}'
```
