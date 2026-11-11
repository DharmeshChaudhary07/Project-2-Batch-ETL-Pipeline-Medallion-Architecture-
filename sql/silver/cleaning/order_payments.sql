-- silver.order_payments: truncate + load from bronze.
-- Run inside a transaction by olist_etl/silver.py (no begin/commit here).

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
