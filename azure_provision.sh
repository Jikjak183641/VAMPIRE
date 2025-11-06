#!/usr/bin/env bash
set -euo pipefail

# azure_provision.sh
# Parameterized script to provision an Azure Database for MySQL (Flexible Server) using the Azure CLI.
# Requires: az CLI logged in and subscription set (az login; az account set --subscription <id>)

print_usage() {
  cat <<EOF
Usage: $0 -g <resource-group> -s <server-name> -u <admin-user> [-p <admin-password>] [-l <location>] [-i <allowed-ip>]

This will create an Azure Resource Group (if missing), a MySQL Flexible Server (MySQL 8.0),
and a database named 'my_database'.

Options:
  -g RESOURCE_GROUP   Azure resource group name
  -s SERVER_NAME      MySQL server name (must be globally unique)
  -u ADMIN_USER       Admin username (no @server suffix)
  -p ADMIN_PASSWORD   Admin password (if omitted you'll be prompted)
  -l LOCATION         Azure location (default: eastus)
  -i ALLOWED_IP       Optional client IP to allow in firewall (default: your current IP)
  -k SKU              SKU name (default: Standard_B1ms)
  -?                  Show this help

Example:
  ./azure_provision.sh -g rg-vampire -s vampire-mysql -u dbadmin -i 1.2.3.4

EOF
}

RESOURCE_GROUP=""
SERVER_NAME=""
ADMIN_USER=""
ADMIN_PASSWORD=""
LOCATION="eastus"
ALLOWED_IP=""
SKU="Standard_B1ms"

while getopts ":g:s:u:p:l:i:k:?" opt; do
  case $opt in
    g) RESOURCE_GROUP="$OPTARG" ;;
    s) SERVER_NAME="$OPTARG" ;;
    u) ADMIN_USER="$OPTARG" ;;
    p) ADMIN_PASSWORD="$OPTARG" ;;
    l) LOCATION="$OPTARG" ;;
    i) ALLOWED_IP="$OPTARG" ;;
    k) SKU="$OPTARG" ;;
    ?) print_usage; exit 0 ;;
  esac
done

if [[ -z "$RESOURCE_GROUP" || -z "$SERVER_NAME" || -z "$ADMIN_USER" ]]; then
  echo "Error: resource group, server name and admin user are required."
  print_usage
  exit 2
fi

if [[ -z "$ADMIN_PASSWORD" ]]; then
  echo -n "Enter admin password for $ADMIN_USER: "
  read -s ADMIN_PASSWORD
  echo
fi

# determine allowed IP if not provided
if [[ -z "$ALLOWED_IP" ]]; then
  echo "Fetching your public IP to authorize in firewall..."
  ALLOWED_IP=$(curl -s ifconfig.me || curl -s https://api.ipify.org || true)
  if [[ -z "$ALLOWED_IP" ]]; then
    echo "Could not determine public IP. Provide one with -i option." >&2
    exit 2
  fi
  echo "Using detected IP: $ALLOWED_IP"
fi

echo "Creating resource group '$RESOURCE_GROUP' in $LOCATION (if not exists)..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

echo "Creating MySQL Flexible Server '$SERVER_NAME' (MySQL 8.0) ..."
az mysql flexible-server create \
  --name "$SERVER_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --admin-user "$ADMIN_USER" \
  --admin-password "$ADMIN_PASSWORD" \
  --sku-name "$SKU" \
  --version "8.0" \
  --public-access "none" \
  --storage-size 32

echo "Creating database 'my_database'..."
az mysql flexible-server db create --resource-group "$RESOURCE_GROUP" --server-name "$SERVER_NAME" --database-name my_database

echo "Creating firewall rule to allow $ALLOWED_IP ..."
az mysql flexible-server firewall-rule create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$SERVER_NAME" \
  --start-ip-address "$ALLOWED_IP" \
  --end-ip-address "$ALLOWED_IP"

echo
echo "Provisioning complete."
echo "Server host: ${SERVER_NAME}.mysql.database.azure.com"
echo "Database: my_database"
echo "To create additional DB users or run SQL, use the mysql client:"
echo "  mysql --host=${SERVER_NAME}.mysql.database.azure.com --user=${ADMIN_USER}@${SERVER_NAME} --database=my_database -p"

echo "Note: The script set public-access to 'none' and created a firewall rule for the provided IP."
echo "If you need programmatic access from CI, add the CI runner IP range or configure private networking." 
