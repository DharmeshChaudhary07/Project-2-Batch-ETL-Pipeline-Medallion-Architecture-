------------------------------------------------------------------------------------------------------------------------
											-- Cleaning data
------------------------------------------------------------------------------------------------------------------------


-- remove/clear data from silver.customers, keeping the table format.
truncate silver.customers;

insert into silver.customers (customer_id, customer_unique_id, zip_code_prefix, city, state)

select 
	trim(customer_id),
	trim(customer_unique_id),
	trim(customer_zip_code_prefix),
	lower(trim(customer_city)),
	upper(trim(customer_state))
from bronze.customers
where customer_id is not null 
		and TRIM(customer_id) != '';

