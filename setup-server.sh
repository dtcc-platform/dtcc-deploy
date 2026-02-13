#!/usr/bin/env bash
set -euo pipefail

# Setup script for deploying dtcc-deploy on a fresh Ubuntu server.
#
# Prerequisites:
#   - Ubuntu 22.04 or 24.04
#
# Usage:
#   bash setup-server.sh

INSTALL_DIR="${INSTALL_DIR:-/opt/dtcc-deploy}"
CONTAINER_PORT="${CONTAINER_PORT:-8000}"
HOST_PORT="${HOST_PORT:-8000}"

GH_PREFIX="https://github.com/"

echo "==> Installing Docker"
if ! command -v docker &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
    sudo usermod -aG docker "$USER"
    echo "Docker installed. You may need to log out and back in for group membership to take effect."
else
    echo "Docker already installed, skipping."
fi

echo "==> Cloning repositories"
sudo mkdir -p "$INSTALL_DIR"
sudo chown "$USER:$USER" "$INSTALL_DIR"

if [ ! -d "$INSTALL_DIR/.git" ]; then
    git clone "${GH_PREFIX}dtcc-platform/dtcc-sim.git" "$INSTALL_DIR"
else
    echo "dtcc-sim already cloned, pulling latest."
    git -C "$INSTALL_DIR" pull
fi

if [ ! -d "$INSTALL_DIR/dtcc-atlas/.git" ]; then
    git clone -b develop "${GH_PREFIX}dtcc-platform/dtcc-atlas.git" "$INSTALL_DIR/dtcc-atlas"
else
    echo "dtcc-atlas already cloned, pulling latest."
    git -C "$INSTALL_DIR/dtcc-atlas" pull
fi

if [ ! -d "$INSTALL_DIR/dtcc-tetgen-wrapper/.git" ]; then
    git clone "${GH_PREFIX}dtcc-platform/dtcc-tetgen-wrapper.git" "$INSTALL_DIR/dtcc-tetgen-wrapper"
else
    echo "dtcc-tetgen-wrapper already cloned, pulling latest."
    git -C "$INSTALL_DIR/dtcc-tetgen-wrapper" pull
fi

echo "==> Building Docker image"
cd "$INSTALL_DIR"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo docker build -f "$SCRIPT_DIR/Dockerfile" -t dtcc-deploy .

echo "==> Starting container"
sudo docker rm -f dtcc-deploy 2>/dev/null || true
sudo docker run -d \
    --name dtcc-deploy \
    --restart unless-stopped \
    -p "${HOST_PORT}:${CONTAINER_PORT}" \
    dtcc-deploy

echo ""
echo "==> Done. dtcc-deploy is running on port ${HOST_PORT}."
echo "    Test with: curl http://localhost:${HOST_PORT}/"
