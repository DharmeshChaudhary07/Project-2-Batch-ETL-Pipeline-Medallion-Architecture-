-- silver.sellers: truncate + load from bronze.
-- Run inside a transaction by olist_etl/silver.py (no begin/commit here).

-- remove/clear data from silver.orders, keeping the table format.
truncate silver.sellers;

insert into silver.sellers (seller_id, zip_code_prefix, city, state)
select
    seller_id,
    zip_code_prefix,
    case
        when city ~ '^[0-9]+$' or city like '%@%' then null
        when city = 'andira-pr' then 'andira'
        when city = 'arraial d''ajuda (porto seguro)' then 'arraial d''ajuda'
        when city = 'sbc' then 'sao bernardo do campo'
        when city = 'sp' then 'sao paulo'
        when city like 's%o paulo' then 'sao paulo'
        else city
    end,
    state
from (
    select
        nullif(trim(seller_id), '') as seller_id,
        nullif(trim(seller_zip_code_prefix), '') as zip_code_prefix,
        nullif(
            trim(
                regexp_replace(
                    replace(lower(trim(seller_city)), '´', ''''),
                    '\s*(/|\\|,| - ).*$',
                    ''
                )
            ),
            ''
        ) as city,
        upper(nullif(trim(seller_state), '')) as state
    from bronze.sellers
) t
where seller_id is not null;
