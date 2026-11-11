---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

-- Creating the bronze table 

-- Bronze table are empty containers with same column name as CSV columns names.

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

-- create bronze.customers


create table if not exists bronze.customers (
customer_id text, 
customer_unique_id text, 
customer_zip_code_prefix text, 
customer_city text, 
customer_state text
);


-- Create bronze.geolocation

create table if not exists bronze.geolocation (
geolocation_zip_code_prefix text,
geolocation_lat text,
geolocation_lng text,
geolocation_city text,
geolocation_state text
);


-- Create bronze.order_items

CREATE TABLE IF NOT EXISTS bronze.order_items (
order_id TEXT, 
order_item_id TEXT, 
product_id TEXT, 
seller_id TEXT,
shipping_limit_date TEXT, 
price TEXT, 
freight_value TEXT);


-- Create bronze.order_payements

CREATE TABLE IF NOT EXISTS bronze.order_payments (
order_id TEXT, 
payment_sequential TEXT, 
payment_type TEXT,
payment_installments TEXT, 
payment_value TEXT);


-- Create bronze.order_reviews

CREATE TABLE IF NOT EXISTS bronze.order_reviews (
review_id TEXT, 
order_id TEXT, 
review_score TEXT, 
review_comment_title TEXT,
review_comment_message TEXT, 
review_creation_date TEXT, 
review_answer_timestamp TEXT);


-- Create bronze.orders

CREATE TABLE IF NOT EXISTS bronze.orders (
order_id TEXT, 
customer_id TEXT, 
order_status TEXT, 
order_purchase_timestamp TEXT,
order_approved_at TEXT, 
order_delivered_carrier_date TEXT,
order_delivered_customer_date TEXT, 
order_estimated_delivery_date TEXT);


-- Create bronze.products

CREATE TABLE IF NOT EXISTS bronze.products (
product_id TEXT, 
product_category_name TEXT, 
product_name_lenght TEXT,
product_description_lenght TEXT, 
product_photos_qty TEXT, 
product_weight_g TEXT,
product_length_cm TEXT,
product_height_cm TEXT,
product_width_cm TEXT);


-- Create bronze.sellers

CREATE TABLE IF NOT EXISTS bronze.sellers (
seller_id TEXT,
seller_zip_code_prefix TEXT, 
seller_city TEXT, 
seller_state TEXT);


-- Create bronze.category_translation

CREATE TABLE IF NOT EXISTS bronze.category_translation (
product_category_name TEXT, 
product_category_name_english TEXT);




