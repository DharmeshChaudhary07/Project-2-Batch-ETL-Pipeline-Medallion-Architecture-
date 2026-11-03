---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

-- Loading the CSV data into our tables which we Loadingd.

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


-- Loading bronze_customers
truncate bronze_customers;

copy bronze_customers 
from '/tmp/olist/olist_customers_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze_geolocation
truncate bronze_geolocation;

copy bronze_geolocation
from '/tmp/olist/olist_geolocation_dataset.csv'
with (format csv, header true, encoding 'UTF8');



-- Loading bronze_order_items
truncate bronze_order_items;

copy bronze_order_items 
from '/tmp/olist/olist_order_items_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze_order_payements
truncate bronze_order_payments;

copy bronze_order_payments 
from '/tmp/olist/olist_order_payments_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze_order_reviews
truncate bronze_order_reviews;

copy bronze_order_reviews 
from '/tmp/olist/olist_order_reviews_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze_orders
truncate bronze_orders;

copy bronze_orders 
from '/tmp/olist/olist_orders_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze_products
truncate bronze_products;

copy bronze_products from '/tmp/olist/olist_products_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze_sellers
truncate bronze_sellers;

copy bronze_sellers 
from '/tmp/olist/olist_sellers_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze_category_translation

truncate bronze_category_translation;
copy bronze_category_translation 
from '/tmp/olist/product_category_name_translation.csv'
with (FORMAT csv, header true, encoding  'UTF8');










