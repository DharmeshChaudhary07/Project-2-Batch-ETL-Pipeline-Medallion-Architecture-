------------------------------------------------------------------------------------------------------------------------
											-- Cleaning data

/*
 The script below is cleaning the tables from bronze layer and loading it into the new silver table.
 		Keywords used below:- 
 						TRUNCATE, 
 						INSERT INTO, 
 						BEGIN;/COMMIT; (If the insert fails, Postgres rolls back everything, including the truncate, and silver keeps 
 										its old data.)
 						Basics syntax used :  trim, UPPER, LOWER, NULLIF, REGEX_REPLACE
 */
------------------------------------------------------------------------------------------------------------------------


--Cleaning the table customers from bronze layer and loading it into silver table.
begin;

-- remove/clear data from silver.customers, keeping the table format.
truncate silver.customers;

insert into silver.customers (customer_id, customer_unique_id, zip_code_prefix, city, state)

select 
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,     --length fix to 5 and add 0 if need in front.
    customer_city,
    customer_state
from(
    select 
        nullif(trim(customer_id), '')                      AS customer_id,
        nullif(trim(customer_unique_id), '')               AS customer_unique_id,
        nullif(trim(customer_zip_code_prefix), '')         AS customer_zip_code_prefix,
        lower(nullif(trim(customer_city), ''))             AS customer_city,
        upper(nullif(trim(customer_state), ''))            AS customer_state,
        row_number() over (
            partition by nullif(trim(customer_id), '')
            order by customer_id
        ) as rn
    from bronze.customers
) t
where rn = 1
  and customer_id is not null 
  and customer_unique_id is not null;

commit;

--------------------------------------------------------------------------------------------

----Cleaning the table geolocation from bronze layer and loading it into silver table.

begin;

-- remove/clear data from silver.geolocation, keeping the table format.
truncate silver.geolocation;

insert into silver.geolocation (zip_code_prefix, latitude, longitude, city, state)

select distinct 
	nullif(trim(geolocation_zip_code_prefix),''),
	round(nullif(trim(geolocation_lat),'')::numeric,8),
	round(nullif(trim(geolocation_lng),'')::numeric,8),
	nullif(lower(trim(geolocation_city)),''),
	nullif(upper(trim(geolocation_state)),'')
from bronze.geolocation
where nullif(trim(geolocation_zip_code_prefix),'') is not null 
			and nullif(trim(geolocation_lat),'') is not null 
			and nullif(trim(geolocation_lng),'') is not null;

commit;

--------------------------------------------------------------------------------------------

----Cleaning the table order_items from bronze layer and loading it into silver table.

begin;

-- remove/clear data from silver.order_items, keeping the table format.
truncate silver.order_items;

insert into silver.order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value) 

select 
	nullif(trim(order_id),''),
	nullif(trim(order_item_id),'')::int,
	nullif(trim(product_id ),''),
	nullif(trim(seller_id ),''),
	nullif(trim(shipping_limit_date ),'')::timestamp,
	nullif(trim(price),'')::numeric(10,2),
	nullif(trim(freight_value),'')::numeric(10,2)
from bronze.order_items 
where nullif(trim(order_id), '') is not null
  and nullif(trim(order_item_id), '') is not null

commit;


--------------------------------------------------------------------------------------------

----Cleaning the table order_payments from bronze layer and loading it into silver table.

begin;

-- remove/clear data from silver.order_payments, keeping the table format.
truncate silver.order_payments;

insert into silver.order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)

select 
	nullif(trim(order_id),''),
	nullif(trim(payment_sequential),'')::int,
	lower(nullif(trim(payment_type),'')),
	nullif(trim(payment_installments),'')::int,
	round(nullif(trim(payment_value),'')::numeric ,2)
from bronze.order_payments 
where nullif(trim(order_id), '') is not null
			and nullif(trim(payment_sequential),'') is not null
			and lower(nullif(trim(payment_type),'')) != 'not_defined'
			and nullif(trim(payment_installments), '')::int >= 1
  			and nullif(trim(payment_value), '')::numeric > 0;

commit;


--------------------------------------------------------------------------------------------

----Cleaning the table order_reviews from bronze layer and loading it into silver table.

begin;

-- remove/clear data from silver.order_reviews, keeping the table format.
truncate silver.order_reviews;

insert into silver.order_reviews
    (review_id, order_id, review_score, review_comment_title,
     review_comment_message, review_creation_date, review_answer_date)
select
    nullif(trim(review_id), ''),
    nullif(trim(order_id), ''),
    nullif(trim(review_score), '')::smallint,
    nullif(trim(regexp_replace(review_comment_title, '\s+', ' ', 'g')), ''),
    nullif(trim(regexp_replace(review_comment_message, '\s+', ' ', 'g')), ''),
    nullif(trim(review_creation_date), '')::timestamp,
    nullif(trim(review_answer_timestamp), '')::timestamp
from bronze.order_reviews
where nullif(trim(review_id), '') is not null
  and nullif(trim(order_id), '') is not null
  and nullif(trim(review_score), '')::smallint between 1 and 5;

commit;


--------------------------------------------------------------------------------------------

----Cleaning the table orders from bronze layer and loading it into silver table.

begin;

-- remove/clear data from silver.orders, keeping the table format.
truncate silver.orders;

insert into silver.orders (
    order_id, customer_id, order_status, order_purchase_ts,
    order_approved_ts, order_delivered_carrier_ts,
    order_delivered_customer_ts, order_estimated_delivery_ts)
    
select
    nullif(trim(order_id), ''),
    nullif(trim(customer_id), ''),
    lower(nullif(trim(order_status), '')),
    nullif(trim(order_purchase_timestamp), '')::timestamp,
    nullif(trim(order_approved_at), '')::timestamp,
    nullif(trim(order_delivered_carrier_date), '')::timestamp,
    nullif(trim(order_delivered_customer_date), '')::timestamp,
    nullif(trim(order_estimated_delivery_date), '')::timestamp
from bronze.orders
where nullif(trim(order_id), '') is not null
  and nullif(trim(customer_id), '') is not null
  and nullif(trim(order_status), '') is not null;

commit;


--------------------------------------------------------------------------------------------

----Cleaning the table products from bronze layer and loading it into silver table.

begin;

-- remove/clear data from silver.orders, keeping the table format.
truncate silver.products;

insert into silver.products (
	product_id, category_name_pt, category_name_en, name_length,
 	description_length, photos_qty, weight_g, length_cm, height_cm, width_cm)
 	
select
    nullif(trim(product_id), ''),
    lower(nullif(trim(p.product_category_name), '')),
    coalesce(
        lower(nullif(trim(t.product_category_name_english), '')),
        lower(nullif(trim(p.product_category_name), '')),
        'unknown'
    ),
    nullif(trim(product_name_lenght), '')::numeric::int,
    nullif(trim(product_description_lenght), '')::numeric::int,
    nullif(trim(product_photos_qty), '')::numeric::int,
    nullif(trim(product_weight_g), '')::numeric::int,
    nullif(trim(product_length_cm), '')::numeric::int,
    nullif(trim(product_height_cm), '')::numeric::int,
    nullif(trim(product_width_cm), '')::numeric::int
from bronze.products p
left join bronze.category_translation t
on lower(trim(p.product_category_name)) = lower(trim(t.product_category_name))
where nullif(trim(p.product_id), '') is not null;

commit;

-- used ::numeric::int kust to be sure that column doesnot have decimal places. is the text like 40.0 cannot convert directly to int

rollback ;



