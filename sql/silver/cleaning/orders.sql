-- silver.orders: truncate + load from bronze.
-- Run inside a transaction by olist_etl/silver.py (no begin/commit here).

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
