
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
/*
Script Purpose:

    This script creates tables in the 'silver' schema, dropping existing tables if they already exist.
    Run this script to re-define/rename the DDL structure of 'silver' Tables.
      
	Silver is the cleaned copy of bronze: real data types (dates as dates, prices as numbers), no duplicates, no empty 
	strings, and consistent text.
*/


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- Drop if already exists
drop table if exists silver.customers;

-- create a table with actual data type
create table silver.customers (
  customer_id        varchar(40) not null primary key,
  customer_unique_id varchar(40) not null,
  zip_code_prefix    varchar(10) not null,
  city               varchar(100),
  state              CHAR(2),
  dwh_load_ts		 timestamp default  current_timestamp
);



-- Drop if already exists
drop table if exists silver.geolocation;
-- create a table with actual data type
create table silver.geolocation (
	zip_code_prefix  	varchar(10) not null,
	latitude      		numeric(12,8) not null,
	longitude      		numeric(12,8) not null,
	city 				varchar(100),
	state   			char(2),
	dwh_load_ts        timestamp default  current_timestamp
);



-- Drop if already exists
drop table if exists silver.order_items;
-- create a table with actual datatype 
create table silver.order_items(
	order_id 		varchar(40) not null,
	order_item_id 	int not null,
	product_id 		varchar(40) not null,
	seller_id   	varchar(40) not null,
	shipping_limit_date  timestamp not null,
	price 			numeric(10,2) not null,
	freight_value  	numeric(10,2) not null,
	dwh_load_ts        timestamp default  current_timestamp,
	primary key (order_id, order_item_id)
);



-- Drop if already exists
drop table if exists silver.order_payments;
-- create a table with actual datatype
create table silver.order_payments(
	order_id 				varchar(40) not null,
	payment_sequential 		int not null,
 	payment_type 			varchar(30) not null,
  	payment_installments 	int,
  	payment_value 			numeric(10,2) not null,
  	dwh_load_ts        timestamp default  current_timestamp,
  	primary key (order_id, payment_sequential)	
);



-- Drop if already exists
drop table if exists silver.order_reviews;
-- create a table with actual datatype
create table silver.order_reviews(
  review_id 				varchar(40) not null,
  order_id 					varchar(40) not null,
  review_score 				int not null, 
  review_comment_title 		text, 
  review_comment_message 	text,
  review_creation_date 		timestamp , 
  review_answer_date		timestamp ,
  dwh_load_ts        timestamp default  current_timestamp,
  primary key (review_id, order_id)
);



-- Drop if already exists
drop table if exists silver.orders;
-- create a table with actual datatype
create table silver.orders(
	order_id varchar(40) PRIMARY KEY,
  	customer_id varchar(40) NOT NULL,
  	order_status varchar(20),
  	order_purchase_ts timestamp,
  	order_approved_ts timestamp ,
 	order_delivered_carrier_ts timestamp ,
  	order_delivered_customer_ts timestamp ,
  	order_estimated_delivery_ts timestamp,
  	dwh_load_ts        timestamp default  current_timestamp
);



-- Drop if already exists
drop table if exists silver.products;
-- create a table with actual datatype
create table silver.products(
	product_id varchar(40) PRIMARY KEY,
  	category_name_pt varchar(100),
 	category_name_en varchar(100),			--extra column
 	name_length int,
 	description_length int, 
 	photos_qty int,
 	weight_g int, 
	length_cm int, 
	height_cm int,
	width_cm int,
	dwh_load_ts        timestamp default  current_timestamp
);



-- Drop if already exists
drop table if exists silver.sellers;
-- create a table with actual datatype
create table silver.sellers(
  	seller_id varchar(40) primary key ,
 	zip_code_prefix varchar(10),
  	city varchar(100), 
	state char(2),
	dwh_load_ts        timestamp default  current_timestamp
);


/*
don’t need a category translation table: it’s only a 71-row lookup (Portuguese name → English name).
The only job it has is to give each product an English category, and your silver.products table already has that column 
(category_name_en, your “extra column”). The cleaning script gets the value with a LEFT JOIN straight from bronze_category_translation.
*/

