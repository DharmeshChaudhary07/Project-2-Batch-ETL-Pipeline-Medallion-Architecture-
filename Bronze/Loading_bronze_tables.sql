
-- ####################################################################################################

-- Loading the CSV data into our tables which we created.


TRUNCATE bronze_customers;

COPY bronze_customers FROM '/tmp/olist/olist_customers_dataset.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
