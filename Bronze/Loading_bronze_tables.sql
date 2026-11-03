
-- ####################################################################################################

-- Loading the CSV data into our tables which we created.



TRUNCATE bronze_customers;

COPY bronze_customers 
FROM '/Users/dharmeshchaudhary/Material/Data_Engineering/Project_1/Brazilian_olist_dataset/olist_customers_dataset.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');