#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REGISTRY_DATA_DIR="$SCRIPT_DIR/.local-registry"

mkdir -p "$REGISTRY_DATA_DIR"

docker run -d \
  --name registry \
  --restart unless-stopped \
  -p 5001:5000 \
  -v "$REGISTRY_DATA_DIR:/var/lib/registry" \
  -e REGISTRY_STORAGE_DELETE_ENABLED=true \
  registry:latest
