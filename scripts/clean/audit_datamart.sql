/*
===============================================================================
Data Quality Audit & Validation Script: Clean Datamart Layer
===============================================================================
Script Purpose:
    This script runs automated post-load data quality checks across all tables 
    in the 'ec_datamart' schema. It verifies data integrity, unqiueness, formatting, 
    and business rule compliance after the ETL/cleaning pipeline execution.

Validation Categories Covered:
    - Uniqueness (Primary Key duplicate checks)
    - Completeness (Mandatory NULL field checks)
    - Consistency & Hygiene (Invalid whitespace, negative values, date logic)
    - Domain Validity (Distinct checks for categories, statuses, and flags)
===============================================================================
*/


/*===============================================================================
1. AUDIT: ec_datamart.clean_customers
===============================================================================
*/

-- Check for duplicate customer IDs
SELECT cust_id, COUNT(cust_id) AS duplicate_count
FROM ec_datamart.clean_customers
GROUP BY cust_id
HAVING COUNT(cust_id) > 1;

-- Check for unexpected NULL values in mandatory demographic and identifier fields
SELECT first_name, last_name, full_name, city, email, phone_number, cust_id
FROM ec_datamart.clean_customers
WHERE first_name IS NULL OR last_name IS NULL
   OR full_name IS NULL OR city IS NULL OR loyalty_tier IS NULL
   OR email IS NULL OR phone_number IS NULL OR cust_id IS NULL;

-- Check for unhandled leading/trailing whitespace in string fields
SELECT first_name, last_name, full_name, city, email, phone_number
FROM ec_datamart.clean_customers
WHERE first_name != TRIM(first_name) OR last_name != TRIM(last_name) 
   OR full_name != TRIM(full_name) OR city != TRIM(city) OR loyalty_tier != TRIM(loyalty_tier)
   OR email != TRIM(email) OR phone_number != TRIM(phone_number);

-- Validate date boundaries for date of birth (DOB)
SELECT MIN(dob) AS min_dob, MAX(dob) AS max_dob
FROM ec_datamart.clean_customers;

-- Validate binary domain values for marketing opt-in flag (must be 0 or 1)
SELECT marketing_opt_in, COUNT(*) AS record_count 
FROM ec_datamart.clean_customers
WHERE marketing_opt_in NOT IN (0, 1)
GROUP BY marketing_opt_in;

-- Profile customer distribution by country
SELECT country, COUNT(*) AS customer_count
FROM ec_datamart.clean_customers
GROUP BY country;

-- Validate email format integrity (must contain '@' and '.')
SELECT cust_id, email
FROM ec_datamart.clean_customers
WHERE email NOT LIKE '%@%.%';


/*
===============================================================================
2. AUDIT: ec_datamart.clean_orders
===============================================================================
*/

-- Check for duplicate order IDs
SELECT order_id, COUNT(order_id) AS duplicate_count
FROM ec_datamart.clean_orders
GROUP BY order_id
HAVING COUNT(order_id) > 1;

-- Check for duplicate order numbers
SELECT order_number, COUNT(order_number) AS duplicate_count
FROM ec_datamart.clean_orders
GROUP BY order_number
HAVING COUNT(order_number) > 1;

-- Check for duplicate customer references if applicable
SELECT customer_id, COUNT(customer_id) AS order_count
FROM ec_datamart.clean_orders
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;

-- Validate chronological order dates (ensure order date is not after ship date)
SELECT MAX(order_date) AS max_order_date, MIN(order_date) AS min_order_date, 
       MAX(ship_date) AS max_ship_date, MIN(ship_date) AS min_ship_date
FROM ec_datamart.clean_orders;

SELECT *
FROM ec_datamart.clean_orders
WHERE order_date > ship_date;

-- Check for mandatory NULL fields in core transactional columns
SELECT order_id, customer_id, order_date, total_amount, quantity
FROM ec_datamart.clean_orders
WHERE order_id IS NULL 
   OR customer_id IS NULL 
   OR order_date IS NULL 
   OR total_amount IS NULL 
   OR quantity IS NULL;

-- Check for unhandled whitespace in transaction properties
SELECT order_number, discount_code, payment_method, payment_status, shipping_method, order_notes
FROM ec_datamart.clean_orders
WHERE discount_code != TRIM(discount_code) OR payment_method != TRIM(payment_method)
   OR payment_status != TRIM(payment_status) OR shipping_method != TRIM(shipping_method) 
   OR order_notes != TRIM(order_notes);

-- Validate categorical domains for orders
SELECT DISTINCT payment_method FROM ec_datamart.clean_orders;
SELECT DISTINCT discount_code FROM ec_datamart.clean_orders;
SELECT DISTINCT payment_status FROM ec_datamart.clean_orders;
SELECT DISTINCT shipping_method FROM ec_datamart.clean_orders;


/*
===============================================================================
3. AUDIT: ec_datamart.clean_products_inventory
===============================================================================
*/

-- Check for duplicate product IDs
SELECT prod_id, COUNT(prod_id) AS duplicate_count
FROM ec_datamart.clean_products_inventory
GROUP BY prod_id
HAVING COUNT(prod_id) > 1;

-- Check for mandatory NULL values in inventory metrics
SELECT prod_id, sku, product_name, category_hierarchy, brand, currency, warehouse_location, color, material
FROM ec_datamart.clean_products_inventory
WHERE prod_id IS NULL 
   OR sku IS NULL 
   OR product_name IS NULL 
   OR category_hierarchy IS NULL 
   OR brand IS NULL 
   OR currency IS NULL 
   OR warehouse_location IS NULL 
   OR color IS NULL 
   OR material IS NULL;

-- Check for unhandled whitespace in product attributes
SELECT sku, product_name, category_hierarchy, brand, currency, warehouse_location, color, material
FROM ec_datamart.clean_products_inventory
WHERE sku != TRIM(sku) OR product_name != TRIM(product_name) 
   OR category_hierarchy != TRIM(category_hierarchy) OR brand != TRIM(brand) 
   OR currency != TRIM(currency) OR warehouse_location != TRIM(warehouse_location) 
   OR color != TRIM(color) OR material != TRIM(material);

-- Profile categorical product dimensions
SELECT DISTINCT brand FROM ec_datamart.clean_products_inventory;
SELECT DISTINCT warehouse_location FROM ec_datamart.clean_products_inventory;
SELECT DISTINCT color FROM ec_datamart.clean_products_inventory;
SELECT DISTINCT material FROM ec_datamart.clean_products_inventory;
SELECT DISTINCT currency FROM ec_datamart.clean_products_inventory;


/*
===============================================================================
4. AUDIT: ec_datamart.clean_shipping_logs
===============================================================================
*/

-- Check for duplicate shipment IDs
SELECT shipment_id, COUNT(shipment_id) AS duplicate_count
FROM ec_datamart.clean_shipping_logs
GROUP BY shipment_id
HAVING COUNT(shipment_id) > 1;

-- Check for mandatory NULL values in logistics logs
SELECT shipment_id, order_ref, carrier, tracking_code, recipient_name, delivery_zone
FROM ec_datamart.clean_shipping_logs
WHERE shipment_id IS NULL OR order_ref IS NULL OR carrier IS NULL 
   OR tracking_code IS NULL OR recipient_name IS NULL OR delivery_zone IS NULL;

-- Check for unhandled whitespace in shipping attributes
SELECT order_ref, carrier, tracking_code, recipient_name, delivery_zone, status_log_clean
FROM ec_datamart.clean_shipping_logs
WHERE order_ref != TRIM(order_ref) OR carrier != TRIM(carrier) 
   OR tracking_code != TRIM(tracking_code) OR recipient_name != TRIM(recipient_name) 
   OR delivery_zone != TRIM(delivery_zone) OR status_log_clean != TRIM(status_log_clean);

-- Validate shipping timeline logic (dispatch date must be <= delivery date)
SELECT *
FROM ec_datamart.clean_shipping_logs
WHERE dispatch_timestamp > delivery_timestamp;

-- Validate financial math integrity (shipping_cost + fuel_surcharge = total_shipping_cost)
SELECT shipment_id, shipping_cost, fuel_surcharge, total_shipping_cost
FROM ec_datamart.clean_shipping_logs
WHERE (shipping_cost + fuel_surcharge) != total_shipping_cost;

-- Check for invalid negative values in dimensions or costs
SELECT shipment_id, package_length_in, package_width_in, shipping_cost, total_shipping_cost
FROM ec_datamart.clean_shipping_logs
WHERE package_length_in <= 0 OR package_width_in <= 0 
   OR shipping_cost < 0 OR total_shipping_cost < 0;


/*
===============================================================================
5. AUDIT: ec_datamart.clean_website_events
===============================================================================
*/

-- Check for duplicate event IDs
SELECT event_id, COUNT(*) AS duplicate_count
FROM ec_datamart.clean_website_events
GROUP BY event_id
HAVING COUNT(*) > 1;

-- Check for mandatory NULL values in event streams
SELECT event_id, session_id, visitor_id, cust_id, event_timestamp, load_time_ms, error_codes
FROM ec_datamart.clean_website_events
WHERE event_id IS NULL OR session_id IS NULL OR visitor_id IS NULL 
   OR cust_id IS NULL OR event_timestamp IS NULL 
   OR load_time_ms IS NULL OR error_codes IS NULL;

-- Check for unhandled whitespace in event metadata
SELECT event_type, traffic_source, device_type, os, browser, ip_address, geo_country, geo_city
FROM ec_datamart.clean_website_events
WHERE event_type != TRIM(event_type) OR traffic_source != TRIM(traffic_source) 
   OR device_type != TRIM(device_type) OR os != TRIM(os) OR browser != TRIM(browser) 
   OR ip_address != TRIM(ip_address) OR geo_country != TRIM(geo_country) OR geo_city != TRIM(geo_city);

-- Profile website event categorical dimensions
SELECT DISTINCT event_type FROM ec_datamart.clean_website_events;
SELECT DISTINCT traffic_source FROM ec_datamart.clean_website_events;
SELECT DISTINCT device_type FROM ec_datamart.clean_website_events;
SELECT DISTINCT os FROM ec_datamart.clean_website_events;
SELECT DISTINCT browser FROM ec_datamart.clean_website_events;
SELECT DISTINCT geo_country FROM ec_datamart.clean_website_events;

-- Check for invalid negative load times
SELECT event_id, load_time_ms
FROM ec_datamart.clean_website_events
WHERE load_time_ms < 0;
