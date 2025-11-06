Subject: VAMPIRE — NYC SQL import to Azure MySQL — Delivery

Summary
-------
I prepared a MySQL 8.0-compatible SQL file and automation to import the `NYC` dataset into an Azure MySQL instance. The main artifacts are in the repository and include a provisioning script, an import helper, and a GitHub Actions workflow to run the import from CI.

Artifacts
---------
- `NYC_mysql.sql` — MySQL 8.0-compatible SQL (creates `my_database`, table `t1`, sample data, and stored routine examples).
- `import_to_azure_mysql.sh` — Helper to import a .sql file using the `mysql` client (uses env vars or prompts for password).
- `azure_provision.sh` — Parameterized Azure CLI script to create an Azure MySQL Flexible Server and a `my_database` database.
- `.github/workflows/import.yml` — Manual GitHub Actions workflow that imports `NYC_mysql.sql` using repository secrets.

How to verify (quick checks)
---------------------------
1. After import, connect via mysql client:

   mysql --host=<host> --user=<user>@<server> --database=my_database -p

2. Run verification queries:

   SELECT COUNT(*) AS total_rows FROM t1;
   SELECT * FROM t1 ORDER BY id LIMIT 10;

3. Call a sample stored procedure (examples):

   CALL BatchGetItem('[1,2]');
   CALL GetItem('{"id":1}');

Security & operational notes
----------------------------
- Do not store credentials in the repo. Use GitHub Secrets for the Actions workflow: `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_DB`, `MYSQL_PWD`.
- Azure provisioning script configures a firewall rule for your IP by default; for CI access, add the runner IP ranges or use private networking.
- The stored procedure examples use JSON functions requiring MySQL 8.0+. Ensure server version >= 8.0.

Next steps offered
------------------
1. I can finish wiring this into a `VAMPIRE` repo layout and provide exact git commands to push to GitHub.
2. I can create a more production-like Azure ARM/Bicep template with backups and HA configuration.
3. I can add more complete stored-procedure JSON parsing and safer value quoting if you want production-ready routines.

Acceptance criteria
-------------------
- SQL imports without syntax errors into a MySQL 8.0+ instance.
- CI workflow can import using secrets without exposing credentials in logs.
- Stakeholders can run the verification queries above and confirm expected rows are present.
