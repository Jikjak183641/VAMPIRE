#!/usr/bin/env bash
set -euo pipefail

# Automated setup: start MariaDB container, import dump (if present), copy SQL, and run it
# Usage: API_KEY=yourkey ./setup_db.sh

CONTAINER_NAME=${CONTAINER_NAME:-vamp_mariadb}
IMAGE=${IMAGE:-mariadb:10.11}
ROOT_PASS=${ROOT_PASS:-rootpass}
DB_NAME=${DB_NAME:-main}
HOST_PORT=${HOST_PORT:-3307}

API_KEY=${API_KEY:-DUMMY_API_KEY}

echo "[setup] Using container ${CONTAINER_NAME}, image ${IMAGE}, DB ${DB_NAME} on host port ${HOST_PORT}"

# Start container if not present
if [ "$(docker ps -a --format '{{.Names}}' | grep -w ${CONTAINER_NAME} || true)" = "${CONTAINER_NAME}" ]; then
  echo "[setup] Container ${CONTAINER_NAME} already exists. Removing to ensure a clean start."
  docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1 || true
fi

echo "[setup] Starting MariaDB container..."
docker run --name ${CONTAINER_NAME} -e MYSQL_ROOT_PASSWORD=${ROOT_PASS} -e MYSQL_DATABASE=${DB_NAME} -p ${HOST_PORT}:3306 -d ${IMAGE}

echo "[setup] Waiting for database to be ready..."
for i in {1..30}; do
  if docker exec ${CONTAINER_NAME} mysqladmin ping -uroot -p${ROOT_PASS} --silent &>/dev/null; then
    echo "[setup] MariaDB is up"
    break
  fi
  sleep 1
done

echo "[setup] Copying SQL files into container..."
docker cp SALESEmployee.sql ${CONTAINER_NAME}:/tmp/SALESEmployee.sql
if [ -f main_dump.sql ]; then
  docker cp main_dump.sql ${CONTAINER_NAME}:/tmp/main_dump.sql || true
fi

echo "[setup] Importing dump (if present)..."
if docker exec ${CONTAINER_NAME} sh -c "[ -f /tmp/main_dump.sql ] && echo present || echo missing" | grep -q present; then
  if ! docker exec -i ${CONTAINER_NAME} sh -c "mysql -uroot -p${ROOT_PASS} ${DB_NAME} < /tmp/main_dump.sql"; then
    echo "[setup] Warning: importing main_dump.sql failed. Continuing and attempting to run SALESEmployee.sql directly."
  else
    echo "[setup] main_dump.sql imported"
  fi
fi

echo "[setup] Running SALESEmployee.sql with API_KEY session variable..."
docker exec -i ${CONTAINER_NAME} mysql -uroot -p${ROOT_PASS} ${DB_NAME} -e "SET @api_key='${API_KEY}'; SOURCE /tmp/SALESEmployee.sql;"

echo "[setup] Done. Container ${CONTAINER_NAME} is running on localhost:${HOST_PORT}"
echo "To stop and remove: ./teardown_db.sh"
