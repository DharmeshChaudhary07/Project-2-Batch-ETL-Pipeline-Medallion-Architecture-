---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

-- creating the gold table 

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

drop table if exists gold.gold_fact_payments, gold.gold_fact_sales,
  gold.gold_dim_customers, gold.gold_dim_products, gold.gold_dim_sellers, gold.gold_dim_date cascade;


create table gold.gold_dim_date (
  date_key     int primary key,          -- yyyymmdd
  full_date    date not null unique,
  year         int, quarter int, month int,
  month_name   text, day int,
  day_of_week  int, day_name text,
  is_weekend   boolean
);


create table gold.gold_dim_customers (
  customer_key       int generated always as identity primary key,
  customer_id        text not null unique,
  customer_unique_id text not null,
  city text, 
  state text, 
  zip_code_prefix text
);


create table gold.gold_dim_sellers (
  seller_key int generated always as identity primary key,
  seller_id  text not null unique,
  city text, 
  state text, 
  zip_code_prefix text
);


create table gold.gold_dim_products (
  product_key int generated always as identity primary key,
  product_id  text not null unique,
  category_pt text, 
  category_en text,
  weight_g numeric, 
  length_cm numeric, 
  height_cm numeric, 
  width_cm numeric
);


create table gold.gold_fact_sales (
  order_id text not null,
  order_item_id int not null,
  customer_key int references gold.gold_dim_customers,
  product_key  int references gold.gold_dim_products,
  seller_key   int references gold.gold_dim_sellers,
  order_date_key     int references gold.gold_dim_date,
  delivered_date_key int references gold.gold_dim_date,
  order_status text,
  price numeric(10,2), 
  freight_value numeric(10,2), 
  total_item_value numeric(10,2),
  delivery_days int, 
  delivery_delay_days int,
  primary key (order_id, order_item_id)
);


create table gold.gold_fact_payments (
  order_id text not null,
  payment_sequential int not null,
  customer_key int references gold.gold_dim_customers,
  order_date_key int references gold.gold_dim_date,
  payment_type text, 
  installments int, 
  payment_value numeric(10,2),
  primary key (order_id, payment_sequential)
);