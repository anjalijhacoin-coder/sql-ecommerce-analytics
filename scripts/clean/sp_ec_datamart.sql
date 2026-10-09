/*
===============================================================================
Stored Procedure: Load Clean Datamart Layer (ec_datamart.sp_clean_datamart)
===============================================================================
Script Purpose:
    This stored procedure orchestrates the transformation and loading process 
    from the raw operational schema ('ec_core') into the structured, cleaned 
    analytics layer ('ec_datamart'). 
    
    Operations Performed:
    - Re-provisions clean tables (customers, orders, products, shipping, web events).
    - Standardizes text casing, trims spaces, and handles missing values.
    - Parses JSON metadata, normalizes units (weights/dimensions), and cleans dates.
    - Tracks execution duration per table and logs total pipeline run time.
    - Implements robust error handling via TRY/CATCH blocks.

Usage:
    EXEC ec_datamart.sp_clean_datamart;
===============================================================================
*/

CREATE OR ALTER PROCEDURE ec_datamart.sp_clean_datamart AS
BEGIN 
DECLARE @start_time DATETIME,  @end_time DATETIME,  @batch_start_time DATETIME,  @batch_end_time DATETIME
BEGIN TRY
SET  @batch_start_time =GETDATE();
PRINT'=========================================================';
PRINT'>>>>Loading Datamart Layer';
PRINT'=========================================================';

PRINT'---------------------------------------------------------';
PRINT'>>>>Loading Clean Tables';
PRINT'---------------------------------------------------------';

--Loading ec_datamart.clean_customers 
SET @start_time =GETDATE();
PRINT'>>>Dropping table:ec_datamart.clean_customers';

IF OBJECT_ID ('ec_datamart.clean_customers','U') IS NOT NULL
    DROP TABLE ec_datamart.clean_customers;

PRINT'>>>Creating table:ec_datamart.clean_customers';
    
    CREATE TABLE  ec_datamart.clean_customers(
    cust_id INT PRIMARY KEY,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),    
    full_name NVARCHAR(50),
    dob DATE,
    email NVARCHAR(255),
    phone_number NVARCHAR(50),
    address_line_1 NVARCHAR(255),
    city NVARCHAR(50),
    state NVARCHAR(50),
    zipcode NVARCHAR(50),
    country NVARCHAR(50),
    registration_date DATETIME,
    last_login DATETIME,
    loyalty_tier NVARCHAR(50),
    pref_language NVARCHAR(50),
    marketing_opt_in int);
PRINT'>>> Inserting data into ec_datamart.clean_customers'
    INSERT INTO ec_datamart.clean_customers
    
    SELECT CAST(cust_id AS INT) AS cust_id 
          ,ISNULL(UPPER(TRIM(first_name)),'N/A') AS first_name
          ,ISNULL(UPPER(TRIM(last_name)),'N/A')  AS last_name
          ,ISNULL(UPPER(TRIM(full_name)),'N/A') AS full_name
          ,dob 
          ,CASE
            WHEN TRIM(LOWER(email))NOT LIKE '%@%.%' THEN 'N/A' 
            ELSE TRIM(LOWER(email))
            END AS email
          ,CASE 
           WHEN phone_num IS NULL OR TRIM(phone_num) = '' THEN 'N/A'
           ELSE REPLACE(REPLACE(TRIM(phone_num), '-', ''), '+', '')
           END AS phone_number
          ,UPPER(TRIM(address_line_1))AS address_line_1 
          ,ISNULL(NULLIF(UPPER(TRIM(city)),'UNKNOWN'),'N/A') AS city
          ,ISNULL(UPPER(TRIM(state)),'N/A') AS state
          ,CAST(zipcode AS VARCHAR(50)) AS zipcode
          ,CASE 
           WHEN UPPER(TRIM(country)) IN ('US', 'USA') THEN 'USA'
           ELSE UPPER(TRIM(country))
          END AS country
          ,registration_date
          ,last_login
          ,ISNULL(UPPER(TRIM(loyalty_tier)),'N/A') AS loyalty_tier
          ,UPPER(TRIM(pref_language)) AS pref_language
          ,ISNULL(CAST(marketing_opt_in AS INT), 0) AS marketing_opt_in
           FROM ECOMDB.ec_core.raw_customers;
         SET @end_time =GETDATE();
PRINT'Load Duration:'+CAST( DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+'Seconds' 
PRINT'---------------------'
--========================================================================
--Loading clean_orders
SET @start_time =GETDATE();
PRINT'>>>Dropping table:ec_datamart.clean_orders';

IF OBJECT_ID('ECOMDB.ec_datamart.clean_orders' ,'U') IS NOT NULL
DROP TABLE ECOMDB.ec_datamart.clean_orders

PRINT'>>>Creating table:ec_datamart.clean_Orders';

CREATE TABLE ECOMDB.ec_datamart.clean_orders (
    order_id INT PRIMARY KEY,
    order_number VARCHAR(50),
    customer_id INT,
    product_id INT,
    order_date DATE,
    ship_date DATE,
    days_to_ship INT,
    quantity INT,
    unit_price DECIMAL(38,13),
    discount_code VARCHAR(50),
    discount_amount DECIMAL(38,13),
    tax_rate DECIMAL(4,2),
    total_amount DECIMAL(38,13),
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    shipping_method VARCHAR(50),
    delivery_address_override INT,
    order_notes VARCHAR(255),
    return_requested INT
);
PRINT'>>> Inserting data into ec_datamart.clean_orders'

INSERT INTO ECOMDB.ec_datamart.clean_orders
SELECT CAST(order_idx AS INT ) AS order_id
      ,TRIM(order_number) AS order_number
      ,CAST(customer_id AS INT) AS customer_id
      ,CAST(product_id  AS INT) AS product_id 
      ,order_date
      ,CASE
         WHEN (order_date)>(ship_date) THEN NULL
          ELSE (ship_date)
          END AS ship_date
      ,CASE
          WHEN ship_date<order_date THEN NULL
          ELSE DATEDIFF(DAY,order_date,ship_date )
          END date_to_ship
      ,ISNULL(CAST(quantity AS INT),0)AS quantity
   
      ,CAST(unit_price AS DECIMAL(38,13)) AS unit_price
      ,ISNULL(NULLIF(UPPER(TRIM(discount_code)), ''), 'N/A') AS discount_code
       ,CAST(discount_amount AS DECIMAL(38,13)) AS discount_amount
       ,CASE 
          WHEN tax_rate LIKE '%[%]%' THEN CAST(TRIM(REPLACE(tax_rate,'%','')) AS DECIMAL(4,2))/100
          ELSE  CAST(TRIM(tax_rate)AS DECIMAL (4,2))
          END tax_rate
      ,CAST(total_amount AS DECIMAL(38,13)) AS total_amount
      ,TRIM(UPPER(payment_method)) AS payment_method 
      ,CASE
            WHEN UPPER(TRIM(payment_status)) ='0' THEN 'FAILED'
            WHEN UPPER(TRIM(payment_status)) IN ('Failed','Pending','Refunded') THEN UPPER(TRIM(payment_status))
            ELSE 'PAID'
            END payment_status
     ,UPPER(TRIM(shipping_method)) AS shipping_method
     ,ISNULL( CAST(delivery_address_override AS INT),0) AS delivery_address_override 
     ,ISNULL(UPPER(TRIM(order_notes)),'N/A')AS order_notes
      ,ISNULL(CAST(return_requested AS INT),0) AS return_requested
      FROM  ECOMDB.ec_core.raw_orders;

SET @end_time=GETDATE();
PRINT'Load Duration:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+'Seconds' 
PRINT'---------------------'


--==========================================================================
--Loading products_inventory
SET @start_time=GETDATE()
PRINT'>>>Dropping the table'
IF OBJECT_ID('ECOMDB.ec_datamart.clean_products_inventory', 'U') IS NOT NULL 
    DROP TABLE ECOMDB.ec_datamart.clean_products_inventory
PRINT'>>>Creating table:ec_datamart.clean_products_inventory';

CREATE TABLE ec_datamart.clean_products_inventory(
    prod_id INT PRIMARY KEY,            
    sku VARCHAR(50),
    product_name VARCHAR(255),
    category_hierarchy VARCHAR(255),
    brand VARCHAR(100),
    supplier_id INT,
    cost_price DECIMAL(6,2),
    retail_price DECIMAL(30,18),
    currency VARCHAR(10),
    weight_kg DECIMAL(30,18),
    length DECIMAL(10,2),
    width DECIMAL(10,2),
    height DECIMAL(10,2),
    active INT,
    stock_count INT,
    reorder_level INT,
    warehouse_location VARCHAR(100),
    color VARCHAR(50),
    material VARCHAR(50),
    warranty_years INT)

PRINT'>>> Inserting data into ec_datamart.clean_products_inventory'

INSERT INTO ec_datamart.clean_products_inventory

SELECT CAST(prod_id AS INT)AS prod_id
      ,UPPER(TRIM(sku)) AS sku
      ,UPPER(TRIM(product_name)) AS product_name
      ,UPPER(TRIM(category_hierarchy)) AS category_hierarchy
      ,CASE 
    WHEN UPPER(TRIM(brand)) = 'UNKNOWN' THEN 'N/A'
    WHEN brand IS NULL THEN 'N/A'
    ELSE UPPER(TRIM(brand))
    END AS brand

      ,CAST(supplier_id AS INT ) AS supplier_id
      ,CAST(cost_price AS DECIMAL(6,2)) AS cost_price
      ,CAST(retail_price AS DECIMAL(30,18)) AS retail_price
      ,UPPER(TRIM(currency)) AS currency
      ,CAST(weight_kg AS DECIMAL(30,18)) AS weight_kg
      ,CAST(PARSENAME(REPLACE(dimensions_cm,'x','.'),3) AS decimal(10,2)) AS length
      ,CAST(PARSENAME(REPLACE(dimensions_cm,'x','.'),2) AS decimal(10,2)) AS width
      ,CAST(PARSENAME(REPLACE(dimensions_cm,'x','.'),1) AS decimal(10,2)) AS height

      ,CAST(is_active AS INT) AS active
      ,CASE  
      WHEN stock_count < 0 THEN NULL
      ELSE  CAST(stock_count AS INT)
      END AS stock_count
      ,CAST(reorder_level AS INT) AS reorder_level
      ,UPPER(TRIM(warehouse_location)) AS warehouse_location
      ,UPPER(JSON_VALUE(metadata_json,'$.color')) AS color
      ,UPPER(JSON_VALUE(metadata_json,'$.material')) AS material
      ,CAST(JSON_VALUE(metadata_json,'$.warranty_years') AS INT) AS warranty_years
  FROM ECOMDB.ec_core.raw_products_inventory;
  SET @end_time=GETDATE();
PRINT'Load Duration:'+  CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+'Seconds' 
PRINT'---------------------'

--=========================================================================
--Loading shipping_logs
SET @start_time=GETDATE();

PRINT'>>>Droppping the table clean_shipping_logs';
IF OBJECT_ID('ECOMDB.ec_datamart.clean_shipping_logs', 'U') IS NOT NULL
 DROP TABLE ECOMDB.ec_datamart.clean_shipping_logs;

 PRINT'>>>Creating the table clean_shipping_logs';
CREATE TABLE ECOMDB.ec_datamart.clean_shipping_logs (
    shipment_id INT PRIMARY KEY NOT NULL,
    order_ref VARCHAR(100),
    carrier VARCHAR(100),
    tracking_code VARCHAR(100),
    recipient_name VARCHAR(150),
    delivery_zone VARCHAR(50),
    dispatch_timestamp DATETIME,
    delivery_timestamp DATETIME,
   estimated_days_to_deliver INT,
    actual_days_to_deliver INT,
    delivery_performance_status VARCHAR(100),
    shipping_cost DECIMAL(30,6),
    fuel_surcharge DECIMAL(30,6),
    total_shipping_cost DECIMAL(30,6),
    package_length_in DECIMAL(30,6),
    package_width_in DECIMAL(30,6),
    package_height_in DECIMAL(30,6),
    weight_billed_kg DECIMAL(30,6),
    status_log_clean VARCHAR(255)
);
PRINT'>>> Inserting data into ec_datamart.clean_shipping_logs'      
  INSERT INTO   ECOMDB.ec_datamart.clean_shipping_logs          
SELECT 
    
    shipment_id,
    UPPER(TRIM(order_ref)) AS order_ref,
    UPPER(TRIM(carrier)) AS carrier,
    UPPER(TRIM(tracking_code)) AS tracking_code,
    COALESCE(UPPER(TRIM(recipient_name)),'N/A') AS recipient_name,
    CASE
    WHEN UPPER(TRIM(delivery_zone))= 'NA' THEN 'NORTH_AMERICA'
    WHEN UPPER(TRIM(delivery_zone))= 'EU' THEN 'EUROPEAN UNION'
    WHEN UPPER(TRIM(delivery_zone)) IS NULL THEN 'N/A'
    ELSE  UPPER(TRIM(delivery_zone))
    END AS delivery_zone,

    -- 3. TIMESTAMPS & DATE MATH
    dispatch_timestamp,
    delivery_timestamp,
   
    -- Handle missing estimates/actuals safely
    COALESCE(est_days_to_deliver, 0) AS estimated_days_to_deliver,
    COALESCE(actual_days_to_deliver, DATEDIFF(DAY, dispatch_timestamp, delivery_timestamp)) AS actual_days_to_deliver,
	CASE 
     WHEN COALESCE(actual_days_to_deliver, DATEDIFF(DAY, dispatch_timestamp, delivery_timestamp))  <est_days_to_deliver THEN 'EARLY'
     WHEN COALESCE(actual_days_to_deliver, DATEDIFF(DAY, dispatch_timestamp, delivery_timestamp))  > est_days_to_deliver THEN 'DELAYED'
     ELSE 'ON TIME'
     END AS delivery_performance_status,
    
    COALESCE(TRY_CAST(shipping_cost AS DECIMAL(30,6)), 0.00) AS shipping_cost,
    COALESCE(TRY_CAST(fuel_surcharge AS DECIMAL(30,6)), 0.00) AS fuel_surcharge,
    -- Total Cost
    (COALESCE(TRY_CAST(shipping_cost AS DECIMAL(30,6)), 0.00) + COALESCE(TRY_CAST(fuel_surcharge AS DECIMAL(30,6)), 0.00)) AS total_shipping_cost,

  
    TRY_CAST(DATEPART(HOUR, package_dimensions_in) AS DECIMAL(30,6)) AS package_length_in,
    TRY_CAST(DATEPART(MINUTE, package_dimensions_in) AS DECIMAL(30,6)) AS package_width_in,
    TRY_CAST(DATEPART(SECOND, package_dimensions_in) AS DECIMAL(30,6)) AS package_height_in,
    
  
    CASE 
        WHEN UPPER(weight_billed) LIKE '%LBS%' THEN TRY_CAST(TRIM(REPLACE(UPPER(weight_billed), 'LBS', '')) AS DECIMAL(30,6)) * 0.453592
        WHEN UPPER(weight_billed) LIKE '%LB%' THEN TRY_CAST(TRIM(REPLACE(UPPER(weight_billed), 'LB', '')) AS DECIMAL(30,6)) * 0.453592
        WHEN UPPER(weight_billed) LIKE '%KGS%' THEN TRY_CAST(TRIM(REPLACE(UPPER(weight_billed), 'KGS', '')) AS DECIMAL(30,6))
        WHEN UPPER(weight_billed) LIKE '%KG%' THEN TRY_CAST(TRIM(REPLACE(UPPER(weight_billed), 'KG', '')) AS DECIMAL(30,6))
        ELSE TRY_CAST(TRIM(weight_billed) AS DECIMAL(30,6))
    END AS weight_billed_kg,
  UPPER(TRIM(status_log)) AS status_log_clean
     FROM ECOMDB.ec_core.raw_shipping_logs;
        SET @end_time=GETDATE();
PRINT'Load Duration:'+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50))+'Seconds' 
PRINT'---------------------'

--=========================================================================
--Loading website_events
SET @start_time=GETDATE();

PRINT'>>>Droppping the table clean_website_events';
IF OBJECT_ID('ECOMDB.ec_datamart.clean_website_events', 'U') IS NOT NULL
    DROP TABLE ECOMDB.ec_datamart.clean_website_events;
PRINT'>>>Creating the table clean_website_events';

CREATE TABLE ECOMDB.ec_datamart.clean_website_events (
    event_id UNIQUEIDENTIFIER PRIMARY KEY,
    session_id UNIQUEIDENTIFIER,
    visitor_id UNIQUEIDENTIFIER,
    cust_id INT,
    event_timestamp DATETIME,
    event_type VARCHAR(50),
    new_product_id INT,
    traffic_source VARCHAR(50),
    device_type VARCHAR(50),
    os VARCHAR(50),
    browser VARCHAR(50),
    ip_address VARCHAR(50),
    geo_country VARCHAR(10),
    geo_city VARCHAR(100),
    load_time_ms INT,
    error_codes INT
);
PRINT'>>> Inserting data into ec_datamart.clean_website_events'      

INSERT INTO ECOMDB.ec_datamart.clean_website_events
SELECT
        TRY_CAST(event_id AS UNIQUEIDENTIFIER) AS event_id
      ,TRY_CAST(session_id AS UNIQUEIDENTIFIER) AS session_id
      ,TRY_CAST(visitor_id AS UNIQUEIDENTIFIER) AS visitor_id
      ,TRY_CAST(cust_id AS INT) AS cust_id 
      ,event_timestamp
      ,UPPER(TRIM(event_type)) AS event_type
      ,CASE
            WHEN page_url LIKE '%/product/%?%'
            THEN TRY_CAST(SUBSTRING(page_url, CHARINDEX('/product/', page_url) + 9, CHARINDEX('?', page_url) - (CHARINDEX('/product/', page_url) + 9)) AS INT)
            ELSE NULL
       END AS new_product_id
      ,CASE 
            WHEN referrer_url IS NULL OR UPPER(TRIM(referrer_url)) = 'DIRECT' THEN 'DIRECT'
            WHEN LOWER(TRIM(referrer_url)) = 'https://www.facebook.com' THEN 'FACEBOOK'
            WHEN LOWER(TRIM(referrer_url)) = 'https://www.google.com' THEN 'GOOGLE'
            ELSE 'N/A'
       END AS traffic_source
      ,UPPER(TRIM(device_type)) AS device_type
      ,UPPER(TRIM(os)) AS os
      ,UPPER(TRIM(browser)) AS browser
      ,TRIM(ip_address) AS ip_address
      ,ISNULL(UPPER(TRIM(geo_country)), 'N/A') AS geo_country
      ,ISNULL(UPPER(TRIM(geo_city)), 'N/A') AS geo_city
      ,TRY_CAST(load_time_ms AS INT) AS load_time_ms 
      ,ISNULL(TRY_CAST(error_codes AS INT), 0) AS error_codes
FROM ECOMDB.ec_core.raw_website_events;
  SET @end_time=GETDATE();
PRINT'Load Duration:' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR(50)) + 'Seconds' 
PRINT'---------------------'
SET @batch_end_time=GETDATE();
PRINT'=============================================='
PRINT'-Total load duration :' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(50)) + 'Seconds';
PRINT'===============================================';
END TRY
BEGIN CATCH
PRINT'==============================================';
PRINT'ERROR OCCURED DURING LOADING CLEAN LAYER';
PRINT'Error Message :' + ERROR_MESSAGE();
PRINT'Error Message :' + CAST (ERROR_NUMBER() AS NVARCHAR(50));
PRINT'Error Message :' + CAST (ERROR_STATE() AS NVARCHAR(50));
PRINT'===============================================';
END CATCH
END;
GO
