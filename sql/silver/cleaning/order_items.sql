-- silver.order_items: truncate + load from bronze.
-- Run inside a transaction by olist_etl/silver.py (no begin/commit here).

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
  and nullif(trim(order_item_id), '') is not null;
