
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


-----------------------------------------------

------ order_reviews

select * from bronze.order_reviews t limit 300;

-- reviews answered before they were created
SELECT COUNT(*) FROM silver.order_reviews
WHERE review_answer_date < review_creation_date;

SELECT review_score, COUNT(*) FROM silver.order_reviews GROUP BY 1 ORDER BY 1;

SELECT COUNT(*) FROM bronze.order_reviews
WHERE review_score NOT IN ('1','2','3','4','5') OR review_score IS NULL;


select count(*) from bronze.order_reviews t ;
select count(*) from silver.order_reviews t ;



-----------------------------------------------

------ orders



  select count(*) from bronze.orders ;
  select count(*) from silver.orders ;
  
-- status values that exist
  
select order_status, count(*) from silver.orders group by order_status  order by count(*) desc;



-- delivered before purchased (impossible)
select count(*) from silver.orders
where order_delivered_customer_ts < order_purchase_ts;


-- delivered orders with no delivery date

select count(*) from silver.orders
where order_status = 'delivered' and order_delivered_customer_ts is null;

-- orphan customers, run after silver.customers is loaded
select count(*) from silver.orders o
left join silver.customers c on o.customer_id = c.customer_id
where c.customer_id is null;


-----------------------------------------------

------ products

select * from bronze.products p limit 100;

select * from bronze.products p where p.product_height_cm like '%' limit 110; 

select * from bronze.products where product_category_name is null ;

select count(*) from silver.products where category_name_en = 'unknown';

select * from silver.products   -- only weight is 0 
where weight_g <= 0 or length_cm <= 0 or height_cm <= 0 or width_cm <= 0;

select count(*) from bronze.products p;
select count(*) from silver.products p;


select distinct category_name_pt
from silver.products
where category_name_pt = category_name_en;

select category_name_pt, category_name_en, count(*)
from silver.products
where category_name_pt in ('pc_gamer', 'portateis_cozinha_e_preparadores_de_alimentos')
group by category_name_pt , category_name_en ;

-----------------------------------------------

------ seller










