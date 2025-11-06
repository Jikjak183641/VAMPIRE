# VAMPIRE Usage Guide

This guide covers how to use the VAMPIRE project after setup.

## Connecting to the Database

```bash
mysql --host=<server>.mysql.database.azure.com --user=<user>@<server> --database=my_database -p
```

## Sample Queries

- Count rows: `SELECT COUNT(*) FROM t1;`
- View data: `SELECT * FROM t1 ORDER BY id;`

## Stored Procedures

### BatchGetItem
```sql
CALL BatchGetItem('[1,2]');
```

### PutItem
```sql
CALL PutItem('{"id":4, "name":"Dana"}');
```

### GetItem
```sql
CALL GetItem('{"id":1}');
```

### DeleteItem
```sql
CALL DeleteItem('{"id":2}');
```

## CI/CD Usage

1. Add secrets in GitHub repo settings.
2. Go to Actions tab, select "Import NYC_mysql.sql", click "Run workflow".

## Best Practices

- Use environment variables for credentials.
- Test locally before CI.
- Monitor Azure costs and usage.
