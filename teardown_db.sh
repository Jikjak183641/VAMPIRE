#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME=${CONTAINER_NAME:-vamp_mariadb}

echo "Stopping and removing container ${CONTAINER_NAME} (if present)..."
docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true
echo "Done."
