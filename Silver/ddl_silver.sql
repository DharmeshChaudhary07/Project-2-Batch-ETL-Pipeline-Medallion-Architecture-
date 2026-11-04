
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
drop table if exists silver_customers;

-- create a table with actual data type
create table silver_customers (
  customer_id        VARCHAR(40) primary key,
  customer_unique_id VARCHAR(40),
  zip_code_prefix    VARCHAR(10),
  city               VARCHAR(100),
  state              CHAR(2)
);



-- Drop if already exists
drop table if exists silver_geolocation;
-- create a table with actual data type
create table silver_geolocation (
	zip_code_prefix  	varchar(10) primary key,
	latitude      		numeric(12,8),
	longitude      		numeric(12,8),
	city 				varchar(100),
	state   			char(2)
);



-- Drop if already exists
drop table if exists silver_order_items;
-- create a table with actual datatype 
create table silver_order_items(
	order_id 		varchar(40),
	order_item_id 	int,
	product_id 		varchar(40),
	seller_id   	varchar(40),
	shipping_limit_date  timestamp,
	price 			numeric(10,2),
	freight_value  	numeric(10,2),
	primary key (order_id, order_item_id)
);



-- Drop if already exists
drop table if exists silver_order_payments;
-- create a table with actual datatype
create table silver_order_payments(
	order_id 				varchar(40),
	payment_sequential 		int,
 	payment_type 			varchar(30),
  	payment_installments 	int,
  	payment_value 			numeric(10,2),
  	primary key (order_id, payment_sequential)	
);



-- Drop if already exists
drop table if exists silver_order_reviews;
-- create a table with actual datatype
create table silver_order_reviews(
  review_id 				varchar(40),
  order_id 					varchar(40),
  review_score 				int,
  review_comment_title 		text, 
  review_comment_message 	text,
  review_creation_ts 		timestamp , 
  review_answer_ts 			timestamp ,
  PRIMARY KEY (review_id, order_id));
