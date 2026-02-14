# dtcc-deploy

Deployment and operations repo for the [DTCC platform](https://github.com/dtcc-platform). It packages, deploys, and provides an AI-accessible interface to the DTCC digital twin platform.

## What it does

**Docker packaging** — The `Dockerfile` builds a single container image that bundles the entire DTCC stack: `dtcc-core`, `dtcc`, `dtcc-sim` (simulations), `dtcc-atlas` (web frontend + backend), and `dtcc-tetgen-wrapper` (mesh generation). It installs FEniCSx, GDAL, Rust, and all other native dependencies.

**Server provisioning** — `setup-server.sh` is a one-shot script that sets up a fresh Ubuntu server: installs Docker, clones all needed repos, builds the image, and starts the container serving on port 8000.

**MCP server** — The `mcp_server/` package exposes the DTCC FastAPI backend as an [MCP](https://modelcontextprotocol.io/) (Model Context Protocol) tool server. This lets Claude or other LLM agents discover datasets, submit simulation jobs, poll for results, and download outputs through structured tool calls.

## Quick start

### Deploy on a server

```bash
bash setup-server.sh
```

This installs Docker (if needed), clones all platform repos, builds the container, and starts it on port 8000.

### Run tests

```bash
pip install -e ".[test]"
pytest tests/ -v -m external
```
