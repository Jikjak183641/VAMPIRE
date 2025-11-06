#!/usr/bin/env bash
set -euo pipefail

# import_to_azure_mysql.sh
# Simple helper to import a .sql file into an Azure (or any) MySQL instance.
# Usage examples:
#   MYSQL_HOST=myserver.mysql.database.azure.com MYSQL_USER=myuser@myserver MYSQL_DB=my_database ./import_to_azure_mysql.sh NYC_mysql.sql
#   ./import_to_azure_mysql.sh -h myserver.mysql.database.azure.com -u myuser@myserver -d my_database NYC_mysql.sql

print_usage() {
  cat <<EOF
Usage: $0 [options] <sql-file>

Options:
  -h HOST       MySQL host (or set MYSQL_HOST env)
  -u USER       MySQL user (or set MYSQL_USER env)
  -d DATABASE   Target database (or set MYSQL_DB env)
  -p            Read password from prompt (recommended if MYSQL_PWD not set)
  -?            Show this help

Environment variables supported: MYSQL_HOST, MYSQL_USER, MYSQL_DB, MYSQL_PWD

EOF
}

MYSQL_HOST=${MYSQL_HOST:-}
MYSQL_USER=${MYSQL_USER:-}
MYSQL_DB=${MYSQL_DB:-}
PROMPT_PWD=0

while getopts ":h:u:d:p?" opt; do
  case $opt in
    h) MYSQL_HOST="$OPTARG" ;;
    u) MYSQL_USER="$OPTARG" ;;
    d) MYSQL_DB="$OPTARG" ;;
    p) PROMPT_PWD=1 ;;
    ?) print_usage; exit 0 ;;
  esac
done
shift $((OPTIND-1))

SQL_FILE=${1:-}

if [[ -z "$SQL_FILE" ]]; then
  echo "Error: missing SQL file."
  print_usage
  exit 2
fi

if [[ ! -f "$SQL_FILE" ]]; then
  echo "Error: SQL file '$SQL_FILE' not found."
  exit 2
fi

if [[ -z "$MYSQL_HOST" || -z "$MYSQL_USER" || -z "$MYSQL_DB" ]]; then
  echo "Error: MYSQL_HOST, MYSQL_USER, and MYSQL_DB must be set (via flags or env vars)."
  print_usage
  exit 2
fi

if [[ -z "${MYSQL_PWD:-}" && $PROMPT_PWD -eq 0 ]]; then
  # Prompt the user for password if not set and -p not provided
  echo -n "MySQL password for $MYSQL_USER@$MYSQL_HOST: "
  read -s MYSQL_PWD
  echo
fi

if [[ -z "${MYSQL_PWD:-}" ]]; then
  echo "Password not provided. Set MYSQL_PWD env or re-run with -p to prompt." >&2
  exit 2
fi

echo "Importing '$SQL_FILE' into $MYSQL_USER@$MYSQL_HOST/$MYSQL_DB..."

# Use MYSQL_PWD env to avoid exposing password on the process list in many environments
export MYSQL_PWD

mysql --host="$MYSQL_HOST" --user="$MYSQL_USER" --database="$MYSQL_DB" --default-character-set=utf8mb4 < "$SQL_FILE"

echo "Import completed."
