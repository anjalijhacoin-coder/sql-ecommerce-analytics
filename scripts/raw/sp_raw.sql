USE ECOMDB;
GO

CREATE OR ALTER PROCEDURE ec_core.raw 
AS
BEGIN 
    DECLARE @start_time DATETIME,  
            @end_time DATETIME,  
            @batch_start_time DATETIME,  
            @batch_end_time DATETIME,
            @msg NVARCHAR(500);

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        -- 1. raw_website_events
        PRINT '=========================================================';
        PRINT '>>>> DROPPING TABLE ec_core.raw_website_events';
        PRINT '=========================================================';
        
        IF OBJECT_ID('ec_core.raw_website_events', 'U') IS NOT NULL
            DROP TABLE ec_core.raw_website_events;
        
        PRINT '---------------------------------------------------------';
        PRINT '>>>> CREATING TABLE ec_core.raw_website_events';
        PRINT '---------------------------------------------------------';
       
        SET @start_time = GETDATE();
        
        CREATE TABLE ec_core.raw_website_events(
            event_id nvarchar(70),
            session_id nvarchar(80),
            visitor_id nvarchar(80),
            cust_id int,
            event_timestamp DATETIME,
            event_type nvarchar(80),
            page_url nvarchar(MAX),
            referrer_url nvarchar(MAX),
            device_type nvarchar(80),
            os nvarchar(80),
            browser nvarchar(80),
            ip_address nvarchar(80),
            geo_country nvarchar(80),
            geo_city nvarchar(80),
            load_time_ms int,
            error_codes int
        );

        SET @end_time = GETDATE();
        SET @msg = '>>>> raw_website_events created in ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' second(s).';
        PRINT @msg;

        -- 2. raw_shipping_logs
        PRINT '=========================================================';
        PRINT '>>>> DROPPING TABLE ec_core.raw_shipping_logs';
        PRINT '=========================================================';
        IF OBJECT_ID('ec_core.raw_shipping_logs', 'U') IS NOT NULL
            DROP TABLE ec_core.raw_shipping_logs;
        
        PRINT '---------------------------------------------------------';
        PRINT '>>>> CREATING TABLE ec_core.raw_shipping_logs';
        PRINT '---------------------------------------------------------';
        
        SET @start_time = GETDATE();

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

        SET @end_time = GETDATE();
        SET @msg = '>>>> raw_shipping_logs created in ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' second(s).';
        PRINT @msg;

        -- 3. raw_products_inventory
        PRINT '=========================================================';
        PRINT '>>>> DROPPING TABLE ec_core.raw_products_inventory';
        PRINT '=========================================================';
        IF OBJECT_ID('ec_core.raw_products_inventory', 'U') IS NOT NULL
            DROP TABLE ec_core.raw_products_inventory;
        
        PRINT '---------------------------------------------------------';
        PRINT '>>>> CREATING TABLE ec_core.raw_products_inventory';
        PRINT '---------------------------------------------------------';
        
        SET @start_time = GETDATE();

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

        SET @end_time = GETDATE();
        SET @msg = '>>>> raw_products_inventory created in ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' second(s).';
        PRINT @msg;

        -- 4. raw_orders
        PRINT '=========================================================';
        PRINT '>>>> DROPPING TABLE ec_core.raw_orders';
        PRINT '=========================================================';
        IF OBJECT_ID('ec_core.raw_orders', 'U') IS NOT NULL
            DROP TABLE ec_core.raw_orders;
        
        PRINT '---------------------------------------------------------';
        PRINT '>>>> CREATING TABLE ec_core.raw_orders';
        PRINT '---------------------------------------------------------';
        
        SET @start_time = GETDATE();

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

        SET @end_time = GETDATE();
        SET @msg = '>>>> raw_orders created in ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' second(s).';
        PRINT @msg;
      
        -- 5. raw_customers
        PRINT '=========================================================';
        PRINT '>>>> DROPPING TABLE ec_core.raw_customers';
        PRINT '=========================================================';
        IF OBJECT_ID('ec_core.raw_customers', 'U') IS NOT NULL
            DROP TABLE ec_core.raw_customers;
        
        PRINT '---------------------------------------------------------';
        PRINT '>>>> CREATING TABLE ec_core.raw_customers';
        PRINT '---------------------------------------------------------';
        
        SET @start_time = GETDATE();

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

        SET @end_time = GETDATE();
        SET @msg = '>>>> raw_customers created in ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR(50)) + ' second(s).';
        PRINT @msg;

        SET @batch_end_time = GETDATE();
        PRINT '=========================================================';
        PRINT '>>>> ALL RAW TABLES SUCCESSFULLY CREATED IN ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR(50)) + ' SECOND(S).';
        PRINT '=========================================================';

    END TRY
    BEGIN CATCH
        PRINT '>>>> Error occurred during raw table setup process.';
        PRINT ERROR_MESSAGE();
        PRINT ERROR_LINE();
    END CATCH
END;
GO
