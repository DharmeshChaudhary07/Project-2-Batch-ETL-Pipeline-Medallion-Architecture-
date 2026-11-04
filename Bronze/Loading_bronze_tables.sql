---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

-- Loading the CSV data into our tables which we Loadingd.

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


-- Loading bronze.customers
truncate bronze.customers;

copy bronze.customers 
from '/tmp/olist/olist_customers_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze.geolocation
truncate bronze.geolocation;

copy bronze.geolocation
from '/tmp/olist/olist_geolocation_dataset.csv'
with (format csv, header true, encoding 'UTF8');



-- Loading bronze.order_items
truncate bronze.order_items;

copy bronze.order_items 
from '/tmp/olist/olist_order_items_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze.order_payements
truncate bronze.order_payments;

copy bronze.order_payments 
from '/tmp/olist/olist_order_payments_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze.order_reviews
truncate bronze.order_reviews;

copy bronze.order_reviews 
from '/tmp/olist/olist_order_reviews_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze.orders
truncate bronze.orders;

copy bronze.orders 
from '/tmp/olist/olist_orders_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze.products
truncate bronze.products;

copy bronze.products from '/tmp/olist/olist_products_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze.sellers
truncate bronze.sellers;

copy bronze.sellers 
from '/tmp/olist/olist_sellers_dataset.csv'
with (FORMAT csv, header true, encoding 'UTF8');



-- Loading bronze.category_translation

truncate bronze.category_translation;
copy bronze.category_translation 
from '/tmp/olist/product_category_name_translation.csv'
with (FORMAT csv, header true, encoding  'UTF8');










