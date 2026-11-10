# Audit: Bronze to Silver

Project: Batch ETL Pipeline (Medallion Architecture)
Dataset: Olist Brazilian E-Commerce
Database: PostgreSQL (schemas: `bronze`, `silver`)

---

## 1. Summary table

| Bronze table | Silver table | Cleaning done | Rows bronze → silver | Rows dropped |
|---|---|---|---|---|
| `bronze.customers` | `silver.customers` | Trim, empty text to NULL, lower city, upper state, remove duplicate `customer_id` | 99,441 → 99,441 | 0 |
| `bronze.geolocation` | `silver.geolocation` | Trim, cast lat/lng to NUMERIC(12,8), lower city, upper state, `DISTINCT` | 1,000,163 → 738,327 | 261,836 (duplicates) |
| `bronze.order_items` | `silver.order_items` | Trim, cast to INT / NUMERIC / TIMESTAMP, key columns must not be NULL | 112,650 → 112,650 | 0 |
| `bronze.order_payments` | `silver.order_payments` | Trim, cast types, lower payment type, remove bad rows | 103,886 → 103,875 | 11 |
| `bronze.order_reviews` | `silver.order_reviews` | Trim, clean spaces and line breaks in comments, cast dates, score 1 to 5 | 99,224 → 99,224 | 0 |
| `bronze.orders` | `silver.orders` | Trim, lower status, cast all dates to TIMESTAMP | 99,441 → 99,441 | 0 |
| `bronze.products` | `silver.products` | Trim, cast to INT, fix column names, add English category, weight 0 set to NULL | 32,951 → 32,951 | 0 |
| `bronze.sellers` | `silver.sellers` | Trim, lower city, upper state, fix messy city names | 3,095 → 3,095 | 0 |
| `bronze.product_category_name_translation` | (no silver table) | Used inside the products load | (add count) → n/a | n/a |

---

## 2. Rules used in every table

- `TRIM` on all text columns.
- `NULLIF(..., '')` so empty text becomes a real NULL.
- Cast text to the correct type (INT, NUMERIC, TIMESTAMP). Bronze stores everything as text.
- Rows with a missing key (for example `order_id`) are removed.
- Each silver table has a primary key and a `dwh_load_ts` column.
- Each load runs inside `BEGIN ... COMMIT`, so a failed load does not leave an empty table.
- IDs are not lowercased as they are already lowercase hash values.

---

## 3. Decisions

### customers
- No rows dropped.
- `customer_id` is unique. `customer_unique_id` repeats when the same person orders again.
- Zip prefix is in varchar in silver. All values are 5 characters long. no padding needed here.

### geolocation
- 261,836 rows removed by DISTINCT. These are rows where all columns are the same (zip, latitude, longitude, city, state). Rows with the same zip code but different coordinates were kept.
- Latitude and longitude are stored as `NUMERIC(12,8)`. 8 decimals is about 1 millimetre, so location is not changed in any meaningful way. (better to use (9,6) 6 decimals is about 0.1 meter).
- Raw distinct rows were 738,332, but silver has 738,327. The 5 extra rows became equal after rounding and trimming.
- City names keep their accents (for example `são josé do rio pardo`).


### order_items
- No rows dropped.
- `price` must not be empty. If a price is missing, the row is removed. No rows were removed, because all prices were present.
- Primary key is (`order_id`, `order_item_id`).

### order_payments
- 11 rows removed:
  - 3 rows with `payment_type = 'not_defined'` (not a real payment type)
  - 2 rows with `payment_installments < 1` (an installment count must be at least 1)
  - 6 rows with `payment_value <= 0` (a payment of zero or less has no meaning for sales)
- Primary key is (`order_id`, `payment_sequential`).

### order_reviews
- No rows dropped.
- `review_id` is not unique by itself, because the same review id can appear on different orders.
- Comment title and message: extra spaces and line breaks are collapsed into one space. Comments that are empty become NULL. Many reviews have no comment, and this is normal.
- Comment text is not lowercased, to keep the original words.
- Review score must be from 1 to 5. All rows passed.

### orders
- No rows dropped.
- Many date columns are NULL on purpose. For example, an order that is not delivered yet has no delivery date. These rows are kept.
- `order_id` is unique and the primary key will stop the load if a duplicate appears.
- Known issue: 8 orders have status `delivered` but no delivery date. They are kept in silver and will be flagged in the data quality checks.
- Order status has 8 values (delivered, shipped, canceled, unavailable, invoiced, processing, created, approved).

### products
- No rows dropped.
- Source column names have a spelling mistake (`lenght`). They are renamed in silver to `name_length` and `description_length`.
- Added a new column `category_name_en` (English category name):
  - Use the English name from the translation table when there is one.
  - Two categories had no translation: `pc_gamer` stays as it is, and `portateis_cozinha_e_preparadores_de_alimentos` was mapped by hand to `portable_kitchen_and_food_preparers`.
  - If the category is missing, the value is `unknown`.
- 610 products have no category (`unknown`). They also have no name length, description length or photos in the source. These are left as NULL.
- 4 products had weight = 0. The weight was changed to NULL, but the product was kept. If the product were dropped, `order_items` rows could point to a product that does not exist.

### sellers
- No rows dropped.
- The seller city column had typing mistakes. About 28 values were fixed:
  - city plus state or country (`lages - sc`, `auriflama/sp`) → city only
  - not a city (a number, an email address) → NULL
  - short names (`sbc` → `sao bernardo do campo`, `sp` → `sao paulo`)
  - wrong apostrophe (`d´oeste` → `d'oeste`)
- After cleaning, only 3 names with an apostrophe are left.

### product_category_name_translation
- No silver table was built. The English names are already inside `silver.products`, so a separate table would not add anything.
- The bronze table is still needed, because the products load joins to it.

---

## 4. Checks done after loading

| Check | Result |
|---|---|
| Bronze and silver row counts compared for every table | Done, see summary table |
| Zip code length is always 5 | Passed |
| State length is always 2 | Passed |
| Payment types after cleaning | 4 types: credit_card, boleto, voucher, debit_card |
| Review score is between 1 and 5 | Passed |
| Products with weight <= 0 | 0 after fix |
| Messy city names in sellers | 0 after fix |

