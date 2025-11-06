# VAMPIRE Setup Guide

Follow these steps to set up the VAMPIRE project.

## Prerequisites

- Azure CLI: `az login`
- MySQL client: `sudo apt-get install default-mysql-client`
- Git and GitHub CLI (optional)

## Step-by-Step Setup

### 1. Clone Repository
```bash
git clone https://github.com/<org>/VAMPIRE.git
cd VAMPIRE
```

### 2. Provision Azure Resources
```bash
chmod +x azure_provision.sh
./azure_provision.sh -g rg-vampire -s vampire-mysql -u dbadmin
```

### 3. Import Data
```bash
export MYSQL_HOST=vampire-mysql.mysql.database.azure.com
export MYSQL_USER=dbadmin@vampire-mysql
export MYSQL_DB=my_database
export MYSQL_PWD=<password>

./import_to_azure_mysql.sh NYC_mysql.sql
```

### 4. Verify Import
```bash
mysql --host=$MYSQL_HOST --user=$MYSQL_USER --database=$MYSQL_DB -p
SELECT * FROM t1;
```

### 5. Push to GitHub
See push_instructions.md for details.

## Troubleshooting

- If provisioning fails, check Azure subscription and permissions.
- If import fails, verify MySQL version and credentials.
