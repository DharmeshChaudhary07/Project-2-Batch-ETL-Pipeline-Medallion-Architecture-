"""Bronze layer: raw CSV -> bronze.* tables (all TEXT columns)."""
from pathlib import Path

from .config import DATA_DIR
from .db import get_connection
from .decorators import log_step
from .logger import get_logger

log = get_logger(__name__)

# bronze table -> CSV file name
BRONZE_FILES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}


def _load_table(conn, table: str, csv_path: Path) -> int:
    if not csv_path.exists():
        raise FileNotFoundError(f"CSV not found for bronze.{table}: {csv_path}")
    with conn.cursor() as cur:
        cur.execute(f"truncate bronze.{table}")
        # COPY ... FROM STDIN streams the file from the client, so it works the same
        # on your Mac and inside Docker (server-side COPY would need the file on the DB host).
        with open(csv_path, encoding="utf-8") as f:
            cur.copy_expert(f"copy bronze.{table} from stdin with (format csv, header true)", f)
        cur.execute(f"select count(*) from bronze.{table}")
        return cur.fetchone()[0]


@log_step
def load_bronze():
    """Load all 9 tables in ONE transaction: if any file fails, bronze keeps its old data."""
    with get_connection() as conn:
        for table, filename in BRONZE_FILES.items():
            rows = _load_table(conn, table, DATA_DIR / filename)
            log.info("bronze.%s loaded: %s rows", table, f"{rows:,}")
