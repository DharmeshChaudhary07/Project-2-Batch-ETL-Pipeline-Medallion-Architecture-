-- ####################################################################################################

-- Creating the bronze table --

-- Bronze table are empty containers with same column name as CSV columns names

-- create bronze_customers


create table if not exists bronze_customers (
customer_id text, 
customer_unique_id text, 
customer_zip_code_prefix text, 
customer_city text, 
customer_state text
);


-- Create bronze_geolocation

create table if not exists bronze_geolocation (
geolocation_zip_code_prefix text,
geolocation_lat text,
geolocation_lng text,
geolocation_city text,
geolocation_state text
);


-- Create bronze_order_items

CREATE TABLE IF NOT EXISTS bronze_order_items (
order_id TEXT, 
order_item_id TEXT, 
product_id TEXT, 
seller_id TEXT,
shipping_limit_date TEXT, 
price TEXT, 
freight_value TEXT);


-- Create bronze_order_payements

CREATE TABLE IF NOT EXISTS bronze_order_payments (
order_id TEXT, 
payment_sequential TEXT, 
payment_type TEXT,
payment_installments TEXT, 
payment_value TEXT);


-- Create bronze_order_reviews

CREATE TABLE IF NOT EXISTS bronze_order_reviews (
review_id TEXT, 
order_id TEXT, 
review_score TEXT, 
review_comment_title TEXT,
review_comment_message TEXT, 
review_creation_date TEXT, 
review_answer_timestamp TEXT);


-- Create bronze_orders

CREATE TABLE IF NOT EXISTS bronze_orders (
order_id TEXT, 
customer_id TEXT, 
order_status TEXT, 
order_purchase_timestamp TEXT,
order_approved_at TEXT, 
order_delivered_carrier_date TEXT,
order_delivered_customer_date TEXT, 
order_estimated_delivery_date TEXT);


-- Create bronze_products

CREATE TABLE IF NOT EXISTS bronze_products (
product_id TEXT, 
product_category_name TEXT, 
product_name_lenght TEXT,
product_description_lenght TEXT, 
product_photos_qty TEXT, 
product_weight_g TEXT,
product_length_cm TEXT,
product_height_cm TEXT,
product_width_cm TEXT);


-- Create bronze_sellers

CREATE TABLE IF NOT EXISTS bronze_sellers (
seller_id TEXT,
seller_zip_code_prefix TEXT, 
seller_city TEXT, 
seller_state TEXT);


-- Create bronze_category_translation

CREATE TABLE IF NOT EXISTS bronze_category_translation (
product_category_name TEXT, 
product_category_name_english TEXT);




