"""Silver layer: clean bronze.* into silver.* using sql/silver/cleaning/<table>.sql."""
import time

from .config import SQL_DIR
from .db import get_connection, run_sql_file
from .decorators import log_step
from .logger import get_logger

log = get_logger(__name__)

SILVER_TABLES = [
    "customers",
    "geolocation",
    "order_items",
    "order_payments",
    "order_reviews",
    "orders",
    "products",
    "sellers",
]


@log_step
def load_silver():
    """One transaction per table (same as the old begin/commit blocks)."""
    with get_connection() as conn:
        for table in SILVER_TABLES:
            path = SQL_DIR / "silver" / "cleaning" / f"{table}.sql"
            t0 = time.perf_counter()
            rows = run_sql_file(conn, path)
            conn.commit()
            log.info("silver.%s loaded: %s rows (%.2fs)", table, f"{rows:,}", time.perf_counter() - t0)
