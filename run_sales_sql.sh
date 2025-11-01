#!/usr/bin/env bash
# Small wrapper to run `SALESEmployee.sql` while injecting an API key from the
# environment. This avoids storing secrets in the SQL file.
#
# Usage examples:
#  API_KEY=sk.XXX ./run_sales_sql.sh            # run against default localhost:3306
#  API_KEY=sk.XXX DB_HOST=127.0.0.1 DB_PORT=3307 ./run_sales_sql.sh  # custom host/port
#  # To run inside the MariaDB container you started earlier:
#  API_KEY=sk.XXX docker exec -i vamp_mariadb mysql -uroot -prootpass main -e "SET @api_key='${API_KEY}'; SOURCE /tmp/SALESEmployee.sql;"

set -euo pipefail

DB_HOST="${DB_HOST:-127.0.0.1}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-rootpass}"
DB_NAME="${DB_NAME:-main}"

if [ -z "${API_KEY:-}" ]; then
  echo "ERROR: API_KEY environment variable is not set."
  echo "Set it like: API_KEY=sk.xxx ./run_sales_sql.sh"
  exit 1
fi

echo "Running /workspaces/VAMPIRE/SALESEmployee.sql against ${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

# Use the mysql client to set the session variable and source the file.
mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASS}" -e "SET @api_key='${API_KEY}';" "${DB_NAME}"
mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" < SALESEmployee.sql

echo "Done."
