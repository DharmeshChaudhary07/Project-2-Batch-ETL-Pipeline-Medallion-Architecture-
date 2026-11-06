
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
												-- Rough work
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

select * from bronze.customers bc limit 40;

select * from bronze.geolocation bg limit 50;

select * from bronze.order_items boi limit 50;

select * from bronze.order_payments bop limit 50;

select * from bronze.order_reviews bor limit 49;

select * from bronze.orders bo limit 50;

select * from bronze.products bp limit 40;

select * from bronze.sellers bs limit 50;

select * from bronze.category_translation bct ;



SELECT 'customers' AS tbl, COUNT(*) FROM bronze.customers
UNION ALL SELECT 'geolocation', COUNT(*) FROM bronze.geolocation
UNION ALL SELECT 'order_items', COUNT(*) FROM bronze.order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM bronze.order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM bronze.order_reviews
UNION ALL SELECT 'orders', COUNT(*) FROM bronze.orders
UNION ALL SELECT 'products', COUNT(*) FROM bronze.products
UNION ALL SELECT 'sellers', COUNT(*) FROM bronze.sellers
UNION ALL SELECT 'category_translation', COUNT(*) FROM bronze.category_translation;


------------------------------------------------------------------------------------------------------------------------


-- ================= Silver layer ======================

select * from bronze.customers c limit 100;

-- as customer_id is primary key should be unique

select 
	customer_id,
	count(*) as Duplicates
from bronze.customers 
group by customer_id 
having count(*) > 1;

SELECT COUNT(*) 
FROM bronze.customers 
WHERE TRIM(customer_id) = '';


-- check for null values in customer_id.
select * from bronze.customers c where c.customer_id  is null ;

-- trim and lowercase/uppercase as needed

-- check for no of rows in both silver and bronze.
select count(*) as bronze from bronze.customers c ;
select count(*) as silver from silver.customers v;

select * from silver.customers c limit 100;

-----------------------------------------------

------ geolocations

select * from bronze.geolocation g limit 400

select distinct g.geolocation_city from bronze.geolocation g 

SELECT
  COUNT(*) AS total_rows,
  (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM bronze.geolocation) d) AS distinct_rows
FROM bronze.geolocation;


select * from bronze.geolocation g where length(g.geolocation_zip_code_prefix) = 5 limit 100  


SELECT COUNT(*) FROM silver.geolocation
WHERE latitude NOT BETWEEN -34 AND 6
   OR longitude NOT BETWEEN -74 AND -34;


select count(*) from bronze.geolocation g ;
select count(*) from silver.geolocation g ;

-----------------------------------------------

------ order_items

select * from bronze.order_items boi limit 50;

select order_id from bronze.order_items oi where oi.order_id is not null limit 100;
select order_item_id  from bronze.order_items oi where oi.order_id is null limit 100

select * from bronze.order_items oi  where price::numeric <= 0;

select * from bronze.order_items oi where oi.freight_value::numeric <= 0;


select count(*) from bronze.order_items oi ;
select count(*) from silver.order_items oi ;


-----------------------------------------------

------ order_payements

select * from bronze.order_payments op limit 100;

select distinct payment_type from bronze.order_payments op ;
select * from bronze.order_payments op where op.payment_type = 'not_defined';
select * from bronze.order_payments op where op.payment_value is null;
select * from bronze.order_payments op where op.payment_sequential is null or op.payment_sequential = '0';


select count(*) from bronze.order_payments op ;
select count(*) from silver.order_payments op ;

-- checks silver.order_payments

-- installments should be at least 1
SELECT COUNT(*) FROM silver.order_payments WHERE payment_installments < 1;

-- zero or negative payment values
SELECT COUNT(*) FROM silver.order_payments WHERE payment_value <= 0;

-- payment types that exist
SELECT payment_type, COUNT(*) FROM silver.order_payments GROUP BY 1;


