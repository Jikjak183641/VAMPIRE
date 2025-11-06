-- Create a new database (if needed)
CREATE DATABASE IF NOT EXISTS my_database;
USE my_database;

-- Create table equivalent to the Python example
CREATE TABLE t1 (
    id INT,
    name VARCHAR(20)
);

-- Insert data equivalent to the Python example
INSERT INTO t1 VALUES
(1, 'Andy'),
(2, 'George'),
(3, 'Betty');

-- Batch operations would be handled differently in MySQL
-- Here are stored procedures to mimic some of the batch functionality

-- BatchGetItem equivalent
DELIMITER //
CREATE PROCEDURE BatchGetItem(IN table_names JSON, IN keys JSON)
BEGIN
    -- MySQL doesn't have direct batch get, so we'd need to implement this differently
    -- This is a simplified example that would need to be expanded
    SELECT * FROM t1 WHERE id IN (SELECT * FROM JSON_TABLE(keys, '$[*]' COLUMNS(value INT PATH '$')));

    -- For multiple tables, you would need dynamic SQL
END //
DELIMITER ;

-- BatchWriteItem equivalent
DELIMITER //
CREATE PROCEDURE BatchWriteItem(IN operations JSON)
BEGIN
    -- This would parse the JSON and perform multiple inserts/updates
    -- Implementation would depend on your specific requirements
    -- This is a placeholder showing the concept
    DECLARE i INT DEFAULT 0;
    DECLARE op_count INT;

    SELECT JSON_LENGTH(operations) INTO op_count;

    WHILE i < op_count DO
        -- Extract operation details and execute
        -- This would need to be implemented based on your specific format
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

-- CreateTable procedure
DELIMITER //
CREATE PROCEDURE CreateTable(IN table_name VARCHAR(255), IN table_definition TEXT)
BEGIN
    SET @sql = CONCAT('CREATE TABLE ', table_name, ' (', table_definition, ')');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- DescribeTable equivalent
DELIMITER //
CREATE PROCEDURE DescribeTable(IN table_name VARCHAR(255))
BEGIN
    SELECT
        COLUMN_NAME AS `Field`,
        COLUMN_TYPE AS `Type`,
        IS_NULLABLE AS `Null`,
        COLUMN_KEY AS `Key`,
        COLUMN_DEFAULT AS `Default`,
        EXTRA AS `Extra`
    FROM
        INFORMATION_SCHEMA.COLUMNS
    WHERE
        TABLE_SCHEMA = DATABASE() AND
        TABLE_NAME = table_name;
END //
DELIMITER ;

-- DeleteTable procedure
DELIMITER //
CREATE PROCEDURE DeleteTable(IN table_name VARCHAR(255))
BEGIN
    SET @sql = CONCAT('DROP TABLE IF EXISTS ', table_name);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- ListTables equivalent
DELIMITER //
CREATE PROCEDURE ListTables()
BEGIN
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = DATABASE();
END //
DELIMITER ;

-- Table operations
DELIMITER //
CREATE PROCEDURE DeleteItem(IN table_name VARCHAR(255), IN item_key JSON)
BEGIN
    SET @sql = CONCAT('DELETE FROM ', table_name, ' WHERE id = ', JSON_EXTRACT(item_key, '$.id'));
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE GetItem(IN table_name VARCHAR(255), IN item_key JSON)
BEGIN
    SET @sql = CONCAT('SELECT * FROM ', table_name, ' WHERE id = ', JSON_EXTRACT(item_key, '$.id'));
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE PutItem(IN table_name VARCHAR(255), IN item_data JSON)
BEGIN
    -- This would need to parse the JSON and build an INSERT or UPDATE statement
    -- Implementation depends on your specific data format
    SET @sql = CONCAT('INSERT INTO ', table_name, ' (id, name) VALUES (',
                      JSON_EXTRACT(item_data, '$.id'), ', ',
                      JSON_EXTRACT(item_data, '$.name'), ')');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateItem(IN table_name VARCHAR(255), IN item_data JSON)
BEGIN
    -- Similar to PutItem but would use UPDATE instead
    SET @sql = CONCAT('UPDATE ', table_name, ' SET name = ',
                      JSON_EXTRACT(item_data, '$.name'), ' WHERE id = ',
                      JSON_EXTRACT(item_data, '$.id'));
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Waiter equivalents would need to be implemented as functions
-- that poll the table status until the desired state is reached

DELIMITER //
CREATE FUNCTION TableExists(IN table_name VARCHAR(255))
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE table_count INT;

    SELECT COUNT(*) INTO table_count
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = table_name;

    RETURN table_count > 0;
END //
DELIMITER ;
