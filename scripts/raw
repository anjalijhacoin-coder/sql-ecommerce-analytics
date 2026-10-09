/*
===============================================================================
DDL Script: Create Raw Tables
===============================================================================
Script Purpose:
    This script creates core operational tables in the 'ec_core' schema, 
    dropping existing tables if they already exist to ensure clean re-deployments.
    Run this script to establish or re-define the DDL structure of the raw 
    data pipeline layer.
===============================================================================
*/

USE ECOMDB;
GO

-- 1. raw_website_events
IF OBJECT_ID('ec_core.raw_website_events', 'U') IS NOT NULL
    DROP TABLE ec_core.raw_website_events;
GO

CREATE TABLE ec_core.raw_website_events (
    event_id NVARCHAR(70),
    session_id NVARCHAR(80),
    visitor_id NVARCHAR(80),
    cust_id INT,
    event_timestamp DATETIME,
    event_type NVARCHAR(80),
    page_url NVARCHAR(MAX),
    referrer_url NVARCHAR(MAX),
    device_type NVARCHAR(80),
    os NVARCHAR(80),
    browser NVARCHAR(80),
    ip_address NVARCHAR(80),
    geo_country NVARCHAR(80),
    geo_city NVARCHAR(80),
    load_time_ms INT,
    error_codes INT
);
GO

-- 2. raw_shipping_logs
IF OBJECT_ID('ec_core.raw_shipping_logs', 'U') IS NOT NULL
    DROP TABLE ec_core.raw_shipping_logs;
GO

CREATE TABLE ec_core.raw_shipping_logs (
    shipment_id INT,
    order_ref NVARCHAR(50),
    carrier NVARCHAR(50),
    tracking_code NVARCHAR(50),
    dispatch_timestamp DATETIME,
    delivery_timestamp DATETIME,
    est_days_to_deliver INT,
    actual_days_to_deliver INT,
    shipping_cost NVARCHAR(50),
    fuel_surcharge NVARCHAR(50),
    recipient_name NVARCHAR(50),
    delivery_zone NVARCHAR(50),
    weight_billed NVARCHAR(50),
    package_dimension NVARCHAR(50),
    status_logs NVARCHAR(50)
);
GO

-- 3. raw_products_inventory
IF OBJECT_ID('ec_core.raw_products_inventory', 'U') IS NOT NULL
    DROP TABLE ec_core.raw_products_inventory;
GO

CREATE TABLE ec_core.raw_products_inventory (
    prod_id INT,
    sku NVARCHAR(50),
    product_name NVARCHAR(50),
    category_hierarchy NVARCHAR(50),
    brand NVARCHAR(50),
    supplier_id INT,
    cost_price NVARCHAR(50),
    retail_price NVARCHAR(50),
    currency NVARCHAR(50),
    weight_kg NVARCHAR(50),
    dimensions_cm NVARCHAR(50),
    is_active NVARCHAR(50),
    stock_count INT,
    reorder_level INT,
    warehouse_location NVARCHAR(50),
    metadata_json NVARCHAR(MAX)
);
GO

-- 4. raw_orders
IF OBJECT_ID('ec_core.raw_orders', 'U') IS NOT NULL
    DROP TABLE ec_core.raw_orders;
GO

CREATE TABLE ec_core.raw_orders (
    order_idx INT,
    order_number NVARCHAR(50),
    customer_id INT,
    prd_id INT,
    order_date DATETIME,
    ship_date DATETIME,
    quantity NVARCHAR(50),
    unit_price NVARCHAR(50),
    discount_code NVARCHAR(50),
    discount_amount NVARCHAR(50),
    tax_rate NVARCHAR(50),
    total_amount NVARCHAR(50),
    payment_method NVARCHAR(50),
    payment_status NVARCHAR(50),
    shipping_method NVARCHAR(50),
    delivery_address_override NVARCHAR(50),
    order_notes NVARCHAR(MAX),
    return_requested NVARCHAR(50)
);
GO

-- 5. raw_customers
IF OBJECT_ID('ec_core.raw_customers', 'U') IS NOT NULL
    DROP TABLE ec_core.raw_customers;
GO

CREATE TABLE ec_core.raw_customers (
    cust_id INT,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    email NVARCHAR(70),
    phone_number NVARCHAR(50),
    dob NVARCHAR(50),
    address_line_1 NVARCHAR(50),
    city NVARCHAR(50),
    state NVARCHAR(50),
    zipcode NVARCHAR(50),
    country NVARCHAR(50),
    registration_date DATETIME,
    last_login DATETIME,
    loyalty_tier NVARCHAR(50),
    pref_language NVARCHAR(50),
    marketing_opt_in NVARCHAR(50),
    full_name NVARCHAR(50)
);
GO
