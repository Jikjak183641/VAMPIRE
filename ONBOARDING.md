# VAMPIRE Onboarding Guide

Welcome to the VAMPIRE project! This guide will help you get started quickly with importing the NYC dataset into Azure MySQL.

## Quick Start Checklist

- [ ] Review [README.md](README.md) for full details.
- [ ] Install prerequisites: Azure CLI, MySQL client, Git.
- [ ] Provision Azure MySQL server: `./azure_provision.sh -g <rg> -s <server> -u <user>`
- [ ] Import data: `./import_to_azure_mysql.sh -h <host> -u <user> -d my_database -p NYC_mysql.sql`
- [ ] Verify: Connect and run `SELECT * FROM t1;`
- [ ] Push to GitHub: Follow [push_instructions.md](push_instructions.md)
- [ ] Set up CI: Add secrets and run workflow.

## Key Files

- **README.md**: Comprehensive project overview, setup, and usage.
- **NYC_mysql.sql**: The SQL file to import.
- **import_to_azure_mysql.sh**: Import script.
- **azure_provision.sh**: Provisioning script.
- **.github/workflows/import.yml**: CI workflow.
- **push_instructions.md**: GitHub setup.
- **STAKEHOLDER_MESSAGE.md**: Delivery notes.

## Common Issues

- MySQL version < 8.0: Update server.
- Firewall blocks: Add your IP or use private networking.
- Privileges missing: Grant CREATE ROUTINE.

For full documentation, see README.md.
