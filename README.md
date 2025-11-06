# VAMPIRE - NYC SQL Import to Azure MySQL

## Overview

VAMPIRE is a collection of MySQL-compatible SQL artifacts and automation scripts designed to import the `NYC` dataset into an Azure Database for MySQL Flexible Server (or any MySQL 8.0+ instance). This project provides a streamlined way to set up, provision, and import data, including example stored procedures for JSON-based operations.

The core components include:
- A cleaned MySQL 8.0-compatible SQL file (`NYC_mysql.sql`) that creates a database, table, sample data, and stored routines.
- Provisioning scripts for Azure infrastructure.
- Import helpers for secure data loading.
- CI/CD integration via GitHub Actions for automated imports.

## Prerequisites

Before getting started, ensure you have the following:

- **Azure CLI**: Installed and logged in (`az login`). Required for provisioning Azure resources.
- **MySQL Client**: `mysql` CLI tool installed (e.g., via `sudo apt-get install default-mysql-client` on Ubuntu).
- **Bash**: For running shell scripts (Linux/macOS or WSL on Windows).
- **Git**: For version control and pushing to GitHub.
- **GitHub CLI (optional)**: For creating repos via CLI (`gh`).
- **Azure Subscription**: With permissions to create resource groups, MySQL servers, and databases.
- **MySQL 8.0+**: Target server must support JSON functions (e.g., `JSON_TABLE`, `->>`).

## Project Structure

- `NYC_mysql.sql`: MySQL-compatible SQL file with database schema, data, and stored procedures.
- `import_to_azure_mysql.sh`: Script to import SQL files into a MySQL server securely.
- `azure_provision.sh`: Script to provision an Azure MySQL Flexible Server and database.
- `.github/workflows/import.yml`: GitHub Actions workflow for automated imports.
- `push_instructions.md`: Instructions for initializing and pushing the repo to GitHub.
- `STAKEHOLDER_MESSAGE.md`: Delivery summary and verification guide.
- `LICENSE`: MIT License.
- `.gitignore`: Standard ignore rules for secrets and artifacts.

## Setup Instructions

### Step 1: Clone or Initialize the Repository

If not already done, clone this repo or initialize locally:

```bash
git clone https://github.com/<your-org-or-username>/VAMPIRE.git
cd VAMPIRE
```

### Step 2: Provision Azure MySQL Server

Use the provisioning script to create an Azure MySQL Flexible Server. This script creates a resource group, MySQL server (MySQL 8.0), database (`my_database`), and a firewall rule for your IP.

```bash
chmod +x azure_provision.sh
./azure_provision.sh -g <resource-group-name> -s <unique-server-name> -u <admin-username> -l <location> -i <your-ip>
```

- Replace `<resource-group-name>` with a new or existing Azure resource group.
- `<unique-server-name>` must be globally unique (e.g., `vampire-mysql-123`).
- `<admin-username>` is the DB admin user (no `@server` suffix).
- `<location>` defaults to `eastus` if omitted.
- `<your-ip>` is your public IP; if omitted, the script detects it automatically.

Example:
```bash
./azure_provision.sh -g rg-vampire -s vampire-mysql-demo -u dbadmin -i 203.0.113.1
```

**Notes**:
- You'll be prompted for the admin password if not provided via `-p`.
- The server is created with public access disabled except for the specified IP. For CI access, add runner IPs or use private networking.
- SKU defaults to `Standard_B1ms`; adjust with `-k` if needed.

After provisioning, note the server host: `<server-name>.mysql.database.azure.com`.

### Step 3: Import the SQL Data

Once the server is provisioned, import the `NYC_mysql.sql` file using the import script.

Set environment variables or use flags:

```bash
export MYSQL_HOST=<server-name>.mysql.database.azure.com
export MYSQL_USER=<admin-username>@<server-name>
export MYSQL_DB=my_database
export MYSQL_PWD=<admin-password>

./import_to_azure_mysql.sh NYC_mysql.sql
```

Or with flags (prompts for password if `-p` used):

```bash
./import_to_azure_mysql.sh -h <server-name>.mysql.database.azure.com -u <admin-username>@<server-name> -d my_database -p NYC_mysql.sql
```

**Security Tip**: Never hardcode passwords in scripts. Use environment variables or prompts.

## Usage Guide

### Verifying the Import

After import, connect to the database and run verification queries:

```bash
mysql --host=<server-name>.mysql.database.azure.com --user=<admin-username>@<server-name> --database=my_database -p
```

Then execute:

```sql
SELECT COUNT(*) AS total_rows FROM t1;
SELECT * FROM t1 ORDER BY id LIMIT 10;
```

Expected: 3 rows with sample data (Andy, George, Betty).

### Using Stored Procedures

The SQL file includes example stored procedures for JSON-based operations (requires MySQL 8.0+):

- **BatchGetItem**: Retrieve multiple rows by ID array.
  ```sql
  CALL BatchGetItem('[1,2]');
  ```

- **PutItem**: Insert or update a row from JSON.
  ```sql
  CALL PutItem('{"id":4, "name":"Cecilia"}');
  ```

- **GetItem**: Retrieve a single row by ID.
  ```sql
  CALL GetItem('{"id":1}');
  ```

- **DeleteItem**: Delete a row by ID.
  ```sql
  CALL DeleteItem('{"id":3}');
  ```

- **TableExists**: Utility function to check table existence.
  ```sql
  SELECT TableExists('t1');
  ```

### Running via CI/CD

The GitHub Actions workflow (`.github/workflows/import.yml`) allows manual or automated imports.

1. Push the repo to GitHub (see `push_instructions.md`).
2. Add repository secrets: `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_DB`, `MYSQL_PWD`.
3. Trigger the workflow from the Actions tab in GitHub.

This runs the import script in a secure environment without exposing credentials.

## Security and Best Practices

- **Credentials**: Never commit passwords or keys. Use GitHub Secrets for CI, environment variables for local runs, or prompts.
- **Privileges**: Ensure the DB user has `CREATE ROUTINE` and `ALTER ROUTINE` for stored procedures.
- **Firewall**: Provision script adds your IP; for broader access, configure VNet integration or add IP ranges.
- **Backups**: Regularly back up your Azure MySQL instance via Azure portal or CLI.
- **Compliance**: For production, enable encryption, auditing, and HA as needed.

## Troubleshooting

- **Import Fails**: Check MySQL version (must be 8.0+), connection details, and user privileges.
- **Azure Provisioning Errors**: Ensure Azure CLI is logged in and subscription is set (`az account set --subscription <id>`).
- **Firewall Issues**: Verify your IP is allowed or use private endpoints.
- **JSON Errors**: Confirm MySQL 8.0+; stored procedures use JSON functions.

## Contributing

1. Fork the repo and create a feature branch.
2. Make changes, test locally.
3. Submit a pull request with a description of changes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Next Steps

- Enhance stored procedures for production use (e.g., better error handling).
- Add ARM/Bicep templates for advanced Azure deployments.
- Integrate with monitoring tools like Azure Monitor.
