-- silver.order_reviews: truncate + load from bronze.
-- Run inside a transaction by olist_etl/silver.py (no begin/commit here).

-- remove/clear data from silver.order_reviews, keeping the table format.
truncate silver.order_reviews;

insert into silver.order_reviews
    (review_id, order_id, review_score, review_comment_title,
     review_comment_message, review_creation_date, review_answer_date)
select
    nullif(trim(review_id), ''),
    nullif(trim(order_id), ''),
    nullif(trim(review_score), '')::smallint,
    nullif(trim(regexp_replace(review_comment_title, '\s+', ' ', 'g')), ''),
    nullif(trim(regexp_replace(review_comment_message, '\s+', ' ', 'g')), ''),
    nullif(trim(review_creation_date), '')::timestamp,
    nullif(trim(review_answer_timestamp), '')::timestamp
from bronze.order_reviews
where nullif(trim(review_id), '') is not null
  and nullif(trim(order_id), '') is not null
  and nullif(trim(review_score), '')::smallint between 1 and 5;
