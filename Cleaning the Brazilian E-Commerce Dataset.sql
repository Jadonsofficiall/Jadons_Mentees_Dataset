## Cleaning the Brazilian E-Commerce Dataset

-- 1. Schema integration & merging
CREATE TABLE olist_cleaned_orders AS
SELECT
	o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    oi.product_id,
    oi.freight_value,
    p.product_category_name,
    t.product_category_name_english,
    c.customer_city,
    c.customer_state
FROM olist_orders_dataset AS o
JOIN olist_order_items_dataset AS oi
ON o.order_id = oi.order_id
JOIN olist_products_dataset AS p
ON oi.product_id = p.product_id
JOIN olist_customers_dataset AS c
ON o.customer_id = c.customer_id
LEFT JOIN product_category_name_translation AS t
ON p.product_category_name = t.product_category_name
;

SELECT *
FROM olist_cleaned_orders;

-- 2. Standardizing the Timestamps
-- Convert string timestamps to proper DATETIME format
UPDATE olist_cleaned_orders
SET
	order_purchase_timestamp = STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'),
    order_delivered_customer_date = STR_TO_DATE(order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'),
    order_estimated_delivery_date = STR_TO_DATE(order_estimated_delivery_date, '%Y-%m-%d %H:%i:%s')
WHERE order_id IS NOT NULL;

-- Modify the column types permanently
ALTER TABLE olist_cleaned_orders
MODIFY COLUMN order_purchase_timestamp DATETIME,
MODIFY COLUMN order_delivered_customer_date DATETIME,
MODIFY COLUMN order_estimated_delivery_date DATETIME;

-- 3.Handling missing values & nulls
-- Filling missing English category names with the Portugese name or 'Unknown'
UPDATE olist_cleaned_orders
SET product_category_name_english = COALESCE(product_category_name_english, product_category_name, 'unknown')
WHERE product_category_name_english IS NULL;

-- Flagging cancelled orders with missing delivery dates (This prevents them from skewing delivery time average)
DELETE FROM olist_cleaned_orders
WHERE order_status = 'canceled' AND order_delivered_customer_date IS NULL;

-- 4. Text standardization (CIty & State)
-- Convert city names to lowercase and trim whitespace
UPDATE olist_cleaned_orders
SET customer_city = LOWER(TRIM(customer_city));

-- Simple accent removal for common Brazilian city characters
UPDATE olist_geolocation_dataset
SET geolocation_city = REPLACE(REPLACE(geolocation_city,'Ã', 'a'), '£', 'e')
WHERE geolocation_city IS NOT NULL;


UPDATE olist_geolocation_dataset
SET geolocation_city = REPLACE(REPLACE(geolocation_city,'Ã', 'a'), '£', 'e')
WHERE geolocation_city IS LIKE 'saeo paulo';


-- Remove logical errors: Delivery date cannot be before Purchase date
DELETE FROM olist_orders_dataset
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- 6. Creating some metrics
-- Add a column for Delivery Lead Time (in days)
ALTER TABLE olist_cleaned_orders 
ADD COLUMN delivery_days INT;

UPDATE olist_cleaned_orders
SET delivery_days = DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)
WHERE order_delivered_customer_date IS NOT NULL;

## THE DATASET IS NOW READY FOR ANALYSIS
-- Congratulations!!!