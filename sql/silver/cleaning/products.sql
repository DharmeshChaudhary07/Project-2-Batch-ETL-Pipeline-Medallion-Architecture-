-- silver.products: truncate + load from bronze.
-- Run inside a transaction by olist_etl/silver.py (no begin/commit here).

-- remove/clear data from silver.orders, keeping the table format.
truncate silver.products;

insert into silver.products (
	product_id, category_name_pt, category_name_en, name_length,
 	description_length, photos_qty, weight_g, length_cm, height_cm, width_cm)
 	
select
    nullif(trim(product_id), ''),
    lower(nullif(trim(p.product_category_name), '')),
    case
        when lower(trim(p.product_category_name)) = 'pc_gamer'
            then 'pc_gamer'
        when lower(trim(p.product_category_name)) = 'portateis_cozinha_e_preparadores_de_alimentos'
            then 'portable_kitchen_and_food_preparers'
        else coalesce(
            lower(nullif(trim(t.product_category_name_english), '')),
            lower(nullif(trim(p.product_category_name), '')),
            'unknown'
        )
    end,
    nullif(trim(product_name_lenght), '')::numeric::int,
    nullif(trim(product_description_lenght), '')::numeric::int,
    nullif(trim(product_photos_qty), '')::numeric::int,
    nullif(trim(product_weight_g), '')::numeric::int,
    nullif(trim(product_length_cm), '')::numeric::int,
    nullif(trim(product_height_cm), '')::numeric::int,
    nullif(trim(product_width_cm), '')::numeric::int
from bronze.products p
left join bronze.category_translation t
on lower(trim(p.product_category_name)) = lower(trim(t.product_category_name))
where nullif(trim(p.product_id), '') is not null;
