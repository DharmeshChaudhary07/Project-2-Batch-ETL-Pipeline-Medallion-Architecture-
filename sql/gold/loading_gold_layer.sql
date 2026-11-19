---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

-- loading into gold layer (dimension table and facts table)

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

truncate gold.gold_fact_payments, gold.gold_fact_sales, gold.gold_dim_customers, gold.gold_dim_products, gold.gold_dim_sellers,
gold.gold_dim_date restart identity cascade;


-- date dimension: 2016 through 2030 
-- pre-generated calendar table, it connects to your fact table (gold_fact_sales) through a shared integer format called a date_key
-- upto 2030 (total rows would be 5500) it wont table much space even less than 1 mb. also future planningit best.

insert into gold.gold_dim_date
select to_char(d,'yyyymmdd')::int, 		-- surrogate key
	   d,
       extract(year from d), 
       extract(quarter from d), 
       extract(month from d),
       to_char(d,'month'), 
       extract(day from d),
       extract(isodow from d),
       to_char(d,'day'),
       extract(isodow from d) in (6,7)
from generate_series('2016-01-01'::date, '2030-12-31'::date, '1 day') as d;

----------------------------------------

insert into gold.gold_dim_customers (customer_id, customer_unique_id, customer_city, customer_state, customer_zip_code_prefix)

select customer_id, 
	customer_unique_id,
	city, 
	state, 
	zip_code_prefix
from silver.customers;

----------------------------------------


insert into gold.gold_dim_sellers (seller_id, seller_city, seller_state, seller_zip_code_prefix)
select seller_id, 
	city, 
	state,
	zip_code_prefix
from silver.sellers;


----------------------------------------


insert into gold.gold_dim_products (product_id, category_pt, category_en, weight_g, length_cm, height_cm, width_cm)
select product_id,
	category_name_pt,
	coalesce(category_name_en, 'unknown'),
    weight_g, 
    length_cm, 
    height_cm, 
    width_cm 
from silver.products 

----------------------------------------




insert into gold.gold_fact_sales (order_id, order_item_id, customer_key, product_key, seller_key, order_date_key, delivered_date_key,
order_status , price ,freight_value, total_item_value, delivery_days, delivery_delay_days)
  
  

select * from gold.gold_fact_sales gfs;

select oi.order_id,
	oi.order_item_id,
    c.customer_key,
    p.product_key,
    s.seller_key,
    to_char(o.order_purchase_timestamp,'yyyymmdd')::int,
    to_char(o.order_delivered_customer_date,'yyyymmdd')::int,
    o.order_status,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value,
    (o.order_delivered_customer_date::date - o.order_purchase_timestamp::date),
    (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date)
from silver_order_items oi
join silver_orders o           on oi.order_id = o.order_id
join gold_dim_customers c      on o.customer_id = c.customer_id
join gold_dim_products p       on oi.product_id = p.product_id
join gold_dim_sellers s        on oi.seller_id = s.seller_id;


----------------------------------------


insert into gold.gold_fact_payments (order_id, payment_sequential, customer_key, order_date_key, payment_type, installments, payment_value)
select 
	op.order_id ,
	op.payment_sequential ,
	gdc.customer_key ,
	to_char(o.order_purchase_ts, 'yyyymmdd'):: int ,
	op.payment_type ,
	op.payment_installments ,
	op.payment_value 
from silver.order_payments op 
join silver.orders o on o.order_id = op.order_id 
join gold.gold_dim_customers gdc on gdc.customer_id = o.customer_id ;





