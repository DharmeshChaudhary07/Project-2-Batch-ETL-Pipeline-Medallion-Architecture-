-- silver.geolocation: truncate + load from bronze.
-- Run inside a transaction by olist_etl/silver.py (no begin/commit here).

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
