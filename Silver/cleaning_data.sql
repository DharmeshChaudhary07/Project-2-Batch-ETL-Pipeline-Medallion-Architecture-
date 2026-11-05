------------------------------------------------------------------------------------------------------------------------
											-- Cleaning data

/*
 The script below is cleaning the tables from bronze layer and loading it into the new silver table.
 		Keywords used below:- 
 						TRUNCATE, 
 						INSERT INTO, 
 						BEGIN;/COMMIT; (If the insert fails, Postgres rolls back everything, including the truncate, and silver keeps 
 										its old data.)
 						Basics like trim, UPPER, LOWER, nullif
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

-- remove/clear data from silver.customers, keeping the table format.
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









