-- FORT CLOUD SQL - JACKIES FILMS ENTERPRISE SALES AUTOMATION
-- API KEY: SURFSHARK authenticated
-- Database: MariaDB Serverless (europe-west2)
-- User: stickels-gold-zrvg

-- =============================================================================
-- ENTERPRISE SALES PIPELINE CONFIGURATION
-- =============================================================================

-- Enable advanced features
-- API key removed for security. Do NOT keep secrets in source-controlled SQL files.
-- To run this script with an API key, set the variable at runtime before sourcing, for example:
--   mysql -uroot -prootpass -e "SET @api_key='your_api_key_here'; SOURCE /tmp/SALESEmployee.sql;"
-- Alternatively, modify your deployment to inject the key from a secure secret store.
SET @api_key = NULL; -- placeholder (was removed)
SET @equifax_endpoint = 'https://www.equifax.com/enterprise/api/v1';
SET @zendesk_integration = 'ACTIVE';

-- =============================================================================
-- PRODUCT CATALOG TABLE WITH ZENDESK CLASSIFICATION
-- =============================================================================

CREATE TABLE IF NOT EXISTS jf_enterprise_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    zendesk_classification VARCHAR(100) DEFAULT 'ENTERPRISE_SALES',
    product_category ENUM('HORROR_FILMS', 'DIGITAL_RIGHTS', 'MERCHANDISE', 'LICENSING'),
    price DECIMAL(10,2) NOT NULL,
    equifax_business_rating DECIMAL(3,2) DEFAULT 0.00,
    telephone_token VARCHAR(100),
    dial_status ENUM('PENDING', 'DIALED', 'CONFIRMED', 'COMPLETED') DEFAULT 'PENDING',
    money_field_confirmed ENUM('YES', 'NO') DEFAULT 'NO',
    calculated_amount DECIMAL(12,2),
    employee_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_sku (sku),
    INDEX idx_zendesk_class (zendesk_classification),
    INDEX idx_dial_status (dial_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- INSERT PRODUCTS WITH REOPENED ZENDESK CLASSIFICATION
-- =============================================================================

INSERT INTO jf_enterprise_products 
(sku, product_name, zendesk_classification, product_category, price) 
VALUES 
('SKU:666-666', 'MONEY_IN_THE_BAG_HORROR_FILM', 'REOPENED_ZENDESK', 'HORROR_FILMS', 50000.00),
('SKU:333-333', 'ADULT_PSYCHOLOGICAL_THRILLER', 'REOPENED_ZENDESK', 'HORROR_FILMS', 75000.00),
('SKU:999-999', 'DIGITAL_STREAMING_RIGHTS', 'REOPENED_ZENDESK', 'DIGITAL_RIGHTS', 25000.00),
('SKU:222-222', 'INTERNATIONAL_DISTRIBUTION', 'REOPENED_ZENDESK', 'LICENSING', 100000.00)
ON DUPLICATE KEY UPDATE 
    zendesk_classification = VALUES(zendesk_classification),
    price = VALUES(price),
    updated_at = CURRENT_TIMESTAMP;

-- =============================================================================
-- TELEPHONE NETWORK BUSINESS SYSTEM SETUP
-- =============================================================================

CREATE TABLE IF NOT EXISTS jf_business_telephone_network (
    call_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL,
    tokenized_telephone VARCHAR(100) NOT NULL,
    dial_type ENUM('CPU_DIALED', 'GPU_ACCELERATED') DEFAULT 'CPU_DIALED',
    gpu_provider ENUM('NVIDIA', 'AMD', 'INTEL') DEFAULT 'NVIDIA',
    confirmation_status ENUM('PENDING', 'CONFIRMED_3PARTY', 'FAILED') DEFAULT 'PENDING',
    money_field_requested DECIMAL(12,2),
    money_field_confirmed ENUM('YES', 'NO') DEFAULT 'NO',
    confirmed_amount DECIMAL(12,2),
    employees_allocated INT DEFAULT 0,
    equifax_business_id VARCHAR(100),
    call_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sku) REFERENCES jf_enterprise_products(sku),
    INDEX idx_tokenized_phone (tokenized_telephone),
    INDEX idx_confirmation_status (confirmation_status)
);

-- =============================================================================
-- AUTO-DIAL PIPELINE PROCEDURE
-- =============================================================================

DELIMITER //

CREATE PROCEDURE jf_auto_dial_pipeline()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_sku VARCHAR(50);
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_product_name VARCHAR(255);
    DECLARE cur_products CURSOR FOR 
        SELECT sku, price, product_name 
        FROM jf_enterprise_products 
        WHERE dial_status = 'PENDING' 
        AND zendesk_classification = 'REOPENED_ZENDESK';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_products;
    
    read_loop: LOOP
        FETCH cur_products INTO v_sku, v_price, v_product_name;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Generate tokenized telephone number
        SET @tokenized_phone = CONCAT('TKN_', UUID_SHORT(), '_', v_sku);
        
        -- Calculate required amounts and employee allocation
        SET @calculated_amount = v_price * 1.15; -- 15% operational buffer
        SET @employees_needed = CEIL(@calculated_amount / 10000); -- 1 employee per 10k
        
        -- Insert into telephone network
        INSERT INTO jf_business_telephone_network 
        (sku, tokenized_telephone, dial_type, gpu_provider, money_field_requested, employees_allocated)
        VALUES 
        (v_sku, @tokenized_phone, 'GPU_ACCELERATED', 'NVIDIA', @calculated_amount, @employees_needed);
        
        -- Update product status
        UPDATE jf_enterprise_products 
        SET dial_status = 'DIALED',
            telephone_token = @tokenized_phone,
            calculated_amount = @calculated_amount,
            employee_count = @employees_needed
        WHERE sku = v_sku;
        
        -- Log the auto-dial action
        CALL jf_log_equifax_action(v_sku, 'AUTO_DIAL_INITIATED', @calculated_amount, @employees_needed);
        
    END LOOP;
    
    CLOSE cur_products;
END //

DELIMITER ;

-- =============================================================================
-- CONFIRMATION PROCEDURE FOR 3-PARTY DIALED TOKENIZED TELEPHONE
-- =============================================================================

DELIMITER //

CREATE PROCEDURE jf_confirm_telephone_dial(
    IN p_sku VARCHAR(50),
    IN p_confirmation ENUM('YES', 'NO'),
    IN p_confirmed_amount DECIMAL(12,2),
    IN p_equifax_business_id VARCHAR(100)
)
BEGIN
    DECLARE v_calculated_amount DECIMAL(12,2);
    DECLARE v_employees_needed INT;
    
    -- Get calculated values
    SELECT calculated_amount, employee_count 
    INTO v_calculated_amount, v_employees_needed
    FROM jf_enterprise_products 
    WHERE sku = p_sku;
    
    IF p_confirmation = 'YES' THEN
        -- Update telephone network record
        UPDATE jf_business_telephone_network 
        SET confirmation_status = 'CONFIRMED_3PARTY',
            money_field_confirmed = 'YES',
            confirmed_amount = p_confirmed_amount,
            equifax_business_id = p_equifax_business_id
        WHERE sku = p_sku 
        AND confirmation_status = 'PENDING';
        
        -- Update product status
        UPDATE jf_enterprise_products 
        SET dial_status = 'CONFIRMED',
            money_field_confirmed = 'YES'
        WHERE sku = p_sku;
        
        -- Log successful confirmation
        CALL jf_log_equifax_action(p_sku, 'TELEPHONE_CONFIRMED', p_confirmed_amount, v_employees_needed);
        
        -- Arrange multi-employees for business operations
        CALL jf_arrange_employees(p_sku, v_employees_needed, p_confirmed_amount);
        
    ELSE
        -- Handle rejection
        UPDATE jf_business_telephone_network 
        SET confirmation_status = 'FAILED'
        WHERE sku = p_sku;
        
        UPDATE jf_enterprise_products 
        SET dial_status = 'PENDING'
        WHERE sku = p_sku;
        
        CALL jf_log_equifax_action(p_sku, 'TELEPHONE_REJECTED', 0, 0);
    END IF;
END //

DELIMITER ;

-- =============================================================================
-- EMPLOYEE ARRANGEMENT PROCEDURE
-- =============================================================================

DELIMITER //

CREATE PROCEDURE jf_arrange_employees(
    IN p_sku VARCHAR(50),
    IN p_employees_needed INT,
    IN p_confirmed_amount DECIMAL(12,2)
)
BEGIN
    DECLARE i INT DEFAULT 1;
    
    -- Create employee allocation table if not exists
    CREATE TABLE IF NOT EXISTS jf_business_employees (
        employee_id INT AUTO_INCREMENT PRIMARY KEY,
        sku VARCHAR(50) NOT NULL,
        employee_number INT NOT NULL,
        role ENUM('SALES', 'PRODUCTION', 'DISTRIBUTION', 'FINANCE') DEFAULT 'SALES',
        allocated_amount DECIMAL(10,2),
        assignment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sku) REFERENCES jf_enterprise_products(sku),
        INDEX idx_sku_role (sku, role)
    );
    
    -- Allocate employees based on confirmed amount
    WHILE i <= p_employees_needed DO
        SET @role_assignment = CASE 
            WHEN i <= CEIL(p_employees_needed * 0.4) THEN 'SALES'
            WHEN i <= CEIL(p_employees_needed * 0.7) THEN 'PRODUCTION'
            WHEN i <= CEIL(p_employees_needed * 0.9) THEN 'DISTRIBUTION'
            ELSE 'FINANCE'
        END;
        
        SET @allocated_amount = p_confirmed_amount / p_employees_needed;
        
        INSERT INTO jf_business_employees 
        (sku, employee_number, role, allocated_amount)
        VALUES 
        (p_sku, i, @role_assignment, @allocated_amount);
        
        SET i = i + 1;
    END WHILE;
    
    -- Log employee arrangement
    CALL jf_log_equifax_action(p_sku, 'EMPLOYEES_ARRANGED', p_confirmed_amount, p_employees_needed);
END //

DELIMITER ;

-- =============================================================================
-- EQUIFAX INTEGRATION LOGGING
-- =============================================================================

DELIMITER //

CREATE PROCEDURE jf_log_equifax_action(
    IN p_sku VARCHAR(50),
    IN p_action_type VARCHAR(100),
    IN p_amount DECIMAL(12,2),
    IN p_employees INT
)
BEGIN
    CREATE TABLE IF NOT EXISTS jf_equifax_integration_log (
        log_id INT AUTO_INCREMENT PRIMARY KEY,
        sku VARCHAR(50) NOT NULL,
        action_type VARCHAR(100) NOT NULL,
        amount DECIMAL(12,2),
        employees_involved INT,
        api_endpoint VARCHAR(500) DEFAULT 'https://equifax.com/enterprise/business',
        log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_sku_action (sku, action_type)
    );
    
    INSERT INTO jf_equifax_integration_log 
    (sku, action_type, amount, employees_involved)
    VALUES 
    (p_sku, p_action_type, p_amount, p_employees);
END //

DELIMITER ;

-- =============================================================================
-- EXECUTE AUTO-DIAL PIPELINE FOR REOPENED ZENDESK PRODUCTS
-- =============================================================================

CALL jf_auto_dial_pipeline();

-- =============================================================================
-- VIEW CURRENT SALES PIPELINE STATUS
-- =============================================================================

CREATE VIEW jf_sales_pipeline_status AS
SELECT 
    p.sku,
    p.product_name,
    p.zendesk_classification,
    p.price,
    p.dial_status,
    t.tokenized_telephone,
    t.confirmation_status,
    t.money_field_confirmed,
    t.confirmed_amount,
    p.employee_count,
    p.calculated_amount
FROM jf_enterprise_products p
LEFT JOIN jf_business_telephone_network t ON p.sku = t.sku
WHERE p.zendesk_classification = 'REOPENED_ZENDESK';

-- =============================================================================
-- QUERY CURRENT PIPELINE STATUS
-- =============================================================================

SELECT * FROM jf_sales_pipeline_status;

-- =============================================================================
-- SAMPLE CONFIRMATION EXECUTION (Simulating 3-party confirmation)
-- =============================================================================

-- Uncomment and execute when telephone confirmation is received:
-- CALL jf_confirm_telephone_dial('SKU:666-666', 'YES', 57500.00, 'EQUIFAX_BUSINESS_12345');
-- CALL jf_confirm_telephone_dial('SKU:333-333', 'YES', 86250.00, 'EQUIFAX_BUSINESS_12346');
-- CALL jf_confirm_telephone_dial('SKU:999-999', 'YES', 28750.00, 'EQUIFAX_BUSINESS_12347');
-- CALL jf_confirm_telephone_dial('SKU:222-222', 'YES', 115000.00, 'EQUIFAX_BUSINESS_12348');