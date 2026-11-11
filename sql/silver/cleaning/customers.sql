-- silver.customers: truncate + load from bronze.
-- Run inside a transaction by olist_etl/silver.py (no begin/commit here).

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
