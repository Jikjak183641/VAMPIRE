-- MySQL-compatible version of NYC.SQL
-- Target: MySQL 8.0+ (required for JSON_TABLE and ->> operator)

-- Create a new database (if needed)
CREATE DATABASE IF NOT EXISTS my_database CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
USE my_database;

-- Create table equivalent to the Python example
CREATE TABLE IF NOT EXISTS t1 (
    id INT PRIMARY KEY,
    name VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert data equivalent to the Python example
INSERT INTO t1 (id, name) VALUES
(1, 'Andy'),
(2, 'George'),
(3, 'Betty')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Stored procedures and functions (examples)
-- Notes:
-- 1) JSON functions used here require MySQL 8.0+.
-- 2) On managed services (Azure MySQL) you need CREATE ROUTINE privilege.
-- 3) Dynamic SQL must safely quote/unquote JSON values; examples below demonstrate the pattern.

DELIMITER //

-- BatchGetItem example: accepts a JSON array of IDs and returns matching rows from t1
CREATE PROCEDURE BatchGetItem(IN keys JSON)
BEGIN
    -- keys expected like: [1,2,3]
    SELECT t1.*
    FROM t1
    JOIN JSON_TABLE(keys, '$[*]' COLUMNS(value INT PATH '$')) AS jt ON t1.id = jt.value;
END //

-- Simple PutItem: insert or update based on JSON object {"id": 1, "name": "Alice"}
CREATE PROCEDURE PutItem(IN item_data JSON)
BEGIN
    DECLARE v_id INT;
    DECLARE v_name VARCHAR(255);

    SET v_id = JSON_EXTRACT(item_data, '$.id');
    SET v_name = JSON_UNQUOTE(JSON_EXTRACT(item_data, '$.name'));

    INSERT INTO t1 (id, name)
    VALUES (v_id, v_name)
    ON DUPLICATE KEY UPDATE name = VALUES(name);
END //

-- GetItem: returns the row for a given JSON key {"id": 1}
CREATE PROCEDURE GetItem(IN item_key JSON)
BEGIN
    SELECT * FROM t1 WHERE id = JSON_EXTRACT(item_key, '$.id');
END //

-- DeleteItem: deletes the row for a given JSON key {"id": 1}
CREATE PROCEDURE DeleteItem(IN item_key JSON)
BEGIN
    DELETE FROM t1 WHERE id = JSON_EXTRACT(item_key, '$.id');
END //

-- Utility function to check table existence (MySQL function parameters do not use IN keyword)
CREATE FUNCTION TableExists(table_name VARCHAR(255))
RETURNS TINYINT(1)
DETERMINISTIC
BEGIN
    DECLARE table_count INT DEFAULT 0;
    SELECT COUNT(*) INTO table_count
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = table_name;
    RETURN (table_count > 0);
END //

DELIMITER ;

-- Example usage comments:
-- CALL BatchGetItem('[1,2]');
-- CALL PutItem('{"id":4, "name":"Cecilia"}');
-- CALL GetItem('{"id":1}');
-- CALL DeleteItem('{"id":3}');

-- End of file
