# Database dump and run instructions

Files added/updated in this workspace:

- `SALESEmployee.sql` — main SQL file (API key placeholder set to NULL). Do not store secrets here.
- `run_sales_sql.sh` — small wrapper script that sets the session API key from the environment and runs the SQL file.
- `main_dump.sql` — (created by the automation) SQL dump of the `main` database (if present).

Quick usage
-----------

1) Run the SQL against a local DB with an API key in env:

   API_KEY=sk.YOURKEY DB_HOST=127.0.0.1 DB_PORT=3307 ./run_sales_sql.sh

2) Automated setup (start a disposable MariaDB container, import dump and run SQL):

   API_KEY=sk.YOURKEY ./setup_db.sh

   This will start a container named `vamp_mariadb` listening on port 3307 by default. Use `./teardown_db.sh` to stop and remove it when done.

3) Use the included MariaDB Docker container (how this workspace was run):

   # Start a disposable MariaDB container (if you need a fresh one):
   docker run --name vamp_mariadb -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=main -p 3307:3306 -d mariadb:10.11

   # Copy file into container and run inside it (recommended for safety):
   docker cp SALESEmployee.sql vamp_mariadb:/tmp/SALESEmployee.sql
   docker exec -i vamp_mariadb mysql -uroot -prootpass main -e "SET @api_key='YOUR_API_KEY'; SOURCE /tmp/SALESEmployee.sql;"

3) Restore the provided DB dump (main_dump.sql) into an empty MariaDB instance:

   # inside a running MariaDB server:
   mysql -uroot -prootpass main < main_dump.sql

Security note
-------------
The original `SALESEmployee.sql` contained a hard-coded API key. That key was removed and replaced with a placeholder. Use `API_KEY` environment variable or your secret manager to inject it at runtime. Rotate keys if the original value is sensitive.

Cleanup
-------
To remove the disposable container used earlier:

   docker stop vamp_mariadb && docker rm vamp_mariadb
